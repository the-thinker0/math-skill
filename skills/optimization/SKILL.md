---
name: optimization
description: |
  触发：当问题涉及资源分配、取舍、最大化/最小化目标，或在限制条件下做决策，或需要判断问题的凸性、使用拉格朗日方法、分析对偶结构时调用。
  Trigger when a problem involves resource allocation, trade-offs, maximizing/minimizing objectives, decision-making under constraints, or when convexity analysis, Lagrangian methods, or duality structures are relevant.
---

# ⚖️ 优化思想

> "在最一般的约束条件下，寻找目标函数的极值——凸性决定难度，KKT 给出必要条件，对偶揭示结构。"
> "Under the most general constraints, find extrema of the objective — convexity determines difficulty, KKT gives necessity, duality reveals structure."
>
> —— 最优化理论与运筹学
> —— Optimization Theory & Operations Research

## 核心原则 / Core Principle

**任何决策问题都可以表述为数学优化问题：在约束条件下最大化（或最小化）某个目标函数。优化的本质不是追求'最好'，而是在约束下追求'可行中的最好'。**

**Any decision problem can be formulated as a mathematical optimization problem: maximizing (or minimizing) an objective function subject to constraints. The essence of optimization is not pursuing 'the best' in the abstract, but pursuing 'the best among the feasible' under constraints.**

> 人生就是一场最优化——目标函数是你追求的价值，初始点是你的起点，约束是时间、健康、规则。局部最优是当前环境中看似最好的选择，全局最优或许在另一个领域。探索与利用的权衡是人生的根本张力。重要的不是找到传说中的全局最优，而是在每一步迭代中保持方向大致正确、接受噪声与约束、允许目标函数随阅历增长而优雅地演变。过程即意义，优化本身就是生活。

> Life itself is an optimization — the objective is what you value, the starting point is where you begin, constraints are time, health, and rules. Local optima are the best-looking choices in your current environment; the global optimum might be in a completely different field. The explore-exploit tradeoff is life's fundamental tension. The point is not finding a legendary global optimum, but keeping the direction roughly right at each iteration, accepting noise and constraints, and letting the objective function evolve gracefully as experience grows. The process is the meaning; optimization itself is life.

一般优化问题的数学形式：

$$\min_{x \in \mathbb{R}^n} f(x) \quad \text{s.t.} \quad g_i(x) \leq 0, \; i=1,\dots,m; \quad h_j(x) = 0, \; j=1,\dots,p$$

其中 $f(x)$ 为目标函数，$g_i(x)$ 为不等式约束，$h_j(x)$ 为等式约束。

拉格朗日函数：

$$L(x, \lambda, \mu) = f(x) + \sum_{i=1}^{m} \lambda_i g_i(x) + \sum_{j=1}^{p} \mu_j h_j(x)$$

KKT 条件（核心必要条件）：若 $x^*$ 为最优解且约束满足某种正则性条件（如 Slater 条件），则存在 $\lambda^* \geq 0$, $\mu^*$ 使得：

1. **驻点条件**：$\nabla_x L(x^*, \lambda^*, \mu^*) = 0$
2. **原始可行性**：$g_i(x^*) \leq 0$, $h_j(x^*) = 0$
3. **对偶可行性**：$\lambda_i^* \geq 0$
4. **互补松弛性**：$\lambda_i^* g_i(x^*) = 0$

凸性定义与关键性质：若 $f$ 和所有 $g_i$ 为凸函数，所有 $h_j$ 为线性函数，则问题为凸优化。凸优化中，**KKT 条件变为充分条件**，且局部最优 = 全局最优。

优化的三个核心要素：
- **目标函数（Objective Function）**：你要最大化或最小化的量
- **约束条件（Constraints）**：不可违反的限制
- **可行域（Feasible Region）**：满足所有约束的解的集合

## 不适用场景 / When NOT to Use

- **没有明确的评价标准**（不知道什么是"好"）——先定义目标函数再谈优化
- **纯粹的执行性任务**（如"把这段代码格式化"）——没有优化空间
- **用户已经确定了方案**——优化已由用户完成，无需重复
- **问题本质是定性判断而非定量极值**——应先建模再优化

- **No clear evaluation criterion** (don't know what "good" means) — define the objective first
- **Purely executional tasks** (e.g., "format this code") — no room for optimization
- **User has already decided on a solution** — optimization already done by user
- **The problem is qualitative judgment, not quantitative extremum** — model first, then optimize

## 何时使用 / When to Use

- 需要在有限资源（时间、精力、金钱）之间做分配
- 面临多目标取舍（如质量 vs 速度、短期 vs 长期）
- 不确定当前策略是否最优，想要系统分析
- 需要在约束条件下做出理性决策
- 科研项目的时间规划或实验设计优化
- 需要判断问题是否为凸优化以决定求解难度

- Need to allocate limited resources (time, effort, money)
- Facing multi-objective trade-offs (e.g., quality vs speed, short-term vs long-term)
- Unsure whether current strategy is optimal, want systematic analysis
- Need rational decision-making under constraints
- Research project time planning or experimental design optimization
- Need to determine if the problem is convex to decide solving difficulty

## 方法流程 / Method

### 第一步：定义目标函数 / Define the Objective Function

明确你要最大化或最小化什么。这是最重要的一步——目标函数不清晰，优化没有方向。

**关键问题**：
- 单一目标还是多目标？
- 目标是可量化的吗？如果不能，能否找到代理变量？
- 目标是时间相关的吗？（静态优化 vs 动态优化）
- **$f$ 是否为凸函数？** 若凸，则局部最优即全局最优；若非凸，需警惕局部极值。

### 第二步：列出约束条件 / List the Constraints

区分**硬约束**与**软约束**，同时对约束进行数学分类：

- **硬约束 [硬]**：物理限制、硬性 deadline、预算上限
- **软约束 [软]**：个人偏好、质量下限、舒适区
- **不等式约束 $g_i(x) \leq 0$**：定义可行域边界，是优化中最常见的约束类型
- **等式约束 $h_j(x) = 0$**：减少可行域维度，通常对应物理守恒或精确要求
- **线性约束 vs 非线性约束**：线性约束保持可行域为凸多面体；非线性约束可能使可行域非凸

### 第三步：类型分类 / Classify the Problem Type

根据目标函数和约束的结构，判定问题类别：

| 类型 | 目标 | 约束 | 核心性质 | 典型方法 |
|------|------|------|----------|----------|
| LP（线性规划） | 线性 | 线性不等式 | 全局最优在顶点 | 单纯形法 |
| QP（二次规划） | 二次 | 线性 | 正定 QP 为凸 | 内点法 |
| 凸优化 | 凸 | 凸不等式 + 线性等式 | 局部=全局 | 梯度下降、内点法 |
| 非凸优化 | 非凸 | 任意 | 多局部极值 | 全局搜索、模拟退火 |
| 组合优化 | 离散域 | 任意 | NP-hard 常见 | 分支定界、启发式 |
| 随机优化 | 含随机项 | 可能含随机 | 期望最优 vs 随机可行 | SAA、鲁棒优化 |

### 第四步：寻找最优解 / Find the Optimal Solution

根据类型分类选择求解策略：
- **LP/QP/凸优化**：利用凸性，梯度类方法或内点法可保证收敛到全局最优
- **非凸优化**：需警惕局部最优——尝试多起点、全局搜索策略，或松弛为凸近似
- **组合优化**：精确求解往往 NP-hard——分支定界求小规模精确解，启发式求大规模近似解
- **随机优化**：样本平均近似（SAA）将随机问题转化为确定性近似问题
- **信息不足**：使用满意解（satisficing）——找到"足够好"的解即可

### 第五步：灵敏度分析 / Sensitivity Analysis

拉格朗日乘子的经济学含义：$\lambda_i^*$ 为第 $i$ 个不等式约束的**影子价格**——约束放松一个单位，目标函数改善约 $\lambda_i^*$ 个单位。互补松弛性表明：若 $\lambda_i^* = 0$，则该约束对最优解无影响（非活跃约束）；若 $\lambda_i^* > 0$，则约束活跃且最优解恰好在其边界上。

**关键问题**：如果约束条件或目标函数发生微小变化，最优解会如何变化？哪些约束是活跃的？影子价格是多少？

### 第六步：多目标与帕累托 / Multi-Objective and Pareto

当存在多个目标 $f_1, f_2, \dots, f_k$ 时，通常不存在单一最优解。帕累托最优解集定义：不存在另一个可行解使所有目标同时改善。

常用方法：
- **加权求和法**：$\min \sum w_i f_i(x)$，权重 $w_i > 0$——不同权重对应帕累托前沿上不同点
- **$\epsilon$-约束法**：将一个目标作为主目标，其余转为不等式约束 $\min f_1(x)$ s.t. $f_i(x) \leq \epsilon_i$——遍历 $\epsilon_i$ 可覆盖帕累托前沿

### 第七步：监控约束变化 / Monitor Constraint Changes

最优解不是永恒的——当约束条件变化时，需要重新优化。活跃约束的变化对最优解影响最大（影子价格高），非活跃约束的微小变化通常不影响最优解。

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|-------------|-------------------------------|---------------------------|
| 没有明确目标就优化 | 目标函数不清晰，$\nabla f$ 方向不确定 | 先精确定义目标函数 $f(x)$ |
| 忽略隐式约束 | 未发现的约束使"最优解"不可行，破坏原始可行性 | 穷尽检查所有可能的约束 |
| 陷入局部最优 | 非凸问题中贪心策略不保证全局最优 | 验证凸性；非凸时用多起点或全局方法 |
| 把最优当唯一 | 最优解可能不唯一（$f$ 在可行域某区域为常数） | 检查是否存在多个等价最优解 |
| 多目标用单目标方法 | 不同目标需 trade-off，不能简单加权覆盖全部帕累托解 | 使用帕累托前沿分析 |
| 忘记重新优化 | 约束变了但未更新，旧解不再满足 KKT | 定期检查约束是否变化 |
| 未验证凸性 | 非凸问题误用凸优化方法，可能收敛到局部极值而非全局最优 | 先判断 $f$ 与约束的凸性，再选方法 |
| 忽略对偶理论 | 对偶问题可能更易求解，且对偶间隙提供最优性界 | 构造对偶问题，利用强对偶性（凸+Slater） |
| 混淆可行与最优 | 可行解满足约束但不一定使 $f$ 最小；最优解必须可行且极值 | 先验证可行性，再验证最优性（KKT） |
| 忽略计算复杂度 | 组合优化问题可能 NP-hard，精确求解时间指数增长 | 对大规模问题使用启发式或近似算法 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：

1. **目标函数**：用一句话明确"我们要最大化/最小化什么" `[目标]: [描述]`，并判断凸性 `[凸性]: [凸/非凸/未知]`
2. **约束清单**：标注每个约束为 `[硬约束]` 或 `[软约束]`，并分类 `[不等式/等式]` `[线性/非线性]`
3. **类型分类**：判定问题类别 `[类型]: [LP/QP/凸/非凸/组合/随机]`
4. **可行域分析**：在约束下，哪些选项是可行的？活跃约束是哪些？
5. **最优解/满意解**：标注使用的策略 `[策略]: [梯度法/内点法/全局搜索/satisficing/帕累托]`
6. **灵敏度分析**：关键约束的影子价格是多少？若关键约束变化 X%，结论如何变化？
7. **行动建议**：明确写出"接下来我将……"

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **建模思想**：优化前需要先建模——定义目标函数和约束本身就是一个建模过程
- **概率与统计**：在不确定性下做优化需要随机优化或鲁棒优化方法
- **变换思想**：有时变换到对偶问题更容易求解；对偶性是优化中最深刻的变换
- **博弈思想**：当多个决策者同时优化时，问题变为博弈论中的均衡问题——纳什均衡即多人优化中的稳定点
- **算法思想**：优化问题的求解依赖于算法设计——凸优化可用梯度法，组合优化需分支定界或启发式算法