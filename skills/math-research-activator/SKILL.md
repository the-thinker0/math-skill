---
name: math-research-activator
description: |
  自动触发：当用户在设计/分析模型结构、注意力机制、GPU kernel/算子、训练或推理 Infra，或需要把现代数学（代数几何、微分几何、李理论、抽象代数、矩阵分析、最优化）激活进算法/硬件协同设计时使用。当工作区出现 ML/模型代码、CUDA/kernel、或算法研究笔记且存在结构、复杂度、显存、数值、并行或数学建模判断时主动介入。职责：问题诊断 → 现代数学结构映射 → 思想武器路由 → GPU 可行性筛选，强制每个产出同时满足「math beautiful × GPU friendly」。也作为手动 /ask 入口（武器选择器）。
  English: Auto-trigger when designing/analyzing model architectures, attention mechanisms, GPU kernels/operators, training/inference infra, or activating modern mathematics (algebraic geometry, differential geometry, Lie theory, abstract algebra, matrix analysis, optimization) for algorithm/hardware co-design. Proactively engages when the workspace contains ML/model code, CUDA/kernels, or algorithm research notes and the task involves structure, complexity, memory, numerics, parallelism, or mathematical modeling judgment. It diagnoses the problem, maps modern-math structures, routes to thinking weapons, and screens GPU feasibility — every output must be both beautiful in math and friendly to GPUs. Also the manual /ask entry (weapon selector).
---

# 🧭 数学研究激活器 / Math Research Activator

> "模型内部已有足够的数学知识，缺的只是一次跨领域的激活。人选方向，Agent 搜索、枚举、验证。"
> "The model already holds enough mathematics inside; what's missing is a cross-domain activation. The human picks the direction; the agent searches, enumerates, verifies."

## 核心原则 / Core Principle

**不做大段数学科普。** 一旦触发，立即进入「诊断 → 映射 → GPU 筛选」三步，把现代数学激活进算法/硬件设计，并让每个产出过**双验收门**：

1. **数学正确（beautiful in math）**——自洽、可微（或可松弛为可微）、有正确性保证。
2. **GPU 可行（friendly to GPU）**——见 `../../references/gpu-friendly-math.md` 八维。

> 这是本技能包的**唯一自动入口**。它按需加载方法论层（`../../references/agentic-workflow.md`、`../../references/gpu-friendly-math.md`）、书籍激活层（`../../references/books/*.md`）和 16 个思想武器（同级目录 `../*/SKILL.md`），常驻只保留最短的触发与诊断逻辑——渐进式披露，省 token。

## 何时自动介入 / When to Auto-Engage

**环境信号（任一命中即考虑介入）：**
- 工作区含模型/算法代码：`model.py`、`config.json`、attention/transformer/MoE 实现、`*.cu`/`*.cuh`/kernel、Triton/CUDA。
- 对话涉及：注意力变体、稀疏/线性注意力、KV-Cache、路由、算子/复杂度/显存、训练动力学、并行策略、芯片/微架构协同。
- 研究笔记/论文审查涉及把数学结构用于算法。

**不介入 / When NOT to use：**
- 纯事实查询、与算法无关的通用编码、纯工程实现且无数学决策。
- 问题不属于数学能帮助的范畴。

## 主流程 / The Activation Loop

> 详细工作方式见 `../../references/agentic-workflow.md`（Human-in-the-Agent-Loop）。

1. **诊断 / Diagnose**：算法结构或瓶颈是什么？（复杂度？显存/KV？数值？并行？表达力？）
2. **映射 / Map**：用「现代数学工具箱」（下）扫描可迁移的结构，**枚举多个候选**（发挥大上下文优势，别只给一个）。
3. **路由 / Route**：选 1–3 个思想武器深入（决策树见下）。
4. **GPU 筛选 / Screen**：每个候选过 `../../references/gpu-friendly-math.md` 八维，给「友好/可改造/不友好」+ 改造建议。
5. **双验收门 / Gate**：只保留**数学正确 AND（八维友好或可改造）**的候选。
6. **追踪 / Track**：复杂探索用 markdown testplan 表（模板见 agentic-workflow.md）迭代收敛。

八维正式术语必须保持一致：**张量化 / GEMM 可映射 / 复杂度 / 显存与 KV-Cache / 低精度稳定 / 并行与通信 / 稀疏结构 / 算子融合**。不要用只覆盖部分维度的模糊判断替代八维门。

## 思想武器路由决策树 / Weapon Routing

按问题核心特征匹配（最多选 3 个，标主/辅）：

1. **多方互动**（我的最优取决于他人）→ `/game-theory`（主）；涉资源分配＋`/optimization`；信息不对称＋`/information-theory`
2. **不确定性/随机性** → `/probability-statistics`（主）；需因果而非相关＋`/causal-inference`
3. **约束下求最优** → `/optimization`（主）；需先建模＋`/modeling`（前置）
4. **当前形式难处理，需换视角/化简** → `/transformation`（主）
5. **需提取本质结构** → `/abstraction`（主）；验证假设＋`/axiomatization`；简化＋`/symmetry-invariance`
6. **需严格推理验证** → `/logic-deduction`（主）；验证前提＋`/axiomatization`
7. **从数据/经验找规律** → `/induction-analogy`（主）；跨域迁移＋`/abstraction`
8. **构建预测/解释模型** → `/modeling`（主）；优化＋`/optimization`；不确定＋`/probability-statistics`
9. **变化中的不变性/守恒/等变** → `/symmetry-invariance`（主）；连通结构＋`/topological-thinking`
10. **化为可执行步骤/评估可行性与复杂度** → `/algorithmic-thinking`（主）
11. **压缩/编码/信息瓶颈/KV-Cache 压缩/量化** → `/information-theory`（主）；涉及表示变换＋`/transformation`；涉及路由信息增益＋`/game-theory`
12. **有限对象的计数/枚举/结构** → `/discrete-combinatorial`（主）

> **现代数学优先提示**：当问题是「设计/改进算子或结构」时，路由武器的同时**务必先开现代数学工具箱**——很多突破来自把代数几何/微分几何/李理论的结构迁移过来，而非只在经典工具里打转。

## 现代数学工具箱（Layer 3 · 按需加载）/ Modern-Math Toolbox

按问题类型加载对应书籍激活文件（`../../references/books/`）：

| 触发信号 | 加载 | 典型激活 |
|---------|------|---------|
| 算子=矩阵乘/谱/低秩/数值稳定 | `matrix-analysis.md` | GEMM 化、低秩压缩、谱归一化、预条件 |
| 训练/收敛/优化器/约束 | `optimization-ml.md` | 自适应/二阶优化的可行性、对偶求解 |
| 对称/等变/半环/置换不变 | `abstract-algebra.md` | 群等变层、热带半环路由、有限域编码 |
| 流形约束/隐空间几何/可微结构 | `smooth-manifolds.md` | 流形优化、Stiefel/正交约束、测地插值 |
| 度量/曲率/自然梯度/规范/纤维丛 | `differential-geometry.md` | 自然梯度/K-FAC、信息几何、gauge 等变 |
| 位姿/SO(3)/SE(3)/状态估计/等变 | `micro-lie-theory.md` | 李群优化、SE(3) 等变、流形损失 |
| 注意力/稀疏/全局一致性/KV 压缩 | `algebraic-geometry-rising-sea.md` | sheaf 注意力、Čech 上同调正则、Plücker KV、热带门控 |

## 深挖回查协议 / Deep-Dive Protocol

- **轻度**：读 `../../references/books/<book>.md`（蒸馏稿，发布即带，自足）。
- **深度（需原文全保真）**：若本机存在 `math_book/<对应 PDF>`，**让 Agent 自动搜索**——`pdftotext "math_book/<file>.pdf" -` → grep 关键词 → Read 命中页。**不依赖预埋锚点。**
- 无 PDF（如 npm 安装的他机）：停在蒸馏稿层，依然自足可用。

## 范例：Tropical Sheaf Attention / Worked Example

一个研究候选样板（详见 `../../references/gpu-friendly-math.md`）：热带门控（半环分段线性替代 Top-K）＋胞腔层扩散（每边低秩限制映射＝小 GEMM）＋Čech 上同调正则（H¹ 作结构一致性信号）＋Plücker KV 压缩。把它当作「math beautiful × GPU friendly」的探索模板：逐项验证复杂度、显存、低精度稳定性与 kernel 可融合性后，才能声称通过八维门。

## 操作规程 / Operating Procedure

触发后输出必须含：
1. **[诊断]**：一句话点明算法结构/瓶颈（互动性/不确定性/约束/结构/动态/复杂度/显存/数值/并行）。
2. **[映射]**：枚举可迁移的现代数学结构候选（≥2 个，标注来自哪本书）。
3. **[武器路由]**：1–3 个思想武器，标主/辅 + 触发命令。
4. **[GPU 筛选]**：每个候选过八维，给「友好/可改造/不友好」+ 改造建议。
5. **[结论]**：保留同时通过双验收门的候选；必要时给 testplan 表。

**必须给出结论，不得只输出分析而不收敛。**

## 与其他 skill 的关系 / Relations

- 本入口路由全部 16 个思想武器，并按需加载方法论层与书籍激活层。
- 手动入口 `/ask` 等价调用本激活器（武器选择器模式）。
- 审视产出可交 `agents/math-critic.md`（含 GPU 可行性维度）做二次把关。
