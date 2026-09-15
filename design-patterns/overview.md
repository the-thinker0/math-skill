# 设计翻译原型库 / Design Translation Pattern Library

> 设计模式库不是完整模型仓库，而是"数学 → AI 设计"的翻译原型集合。
> 当现有模式不足时，应根据数学来源生成临时设计草案，并标记为 temporary design pattern，而不是拒绝或强行套用已有模式。
> 证据标注区分有支持结论[v]、待验证提案[~]、所述条件下不相容[x]及不适用维度[N/A]；见下文审查约定。

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

只有用户在设计/改造模块且现有模式不适配时，才生成临时设计候选；单纯知识查询无需附带新设计。

## 按组件类型

| 组件 | 目录 | 模式数 |
|------|------|--------|
| 注意力 | `attention/` | 5 |
| 损失函数 | `loss/` | 5 |
| 路由 | `routing/` | 4 |
| 表示 | `representation/` | 4 |
| 压缩 | `compression/` | 4 |

## 从原型到可审查模块

模式是候选算子，不是已测架构结果。`[v]` 需要明确假设下的定理或记录验证；`[~]` 是待验证方案，`[x]` 是所述条件下不相容，`[N/A]` 是不适用维度。未标注文字不是证明或基准测试。

每次改造记录：张量形状与轴；数学恒等式或近似；小规模精确参照与失效案例；fp32 及目标精度的数值残差；完整前后向或 prefill/decode 成本；相同预算的任务基线。不要把论文表述模板复制为已经做过的实验。

| 所需保证 | 最低限度的有效检查 |
|---|---|
| 投影/低秩近似 | 正交与重建残差；下游查询/输出误差 |
| 等变性 | 整个模块变换输入残差，包含mask/位置及输出类型 |
| IB/对比损失 | 随机变量定义、界方向、beta口径及采样分布 |
| 平衡路由 | 软边缘残差，另行检查硬容量/溢出 |
| 保拓扑 | 过滤、系数域、维数/单形限制；持久图或Betti诊断 |

完整案例：`../references/worked-examples/query-aware-compression.md` 与 `../references/worked-examples/equivariance-check.md`。GPU 方法论：`../references/gpu-friendly-math.md`。
