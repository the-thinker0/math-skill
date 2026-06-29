# Math Skill 使用指南 / User Guide (v2)

## 简介 / Introduction

Math Skill v2 是一个**自动触发的现代数学能力激活器**：当工作区出现算法 / 模型 / GPU kernel 代码时主动介入，把代数几何、微分几何、李理论、范畴论、矩阵分析、最优化等**现代数学**激活进算法与 GPU 协同设计，并强制每个产出通过**双验收门**（数学正确 × GPU 可行）。

包含**十六种数学思想武器**（十五种专业武器 + 一个 `math-research-activator` 自动触发入口）。每个武器为单一研究 / 算法路径（v1 的「生活模式」已整体移除），配方法论、数学形式化、GPU 友好性横切与数学出处。

## 安装 / Installation

直接粘贴下面这段给 Claude Code 或其他终端型 AI 助手即可：

```
请帮我安装 math-skill：https://github.com/the-thinker0/math-skill，并教我如何使用
```

也可指定安装方式（npm / git clone / 本地路径）。

## 使用方法 / Usage

### 自动触发 / Auto-Trigger

`math-research-activator` 是本技能包的**唯一自动入口**。当工作区出现以下信号时主动介入：

- 模型 / 算法代码：`model.py`、`config.json`、attention / transformer / MoE、`*.cu` / `*.cuh` / kernel、Triton / CUDA。
- 对话涉及：注意力变体、稀疏 / 线性注意力、KV-Cache、路由、算子 / 复杂度 / 显存、训练动力学、并行策略、芯片协同。

介入后走主流程：**诊断 → 现代数学结构映射 → 思想武器路由 → GPU 可行性筛选 → 双验收门**。常驻只保留最短的触发与诊断逻辑，方法论层与书籍层按需加载（渐进式披露，省 token）。

### 手动触发命令 / Manual Commands

仍兼容 v1 的手动命令习惯，**不会在每次对话开始时自动加载**。不确定该用哪个武器时先 `/ask`：

| 命令 | 思想武器 | 适用场景 |
|------|---------|---------|
| `/ask` | 🧭 数学研究激活器 | 不确定该用哪个武器 / 要把现代数学激活进算法时，诊断+映射+路由+GPU 筛选 |
| `/axiomatization` | 📐 公理化思想 | 审查算法假设、为结构定公理与不变量 |
| `/abstraction` | 🧩 抽象化思想 | 提炼可迁移结构、发现跨域共性 |
| `/logic-deduction` | 🧠 逻辑演绎 | 形式验证算法正确性、循环不变量 |
| `/modeling` | 🌉 建模思想 | 构建可计算模型、参数化选择 |
| `/optimization` | ⚖️ 优化思想 | 优化器选择、二阶法 GPU 可行性、对偶 |
| `/probability-statistics` | 🎲 概率与统计 | 随机算法、采样、量化、训练动力学 |
| `/transformation` | 🔄 变换思想 | 卷积→GEMM、谱变换、KV 频域压缩 |
| `/symmetry-invariance` | ⚛️ 对称与不变性 | 等变网络（SO(3)/SE(3)）、热带半环路由 |
| `/induction-analogy` | 📈 归纳与类比 | 跨域结构迁移、归纳偏置设计 |
| `/algorithmic-thinking` | 🖥️ 算法与计算思想 | 复杂度（亚二次）、并行、算子融合 |
| `/information-theory` | 📡 信息论思想 | 压缩、剪枝、量化、KV 压缩、路由 |
| `/game-theory` | 🎯 博弈论思想 | 多智能体、对抗训练、路由博弈 |
| `/causal-inference` | 🔗 因果推断思想 | 可解释性、分布外泛化、DGP 建模 |
| `/topological-thinking` | 🌀 拓扑思想 | Čech 上同调正则、sheaf 注意力、TDA |
| `/discrete-combinatorial` | 🧮 离散与组合思想 | 稀疏结构、路由、有限域 / 半环算法 |

### 使用示例 / Examples

```
# 不确定该用哪个武器 / 要激活现代数学
/ask 我想设计一个亚二次注意力，能映射到 Tensor Core GEMM，有什么现代数学结构可迁移？

# 审查算法假设
/axiomatization 这个注意力变体声称排列不变，但位置编码引入了隐含全序假设，自洽吗？

# 优化器 / 二阶法可行性
/optimization K-FAC 替换 Adam，显存吃紧，GPU 上可行吗？有低秩近似改造吗？

# 等变设计
/symmetry-invariance 设计 SO(3) 等变特征层，群作用能张量化落 GEMM 吗？

# 拓扑正则
/topological-thinking 用 Čech 上同调 H¹ 作幻觉判据，能做成局部可融合的损失吗？
```

### 语言切换 / Language Switching

**默认输出中文。** 如需英文，在命令后追加 "in English"：

```
/optimization Is K-FAC feasible on H100 with this batch size? in English
```

### 组合使用 / Combining Skills

多个武器可串联：先 `/ask` 做诊断 + 路由，再按推荐顺序逐个调用。激活器会推荐 1–3 个武器（标主 / 辅）+ 触发顺序。

## 三层渐进式披露 / Progressive Disclosure

| 层 | 内容 | 加载时机 |
|----|------|---------|
| 常驻触发层 | `skills/math-research-activator/SKILL.md` + 各武器 `description` | 自动 / 手动触发即载 |
| 方法论层 | `references/agentic-workflow.md`、`references/gpu-friendly-math.md` | 激活器按需引用 |
| 书籍激活层 | `references/books/*.md` × 7 | 按问题类型按需加载 |

`references/gpu-friendly-math.md` 是 GPU 可行性验收门的**唯一真理来源**（八维：张量化 / GEMM 可映射 / 复杂度亚二次 / 显存与 KV-Cache / 低精度稳定 / 并行与通信 / 稀疏结构 / 算子融合）。

### 数学形式化格式 / Mathematical Formalization Format

每个常规 `SKILL.md` 的「数学形式化」不是独立 `##` 标题，而是「核心原则」节内的 blockquote 子节：

```
> **数学形式化 / Mathematical Formalization**
```

这是预期格式，用于把定义 / 定理 / 公式紧贴核心原则，减少节级噪声。`math-research-activator` 是路由入口，不要求包含此子节。

**深挖回查**：蒸馏稿自足可用；需原文全保真且本机有 `math_book/<PDF>` 时，Agent 自动 `pdftotext` + grep + Read 命中页。PDF 绝不打包进 npm / git。

## 十六思想武器速查 / Quick Reference

### 🧭 数学研究激活器
自动触发入口。诊断算法结构 / 瓶颈 → 扫描可迁移的现代数学结构（枚举多候选）→ 路由 1–3 个思想武器 → 每个候选过八维 GPU 门 → 只保留数学正确 AND GPU 友好 / 可改造的候选。

### 📐 公理化思想
从最少假设出发，严格逻辑构建。审查算法假设合理性、为结构定公理与不变量。

### 🧩 抽象化思想
抓住本质特征，忽略非本质。提炼可迁移的数学结构、发现跨域共性（范畴 / 代数 / 拓扑视角）。

### 🧠 逻辑演绎
从真命题严格推理新真命题。形式验证算法正确性、循环不变量、程序性质。

### 🌉 建模思想
现实问题 → 模型 → 解释现实。构建可计算模型、参数化与验证。

### ⚖️ 优化思想
约束下寻找最优解。凸性分析、KKT、对偶、二阶法 GPU 可行性。

### 🎲 概率与统计
量化不确定性，从数据提取规律。假设检验、回归、随机算法、采样、量化。

### 🔄 变换思想
复杂问题 → 等价简单问题。Fourier / Laplace / 生成函数；卷积→GEMM、谱变换。

### ⚛️ 对称与不变性
寻找变化中的不变性质。群论、Galois、Noether；等变网络、热带半环路由。

### 📈 归纳与类比
从特殊到一般，从已知到未知。数学归纳、跨域结构迁移、归纳偏置。

### 🖥️ 算法与计算思想
化为有限步骤，评估代价与可行性。复杂度（亚二次）、可计算性、并行、算子融合。

### 📡 信息论思想
信息是不确定性的减少。熵 / 互信息 / KL；压缩、剪枝、量化、KV 压缩。

### 🎯 博弈论思想
最优策略取决于他人的选择。Nash 均衡、minimax、机制设计、多智能体。

### 🔗 因果推断思想
相关≠因果，但因果可形式化。DAG、do-演算、反事实、可解释性 / 分布外泛化。

### 🌀 拓扑思想
连续变形下不变的性质。持续同调、TDA、Čech 上同调正则、sheaf 注意力。

### 🧮 离散与组合思想
计数、枚举、有限对象的规律。生成函数、图论、有限域 / 半环算法。

## 知识体系 / Knowledge Base

`knowledge-base/overview.md` 提供数学知识体系概述：三大基础支柱（代数 / 几何 / 分析）、主要分支、知识层次（地基→代数→综合→前沿）、思维武器与数学分支映射（含激活器）。

## 数学审视 / Math Critic

`agents/math-critic.md` 定义兼具审查与实现能力的子 Agent。**审视维度共 18 个**：15 个武器对应维 + 工具选择 / 流程审视（↔ math-research-activator）+ **GPU 可行性审视**（↔ gpu-friendly-math 八维）+ **现代数学激活审视**（↔ references/books/*）。涉算法 / GPU 设计时，后两维为强制项。不机械遍历——根据问题性质选最相关 3–5 维深入。不确定该审视哪些维度时先 `/ask`。

## 验证 / Validation

```bash
# Linux/macOS
bash tests/validate.sh

# Windows PowerShell
.\tests\validate.ps1
```

校验项含：16 武器 frontmatter、生活模式残留清零、references 层完整、activator 路由、math-critic 双新维度、npm pack 含 references/ 且不含 PDF / math_book/。

## License

MIT License. See `LICENSE` for details.
