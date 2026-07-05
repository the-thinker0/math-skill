# 设计翻译原型库 / Design Translation Pattern Library

> 设计模式库不是完整模型仓库，而是"数学 → AI 设计"的翻译原型集合。
> 当现有模式不足时，应根据数学来源生成临时设计草案，并标记为 temporary design pattern，而不是拒绝或强行套用已有模式。
> 严谨性约定：复杂度、显存、FlashAttention/Tensor Core/KV-Cache 等工程结论需用 [v]/[~]/[x] 标注；未标注结论视为理论可行但需工程验证。

## 翻译范式

| 数学结构 | AI 设计方向 |
|---------|-----------|
| 投影/分解 | subspace split / conflict removal / low-rank attention |
| 谱结构 | token pruning / stability monitor / spectral filter |
| 信息论 | bottleneck loss / entropy gate / uncertainty routing |
| 几何/度量 | manifold representation / metric-aware update |
| 拓扑 | topology-preserving compression / obstruction loss |
| 对偶 | constrained optimization / primal-dual training |
| 对称/群 | equivariant features / weight sharing / orbit aggregation |
| 变分 | energy minimization / variational regularization |

## 与知识锚点的关系

```
知识锚点提供数学工具 → 设计模式翻译成 AI 模块
```

当知识锚点触发 Knowledge Gap Protocol 生成临时知识卡时，此处也应生成对应的临时设计草案。

## 按组件类型

| 组件 | 目录 | 模式数 |
|------|------|--------|
| 注意力 | `attention/` | 5 |
| 损失函数 | `loss/` | 5 |
| 路由 | `routing/` | 4 |
| 表示 | `representation/` | 4 |
| 压缩 | `compression/` | 4 |
