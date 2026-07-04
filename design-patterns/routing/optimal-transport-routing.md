# Optimal Transport Routing（最优传输路由）

## 适用问题
当需要将一组输入 token/样本 分配到一组专家/子模块，且追求全局最优的匹配代价时使用。
典型场景：(1) 负载均衡的 MoE 路由——将 N 个 token 分配到 K 个专家，代价矩阵为负相似度；
(2) 跨层特征对齐——将第 l 层特征传输到第 l+1 层的最优子集；
(3) 多任务样本分配——将 batch 中的样本分配到最合适的任务头。
核心诉求：**全局最优分配，而非贪心逐点决策**。

## 数学思想来源
- 透镜：lenses/variational.md（凸优化、对偶理论）、lenses/geometric.md（Wasserstein 距离）
- 知识：knowledge-base/optimization/lagrangian-duality.md（线性规划、Sinkhorn 算法）、
  knowledge-base/probability/entropy.md（耦合分布、边缘约束）

## 需要的数学知识
- **离散最优传输**：min_{P∈Π(μ,ν)} ⟨C, P⟩ = Σ_{ij} C_{ij} P_{ij}
  其中 Π(μ,ν) = {P ≥ 0 : P·1 = μ, P^T·1 = ν} 为边际约束耦合集
- **熵正则化 Sinkhorn**：min ⟨C,P⟩ - ε·H(P) → P* = diag(u)·exp(-C/ε)·diag(v)
  通过交替缩放行/列（Sinkhorn-Knopp）求解，收敛速度 O(1/ε²)
- **Wasserstein-1 距离**：W_1(μ,ν) = min_{π∈Π} E_π[‖x-y‖] = sup_{‖f‖_L≤1} E_μ[f] - E_ν[f]
  Kantorovich-Rubinstein 对偶，用于连续分布匹配
- **Gromov-Wasserstein**：当源/目标空间维度不同时，min 结构保持的传输代价

## AI 模块形式
```
模块：OptimalTransportRouter
输入：token 表示 X ∈ R^{N×d}，专家嵌入 E ∈ R^{K×d}，容量约束 cap ∈ R^K

代价矩阵：C_{ik} = -sim(X_i, E_k)  或  ‖X_i - E_k‖²  (N×K)

Sinkhorn 路由（熵正则化）：
  K_mat = exp(-C / ε)              // Gibbs kernel, ε=0.05~0.1
  for t = 1..T:                     // T=5~20 次迭代
    u = a / (K_mat @ v)            // 行缩放，a = 1/N
    v = b / (K_mat^T @ u)          // 列缩放，b = cap/sum(cap)
  P = diag(u) @ K_mat @ diag(v)   // 最优传输计划，双随机矩阵
  assignment = argmax(P, dim=1)    // 硬分配（推理时）
  // 训练时：weighted_features = P @ E  (软分配，可微)

容量约束（b 向量）：
  b_k = total_tokens / K           // 均匀分配
  b_k = α·uniform + (1-α)·learned  // 学习非均匀分配
```

## 可实现结构
- **Sinkhorn 层**：自定义 autograd Function，前向做 Sinkhorn 迭代，反向用隐函数定理求梯度
- **迭代次数固定**：T=10 次固定迭代 → 可展开为计算图（unrolled optimization）
- **log-domain 稳定化**：将 Sinkhorn 转换到 log 域避免 exp 溢出：
  log_u = log_a - logsumexp(log_K + log_v, dim=1)
- **Batch OT**：每个 micro-batch 独立求解，并行化 Sinkhorn 迭代

## GPU 可行性
- **张量化**：Sinkhorn 核心为矩阵向量乘法 K@v (N×K)·(K×1)，标准 GEMV
- **GEMM 可映射**：C 的计算 X@E^T 为 GEMM (N×d)@(d×K)；Sinkhorn 迭代为 GEMV
- **复杂度**：O(N·K·T) 其中 T=10~20，当 N=2048, K=64 时约 2.6M FLOPs，极小
- **显存与 KV-Cache**：存储 C(N×K) 和 P(N×K)，N=2048,K=64 时约 1MB
- **低精度稳定**：Sinkhorn 在 fp16 下 exp(-C/ε) 可能溢出，建议 log-domain + fp32
- **并行与通信**：batch 维度独立；Sinkhorn 迭代为顺序依赖，但每次迭代的 matvec 高度并行
- **稀疏结构**：ε→0 时 P 趋于稀疏（permutation matrix），可用 top-k 近似加速
- **算子融合**：exp → matvec → division 的 Sinkhorn 单步可融合为 CUDA kernel

## 论文表述方式
"将 token-to-expert 路由建模为熵正则化最优传输问题，通过 Sinkhorn-Knopp 算法在 T=10 次
迭代内求得 ε-近似最优的双随机分配矩阵，理论保证传输代价在 O(ε·log N) 内收敛到全局最优，
同时通过边际约束 b 精确控制各专家的负载上限。"

## 风险
- ε 过小导致 Sinkhorn 数值不稳定（exp 溢出），需用 log-domain 或增大 ε
- T 次迭代的固定展开限制了解精度，过多 T 增加延迟
- N×K 代价矩阵在 N, K 都很大时内存压力显著（N=32K, K=256 → 32MB）
- 训练-推理不一致：软分配 vs 硬分配的性能 gap
