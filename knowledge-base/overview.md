# 数学激活锚点索引 / Mathematical Activation Anchor Index

> knowledge-base/ 不是封闭百科，而是高频数学结构的激活入口。每张卡片是一个激活锚点，回答：激活什么数学概念、连接哪些更深知识、可翻译成哪些 AI 设计动作、不足时应该往哪里扩展。

## 知识库结构

知识库按领域组织，共 9 个目录、37 张知识卡片：其中 8 个共享数学领域含 33 张锚点，密码学领域含 4 张专属锚点。共享数学卡按需给出 AI/工程翻译；密码学卡优先保持安全定义、构造与归约语义，不强塞 AI 或 GPU 模板。

| 领域 | 目录 | 卡片 | 典型应用 |
|------|------|------|---------|
| 矩阵分析 | `matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation | LoRA、谱归一化、条件数监控 |
| 最优化 | `optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method | GAN minimax、权重约束、Muon 优化器 |
| 微分几何 | `differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection | 自然梯度、流形优化、K-FAC |
| 李理论 | `lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance | 等变网络、SO(3) 参数化、球谐特征 |
| 拓扑 | `topology/` | persistent-homology, euler-characteristic, fundamental-group | 拓扑正则、隐空间监控 |
| 概率与信息 | `probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information | VAE、知识蒸馏、泛化界 |
| 信息几何 | `information-geometry/` | natural-gradient, fisher-metric | 自然梯度下降、Fisher-Rao 度量 |
| 代数几何 | `algebraic-geometry/` | grassmannian-plucker, sheaf-cohomology | 子空间参数化、局部到整体一致性 |
| 密码学（领域专属） | `cryptography/` | prf-prg-owf, attack-game-framework, cca-cpa-ae-hierarchy, reduction-proof-template | 安全定义、构造、攻击游戏、归约证明 |

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

现有 33 个共享数学锚点与 4 个密码学锚点覆盖高频结构。当问题需要的工具不在其中时：

1. 查看对应领域的 `*/index.md`（如 `topology/index.md`），获取扩展概念和参考书方向
2. 进入根 `../SKILL.md` 中定义的**知识缺口协议**，生成临时知识卡
3. 不得回答"知识库未覆盖"或强行套用最相近卡片

> **Domain Router 提示**：纯密码问题先加载 `cryptography/` 的最小相关锚点；只有锚点不足或用户要求文献级深度时才查 `../references/books/`。共享数学锚点按需加载且不复制密码学语义。纯 AI 问题不因出现 “hash”“attack”“security”等单词就自动进入密码学路由。

## 领域扩展索引

每个领域有一个 `*/index.md`，列出：领域触发信号、核心锚点、扩展概念、参考书方向、临时激活规则。

| 领域 | 扩展索引 |
|------|---------|
| 矩阵分析 | `matrix-analysis/index.md` |
| 最优化 | `optimization/index.md` |
| 微分几何 | `differential-geometry/index.md` |
| 李理论 | `lie-theory/index.md` |
| 拓扑 | `topology/index.md` |
| 概率与信息 | `probability/index.md` |
| 信息几何 | `information-geometry/index.md` |
| 代数几何 | `algebraic-geometry/index.md` |
| 密码学 | `cryptography/index.md` |
