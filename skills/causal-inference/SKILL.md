---
name: causal-inference
description: |
  触发：当需要区分因果与相关、评估干预效果、或回答"如果做了X会怎样"时调用。
  English: Trigger when you need to distinguish causation from correlation, evaluate intervention effects, or answer "what if we did X?"
---

# 🔗 因果推断思想

> "相关不等于因果——但因果可以形式化。"
> "Correlation is not causation — but causation can be formalized."
>
> —— 因果推断、结构因果模型、反事实推理
> —— Causal Inference, Structural Causal Models, Counterfactual Reasoning

## 核心原则 / Core Principle

**因果推断回答的问题超出了概率论的表达能力：概率论能回答"看到 X 时 Y 如何"，但不能回答"如果做了 X 会怎样"。Pearl 的因果层级（Ladder of Causation）将推理能力分为三层，每层需要更强的建模假设。**

**Causal inference answers questions beyond the expressive power of probability theory: probability can answer "how is Y when we see X," but not "what if we did X." Pearl's Ladder of Causation divides reasoning into three levels, each requiring stronger modeling assumptions.**

Pearl 因果层级 / Pearl's Causal Hierarchy：

- **Level 1 关联 / Association**：P(y|x) —— 看到/观察 / Seeing/Observing
  - 问题："观察到 X 时 Y 是什么？"——纯粹统计关联，条件概率即可回答
  - 例："购买牙膏的人更可能购买牙线"——P(牙线|牙膏) > P(牙线)

- **Level 2 干预 / Intervention**：P(y|do(x)) —— 做/干预 / Doing/Intervening
  - 问题："如果我强制设定 X，Y 会怎样？"——需要因果模型，do-演算回答
  - 例："如果提高价格，销量会怎样？"——P(销量|do(价格↑)) ≠ P(销量|价格↑)

- **Level 3 反事实 / Counterfactual**：P(y_x|x',y') —— 想/回顾 / Imagining/Retrospective
  - 问题："如果当时 X 是 x₁ 而不是 x₀，Y 会怎样？"——需要结构因果模型
  - 例："如果患者当时没服药，他是否还能康复？"——个体层面推理

**do(x) 干预不同于条件化 x**：

P(y|do(x)) = Σ_z P(y|x,z)P(z) （后门调整公式 / back-door adjustment）

- 条件化 P(y|x)：在观察到 X=x 的人群中 Y 的分布——受混淆变量影响
- 干预 P(y|do(x))：在强制设定 X=x 的人群中 Y 的分布——切断了所有指向 X 的因果箭头

**因果推理需要显式因果模型，不能仅靠数据推导。DAG 编码因果假设，do-演算将干预表达式转化为可观测量。**

> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **纯粹的预测任务且无因果问题**（只需要预测 P(y|x)，不关心"为什么"）——关联足够，因果是多余的
  **Purely predictive tasks with no causal question** (only need P(y|x), don't care "why") — association suffices, causation is superfluous

- **无可编码的因果假设**（无法画出合理的 DAG，因果方向不确定）——因果推断依赖显式假设，没有假设就没有因果结论
  **No causal assumptions available to encode** (cannot draw a reasonable DAG, causal direction uncertain) — causal inference requires explicit assumptions; without assumptions there are no causal conclusions

- **确定性系统且无变异**（每个输入严格对应唯一输出，无随机性）——因果已被确定性机制完全描述，无需概率因果框架
  **Deterministic system with no variation** (each input strictly maps to a unique output, no randomness) — causation is fully described by the deterministic mechanism, no probabilistic causal framework needed

## 何时使用 / When to Use

- 需要知道干预的效果（"如果做了 X，Y 会怎样？"）——需要 P(y|do(x)) 而非 P(y|x)
  Need to know the effect of an intervention ("what if we did X?") — need P(y|do(x)) not P(y|x)

- 需要区分原因与混淆变量（X 是 Y 的原因，还是 Z 同时导致了 X 和 Y？）——DAG 帮助识别混淆路径
  Need to distinguish cause from confounder (is X a cause of Y, or does Z cause both X and Y?) — DAG helps identify confounding paths

- 需要反事实推理（"如果当时没有做 A，结果会怎样？"）——Level 3 推理需要结构方程
  Need counterfactual reasoning ("what if A had not been done, what would the result be?") — Level 3 reasoning requires structural equations

- 需要政策评估（某政策是否真的有效？还是混淆变量制造了虚假效果？）——后门调整消除混淆偏差
  Need policy evaluation (is a policy truly effective, or is a confounder creating a spurious effect?) — back-door adjustment removes confounding bias

- 需要识别中介变量（X 通过 M 影响 Y，还是 X 直接影响 Y？）——中介分析拆分直接与间接效应
  Need to identify mediators (does X affect Y through M, or directly?) — mediation analysis decomposes direct and indirect effects

- 需要设计实验来验证因果机制（如何构造 RCT 或自然实验来测试因果假设？）——实验设计直接阻断混淆路径
  Need to design experiments targeting causal mechanisms (how to construct an RCT or natural experiment to test causal hypotheses?) — experimental design directly blocks confounding paths

## 方法流程 / Method

### 第一步：构建因果 DAG / Construct the Causal DAG

明确问题中的所有变量，画出因果箭头，编码关于直接原因的假设，检查是否有循环（DAG 必须是无环的）。

- **识别变量**：原因变量 X（干预对象）、结果变量 Y（关注效应）、混淆变量 Z（同时影响 X 和 Y）、中介变量 M（X→M→Y）
- **画因果箭头**：每个箭头 X→Y 表示"X 是 Y 的直接原因"——箭头方向编码因果假设
- **检查无环性**：DAG 是有向无环图——若存在环路，则因果方向不确定，需要重新建模

**关键问题**：你是否有足够的领域知识来编码因果方向？因果推断的结论完全依赖 DAG 的正确性。

### 第二步：识别混淆变量 / Identify Confounders

混淆变量同时影响原因 X 和结果 Y，创造虚假的关联——不调整混淆则效应估计有偏。

- **定义**：变量 Z 是混淆变量，若 Z 是 X 和 Y 的共同原因（DAG 中 Z→X 且 Z→Y）
- **DAG 识别法**：找出 X 和 Y 的所有共同祖先——这些就是潜在的混淆变量
- **后门路径**：X ← Z → Y 是后门路径——它创造的非因果关联需要被阻断

**关键问题**：所有混淆变量是否都可观测？若存在未观测混淆，后门调整不可用，需考虑前门准则或工具变量。

### 第三步：选择识别策略 / Choose Identification Strategy

根据混淆变量的可观测性，选择从观测数据计算 P(y|do(x)) 的策略：

**后门准则 / Back-door Criterion**：
若存在变量集 S 使得 (1) S 阻断 X→Y 的所有后门路径，(2) S 不包含 X 的后代，则：
P(y|do(x)) = Σ_s P(y|x,S=s)·P(S=s)

**前门准则 / Front-door Criterion**：
若混淆变量不可观测但中介变量 M 可观测，且 (1) X→M 且 X 到 M 无后门路径，(2) M→Y 且 X 到 Y 的所有后门路径都被 M 阻断，则：
P(y|do(x)) = Σ_m P(y|do(m))·P(m|do(x)) = Σ_m Σ_z P(y|m,z)·P(z)·P(m|x)

**do-演算 / Do-calculus**：
三条规则允许在可观测量间转换 do-表达式：
- 规则 1（插入/删除观察）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头后的图中成立，则 P(y|do(x),z) = P(y|do(x))
- 规则 2（干预与观察互换）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头并删去所有从 Z 出发的箭头后的图中成立，则 P(y|do(x),do(z)) = P(y|do(x),z)
- 规则 3（插入/删除干预）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头并删去所有从 Z 到 X 的路径上的箭头后的图中成立，则 P(y|do(x),do(z)) = P(y|do(x))

### 第四步：计算干预效果 / Compute Intervention Effects

使用调整公式计算 P(y|do(x))，并与观察性 P(y|x) 对比以衡量混淆偏差。

- **后门调整**：P(y|do(x)) = Σ_z P(y|x,z)·P(z)——对混淆变量 Z 的所有取值加权平均
- **混淆偏差度量**：|P(y|do(x)) - P(y|x)|——偏差越大，说明混淆越严重
- **因果效应**：ATE = E[Y|do(X=1)] - E[Y|do(X=0)]——平均处理效应

**关键问题**：P(y|do(x)) 与 P(y|x) 是否显著不同？若不同，说明观察性分析有混淆偏差；若相同，说明没有显著混淆（但可能是巧合）。

### 第五步：反事实分析 / Counterfactual Analysis

对个体层面进行回顾性推理：如果 X 是 x₁ 而不是 x₀，Y 会怎样？

- **结构因果模型 / SCM**：Y = f(X, Z, U)，其中 U 为外生变量（不可观测的个体特征）
- **反事实计算**：给定观测值 (X=x₀, Y=y₀, Z=z₀)，反事实 Y_{x₁} = f(x₁, z₀, u₀)
- **个体因果效应**：Y_{x₁} - Y_{x₀}——个体层面的因果效应，需要结构方程

**关键问题**：你有足够的信息来区分个体差异吗？反事实推理依赖结构方程的具体形式，对模型假设极为敏感。

### 第六步：实验设计验证 / Experimental Design for Verification

**RCT 作为黄金标准 / RCT as Gold Standard**：
- 随机化切断所有指向 X 的因果箭头——随机分配使处理组与对照组在所有变量（已知与未知）上期望相等
- 随机化直接阻断所有后门路径，无需识别混淆变量
- ATE = E[Y|随机分配X=1] - E[Y|随机分配X=0] = E[Y|do(X=1)] - E[Y|do(X=0)]

**当 RCT 不可能时 / When RCT is Impossible**：

- **自然实验 / Natural Experiments**：利用自然发生的随机化事件（如地震、政策变更）作为"准随机化"
- **工具变量 / Instrumental Variables (IV)**：变量 V 是工具变量，若 V→X 且 V 到 Y 无直接路径、V 与 Y 无共同原因——利用 V 创造的 X 的变异来估计因果效应
- **双重差分 / Difference-in-Differences (DD)**：比较处理组与对照组在干预前后差异的变化——DD = (Y₁^处理后 - Y₁^处理前) - (Y₀^处理后 - Y₀^处理前)

### 第七步：敏感性分析 / Sensitivity Analysis

因果结论对未观测混淆有多脆弱？量化混淆必须有多强才能推翻结论。

- **Rosenbaum 方法**：对于给定的混淆强度 Γ，计算因果结论可能翻转的最大 p-value——Γ 越大，结论越脆弱
- **E-value**：使观察到的效应估计归零所需的混淆最小强度——E-value 越大，结论越稳健
- **关键问题**：如果存在一个未观测混淆变量 U，它必须多强（与 X 和 Y 的关联必须多大）才能使因果结论不再成立？

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|---|---|---|
| 从相关直接推断因果 / Inferring causation from correlation directly | P(y|x) ≠ P(y|do(x))；相关可能由混淆变量创造，而非因果机制 | 画 DAG 识别混淆路径，用后门调整计算 P(y|do(x)) |
| 忽略混淆变量 / Ignoring confounders | 不调整混淆时，|P(y|do(x)) - P(y|x)| = 混淆偏差；效应估计有偏且方向可能错误 | 识别 X 和 Y 的所有共同祖先，对可观测混淆做调整 |
| 混淆 do(x) 与条件化 P(y|x) / Confounding do(x) with conditioning P(y|x) | do(x) 切断所有指向 X 的箭头；条件化 x 不切断任何箭头——两者数学含义不同 | 明确区分：do(x) 是干预（"强制设定 X=x"），P(y|x) 是观察（"看到 X=x 时 Y 如何"） |
| 忽略中介效应 / Ignoring mediation effects | X→M→Y 中，总效应 = 直接效应 + 间接效应；忽略中介会混淆因果路径 | 进行中介分析，拆分直接效应与间接效应（前门准则可利用中介） |
| 过度依赖单一因果假设 / Over-relying on a single causal assumption (DAG may be wrong) | DAG 的错误导致因果结论全盘错误；不同 DAG 可能给出相反结论 | 检验 DAG 的合理性；比较多个备选 DAG；进行敏感性分析 |
| 忽略敏感性分析 / Skipping sensitivity analysis | 未观测混淆可能推翻因果结论；不评估脆弱性则结论不可靠 | 用 Rosenbaum 方法或 E-value 量化结论对未观测混淆的脆弱性 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：

1. **[DAG]:[因果图]**：画出所有变量的有向无环图，标注每条因果箭头的假设依据
2. **[混淆变量]:[列表]**：列出 X 和 Y 的所有共同祖先，标注哪些可观测、哪些不可观测
3. **[识别策略]:[后门/前门/do算子]**：根据混淆可观测性选择识别策略，说明选择理由
4. **[干预效果]:P(y|do(x))=[值]**：用调整公式计算因果效应，与观察性关联对比
5. **[反事实]:[分析]**：对关键个体或子群体进行反事实推理，说明所需结构方程
6. **[验证方法]:[RCT/自然实验/IV/DD]**：说明如何用实验或准实验方法验证因果结论
7. **[敏感性]:[评估]**：量化因果结论对未观测混淆的脆弱性（Rosenbaum Γ 或 E-value）

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **概率与统计**：统计是因果的基础但不充分——P(y|x) 是统计关联，P(y|do(x)) 是因果效应；因果需要额外假设
- **建模思想**：因果 DAG 是结构模型——编码变量间的因果机制假设，是建模的因果版本
- **逻辑演绎**：因果推理的演绎链条——从 DAG 假设出发，通过 do-演算三条规则演绎出因果结论
- **信息论思想**：信号与信息不对称——混淆变量制造虚假信号，因果推断从噪声中提取真实因果信号
- **博弈思想**：策略互动中的因果——参与者的策略选择构成因果干预，均衡分析需要因果推理