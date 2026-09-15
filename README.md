<div align="center">

# 📐 Math Skill

### 把研究目标变成数学构造与验证

<a href="README.md">中文</a> | <a href="README.en-US.md">English</a>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

**🎉 NEWS: v3.3.7 已发布 · 已支持 dsh harness 🚀**

</div>

> 从目标与约束出发，推导可实现机制，并用证据决定下一步。

面向 **Claude Code / Codex / Cursor / DeepSeek Harness (dsh) 等** 的数学推理技能——在 AI 架构设计、数学结构迁移和密码学证明审查中，将模糊目标形式化，构造算子与验证方法，也支持已有论证和密码学安全性的审查。

如果这个 skill 对你有启发，欢迎点亮一颗 Star⭐。你的支持是项目持续打磨的动力。

---

## 它如何帮助研究？

本轮重点是发现有价值的跨数学领域思路，再将值得做的方向落实为机制或研究结论，不要求用户先知道该用哪种数学。原有 15 个透镜、41 张锚点和 22 个原型继续作为材料；候选不受这个目录限制。

| 用户输入 | 新增处理方式 | 按需资源 |
|---|---|---|
| “只有研究目标，还没有公式” | 从期望/失败行为选对象，推导更新或决策规则 | [构造工作台](references/design-workbench.md) |
| “想要有价值的跨数学领域思路，减少套模板” | 沿任务缺失的结构关系寻找新领域，核验对象对应并比较不同机制 | [结构迁移](references/structural-transfer.md) |
| “这个定理怎么变成真实模块？” | 将条件落实为参数化约束、求解残差或可检验假设 | [从定理到实现](references/design-workbench.md) |
| “运行一个小验证，再接着改” | 为当前候选生成检查，记录失败，修订后再验证 | [研究循环](references/agentic-workflow.md) |

三条迁移示例展示如何发现机会或排除错误路线：[观测信息与函数空间投影](references/structural-transfer.md)、[连续选向的拓扑障碍与多解表示](references/transfer-bridges.md)、[局部一致性与纠错距离](references/transfer-bridges.md)。示例用于校准什么算真实结构对应，不是固定推荐菜单。

一次独立的在线信息融合试用生成了“四值证据格”和“真值与来源故障联合后验”两条路线，含具体推导与失效条件。[试用记录与原始回答](tests/usability/README.md)保留了证据和局限；单次结果不代表整体质量提升。

选定结构后，可按需参考五类[数学构造动作](references/construction-moves.md)。例如，廉价函数基统计可与随机残差修正组合，推导出条件无偏的线性聚合估计；归一化、方差和存储边界需要分别检查。这提供构造新计算图的起点，不宣称已经取得任务收益或论文新颖性。

下面保留三组可复算的数学核验案例：

| 研究问题 | 关键检查 | 完整案例 |
|---|---|---|
| SVD 压缩误差很小，是否对所有未来 query 保持 attention？ | 二维反例；query 范数受限时的输出误差界；基底与系数存储成本 | [低秩 KV 与 query](references/worked-examples/query-aware-compression.md) |
| attention 是否对 token 置换等变？ | score 的共轭变换、位置编码/causal mask、有限群平均的逆作用 | [等变性检查](references/worked-examples/equivariance-check.md) |
| PRF 安全能给 MAC 多紧的伪造界？ | 固定新鲜性游戏；实际 oracle 次数；不凭空添加 Q 倍损失 | [PRF→MAC 归约](references/worked-examples/security-reduction.md) |

普通鲁棒性证书（如 Lipschitz 或随机平滑）仍属 AI 数学问题；出现“证书”“攻击”“证明”不自动进入密码学。只有涉及密码学原语/安全实验与 AI 对象的组合时，才加载交叉域材料。

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

> 也支持：`install --codex` / `--claude` / `--dsh`（单独）、`update --all`（更新）、`doctor --all`（检查安装完整性与重复入口）
> 安装器自动排除内层 `skills/` 目录，保证每个平台只有一个入口。
>
> **DeepSeek Harness (dsh)**：`--dsh` 写入 `~/.dsh/skills/math-research-activator/`（可用 `$DSH_HOME` 覆盖）。安装后重启 dsh，命令面板输入 `/math-research-activator` 即可调用。也可手动把该目录放到项目级 `.dsh/skills/` 或共享的 `~/.agents/skills/`。

### 使用

**自动触发**：系统自动诊断用户意图，路由到合适的层：

| 场景 | 诊断信号 | 调用路径 |
|------|---------|---------|
| 问题分析 | "这个设计合理吗？" | 从现有对象分析；按需使用锚点或透镜 |
| 跨域探索 | "能从不同数学领域找两条思路吗？" | 结构缺口 → 对象对应 → 推导与反例筛选 |
| 机制设计 | "我希望模块有这种行为，该怎么设计？" | 目标形式化 → 推导机制 → 实现与验证 |
| 知识查询 | "切空间和梯度优化有什么关系？" | 激活锚点 |
| 验证审查 | "这个归约的 tightness 够吗？" | 锚点 → 条件/边界 |
| 纯工程 | debug、重构、调参 | **不触发** |

**手动触发**：

```
/ask <你的问题>                       # Claude Code / Codex：智能诊断并路由
/math-research-activator <你的问题>   # DeepSeek Harness (dsh) 命令面板
```

### 语言

自动检测中英文：中文消息返回中文输出，英文消息返回英文输出。技术词、代码、公式不决定语言。

---

## 三层正交架构

```
研究目标 → 数学形式化 → 构造与推导 → 实现对应 → 验证与修订
                  ↑ 按需使用透镜、锚点、原型；不是固定流水线
```

| 层 | 职责 | 目录 | 文件数 |
|----|------|------|--------|
| **思想透镜** | 诊断问题结构，推荐数学视角 | `lenses/*.md` | 15 |
| **激活锚点** | 37 个共用数学锚点 + 4 个密码学锚点；不足时触发知识缺口协议 | `knowledge-base/*/*.md` | 41 |
| **设计翻译** | 把数学变成 AI 模块/loss/算子 | `design-patterns/*/*.md` | 22 |

辅助层：
- [结构迁移](references/structural-transfer.md) + [迁移桥示例](references/transfer-bridges.md)：主动寻找跨数学领域对应，检验迁回结论与价值
- [构造工作台](references/design-workbench.md) + [数学构造动作](references/construction-moves.md)：从目标生成机制，落实条件与实现
- [研究循环](references/agentic-workflow.md)：执行小验证、依据结果修订并接续上下文
- `references/books/*.md`：10 本书蒸馏稿（7 本 AI 方向 + 3 本密码学方向），需要深入时的完整上下文
- `references/gpu-friendly-math.md`：按需 GPU 检查；不适用维度标 N/A
- `agents/math-critic.md`：仅全面/论文级审查按需加载的 19 维深度批判器

### Domain Router

AI 研究与密码学**共享**数学根基（概率/信息/代数/矩阵/谱/优化），但**独有**各自专业层。Domain Router 在意图诊断后、调用透镜前，先判定问题归属，决定加载哪些锚点/书稿/设计模式，避免跨域污染与 token 浪费。

| Domain | 加载内容 | 信号词 |
|--------|---------|--------|
| **共用数学** | 8 域 37 锚点 + 相关透镜 | 概率/信息/代数/几何/矩阵/谱/优化/拓扑/复杂度 |
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
| 矩阵分析 | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation, random-matrix, hankel-state-space |
| 最优化 | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| 微分几何 | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| 李理论 | group-action, lie-group, lie-algebra, representation, equivariance |
| 拓扑 | persistent-homology, euler-characteristic, fundamental-group |
| 概率与信息 | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information, optimal-transport, score-matching-sde |
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

## 从问题出发的范例

“压缩 KV Cache 且保留长期依赖”首先需要确定应保留哪些未来查询的答案。由此可寻找对查询族充分的摘要、比较一致逼近与分布平均风险，并构造摘要相同而答案不同的反例；不能先把候选定成低秩加 top-k。完整推导见 [工作流范例](references/skill-index.md#工作流范例)。
---

## 目录结构

```
math-skill/
├── SKILL.md / SKILL.en.md          # 安装入口：意图诊断 + 路由
├── skills/math-research-activator/ # 仓库兼容入口（不随 npm 分发）
├── lenses/                         # 15 个思想透镜（推理方法论）
├── knowledge-base/                 # 激活锚点（按数学领域组织，非封闭百科；共 41 卡）
│   ├── matrix-analysis/            # 矩阵分析（7 卡片）
│   ├── optimization/               # 最优化（5 卡片）
│   ├── differential-geometry/      # 微分几何（6 卡片）
│   ├── lie-theory/                 # 李理论（5 卡片）
│   ├── topology/                   # 拓扑（3 卡片）
│   ├── probability/                # 概率与信息（7 卡片）
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
│   ├── worked-examples/            # 3 组中英案例，含可运行数值检查
│   ├── structural-transfer.md     # 从任务结构寻找跨数学领域思路
│   ├── transfer-bridges.md         # 结构对应、反例与研究机会
│   ├── design-workbench.md         # 从模糊目标构造可实现机制
│   ├── construction-moves.md       # 5 类可组合数学动作
│   ├── gpu-friendly-math.md        # GPU 维度清单（仅评相关项）
│   ├── agentic-workflow.md         # 协作方式
│   ├── inspiration.md              # 灵感来源
│   ├── musings.md                  # 杂谈（哲学感悟，不自动加载）
│   └── skill-index.md              # 索引（按需目录，不默认加载）
├── agents/math-critic.md           # 数学-工程双重批判器（19 维，含密码学安全审视）
├── commands/ask.md                 # /ask 手动入口
├── bin/math-skill.cjs              # 安装、更新、诊断和卸载
├── tests/                         # 结构、安装器、评测与案例回归（不发布）
├── math_book/                      # 本地 PDF（不发布）
└── README.md / LICENSE
```

---

## 推荐书目

### AI 方向（7 本）

| # | 书名 | 作者 | 出版社 / 版次 | 年份 | ISBN | 蒸馏文件 |
|---|------|------|-------------|------|------|---------|
| 1 | *Contemporary Abstract Algebra* | Joseph A. Gallian | Brooks/Cole, Cengage, 8th ed. | 2013 | 978-1-133-59971-5 | [中文](references/books/abstract-algebra.md) / [EN](references/books/abstract-algebra.en.md) |
| 2 | *The Rising Sea: Foundations of Algebraic Geometry* | Ravi Vakil | Princeton University Press | 2025 | 978-0-691-26866-8 | [中文](references/books/algebraic-geometry-rising-sea.md) / [EN](references/books/algebraic-geometry-rising-sea.en.md) |
| 3 | *Manifolds and Differential Geometry* | Jeffrey M. Lee | AMS, Graduate Studies in Math Vol. 107 | 2009 | 978-0-8218-4815-9 | [中文](references/books/differential-geometry.md) / [EN](references/books/differential-geometry.en.md) |
| 4 | *Matrix Analysis* | Roger A. Horn, Charles R. Johnson | Cambridge University Press, 2nd ed. | 2013 | 978-0-521-83940-2 | [中文](references/books/matrix-analysis.md) / [EN](references/books/matrix-analysis.en.md) |
| 5 | *A micro Lie theory for state estimation in robotics* | Joan Solà et al. | arXiv:1812.01537v9 | 2021 | — | [中文](references/books/micro-lie-theory.md) / [EN](references/books/micro-lie-theory.en.md) |
| 6 | *An Introduction to Optimization, With Applications to ML* | Chong, Lu, Żak | John Wiley & Sons, 5th ed. | 2024 | 978-1-119-87763-9 | [中文](references/books/optimization-ml.md) / [EN](references/books/optimization-ml.en.md) |
| 7 | *Introduction to Smooth Manifolds* | John M. Lee | Springer, GTM 218, 2nd ed. | 2013 | 978-1-4419-9981-8 | [中文](references/books/smooth-manifolds.md) / [EN](references/books/smooth-manifolds.en.md) |

### 密码学方向（3 本）

| # | 书名 | 作者 | 出版社 / 版次 | 年份 | ISBN | 蒸馏文件 |
|---|------|------|-------------|------|------|---------|
| 8 | *A Graduate Course in Applied Cryptography* | Dan Boneh & Victor Shoup | v0.6 在线版 | 2023 | — | [中文](references/books/applied-cryptography.md) / [EN](references/books/applied-cryptography.en.md) |
| 9 | *Foundations of Cryptography, Volume 1: Basic Tools* | Oded Goldreich | Cambridge University Press | 2001 | 978-0-521-79172-4 | [中文](references/books/foundations-of-cryptography.md) / [EN](references/books/foundations-of-cryptography.en.md) |
| 10 | *Introduction to Modern Cryptography* | Jonathan Katz & Yehuda Lindell | CRC Press, 2nd ed. | 2015 | 978-1-4665-7026-9 | [中文](references/books/introduction-to-modern-cryptography.md) / [EN](references/books/introduction-to-modern-cryptography.en.md) |

蒸馏文件已随 npm 包发布。如需全保真原文，将 PDF 放入 `math_book/` 文件夹即可。

---

## 验证与下一版本状态

在仓库检出目录运行：

```bash
npm run validate
npm test
npm run eval:behavioral
```

`validate` 检查双语、计数、路径、frontmatter、70 例路由清单及 npm 文件清单；`test` 覆盖安装回滚、评测失败路径及案例中的可运行检查。行为评测需要可信运行时适配器，缺配置明确显示 **SKIP**；要求真实运行证据时加 `--require-runtime`。详见仓库内的[评测契约](tests/eval/README.md)（tests 不随 npm 分发）。

`doctor` 检查必需资源与重复入口，损坏/重复安装返回 2；未知参数返回 1。Windows 仍需原生环境验证；跨设备失败路径已用本地故障注入覆盖。

## 变更日志

### v3.3.7 — 跨数学领域探索、构造能力与评测自动化

- 新增结构迁移流程：从任务关系寻找新领域、建立可检查的对象对应、筛选能改变机制或研究判断的方向。
- 补充概率与函数分析、覆盖空间与多解表示、局部一致性与纠错距离的迁移示例；生成阶段推迟加载已有设计原型。
- 新增双语构造工作台与五类可组合数学动作，把临时知识卡接回实际构造，补齐定理条件到实现的对应。
- 主入口改为按目标求解/构造；透镜与原型成为按需工具，合并重复加载规训。
- 研究循环支持当前候选的小验证、失败修订和多轮状态延续。
- 修正透镜、锚点、设计模式和书稿中的公式、条件与伪代码，覆盖谱误差/任务误差、Stiefel 几何、曲率/Hessian、信息界、路由与密码归约。
- 用作者目录替换错误密码学章号，Boneh–Shoup 对齐 v0.6；补充三组双语完整案例和可操作的临时卡/来源记录。
- 查询/验证任务保留定理条件；鲁棒性证书不再误入密码域；移除 critic 递归路由和强制枚举候选。
- **数学勘误（双语同步 + 回归锁定）**：`prf-prg-owf` PRG 优势公式多余右括号修正；`natural-gradient` SVI 自然梯度改为 Hoffman et al. 2013 实际形式（差值对当前自然参数取：$\hat\lambda = \eta_0 + N\,\mathbb{E}_q[T]$，更新 $\lambda \leftarrow (1-\rho)\lambda + \rho\hat\lambda$）
- **Tier 1 评测自动化（CI 必跑）**：新增 `tests/eval/cases.jsonl`（70 例结构化断言）与零依赖 runner `run_eval.mjs`——schema 校验、纸面清单 ↔ manifest 双向 parity（防漂移）、Domain Router 隔离策略静态断言、may_load 存在性检查；已接入 `validate.mjs`
- **Tier 2 行为级评测槽**：新增 `behavioral_eval.mjs`——配置 `MATH_SKILL_EVAL_CMD` 即对真实 agent 输出做确定性判定（E 场景零引用、纯 AI 不引密码材料、纯密码不引设计模式、中文 CJK 占比）；未配置时安全跳过，不阻塞 CI
- **frontmatter 触发条款守护**：四个入口 description 的负面范围条款（"纯实现型 debug…不触发"/"Do not use…implementation-only debugging"）纳入语义回归，防止静默删除导致误触发
- 修复安装备份/回滚与残损安装检测；统一跨平台校验（`validate.mjs` 为单一校验核心），强化 schema/路径隔离，并区分静态通过与可信运行 trace。

### v3.3.6 — DeepSeek Harness (dsh) 适配

- **dsh skill 安装**：npx 安装器新增 `--dsh`，将标准 Agent Skills 包写入 `~/.dsh/skills/math-research-activator`（尊重 `$DSH_HOME`）；`--all` 与自动检测覆盖 dsh
- **调用方式**：dsh 命令面板 `/math-research-activator`；透镜/锚点等资源路径相对 skill 安装目录（dsh 的 `resourceBase`）
- **文档**：README 增加 NEWS 横幅与 dsh 安装/使用说明（中英同步）

### v3.3.5 — 知识勘误与锚点扩展

- **新增 4 张共用锚点**：`random-matrix`、`hankel-state-space`（矩阵分析）+ `optimal-transport`、`score-matching-sde`（概率与信息），补齐随机矩阵 / 最优传输 / 扩散-SSM 三类高频缺口；全仓计数统一为 37 共用 + 4 密码 = 41
- **数学勘误（双语同步）**：Bernstein 不等式补假设、Morse 公式修正、球面指数映射补前提、变分推断自然梯度公式修正、Cramér–Rao 路由纠正
- **表述精确化**：凸优化"唯一可高效求解"过强断言软化、KKT/Slater 措辞修正、KL 双向免责、持续同调可微性正确表述、Plücker 公式符号统一
- **跨文件自洽**：D1–D8 维度与 `[v]/[~]/[x]` 评级图例内联到 `gpu-friendly-math`；categorical/perturbation/game 透镜补域边界护栏，game 与密码攻击游戏互消歧

### v3.3.4 — v3.3.3 热修复

- **安装器热修复**：修复 `update --all` 在 skill 目标位残留非目录文件（如损坏旧安装的残留）时触发 `ENOTDIR`、导致 claude 侧升级失败的问题；现在安装器会先安全转移该残留再替换，升级不再中断

### v3.3.3 — 知识纠错·精益加载

- **知识内容纠错（双语）**：修正两本书稿与 README 的错误 ISBN（Goldreich、Katz & Lindell，经校验位验证）；修正拓扑透镜"同 χ 同曲面、同 π₁ 同同伦"的错误断言与孤儿路由 `tda`；local-to-global 中文把 monodromy 误译为"单值化定理"；categorical 透镜路由改正；VIB 目标补回 β 乘子
- **精益加载协议（省 token，不设输出模板）**：锚点按节读取、默认跳过尾部节，原型跳过与已读锚点重复的数学段，最小路径优先；输出结构由研究/设计任务决定，不套固定格式
- **工程修复**：validate.ps1 版本与 sh 对齐并补齐校验缺口；npx 安装器加内容完整性校验、拒绝残缺安装；发布包剔除 repo-only 的 `skills/` 死重与重复 name 声明
- **验证**：`validate.sh` 检查 529 → 537 全绿，新增内容与精益加载守护防回潮

### v3.3.2 — 产品化与 npx 安装器

- **npx CLI 安装器**：新增 `bin/math-skill.cjs`，支持 `npx -y math-skill@latest install/update/doctor/uninstall`；原子替换旧版、排除内层 `skills/` 防双入口、`doctor` 检查重复入口
- **README 产品化重构**：标题居中 + 副标题；首屏放案例和 Quick Start（原埋在 L128）；Star 求赞移至开头；npm 安装升级为 npx 首选；平台加"等"不限制框架
- **案例更新**：KAN 分析（AI）+ PRF 水印归约验证（密码学）替换旧 FFT/正交损失案例；"不调用 Skill"回答改为真实合理输出；案例标题加 `【AI】`/`【密码学】` 域标签
- **changelog 浓缩**：v3.3.0–v3.1.1 各版本从 7-13 点压缩至 5 点（~62% 篇幅缩减）；恢复 Sophus Lie 灵感小节和四步流程图

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
