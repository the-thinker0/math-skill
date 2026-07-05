# 数学知识库导航 / Knowledge Base Navigation

> 本文件是 v3 知识库的索引，帮助你从问题类型找到具体的知识卡片。

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

## 与思想透镜的关系

思想透镜（`../lenses/`）负责"用什么视角看问题"，知识库负责"提供具体数学工具"。典型链路：

```
透镜诊断 → 知识卡片提供工具 → 设计模式翻译成 AI 模块
```

深入查阅时，`../references/books/*.md` 提供 7 本书的蒸馏稿。
