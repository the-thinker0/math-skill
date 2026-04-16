---
name: game-theory
description: |
  科研模式触发：当涉及数学建模、论文分析、算法设计中的多方互动决策、纳什均衡计算、机制设计时调用。
  生活模式触发：当涉及日常决策受他人影响、人际互动策略、生活规划中的利益协调与冲突时调用。
  Research mode trigger: When math modeling, paper analysis, algorithm design involves multi-party interactive decisions, Nash equilibrium computation, mechanism design.
  Life mode trigger: When daily decisions are influenced by others, interpersonal interaction strategy, benefit coordination and conflict in life planning.
  English: Trigger when decisions involve multiple interacting parties, optimal strategy depends on others' choices, or incentive mechanisms need designing.
---

# 🎯 博弈论思想

> "你的最优选择取决于他人的选择——思考不仅要深入，还要互动。"
> "Your optimal choice depends on others' choices — thinking must be interactive, not just deep."
>
> —— 博弈论、决策论、机制设计 / Game Theory, Decision Theory, Mechanism Design

## 核心原则 / Core Principle

**战略互动——你的最优行动取决于他人做什么，而他人的最优行动取决于你做什么。纳什均衡：无人能从单方面偏离中获益的策略组合。**

**Strategic interaction — your best action depends on what others do, and theirs depend on what you do. Nash equilibrium: strategy profile where no player benefits from unilateral deviation.**

关键概念：
- **支付矩阵（Payoff Matrix）**：每个策略组合下各参与者的收益表
- **占优策略（Dominant Strategy）**：无论他人选什么，该策略总是最优
- **混合策略（Mixed Strategy）**：以概率分布随机选择纯策略
- **帕累托最优性（Pareto Optimality）**：不存在使所有人同时改善的策略组合

博弈的三种分类维度：
- **合作博弈 vs 非合作博弈**：参与者能否达成有约束力的协议
- **零和博弈 vs 一般和博弈**：参与者收益是否完全对立
- **同时博弈 vs 序列博弈**：参与者行动是否有序列依赖

> **数学形式化 / Mathematical Formalization**（科研模式参考）
>
> 形式化定义：n 个参与者，每人有策略集 $S_i$ 和支付函数 $u_i: S_1 \times \cdots \times S_n \to \mathbb{R}$。
>
> 纳什均衡：策略组合 $s^* = (s_1^*, \ldots, s_n^*)$ 满足
>
> $$u_i(s^*) \geq u_i(s_i, s^*_{-i}) \quad \text{for all } s_i \in S_i, \text{ all } i$$
>
> 其中 $s^*_{-i} = (s_1^*, \ldots, s_{i-1}^*, s_{i+1}^*, \ldots, s_n^*)$ 表示除参与者 $i$ 外所有其他人的策略。混合策略纳什均衡：概率分布 $\sigma^*$ 使得
>
> $$u_i(\sigma^*) \geq u_i(s_i, \sigma^*_{-i}) \quad \text{for all } s_i \in S_i, \text{ all } i$$

## 不适用场景 / When NOT to Use

- **单人决策问题，与他人无互动** `[科研/通用]` ——优化思想更适用，无需考虑他人策略响应
- **纯合作问题，无利益冲突** `[科研/通用]` ——参与者目标完全一致，无需战略分析
- **确定性问题，无战略不确定性** `[科研]` ——结果由自身行动唯一决定，不涉及他人反应
- **情绪驱动的即时反应，无策略考量空间** `[生活]` ——来不及分析他人选择，博弈框架无法介入
- **纯粹运气决定的结果，各方无策略选择** `[通用]` ——无策略集可分析，博弈论不适用

- **Single-player decision with no interaction with others** `[Research/General]` — optimization suffices, no need to consider strategic response
- **Purely cooperative problem with no conflict** `[Research/General]` — all players share identical goals, strategic analysis unnecessary
- **Deterministic problem with no strategic uncertainty** `[Research]` — outcome determined solely by own actions, no others' reactions involved
- **Emotion-driven instant reaction with no room for strategic deliberation** `[Life]` — too fast to analyze others' choices, game theory framework cannot intervene
- **Pure luck-determined outcomes with no strategic choices for any party** `[General]` — no strategy sets to analyze, game theory not applicable

## 何时使用 / When to Use

### 科研触发条件 / Research Triggers

- 多个决策者相互影响，各自的策略影响他人收益
- 最佳策略取决于他人可能的响应，需预判他人行动
- 需设计激励机制，使自利行为导向社会最优结果
- 谈判或讨价还价，需分析利益分配与威胁点
- 分析竞争市场中的定价、进入、退出等策略行为
- 预测均衡结果——在给定规则下系统趋向何种稳定状态

- Multiple decision-makers interact, each strategy affects others' payoffs
- Optimal strategy depends on others' likely responses, need to anticipate their actions
- Designing incentive mechanisms, making self-interested behavior lead to socially optimal outcomes
- Negotiating or bargaining, analyzing benefit distribution and threat points
- Analyzing competitive markets — pricing, entry, exit and other strategic behaviors
- Predicting equilibrium outcomes — what stable state the system converges to under given rules

### 生活触发条件 / Life Triggers

- 你的决定会受到别人决定的影响（如选择去哪家餐厅取决于朋友偏好）
- 需要预判他人反应来做决策（如谈判薪资、分配家务、竞标拍卖）
- 多方利益冲突需要协调（如家庭资源分配、团队任务分工）
- 感觉陷入两难——无论怎么选都不满意，可能需要改变互动规则
- 重复互动中需要建立合作或信任（如邻里关系、长期合作）
- 需要设计规则让别人自愿做出好选择（如激励机制、团队奖惩制度）

- Your decision is influenced by others' decisions (e.g., choosing a restaurant depends on friends' preferences)
- Need to anticipate others' reactions before deciding (e.g., salary negotiation, chore division, bidding)
- Multiple parties' interests conflict and need coordination (e.g., family resource allocation, team task division)
- Feeling trapped in a dilemma — no choice satisfies, may need to change interaction rules
- Need to build cooperation or trust in repeated interactions (e.g., neighbor relations, long-term partnerships)
- Need to design rules so others voluntarily make good choices (e.g., incentive mechanisms, team reward/penalty systems)

## 方法流程 / Method

### 第一步：识别参与者与策略 / Identify Players and Strategies

#### 科研模式 / Research Mode

定义博弈的基本要素：
- **参与者（Players）**：$N = \{1, 2, \ldots, n\}$，谁在做决策？
- **策略集（Strategy Sets）**：$S_i$ 为参与者 $i$ 的所有可选行动
- **支付函数（Payoff Functions）**：$u_i: S_1 \times \cdots \times S_n \to \mathbb{R}$，每个策略组合下 $i$ 的收益
- **信息结构（Information Structure）**：各参与者知道什么？不知道什么？信息是否对称？

关键问题：是否存在隐藏信息（不完全信息博弈）？行动是否有序列（序列博弈）？参与者能否通信？

#### 生活模式 / Life Mode

回答以下问题来识别博弈要素：
- **谁在影响你的决策？** 列出所有相关方——他们不是旁观者，他们的选择会影响你的结果
- **他们的选择会影响你的结果吗？** 如果不会，这不是博弈，只需优化
- **你了解他们的动机吗？** 各方真正在意什么？表面说法 vs 实际利益
- **各方有哪些可选行动？** 不需要列完所有选项，但要覆盖关键可能性

#### 共通要点 / Common Key Points

核心是识别"互动结构"——谁的选择影响谁的结果。遗漏关键参与者是最常见的错误。

---

### 第二步：构建支付矩阵/函数 / Construct Payoff Matrix or Functions

#### 科研模式 / Research Mode

- **2人博弈**：用支付矩阵（表格）表示，行参与者和列参与者的策略组合对应单元格 $(u_1, u_2)$
- **n人博弈**：用效用函数 $u_i(s_1, \ldots, s_n)$ 表示，每个参与者的收益依赖于所有人的策略
- 验证完备性：是否遗漏了关键参与者或策略？支付是否准确反映偏好？

关键问题：支付是零和的还是一般和的？是否存在外部性（一人的策略影响非参与者）？

#### 生活模式 / Life Mode

梳理各方的得失：
- **各方的得失是什么？** 不同选择下每个人会得到什么、失去什么？得失不限于金钱——时间、情感、声誉都是支付
- **不同选择下每个人会得到什么、失去什么？** 尝试画出简单的"如果A选X、B选Y，各方的结果"
- **你是否完整考虑了所有人的利益？** 只考虑自己的支付而忽略他人的，会导致错误的策略预判

#### 共通要点 / Common Key Points

支付（payoff）是博弈分析的根基。如果支付评估不准，后续所有分析都会偏。务必考虑所有参与者的完整利益维度。

---

### 第三步：寻找占优策略 / Find Dominant Strategies

#### 科研模式 / Research Mode

- **严格占优策略（Strictly Dominant）**：$s_i^*$ 使得 $u_i(s_i^*, s_{-i}) > u_i(s_i, s_{-i})$ 对所有 $s_i \neq s_i^*$ 和所有 $s_{-i}$ 成立
- **弱占优策略（Weakly Dominant）**：$u_i(s_i^*, s_{-i}) \geq u_i(s_i, s_{-i})$ 对所有 $s_{-i}$ 成立，且至少一个 $s_{-i}$ 严格不等
- **迭代消去劣策略（Iterated Elimination of Dominated Strategies）**：依次删去每个参与者的劣策略，缩小策略空间

若存在占优策略均衡，这是最强形式的均衡——无人有任何偏离动机，不论理性程度。

#### 生活模式 / Life Mode

问自己：
- **有没有一个选择，无论对方怎么做都是你的最佳？** 如果有，直接选它——不需要猜测对方意图
- 如果没有占优策略，你的最优选择取决于对方怎么做——这时需要进入下一步分析
- 排除明显不好的选项：有些选择在任何情况下都不如其他选择，先删掉它们简化决策

#### 共通要点 / Common Key Points

占优策略是最强的结论——一旦找到，问题就解决了。如果没有占优策略，才需要更复杂的均衡分析。

---

### 第四步：计算纳什均衡 / Compute Nash Equilibria

#### 科研模式 / Research Mode

- **纯策略纳什均衡**：通过最优响应分析（best response analysis）——对每个 $s_{-i}$，找出 $i$ 的最优响应 $BR_i(s_{-i})$，交叉点即为均衡
- **混合策略纳什均衡**：计算使其他参与者无差异的概率分布——参与者 $i$ 的混合策略 $\sigma_i$ 使得参与者 $j$ 的所有纯策略期望支付相等

$$u_j(s_j, \sigma^*_{-j}) = u_j(s_j', \sigma^*_{-j}) \quad \text{for all } s_j, s_j' \in S_j$$

- **多重均衡**：帕累托排序——比较各均衡下所有参与者的支付，标注帕累托最优均衡与帕累托劣均衡

#### 生活模式 / Life Mode

寻找稳定状态：
- **是否存在一个稳定状态——大家都不愿意单方面改变策略？** 这就是最可能的结果
- 如果存在这样的稳定状态，那就是最可能的结局——每个人都在做自己能做的最好选择
- **如果有多个稳定状态，哪个更可能发生？** 多重均衡意味着结果不确定——需要看历史惯例、沟通协调或焦点效应（salience）

#### 共通要点 / Common Key Points

纳什均衡是博弈论的核心预测工具——它告诉你"在理性假设下，最可能的结果是什么"。多重均衡是常态，需要额外信息选择。

---

### 第五步：分析博弈类型 / Analyze Game Type

#### 科研模式 / Research Mode

- **零和博弈**：minimax 定理 $\max_x \min_y f(x,y) = \min_y \max_x f(x,y)$，最优策略是保守的——在最坏情况下最大化收益
- **序列博弈**：逆向归纳法（backward induction）与子博弈完美均衡（subgame perfect equilibrium）——每一步都是后续子博弈的纳什均衡
- **合作博弈**：联盟形成（coalition formation）与 Shapley 值（Shapley Value）——按边际贡献分配联盟收益

$$\phi_i(v) = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|!(n - |S| - 1)!}{n!} [v(S \cup \{i\}) - v(S)]$$

#### 生活模式 / Life Mode

判断互动类型，选择对应策略：
- **如果是竞争关系（一方得另一方必失）**：保守策略——做最坏情况下最好的选择。不要指望对方合作，先确保自己不会太惨
- **如果是合作关系**：寻找双赢点——双方都能改善的选项。关注如何分配合作收益，而非如何争夺
- **如果是谈判**：识别双方的底线和共识区域——谈判的核心是找到双方都能接受的区域，而非各自的最优

#### 共通要点 / Common Key Points

博弈类型决定了分析方法——零和用保守策略，序列用逆向推理，合作用联盟分析。误判类型会导致方法错用。

---

### 第六步：检查均衡稳定性 / Check Equilibrium Stability

#### 科研模式 / Research Mode

- **颤抖手完美（Trembling-Hand Perfect Equilibrium）**：均衡在微小失误下仍然稳定——排除依赖"对手绝不犯错"的均衡
- **演化稳定性（Evolutionarily Stable Strategy, ESS）**：在重复互动中，均衡策略能否抵御入侵策略——生物学与经济学交叉
- **偏离均衡路径的激励（Off-Equilibrium Path Incentives）**：序列博弈中，参与者是否有动机在非均衡节点上遵守承诺

关键问题：均衡是唯一的还是多重的？多重均衡中哪个更可能被选择？均衡是否对微小扰动鲁棒？

#### 生活模式 / Life Mode

评估稳定状态的可靠性：
- **这个稳定状态靠谱吗？** 如果有人犯小错（误解你的意图、操作失误），局面会崩吗？
- **在重复互动中，这个状态能持续吗？** 单次博弈的结论在长期关系中可能完全不同——合作可以在重复互动中涌现
- 如果稳定状态对小错误不鲁棒，实际结局可能偏离理论预测——需要考虑容错方案

#### 共通要点 / Common Key Points

稳定的均衡才是可信的预测。不稳定的均衡可能在现实中永远不会出现。

---

### 第七步：设计机制与改进 / Design Mechanisms and Improve

#### 科研模式 / Research Mode

如果不存在好的纳什均衡，重新设计博弈：
- **改变支付结构**：引入惩罚或奖励，使均衡转向更优结果
- **增加规则**：引入可强制执行的协议、惩罚偏离者
- **引入通信与声誉**：重复博弈中声誉机制可维持合作
- **Vickrey 拍卖（第二价格拍卖）**：报真实估值是占优策略——机制设计的经典范例
- **机制设计（Mechanism Design）**：在满足激励相容性（incentive compatibility）和效率（efficiency）的前提下设计规则

$$\text{Mechanism Design: } \max \text{ social welfare} \quad \text{s.t.} \quad \text{incentive compatibility + individual rationality}$$

显示原理（Revelation Principle）：任何贝叶斯博弈的均衡都可由一个直接机制（direct mechanism）实现——参与者如实报告类型是均衡。

#### 生活模式 / Life Mode

改变规则让好结局更自然：
- **如果当前规则下大家都陷入不好的结局（如囚徒困境），能否改变规则让好结局成为自然选择？** 这是机制设计的核心思想
- **引入承诺**：先做出不可反悔的承诺，改变他人的预期和选择（如预先公开你的底线）
- **声誉机制**：在长期互动中，好声誉本身就是资产——维护声誉可以维持合作
- **改变激励结构**：让"做好事"变得自然——调整奖惩让每个人的最优选择恰好也是整体最优

#### 共通要点 / Common Key Points

机制设计是博弈论最实用的分支——与其抱怨人不合作，不如改变规则让合作成为自利选择。

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|-------------|-------------------------------|---------------------------|
| 假设他人像自己一样思考 `[科研/通用]` | 他人可能有不同的支付函数或理性水平，$u_i \neq u_j$ | 明确各参与者的支付函数与信念 |
| 忽略混合策略 `[科研]` | 纯策略均衡可能不存在，但混合策略均衡总存在（Nash, 1950） | 检查是否需要混合策略分析 |
| 混淆纳什均衡与帕累托最优 `[科研/通用]` | 纳什均衡可以是帕累托劣的（囚徒困境），两者独立 | 分别标注均衡性与效率性 |
| 忽略信息不对称 `[科研]` | 不完全信息博弈的均衡与完全信息博弈截然不同 | 区分贝叶斯博弈与完全信息博弈 |
| 过度简化支付结构 `[科研/通用]` | 遗漏关键支付维度使均衡分析失真 | 系统检查所有参与者的完整支付 |
| 忽略重复互动动态 `[科研/通用]` | 单次博弈的均衡在重复博弈中可能改变（folk theorem） | 分析重复博弈的子博弈完美均衡 |
| 假设别人和你想法一样 `[生活]` | 不同人有不同动机、偏好和信息，不能用自己的思维代入他人 | 主动了解他人的真实利益和约束 |
| 忽略情绪和非理性因素 `[生活]` | 博弈论假设理性，但现实中愤怒、信任、面子等深刻影响选择 | 识别关键情绪因素，修正支付评估 |
| 只考虑自己的最优不考虑他人的反应 `[生活]` | 单方优化不是博弈分析——你的最优取决于他人的选择 | 先想"如果我这么做，对方会怎么反应" |

## 操作规程 / Operating Procedure

当本 skill 被触发时，先判断模式：

> **模式选择 / Mode Selection**
> - 若问题涉及数学建模、论文分析、算法设计、均衡计算 → **科研模式**
> - 若问题涉及日常决策、人际互动、生活规划、冲突协调 → **生活模式**
> - 若问题同时涉及两者 → **双模式并行，生活模式优先输出，科研模式作为补充验证**

### 科研模式输出格式 / Research Mode Output Format

1. **[参与者]:[列表]**：明确所有决策者及其类型（理性/有限理性/未知）
2. **[策略集]:[描述]**：列出每个参与者的可选策略，标注是否为有限/无限策略集
3. **[支付矩阵]:[关键值]**：写出核心策略组合的支付值 $(u_1, u_2, \ldots)$ 或支付函数形式
4. **[均衡]:[纳什均衡策略/混合概率]**：计算所有纳什均衡（纯策略和混合策略），标注多重均衡
5. **[博弈类型]:[零和/非零和/序列/合作]**：分类博弈结构，选择对应分析方法
6. **[稳定性]:[分析]**：检查均衡的颤抖手完美性、演化稳定性、偏离均衡路径激励
7. **[机制建议]:[改进]**：若均衡不理想，提出机制设计建议——改变支付、增加规则、引入声誉等

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

### 生活模式输出格式 / Life Mode Output Format

1. **[参与者]:[谁在影响你的决策]** — 列出所有相关方及其可能的行动
2. **[得失]:[各方的利益]** — 不同选择下每个人的得失
3. **[稳定状态]:[分析]** — 是否存在没人愿意单方面改变的策略组合？标注多重稳定状态
4. **[互动类型]:[竞争/合作/谈判]** — 分类互动结构，选择对应策略
5. **[稳定性]:[评估]** — 这个稳定状态是否对小错误鲁棒？能否在重复互动中持续？
6. **[规则建议]:[改进]** — 如果当前规则下结局不理想，如何改变规则让好结局更自然

**输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系

- **优化思想**：Nash均衡是互相优化——每个参与者在他人的策略约束下优化自己的支付，均衡是所有优化问题的共同解
- **概率与统计**：混合策略以概率分布选择行动，贝叶斯博弈用概率处理类型不确定性，均衡计算依赖期望支付
- **信息论思想**：信息不对称与信号传递——Spence 信号博弈模型中，信息结构直接影响均衡的存在与性质
- **因果推断思想**：因果与博弈互动——参与者的策略选择因果影响他人收益，战略互动中的因果链是双向的
- **算法思想**：博弈算法与均衡计算——纳什均衡的计算复杂度（PPAD-complete），Lemke-Howson 算法，演化博弈的模拟算法