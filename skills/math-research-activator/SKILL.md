---
name: math-research-activator
description: |
  数学研究操作系统：自动诊断用户意图，路由到思想透镜、数学知识库或设计翻译层。触发于设计/改进模型架构/算子/注意力、分析理论性质、迁移数学结构到 AI 设计。不触发于纯工程任务（debug、重构、调参）。
  English: Mathematical research OS — auto-diagnoses user intent, routes to thinking lenses, math knowledge base, or design translation layer. Triggers on architecture/operator design, theoretical analysis, math-to-AI transfer. Does NOT trigger for pure engineering tasks.
---

> ## 语言路由与混合输入规则
>
> 语言路由只决定"读取哪个语言版本的说明"和"最终用什么语言回答"，不参与数学系统是否触发、也不参与 A/B/C/D/E 场景判断。
>
> ### 判定规则
>
> 1. **先判断自然语言主框架**
>    - 如果用户的请求句式、动词、语气词主要是中文，即使夹杂英文技术词，也按中文处理。
>    - 例如："帮我 design 一个 attention""这个 loss 有没有理论问题""能不能用 manifold 做 routing"均按中文处理。
>
> 2. **英文技术词不计入英文主语言**
>    - attention、loss、routing、embedding、manifold、operator、kernel、KV-cache、transformer、MoE 等 AI/数学/工程术语视为领域术语，不作为切换到英文的依据。
>
> 3. **代码、路径、公式不参与语言判定**
>    - 文件路径、函数名、变量名、LaTeX 公式、命令行参数不计入语言比例。
>
> 4. **主语言不明显时，沿用用户上一轮主要语言**
>    - 若中英文比例接近且无法判断，以用户最近一次明确使用的自然语言为准。
>    - 若没有上下文，默认中文。
>
> 5. **输出语言与主语言一致**
>    - 中文主语言 → 读取中文 `SKILL.md`，用中文回答，保留必要英文术语。
>    - 英文主语言 → 读取 `SKILL.en.md`，用英文回答。
>    - 用户明确要求"用英文/用中文"时，以用户显式要求为准。

# 数学研究操作系统 / Math Research OS

> "思想系统不负责给定理，知识系统不负责乱启发，设计层不负责装深刻。"

本系统是面向 AI 架构创新的数学参谋部——不是武器库，而是告诉你：**这场仗是什么仗、该用什么兵种、怎么部署、哪里会翻车。**

## 核心原则

> Math Skill 不存储数学，它激活数学、路由数学，并把数学翻译成 AI 研究设计。

- **knowledge-base/** 不是封闭百科，而是数学激活锚点集合（activation anchors）
- 当现有卡片不能覆盖问题时，Agent 不得停止或强行套用，而应基于透镜、参考层和自身数学知识生成"临时知识卡"，继续完成设计翻译
- **design-patterns/** 是 math→AI 翻译原型集合，不是完整模型仓库；无对应模式时根据数学结构临时生成候选设计，并标记为 temporary design pattern

## 三层正交架构

| 层 | 职责 | 目录 | 核心问题 |
|----|------|------|---------|
| **思想透镜** | 诊断问题结构，推荐数学视角 | `../../lenses/*.md` | 这个问题该用什么视角看？ |
| **数学知识** | 提供具体数学工具（定义/定理/公式） | `../../knowledge-base/*/*.md` | 这个视角需要哪些具体数学？ |
| **设计翻译** | 把数学变成 AI 模块/loss/算子 | `../../design-patterns/*/*.md` | 这些数学怎么变成模型结构？ |

辅助层：
- `../../references/books/*.md`：7 本书的蒸馏稿，需要深入时的完整上下文
- `../../references/gpu-friendly-math.md`：GPU 八维验收门（唯一权威）
- `../../agents/math-critic.md`：数学-工程双重批判器

## 意图诊断（5 场景）

| 场景 | 诊断信号 | 调用路径 |
|------|---------|---------|
| **A. 问题分析** | "这个设计合理吗？""逻辑链有没有漏洞？" | 透镜 → critic |
| **B. 机制设计** | "设计新 attention""把 X 迁移到 Y" | 透镜 → 知识 → 设计 → critic |
| **C. 知识查询** | "流形上的切空间是什么？""投影定理怎么用？" | 知识 |
| **D. 验证审查** | "这个公式成立吗？""loss 能保证什么？" | 知识 → 相关设计模式（若引用具体 AI 构造）→ critic |
| **E. 纯工程** | debug、重构、调参、代码审查 | **不调用数学系统** |

## 透镜库（15 个数学视角）

每个透镜回答：这是什么视角？适合诊断什么问题？会路由到哪些知识域？

| 透镜 | 文件 | 核心视角 |
|------|------|---------|
| 公理化 | `../../lenses/axiomatization.md` | 审查假设的相容性/独立性/完备性 |
| 对偶 | `../../lenses/duality.md` | 转换到对偶空间暴露约束与不变量 |
| 对称性 | `../../lenses/symmetry.md` | 变换下的不变量与守恒律 |
| 谱分解 | `../../lenses/spectral.md` | 特征值/奇异值揭示主导结构 |
| 几何 | `../../lenses/geometric.md` | 度量/曲率/流形上的空间结构 |
| 投影与分解 | `../../lenses/projection.md` | 正交分解、子空间分离、冲突消除 |
| 变分 | `../../lenses/variational.md` | 约束下极值、能量最小化 |
| 局部到整体 | `../../lenses/local-to-global.md` | 局部性质拼接为全局、层上同调障碍 |
| 拓扑 | `../../lenses/topological.md` | 连续变形不变量、连通性、空洞 |
| 范畴化 | `../../lenses/categorical.md` | 泛性质、函子、自然变换 |
| 扰动 | `../../lenses/perturbation.md` | 小扰动的传播、稳定性、鲁棒性 |
| 因果 | `../../lenses/causal.md` | 相关≠因果、干预、反事实 |
| 博弈 | `../../lenses/game.md` | 多方策略互动、均衡、机制设计 |
| 概率统计 | `../../lenses/probabilistic.md` | 量化不确定性、贝叶斯更新 |
| 算法 | `../../lenses/algorithmic.md` | 复杂度、可行性、并行性 |

## 知识库（按数学领域组织）

每个知识卡片回答：最小定义、核心公式、适用问题、AI 设计翻译、工程可行性、风险。

| 领域 | 目录 | 知识卡片 |
|------|------|---------|
| 矩阵分析 | `../../knowledge-base/matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| 最优化 | `../../knowledge-base/optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| 微分几何 | `../../knowledge-base/differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| 李理论 | `../../knowledge-base/lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance |
| 拓扑 | `../../knowledge-base/topology/` | persistent-homology, euler-characteristic, fundamental-group |
| 概率与信息 | `../../knowledge-base/probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| 信息几何 | `../../knowledge-base/information-geometry/` | natural-gradient, fisher-metric |

## 设计模式库（按 AI 组件组织）

每个设计模式回答：数学来源、AI 模块形式、可实现结构、GPU 可行性、论文表述、风险。

| 组件类型 | 目录 | 模式 |
|---------|------|------|
| 注意力 | `../../design-patterns/attention/` | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| 损失函数 | `../../design-patterns/loss/` | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| 路由 | `../../design-patterns/routing/` | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| 表示 | `../../design-patterns/representation/` | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| 压缩 | `../../design-patterns/compression/` | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

## 自动触发条件

**必须同时满足 Gate 1 + Gate 2 + Gate 3 才介入：**

### Gate 0 · 排除门（最高优先级）
以下任务**无论工作区含什么**都不触发：代码审查、debug、重构、调参、构建部署、纯事实查询、通用软件工程。

### Gate 1 · 环境信号
工作区含架构核心代码（attention/transformer/MoE、`*.cu`/kernel）或研究笔记。仅 `model.py`、`trainer.py` 等常规文件**不构成**环境信号。

### Gate 2 · 任务信号
用户任务涉及**设计/改进**新架构/算子、**分析**理论性质、**迁移**数学结构到 AI 设计，或**查询与 AI 研究相关的数学知识**（如"切空间在优化中怎么用"）。纯百科式数学查询（如"什么是群"且无 AI 上下文）不自动触发，但可通过 `/ask` 手动进入。

### Gate 3 · 意图匹配
用户意图匹配场景 A/B/C/D 之一。纯工程任务匹配场景 E → 不介入。

> **`/ask` 入口**：手动调用时跳过 Gate 1 和 Gate 2，仅执行 Gate 0（排除门）+ Gate 3（意图匹配），可直接进入任意场景包括知识查询。

## 主流程

### 第一步：诊断意图
1. 判断用户意图属于场景 A/B/C/D/E 哪个
2. 提取问题核心张力：想保留什么？想抑制什么？约束是什么？工程瓶颈是什么？
3. 输出问题类型分类

### 第二步：路由调用

```
场景 A（分析）：选 1-3 个透镜 → 输出视角诊断 → critic 审查
场景 B（设计）：选 1-3 个透镜 → 调用相关激活锚点；若无覆盖则进入 Knowledge Gap Protocol → 生成正式/临时设计模式 → critic 审查
场景 C（查询）：优先加载相关激活锚点；若无覆盖则生成临时知识卡 → 按知识激活协议输出
场景 D（验证）：加载相关锚点或临时知识卡 → critic 审查条件与边界
场景 E（工程）：不介入
```

### 第三步：输出格式

**场景 A/B 输出**：
1. **[诊断]** 问题类型 + 核心张力
2. **[透镜]** 推荐 1-3 个数学视角（标注为什么适合/不适合）
3. **[知识]**（仅场景 B）激活的数学结构（引用激活锚点或临时知识卡）
4. **[设计]**（仅场景 B）候选 AI 模块草案（引用设计模式或临时设计草案）
5. **[GPU]** 候选过八维门（友好/可改造/不友好）
6. **[结论]** 保留通过双验收门的候选 + 下一步建议

**场景 C 输出**（知识激活协议）：
1. 最小定义
2. 核心公式
3. 适用问题
4. AI 设计翻译
5. 工程可行性
6. 风险与失效条件
7. 深入参考（书蒸馏稿 / 原书路径）

**场景 D 输出**：
1. 成立条件
2. 不成立条件
3. 最多能保证什么
4. 不能保证什么
5. 工程可行性

**必须给出结论，不得只输出分析而不收敛。**

## GPU 八维验收门

正式术语（唯一权威来源：`../../references/gpu-friendly-math.md`）：
**张量化 / GEMM 可映射 / 复杂度 / 显存与 KV-Cache / 低精度稳定 / 并行与通信 / 稀疏结构 / 算子融合**

## 深度查阅协议

- **轻度**：读知识卡片（`../../knowledge-base/*/*.md`），自足可用
- **中度**：读书蒸馏稿（`../../references/books/*.md`），获取更完整上下文
- **深度**：本机有 `math_book/<PDF>` 时，Agent 自动 `pdftotext` + grep 定位原文页

## 知识缺口协议 / Knowledge Gap Protocol

当用户问题需要的数学工具不在现有 `knowledge-base/` 中时，不得强行套用已有卡片。执行以下流程：

1. **缺口识别**：明确指出现有知识库中没有完全对应的知识卡片。判断缺口属于：新领域、新定理族、新结构、新应用场景，还是已有卡片的组合扩展。

2. **透镜回退**：选择 1-3 个最相关思想透镜，用它们确定问题的数学结构。例如：局部到整体、范畴化、谱分解、投影、因果、扰动等。

3. **候选知识定位**：给出应查找的数学关键词、定理族、概念簇、参考书方向。不要求已有知识卡覆盖，但必须说明为什么这些知识相关。

4. **临时知识卡**：生成一个"临时知识摘要"，格式同正式知识卡：
   - 最小定义
   - 核心结构
   - 适用问题
   - AI 设计翻译
   - GPU 可行性
   - 风险与失效条件

5. **设计翻译**：若用户目标是机制设计，则将临时知识转译为候选 AI 模块、loss、routing、attention、representation 或 compression 方案。

6. **升级建议**：如果该缺口高频出现，建议新增正式 knowledge card 或 design pattern。

## 工作流范例

**用户**："设计新的 KV Cache 压缩方法，保留长期依赖，不想只做 top-k"

```
第一步 诊断：场景 B（机制设计）
  问题类型：序列记忆压缩 + 信息保留 + 长程结构
  核心张力：压缩 token 数量 vs 不破坏长期依赖

第二步 透镜选择：
  1. 谱分解（保留主导子空间）
  2. 信息论（保留最大互信息状态）
  3. 拓扑（保留序列结构关键连接点）

第三步 知识查询：
  → low-rank-approximation（矩阵分析）
  → leverage-score-selection（矩阵分析）
  → information-bottleneck（概率与信息）

第四步 设计翻译：
  候选 A：Spectral KV Compression（低秩 + leverage score）
  候选 B：Information-Preserving Cache（query sensitivity）
  候选 C：Topology-Preserving Cache（图桥接节点保留）

第五步 Critic 审查：
  A 最 GPU 友好，B 需估计未来 query 有不确定性，C 图构建成本过高
  建议：优先 A，B 作轻量 gate
```
