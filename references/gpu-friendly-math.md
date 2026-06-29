# GPU 友好性总清单 / GPU-Friendly Math Checklist

> 本文件是「GPU 可行性」验收门的**唯一权威来源（single source of truth）**。
> activator、16 个思想武器、`books/*.md`、以及 `../agents/math-critic.md` 都引用此处，不重复定义。
>
> This file is the single source of truth for the "GPU-feasibility" acceptance gate. The activator, the 16 weapons, the book references, and the math-critic all point here.

## 核心命题 / Core Proposition

**数学美 ≠ 可算。** 一个结构要真正进入现代 GPU 集群的训练与推理，必须同时满足两件事：

1. **数学正确（beautiful in math）**——结构自洽、可微（或可松弛为可微）、有正确性保证。
2. **硬件可行（friendly to GPU）**——能高效映射到 GPU 微架构（Tensor Core、显存层级、并行与互连）。

许多"看上去很美"的现代数学结构，一遇到 GPU 的并行计算与低精度数制误差就无法高性能运行。本清单就是把"GPU 可行性"变成**可逐项打分**的工程标准，避免把不可算的东西当成果。

## 八维检查 / The 8-Dimension Scorecard

对任何候选结构（算子、注意力变体、路由、正则项、压缩方案……）逐项评 `友好 / 可改造 / 不友好`，并给出改造建议。

| # | 维度 | 关键问题 | 友好 ✅ | 不友好 ❌ |
|---|------|---------|--------|----------|
| 1 | **张量化 / Tensorization** | 能否表达为稠密张量运算，避免逐元素不规则控制流？ | 批量张量代数 | 标量循环、数据相关分支 |
| 2 | **GEMM 可映射 / GEMM mappability** | 能否落到 矩阵乘 / batched GEMM / 卷积，吃满 Tensor Core？ | 可写成 GEMM 链 | 无法矩阵化的不规则运算 |
| 3 | **复杂度 / Complexity** | 前向/反向是否亚二次？随序列/规模如何增长？ | 线性/亚二次、可分块 | O(n²) 起的显存/算力爆炸 |
| 4 | **显存与 KV-Cache / Memory** | 峰值显存、激活/状态/KV 占用；能否压缩？ | 低秩/量化/块摘要可压 | 必须物化巨大中间张量 |
| 5 | **低精度稳定 / Low-precision** | fp16/bf16/fp8 下是否稳定、可确定性复现？ | 动态范围可控、数值稳健 | 灾难性抵消、病态、需 fp64 |
| 6 | **并行与通信 / Parallelism** | 能否跨 SM/设备并行？通信 vs 计算、能否 overlap？ | 高并行、通信可 overlap | 长串行递推、通信瓶颈 |
| 7 | **稀疏结构 / Sparsity** | 是结构化还是非结构化稀疏？ | 块/带状结构化稀疏 | 随机 gather/scatter |
| 8 | **算子融合 / Kernel fusion** | 能否融合、避免物化大中间量（FlashAttention 式）？ | 可融合、可重计算 | 频繁小 kernel、发散控制流 |

**评分结论**：只保留**数学美 AND（八维全部友好或可改造）**的候选；任何一维"不友好且不可改造"，要么改造、要么淘汰。

## 常见「美但不可算」反模式 / Anti-Patterns

- **稠密全局算子 O(n²)**：朴素 softmax 注意力随上下文爆炸。
- **非结构化稀疏 / 不规则图遍历**：随机访存毁掉访存局部性。
- **高精度依赖**：病态问题，需 fp64 才正确（绝大多数训练只有 bf16/fp16/fp8）。
- **串行递推**：长程依赖无法并行（朴素 RNN 式）。
- **频繁小 kernel + 控制流发散**：启动开销与 warp divergence 吃掉算力。
- **不可微 / 需离散搜索**：阻断端到端梯度训练。

## 改造手法 / Make-It-Computable Toolkit

把"美但不可算"改造成"既美又可算"的常用招式：

- **离散 → 连续松弛**：Gumbel-softmax；**热带半环（tropical semiring）上的分段线性**门控替代硬 Top-K。
- **块稀疏化**：块内 dense attention、块间结构化 sparse（如 DeepSeek CSA 式分块）。
- **低秩 / 投影压缩**：限制映射（restriction map）用低秩线性变换；**低秩基底式块摘要**压缩 KV-Cache（存基底而非 Plücker 坐标——后者低秩时反扩张）。
- **数值重参数化**：log-sum-exp、归一化、稳定 softmax，保证低精度稳定。
- **算子融合 / 重计算**：融合 kernel、activation recompute 省显存。
- **结构嵌入 GEMM**：把代数/几何变换写成**可学习线性映射**，使其天然落到 Tensor Core。

## 范例对照：Tropical Sheaf Attention / Worked Example

来自 `agentic-workflow.md` 引用的 auto-research 方向，演示一个**候选设计如何进入八维验证**：

| 组件 | 数学来源 | GPU 友好性 |
|------|---------|-----------|
| 热带门控 Tropical Gating | 热带半环分段线性 | 替代 Top-K：逐元素 max-plus——dim 1 ✅ 张量化 / dim 2 ❌ 非 Tensor Core GEMM（落 CUDA core）/ dim 3 ✅ 仅逐 token 门控亚二次（min-plus matmul 则 APSP-hard 非亚二次）；次可微，折点需 LogSumExp 软化（软化退回标准 softmax）|
| 胞腔层扩散 Cellular Sheaf Diffusion | 代数几何/拓扑（层、限制映射）| 每边低秩线性变换 = 小 GEMM（维度 2/4）|
| Čech 上同调正则 | 代数拓扑（一阶上同调 H¹）| 局部、廉价；作幻觉的代数判据（维度 3/8）|
| 低秩基底 KV 压缩（Plücker/Grassmannian 视角） | 射影几何 | 存基底而非 Plücker 坐标（后者低秩时反扩张）；块摘要候选，压缩率/误差/吞吐需实测（维度 4）|

使用时不要把上表当作已验证结论。正确做法是把每个组件写进 testplan：证明或估计复杂度，测峰值显存和吞吐，检查 bf16/fp8 稳定性，确认能否落到 GEMM / batched GEMM / fused kernel。只有实测和推导都通过后，才标为 "math beautiful × GPU friendly"。
