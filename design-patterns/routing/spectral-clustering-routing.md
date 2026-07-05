# Spectral Clustering Routing（谱聚类路由）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当需要基于 token/样本的内在相似性结构进行分组路由时使用。典型场景：
(1) 无监督专家分配——没有路由标签时，用谱聚类自动发现 token 的自然分簇；
(2) 自适应专家初始化——训练初期用谱聚类结果初始化专家参数；
(3) 输入感知的动态聚类——不同 batch 的 token 分布不同，路由应自适应；
(4) 多粒度聚类——不同层使用不同粒度的谱聚类（粗→细）。
核心诉求：**发现数据内在的簇结构，用于路由或专家初始化**。

## 数学思想来源
- 透镜：lenses/geometric.md（谱图论、拉普拉斯特征映射）、lenses/variational.md（松弛与近似）
- 知识：knowledge-base/matrix-analysis/projection.md（特征值分解、Rayleigh 商）、
  knowledge-base/differential-geometry/manifold.md（流形学习、图割）

## 需要的数学知识
- **谱聚类 (Ng-Jordan-Weiss)**：
  1. 构造相似度图 W_{ij} = exp(-‖x_i - x_j‖² / 2σ²)
  2. 计算归一化拉普拉斯 L_sym = I - D^{-1/2} W D^{-1/2}
  3. 取前 k 个最小特征向量 U_k ∈ R^{N×k}
  4. 对 U_k 的行做 k-means 得到 k 个簇
- **Nyström 近似**：当 N 太大无法计算完整 W 时，采样 m<<N 个点
  W ≈ C · W_m^{-1} · C^T，将特征分解降维到 m×m
- **谱松弛连续化**：离散聚类分配 → 连续特征向量 → 可微路由
  用 softmax(U_k · W_proj) 替代硬 k-means 分配
- **幂迭代加速**：不需完整特征分解，只需前 k 个特征向量
  用 Lanczos/Arnoldi 迭代 O(N²·k·iter) 或 randomized SVD O(N·k·log k)

## AI 模块形式
```
模块：SpectralClusterRouter
输入：X ∈ R^{N×d}，簇数 K

方法1 - 在线谱聚类路由（训练时周期性更新）：
  // 每 M 步更新一次聚类中心，推理时用最近邻
  W = exp(-cdist(X_sample, X_sample) / (2σ²))  // m×m 采样相似度
  L = I - D^{-1/2} W D^{-1/2}                    // 归一化拉普拉斯
  U_k = eigsh(L, k=K, which='SM')                // 前 K 个最小特征向量
  centers = kmeans(U_k, K)                        // K 个聚类中心
  // 路由：将新 token 投影到谱空间后分配
  proj = X @ W_proj                               // N→K 维投影（可学习）
  assignment = argmin(cdist(proj, centers))        // 最近中心分配

方法2 - 可微谱路由（端到端）：
  // 用 softmax 松弛替代硬分配
  sim_matrix = X @ X^T                             // N×N（或采样 m×m）
  A = exp(sim_matrix / τ)                          // 相似度图（可学习 τ）
  D_inv_sqrt = diag(1 / sqrt(sum(A, dim=1) + ε))
  L_norm = I - D_inv_sqrt @ A @ D_inv_sqrt         // 归一化拉普拉斯
  // 近似前 K 个特征向量（幂迭代 + 正交化）
  U_k = power_iteration_approx(L_norm, K, steps=5)  // N×K
  // 软分配
  cluster_logits = U_k @ W_cluster                  // N×K（可学习投影）
  route_probs = softmax(cluster_logits / τ_route)    // 软路由概率

方法3 - 锚点谱聚类（大规模）：
  anchors = kmeans_pp(X, m)                         // m 个锚点，m << N
  Z = exp(-cdist(X, anchors) / (2σ²))               // N×m 亲和矩阵
  L_anchor = I - D_z^{-1/2} Z^T Z D_z^{-1/2}        // m×m 拉普拉斯
  U_k = eigsh(L_anchor, K)                          // m×K 特征向量
  route = Z @ U_k @ W_proj                           // N×K 路由分数
```

## 可实现结构
- **周期性离线聚类**：每 N_step 步收集 token 表示 → 离线谱聚类 → 更新路由表
- **Nyström 采样**：随机采样 m=1024 个代表点，将 N×N 问题降为 m×m
- **幂迭代实现**：5~10 步幂迭代 + Gram-Schmidt 正交化，GPU 友好
- **渐进式训练**：初期用 k-means 粗路由 → 中期谱聚类精化 → 后期可微调路由网络

## GPU 可行性
- **张量化**：相似度矩阵 X@X^T 为 GEMM；拉普拉斯构造为 element-wise + 对角矩阵
- **GEMM 可映射**：方法3 的 Z^T@Z 为 GEMM (m×N)@(N×m)；Z@U_k 为 GEMM (N×m)@(m×K)
- **复杂度**：完整谱聚类 O(N²·K) 不可扩展；Nyström O(N·m·K+m³)；幂迭代 O(N²·K·T)
- **显存与 KV-Cache**：N×N 相似度矩阵在 N>4096 时 >64MB，必须采样降维
- **低精度稳定**：特征分解建议 fp32；exp(-dist/σ²) 在 fp16 下需 clip distance
- **并行与通信**：幂迭代的 matvec 高度并行；k-means 的 assign+update 可批并行
- **稀疏结构**：k-NN 图替代全连接图，W 稀疏度 >95%，SpMM 加速
- **算子融合**：D^{-1/2}@A@D^{-1/2} 的对角缩放可融合；cdist+exp+normalize 可融合

## 论文表述方式
"利用谱聚类的连续松弛实现可微路由：构造 token 相似度图的归一化拉普拉斯，
通过 Nyström 近似将 O(N²) 特征分解降为 O(Nm+K³)，配合幂迭代实现 GPU 友好的
在线谱聚类，聚类质量以 Normalized Cut 衡量保证 O(√(log N/K)) 的近似比。"

## 风险
- N×N 相似度矩阵的显存和计算在长序列下不可扩展，必须采样或 k-NN 稀疏化
- 特征分解不可微（特征值重合时梯度未定义），端到端训练需松弛或 stop-gradient
- 簇数 K 需先验指定，且 K 变化时需重新聚类
- σ（带宽参数）对聚类质量敏感，过小导致孤立点，过大导致合并
