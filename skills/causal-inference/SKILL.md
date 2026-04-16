---
name: causal-inference
description: |
  科研模式触发：干预效果评估、政策评估、DAG建模、do-calculus、反事实推理的数学形式化。
  生活模式触发：区分原因与借口、反事实思考、评估某事是否真的有效、判断"做了X会怎样"而非"看到X时如何"。
  English Research Mode: intervention effect evaluation, policy evaluation, DAG modeling, do-calculus, counterfactual reasoning formalization.
  English Life Mode: distinguishing cause from excuse, counterfactual thinking, evaluating whether something truly works, judging "what if we did X" not "how is Y when we see X".
---

# 🔗 因果推断思想

> "相关不等于因果——但因果可以理清。关键区别：'看到X时Y如何'≠'如果做了X会怎样'"
> "Correlation is not causation — but causation can be sorted out. Key distinction: 'how is Y when we see X' ≠ 'what if we did X'"
>
> —— 因果推断、结构因果模型、反事实推理
> —— Causal Inference, Structural Causal Models, Counterfactual Reasoning

## 核心原则 / Core Principle

**因果推断回答的问题超出了概率论的表达能力：概率论能回答"看到 X 时 Y 如何"，但不能回答"如果做了 X 会怎样"。Pearl 的因果层级（Ladder of Causation）将推理能力分为三层，每层需要更强的建模假设。**

**Causal inference answers questions beyond the expressive power of probability theory: probability can answer "how is Y when we see X," but not "what if we did X." Pearl's Ladder of Causation divides reasoning into three levels, each requiring stronger modeling assumptions.**

> **数学形式化 / Mathematical Formalization**（科研模式参考）
>
> Pearl 因果层级 / Pearl's Causal Hierarchy：
>
> - **Level 1 关联 / Association**：P(y|x) —— 看到/观察 / Seeing/Observing
>   - 问题："观察到 X 时 Y 是什么？"——纯粹统计关联，条件概率即可回答
>   - 例："购买牙膏的人更可能购买牙线"——P(牙线|牙膏) > P(牙线)
>
> - **Level 2 干预 / Intervention**：P(y|do(x)) —— 做/干预 / Doing/Intervening
>   - 问题："如果我强制设定 X，Y 会怎样？"——需要因果模型，do-演算回答
>   - 例："如果提高价格，销量会怎样？"——P(销量|do(价格↑)) ≠ P(销量|价格↑)
>
> - **Level 3 反事实 / Counterfactual**：P(y_x|x',y') —— 想/回顾 / Imagining/Retrospective
>   - 问题："如果当时 X 是 x₁ 而不是 x₀，Y 会怎样？"——需要结构因果模型
>   - 例："如果患者当时没服药，他是否还能康复？"——个体层面推理
>
> **do(x) 干预不同于条件化 x**：
>
> P(y|do(x)) = Σ_z P(y|x,z)P(z) （后门调整公式 / back-door adjustment）
>
> - 条件化 P(y|x)：在观察到 X=x 的人群中 Y 的分布——受混淆变量影响
> - 干预 P(y|do(x))：在强制设定 X=x 的人群中 Y 的分布——切断了所有指向 X 的因果箭头
>
> **do-演算三条规则 / Do-calculus Three Rules**：
>
> - 规则 1（插入/删除观察）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头后的图中成立，则 P(y|do(x),z) = P(y|do(x))
> - 规则 2（干预与观察互换）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头并删去所有从 Z 出发的箭头后的图中成立，则 P(y|do(x),do(z)) = P(y|do(x),z)
> - 规则 3（插入/删除干预）：若 Y ⊥ Z | X 在删去所有指向 X 的箭头并删去所有从 Z 到 X 的路径上的箭头后的图中成立，则 P(y|do(x),do(z)) = P(y|do(x))
>
> **因果推理需要显式因果模型，不能仅靠数据推导。DAG 编码因果假设，do-演算将干预表达式转化为可观测量。**
>
> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **纯粹的预测任务且无因果问题** `[科研/通用]`（只需要预测 P(y|x)，不关心"为什么"）——关联足够，因果是多余的
  **Purely predictive tasks with no causal question** (only need P(y|x), don't care "why") — association suffices, causation is superfluous

- **无可编码的因果假设** `[科研/通用]`（无法画出合理的 DAG，因果方向不确定）——因果推断依赖显式假设，没有假设就没有因果结论
  **No causal assumptions available to encode** (cannot draw a reasonable DAG, causal direction uncertain) — causal inference requires explicit assumptions; without assumptions there are no causal conclusions

- **确定性系统且无变异** `[科研]`（每个输入严格对应唯一输出，无随机性）——因果已被确定性机制完全描述，无需概率因果框架
  **Deterministic system with no variation** (each input strictly maps to a unique output, no randomness) — causation is fully described by the deterministic mechanism, no probabilistic causal framework needed

- **只需要解释现象而非追问"如果做了X"** `[生活]`（日常生活中只需理解"为什么发生"，不需要精确量化干预效果）——常识推理足够，不必引入形式化框架
  **Only need to explain phenomena, not ask "what if we did X"** (daily life only needs to understand "why it happened," no need to precisely quantify intervention effects) — common-sense reasoning suffices, no need for formalized frameworks

## 何时使用 / When to Use

### 科研触发条件 / Research Trigger Conditions

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

### 生活触发条件 / Life Trigger Conditions

- 需要区分原因与借口（"他迟到是因为堵车"是真原因还是借口？——真原因可以通过干预验证，借口只是事后解释）
  Need to distinguish cause from excuse ("he was late because of traffic" — is that a real cause or just an excuse?) — real causes can be verified through intervention, excuses are just post-hoc explanations

- 需要反事实思考（"如果当初选了另一条路会怎样？"——帮助理解当下选择的真实影响）
  Need counterfactual thinking ("what if I had chosen another path?") — helps understand the real impact of current choices

- 需要评估某事是否真的有效（"早起就能成功？"还是"成功人士恰好早起？"——区分"做了X的效果"和"看到X时的关联"）
  Need to evaluate whether something truly works ("does waking up early lead to success?" or "do successful people just happen to wake up early?") — distinguish "the effect of doing X" from "the association when seeing X"

- 需要判断"如果做了X会怎样"而非"看到X时如何"（"看到健身的人更健康"≠"健身就能健康"——可能有隐藏的共同原因）
  Need to judge "what if we did X" not "how things are when we see X" ("seeing gym-goers healthier" ≠ "going to the gym makes you healthy") — there may be hidden common causes

- 需要避免把相关当因果（"喝咖啡的人更健康"可能不是咖啡的功劳——而是喝咖啡的人本身更注重健康习惯）
  Need to avoid mistaking correlation for causation ("coffee drinkers are healthier" may not be thanks to coffee — rather, coffee drinkers tend to have healthier habits)

## 方法流程 / Method

### 第一步：构建因果 DAG / Construct the Causal DAG

#### 科研模式 / Research Mode

明确问题中的所有变量，画出因果箭头，编码关于直接原因的假设，检查是否有循环（DAG 必须是无环的）。

- **识别变量**：原因变量 X（干预对象）、结果变量 Y（关注效应）、混淆变量 Z（同时影响 X 和 Y）、中介变量 M（X→M→Y）
- **画因果箭头**：每个箭头 X→Y 表示"X 是 Y 的直接原因"——箭头方向编码因果假设
- **检查无环性**：DAG 是有向无环图——若存在环路，则因果方向不确定，需要重新建模

**关键问题**：你是否有足够的领域知识来编码因果方向？因果推断的结论完全依赖 DAG 的正确性。

#### 生活模式 / Life Mode

画出因果链——用箭头表示"导致"而非"伴随"。问自己：X真的导致Y，还是它们只是恰好同时出现？有没有隐藏的共同原因同时影响了X和Y？

Draw causal chains — use arrows to mean "causes" not "co-occurs." Ask yourself: does X truly cause Y, or do they just happen to appear together? Is there a hidden common cause that influences both X and Y?

- 不要把"同时出现"当成"导致"——两个现象经常一起出现，不代表一个导致了另一个
- 用简单箭头图理清因果：A→B→C 表示"A导致B，B导致C"
- 检查有没有"隐藏的第三因素"同时指向A和B

#### 共通要点 / Shared Essentials

因果假设必须显式声明——无论是形式化 DAG 还是简单因果链，都需要明确"谁导致谁"的假设依据。

Causal assumptions must be explicitly stated — whether formal DAGs or simple causal chains, the basis for "who causes whom" must be made clear.

### 第二步：识别混淆变量 / Identify Confounders

#### 科研模式 / Research Mode

混淆变量同时影响原因 X 和结果 Y，创造虚假的关联——不调整混淆则效应估计有偏。

- **定义**：变量 Z 是混淆变量，若 Z 是 X 和 Y 的共同原因（DAG 中 Z→X 且 Z→Y）
- **DAG 识别法**：找出 X 和 Y 的所有共同祖先——这些就是潜在的混淆变量
- **后门路径**：X ← Z → Y 是后门路径——它创造的非因果关联需要被阻断

**关键问题**：所有混淆变量是否都可观测？若存在未观测混淆，后门调整不可用，需考虑前门准则或工具变量。

#### 生活模式 / Life Mode

有没有一个隐藏因素同时影响了"原因"和"结果"？——比如"喝咖啡的人更健康"可能是因为喝咖啡的人本身更注重健康习惯，而不是咖啡让人健康

Is there a hidden factor that influences both the "cause" and the "outcome"? — e.g., "coffee drinkers are healthier" might be because coffee drinkers tend to have healthier habits, not because coffee makes you healthy

- 检查：有没有一个你没考虑到的因素，同时影响了两边？
- 常见混淆：健康习惯与健康结果、教育与收入、年龄与多种结果
- 混淆的特征：它同时出现在"原因"和"结果"的上游

#### 共通要点 / Shared Essentials

混淆变量的本质是创造虚假关联——不管形式化与否，识别"同时影响X和Y的因素"是因果推理的核心步骤。

The essence of confounders is creating spurious associations — whether formalized or not, identifying "factors that simultaneously influence X and Y" is the core step of causal reasoning.

### 第三步：选择识别策略 / Choose Identification Strategy

#### 科研模式 / Research Mode

根据混淆变量的可观测性，选择从观测数据计算 P(y|do(x)) 的策略：

**后门准则 / Back-door Criterion**：
若存在变量集 S 使得 (1) S 阻断 X→Y 的所有后门路径，(2) S 不包含 X 的后代，则：
P(y|do(x)) = Σ_s P(y|x,S=s)·P(S=s)

**前门准则 / Front-door Criterion**：
若混淆变量不可观测但中介变量 M 可观测，且 (1) X→M 且 X 到 M 无后门路径，(2) M→Y 且 X 到 Y 的所有后门路径都被 M 阻断，则：
P(y|do(x)) = Σ_m P(y|do(m))·P(m|do(x)) = Σ_m Σ_z P(y|m,z)·P(z)·P(m|x)

**do-演算 / Do-calculus**：
三条规则允许在可观测量间转换 do-表达式（详见核心原则中的数学形式化块）

#### 生活模式 / Life Mode

如何排除混淆因素的干扰？——能不能找到一个"纯净"的比较组（只差别在X上，其他条件完全一样）？

How to eliminate the influence of confounding factors? — can we find a "clean" comparison group (different only in X, identical in all other conditions)?

- 最理想的比较：两组人除了"是否做了X"之外完全一样——如果结果不同，才能说X导致了差异
- 如果找不到"纯净"比较组，至少尽量控制已知混淆因素——让比较更公平
- 注意：观察性数据总有遗漏混淆的风险，真正的因果验证需要实验

#### 共通要点 / Shared Essentials

识别策略的本质是"如何从混杂的数据中提取纯净的因果信号"——形式化工具和常识策略都在解决同一个问题。

The essence of identification strategy is "how to extract a clean causal signal from mixed data" — formal tools and common-sense strategies both solve the same problem.

### 第四步：计算干预效果 / Compute Intervention Effects

#### 科研模式 / Research Mode

使用调整公式计算 P(y|do(x))，并与观察性 P(y|x) 对比以衡量混淆偏差。

- **后门调整**：P(y|do(x)) = Σ_z P(y|x,z)·P(z)——对混淆变量 Z 的所有取值加权平均
- **混淆偏差度量**：|P(y|do(x)) - P(y|x)|——偏差越大，说明混淆越严重
- **因果效应**：ATE = E[Y|do(X=1)] - E[Y|do(X=0)]——平均处理效应

**关键问题**：P(y|do(x)) 与 P(y|x) 是否显著不同？若不同，说明观察性分析有混淆偏差；若相同，说明没有显著混淆（但可能是巧合）。

#### 生活模式 / Life Mode

如果我真的做了X（而不是刚好看到X），结果会怎样？——"看到成功人士早起"≠"早起就能成功"

What would happen if I actually did X (rather than just seeing X)? — "seeing successful people wake up early" ≠ "waking up early leads to success"

- 区分两种问题："看到X的人Y如何？"和"做了X之后Y如何？"
- 第一个问题只是观察——可能有混淆；第二个才是因果——需要排除混淆
- 实际判断时：问"如果我主动做了X，结果和只是看到别人做X时一样吗？"

#### 共通要点 / Shared Essentials

干预效果的核心是"做了"与"看到"的区别——无论是 P(y|do(x)) 还是日常直觉，都要区分主动干预与被动观察。

The core of intervention effects is the distinction between "doing" and "seeing" — whether P(y|do(x)) or daily intuition, we must separate active intervention from passive observation.

### 第五步：反事实分析 / Counterfactual Analysis

#### 科研模式 / Research Mode

对个体层面进行回顾性推理：如果 X 是 x₁ 而不是 x₀，Y 会怎样？

- **结构因果模型 / SCM**：Y = f(X, Z, U)，其中 U 为外生变量（不可观测的个体特征）
- **反事实计算**：给定观测值 (X=x₀, Y=y₀, Z=z₀)，反事实 Y_{x₁} = f(x₁, z₀, u₀)
- **个体因果效应**：Y_{x₁} - Y_{x₀}——个体层面的因果效应，需要结构方程

**关键问题**：你有足够的信息来区分个体差异吗？反事实推理依赖结构方程的具体形式，对模型假设极为敏感。

#### 生活模式 / Life Mode

如果当初选了另一条路，现在会怎样？——反事实思考帮助理解因果关系，但要注意：我们永远无法真正验证"如果当初怎样"

What if I had chosen a different path? — counterfactual thinking helps understand causation, but note: we can never truly verify "what if things had been different"

- 反事实思考的价值：帮助理解"什么导致了什么"——如果去掉X，Y还会发生吗？
- 反事实思考的局限：我们永远无法回到过去验证——只能基于现有信息推断
- 避免过度依赖反事实：它帮助理解因果，但不能作为确定性的证据

#### 共通要点 / Shared Essentials

反事实推理是因果理解的最深层——它追问"如果不是这样，会怎样"，无论是形式化 SCM 还是日常反思，都需要承认其不可验证性。

Counterfactual reasoning is the deepest level of causal understanding — it asks "what if it had been otherwise," whether formal SCM or daily reflection, we must acknowledge its unverifiability.

### 第六步：实验设计验证 / Experimental Design for Verification

#### 科研模式 / Research Mode

**RCT 作为黄金标准 / RCT as Gold Standard**：
- 随机化切断所有指向 X 的因果箭头——随机分配使处理组与对照组在所有变量（已知与未知）上期望相等
- 随机化直接阻断所有后门路径，无需识别混淆变量
- ATE = E[Y|随机分配X=1] - E[Y|随机分配X=0] = E[Y|do(X=1)] - E[Y|do(X=0)]

**当 RCT 不可能时 / When RCT is Impossible**：

- **自然实验 / Natural Experiments**：利用自然发生的随机化事件（如地震、政策变更）作为"准随机化"
- **工具变量 / Instrumental Variables (IV)**：变量 V 是工具变量，若 V→X 且 V 到 Y 无直接路径、V 与 Y 无共同原因——利用 V 创造的 X 的变异来估计因果效应
- **双重差分 / Difference-in-Differences (DD)**：比较处理组与对照组在干预前后差异的变化——DD = (Y₁^处理后 - Y₁^处理前) - (Y₀^处理后 - Y₀^处理前)

#### 生活模式 / Life Mode

如何验证因果关系？最可靠的方法是做实验——把人随机分成两组，一组做X一组不做，看结果是否不同。如果不能做实验，找自然发生的对比情境

How to verify causal relationships? The most reliable method is experimentation — randomly divide people into two groups, one does X and one doesn't, see if results differ. If experiments aren't possible, find naturally occurring comparison scenarios

- 最可靠：随机实验——两组人完全一样，唯一的差别是"是否做了X"
- 退而求其次：自然对比——找到恰好相似但X不同的情境进行比较
- 日常可用：小规模试错——自己尝试做/不做X，观察结果变化（但要注意其他变量也在变化）

#### 共通要点 / Shared Essentials

验证因果的核心是"随机化"或"等价比较"——无论是 RCT 还是日常小实验，都需要尽量排除其他变量的干扰。

The core of causal verification is "randomization" or "equivalent comparison" — whether RCT or daily small experiments, we must try to eliminate interference from other variables.

### 第七步：敏感性分析 / Sensitivity Analysis

#### 科研模式 / Research Mode

因果结论对未观测混淆有多脆弱？量化混淆必须有多强才能推翻结论。

- **Rosenbaum 方法**：对于给定的混淆强度 Γ，计算因果结论可能翻转的最大 p-value——Γ 越大，结论越脆弱
- **E-value**：使观察到的效应估计归零所需的混淆最小强度——E-value 越大，结论越稳健
- **关键问题**：如果存在一个未观测混淆变量 U，它必须多强（与 X 和 Y 的关联必须多大）才能使因果结论不再成立？

#### 生活模式 / Life Mode

因果结论有多脆弱？如果有一个你没考虑到的隐藏因素，它得多强才能推翻你的结论？——越脆弱，越要谨慎

How fragile is the causal conclusion? If there's a hidden factor you haven't considered, how strong would it need to be to overturn your conclusion? — the more fragile, the more cautious you should be

- 问问自己：有没有遗漏的混淆因素？如果有，它得多重要才能改变结论？
- 如果结论很容易被推翻，就不要太自信——谨慎行事
- 越重要的决策，越需要做敏感性检查——确保结论足够稳健

#### 共通要点 / Shared Essentials

敏感性分析是因果推理的"安全网"——无论是形式化的 Rosenbaum Γ 还是日常的"还能有多强"判断，都在检验结论的稳健性。

Sensitivity analysis is the "safety net" of causal reasoning — whether formal Rosenbaum Γ or daily "how strong could it be" judgment, both test the robustness of conclusions.

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|---|---|---|
| 从相关直接推断因果 / Inferring causation from correlation directly `[科研/通用/生活]` | P(y|x) ≠ P(y|do(x))；相关可能由混淆变量创造，而非因果机制 | 画 DAG 识别混淆路径，用后门调整计算 P(y|do(x)) |
| 忽略混淆变量 / Ignoring confounders `[科研/通用/生活]` | 不调整混淆时，|P(y|do(x)) - P(y|x)| = 混淆偏差；效应估计有偏且方向可能错误 | 识别 X 和 Y 的所有共同祖先，对可观测混淆做调整 |
| 混淆 do(x) 与条件化 P(y|x) / Confounding do(x) with conditioning P(y|x) `[科研/通用]` | do(x) 切断所有指向 X 的箭头；条件化 x 不切断任何箭头——两者数学含义不同 | 明确区分：do(x) 是干预（"强制设定 X=x"），P(y|x) 是观察（"看到 X=x 时 Y 如何"） |
| 忽略中介效应 / Ignoring mediation effects `[科研/通用]` | X→M→Y 中，总效应 = 直接效应 + 间接效应；忽略中介会混淆因果路径 | 进行中介分析，拆分直接效应与间接效应（前门准则可利用中介） |
| 过度依赖单一因果假设 / Over-relying on a single causal assumption (DAG may be wrong) `[科研]` | DAG 的错误导致因果结论全盘错误；不同 DAG 可能给出相反结论 | 检验 DAG 的合理性；比较多个备选 DAG；进行敏感性分析 |
| 忽略敏感性分析 / Skipping sensitivity analysis `[科研]` | 未观测混淆可能推翻因果结论；不评估脆弱性则结论不可靠 | 用 Rosenbaum 方法或 E-value 量化结论对未观测混淆的脆弱性 |
| 把相关当因果 / Mistaking correlation for causation `[生活]` | 日常生活中最常见的错误——"看到X和Y一起出现"就认为"X导致Y" | 问自己：有没有隐藏的共同原因？X和Y是否只是恰好同时出现？ |
| 忽略隐藏的共同原因 / Ignoring hidden common causes `[生活]` | 隐藏因素同时影响X和Y，制造虚假因果——比如"健康习惯"同时影响"喝咖啡"和"健康状况" | 检查有没有同时影响"原因"和"结果"的隐藏因素——寻找上游的共同原因 |
| 轻信"做了X就有效"而没验证 / Believing "doing X works" without verification `[生活]` | 观察到的效果可能是混淆偏差而非真实因果效应——没有验证就行动可能误导决策 | 找对比情境验证：有没有不做X但结果一样的情况？做小规模试错再全面推行 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，根据模式选择输出格式：

### 模式选择 / Mode Selector

- **科研模式**：当问题涉及干预效果评估、政策评估、DAG建模、do-calculus时使用
  **Research Mode**: Use when the question involves intervention effect evaluation, policy evaluation, DAG modeling, do-calculus
- **生活模式**：当问题涉及区分原因与借口、反事实思考、评估某事是否真的有效时使用
  **Life Mode**: Use when the question involves distinguishing cause from excuse, counterfactual thinking, evaluating whether something truly works

### 科研模式输出格式 / Research Mode Output Format

1. **[DAG]:[因果图]**：画出所有变量的有向无环图，标注每条因果箭头的假设依据
2. **[混淆变量]:[列表]**：列出 X 和 Y 的所有共同祖先，标注哪些可观测、哪些不可观测
3. **[识别策略]:[后门/前门/do算子]**：根据混淆可观测性选择识别策略，说明选择理由
4. **[干预效果]:P(y|do(x))=[值]**：用调整公式计算因果效应，与观察性关联对比
5. **[反事实]:[分析]**：对关键个体或子群体进行反事实推理，说明所需结构方程
6. **[验证方法]:[RCT/自然实验/IV/DD]**：说明如何用实验或准实验方法验证因果结论
7. **[敏感性]:[评估]**：量化因果结论对未观测混淆的脆弱性（Rosenbaum Γ 或 E-value）

**科研模式输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

### 生活模式输出格式 / Life Mode Output Format

1. **[因果链]:[分析]** — X真的导致Y吗？还是它们只是恰好同时出现？画出因果链
   **[Causal Chain]:[Analysis]** — Does X truly cause Y? Or do they just happen to co-occur? Draw the causal chain
2. **[隐藏因素]:[列表]** — 有没有同时影响X和Y的隐藏因素
   **[Hidden Factors]:[List]** — Are there hidden factors that simultaneously influence X and Y
3. **[真实效果]:[判断]** — 如果我真的做了X，结果会怎样（而不是"看到X时结果如何"）
   **[True Effect]:[Judgment]** — What would happen if I actually did X (not "how things are when we see X")
4. **[反事实]:[思考]** — 如果当初没做X/做了X，结果会怎样
   **[Counterfactual]:[Thinking]** — What if I hadn't done X / had done X, what would the result be
5. **[验证方式]:[建议]** — 如何验证这个因果判断是否可靠
   **[Verification]:[Suggestion]** — How to verify whether this causal judgment is reliable
6. **[行动建议]:[步骤]** — 在当前因果判断下最务实的行动方案
   **[Action Advice]:[Steps]** — The most pragmatic action plan given the current causal judgment

**生活模式输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **概率与统计**：统计是因果的基础但不充分——P(y|x) 是统计关联，P(y|do(x)) 是因果效应；因果需要额外假设
- **建模思想**：因果 DAG 是结构模型——编码变量间的因果机制假设，是建模的因果版本
- **逻辑演绎**：因果推理的演绎链条——从 DAG 假设出发，通过 do-演算三条规则演绎出因果结论
- **信息论思想**：信号与信息不对称——混淆变量制造虚假信号，因果推断从噪声中提取真实因果信号
- **博弈思想**：策略互动中的因果——参与者的策略选择构成因果干预，均衡分析需要因果推理