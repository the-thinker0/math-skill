<div align="center">

# 📐 Math Skill

### 面向 AI 与密码学创新的数学研究操作系统

<a href="README.md">中文</a> | <a href="README.en-US.md">English</a>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

</div>

> Math Skill 不存储数学，它激活数学、路由数学，并把数学翻译成 AI 研究设计。

面向 **Claude Code / Codex / Cursor 等** 的数学推理技能——在 AI 架构设计、数学结构迁移和密码学证明审查中，自动激活正确的数学透镜、知识锚点和设计原型，给出带条件、带反例、可证伪的结论。

如果这个 skill 对你有启发，欢迎点亮一颗 Star⭐。你的支持是项目持续打磨的动力。

---

## 它和直接问 AI 有什么区别？

### 【AI】案例 1：分析——"KAN 的数学基础和风险"

**用户**："KAN 用可学习 B-spline 替代 ReLU，声称比 MLP 更准确且可解释。我想分析它的数学基础和潜在风险。"

**不调用 Skill**：
> KAN 基于 Kolmogorov-Arnold 表示定理，用 B-spline 作为可学习激活函数放在边上。优点是参数效率高、激活函数可解释。风险主要是 spline 计算比 ReLU 慢、grid 过细可能过拟合。建议在具体任务上做消融实验。

**调用 Skill 后**（激活：扰动 + 谱分解透镜 → `low-rank-approximation` 锚点）：

> **结论**：KA 定理保证表达能力的**存在性**，不保证**可学习性**。决定 KAN 实际性能的两个被忽视的数学量是 spline 基的有效秩和参数空间的 Fisher 曲率。
>
> - **存在性 ≠ 可学习性**：KA 定理保证 ∑φ_q(∑ψ_{q,p}(x_p)) 可表示任意连续函数，但与 MLP 的万能逼近定理一样，不保证梯度下降能找到该表示
> - **Spline 基有效秩**：B-spline 基函数的支撑重叠导致 effective rank 远低于参数增长；若 grid 细化但基函数高度相关，实际表达能力增长停滞——需监控奇异值衰减曲线而非只看参数量
> - **Fisher 曲率**：spline 的二阶可导使 Hessian 更规则，但 Fisher 信息矩阵的 condition number 可能远大于 ReLU 网络；natural gradient 有理论优势但估计成本更高
> - **可证伪实验**：比较 KAN 与同参数预算 MLP 的 spline 基有效秩衰减；若 rank 增长停滞而参数持续增长，则"可解释"优势被冗余抵消

### 【密码学】案例 2：验证——"PRF 水印归约的紧度"

**用户**："我用 PRF 给模型权重加水印，归约证明说'去水印 ≥ 破 PRF'。这个归约 tight 吗？"

**不调用 Skill**：
> 如果去水印的难度等价于区分 PRF 输出和真随机，那么在水印方案依赖的 PRF 安全假设成立时，归约是紧的。建议选择 AES-based PRF 以确保假设强度。

**调用 Skill 后**（激活：`reduction-proof-template` + `prf-prg-owf` 锚点）：

> **结论**：归约方向正确，但紧度取决于查询数 Q 和模拟质量，不能仅凭"假设 PRF 安全"就声称紧归约。
>
> - **归约损失**：Adv^scheme ≤ Q · Adv^PRF + δ，其中 Q 是敌手查询数。若 Q 随模型参数量线性增长，具体安全参数显著退化——必须报告 Q 的量级，不能只写"多项式损失"
> - **模拟质量**：归约须构造模拟器 B 回答敌手 oracle 查询；若 B 的模拟分布与真实游戏统计距离不可忽略，整个归约失效
> - **假设层级**：AES 当 PRF 是广泛采用的经验假设，不是从规范无条件证明的定理——标准模型、ROM、具体安全三个层级不能混用
> - **多用户退化**：模型部署后多用户独立查询，birthday bound 和 hybrid 步数放大优势损失
> - **可证伪检查**：写出 B 的完整模拟（参数生成、查询回答、挑战嵌入、abort 处理），代入具体参数估计 Q 和 δ

---

## 快速开始

### 安装

**npx**（推荐）：

```bash
npx -y math-skill@latest install --all
```

**或把项目地址丢给 AI，让它自行安装**：

```
请帮我安装 math-skill：https://github.com/the-thinker0/math-skill，并教我如何使用
```

> 也支持：`install --codex` / `--claude`（单独）、`update --all`（更新）、`doctor --all`（检查重复入口）
> 安装器自动排除内层 `skills/` 目录，保证每个平台只有一个入口。

### 使用

**自动触发**：系统自动诊断用户意图，路由到合适的层：

| 场景 | 诊断信号 | 调用路径 |
|------|---------|---------|
| 问题分析 | "这个设计合理吗？" | 透镜 → 紧凑审查 |
| 机制设计 | "设计新 attention" | 透镜 → 锚点 → 设计翻译 → 紧凑审查 |
| 知识查询 | "切空间和梯度优化有什么关系？" | 激活锚点 |
| 验证审查 | "这个归约的 tightness 够吗？" | 锚点 → 条件/边界 |
| 纯工程 | debug、重构、调参 | **不触发** |

**手动触发**：

```
/ask <你的问题>          # 智能诊断：自动判断场景并路由
```

### 语言

自动检测中英文：中文消息返回中文输出，英文消息返回英文输出。技术词、代码、公式不决定语言。

---

## 三层正交架构

```
问题 → 透镜（用什么视角看？）→ 锚点（激活哪些数学结构？）→ 设计翻译（变成什么模块？）→ 审查（站得住吗？）
```

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

## 灵感

为解微分方程发明的李群-李代数，最终成为描述对称性和机器人状态估计的通用语言——数学工具的价值远超初衷，这正是「跨领域激活」的原型。详见 [`references/inspiration.md`](references/inspiration.md)。

---

## 路由范例

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

- **权威入口与渐进加载**：根 `SKILL.md`/`SKILL.en.md` 成为自足规范入口；五类场景设最小加载路径（默认 1-2 透镜、1-3 锚点、0-2 模式），概念查询与纯密码任务不再默认加载完整 critic/书稿/GPU 清单
- **Domain Router 重写**：从关键词投票改为按"目标对象 + 所求保证"判域；`hashing`/`attack`/`security` 等孤立词不再误触发密码学；纯 AI、纯密码、共用数学和 AI×密码交叉路径明确隔离
- **密码学去污染与数学校正**：四张密码学锚点改用安全定义/攻击游戏/归约损失组织，不再强塞 AI 翻译或 GPU 验收；修正投影伪逆条件、KL 方向、低秩梯度表述、正交损失公式等过度类比；所有保证/等价/最优表述强调成立条件
- **双语与 GPU 审查收敛**：密码学书稿完整中英配对；GPU 审查改为相关性驱动（只评决策相关维度，无关项标 N/A）；普通任务用紧凑检查，19 维 critic 仅论文级审查加载
- **索引、eval 与验证同步**：更新 skill-index/overview/agentic-workflow 和 A/B/C/D/E eval 场景；Bash/PowerShell 验证覆盖 frontmatter、37 锚点配对、交叉引用、Domain Router 隔离等

### v3.2.1 — 设计哲学修正与可靠性增强

- **设计哲学明确化**：声明 skill 是思考的 activator 而非百科；`knowledge-base/` 回归数学结构本身（不固化 AI 架构），`design-patterns/` 定位为翻译范式示范而非模板库
- **密码学与代数几何锚点补齐**：新增 `knowledge-base/cryptography/`（4 卡）与 `knowledge-base/algebraic-geometry/`（2 卡），使 Domain Router 密码学层有实质锚点
- **测试与验证扩展**：新增场景 A/D eval、交叉域路由、Knowledge Gap Protocol、Domain Router 隔离测试；validate.sh 增加知识卡六段结构与 GPU 八维覆盖检查
- **critic 19 维分层**：核心/情境/强制/元四层标注，减少 Agent 认知负担
- **inspiration.md 拆分**：技术灵感保留，哲学内容移至 `musings.md`

### v3.2.0 — 密码学方向接入 + Domain Router

- **新增 3 本密码学书稿**：Boneh & Shoup、Goldreich、Katz & Lindell 蒸馏稿（中英成对），精简为 ~125-155 行/本的激活索引格式
- **Domain Router 路由层**：意图诊断后、透镜前判定问题 domain（AI/密码/纯数学/交叉），按 domain 加载专属内容，共用数学不重复加载，避免跨域污染
- **math-critic 升级 19 维**：新增密码学安全审视维度（安全定义/归约紧度/假设依赖/合成陷阱/反模式/跨域迁移）
- **Token 优化**：密码学书稿从 2084 行精简到 404 行（~80%）；纯 AI 问题不加载密码书稿（省 ~400 行/次），纯密码不加载 AI 设计模式（省 ~2200 行/次）
- **AI 与密码学隔离**：Domain Router 明确"纯 AI 不加载密码学书稿；纯密码不加载 AI 设计模式"

### v3.1.1 — 术语闭环清洁

- **"激活锚点"口径统一**：skill-index、README、SKILL.md 中"数学知识/知识卡片"统一改为"激活锚点"
- **README 纠正**：工作流范例第三步从"知识查询"改为"激活锚点"；`leverage-score-selection` 标签修正
- **SKILL.md 架构表更新**：三层架构表和意图诊断表术语对齐
- **英文 README 书目链接**：蒸馏文件从 `.md` 改为 `.en.md`
- **validate 关键词**：从"数学知识"改为"激活锚点"

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
