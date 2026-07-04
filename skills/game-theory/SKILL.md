---
name: game-theory
description: |
  触发：当策略取决于他人选择、需计算纳什均衡、分析零和/非零和博弈、做机制设计；或为多智能体系统、对抗训练、路由博弈设计策略时调用。
  English: Trigger when optimal strategy depends on others' choices, needing Nash equilibrium computation, zero-sum/non-zero-sum analysis, mechanism design; or designing strategies for multi-agent systems, adversarial training, routing games.
---

> **语言路由**：若用户消息为英文，请读取并遵循同目录下的 `SKILL.en.md`，按其操作规程以英文输出；中文消息则继续使用本文件。

# 🎯 博弈论思想 / Game Theory

> "你的最优选择取决于他人的选择——思考不仅要深入，还要互动。"
> "Your optimal choice depends on others' choices — thinking must be interactive, not just deep."
>
> —— 博弈论、决策论、机制设计 / Game Theory, Decision Theory, Mechanism Design

## 核心原则 / Core Principle

**战略互动——你的最优行动取决于他人做什么，而他人的最优行动取决于你做什么。纳什均衡：无人能从单方面偏离中获益的策略组合。**

**Strategic interaction — your best action depends on what others do, and theirs depend on what you do. Nash equilibrium: strategy profile where no player benefits from unilateral deviation.**

关键概念：**支付矩阵（Payoff Matrix）**、**占优策略（Dominant Strategy）**、**混合策略（Mixed Strategy）**、**帕累托最优性（Pareto Optimality）**。分类维度：合作 vs 非合作、零和 vs 一般和、同时 vs 序列。

> **数学形式化 / Mathematical Formalization**
>
> 形式化定义：n 个参与者，每人有策略集 $S_i$ 和支付函数 $u_i: S_1 \times \cdots \times S_n \to \mathbb{R}$。
>
> 纳什均衡：策略组合 $s^* = (s_1^*, \ldots, s_n^*)$ 满足 $u_i(s^*) \geq u_i(s_i, s^*_{-i})$ 对所有 $s_i \in S_i$、所有 $i$ 成立，其中 $s^*_{-i}$ 为除 $i$ 外所有人的策略。混合策略纳什均衡：概率分布 $\sigma^*$ 使 $u_i(\sigma^*) \geq u_i(s_i, \sigma^*_{-i})$。
>
> 占优策略：严格 $u_i(s_i^*, s_{-i}) > u_i(s_i, s_{-i})$；弱占优 $\geq$ 且至少一处严格。
>
> 零和 minimax：$\max_x \min_y f(x,y) = \min_y \max_x f(x,y)$。

## GPU 友好性 / GPU-Friendliness（横切检查）

博弈求解映射 GPU 的能力差异极大，过 `../../references/gpu-friendly-math.md` 八维门：

- **矩阵博弈 / 双人零和（minimax）**：等价于线性规划（LP），支付矩阵运算可 GEMM 化、可批量并行——**友好**。
- **混合策略均衡求解**：支撑集上的线性方程组/无差异方程，小规模可批量解；规模大时注意稀疏性与条件数。
- **大规模多智能体均衡精确求解**：n 人纳什均衡 PPAD-complete，一般情形**不可算**→ **反模式**，改用近似/学习方法（fictitious play、虚拟自博、多智能体 RL、NFSP）。
- **演化/重复博弈模拟**：群体与策略批量更新可并行；注意 agent 间通信与同步开销。

八维最低判定（正式术语）：**张量化**看玩家/策略/回合是否能批量展开；**GEMM 可映射**看支付矩阵、minimax、LP/线性方程是否落矩阵运算；**复杂度**标注 Nash/机制求解的 PPAD/组合爆炸风险；**显存与 KV-Cache**看策略-状态笛卡尔积是否可压缩；**低精度稳定**看均衡求解、LP、soft best-response 是否条件数可控；**并行与通信**看多智能体 rollout 的同步成本；**稀疏结构**看交互图是否结构化；**算子融合**看收益、mask、best-response 更新能否融合。

> 配合 `../../references/books/optimization-ml.md`（对偶/minimax、博弈学习算法）与 `../../references/books/matrix-analysis.md`（矩阵博弈、线性方程组）。

## 不适用场景 / When NOT to Use

- **单人决策问题，与他人无互动**——优化思想更适用，无需考虑他人策略响应。
- **纯合作问题，无利益冲突**——参与者目标完全一致，无需战略分析。
- **确定性问题，无战略不确定性**——结果由自身行动唯一决定，不涉及他人反应。
- **纯粹运气决定的结果，各方无策略选择**——无策略集可分析，博弈论不适用。

## 何时使用 / When to Use

- 多个决策者相互影响，各自策略影响他人收益；最佳策略取决于他人响应，需预判他人行动。
- 需设计激励机制，使自利行为导向社会最优结果；预测给定规则下的均衡稳定状态。
- 分析竞争市场中的定价、进入、退出；谈判/讨价还价中的利益分配与威胁点。
- **为多智能体系统、对抗训练（GAN/鲁棒学习）、路由博弈设计策略与均衡目标**。

## 方法流程 / Method

### 第一步：识别参与者与策略
定义博弈基本要素：参与者 $N=\{1,\ldots,n\}$；策略集 $S_i$；支付函数 $u_i: S_1\times\cdots\times S_n\to\mathbb{R}$；信息结构（是否对称？是否不完全信息？行动是否序列？能否通信？）。核心是识别"互动结构"——谁的选择影响谁的结果，遗漏关键参与者是最常见错误。

### 第二步：分析博弈类型
先判定零和/一般和、同时/序列、合作/非合作、完全信息/不完全信息。类型决定方法：零和用 minimax/LP；序列博弈用逆向归纳与子博弈完美均衡；合作博弈用 Shapley 值按边际贡献分配：
$$\phi_i(v)=\sum_{S\subseteq N\setminus\{i\}}\frac{|S|!(n-|S|-1)!}{n!}[v(S\cup\{i\})-v(S)]$$
误判类型会直接导致均衡概念和求解方法错用。

### 第三步：构建支付矩阵/函数
2 人博弈用支付矩阵，单元格 $(u_1,u_2)$；n 人博弈用 $u_i(s_1,\ldots,s_n)$。验证完备性：是否遗漏参与者或策略？支付是否准确反映偏好？是否存在外部性？支付是分析根基，评估不准则后续全偏。

### 第四步：寻找占优策略
严格占优 $u_i(s_i^*,s_{-i}) > u_i(s_i,s_{-i})$ 对所有 $s_i\neq s_i^*$、所有 $s_{-i}$；弱占优 $\geq$ 且至少一处严格；**迭代消去劣策略**依次删去劣策略缩小空间。存在占优策略均衡是最强结论——无人有任何偏离动机；否则进入均衡分析。

### 第五步：计算均衡
按第二步的博弈类型选方法。纯策略纳什：对每个 $s_{-i}$ 找最优响应 $BR_i(s_{-i})$，交叉点即均衡。混合策略：求使他人无差异的概率分布 $u_j(s_j,\sigma^*_{-j})=u_j(s_j',\sigma^*_{-j})$ 对所有 $s_j,s_j'\in S_j$。零和矩阵博弈可走 minimax $\max_x\min_y f=\min_y\max_x f$；序列博弈用逆向归纳；合作博弈输出分配方案而非普通纳什。多重均衡做帕累托排序，标注最优与劣均衡。

### 第六步：检查均衡稳定性
颤抖手完美（微小失误下仍稳定，排除依赖"对手绝不犯错"的均衡）；演化稳定策略 ESS（重复互动中抵御入侵）；偏离均衡路径激励（序列博弈中是否有动机遵守承诺）。追问：均衡唯一还是多重？对微小扰动是否鲁棒？稳定均衡才是可信预测。

### 第七步：设计机制与改进
若不存在好的均衡，重新设计博弈：改变支付结构（奖惩）、增加可执行规则、引入通信与声誉、Vickrey 拍卖（报真实估值为占优策略）。机制设计形式化：
$$\max\ \text{social welfare}\quad\text{s.t.}\quad\text{incentive compatibility + individual rationality}$$
显示原理：任何贝叶斯博弈均衡都可由直接机制实现——如实报告类型即均衡。机制设计是最实用分支——与其抱怨人不合作，不如改变规则让合作成为自利选择。

## 常见错误 / Common Errors

| 错误 / Error | 批评 / Critique | 正确做法 / Correct Approach |
|---|---|---|
| 假设他人像自己一样思考 | 他人支付函数/理性水平不同，$u_i\neq u_j$ | 明确各参与者支付函数与信念 |
| 忽略混合策略 | 纯策略均衡可能不存在，混合均衡总存在（Nash, 1950） | 检查是否需混合策略分析 |
| 混淆纳什均衡与帕累托最优 | 纳什均衡可帕累托劣（囚徒困境），两者独立 | 分别标注均衡性与效率性 |
| 忽略信息不对称 | 不完全信息均衡与完全信息截然不同 | 区分贝叶斯博弈与完全信息博弈 |
| 过度简化支付结构 | 遗漏关键支付维度使均衡失真 | 系统检查所有参与者完整支付 |
| 忽略重复互动动态 | 单次均衡在重复博弈中可能改变（folk theorem） | 分析子博弈完美均衡 |
| 大规模均衡精确求解不可算 | n 人纳什均衡 PPAD-complete，精确解不可行 | 过 GPU 八维门，改用近似/学习（虚拟自博、MARL） |

## 操作规程 / Operating Procedure

当本 skill 被触发时，输出必须包含：

1. **[参与者]**：所有决策者及其类型（理性/有限理性/未知）。
2. **[策略集]**：每个参与者的可选策略，标注有限/无限。
3. **[支付矩阵]**：核心策略组合的支付值 $(u_1,u_2,\ldots)$ 或支付函数形式。
4. **[博弈类型]**：零和/非零和/序列/合作，对应分析方法。
5. **[均衡]**：所有适用均衡（纯策略、混合策略、子博弈完美、合作分配等），标注多重均衡。
6. **[稳定性]**：颤抖手完美性、演化稳定性、偏离均衡路径激励。
7. **[机制建议]**：若均衡不理想，提出机制设计建议（改变支付、增加规则、引入声誉等）。
8. **[GPU 可行性]**：矩阵博弈/minimax→LP 可 GEMM；大规模多智能体均衡是否不可算→近似/学习方法，过八维门。

**输出不得只给分析而无结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **优化思想**：纳什均衡是互相优化——每人在他人策略约束下优化自己支付，均衡是所有优化问题的共同解。
- **概率与统计**：混合策略以概率分布选行动，贝叶斯博弈用概率处理类型不确定性，均衡依赖期望支付。
- **信息论思想**：信息不对称与信号传递——Spence 信号博弈中信息结构直接影响均衡存在与性质。
- **因果推断思想**：策略选择因果影响他人收益，战略互动中的因果链是双向的。
- **算法思想**：纳什均衡计算复杂度（PPAD-complete）、Lemke-Howson 算法、演化博弈模拟。
- **现代数学激活**：`../../references/books/optimization-ml.md`（对偶/minimax、博弈学习算法）、`../../references/books/matrix-analysis.md`（矩阵博弈、支付矩阵的线性代数结构）。
