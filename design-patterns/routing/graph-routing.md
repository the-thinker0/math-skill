# Graph Routing（图路由）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当模块/专家之间存在已知的或可学习的拓扑结构时使用。典型场景：
(1) 层次化 MoE——专家按树形结构组织，路由沿树的边进行；
(2) Pipeline/串行路由——输入按 DAG 顺序经过多个处理阶段；
(3) 空间/时间相关路由——相邻位置的 token 倾向路由到相近专家（空间连续性）；
(4) 知识图谱引导的专家选择——专家按概念图谱组织。
核心诉求：**利用结构化先验约束路由决策，减少搜索空间**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（图拉普拉斯、谱图论）、../../lenses/probabilistic.md（消息传递、信息流）
- 知识：../../knowledge-base/matrix-analysis/projection.md（邻接矩阵、谱分解）、
  ../../knowledge-base/optimization/lagrangian-duality.md（图上优化、扩散过程）

## 需要的数学知识
- **图拉普拉斯**：L = D - A（组合）或 L_sym = D^{-1/2} L D^{-1/2}（归一化）
  特征分解 L = U Λ U^T 给出图的频域基，低频分量对应平滑信号
- **图扩散/Random Walk**：P = D^{-1}A 为转移矩阵，P^t 描述 t 步后的分布
  PageRank: π = α·P^T·π + (1-α)·v，平衡图结构与先验偏好
- **Graph Neural Network 消息传递**：
  h_i^{(l+1)} = σ(Σ_{j∈N(i)} W^{(l)} h_j^{(l)} / √(d_i·d_j))
  等价于一次稀疏矩阵乘法 L_sym · H · W
- **Min-Cut 谱聚类**：min cut(A,B) s.t. vol(A)=vol(B) → 近似解为 L 的 Fiedler 向量

## AI 模块形式
```
模块：GraphRouter
输入：token 表示 X ∈ R^{N×d}，专家图 G = (V, E) 其中 |V|=K

方法1 - 图扩散路由（预计算）：
  A ∈ R^{K×K}   // 专家邻接矩阵（预定义或可学习）
  P = softmax(A / τ, dim=-1)   // 归一化转移概率
  P_t = matrix_power(P, t)     // t 步扩散，t=2~5
  // 路由分数 = 初始分数 × 扩散矩阵
  score_init = X @ W_gate      // N×K，标准 gate
  score_final = score_init @ P_t  // N×K，图扩散平滑
  // 一次 GEMM (N×K)@(K×K) 即可融入图结构

方法2 - GNN 路由（可学习图结构）：
  H_0 = expert_embeddings  // K×d
  H_1 = ReLU(L_norm @ H_0 @ W_1)  // 1层 GCN
  H_2 = L_norm @ H_1 @ W_2         // 2层 GCN
  score = X @ H_2^T                // N×K 路由分数
  // 图结构通过 A 的可学习参数化端到端更新

方法3 - 层次树路由（O(log K) 复杂度）：
  // 专家组织为二叉树，每个内部节点为二分类器
  for level in range(depth):       // depth = log₂(K)
    direction = sigmoid(X @ w_level + b_level)  // 左/右子树选择
    path_prob *= direction          // 路径概率累积
  // 总计算量：O(N·d·log K) vs 标准 MoE 的 O(N·d·K)
```

## 可实现结构
- **稀疏邻接矩阵**：用 torch.sparse 存储 A，稀疏 matmul 替代 dense
- **预计算扩散核**：P_t 在训练初期固定，周期性重计算（每 epoch 一次）
- **图结构学习**：A = softmax(MLP(E_i ⊕ E_j)) 参数化边权重，端到端学习
- **层次树实现**：用完全二叉树的数组表示，level-wise 向量化

## GPU 可行性
- **D1[v]**：GCN 层为稀疏矩阵×稠密矩阵 (SpMM)，PyTorch 和 cuSPARSE 均支持
- **D2[v]**：方法1 的 score_init@P_t 为标准 GEMM (N×K)@(K×K)
- **D3[v]**：方法1 O(N·K²) 扩散 + O(N·K·d) gate；方法3 O(N·d·log K) 显著优于 O(N·d·K)
- **D4[v]**：A 矩阵 K×K 稀疏存储；层次树参数 d×log K 极小
- **D5[v]**：概率矩阵 P 和 softmax 在 fp16 下需注意归一化精度
- **D6[v]**：GNN 消息传递可批量并行；层次树同层节点独立可并行判断
- **D7[v]**：图邻接矩阵天然稀疏（度 << K），SpMM 加速比 O(K²) 到 O(K·avg_deg)
- **D8[v]**：GCN 的 L_norm@H@W 可融合为单次稀疏 GEMM

## 论文表述方式
"利用专家间的层次树/图拓扑结构，将路由决策从 O(N·K) 的平铺搜索压缩为 O(N·log K) 的
树遍历或 O(N·K·avg_deg) 的图扩散，Fiedler 谱分析表明图的代数连通度 λ₂ 直接控制
路由的多样性-一致性权衡。"

## 风险
- 图结构先验不正确时，路由被误导到次优专家
- 图扩散过度平滑（t 过大）导致所有 token 路由到同一专家（oversmoothing）
- 可学习图结构增加参数量和过拟合风险
- 层次树的二分类误差逐层累积，depth 过深时性能下降
