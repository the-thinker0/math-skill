# MoE Routing（混合专家路由）

## 适用问题
大规模模型中需要动态选择少量专家处理每个 token，以实现参数扩展而推理代价可控。
典型场景：(1) Sparse MoE 层——每个 token 选择 top-k 专家（k<<K）；
(2) Shared+Private 专家混合——共享专家处理通用特征，私有专家处理特异特征；
(3) 多粒度 MoE——不同层使用不同粒度的专家分工。
核心诉求：**稀疏激活、负载均衡、端到端可训练**。

## 数学思想来源
- 透镜：lenses/variational.md（离散优化松弛、Gumbel-Softmax）、lenses/probabilistic.md（信息论路由）
- 知识：knowledge-base/optimization/lagrangian-duality.md（组合优化、整数规划松弛）、
  knowledge-base/probability/entropy.md（混合模型、EM 算法）

## 需要的数学知识
- **混合模型 EM**：p(y|x) = Σ_k π_k(x) · p(y|x,θ_k)
  E 步估计责任 γ_{nk} = π_k·p(y_n|x_n,θ_k) / Σ_j π_j·p(y_n|x_n,θ_j)
  M 步更新专家参数 θ_k 和混合权重 π_k
- **Top-k 稀疏 Gate**：G(x) = Softmax(TopK(x·W_g))
  TopK 操作不可微，训练时用 noisy top-k 或 straight-through estimator
- **负载均衡辅助损失**：L_aux = α · K · Σ_k f_k · P_k
  f_k = 分配到专家 k 的 token 比例，P_k = 专家 k 的平均门控概率
- **Expert Choice Routing**：专家主动选择 token，而非 token 选择专家
  score_{ki} = sim(e_k, x_i)，每个专家选 top-C 个 token

## AI 模块形式
```
模块：MoERouter
输入：X ∈ R^{N×d}，K 个专家 {E_k}_{k=1}^K，每 token 激活 k 个专家

方法1 - Standard Top-K Gate (Switch/ST-MoE)：
  logits = X @ W_gate               // N×K，标准 GEMM
  noise = randn(N, K) * softplus(X @ W_noise)  // 可学习噪声，促进探索
  logits_noisy = logits + noise
  topk_vals, topk_idx = topk(logits_noisy, k, dim=-1)  // 选 top-k
  gate_weights = softmax(topk_vals, dim=-1)    // k 个专家的权重
  // 输出 = Σ_{j∈top-k} gate_weights_j · E_j(X)

方法2 - Shared + Private 双路路由：
  // Shared 专家始终激活，Private 专家 top-k 选择
  shared_out = E_shared(X)           // 所有 token 都过 shared 专家
  private_logits = X @ W_private_gate  // N×K_private
  private_topk = topk(private_logits, k_p)
  private_out = Σ_j gate_j · E_private_j(X)
  output = shared_out + private_out   // 或 concat + linear

方法3 - Expert Choice (Google 2022)：
  // 反转视角：每个专家选择 top-C 个 token
  affinity = E_embeddings @ X^T      // K×N，专家与 token 的亲和力
  for k in range(K):
    chosen_tokens = topk(affinity[k], C)  // 每个专家选 C=N/K 个 token
    expert_k.process(chosen_tokens)
  // 天然负载均衡：每个专家处理恰好 C 个 token

辅助损失：
  f = onehot(topk_idx).float().mean(dim=0)   // K 维，各专家负载
  P = softmax(logits, dim=-1).mean(dim=0)    // K 维，各专家平均概率
  L_aux = K * dot(f, P)                      // 均匀时为 1，不均匀时 >1
```

## 可实现结构
- **Gate 网络**：单层 Linear(d, K) + optional noise network
- **专家并行**：each expert on separate GPU，all-to-all 通信交换 token
- **容量因子**：cap = C_factor · N/K，超出容量的 token 走 residual（不被丢弃）
- **Router Z-loss**：L_z = α·mean(logsumexp(logits)²) 稳定 logits 幅度

## GPU 可行性
- **张量化**：gate logits = X@W_gate 为标准 GEMM (N×d)@(d×K)；专家计算为 batched GEMM
- **GEMM 可映射**：gate 1 次 GEMM；每个专家内部为标准 FFN（2 次 GEMM + activation）
- **复杂度**：gate O(N·d·K)；每专家 O(N·d·d_ff/k)；总 FLOPs ≈ 标准 FFN × k
- **显存与 KV-Cache**：K 个专家参数全存储但仅 k 个激活，激活显存 ≈ 标准 FFN × k
- **低精度稳定**：gate 的 softmax + top-k 在 fp16 安全；Router Z-loss 需 fp32 logsumexp
- **并行与通信**：专家并行需 all-to-all 通信（每个 GPU 收发 N/K 个 token），带宽敏感
- **稀疏结构**：top-k 路由天然稀疏（激活 k/K 的参数），稀疏度 = 1 - k/K
- **算子融合**：gate → top-k → softmax → weighted-sum 可融合；专家内 FFN 可 fuse

## 论文表述方式
"采用 noisy top-k 门控实现稀疏混合专家路由，激活 k/K 比例的参数以 O(k) 推理代价
获得 O(K) 参数容量，配合负载均衡辅助损失 L_aux = K·⟨f,P⟩ 和 Router Z-loss 保证
专家利用率 >95%，在同等 FLOPs 预算下相比 dense 模型提升 X% 性能。"

## 风险
- 负载不均衡：少数专家被过度选择（马太效应），其余专家得不到训练
- Top-k 操作不可微，straight-through 估计引入梯度偏差
- All-to-all 通信在多 GPU 下成为瓶颈，尤其 k>1 时通信量翻倍
- 噪声注入虽促进探索但增加训练方差，需 careful annealing
