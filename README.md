# ⚔️ Math Skill — 数学研究激活器 / Math Research Activator

> **把现代数学（代数几何 / 微分几何 / 李理论 / 范畴论 / 矩阵分析 / 最优化）激活进算法与 GPU 协同设计——既在 math 上 beautiful，又 GPU friendly。**
>
> **Activating modern mathematics (algebraic geometry / differential geometry / Lie theory / category theory / matrix analysis / optimization) into algorithm × GPU co-design — beautiful in math, friendly to GPUs.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

## 核心理念 / Philosophy

这次 AI 革命的数学基础，是 **20 世纪数学第一次登上商用计算舞台**——范畴论、代数拓扑、代数几何。当前主流算法的数学基础大多还停留在 1800–1900 年代的微积分 / 线性代数。把现代数学激活进算法设计，是算法探索阶段最重要的事。

这个 skill 把十六种数学核心思想封装为可调用的思维框架，并在工作区出现 ML / 模型代码、CUDA / kernel、算法研究笔记时**自动介入**：诊断问题 → 映射现代数学结构 → 路由思想武器 → GPU 可行性筛选，强制每个产出同时通过**双验收门**：

1. **数学正确（beautiful in math）**——自洽、可微（或可松弛为可微）、有正确性保证。
2. **GPU 可行（friendly to GPU）**——过 `references/gpu-friendly-math.md` 八维门。

> "模型内部已有足够的数学知识，缺的只是一次跨领域的激活。人选方向，Agent 搜索、枚举、验证。"

---

## v2.0.0 能力边界 / What v2.0.0 Does

- **自动触发入口**：`math-research-activator` 在工作区出现 ML / 模型代码、CUDA / kernel、算法研究笔记，且任务涉及结构、复杂度、显存、数值、并行或数学建模判断时主动介入。
- **现代数学激活层**：`references/books/*.md` × 7（代数几何、微分几何、李理论、抽象代数、矩阵分析、最优化、流形）作为低 token 的激活索引，按问题类型加载，不替代原书全文。
- **GPU 八维横切**：15 个思想武器都显式落到 `references/gpu-friendly-math.md` 的正式八维：张量化 / GEMM 可映射 / 复杂度 / 显存与 KV-Cache / 低精度稳定 / 并行与通信 / 稀疏结构 / 算子融合。
- **单一研究路径**：面向科研、算法、算子和训练/推理 Infra；不再保留生活建议模式。
- **渐进式披露**：常驻层（activator + description）→ 方法论层（按需）→ 书籍层（按需），避免无关上下文常驻。

---

## 十六思想武器 / Sixteen Thinking Weapons

| # | 思想武器 | 核心要义 | 算法 / GPU 应用 |
|---|---------|---------|----------------|
| 0 | 🧭 [数学研究激活器](skills/math-research-activator/SKILL.md) | 自动触发入口：诊断→映射→路由→GPU 筛选，双验收门把关 | 工作区出现 kernel / 模型代码时主动介入 |
| 1 | 📐 [公理化思想](skills/axiomatization/SKILL.md) | 从最少假设出发，严格逻辑构建 | 审查算法假设、为结构定公理与不变量 |
| 2 | 🧩 [抽象化思想](skills/abstraction/SKILL.md) | 抓住本质，忽略非本质细节 | 提炼可迁移结构、发现跨域共性 |
| 3 | 🧠 [逻辑演绎](skills/logic-deduction/SKILL.md) | 从真命题严格推理新真命题 | 形式验证算法正确性、循环不变量 |
| 4 | 🌉 [建模思想](skills/modeling/SKILL.md) | 现实问题→数学问题→解释现实 | 构建可计算模型、参数化选择 |
| 5 | ⚖️ [优化思想](skills/optimization/SKILL.md) | 约束条件下寻找最优解 | 优化器选择、二阶法 GPU 可行性、对偶 |
| 6 | 🎲 [概率与统计](skills/probability-statistics/SKILL.md) | 量化不确定性，数据提取规律 | 随机算法、采样、量化、训练动力学 |
| 7 | 🔄 [变换思想](skills/transformation/SKILL.md) | 复杂问题→等价简单问题 | 卷积→GEMM、谱变换、KV 频域压缩 |
| 8 | ⚛️ [对称与不变性](skills/symmetry-invariance/SKILL.md) | 变换下保持不变的性质 | 等变网络（SO(3)/SE(3)）、热带半环路由 |
| 9 | 📈 [归纳与类比](skills/induction-analogy/SKILL.md) | 从特殊到一般，已知到未知 | 跨域结构迁移、归纳偏置设计 |
| 10 | 🖥️ [算法与计算思想](skills/algorithmic-thinking/SKILL.md) | 化为有限步骤，评估代价与可行性 | 复杂度（亚二次）、并行、算子融合 |
| 11 | 📡 [信息论思想](skills/information-theory/SKILL.md) | 信息是不确定性的减少 | 压缩、剪枝、量化、KV 压缩、路由 |
| 12 | 🎯 [博弈论思想](skills/game-theory/SKILL.md) | 最优策略取决于他人的选择 | 多智能体、对抗训练、路由博弈 |
| 13 | 🔗 [因果推断思想](skills/causal-inference/SKILL.md) | 相关≠因果，但因果可形式化 | 可解释性、分布外泛化、DGP 建模 |
| 14 | 🌀 [拓扑思想](skills/topological-thinking/SKILL.md) | 连续变形下不变的性质 | Čech 上同调正则、sheaf 注意力、TDA |
| 15 | 🧮 [离散与组合思想](skills/discrete-combinatorial/SKILL.md) | 计数、枚举、有限对象的规律 | 稀疏结构、路由、有限域 / 半环算法 |

---

## 快速开始 / Quick Start

### 安装 / Installation

直接粘贴下面这段给 Claude Code 或其他终端型 AI 助手即可：

```
请帮我安装 math-skill：https://github.com/the-thinker0/math-skill，并教我如何使用
```

手动安装备选（下载源码，不等于自动注册 skill）：

```bash
git clone https://github.com/the-thinker0/math-skill.git
```

Claude Code / Codex 类平台：按平台的 skills / commands 目录规则复制或软链 `skills/`、`commands/`，并把 `references/` 保持在同一仓库层级。不要只复制单个 `SKILL.md`，否则 `../../references/*` 无法解析。

Cursor / 其他 Markdown 规则平台：把 `commands/*.md` 作为手动入口，把 `skills/*/SKILL.md` 作为规则/技能正文，并保留 `references/`。如果平台没有自动 skill 触发机制，就用 `/ask` 或对应命令手动触发。

也可先检查 npm 包内容：

```bash
npm pack math-skill --dry-run
```

### 使用 / Usage

**自动触发**：当工作区出现模型 / 算法代码（`model.py`、attention / transformer / MoE、`*.cu` / kernel、Triton）或对话涉及算子 / 复杂度 / 显存 / KV-Cache / 并行策略时，`math-research-activator` 会主动介入，走「诊断→映射→GPU 筛选」。

**手动触发**（不确定该用哪个武器时先 `/ask`）：

```
/ask <你的问题>                     # 激活器：诊断+映射+路由+GPU 筛选
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
/optimization Is K-FAC feasible on H100 with this batch size? in English
```

---

## 使用场景示例 / Usage Examples

### 自动触发（研究 / 算法 / GPU）

工作区有 kernel 或注意力实现时，激活器会主动给出：问题诊断、可迁移的现代数学结构候选、武器路由、八维 GPU 筛选。范例见 `skills/math-research-activator/SKILL.md` 的 **Tropical Sheaf Attention**：它是候选探索模板，不是预设成立的 benchmark 结论；必须经复杂度、显存、低精度稳定性和 kernel 可融合性验证后才能采用。

### 手动触发（研究场景）

**审查算法的理论假设**：
```
/axiomatization 这个注意力变体声称保持排列不变，但它的位置编码引入了隐含的全序假设，是否自洽？
```

**检查证明 / 不变量**：
```
/logic-deduction 这个收敛性证明从第 5 行到第 6 行的推导是否有跳跃？循环不变量成立吗？
```

**优化器 / 二阶法可行性**：
```
/optimization 想用 K-FAC 替换 Adam，但显存吃紧，这个二阶法在 GPU 上可行吗？有可改造的低秩近似吗？
```

**变换换表示**：
```
/transformation 这个自定义卷积算子能否等价改写成 GEMM 吃满 Tensor Core？逆变换数值稳定吗？
```

**等变 / 对称**：
```
/symmetry-invariance 设计一个 SO(3) 等变的特征提取层，群作用能张量化落到 GEMM 吗？
```

---

## 三层渐进式披露 / Progressive Disclosure

| 层 | 内容 | 加载时机 |
|----|------|---------|
| 常驻触发层 | `skills/math-research-activator/SKILL.md` + 各武器简短 `description` | 自动 / 手动触发即载 |
| 方法论层 | `references/agentic-workflow.md`（Human-in-the-Agent-Loop）、`references/gpu-friendly-math.md`（八维门） | 激活器按需引用 |
| 书籍激活层 | `references/books/*.md` × 7（现代数学结构蒸馏稿） | 按问题类型按需加载 |

**深挖回查**：蒸馏稿自足可用；需原文全保真且本机有 `math_book/<PDF>` 时，让 Agent 自动 `pdftotext` + grep + Read 命中页（不依赖预埋锚点）。PDF 绝不打包进 npm / git（版权 + 110MB）。

---

## 目录结构 / Directory Structure

```
math-skill/
├── package.json             # v2.0.0，files[] 含 references/
├── .gitignore / .npmignore  # 排除 math_book/ PDF
├── commands/                # 手动 slash 命令入口（15 武器 + ask）
├── skills/                  # 16 思想武器（15 武器 + math-research-activator）
│   ├── math-research-activator/   # 自动触发入口
│   └── <weapon>/{SKILL.md, original-texts.md}
├── references/              # v2 新增：方法论 + 书籍激活层
│   ├── agentic-workflow.md        # 协作方式
│   ├── gpu-friendly-math.md       # 八维 GPU 验收门
│   └── books/                     # 7 本现代数学蒸馏稿
├── agents/math-critic.md    # 审视 Agent（18 维，含 GPU + 现代数学激活）
├── knowledge-base/overview.md
├── docs/{CLAUDE.md, inspiration.md}
├── tests/{validate.sh, validate.ps1}
├── math_book/               # 本地 PDF（git/npm 忽略，不发布）
└── README.md / LICENSE
```

---

## 每个思想武器包含什么 / What Each Skill Contains

每个 `skills/*/SKILL.md`（v2 单一研究 / 算法路径）：

1. **核心原则** + blockquote 子节 **数学形式化**（定义 / 定理 / 公式）
2. **GPU 友好性（横切检查）**——本武器结构如何映射 GPU，过八维门
3. **不适用场景** / **何时使用**（研究触发，含算法 / 算子设计用法）
4. **方法流程**——单一科研路径（保留全部数学）
5. **常见错误**——含一行 GPU 可算性
6. **操作规程**——单一输出格式，末尾 `[GPU 可行性]` 项
7. **与其他 skill 的关系**——含「现代数学激活」行，指向 `references/books/*`

每个武器还配 `original-texts.md`（数学出处与经典文献）。审视产出可交 `agents/math-critic.md`（18 维，含 GPU 可行性 + 现代数学激活）二次把关。

---

## 数学知识体系 / Mathematical Knowledge System

`knowledge-base/overview.md` 提供数学知识地图：三大支柱（代数 / 几何 / 分析）、主要分支、知识层次（地基→代数→综合→前沿）、思维武器与数学分支映射。

---

## 灵感来源 / Inspiration

Sophus Lie 打造"屠龙刀"的故事告诉我们：为解微分方程发明的李群-李代数，最终成为描述对称性、机器人状态估计的通用语言——数学工具的价值远超初衷，这正是「跨领域激活」的原型。详见 [`docs/inspiration.md`](docs/inspiration.md)。

---

## 许可证 / License

MIT License. 详见 `LICENSE`。
