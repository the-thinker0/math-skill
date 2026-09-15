# Optimal Transport Routing（最优传输路由）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当需要将一组输入 token/样本 分配到一组专家/子模块，且追求全局最优的匹配代价时使用。
典型场景：(1) 负载均衡的 MoE 路由——将 N 个 token 分配到 K 个专家，代价矩阵为负相似度；
(2) 跨层特征对齐——将第 l 层特征传输到第 l+1 层的最优子集；
(3) 多任务样本分配——将 batch 中的样本分配到最合适的任务头。
核心诉求：**全局最优分配，而非贪心逐点决策**。

## 数学思想来源
- 透镜：../../lenses/variational.md（凸优化、对偶理论）、../../lenses/geometric.md（Wasserstein 距离）
- 知识：../../knowledge-base/probability/optimal-transport.md（Kantorovich 松弛、Sinkhorn、Wasserstein 距离）、
  ../../knowledge-base/optimization/lagrangian-duality.md（对偶理论、约束优化）、
  ../../knowledge-base/probability/entropy.md（熵正则化、边际约束）

## 需要的数学知识

- $N$ 个 token、$K$ 个专家取概率边缘 $a_i=1/N$、$b_k\ge0$、$\sum_k b_k=1$。平衡 OT 施加的是**等式** $P\mathbf1=a$、$P^T\mathbf1=b$。
- Sinkhorn 对正 Gibbs 核求解 $\min_{P\in\Pi(a,b)}\langle C,P\rangle-\epsilon H(P)$。有限迭代误差依赖成本范围、边缘、正则量及容差；没有脱离具体定理的通用 $O(1/\epsilon^2)$ 迭代数。
- 容量上界 $c_k$ 对应 $\sum_i P_{ik}\le c_k/N$，需不等式/非平衡或容量约束形式。设 $b=c/\sum c$ 会约束归一化目标负载，不只是容量上界。
- 即便软计划边缘可行，逐行 argmax/top-k 也可能超容量；硬可行性需容量感知舍入或最小费用流/分配步骤。
- Gromov–Wasserstein 用于缺少共同度量对应时比较成对关系成本；仅坐标维数不同并不强制使用它。

## AI 模块形式

```python
C = -X @ E.T                         # N x K；明确成本尺度
log_K = -C.float() / epsilon
log_a = full((N,), -log(N))
log_b = log(target_load_probs)       # 正的K维向量，和为1
log_v = zeros(K)
for _ in range(T):
    log_u = log_a - logsumexp(log_K + log_v[None, :], dim=1)
    log_v = log_b - logsumexp(log_K + log_u[:, None], dim=0)
P = exp(log_u[:, None] + log_K + log_v[None, :])
row_error = norm(P.sum(1) - exp(log_a), p=1)
col_error = norm(P.sum(0) - exp(log_b), p=1)
route_probs = P / exp(log_a)[:, None] # 专家条件权重，行和约为1
soft_output = route_probs @ E
hard_assignment = capacity_aware_round(P, integer_capacities)
```
检查总整数容量及舍入可行性。平衡均匀边缘为 $b_k=1/K$，不是 $N/K$。方阵均匀边缘时是 $NP$ 双随机；$P$ 自身行列和为 $1/N$。小 $\epsilon$ 可逼近稀疏无正则计划，但只在适当缩放的方形分配问题中才是置换矩阵。

## 可实现结构
- **Sinkhorn 层**：自定义 autograd Function，前向做 Sinkhorn 迭代，反向用隐函数定理求梯度
- **迭代次数固定**：T=10 次固定迭代 → 可展开为计算图（unrolled variational）
- **log-domain 稳定化**：将 Sinkhorn 转换到 log 域避免 exp 溢出：
  log_u = log_a - logsumexp(log_K + log_v, dim=1)
- **Batch OT**：每个 micro-batch 独立求解，并行化 Sinkhorn 迭代

## GPU 可行性

- **D1/D2[~]**：成本构造用 GEMM；稳定 Sinkhorn 使用顺序依赖的行/列 log-sum-exp 归约。
- **D3[~]**：成本 $O(NKd)$ 加迭代 $O(TNK)$ 及舍入成本；测量达到目标残差所需步数，不指定通用固定 $T$。
- **D4[~]**：两个 fp32 $N\times K$ 阵需 $8NK$ 字节，尚未计中间步。展开反传可存 $O(TNK)$；隐式微分需要正则性与准确求解。
- **D5[~]**：使用对数域 fp32，随 $\epsilon$ 减小监控边缘残差。
- **D6[~]**：独立批次可并行；行列更新互相依赖。跨设备全局负载约束需要通信。
- **D7/D8[~]**：稀疏近似及融合归约会改变实现，可能影响可行性；同时验证边缘及最终硬容量。

## 论文表述方式

“我们求解边缘目标明确的熵正则传输松弛，报告有限迭代后的残差。容量感知舍入得到单独检查的硬分配；报告其成本增加、溢出、延迟及任务质量变化。”

## 风险
- ε 过小导致 Sinkhorn 数值不稳定（exp 溢出），需用 log-domain 或增大 ε
- T 次迭代的固定展开限制了解精度，过多 T 增加延迟
- N×K 代价矩阵在 N, K 都很大时内存压力显著（N=32K, K=256 → 32MB）
- 训练-推理不一致：软分配 vs 硬分配的性能 gap
