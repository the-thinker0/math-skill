---
name: game-theory
description: |
  触发：当涉及多方互动决策、最优策略取决于他人选择、或需要设计激励机制时调用。
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

形式化定义：n 个参与者，每人有策略集 $S_i$ 和支付函数 $u_i: S_1 \times \cdots \times S_n \to \mathbb{R}$。

纳什均衡：策略组合 $s^* = (s_1^*, \ldots, s_n^*)$ 满足

$$u_i(s^*) \geq u_i(s_i, s^*_{-i}) \quad \text{for all } s_i \in S_i, \text{ all } i$$

其中 $s^*_{-i} = (s_1^*, \ldots, s_{i-1}^*, s_{i+1}^*, \ldots, s_n^*)$ 表示除参与者 $i$ 外所有其他人的策略。混合策略纳什均衡：概率分布 $\sigma^*$ 使得

$$u_i(\sigma^*) \geq u_i(s_i, \sigma^*_{-i}) \quad \text{for all } s_i \in S_i, \text{ all } i$$

## 不适用场景 / When NOT to Use

- **单人决策问题，与他人无互动**——优化思想更适用，无需考虑他人策略响应
- **纯合作问题，无利益冲突**——参与者目标完全一致，无需战略分析
- **确定性问题，无战略不确定性**——结果由自身行动唯一决定，不涉及他人反应

- **Single-player decision with no interaction with others** — optimization suffices, no need to consider strategic response
- **Purely cooperative problem with no conflict** — all players share identical goals, strategic analysis unnecessary
- **Deterministic problem with no strategic uncertainty** — outcome determined solely by own actions, no others' reactions involved

## 何时使用 / When to Use

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

## 方法流程 / Method

### 第一步：识别参与者与策略 / Identify Players and Strategies

定义博弈的基本要素：
- **参与者（Players）**：$N = \{1, 2, \ldots, n\}$，谁在做决策？
- **策略集（Strategy Sets）**：$S_i$ 为参与者 $i$ 的所有可选行动
- **支付函数（Payoff Functions）**：$u_i: S_1 \times \cdots \times S_n \to \mathbb{R}$，每个策略组合下 $i$ 的收益
- **信息结构（Information Structure）**：各参与者知道什么？不知道什么？信息是否对称？

关键问题：是否存在隐藏信息（不完全信息博弈）？行动是否有序列（序列博弈）？参与者能否通信？

### 第二步：构建支付矩阵/函数 / Construct Payoff Matrix or Functions

- **2人博弈**：用支付矩阵（表格）表示，行参与者和列参与者的策略组合对应单元格 $(u_1, u_2)$
- **n人博弈**：用效用函数 $u_i(s_1, \ldots, s_n)$ 表示，每个参与者的收益依赖于所有人的策略
- 验证完备性：是否遗漏了关键参与者或策略？支付是否准确反映偏好？

关键问题：支付是零和的还是一般和的？是否存在外部性（一人的策略影响非参与者）？

### 第三步：寻找占优策略 / Find Dominant Strategies

- **严格占优策略（Strictly Dominant）**：$s_i^*$ 使得 $u_i(s_i^*, s_{-i}) > u_i(s_i, s_{-i})$ 对所有 $s_i \neq s_i^*$ 和所有 $s_{-i}$ 成立
- **弱占优策略（Weakly Dominant）**：$u_i(s_i^*, s_{-i}) \geq u_i(s_i, s_{-i})$ 对所有 $s_{-i}$ 成立，且至少一个 $s_{-i}$ 严格不等
- **迭代消去劣策略（Iterated Elimination of Dominated Strategies）**：依次删去每个参与者的劣策略，缩小策略空间

若存在占优策略均衡，这是最强形式的均衡——无人有任何偏离动机，不论理性程度。

### 第四步：计算纳什均衡 / Compute Nash Equilibria

- **纯策略纳什均衡**：通过最优响应分析（best response analysis）——对每个 $s_{-i}$，找出 $i$ 的最优响应 $BR_i(s_{-i})$，交叉点即为均衡
- **混合策略纳什均衡**：计算使其他参与者无差异的概率分布——参与者 $i$ 的混合策略 $\sigma_i$ 使得参与者 $j$ 的所有纯策略期望支付相等

$$u_j(s_j, \sigma^*_{-j}) = u_j(s_j', \sigma^*_{-j}) \quad \text{for all } s_j, s_j' \in S_j$$

- **多重均衡**：帕累托排序——比较各均衡下所有参与者的支付，标注帕累托最优均衡与帕累托劣均衡

### 第五步：分析博弈类型 / Analyze Game Type

- **零和博弈**：minimax 定理 $\max_x \min_y f(x,y) = \min_y \max_x f(x,y)$，最优策略是保守的——在最坏情况下最大化收益
- **序列博弈**：逆向归纳法（backward induction）与子博弈完美均衡（subgame perfect equilibrium）——每一步都是后续子博弈的纳什均衡
- **合作博弈**：联盟形成（coalition formation）与 Shapley 值（Shapley Value）——按边际贡献分配联盟收益

$$\phi_i(v) = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|!(n - |S| - 1)!}{n!} [v(S \cup \{i\}) - v(S)]$$

### 第六步：检查均衡稳定性 / Check Equilibrium Stability

- **颤抖手完美（Trembling-Hand Perfect Equilibrium）**：均衡在微小失误下仍然稳定——排除依赖"对手绝不犯错"的均衡
- **演化稳定性（Evolutionarily Stable Strategy, ESS）**：在重复互动中，均衡策略能否抵御入侵策略——生物学与经济学交叉
- **偏离均衡路径的激励（Off-Equilibrium Path Incentives）**：序列博弈中，参与者是否有动机在非均衡节点上遵守承诺

关键问题：均衡是唯一的还是多重的？多重均衡中哪个更可能被选择？均衡是否对微小扰动鲁棒？

### 第七步：设计机制与改进 / Design Mechanisms and Improve

如果不存在好的纳什均衡，重新设计博弈：
- **改变支付结构**：引入惩罚或奖励，使均衡转向更优结果
- **增加规则**：引入可强制执行的协议、惩罚偏离者
- **引入通信与声誉**：重复博弈中声誉机制可维持合作
- **Vickrey 拍卖（第二价格拍卖）**：报真实估值是占优策略——机制设计的经典范例
- **机制设计（Mechanism Design）**：在满足激励相容性（incentive compatibility）和效率（efficiency）的前提下设计规则

$$\text{Mechanism Design: } \max \text{ social welfare} \quad \text{s.t.} \quad \text{incentive compatibility + individual rationality}$$

显示原理（Revelation Principle）：任何贝叶斯博弈的均衡都可由一个直接机制（direct mechanism）实现——参与者如实报告类型是均衡。

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|-------------|-------------------------------|---------------------------|
| 假设他人像自己一样思考 | 他人可能有不同的支付函数或理性水平，$u_i \neq u_j$ | 明确各参与者的支付函数与信念 |
| 忽略混合策略 | 纯策略均衡可能不存在，但混合策略均衡总存在（Nash, 1950） | 检查是否需要混合策略分析 |
| 混淆纳什均衡与帕累托最优 | 纳什均衡可以是帕累托劣的（囚徒困境），两者独立 | 分别标注均衡性与效率性 |
| 忽略信息不对称 | 不完全信息博弈的均衡与完全信息博弈截然不同 | 区分贝叶斯博弈与完全信息博弈 |
| 过度简化支付结构 | 遗漏关键支付维度使均衡分析失真 | 系统检查所有参与者的完整支付 |
| 忽略重复互动动态 | 单次博弈的均衡在重复博弈中可能改变（folk theorem） | 分析重复博弈的子博弈完美均衡 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：

1. **[参与者]:[列表]**：明确所有决策者及其类型（理性/有限理性/未知）
2. **[策略集]:[描述]**：列出每个参与者的可选策略，标注是否为有限/无限策略集
3. **[支付矩阵]:[关键值]**：写出核心策略组合的支付值 $(u_1, u_2, \ldots)$ 或支付函数形式
4. **[均衡]:[纳什均衡策略/混合概率]**：计算所有纳什均衡（纯策略和混合策略），标注多重均衡
5. **[博弈类型]:[零和/非零和/序列/合作]**：分类博弈结构，选择对应分析方法
6. **[稳定性]:[分析]**：检查均衡的颤抖手完美性、演化稳定性、偏离均衡路径激励
7. **[机制建议]:[改进]**：若均衡不理想，提出机制设计建议——改变支付、增加规则、引入声誉等

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系

- **优化思想**：Nash均衡是互相优化——每个参与者在他人的策略约束下优化自己的支付，均衡是所有优化问题的共同解
- **概率与统计**：混合策略以概率分布选择行动，贝叶斯博弈用概率处理类型不确定性，均衡计算依赖期望支付
- **信息论思想**：信息不对称与信号传递——Spence 信号博弈模型中，信息结构直接影响均衡的存在与性质
- **因果推断思想**：因果与博弈互动——参与者的策略选择因果影响他人收益，战略互动中的因果链是双向的
- **算法思想**：博弈算法与均衡计算——纳什均衡的计算复杂度（PPAD-complete），Lemke-Howson 算法，演化博弈的模拟算法