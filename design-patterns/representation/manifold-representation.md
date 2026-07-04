# Manifold Representation（流形表示）

## 适用问题
当输入数据虽然在高维空间中，但实际分布在低维流形上时使用。典型场景：
(1) 自然语言 token 的语义空间——虽维度 d=4096，但有效自由度远小于 d；
(2) 多模态对齐——文本和图像分布在不同的流形上，需要对齐；
(3) 专家特征空间——每个专家处理流形的不同局部区域；
(4) 降维/压缩——利用流形低维本质减少参数量。
核心诉求：**利用数据的低维流形结构，提高表示效率和泛化能力**。

## 数学思想来源
- 透镜：lenses/geometry.md（黎曼几何、测地线、曲率）、lenses/information.md（内在维度）
- 知识：knowledge-base/fundamentals/geometry.md（流形、切空间、指数映射）、
  knowledge-base/fundamentals/linear-algebra.md（SVD、低秩近似、PCA）

## 需要的数学知识
- **流形假设**：数据 x ∈ R^D 实际分布在 d << D 维的光滑流形 M 上
  局部可用切空间 T_pM ≈ R^d 线性近似
- **局部坐标卡 (Chart)**：φ: U ⊂ M → R^d，将流形局部映射到低维欧氏空间
  多个坐标卡 {φ_i} 构成图册（Atlas），覆盖整个流形
- **测地线距离**：d_M(p,q) = inf ∫‖γ'(t)‖dt，流形上两点间最短路径
  近似计算：k-NN 图上 Dijkstra/Isomap
- **指数映射/对数映射**：
  exp_p: T_pM → M（切空间到流形），log_p: M → T_pM（流形到切空间）
  用于在切空间中做线性运算后映射回流形

## AI 模块形式
```
模块：ManifoldRepresentation
输入：X ∈ R^{N×D}（高维输入），目标流形维度 d << D

方法1 - 局部线性嵌入（Chart-based）：
  // 将 d 维流形分成 K 个局部区域，每个区域用线性投影
  assignments = cluster(X, K)         // 将输入分配到 K 个局部区域
  for k in range(K):
    z_k = W_k @ X[assignments==k] + b_k  // 局部线性投影 d×D → d×d
  // 等效为 MoE：K 个"chart expert"各负责流形一个局部
  z = Σ_k g_k(x) · (W_k @ x + b_k)   // g_k 为 chart 分配权重

方法2 - 测地线保持损失（全局结构保持）：
  // 保持高维空间的测地线距离在低维表示中不变
  D_high = geodesic_distance(X, k_nn=10)   // k-NN 图上最短路
  D_low = pairwise_distance(Z)              // 低维表示的欧氏距离
  L_geo = ‖D_high - D_low‖_F² / N²         // Sammon mapping
  // 或用 t-SNE 式 KL 散度：
  p_ij = exp(-D_high²/2σ²) / Σ  // 高维亲和度
  q_ij = 1/(1+D_low²) / Σ        // 低维 t 分布亲和度
  L_tsne = KL(P ‖ Q)

方法3 - 黎曼优化（直接在流形上优化）：
  // 参数约束在 Stiefel/Grassmann 流形上
  W ∈ St(d, r)  i.e. W^T W = I_r           // 正交约束
  // Riemannian SGD：
  grad_euclidean = ∇f(W)
  grad_riemannian = grad_euclidean - W @ (W^T @ grad_euclidean)  // 投影到切空间
  W = retract(W, -lr · grad_riemannian)     // 缩回映射到流形
  // retract 可用 QR 分解或 Cayley 变换实现
```

## 可实现结构
- **Chart MoE**：K 个局部线性投影 + softmax 门控 → 天然与 MoE 框架集成
- **流形正则化**：L_manifold = tr(Z^T L Z) / N²，L 为图拉普拉斯，Z 为表示
  鼓励相邻样本的表示相近
- **内在维度估计**：用 MLE 或 two-norm 方法估计数据的有效维度 d*
- **自适应 d**：不同区域的局部维度不同，用 PCA 局部估计

## GPU 可行性
- **张量化**：局部线性投影为 GEMM (d×D)@(D×N)；图拉普拉斯正则为 SpMM
- **GEMM 可映射**：Chart MoE 的 K 个线性投影为 batched GEMM (K×d×D)@(D×N)
- **复杂度**：k-NN 构建 O(N·D·log N) 需 FAISS；流形正则 O(N²) 需采样近似
- **显存与 KV-Cache**：K 个 chart 参数 K·d·D 通常 <10MB；k-NN 图 N·k·4 bytes
- **低精度稳定**：距离计算和 exp 在 fp16 下需注意数值范围；黎曼 retract 建议 fp32
- **并行与通信**：K 个 chart 独立计算，完美并行；k-NN 搜索用 FAISS GPU 加速
- **稀疏结构**：k-NN 图天然稀疏，流形正则 L 为稀疏矩阵，SpMM 加速
- **算子融合**：chart 内的 matmul+bias+activation 可融合；门控 softmax+weighted-sum 可融合

## 论文表述方式
"基于流形假设将 D 维 token 表示约束到 d*（内在维度估计）维子流形上，
通过 K 个局部坐标卡（Chart MoE）实现分段线性近似，配合图拉普拉斯流形正则
保持全局测地线结构，理论上保证嵌入误差以 O(N^{-2/d*}) 收敛。"

## 风险
- 内在维度 d* 估计不准确导致过度压缩或维度浪费
- k-NN 图构建在大规模数据下计算代价高，需采样或近似
- 流形正则的 N² 复杂度限制 batch size，需 mini-batch 采样
- 局部 chart 边界处表示不连续，需重叠区域和平滑过渡
