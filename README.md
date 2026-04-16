# ⚔️ Math Skill — 数学思想武器

> **数学思想武器：将数学思维应用到科研和生活中。**\
> **Mathematical Thinking Weapons: Apply Mathematical Thinking to Research and Daily Life.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 核心理念 / Philosophy

数学不只是一种计算工具，更是一种**思想方法**。从公理化到抽象，从逻辑演绎到概率思维，数学提供了理解世界的独特视角。

这个 skill 将数学中最核心的思想方法提取为**可操作的思维框架**，帮助你在科研中发现新角度、在生活中做出更理性的决策。它既是研究者的思维武器，也是一套生活问题的理性工具。

> "数学不只是计算，它是关于结构、关系和变化的系统性思考方式。"\
> "Mathematics is not just computation — it is a systematic way of thinking about structure, relationships, and change."

---

## 双路径模式 / Dual-Path Mode

每个思想武器都有两种模式：

- **科研模式 / Research Mode**：保留完整数学符号与推导，适用于数学推导、论文审查、算法设计、实验设计优化
- **生活模式 / Life Mode**：只保留思维框架的核心步骤，用日常语言替代数学符号，适用于日常决策、人际互动、时间管理、生活规划

系统根据问题性质自动选择模式——科研问题自动使用科研模式，生活问题自动使用生活模式。不再用 KKT 条件分析人际矛盾，也不用纳什均衡公式计算时间分配。

---

## 十六思想武器 / Sixteen Thinking Weapons

| # | 思想武器 | 核心要义 | 科研应用 | 生活应用 |
|---|---------|---------|---------|---------|
| 0 | 🧭 [武器选择器](skills/meta-selector/SKILL.md) | 不确定该用哪个工具时，根据问题特征推荐1-3个最合适的思想武器 | 选择审视维度、判断方法论方向 | 面对模糊问题时快速定位切入点 |
| 1 | 📐 [公理化思想](skills/axiomatization/SKILL.md) | 从最少假设出发，严格逻辑构建 | 审查论文假设合理性、构建理论框架 | 分析观点的逻辑前提、识别隐含假设 |
| 2 | 🧩 [抽象化思想](skills/abstraction/SKILL.md) | 抓住本质，忽略非本质细节 | 提炼科学问题核心、发现跨领域共性 | 简化复杂问题、透过现象看本质 |
| 3 | 🧠 [逻辑演绎](skills/logic-deduction/SKILL.md) | 从真命题严格推理新真命题 | 检查证明严谨性、发现逻辑漏洞 | 性辩论、识别逻辑谬误 |
| 4 | 🌉 [建模思想](skills/modeling/SKILL.md) | 现实问题→数学问题→解释现实 | 构建科研模型、预测实验结果 | 规划预算、路线、风险评估 |
| 5 | ⚖️ [优化思想](skills/optimization/SKILL.md) | 约束条件下寻找最优解 | 实验设计优化、资源分配优化 | 时间管理、投资组合、购物决策 |
| 6 | 🎲 [概率与统计](skills/probability-statistics/SKILL.md) | 量化不确定性，数据提取规律 | 实验数据分析、显著性检验 | 解读新闻数据、评估风险、避免偏差 |
| 7 | 🔄 [变换思想](skills/transformation/SKILL.md) | 复杂问题→等价简单问题 | 信号处理、方程求解、数据降维 | 换角度看问题、分解难题 |
| 8 | ⚛️ [对称与不变性](skills/symmetry-invariance/SKILL.md) | 变换下保持不变的性质 | 发现守恒量、分类研究对象 | 寻找不变量、识别模式 |
| 9 | 📈 [归纳与类比](skills/induction-analogy/SKILL.md) | 从特殊到一般，已知到未知 | 提出科学假说、发现新定理 | 从经验中学习、跨领域借鉴 |
| 10 | 🖥️ [算法与计算思想](skills/algorithmic-thinking/SKILL.md) | 将问题转化为有限步骤的程序 | 分析计算代价、判断问题可行性 | 设计高效流程、自动化重复任务 |
| 11 | 📡 [信息论思想](skills/information-theory/SKILL.md) | 信息是不确定性的减少 | 最优压缩、信道容量、特征选择 | 评估信息价值、减少冗余 |
| 12 | 🎯 [博弈论思想](skills/game-theory/SKILL.md) | 最优策略取决于他人的选择 | 多方互动决策、机制设计 | 谈判策略、竞争分析 |
| 13 | 🔗 [因果推断思想](skills/causal-inference/SKILL.md) | 相关≠因果，但因果可形式化 | 干预效果评估、政策评价 | 区分原因与借口、反事实思考 |
| 14 | 🌀 [拓扑思想](skills/topological-thinking/SKILL.md) | 连续变形下不变的性质 | 拓扑数据分析、形状分类 | 理解连通结构、鲁棒性分析 |
| 15 | 🧮 [离散与组合思想](skills/discrete-combinatorial/SKILL.md) | 计数、枚举、有限对象的规律 | 组合计数、图论分析、生成函数 | 系统性枚举、鸽巢推理 |

---

## 快速开始 / Quick Start

### 安装 / Installation

直接粘贴下面这段给 Claude Code、OpenClaw 或其他终端型 AI 助手即可：

```
请帮我安装 math-skill：https://github.com/the-thinker0/math-skill，并教我如何使用
```

手动安装备选：

```bash
npm install math-skill    # npm
```

or:
```bash
git clone https://github.com/the-thinker0/math-skill.git  # GitHub
```

其他平台（Cursor 等）：核心内容是通用 Markdown，请参照各平台文档将其放入要求的目录结构中。

### 使用

在 Claude Code 等支持 skill 的 AI 助手中，使用以下命令触发对应思想武器：

```
/ask <你的问题>                     # 武器选择器（不确定该用哪个工具时先问这个）
/axiomatization <你的问题>          # 公理化思想
/abstraction <你的问题>             # 抽象化思想
/logic-deduction <你的问题>         # 逻辑演绎
/modeling <你的问题>                # 建模思想
/optimization <你的问题>            # 优化思想
/probability-statistics <你的问题>  # 概率与统计
/transformation <你的问题>          # 变换思想
/symmetry-invariance <你的问题>     # 对称与不变性
/induction-analogy <你的问题>       # 归纳与类比
/algorithmic-thinking <你的问题>    # 算法与计算思想
/information-theory <你的问题>      # 信息论思想
/game-theory <你的问题>             # 博弈论思想
/causal-inference <你的问题>        # 因果推断思想
/topological-thinking <你的问题>    # 拓扑思想
/discrete-combinatorial <你的问题>  # 离散与组合思想
```

### 语言切换

默认输出为**中文**。如需**英文**输出，在命令后追加 `in English`：

```
/optimization How should I allocate my research time this semester? in English
```

---

## 使用场景示例 / Usage Examples

### 不确定该用哪个工具时

```
/ask 我面对一个复杂的决策，既涉及多方互动又涉及资源分配，不知道从哪个角度切入...
```

### 科研场景

**审查论文的理论基础**：
```
/axiomatization 这篇论文声称从三个假设推导出新定理，但我怀疑假设集合可能不自洽...
```

**检查证明的逻辑**：
```
/logic-deduction 定理 3.2 的证明中，第 5 行到第 6 行的推导是否有逻辑跳跃？
```

**构建数学模型**：
```
/modeling 我的实验数据显示变量 x 和 y 有某种非线性关系，用什么模型来描述？
```

**优化实验设计**：
```
/optimization 我有 3 个实验要做，只有 2 周时间，每个实验需要不同设备，怎么安排？
```

**统计检验**：
```
/probability-statistics 新药有效率比旧药高 15%，p=0.03，n=50，结果可靠吗？
```

### 生活场景（自动使用生活模式）

**时间管理**：
```
/optimization 我需要在论文、作业和社交之间分配时间，论文 deadline 还有两周...
```

**解读新闻**：
```
/probability-statistics 新闻说某种食物能使患癌风险降低 30%，我应该多吃吗？
```

**解决人际矛盾**：
```
/transformation 我无法解决和室友的矛盾，在当前沟通方式下僵局似乎无法打破...
```

---

## 目录结构 / Directory Structure

```
math-skill/
├── .gitignore               # Git 排除文件
├── .npmignore               # npm 发布排除文件
├── package.json             # 包描述文件
├── commands/                # 手动触发的 slash 命令入口
│   ├── ask.md               # 武器选择器命令
│   ├── axiomatization.md
│   ├── abstraction.md
│   ├── logic-deduction.md
│   ├── modeling.md
│   ├── optimization.md
│   ├── probability-statistics.md
│   ├── transformation.md
│   ├── symmetry-invariance.md
│   ├── induction-analogy.md
│   ├── algorithmic-thinking.md
│   ├── information-theory.md
│   ├── game-theory.md
│   ├── causal-inference.md
│   ├── topological-thinking.md
│   └── discrete-combinatorial.md
├── skills/                  # 十六思想武器详细定义
│   ├── meta-selector/       # 武器选择器（第0号武器）
│   │   ├── SKILL.md
│   │   └── original-texts.md
│   ├── axiomatization/
│   │   ├── SKILL.md         # 核心方法论 + 操作规程（科研模式 + 生活模式）
│   │   └── original-texts.md # 数学出处与经典文献
│   ├── abstraction/
│   ├── logic-deduction/
│   ├── modeling/
│   ├── optimization/
│   ├── probability-statistics/
│   ├── transformation/
│   ├── symmetry-invariance/
│   ├── induction-analogy/
│   ├── algorithmic-thinking/
│   ├── information-theory/
│   ├── game-theory/
│   ├── causal-inference/
│   ├── topological-thinking/
│   └── discrete-combinatorial/
├── knowledge-base/          # 数学知识体系概述
│   └── overview.md
├── agents/                  # 子 Agent 定义
│   └── math-critic.md       # 数学审视子 Agent
├── tests/                   # 验证脚本
│   ├── validate.sh
│   └── validate.ps1
├── docs/                    # 使用指南
│   └── CLAUDE.md
├── README.md
└── LICENSE
```

---

## 每个思想武器包含什么 / What Each Skill Contains

每个思想武器 (`skills/*/SKILL.md`) 包含以下部分：

1. **核心原则** — 该思想方法的精髓，配有数学家的名言。数学形式化部分用独立标记，生活模式读者可跳过
2. **不适用场景** — 何时不应该使用该工具（避免误用），标注适用模式 `[科研/通用/生活]`
3. **何时使用** — 科研触发条件和生活触发条件分别列出
4. **方法流程** — 分步操作指南，每步配有**科研模式**（完整数学）和**生活模式**（日常语言）两条路径，以及**共通要点**
5. **常见错误** — 错误做法与正确做法的对比表，标注适用模式
6. **操作规程** — 双路径输出格式：科研模式输出格式和生活模式输出格式，确保每次使用都有可观测的结果
7. **与其他 skill 的关系** — 思想武器之间的联系

此外，每个思想武器还配有 `original-texts.md`，包含：
- 数学出处和经典文献
- 重要定理的原始表述
- 历史背景和哲学含义

---

## 数学知识体系 / Mathematical Knowledge System

`knowledge-base/overview.md` 提供了完整的数学知识体系地图：

### 三大基础支柱

- **代数学** — 数、结构、关系和符号运算
- **几何学** — 空间、形状、结构及其关系
- **分析学** — 函数、极限、连续、微分、积分

### 主要分支

数论、概率统计、拓扑学、离散数学、应用数学（运筹学、信息论、金融数学等）

### 知识层次

地基层 → 代数层 → 综合层 → 前沿层

---

## 灵感来源 / Inspiration

灵感来自于个人学习中的两段感悟：Sophus Lie 打造"屠龙刀"的故事告诉我们，数学工具的价值远超其初衷——为解微分方程发明的李群-李代数，最终成为描述对称性的通用语言；而最优化理论与人生决策的哲学共鸣，让人意识到数学不只是算法，更是理解生活的透镜。详见 [`docs/inspiration.md`](docs/inspiration.md)。

---

## 许可证 / License

MIT License. 详见 `LICENSE`。

---

## 贡献 / Contributing

欢迎提交 Issue 和 Pull Request，与大家一起交流！