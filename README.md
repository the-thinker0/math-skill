<p align="right">
  <a href="README.md">中文</a> | <a href="README.en-US.md">English</a>
</p>

# ⚔️ Math Skill — 面向 AI 架构创新的数学研究操作系统

> **思想系统不负责给定理，知识系统不负责乱启发，设计层不负责装深刻。**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

> **如果这个项目对你有所启发，请不吝点亮一颗 Star⭐。** 每一个 Star 都是对数学之美的共鸣，也是支撑这个项目继续前行的力量。欢迎每一位热爱数学、在数学海洋中遨游的同行者。

---

## 灵感来源

Sophus Lie 打造"屠龙刀"的故事告诉我们：为解微分方程发明的李群-李代数，最终成为描述对称性、机器人状态估计的通用语言——数学工具的价值远超初衷，这正是「跨领域激活」的原型。详见 [`references/inspiration.md`](references/inspiration.md)。

> 数学最迷人的地方：为特定问题发明的工具，在完全不同的领域展现出远超初衷的价值。

---

## 核心理念

当你面对一个 AI 研究问题时，这个系统帮你回答四个问题：

1. **该用什么数学思想看？** → 思想透镜
2. **需要查什么具体数学知识？** → 知识库
3. **怎么把数学变成模型设计？** → 设计翻译层
4. **这个设计是否数学上靠谱、工程上可行？** → 批判器

```
问题
 ↓
思想透镜：这个问题该用什么视角看？
 ↓
数学知识：这个视角需要哪些具体数学工具？
 ↓
设计翻译：这些工具怎么变成模型结构 / loss / 算子？
 ↓
批判器：数学上站得住、工程上跑得动吗？
```

---

## 三层正交架构

| 层 | 职责 | 目录 | 文件数 |
|----|------|------|--------|
| **思想透镜** | 诊断问题结构，推荐数学视角 | `lenses/*.md` | 15 |
| **数学知识** | 提供具体数学工具（定义/定理/公式） | `knowledge-base/*/*.md` | 26 |
| **设计翻译** | 把数学变成 AI 模块/loss/算子 | `design-patterns/*/*.md` | 15+ |

辅助层：
- `references/books/*.md`：7 本书蒸馏稿，需要深入时的完整上下文
- `references/gpu-friendly-math.md`：GPU 八维验收门
- `agents/math-critic.md`：数学-工程双重批判器

### 15 个思想透镜

| 透镜 | 文件 | 核心视角 |
|------|------|---------|
| 公理化 | `lenses/axiomatization.md` | 审查假设的相容性/独立性/完备性 |
| 对偶 | `lenses/duality.md` | 转换到对偶空间暴露约束与不变量 |
| 对称性 | `lenses/symmetry.md` | 变换下的不变量与守恒律 |
| 谱分解 | `lenses/spectral.md` | 特征值/奇异值揭示主导结构 |
| 几何 | `lenses/geometric.md` | 度量/曲率/流形上的空间结构 |
| 投影与分解 | `lenses/projection.md` | 正交分解、子空间分离、冲突消除 |
| 变分 | `lenses/variational.md` | 约束下极值、能量最小化 |
| 局部到整体 | `lenses/local-to-global.md` | 局部性质拼接为全局、层上同调障碍 |
| 拓扑 | `lenses/topological.md` | 连续变形不变量、连通性、空洞 |
| 范畴化 | `lenses/categorical.md` | 泛性质、函子、自然变换 |
| 扰动 | `lenses/perturbation.md` | 小扰动的传播、稳定性、鲁棒性 |
| 因果 | `lenses/causal.md` | 相关≠因果、干预、反事实 |
| 博弈 | `lenses/game.md` | 多方策略互动、均衡、机制设计 |
| 概率统计 | `lenses/probabilistic.md` | 量化不确定性、贝叶斯更新 |
| 算法 | `lenses/algorithmic.md` | 复杂度、可行性、并行性 |

### 知识库（按数学领域）

| 领域 | 知识卡片 |
|------|---------|
| 矩阵分析 | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| 最优化 | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| 微分几何 | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| 李理论 | group-action, lie-group, lie-algebra, representation, equivariance |
| 拓扑 | persistent-homology, euler-characteristic, fundamental-group |
| 概率与信息 | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| 信息几何 | natural-gradient, fisher-metric |

### 设计模式库（按 AI 组件）

| 组件 | 设计模式 |
|------|---------|
| 注意力 | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| 损失函数 | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| 路由 | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| 表示 | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| 压缩 | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

---

## 快速开始

### 安装

```
请帮我安装 math-skill：https://github.com/the-thinker0/math-skill，并教我如何使用
```

手动安装：

```bash
git clone https://github.com/the-thinker0/math-skill.git
```

### 使用

**自动触发**：系统自动诊断用户意图，路由到合适的层：

| 场景 | 诊断信号 | 调用路径 |
|------|---------|---------|
| 问题分析 | "这个设计合理吗？" | 透镜 → critic |
| 机制设计 | "设计新 attention" | 透镜 → 知识 → 设计 → critic |
| 知识查询 | "切空间和梯度优化有什么关系？" | 知识 |
| 验证审查 | "这个公式成立吗？" | 知识 → critic |
| 纯工程 | debug、重构、调参 | **不调用** |

**手动触发**：

```
/ask <你的问题>          # 智能诊断：自动判断场景并路由
```

### 语言切换

自动检测用户语言：中文消息返回中文输出，英文消息返回英文输出。

---

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

---

## 目录结构

```
math-skill/
├── skills/
│   └── math-research-activator/    # 总控：意图诊断 + 路由
├── lenses/                         # 15 个思想透镜（推理方法论）
├── knowledge-base/                 # 数学知识库（按领域组织）
│   ├── matrix-analysis/            # 矩阵分析（5 卡片）
│   ├── optimization/               # 最优化（5 卡片）
│   ├── differential-geometry/      # 微分几何（6 卡片）
│   ├── lie-theory/                 # 李理论（5 卡片）
│   ├── topology/                   # 拓扑（3 卡片）
│   ├── probability/                # 概率与信息（5 卡片）
│   └── information-geometry/       # 信息几何（2 卡片）
├── design-patterns/                # 设计翻译层（按 AI 组件组织）
│   ├── attention/                  # 注意力机制（5 模式）
│   ├── loss/                       # 损失函数（5 模式）
│   ├── routing/                    # 路由（4 模式）
│   ├── representation/             # 表示（4 模式）
│   └── compression/                # 压缩（4 模式）
├── references/                     # 参考层
│   ├── books/                      # 7 本书蒸馏稿
│   ├── gpu-friendly-math.md        # GPU 八维验收门
│   ├── agentic-workflow.md         # 协作方式
│   └── inspiration.md              # 灵感来源
├── agents/math-critic.md           # 数学-工程双重批判器
├── commands/ask.md                 # /ask 手动入口
├── math_book/                      # 本地 PDF（不发布）
└── README.md / LICENSE
```

---

## 推荐书目

| # | 书名 | 作者 | 出版社 / 版次 | 年份 | ISBN | 蒸馏文件 |
|---|------|------|-------------|------|------|---------|
| 1 | *Contemporary Abstract Algebra* | Joseph A. Gallian | Brooks/Cole, Cengage, 8th ed. | 2013 | 978-1-133-59971-5 | `abstract-algebra.md` |
| 2 | *The Rising Sea: Foundations of Algebraic Geometry* | Ravi Vakil | Princeton University Press | 2025 | 978-0-691-26866-8 | `algebraic-geometry-rising-sea.md` |
| 3 | *Manifolds and Differential Geometry* | Jeffrey M. Lee | AMS, Graduate Studies in Math Vol. 107 | 2009 | 978-0-8218-4815-9 | `differential-geometry.md` |
| 4 | *Matrix Analysis* | Roger A. Horn, Charles R. Johnson | Cambridge University Press, 2nd ed. | 2013 | 978-0-521-83940-2 | `matrix-analysis.md` |
| 5 | *A micro Lie theory for state estimation in robotics* | Joan Solà et al. | arXiv:1812.01537v9 | 2021 | — | `micro-lie-theory.md` |
| 6 | *An Introduction to Optimization, With Applications to ML* | Chong, Lu, Żak | John Wiley & Sons, 5th ed. | 2024 | 978-1-119-87763-9 | `optimization-ml.md` |
| 7 | *Introduction to Smooth Manifolds* | John M. Lee | Springer, GTM 218, 2nd ed. | 2013 | 978-1-4419-9981-8 | `smooth-manifolds.md` |

蒸馏文件已随 npm 包发布。如需全保真原文，将 PDF 放入 `math_book/` 文件夹即可。

---

## 变更日志

### v3.0.0 — 数学研究操作系统

**架构重构**：从"思想武器库"升级为"数学参谋部"——三层正交架构：

- **思想透镜**（15 个）：从 v2 的"思想武器"瘦身而来，只保留推理方法论，不再混入具体数学知识
- **知识库**（26 张卡片）：按数学领域组织的具体工具卡片，含定义/公式/AI 设计翻译/GPU 可行性
- **设计翻译层**（新增）：数学→AI 模块的桥梁，按 AI 组件（attention/loss/routing/representation/compression）组织
- **Activator 重写**：从环境信号匹配改为意图诊断（5 场景：分析/设计/查询/验证/工程）
- **知识激活协议**：知识卡片固定输出格式（最小定义→公式→适用问题→AI 翻译→工程可行性→风险）

### v2.1.0 — 完整双语支持
- 全面双语（37 个 .en.md 文件）、自动语言路由、命令一致、token 保障

### v2.0.1
- 收紧自动触发条件、新增排除门、环境信号收窄

### v2.0.0
- 16 思想武器、现代数学激活层、GPU 八维横切

### v1.0.0
- 初始发布：十五思想武器 + 科研与生活双路径

---

## 许可证

MIT License. 详见 `LICENSE`。

---

## 贡献

欢迎提交 Issue 和 Pull Request！

---

## Star History

<a href="https://www.star-history.com/?repos=the-thinker0%2Fmath-skill&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&legend=top-left" />
 </picture>
</a>
