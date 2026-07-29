<p align="right">
  <a href="README.md">中文</a> | <a href="README.en-US.md">English</a>
</p>

# 📐 Math Skill: 面向 AI 与密码学创新的数学研究操作系统

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

> **如果这个项目对你有所启发，请不吝点亮一颗 Star⭐。** 每一个 Star 都是对数学之美的共鸣，也是支撑这个项目继续前行的力量。欢迎每一位热爱数学、在数学海洋中遨游的同行者。

---

## 📢 社区公告

> **v3.3.1 已发布**：文档纪律修复版——补全 README 目录树遗漏域、纠正工作流范例、瘦身 changelog、统一入口话术与计数口径。v3.3.0 完成路由收敛与专业性校正；本版修复其遗留的文档一致性问题。详见变更日志。欢迎通过 GitHub Issues 或 Discussions 反馈使用体验与边界场景。

---

## 灵感来源

Sophus Lie 打造"屠龙刀"的故事告诉我们：为解微分方程发明的李群-李代数，最终成为描述对称性、机器人状态估计的通用语言——数学工具的价值远超初衷，这正是「跨领域激活」的原型。详见 [`references/inspiration.md`](references/inspiration.md)。

> 数学最迷人的地方：为特定问题发明的工具，在完全不同的领域展现出远超初衷的价值。

---

> Math Skill 不存储数学，它激活数学、路由数学，并把数学翻译成 AI 研究设计。

## 核心理念

当你面对一个 AI 研究问题时，这个系统帮你回答四个问题：

1. **该用什么数学思想看？** → 思想透镜
2. **应该激活哪些数学结构？** → 激活锚点 / 临时知识卡
3. **怎么把数学变成模型设计？** → 设计翻译原型
4. **这个设计是否数学上靠谱、工程上可行？** → 批判器

```
问题
 ↓
思想透镜：这个问题该用什么视角看？
 ↓
激活锚点：应该激活哪些数学结构？不足时进入知识缺口协议
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
| **激活锚点** | 33 个共用数学锚点 + 4 个密码学锚点；不足时触发知识缺口协议 | `knowledge-base/*/*.md` | 37 |
| **设计翻译** | 把数学变成 AI 模块/loss/算子 | `design-patterns/*/*.md` | 22 |

辅助层：
- `references/books/*.md`：10 本书蒸馏稿（7 本 AI 方向 + 3 本密码学方向），需要深入时的完整上下文
- `references/gpu-friendly-math.md`：按需 GPU 检查；不适用维度标 N/A
- `agents/math-critic.md`：仅全面/论文级审查按需加载的 19 维深度批判器

### Domain Router

AI 研究与密码学**共享**数学根基（概率/信息/代数/矩阵/谱/优化），但**独有**各自专业层。Domain Router 在意图诊断后、调用透镜前，先判定问题归属，决定加载哪些锚点/书稿/设计模式，避免跨域污染与 token 浪费。

| Domain | 加载内容 | 信号词 |
|--------|---------|--------|
| **共用数学** | 8 域 33 锚点 + 相关透镜 | 概率/信息/代数/几何/矩阵/谱/优化/拓扑/复杂度 |
| **AI 研究** | 共用数学按需 + 0–2 个相关设计原型；书稿只在深查时加载 | attention/loss/routing/representation/compression/MoE/transformer/KV-cache/LoRA/SSM/扩散/RL |
| **密码学** | 4 张密码锚点；不足时才查 3 本密码书稿；共用数学按需 | 加密/签名/MAC/PRF/PRG/PRP/OWF/CCA/CPA/AE/零知识/归约/DL/CDH/DDH/RSA/ECC/格密码 |
| **AI×密码交叉** | 双 domain 加载 + 交叉点标注 | "PRF 做模型水印""对抗样本归约""可验证推理" |

> 规则：domain 判定先于透镜调用；共用数学不重复加载；不跨域时不污染；缺口协议临时卡标注 domain。

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

### 激活锚点（按数学领域）

| 领域 | 锚点 |
|------|---------|
| 矩阵分析 | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| 最优化 | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| 微分几何 | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| 李理论 | group-action, lie-group, lie-algebra, representation, equivariance |
| 拓扑 | persistent-homology, euler-characteristic, fundamental-group |
| 概率与信息 | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| 信息几何 | natural-gradient, fisher-metric |
| 代数几何 | sheaf-cohomology, grassmannian-plucker |
| 密码学（独有） | prf-prg-owf, reduction-proof-template, attack-game-framework, cca-cpa-ae-hierarchy |

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

Codex 手动安装（把整个仓库作为一个自足 skill，而不是只复制内层目录）：

```bash
git clone https://github.com/the-thinker0/math-skill.git ~/.codex/skills/math-research-activator
```

根 `SKILL.md` 是 Codex 权威入口；`skills/math-research-activator/SKILL.md` 只是 Claude/plugin 风格兼容入口并转发到根文件。不要单独复制内层目录，否则它引用的知识库与设计模式不完整。

### 使用

**自动触发**：系统自动诊断用户意图，路由到合适的层：

| 场景 | 诊断信号 | 调用路径 |
|------|---------|---------|
| 问题分析 | "这个设计合理吗？" | 透镜 → critic |
| 机制设计 | "设计新 attention" | 透镜 → 激活锚点/临时知识卡 → 设计翻译 → critic |
| 知识查询 | "切空间和梯度优化有什么关系？" | 激活锚点；不足则 Knowledge Gap Protocol |
| 验证审查 | "这个公式成立吗？" | 激活锚点/临时知识卡 → critic |
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

第二步 透镜选择（默认 ≤2）：
  1. 谱分解（保留主导子空间）
  2. 概率/信息（保留互信息敏感状态）
  （拓扑仅在用户强调连通/桥接结构时再加，不计入默认预算）

第三步 激活锚点：
  → low-rank-approximation（矩阵分析锚点）
  → information-bottleneck（概率与信息锚点）
  → leverage-score-selection 或 low-rank-kv-cache（0–2 个压缩设计模式）
  若现有锚点不足，进入 Knowledge Gap Protocol 生成临时知识卡。

第四步 设计翻译：
  主方案：Spectral KV Compression（低秩 + leverage score）
  备选仅写关键差异：Information-Preserving Cache（依赖未来 query 估计）

第五步 紧凑审查（普通任务不加载完整 critic）：
  主方案最 GPU 友好；备选需估计未来 query，不确定性更高
  结论：优先主方案；需要 query 敏感保留时再加轻量 gate
```

---

## 目录结构

```
math-skill/
├── skills/
│   └── math-research-activator/    # 总控：意图诊断 + 路由
├── lenses/                         # 15 个思想透镜（推理方法论）
├── knowledge-base/                 # 激活锚点（按数学领域组织，非封闭百科；共 37 卡）
│   ├── matrix-analysis/            # 矩阵分析（5 卡片）
│   ├── optimization/               # 最优化（5 卡片）
│   ├── differential-geometry/      # 微分几何（6 卡片）
│   ├── lie-theory/                 # 李理论（5 卡片）
│   ├── topology/                   # 拓扑（3 卡片）
│   ├── probability/                # 概率与信息（5 卡片）
│   ├── information-geometry/       # 信息几何（2 卡片）
│   ├── algebraic-geometry/         # 代数几何（2 卡片）
│   └── cryptography/               # 密码学（4 卡片，域独有）
├── design-patterns/                # 设计翻译层（按 AI 组件组织）
│   ├── attention/                  # 注意力机制（5 模式）
│   ├── loss/                       # 损失函数（5 模式）
│   ├── routing/                    # 路由（4 模式）
│   ├── representation/             # 表示（4 模式）
│   └── compression/                # 压缩（4 模式）
├── references/                     # 参考层
│   ├── books/                      # 10 本书蒸馏稿（7 AI + 3 密码学）
│   ├── gpu-friendly-math.md        # GPU 维度清单（仅评相关项）
│   ├── agentic-workflow.md         # 协作方式
│   ├── inspiration.md              # 灵感来源
│   ├── musings.md                  # 杂谈（哲学感悟，不自动加载）
│   └── skill-index.md              # 索引（按需目录，不默认加载）
├── agents/math-critic.md           # 数学-工程双重批判器（19 维，含密码学安全审视）
├── commands/ask.md                 # /ask 手动入口
├── math_book/                      # 本地 PDF（不发布）
└── README.md / LICENSE
```

---

## 推荐书目

### AI 方向（7 本）

| # | 书名 | 作者 | 出版社 / 版次 | 年份 | ISBN | 蒸馏文件 |
|---|------|------|-------------|------|------|---------|
| 1 | *Contemporary Abstract Algebra* | Joseph A. Gallian | Brooks/Cole, Cengage, 8th ed. | 2013 | 978-1-133-59971-5 | `abstract-algebra.md` / `.en.md` |
| 2 | *The Rising Sea: Foundations of Algebraic Geometry* | Ravi Vakil | Princeton University Press | 2025 | 978-0-691-26866-8 | `algebraic-geometry-rising-sea.md` / `.en.md` |
| 3 | *Manifolds and Differential Geometry* | Jeffrey M. Lee | AMS, Graduate Studies in Math Vol. 107 | 2009 | 978-0-8218-4815-9 | `differential-geometry.md` / `.en.md` |
| 4 | *Matrix Analysis* | Roger A. Horn, Charles R. Johnson | Cambridge University Press, 2nd ed. | 2013 | 978-0-521-83940-2 | `matrix-analysis.md` / `.en.md` |
| 5 | *A micro Lie theory for state estimation in robotics* | Joan Solà et al. | arXiv:1812.01537v9 | 2021 | — | `micro-lie-theory.md` / `.en.md` |
| 6 | *An Introduction to Optimization, With Applications to ML* | Chong, Lu, Żak | John Wiley & Sons, 5th ed. | 2024 | 978-1-119-87763-9 | `optimization-ml.md` / `.en.md` |
| 7 | *Introduction to Smooth Manifolds* | John M. Lee | Springer, GTM 218, 2nd ed. | 2013 | 978-1-4419-9981-8 | `smooth-manifolds.md` / `.en.md` |

### 密码学方向（3 本）

| # | 书名 | 作者 | 出版社 / 版次 | 年份 | ISBN | 蒸馏文件 |
|---|------|------|-------------|------|------|---------|
| 8 | *A Graduate Course in Applied Cryptography* | Dan Boneh & Victor Shoup | v0.4 在线版 | 2017 | — | `applied-cryptography.md` / `.en.md` |
| 9 | *Foundations of Cryptography, Volume 1: Basic Tools* | Oded Goldreich | Cambridge University Press | 2001 | 978-0-521-79235-9 | `foundations-of-cryptography.md` / `.en.md` |
| 10 | *Introduction to Modern Cryptography* | Jonathan Katz & Yehuda Lindell | CRC Press, 2nd ed. | 2015 | 978-1-4665-7026-1 | `introduction-to-modern-cryptography.md` / `.en.md` |

> 三份密码学蒸馏稿均已中英配对；按用户主语言选择 `.md` 或 `.en.md`，且仍只在锚点不足或需要书稿深度时加载。

蒸馏文件已随 npm 包发布。如需全保真原文，将 PDF 放入 `math_book/` 文件夹即可。

---

## 变更日志

### v3.3.1 — 文档纪律修复版

- **README 目录树补全**：补入 `algebraic-geometry/`、`cryptography/`、`musings.md`、`skill-index.md`，卡片总数标注对齐 37
- **README 工作流范例纠正**：透镜默认 ≤2、设计模式与锚点分离、第五步改为紧凑审查，与 `SKILL.md` 预算一致
- **changelog 瘦身**：v1/v2 压缩为一行摘要，移除"37 个 .en.md""16 思想武器"等失真数字
- **入口话术与计数口径统一**：三处入口对"何时读 `.en` 版"措辞统一；全仓计数统一为 33 共用 + 4 密码 = 37
- **元数据与工程卫生**：`package.json` description/keywords 瘦身；`CLAUDE.md` 目录树与 Node.js 依赖表述修正；`validate.sh` 新增 20 条文档纪律结构性检查；`original-texts` 加用途标注并修正 v2 旧术语

### v3.3.0 — 路由收敛、双语补全与专业性校正

- **权威入口与兼容结构**：新增根 `SKILL.md` / `SKILL.en.md` 作为完整、自足的规范入口；`skills/math-research-activator/SKILL*.md` 缩为薄转发层，继续兼容 Claude/plugin 目录布局，同时避免两份完整正文长期漂移。`commands/ask*`、critic、索引和 overview 的引用均改到根入口。
- **渐进加载与 token 最小化**：按 A 分析、B 设计、C 查询、D 验证、E 纯工程五类场景设置最小路径；默认限制为 1–2 个透镜、1–3 个锚点和 0–2 个设计原型。概念查询、纯密码任务和普通验证不再默认加载完整 critic、书稿、GPU 清单或目录索引，也不向用户复述内部加载过程。
- **Domain Router 重写**：从关键词投票改为按“目标对象 + 所求保证”判域；`hashing`、`attack`、`security` 等孤立词不再误触发密码学。纯 AI、纯密码、共用数学和 AI×密码交叉路径明确隔离；交叉四元组只在真正涉及原语/安全性质向 AI 对象迁移时输出。
- **密码学知识去污染**：四张密码学锚点改用安全定义、攻击游戏、归约损失、构造边界和实现注意事项组织，不再强塞 AI 设计翻译或 GPU 验收；明确标准模型定理、基于原语的归约与 AES 等具体算法经验假设的层级差异，并校正 PRF/PRG/OWF、Feistel、CPA/CCA/AE、KEM/DEM、nonce/IV、密钥分离与组合顺序等表述。
- **数学概念与工程断言校正**：修正一般投影的 Moore–Penrose 伪逆条件、attention/QKV 与线性投影的边界、KL 散度方向、低秩近似的梯度表述、正交损失的形状/归一化条件，以及抽象代数与几何书稿中的若干过度类比；所有保证、等价、稳定和最优性表述强调成立条件或降级为待验证假设。
- **密码学书稿完整双语化**：新增 `applied-cryptography.en.md`、`foundations-of-cryptography.en.md`、`introduction-to-modern-cryptography.en.md`。commands、agents、lenses、knowledge-base、design-patterns 与 references 现均保持中英文件配对；按用户主语言只加载一侧，避免双份上下文。
- **GPU 审查改为相关性驱动**：不再要求每个候选机械覆盖八个维度；先声明 shape、baseline 与部署约束，只评会影响决策的维度，无关项标 `N/A`。要求用 FLOPs、峰值中间张量/状态、字节量、通信量或低精度风险等可核查信号支持判断，并明确“可写成 GEMM”不等于实际更快。
- **critic 与输出质量收敛**：普通任务使用入口内的紧凑检查，只有论文级或显式全面审查才加载 19 维 critic；现代数学激活维度只在确有迁移声称时强制，密码学优先加载 `knowledge-base/cryptography/` 锚点再按需读书稿，不以 GPU 清单作安全门；探索性候选必须标注假设、边界和证伪方法。
- **审查后残余一致性修补（发布前）**：兼容入口 description 与根 `SKILL.md` 对齐（补回数学查询触发）；索引工作流范例改回默认 ≤2 透镜；CLAUDE/eval 去除过时 Gate 术语并更正 books 双语事实；层上同调 $H^1$ 措辞收紧，避免与层公理混淆。
- **索引、路由样例与语言规则同步**：更新 `skill-index`、`knowledge-base/overview`、agentic workflow 和 A/B/C/D/E eval 场景，补充假阳性、交叉域、知识缺口与主语言判断边界；代码、路径、公式和英文技术词不参与主语言投票。
- **测试职责边界清理**：移除仅服务本次审计的六维输出评分和 token/cost 回归规范，保留与 skill 行为直接相关的路由、隔离、双语、引用与语义回归场景。
- **验证与发布完整性**：Bash/PowerShell 验证覆盖根入口 frontmatter、兼容转发、37 张锚点、中英配对、交叉引用、Domain Router 隔离、Knowledge Gap Protocol、GPU 量化信号和高风险语义回归；npm 包显式包含根 `SKILL*.md`，排除 PDF、`math_book/`、测试与本地 npm 缓存。

### v3.2.1 — 设计哲学修正与可靠性增强

- **设计哲学明确化**：`SKILL.md` / `SKILL.en.md` 新增"设计哲学：activator 而非百科"小节，声明 skill 是思考的 activator 和数学锚点，`knowledge-base/` 回归数学结构本身（不固化具体 AI 架构），`design-patterns/` 定位为翻译范式示范而非模板库；新增"兼容性原则"小节，声明对未预置架构的研究问题通过透镜路由 + 锚点激活 + 临时知识卡完成引导
- **密码学锚点补齐**：新增 `knowledge-base/cryptography/` 目录，含 `prf-prg-owf`、`reduction-proof-template`、`attack-game-framework`、`cca-cpa-ae-hierarchy` 四张锚点卡（中英成对），使 Domain Router 的密码学层加载有实质锚点（修复 v3.2.0 理念不一致：此前声明加载密码学层但无结构化锚点）
- **代数几何锚点补齐**：新增 `knowledge-base/algebraic-geometry/` 目录，含 `sheaf-cohomology`、`grassmannian-plucker` 两张锚点卡（中英成对），覆盖 `design-patterns/` 已使用但无锚点的数学结构（层上同调、格拉斯曼流形）
- **测试覆盖扩展**：新增场景 A（问题分析）、场景 D（验证审查）、交叉域路由（AI×密码四元组标注）、Knowledge Gap Protocol、Domain Router 隔离（不污染保证）五类 eval 测试
- **validate.sh 结构化检查**：新增知识卡六段结构、设计模式 GPU 八维覆盖、Domain Router 隔离与 Knowledge Gap Protocol 关键字段检查
- **critic 19 维分层**：核心维度 / 情境维度 / 强制维度 / 元维度分层标注，减少 Agent 的认知负担
- **inspiration.md 拆分**：技术灵感部分（屠龙刀故事）保留；哲学内容（人生最优化等）移至 `musings.md`，避免与 skill 严谨技术风格冲突

### v3.2.0 — 密码学方向接入 + Domain Router

**密码学方向正式落地**：参考层从 7 本扩到 10 本，新增 3 本现代密码学经典蒸馏稿，精简为与 AI 方向书稿一致的激活索引格式（约 125-155 行/本，保留核心思想与关键桥接事实）。

- **新增 3 本密码学书稿**：
  - `references/books/applied-cryptography.md`（Boneh & Shoup）：攻击游戏/归约证明/构造/协议
  - `references/books/foundations-of-cryptography.md`（Goldreich）：计算不可区分/OWF-PRG-PRF 等价链/模拟范式/元定理
  - `references/books/introduction-to-modern-cryptography.md`（Katz & Lindell）：形式化定义/CPA-CCA-AE/构造范式/实现陷阱
- **Domain Router 路由层**（核心创新）：在意图诊断后、透镜调用前判定问题 domain（AI/密码/纯数学/交叉），按 domain 加载专属内容，共用数学不重复加载，避免跨域污染与 token 浪费
- **SKILL.md / SKILL.en.md**：新增 Domain Router 小节 + 路由规则 + 判定流程图；主流程整合 domain 标注与 domain-specific 路由（AI 走 design-patterns + GPU 门，密码走归约模板 + 假设/陷阱检查）
- **math-critic 升级为 19 维**：新增第 19 维「密码学安全审视」（安全定义/归约紧度/假设依赖/合成陷阱/反模式/跨域迁移合理性/Domain Router 一致性）
- **skill-index / overview**：补 Domain Router 总览表与密码学书稿激活家族标注；overview 增 Domain Router 加载提示
- **Token 优化**：密码学书稿从 2084 行精简到 404 行（压缩 ~80%）；Domain Router 按 domain 裁剪输出，避免全量加载；输出格式强调"domain 判定后只展开该 domain 专属小节"。量化估算：纯 AI 问题完全不加载 3 本密码学书稿（省约 400 行/次），纯密码学问题完全不加载 22 个 AI design-patterns（省约 2200-3300 行/次）；密码学书稿本身的精简再省约 872 行/次
- **文件清理**：删除朋友误放在根目录的重复 `SKILL.md/SKILL.en.md/original-texts.md/original-texts.en.md`（权威版本在 `skills/math-research-activator/`）；修正 `agents/math-critic.{en,}.md` 与 `knowledge-base/overview.en.md` 中的 SKILL 相对路径
- **AI 与密码学隔离保证**：Domain Router 规则 4 明确"纯 AI 问题不加载密码学书稿；纯密码学问题不加载 AI 设计模式"，从加载层防止概念混淆

### v3.1.1 — 术语闭环清洁

- **skill-index 口径统一**：标题、知识库小节、工作流范例从"知识库/知识查询"改为"激活锚点"
- **package.json description**：更新为新定位描述
- **README 使用表**：机制设计、知识查询、验证审查路径从"知识"改为"激活锚点/临时知识卡"
- **README 工作流范例**：第三步从"知识查询"改为"激活锚点"，`leverage-score-selection` 标签从"矩阵分析"改为"压缩设计模式"
- **README 目录结构**：`knowledge-base/` 注释从"数学知识库"改为"激活锚点"
- **README 激活锚点表头**：列名从"知识卡片"改为"锚点"
- **SKILL.md / SKILL.en.md**：三层架构表和意图诊断表从"数学知识/Math Knowledge"改为"激活锚点/Activation Anchors"
- **英文 README 书目链接**：蒸馏文件从 `.md` 改为 `.en.md`
- **validate 关键词**：从检查"数学知识/Math Knowledge"改为"激活锚点/Activation Anchors"

### v3.1.0 — 激活锚点与知识缺口协议

**定位升级**：从"数学知识库"转为"数学激活系统"——知识库不是封闭百科，而是激活锚点集合。

- **核心原则**：Math Skill 不存储数学，它激活数学、路由数学，并把数学翻译成 AI 研究设计
- **知识缺口协议**：当现有锚点不覆盖时，6 步流程生成临时知识卡（缺口识别→透镜回退→候选定位→临时知识卡→设计翻译→升级建议）
- **领域扩展索引**：7 个数学领域各增 `index.md`，列出触发信号、扩展概念、参考书方向、临时激活规则
- **知识卡片重定位**：每张卡片增加"路由扩展"和"可扩展方向"，从终点变为路由节点
- **设计模式定位**：新增 `design-patterns/overview.md`，声明为 math→AI 翻译原型集合

### v3.0.1 — Token 优化与双语补全

- **Emoji 清理**：移除所有 skill 文件中的 emoji 符号，GPU 评级标记替换为文本 `[v]`/`[~]`/`[x]`，节约 ~1,400 tokens
- **英文蒸馏稿补全**：7 本书蒸馏稿新增英文翻译（`references/books/*.en.md`），`commands/ask.en.md` 新增英文入口
- **混合语言路由**：新增 5 条判定规则，解决中英混杂输入的路由问题（技术词不计入语言判定，按句式主框架判定）
- **GPU 维度缩写**：八维标签从 `**维度 N 全称**` 压缩为 `**DN**`（D1-D8），定义于 `gpu-friendly-math.md`，额外节约 ~800-1,000 tokens
- 术语统一、交叉引用修正及其他小问题修复

### v3.0.0 — 数学研究操作系统

**架构重构**：从"思想武器库"升级为"数学参谋部"——三层正交架构：

- **思想透镜**（15 个）：从 v2 的"思想武器"瘦身而来，只保留推理方法论，不再混入具体数学知识
- **知识库**（31 张卡片，v3.2 起扩展至 37）：按数学领域组织的具体工具卡片，含定义/公式/AI 设计翻译/GPU 可行性
- **设计翻译层**（新增）：数学→AI 模块的桥梁，按 AI 组件（attention/loss/routing/representation/compression）组织
- **Activator 重写**：从环境信号匹配改为意图诊断（5 场景：分析/设计/查询/验证/工程）
- **知识激活协议**：知识卡片固定输出格式（最小定义→公式→适用问题→AI 翻译→工程可行性→风险）

### v2.1.0 — 完整双语支持
- 全面双语、自动语言路由、命令一致、token 保障

### v2.0.0–v2.0.1
- 16 思想武器（v2 旧名，v3 起改为 15 透镜）、现代数学激活层、GPU 八维横切；收紧自动触发条件与排除门

### v1.0.0
- 初始发布：早期"思想武器库 + 科研与生活双路径"形态（已在 v3.0.0 重构为三层架构）

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
