# Skill 索引：透镜库、知识库、设计模式库、工作流范例

> 本文件从 `SKILL.md` 提取，供需要查阅完整目录时使用。SKILL.md 保留精简摘要和指向本文件的链接。

## 语言路由与混合输入规则（完整版）

语言路由只决定"读取哪个语言版本的说明"和"最终用什么语言回答"，不参与数学系统是否触发、也不参与 A/B/C/D/E 场景判断。

### 判定规则

1. **先判断自然语言主框架**
   - 如果用户的请求句式、动词、语气词主要是中文，即使夹杂英文技术词，也按中文处理。
   - 例如："帮我 design 一个 attention""这个 loss 有没有理论问题""能不能用 manifold 做 routing"均按中文处理。

2. **英文技术词不计入英文主语言**
   - attention、loss、routing、embedding、manifold、operator、kernel、KV-cache、transformer、MoE 等 AI/数学/工程术语视为领域术语，不作为切换到英文的依据。

3. **代码、路径、公式不参与语言判定**
   - 文件路径、函数名、变量名、LaTeX 公式、命令行参数不计入语言比例。

4. **主语言不明显时，沿用用户上一轮主要语言**
   - 若中英文比例接近且无法判断，以用户最近一次明确使用的自然语言为准。
   - 若没有上下文，默认中文。

5. **输出语言与主语言一致**
   - 中文主语言 → 读取中文 `SKILL.md`，用中文回答，保留必要英文术语。
   - 英文主语言 → 读取 `SKILL.en.md`，用英文回答。
   - 用户明确要求"用英文/用中文"时，以用户显式要求为准。

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
