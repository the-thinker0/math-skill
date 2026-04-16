---
name: algorithmic-thinking
description: |
  科研模式触发：当需要算法设计、复杂度分析、可计算性理论、P/NP分类时调用。
  生活模式触发：当需要设计高效工作流程、自动化重复任务、评估计划可行性时调用。
  English (Research mode): Trigger when you need algorithm design, complexity analysis, computability theory, or P/NP classification.
  English (Life mode): Trigger when you need to design efficient workflows, automate repetitive tasks, or assess feasibility of plans.
---

# 算法与计算思想

> "算法是思想的自动化——将洞察转化为可重复执行的精确步骤。"
> "An algorithm is the automation of thought — turning insight into precisely repeatable steps."
>
> —— 计算理论、算法分析、复杂度理论
> —— Computability Theory, Algorithm Analysis, Complexity Theory

## 核心原则 / Core Principle

把问题拆解为可执行的步骤，评估代价，判断可行性。计算思想的核心是：(1) 将问题分解为可执行步骤，(2) 识别可复用的模式，(3) 抽象掉实现细节，(4) 分析资源需求（时间、空间）。这四项构成了从问题到程序的桥梁——没有分解就无法规划，没有模式识别就无法复用，没有抽象就无法泛化，没有资源分析就无法评估可行性。

Break problems into executable steps, assess cost, judge feasibility. Computational thinking means: (1) decomposing problems into steps, (2) recognizing patterns for reuse, (3) abstracting away implementation details, (4) analyzing resource requirements (time, space). These four pillars form the bridge from problem to program — without decomposition there is no plan, without pattern recognition there is no reuse, without abstraction there is no generalization, without resource analysis there is no feasibility assessment.

关键洞察：某些问题本质上是困难的（NP完全），某些问题本质上是不可解的（不可判定）。了解这些极限与找到解同样重要。忽视计算极限的算法设计如同在悬崖上建桥——看似可行，实则必然崩塌。算法思想的第一原则不是"如何求解"，而是"是否可解、代价几何"。

Key insight: some problems are inherently hard (NP-complete), some are inherently unsolvable (undecidable). Knowing these limits is as important as finding solutions. Algorithm design that ignores computational limits is like building a bridge over a cliff — it seems feasible but will inevitably collapse. The first principle of algorithmic thinking is not "how to solve" but "whether it is solvable and at what cost."

算法的四个基本属性决定了其质量：(1) 有限性——必须在有限步骤内终止；(2) 确定性——每步操作必须明确无歧义；(3) 输入性——有零个或多个输入；(4) 输出性——有一个或多个输出。违反任一属性则不是算法而是其他类型的计算描述。

The four essential properties of an algorithm: (1) finiteness — must terminate in finite steps; (2) definiteness — each step must be unambiguous; (3) input — zero or more inputs; (4) output — one or more outputs. Violating any of these means it is not an algorithm but some other computational description.

算法思想的元层次价值：面对任何问题时，算法思维首先问的不是"答案是什么"，而是"能否系统化地找到答案、找到答案需要多少资源、这个寻找过程本身是否可行"。这种从"求解"到"可求解性"的视角转换，是算法思想区别于其他数学思维方法的标志。

The meta-level value of algorithmic thinking: it first asks not "what is the answer" but "can the answer be found systematically, how many resources are needed, and is the finding process itself feasible." This shift from "solving" to "solvability" is the hallmark that distinguishes algorithmic thinking from other mathematical thinking methods.

> **数学形式化 / Mathematical Formalization**（科研模式参考）
>
> 图灵机 M: Σ* → Σ* 在有限步骤内停机。时间复杂度 T(n) = 长度为 n 的输入的最大执行步数。空间复杂度 S(n) = 最大使用单元数。丘奇-图灵论题：任何可计算的都可由图灵机计算。
>
> Turing machine M: Σ* → Σ* halting in finite steps. Time complexity T(n) = max steps for inputs of length n. Space complexity S(n) = max cells used. The Church-Turing thesis: anything computable is computable by a Turing machine.
>
> 三级层次结构：可计算的（算法存在）→ 可行的（多项式时间算法存在）→ 难解的（仅有指数时间算法或无算法）。可计算但不可行的问题在实践中等同于不可计算——蛮力搜索 2^n 个组合虽"有算法"，但对 n=100 毫无实用价值。P vs NP 问题正是可行与难解之间的分界线。
>
> Three-level hierarchy: computable (algorithm exists) → tractable (polynomial-time algorithm exists) → intractable (only exponential-time or no algorithm). A computable-but-intractable problem is practically equivalent to uncomputable — brute-force search over 2^n combinations "has an algorithm," but for n=100 it has zero practical value. The P vs NP question is precisely the boundary between tractable and intractable.
>
> 复杂度符号：O(f(n)) 表示上界（不超过 f(n) 量级），Ω(f(n)) 表示下界（至少 f(n) 量级），Θ(f(n)) 表示精确界（恰为 f(n) 量级）。常见递推：T(n) = 2T(n/2) + O(n) → O(n log n)；T(n) = T(n-1) + O(n) → O(n^2)；T(n) = T(n/2) + O(1) → O(log n)。复杂度类：O(1) ⊂ O(log n) ⊂ O(n) ⊂ O(n log n) ⊂ O(n^k) ⊂ O(2^n) ⊂ O(n!)。
>
> Complexity notation: O(f(n)) upper bound, Ω(f(n)) lower bound, Θ(f(n)) tight bound. Common recurrences: T(n) = 2T(n/2) + O(n) → O(n log n); T(n) = T(n-1) + O(n) → O(n^2); T(n) = T(n/2) + O(1) → O(log n). Complexity classes: O(1) ⊂ O(log n) ⊂ O(n) ⊂ O(n log n) ⊂ O(n^k) ⊂ O(2^n) ⊂ O(n!).
>
> P/NP-hard/不可判定定义：P = 可在多项式时间内判定的问题类；NP-hard = 比所有 NP 问题都难的问题；不可判定 = 不存在任何算法可判定的问题。NP-hard 问题应对策略：近似算法（有误差界限）或启发式（概率保证）。不可判定问题应对：寻找可判定的受限版本。
>
> P/NP-hard/undecidable definitions: P = problems decidable in polynomial time; NP-hard = problems at least as hard as all NP problems; undecidable = no algorithm can decide them. NP-hard strategies: approximation (error bounds) or heuristics (probabilistic guarantees). Undecidable strategies: find decidable restricted versions.
>
> 循环不变量定义：每次迭代前和后成立的性质，加上终止条件蕴含输出正确。Hoare 逻辑：{P} S {Q}——前置条件 P 经过语句 S 后产生后置条件 Q。
>
> Loop invariant definition: property holding before and after each iteration, plus termination condition implies output correctness. Hoare logic: {P} S {Q} — precondition P through statement S yields postcondition Q.

## 不适用场景 / When NOT to Use

1. **问题有闭式解，不需要逐步计算** `[科研/通用]` —— 例如二次方程求根公式直接给出答案，无需迭代算法。闭式解在单步内完成计算，算法化反而增加复杂度而不带来收益。

   Closed-form solutions exist `[Research/General]` — e.g., the quadratic formula gives answers directly, no iterative algorithm needed. Algorithmizing closed-form solutions adds complexity without benefit.

2. **问题本质是定性的而非程序性的** `[通用]` —— 例如"这个数学结构是否优美"、"这个证明是否有洞察力"无法化为有限步骤。定性判断依赖直觉与审美，而非可重复的机械过程。

   The problem is qualitative, not procedural `[General]` — e.g., "is this mathematical structure elegant" cannot be reduced to finite steps. Qualitative judgment relies on intuition, not repeatable mechanical processes.

3. **输入无结构无法离散化** `[科研]` —— 例如连续感知数据流无法直接作为算法输入。当预处理本身比核心问题更复杂时，算法化可能不是最优路径。

   Input is unstructured and cannot be discretized `[Research]` — e.g., raw continuous sensory streams cannot directly serve as algorithm input. When preprocessing is more complex than the core problem, algorithmization may not be optimal.

4. **只需简单直觉判断即可决策** `[生活]` —— 例如日常小决策（今天吃什么、穿什么）无需算法化。过度系统化简单问题反而浪费时间。

   Simple intuitive judgment suffices `[Life]` — e.g., daily small decisions (what to eat, what to wear) need no algorithmization. Over-systematizing simple problems wastes time.

## 何时使用 / When to Use

### 科研触发条件 / Research Triggers

1. 需要自动化重复过程——当同一操作需对大量数据反复执行时，算法化是自然选择。手动处理一百条记录尚可忍受，处理一百万条则必须算法化。

   Automating repetitive processes — when the same operation must be executed on large datasets repeatedly. A million records requires algorithmization.

2. 需要验证程序是否终止——证明算法在有限步内停机是计算思想的基本要求。无限循环是软件系统的致命缺陷，终止性证明是算法可靠性的基石。

   Verifying program termination — proving an algorithm halts in finite steps is a fundamental requirement. Infinite loops are fatal defects; termination proofs are the cornerstone of reliability.

3. 需要估算计算代价——在大规模数据上运行前，必须评估时间和空间消耗。未经复杂度分析的算法可能因资源耗尽而崩溃。

   Estimating computational cost — before running on large-scale data, time and space consumption must be assessed. Complexity analysis elevates "can run" to "runs reliably within constraints."

4. 面对组合爆炸——当搜索空间随输入规模指数增长时，需要算法策略来有效剪枝。组合爆炸是算法思维的经典战场。

   Facing combinatorial explosion — when the search space grows exponentially with input size, algorithmic strategies are needed for effective pruning.

5. 需要判断问题是否可行——确定问题属于 P、NP-hard 还是不可判定，决定求解策略。可行性分类不是学术标签而是实践指南。

   Determining problem feasibility — deciding whether a problem is in P, NP-hard, or undecidable determines the solving strategy. Feasibility classification is a practical guide.

6. 需要设计高效求解步骤——从蛮力到精巧算法，效率差异可达数个量级。高效算法不仅节省时间，更扩展了可求解问题的边界。

   Designing efficient solution steps — efficiency differences can span orders of magnitude. Efficient algorithms expand the boundary of solvable problems.

### 生活触发条件 / Life Triggers

1. 需要设计高效工作流程——当日常任务有固定模式可优化时，用算法思维梳理流程、消除冗余步骤。例如优化出行路线、安排多任务优先级。

   Designing efficient workflows — when daily tasks have patterns to optimize, use algorithmic thinking to streamline processes and eliminate redundant steps. E.g., optimizing travel routes, prioritizing multi-task schedules.

2. 需要自动化重复性工作——反复手动执行相同步骤（如定期报表整理、批量邮件回复）时，应寻找自动化方案。

   Automating repetitive tasks — when repeatedly executing the same steps manually (e.g., periodic report formatting, batch email replies), seek automation solutions.

3. 需要评估计划可行性——面对复杂计划时，先估算所需时间、精力、资源，判断是否在合理范围内可行，而非盲目启动。

   Assessing plan feasibility — before a complex plan, estimate required time, effort, and resources first, then judge whether it is feasible within reasonable bounds.

4. 需要把大任务拆成小步骤——面对看似难以开始的大项目时，将其拆成一系列可独立完成的小步骤，逐步推进。

   Breaking large tasks into small steps — when a big project seems impossible to start, break it into a series of independently completable small steps.

5. 需要判断是否值得追求完美——某些目标注定耗时巨大，接受"足够好"而非追求完美是更明智的选择。

   Judging whether perfection is worth pursuing — some goals are inherently time-consuming; accepting "good enough" rather than pursuing perfection may be wiser.

## 方法流程 / Method

### Step 1: 形式化输入输出规格 / Formalize Input/Output Specification

#### 科研模式 / Research Mode

定义输入域、输出域、约束条件。精确的规格是算法设计的起点——模糊的规格产生模糊的算法。

输入规格应明确：数据类型（整数、浮点、字符串、图）、规模范围（n ∈ [1, 10^6]）、合法性条件（前置条件 pre-condition）。输出规格应明确：返回值类型、精度要求、边界情况处理。约束条件应覆盖时间限制、空间限制、正确性保证（后置条件 post-condition）。

Define input domain, output domain, and constraints. Input specs: data types, size ranges, validity conditions (pre-condition). Output specs: return types, precision requirements, edge case handling. Constraints: time limits, space limits, correctness guarantees (post-condition).

规格的形式化程度应与问题的复杂性匹配——简单问题用自然语言描述即可，复杂问题需要数学定义精确的输入/输出域。检验方法：如果无法写出前置条件和后置条件的谓词，则规格尚未足够形式化。

The formality level should match the problem complexity. Test: if you cannot write pre-condition and post-condition predicates, the spec is not formal enough.

#### 生活模式 / Life Mode

明确你要做什么，期望得到什么结果——输入是什么（需要什么前提），输出是什么（期望什么成果）。

Clarify what you want to do and what result you expect — what is the input (what prerequisites are needed), what is the output (what outcome is desired).

#### 共通要点 / Shared Essentials

无论科研还是生活，第一步都必须明确：问题是什么、期望结果是什么、前提条件是什么。没有清晰的输入输出定义，后续所有步骤都会偏离方向。

Whether in research or life, the first step must clarify: what is the problem, what is the expected result, what are the prerequisites. Without clear I/O definition, all subsequent steps will drift off course.

### Step 2: 分解子问题 / Decompose into Sub-problems

#### 科研模式 / Research Mode

将大问题拆分为可独立求解的小块。子问题应边界清晰、接口明确。分解的质量直接影响算法的可理解性、可验证性和可优化性——一个好的分解使得你可以独立思考每个子问题，而不必同时操心全局。

分解策略包括：按数据分（处理不同子集）、按功能分（完成不同子任务）、按层次分（先粗后细逐层精化）。好的分解使每个子问题可独立验证，整体组合可递归验证。子问题间的依赖关系应显式标注，避免隐式耦合导致的组合错误。

Break the large problem into manageable pieces. Strategies: by data, by function, by layers. Good decomposition makes each sub-problem independently verifiable. Dependencies should be explicitly noted.

#### 生活模式 / Life Mode

把大问题拆成小步骤——每个步骤足够小，可以单独完成。复杂问题往往可以拆成一系列简单步骤。

Break big problems into small steps — each step small enough to complete independently. Complex problems can often be broken into a series of simple steps.

#### 共通要点 / Shared Essentials

分解的关键是：每个子问题/步骤应足够小以便独立处理，但不过度碎片化以致失去整体视野。好的分解让人可以专注当前一步而不必同时操心全局。

The key to decomposition: each sub-problem/step should be small enough to handle independently, but not so fragmented that the overall picture is lost. Good decomposition lets you focus on one step at a time.

### Step 3: 设计程序 / Design the Procedure

#### 科研模式 / Research Mode

选择算法范式——核心决策，范式选择错误会导致后续所有努力白费：

- **分治 (Divide-and-Conquer)**：分割、求解子部分、合并结果。适用于子问题独立、合并代价低于整体求解代价。经典实例：归并排序、快速排序、Strassen 矩阵乘法。递推关系 T(n) = aT(n/b) + f(n) 由主定理求解。

- **动态规划 (Dynamic Programming)**：重叠子问题、备忘录化避免重复计算。适用于子问题共享子结构、最优子结构成立。经典实例：最短路径、背包问题、序列对齐。

- **贪心 (Greedy)**：每步选择局部最优，期望全局最优。适用于贪心选择性质成立。经典实例：Dijkstra 算法、Huffman 编码、最小生成树。

- **回溯 (Backtracking)**：系统性搜索，遇死路则剪枝回退。适用于搜索空间有结构、可提前判断死路。经典实例：N 皇后、旅行商精确解、约束满足问题。

- **随机化 (Randomized)**：概率捷径，以随机选择换取效率。适用于确定性算法代价过高、随机采样能以高概率给出好结果。经典实例：随机快排、Monte Carlo、Las Vegas 算法。

范式选择原则：子问题独立选分治、子问题重叠选动规、贪心性质成立选贪心、搜索空间有结构选回溯、确定性代价过高选随机化。实际问题可能混合使用多种范式。

Choose a paradigm — core decision:
- **Divide-and-Conquer**: split, solve parts, merge. Subproblems independent, merge cost lower than whole.
- **Dynamic Programming**: overlapping subproblems, memoize. Optimal substructure holds.
- **Greedy**: locally optimal, expecting global. Greedy-choice property holds.
- **Backtracking**: systematic search with pruning. Search space structured.
- **Randomized**: probabilistic shortcuts. Deterministic cost too high.

Paradigm selection: independent → divide-and-conquer, overlapping → DP, greedy-choice → greedy, structured → backtracking, high deterministic cost → randomized. Real problems may mix paradigms.

#### 生活模式 / Life Mode

设计执行方案——常见策略：分步推进、先做最关键的部分、试错修正、从简单版本开始逐步完善。

Design an execution plan — common strategies: step-by-step progress, tackle the most critical part first, trial-and-error correction, start from a simple version and gradually improve.

#### 共通要点 / Shared Essentials

方案设计的关键是选择合适的策略来匹配问题的结构。不同类型的问题需要不同的处理方式——没有万能方法，但有适合特定问题特征的策略。

The key to procedure design is choosing a strategy that matches the problem's structure. Different problem types need different approaches — no universal method, but strategies suited to specific problem features.

### Step 4: 分析复杂度 / Analyze Complexity

#### 科研模式 / Research Mode

时间复杂度 O(f(n))，空间复杂度 O(g(n))。区分最坏情况与平均情况。大 O 符号描述增长阶而非实际耗时。

分析要点：识别基本操作计数、递推关系求解（主定理）、输入分布假设对平均复杂度的影响。除了大 O（上界），还应关注大 Ω（下界）和大 Θ（精确界）。复杂度分析不是事后验证而是设计过程中的持续评估——每一步设计都应伴随复杂度估测。

Time O(f(n)), space O(g(n)). Distinguish worst-case vs average-case. Beyond big-O (upper bound), attend to big-Ω (lower bound) and big-Θ (tight bound). Complexity analysis is ongoing evaluation during design, not post-hoc verification.

实际意义：n=10^6 时，O(n) 约 10^6 步（秒级），O(n^2) 约 10^12 步（不可行），O(2^n) 远超宇宙年龄。

Practical significance: at n=10^6, O(n) ~ 10^6 steps (seconds), O(n^2) ~ 10^12 steps (infeasible), O(2^n) far exceeds the age of the universe.

#### 生活模式 / Life Mode

评估需要多少时间和精力——粗略判断这个方案是否可行，会不会耗时过长或成本太高。

Assess how much time and effort is needed — roughly judge whether the plan is feasible, whether it will take too long or cost too much.

#### 共通要点 / Shared Essentials

复杂度分析的核心目的：在执行之前判断"是否值得做"。不评估代价的方案，往往在中途发现资源不足而被迫放弃。

The core purpose of complexity analysis: judge "is it worth doing" before execution. A plan without cost assessment often fails midway when resources run short.

### Step 5: 证明正确性 / Prove Correctness

#### 科研模式 / Research Mode

使用循环不变量、结构归纳、终止证明、前置/后置条件。未经证明的算法是猜测，不是解决方案。正确性证明是算法区别于程序的标志——程序是实现，算法是保证。

循环不变量：初始化（循环前不变量成立）、维护（每次迭代保持不变量）、终止（不变量加终止条件给出后置条件）。结构归纳：假设子调用正确，证明当前调用正确。终止证明：构造递减度量，证明每步使度量严格递减。Hoare 逻辑：{P} S {Q}——前置条件 P 经过语句 S 后产生后置条件 Q。

Use loop invariants, structural induction, termination proofs, pre/post conditions. Loop invariant: initialization, maintenance, termination. Structural induction: assume sub-calls correct, prove current call correct. Termination: decreasing measure. Hoare logic: {P} S {Q}.

#### 生活模式 / Life Mode

验证方案是否真的能解决问题——每一步是否都朝正确方向推进？有没有步骤可能走错路？

Verify whether the plan actually solves the problem — does each step move in the right direction? Are there steps that might lead down the wrong path?

#### 共通要点 / Shared Essentials

无论科研还是生活，方案必须经过验证。未经验证的方案只是猜想——可能在关键时刻失败。验证的重点是：每一步是否可靠、整体是否连贯、最终是否能达成目标。

Whether in research or life, plans must be verified. Unverified plans are conjectures — they may fail at critical moments. Verification focuses on: is each step reliable, is the whole coherent, can it achieve the goal.

### Step 6: 检查可行性 / Check Tractability

#### 科研模式 / Research Mode

问题是否属于 P？NP-hard？不可判定？若 NP-hard → 使用启发式/近似；若不可判定 → 重新表述问题。

可行性判断决定了后续所有策略：对 P 问题追求最优精确算法；对 NP-hard 问题设计近似算法或启发式，明确误差界限或概率保证；对不可判定问题寻找可判定的近似版本或受限子问题。常见 NP-hard 问题：旅行商、图着色、子集和、SAT。常见不可判定问题：停机问题、希尔伯特第十问题。

Is the problem in P? NP-hard? Undecidable? If NP-hard → heuristics/approximation; if undecidable → reformulate. Common NP-hard: TSP, graph coloring, subset sum, SAT. Common undecidable: halting problem, Hilbert's tenth problem.

#### 生活模式 / Life Mode

判断问题是否可以在合理时间内解决——有些问题注定耗时巨大，接受近似方案而非追求完美。

Judge whether the problem can be solved in a reasonable time — some problems are inherently time-consuming; accept approximate solutions rather than pursuing perfection.

#### 共通要点 / Shared Essentials

可行性检查是算法思维的标志性步骤——它问的不是"如何做"，而是"是否值得做"。对不可能或代价过高的问题，调整目标比强行推进更明智。

Tractability checking is the hallmark of algorithmic thinking — it asks not "how to do" but "is it worth doing." For impossible or prohibitively costly problems, adjusting goals is wiser than pushing forward.

### Step 7: 优化与改进 / Optimize and Improve

#### 科研模式 / Research Mode

减少常数因子、利用数据结构特性、并行化。优化应基于瓶颈分析而非盲目调参。

优化层次：(1) 算法级——换更优范式（如从蛮力到分治）；(2) 数据结构级——换更优存储与查询方式；(3) 实现级——缓存、并行、SIMD；(4) 问题级——换问题表述使更易求解。优化优先级：算法级收益最大（O(n^2) → O(n log n)），数据结构级次之，实现级最小但最可控，问题级可能质的飞跃。

Reduce constant factors, exploit data structure properties, parallelize. Optimization levels: (1) algorithmic — switch paradigm; (2) data structure — better storage/query; (3) implementation — caching, parallelism; (4) problem-level — reformulate. Priority: algorithmic (highest payoff), data structure, implementation, problem-level (qualitative leap possible).

#### 生活模式 / Life Mode

优化执行效率——消除重复步骤、合并相似任务、找到更快的方法完成每一步。

Optimize execution efficiency — eliminate redundant steps, merge similar tasks, find faster ways to complete each step.

#### 共通要点 / Shared Essentials

优化的原则：先确保方案正确可行，再追求高效。过早优化是浪费——方向正确但低效胜过方向错误但高效。每次优化后必须重新验证正确性。

Optimization principle: ensure correctness and feasibility first, then pursue efficiency. Premature optimization is waste — correctly directed but slow beats incorrectly directed but fast. Re-verify after each optimization.

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|---|---|---|
| 假设指数算法可接受 `[科研]` | NP-hard问题对大n需要启发式而非精确算法；2^50步即使每步1ns也需35年 | 对大n问题用近似或启发式，明确误差界限 |
| 未证明终止性 `[科研]` | 无限循环是真实风险；程序挂起远比慢速结果更危险 | 用递减度量证明终止，构造良序集上的递减函数 |
| 忽略最坏与平均情况区别 `[科研]` | 快排最坏O(n²)但平均O(n log n)；最坏情况可能在实际中出现 | 明确分析场景，注明假设条件 |
| 混淆存在性与可构造性 `[科研]` | 解可能存在但不可计算；存在性≠可构造性是计算理论的基本分界 | 区分存在性证明与算法构造，明确算法输出 |
| 低估常数因子影响 `[科研/通用]` | 带巨大常数的O(n log n)可能比带小常数的O(n²)慢；理论最优≠实际最优 | 实际测试比较，关注常数因子与缓存效应 |
| 忽略空间复杂度 `[科研]` | 时间高效的算法可能消耗不可接受的内存；DFS需O(n)空间但BFS需O(2^n) | 同时分析时间与空间，标注空间限制 |
| 过早优化 `[通用]` | 未证正确就优化方向可能全错；优化错误算法是双重浪费 | 先证正确再析复杂度最后才优化 |
| 忽视输入分布 `[科研/通用]` | 平均复杂度依赖输入分布假设；随机输入≠实际输入 | 标明分布假设，分析实际场景下的表现 |
| 不评估可行性就开始执行 `[生活]` | 不判断是否值得做就开始做，往往中途发现资源不足而被迫放弃 | 先评估时间和精力需求，判断可行性再启动 |
| 方案过于复杂无法实际操作 `[生活]` | 过度设计导致执行困难，步骤太多反而无法推进 | 保持方案简洁，每一步都能实际完成 |
| 追求完美方案而忽略可行性 `[生活]` | 某些问题注定耗时巨大，追求完美反而无法完成任何实质进展 | 接受"足够好"的近似方案，优先完成而非完美 |

## 操作规程 / Operating Procedure

每次使用算法思维分析问题时，根据场景选择模式：

**科研模式**——用于算法设计、复杂度分析、可计算性判定等学术场景，必须按照以下格式输出完整结论。每项之间用换行分隔，不可合并或省略：

1. **输入规格**：[输入]: [描述] — 例如：[输入]: 无序整数数组 A[1..n]，n ∈ [1, 10^6]

2. **输出规格**：[输出]: [描述] — 例如：[输出]: A 的升序排列

3. **算法范式**：[范式]: [分治/动规/贪心/回溯/随机化] 因为 [理由] — 例如：[范式]: 分治 因为 子问题独立且合并代价 O(n)

4. **复杂度**：[时间]: O([f(n)]) [空间]: O([g(n)]) [场景]: [最坏/平均] — 例如：[时间]: O(n log n) [空间]: O(n) [场景]: 最坏

5. **正确性**：[循环不变量/归纳策略]: [具体内容] ✅ 已证 或 ❌ 未证 — 例如：[循环不变量]: 合并前两部分各自有序 ✅ 已证

6. **可行性**：[类别]: [P/NP-hard/不可判定] [应对]: [精确/近似/启发式/重新表述] — 例如：[类别]: P [应对]: 精确算法

7. **改进建议**：[优化方向]: [具体建议] — 例如：[优化方向]: 实现级 → 用原地归并减少空间至 O(1)

**科研模式输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

---

**生活模式**——用于设计高效工作流程、自动化重复任务、评估计划可行性等日常场景，按照以下格式输出。每项之间用换行分隔，不可合并或省略：

1. **[目标与前提]:[明确]** — 要做什么，需要什么前提条件。例如：[目标与前提]:[明确] 完成季度报告，前提是有原始数据和模板

2. **[步骤分解]:[列表]** — 把问题拆成可执行的小步骤。例如：[步骤分解]:[列表] 1.收集数据 2.整理格式 3.填充模板 4.审核校对

3. **[可行方案]:[设计]** — 选择最合适的执行策略。例如：[可行方案]:[设计] 分步推进——先完成数据收集再逐步填充

4. **[成本评估]:[粗略]** — 需要多少时间、精力、资源。例如：[成本评估]:[粗略] 约3小时，需集中注意力，无需额外资源

5. **[可行性判断]:[结论]** — 方案是否可以在合理条件下完成。例如：[可行性判断]:[结论] 可行——时间充足、资源齐备、步骤清晰

6. **[行动建议]:[步骤]** — 具体执行的第一步是什么。例如：[行动建议]:[步骤] 立即开始数据收集，预计30分钟完成

**生活模式输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

算法思维与其他数学思维方法存在深层联系，理解这些联系有助于在恰当场景选择恰当的思维工具：

- **优化思想**：许多优化算法是算法思想的具体实例（梯度下降、分支定界）——优化思想关注目标函数的最优值，算法思想关注达到最优值的步骤与代价
- **变换思想**：FFT是算法思想应用于变换的典范——O(n log n) vs O(n²)——变换将问题映射到易解空间，算法在变换空间高效求解
- **逻辑演绎**：正确性证明使用演绎推理（循环不变量、归纳）——算法的正确性证明本质上是一系列演绎推理步骤的链
- **归纳与类比**：分治策略使用结构类比——子问题与原问题同构——这正是归纳思想的算法化体现
- **离散/组合思想**：算法处理离散对象，组合计数支撑复杂度分析——组合爆炸的计算正是算法思维需要克服的核心障碍