---
name: causal-inference
description: |
  触发：相关≠因果、干预/反事实推理、do-演算、因果图(DAG)建模、混淆变量识别、政策/处理效应评估；或为模型可解释性、分布外泛化、数据生成过程(DGP)建模而需显式因果假设时调用。
  English: Trigger when a problem concerns correlation≠causation, intervention/counterfactual reasoning, do-calculus, causal DAG modeling, confounder identification, policy/treatment effect estimation; or needs explicit causal assumptions for model interpretability, out-of-distribution generalization, or data-generating process modeling.
---

> **语言路由**：若用户消息为英文，请读取并遵循同目录下的 `SKILL.en.md`，按其操作规程以英文输出；中文消息则继续使用本文件。

# 🔗 因果推断思想 / Causal Inference

> "相关不等于因果——但因果可以理清。关键区别：'看到X时Y如何'≠'如果做了X会怎样'"
> "Correlation is not causation — but causation can be sorted out. Key distinction: 'how is Y when we see X' ≠ 'what if we did X'"
>
> —— 因果推断、结构因果模型、反事实推理
> —— Causal Inference, Structural Causal Models, Counterfactual Reasoning

## 核心原则 / Core Principle

**因果推断回答的问题超出概率论的表达能力：概率论能回答"看到 X 时 Y 如何"，但不能回答"如果做了 X 会怎样"。Pearl 因果层级将推理分为三层，每层需要更强的建模假设。**

**Causal inference answers questions beyond probability's expressive power: probability answers "how is Y when we see X," not "what if we did X." Pearl's causal hierarchy has three levels, each requiring stronger modeling assumptions.**

> **数学形式化 / Mathematical Formalization**
>
> Pearl 因果层级 / Causal Hierarchy：
> - **Level 1 关联 / Association**：P(y|x) —— 看到/观察 / Seeing
> - **Level 2 干预 / Intervention**：P(y|do(x)) —— 做/干预 / Doing
> - **Level 3 反事实 / Counterfactual**：P(y_x|x',y') —— 想/回顾 / Imagining
>
> **do(x) ≠ 条件化 x**：do(x) 切断所有指向 X 的箭头（图手术），条件化 x 不切断任何箭头。后门调整 / back-door adjustment：P(y|do(x)) = Σ_z P(y|x,z)P(z)
>
> **潜在结果 / Potential Outcomes (Neyman-Rubin)**：Y(x) 为"若施干预 X=x 时 Y 的取值"；个体效应 τ_i = Y_i(1)-Y_i(0)，平均处理效应 ATE = E[Y(1)]-E[Y(0)] = E[Y|do(X=1)] - E[Y|do(X=0)]。
>
> **结构因果模型 / SCM**：Y := f(X, Z, U)，U 为外生变量；DAG + 结构方程共同确定反事实 Y_x = f(x, Z, U)。
>
> **d-分离 / d-Separation**：路径被 Z 阻断 ⟺ 链/叉中点 ∈ Z，或 collider X→C←Y 且 C 及其后代 ∉ Z。d-分离 X⊥_G Y|Z 蕴含条件独立，是图上读出因果假设的工具。
>
> **do-演算三规则 / Do-calculus**（在修正图上用 d-分离判断）：
> - 规则 1（插入/删除观察）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头后的图中成立，则 P(y|do(x),z) = P(y|do(x))
> - 规则 2（干预与观察互换）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头并删去所有从 Z 出发的箭头后的图中成立，则 P(y|do(x),do(z)) = P(y|do(x),z)
> - 规则 3（插入/删除干预）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头并删去所有从 Z 到 X 的路径上的箭头后的图中成立，则 P(y|do(x),do(z)) = P(y|do(x))
>
> **因果推理需显式因果模型，不能仅靠数据推导。DAG 编码因果假设，do-演算将干预表达式转化为可观测量。**
>
> 详细数学依据见 `original-texts.md`

## GPU 友好性 / GPU-Friendliness（横切检查）

当因果推断用于**模型可解释性 / 分布外泛化 / 数据生成过程建模**并需大规模估计时，方法本身要过 `../../references/gpu-friendly-math.md` 八维门：

- **效应估计 / 调整回归**：后门调整、IPW、双重机器学习的条件期望/regression 全是批量 GEMM，张量化、可融合、低精度可行——**友好**（见 `../../references/books/optimization-ml.md`）。
- **条件独立检验**：高维条件独立检验含精度阵（协方差逆）求逆 $O(p^3)$，可改 **低秩/对角近似**或迭代求解器——**可改造**（见 `../../references/books/matrix-analysis.md`）。
- **精确因果发现（DAG 搜索）**：DAG 空间随节点数超指数增长，精确打分搜索 NP-hard、不可微、串行——典型"美但不可算"反模式。
- **改造手法**：NOTEARS 式**连续松弛**（无环性 $h(W)=\text{tr}(e^{W\circ W})-p=0$）把离散图搜索变成可微优化；或 MCMC/贪心+打分作启发式近似。
- **反事实/SCM 仿真**：结构方程前向模拟可批量并行；但个体反事实依赖外生 U 的识别，警惕串行依赖。

八维最低判定（正式术语）：**张量化**看样本/干预/候选图能否批量处理；**GEMM 可映射**看调整回归与表示学习是否落矩阵乘；**复杂度**看因果发现是否避开超指数 DAG 搜索；**显存与 KV-Cache**看精度阵、候选图和中间反事实是否可压缩；**低精度稳定**看 IPW 权重、协方差逆和 logit 是否稳健；**并行与通信**看多环境/多干预估计能否并行；**稀疏结构**看 DAG/SCM 是否结构化稀疏；**算子融合**看打分、mask、loss 能否融合。

> 配合 `../../references/books/optimization-ml.md`（干预估计/regression）与 `../../references/books/matrix-analysis.md`（条件独立/低秩精度阵）。

## 不适用场景 / When NOT to Use

- **纯预测任务且无因果问题**（只需 P(y|x)，不关心"为什么"）——关联足够，因果多余。
- **无可编码的因果假设**（画不出合理 DAG，因果方向不确定）——没有显式假设就没有因果结论。
- **确定性系统且无变异**（输入严格唯一映射输出）——因果已被机制完全描述，无需概率因果框架。

## 何时使用 / When to Use

- 需要知道干预的效果（"做了 X，Y 会怎样？"）——需 P(y|do(x)) 而非 P(y|x)。
- 需要区分原因与混淆变量（X 导致 Y，还是 Z 同时导致 X 和 Y？）——DAG 识别混淆路径。
- 需要反事实推理（"若当时没做 A 结果会怎样？"）——Level 3 需结构方程。
- 需要政策/处理效应评估（RCT 不可行时的后门调整、IV、双重差分）。
- 需要中介分析（拆分 X→M→Y 的直接与间接效应）。
- 需要为**模型可解释性 / 分布外泛化**建模数据生成过程（DGP），把预测器的关联变成可干预的因果机制。

## 方法流程 / Method

### 第一步：构建因果 DAG / Construct the Causal DAG
明确所有变量，画因果箭头编码直接原因假设，检查无环性。识别原因变量 X（干预对象）、结果 Y（效应）、混淆 Z（X、Y 共同原因）、中介 M（X→M→Y）。箭头 X→Y 表示"X 是 Y 的直接原因"，方向编码因果假设。DAG 必须有向无环——存在环路则因果方向不确定，需重新建模。**关键**：是否有足够领域知识编码因果方向？结论完全依赖 DAG 正确性。

### 第二步：识别混淆变量 / Identify Confounders
混淆变量同时影响 X 和 Y，创造虚假关联——不调整则效应估计有偏。**定义**：Z 是混淆 ⟺ Z 是 X、Y 的共同原因（Z→X 且 Z→Y）。**DAG 识别法**：找 X、Y 的所有共同祖先。**后门路径** X←Z→Y 创造非因果关联需阻断。**关键**：所有混淆是否可观测？存在未观测混淆则后门调整不可用，需前门准则或工具变量。

### 第三步：选择识别策略 / Choose Identification Strategy
据混淆可观测性，选择从观测数据计算 P(y|do(x)) 的策略：
- **后门准则 / Back-door**：若 ∃ S 阻断 X→Y 所有后门路径且 S 不含 X 的后代，则 P(y|do(x)) = Σ_s P(y|x,S=s)·P(S=s)。
- **前门准则 / Front-door**：混淆不可观测但中介 M 可观测，且 X→M 无后门、M 阻断 X→Y 所有后门路径，则 P(y|do(x)) = Σ_m P(m|x)·Σ_z P(y|m,z)P(z)。
- **do-演算**：三规则在可观测量间转换 do-表达式（见核心原则数学形式化块）。

### 第四步：计算干预效果 / Compute Intervention Effects
用调整公式算 P(y|do(x))，与观察性 P(y|x) 对比衡量混淆偏差：
- 后门调整：P(y|do(x)) = Σ_z P(y|x,z)·P(z)——对 Z 所有取值加权平均。
- 混淆偏差：|P(y|do(x)) - P(y|x)|——偏差越大混淆越严重。
- 平均处理效应：ATE = E[Y|do(X=1)] - E[Y|do(X=0)] = E[Y(1)] - E[Y(0)]。
**关键**：P(y|do(x)) 与 P(y|x) 是否显著不同？不同则观察性分析有混淆偏差。

### 第五步：反事实分析 / Counterfactual Analysis
个体层面回顾性推理：若 X 是 x₁ 而非 x₀，Y 会怎样？
- **SCM**：Y = f(X, Z, U)，U 为外生变量。
- **反事实计算**：给定观测 (x₀,y₀,z₀)，反事实 Y_{x₁} = f(x₁, z₀, u₀)。
- **个体因果效应**：Y_{x₁} - Y_{x₀}——需结构方程。
**关键**：反事实依赖结构方程具体形式，对模型假设极敏感。

### 第六步：实验设计验证 / Experimental Design
- **RCT（黄金标准）**：随机化切断所有指向 X 的箭头，处理组与对照组在所有变量上期望相等；ATE = E[Y|do(X=1)] - E[Y|do(X=0)]。
- **自然实验**：利用自然发生的准随机事件（地震、政策变更）。
- **工具变量 IV**：V→X 且 V 到 Y 无直接路径、V 与 Y 无共同原因——用 V 创造的 X 变异估计因果效应。
- **双重差分 DD**：(Y₁^后-Y₁^前) - (Y₀^后-Y₀^前)。

### 第七步：敏感性分析 / Sensitivity Analysis
量化结论对未观测混淆的脆弱性：
- **Rosenbaum Γ**：对混淆强度 Γ，算结论可能翻转的最大 p-value——Γ 越大越脆弱。
- **E-value**：使效应估计归零所需的最小混淆强度——越大越稳健。
**关键**：未观测混淆 U 必须多强才能推翻结论？

## 常见错误 / Common Errors

| 错误 / Error | 批评 / Critique | 正确做法 / Correct Approach |
|---|---|---|
| 从相关直接推断因果 | P(y\|x)≠P(y\|do(x))；相关可能由混淆创造 | 画 DAG 识别混淆，用后门调整算 P(y\|do(x)) |
| 忽略混淆变量 | 不调整时 \|P(y\|do(x))-P(y\|x)\|=混淆偏差 | 找 X、Y 所有共同祖先，调整可观测混淆 |
| 混淆 do(x) 与条件化 P(y\|x) | do(x) 切断指向 X 的箭头，条件化不切断 | 明确区分干预（强制设定）与观察（看到时） |
| 忽略中介效应 | X→M→Y 总效应=直接+间接 | 中介分析拆分直接/间接效应，前门准则可用 |
| 过度依赖单一 DAG | DAG 错则结论全错，不同 DAG 可能给相反结论 | 检验 DAG 合理性，比较多个备选 DAG |
| 忽略敏感性分析 | 未观测混淆可能推翻结论 | 用 Rosenbaum Γ 或 E-value 量化脆弱性 |
| 精确因果图搜索不可算 | DAG 空间超指数、NP-hard、不可微 | 连续松弛（NOTEARS）/启发式近似，过 GPU 八维门 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，输出必须包含：

1. **[DAG]**：所有变量的有向无环图，标注每条箭头的假设依据。
2. **[混淆变量]**：列出 X、Y 的所有共同祖先，标注可观测/不可观测。
3. **[识别策略]**：后门/前门/do-演算，说明选择理由。
4. **[干预效果]**：P(y|do(x))=[值]，用调整公式计算并与 P(y|x) 对比。
5. **[反事实]**：对关键个体/子群反事实推理，说明所需结构方程。
6. **[验证方法]**：RCT/自然实验/IV/DD，如何验证因果结论。
7. **[敏感性]**：Rosenbaum Γ 或 E-value，量化对未观测混淆的脆弱性。
8. **[GPU 可行性]**（若用于可解释性/OOD/DGP 建模的大规模估计）：因果发现/估计方法过八维门，标注友好/可改造/不友好 + 改造建议。

**输出不得只给分析而无结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **概率与统计**：统计是因果的基础但不充分——P(y|x) 是关联，P(y|do(x)) 是因果效应；因果需额外假设。
- **建模思想**：因果 DAG 是结构模型——编码变量间因果机制假设，是建模的因果版本。
- **逻辑演绎**：从 DAG 假设出发，通过 do-演算三规则演绎因果结论。
- **信息论思想**：混淆变量制造虚假信号，因果推断从噪声中提取真实因果信号。
- **博弈思想**：策略互动中参与者的选择构成因果干预，均衡分析需因果推理。
- **现代数学激活**：`../../references/books/optimization-ml.md`（干预估计/regression、双重 ML）、`../../references/books/matrix-analysis.md`（条件独立检验、精度阵低秩近似）。
