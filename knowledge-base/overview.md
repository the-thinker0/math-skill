# 数学激活锚点索引 / Mathematical Activation Anchor Index

> knowledge-base/ 不是封闭百科，而是高频数学结构的激活入口。每张卡片是一个激活锚点，回答：激活什么数学概念、连接哪些更深知识、可翻译成哪些 AI 设计动作、不足时应该往哪里扩展。

## 知识库结构

知识库按数学领域组织，共 7 个领域、31 张知识卡片。每张卡片包含：最小定义、核心公式、适用问题、AI 设计翻译、工程可行性、风险与失效条件。

| 领域 | 目录 | 卡片 | 典型应用 |
|------|------|------|---------|
| 矩阵分析 | `matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation | LoRA、谱归一化、条件数监控 |
| 最优化 | `optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method | GAN minimax、权重约束、Muon 优化器 |
| 微分几何 | `differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection | 自然梯度、流形优化、K-FAC |
| 李理论 | `lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance | 等变网络、SO(3) 参数化、球谐特征 |
| 拓扑 | `topology/` | persistent-homology, euler-characteristic, fundamental-group | 拓扑正则、隐空间监控 |
| 概率与信息 | `probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information | VAE、知识蒸馏、泛化界 |
| 信息几何 | `information-geometry/` | natural-gradient, fisher-metric | 自然梯度下降、Fisher-Rao 度量 |

## 从问题找知识卡

| 问题类型 | 推荐知识卡 |
|---------|-----------|
| 需要降维/压缩 | low-rank-approximation, projection |
| 需要约束优化 | constrained-optimization, lagrangian-duality |
| 需要等变/对称 | group-action, equivariance, representation |
| 需要稳定训练 | matrix-perturbation, positive-semidefinite, fisher-information |
| 需要流形参数化 | manifold, riemannian-optimization, tangent-space |
| 需要信息压缩 | information-bottleneck, entropy, kl-divergence |
| 需要拓扑正则 | persistent-homology, euler-characteristic |

## 当锚点不够时

现有 31 个锚点覆盖 AI 研究中最常用的数学结构。当问题需要的数学工具不在其中时：

1. 查看对应领域的 `index.md`（如 `topology/index.md`），获取扩展概念和参考书方向
2. 进入 SKILL.md 中定义的**知识缺口协议**，生成临时知识卡
3. 不得回答"知识库未覆盖"或强行套用最相近卡片

## 领域扩展索引

每个领域有一个 `index.md`，列出：领域触发信号、核心锚点、扩展概念、参考书方向、临时激活规则。

| 领域 | 扩展索引 |
|------|---------|
| 矩阵分析 | `matrix-analysis/index.md` |
| 最优化 | `optimization/index.md` |
| 微分几何 | `differential-geometry/index.md` |
| 李理论 | `lie-theory/index.md` |
| 拓扑 | `topology/index.md` |
| 概率与信息 | `probability/index.md` |
| 信息几何 | `information-geometry/index.md` |
