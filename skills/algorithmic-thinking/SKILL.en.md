---
name: algorithmic-thinking
description: |
  Trigger when a problem needs finite-step solving, algorithm design, complexity analysis (time/space), tractability & parallelism assessment (P/NP-hard/undecidable); or termination/correctness proofs; or designing executable algorithms/operators for GPU (assessing complexity order, parallelism, memory access & fusion).
---

# 🖥️ Algorithmic Thinking

> "An algorithm is the automation of thought — turning insight into precisely repeatable steps."
>
> — Computability Theory, Algorithm Analysis, Complexity Theory

## Core Principle

**Break problems into executable steps, assess cost, judge feasibility. The first principle is not "how to solve" but "whether it is solvable and at what cost" — some problems are inherently hard (NP-complete), some inherently unsolvable (undecidable); knowing these limits is as important as finding solutions.**

> **Mathematical Formalization**
>
> A Turing machine M: Σ* → Σ* halts within a finite number of steps. Time complexity T(n) = the maximum number of execution steps for an input of length n; space complexity S(n) = the maximum number of cells used. Church–Turing thesis: anything computable is computable by a Turing machine.
>
> Three-tier hierarchy: computable (an algorithm exists) → tractable (a polynomial-time algorithm exists) → intractable (only exponential-time or no algorithm). Computable but intractable is practically equivalent to uncomputable — brute force 2^n is worthless for n=100. P vs NP is precisely the boundary between tractable and intractable.
>
> Complexity notation: O(f(n)) upper bound, Ω(f(n)) lower bound, Θ(f(n)) tight bound. Common recurrences: T(n)=2T(n/2)+O(n) → O(n log n); T(n)=T(n-1)+O(n) → O(n²); T(n)=T(n/2)+O(1) → O(log n). Complexity classes: O(1) ⊂ O(log n) ⊂ O(n) ⊂ O(n log n) ⊂ O(n^k) ⊂ O(2^n) ⊂ O(n!).
>
> Complexity class definitions: P = polynomial-time decidable; NP-hard = at least as hard as every problem in NP; undecidable = no algorithm can decide it. NP-hard response: approximation (with error bounds) or heuristics (with probabilistic guarantees); undecidable response: find a decidable restricted version.
>
> Loop invariant: a property that holds before and after every iteration, which together with the termination condition implies output correctness. Hoare logic: {P} S {Q} — precondition P, after statement S, yields postcondition Q.

## GPU-Friendliness (Cross-Cutting Check)

Algorithmic thinking is the weapon most directly relevant to GPU — complexity order, parallelism, memory access/communication, and operator fusion directly determine whether an algorithm can run efficiently on GPU. Every algorithm must pass the `../../references/gpu-friendly-math.md` eight-dimension gate:

- **Complexity order**: Sub-quadratic O(n log n)/O(n) is friendly (fully utilizes parallel cores); O(n²) is borderline (GEMM is an exception, salvageable by Tensor Cores); O(2^n)/O(n!) is an anti-pattern.
- **Parallelism and communication**: Divide-and-conquer / data parallelism is friendly (sub-problems are independent, batchable); dependency chains in dynamic programming and serial search in backtracking require adaptation (chunking / skew scanning).
- **Memory and KV-Cache / Parallelism and communication**: Coalesced access is friendly; butterfly reductions and prefix scans have dependency patterns that require attention to bandwidth; random scatter/gather is unfriendly.
- **Operator fusion**: Multiple elementwise steps can be fused into a single kernel; algorithms that repeatedly read/write to memory — "beautiful but intractable" — should be rearranged into a single pass.

Eight-dimension minimum criteria (formal terms): **Tensorization** requires the main loop to be batchable; **GEMM-mappability** prioritizes expressing the core computation as GEMM/conv/scan; **complexity** must specify both time and space order; **memory and KV-cache** checks whether intermediate tables, state, and cache can be chunked; **low-precision stability** checks reduction, sorting, and iteration errors; **parallelism and communication** checks dependency graphs and cross-device synchronization; **sparse structure** accepts only structured sparsity; **operator fusion** requires reducing small kernels and memory round-trips.

| Algorithm characteristic | GPU classification | Notes |
|---|---|---|
| Divide-and-conquer / Merge / FFT | Friendly | Sub-quadratic, batchable, regular structure |
| Dynamic programming (dependency chains) | Adaptable | Chunking / skew scanning breaks serial dependencies |
| Backtracking / DFS serial search | Anti-pattern | Unpredictable branching, cannot fill SIMD lanes |
| Brute force O(2^n) | Anti-pattern | Complexity order itself is intractable |

> Used together with `../../references/books/matrix-analysis.md` (GEMM / low-rank decomposition for order reduction), `../../references/books/optimization-ml.md` (first-order / second-order method feasibility), `../../references/books/abstract-algebra.md` (parallel algorithms over semirings / finite fields).

## When NOT to Use

- **The problem has a closed-form solution and does not require step-by-step computation** — e.g., the quadratic formula directly gives the answer; algorithmic treatment only adds complexity.
- **The problem is qualitative rather than procedural** — e.g., "Is this structure elegant?" or "Is this proof insightful?" cannot be reduced to finite steps.
- **The input is unstructured and cannot be discretized** — e.g., a continuous perceptual data stream cannot directly serve as algorithm input; when preprocessing is more complex than the core problem, algorithmic treatment may not be optimal.

## When to Use

- Automating a repetitive process — the same operation must be performed on large volumes of data; manual execution does not scale.
- Verifying program termination — proving the algorithm halts in a finite number of steps is the cornerstone of reliability.
- Estimating computational cost — evaluating time/space consumption before large-scale runs to avoid resource exhaustion.
- Facing combinatorial explosion — the search space grows exponentially with input size, requiring pruning strategies.
- Judging problem feasibility — determining P / NP-hard / undecidable to decide on a solution strategy.
- Designing efficient solution procedures — from brute force to elegant algorithms, efficiency differences can span several orders of magnitude.
- **Designing executable algorithms/operators for GPU** — assessing complexity order, parallelism, memory access, and fusion so the algorithm is truly tractable on hardware.

## Method

### Step 1: Formalize I/O Spec
Define the input domain, output domain, and constraints. The input specification states data types (integer/floating-point/string/graph), scale range n∈[1,10^6], and validity conditions (preconditions); the output specification states the return type, precision, and boundary handling; constraints cover time/space limits and correctness guarantees (postconditions). Test: if you cannot write down the precondition/postcondition predicates, the specification is not yet formal enough.

### Step 2: Decompose into Sub-problems
Break the large problem into independently solvable pieces with clear boundaries and well-defined interfaces. Decomposition strategies: by data (processing different subsets), by function (completing different subtasks), by level (coarse-to-fine refinement). Good decomposition makes each sub-problem independently verifiable and the whole recursively verifiable; dependencies between sub-problems must be explicitly annotated to avoid implicit coupling.

### Step 3: Design the Procedure
Choose an algorithmic paradigm — this is the core decision; choosing wrong wastes all subsequent effort:

- **Divide-and-Conquer**: Partition, solve sub-parts, merge. Sub-problems are independent; merge cost is lower than solving the whole. Classics: merge sort, quicksort, Strassen matrix multiplication. Recurrence T(n)=aT(n/b)+f(n), solved by the Master Theorem.
- **Dynamic Programming (DP)**: Overlapping sub-problems, memoization to avoid repetition. Optimal substructure holds. Classics: shortest paths, knapsack, sequence alignment.
- **Greedy**: Locally optimal at each step, hoping for global optimality. Greedy-choice property holds. Classics: Dijkstra, Huffman, MST.
- **Backtracking**: Systematic search, pruning and retreating upon hitting dead ends. Search space has structure. Classics: N-queens, exact TSP, CSP.
- **Randomized**: Probabilistic shortcuts, trading randomness for efficiency. Deterministic cost is too high. Classics: randomized quicksort, Monte Carlo, Las Vegas.

Selection principle: independent → divide-and-conquer; overlapping → DP; greedy property → greedy; structured search → backtracking; deterministic cost too high → randomized. Practical problems often mix multiple paradigms.

### Step 4: Analyze Complexity
Time O(f(n)), space O(g(n)), distinguishing worst case from average case. Identify basic operation counts, solve recurrences (Master Theorem), and attend to how input distributions affect average-case complexity; beyond O (upper bound), attend to Ω (lower bound) and Θ (tight bound). Complexity analysis is an ongoing assessment during design, not post-hoc verification. Practical significance: for n=10^6, O(n) ≈ 10^6 steps (seconds), O(n²) ≈ 10^12 steps (infeasible), O(2^n) far exceeds the age of the universe.

### Step 5: Prove Correctness
Use loop invariants, structural induction, termination proofs, and pre/postconditions. An unverified algorithm is a guess. Loop invariant: initialization (holds before the loop), maintenance (preserved by each iteration), termination (invariant plus termination condition yields the postcondition); structural induction: assume correctness of sub-calls and prove the current call; termination: construct a decreasing measure and prove it strictly decreases; Hoare logic: {P} S {Q}.

### Step 6: Check Tractability
Is the problem in P? NP-hard? Undecidable? P → pursue the optimal exact algorithm; NP-hard → approximation/heuristics with explicit error bounds or probabilistic guarantees; undecidable → find a decidable restricted version. Common NP-hard problems: TSP, graph coloring, subset sum, SAT; common undecidable problems: the halting problem, Hilbert's tenth problem.

### Step 7: Optimize and Improve
Reduce constant factors, leverage data structures, parallelize — based on bottleneck analysis, not blind tuning. Optimization levels: (1) Algorithm level — switch to a superior paradigm (O(n²) → O(n log n) yields the largest gain); (2) Data structure level — switch to better storage/query structures; (3) Implementation level — caching, parallelism, SIMD, operator fusion; (4) Problem level — reformulate for easier solving (may yield qualitative leaps). Priority: algorithm level > data structure level > implementation level; problem level may enable leaps. Re-verify correctness after every optimization.

## Common Errors

| Error | Critique | Correct Approach |
|-------|----------|-----------------|
| Assuming exponential algorithms are acceptable | NP-hard problems require heuristics for large n, not exact solutions; 2^50 steps at 1ns each takes 35 years | Use approximation/heuristics for large n with explicit error bounds |
| Failing to prove termination | Infinite loops are a real risk; hanging is far more dangerous than slow results | Prove termination via a decreasing measure; construct a decreasing function on a well-ordered set |
| Confusing worst case with average case | Quicksort is worst-case O(n²) but average O(n log n); the worst case can occur in practice | Clearly state the analysis scenario and note assumptions |
| Confusing existence with constructibility | A solution may exist but be uncomputable; existence ≠ constructibility | Distinguish existence proofs from algorithmic constructions |
| Underestimating constant factors | O(n log n) with a huge constant may be slower than O(n²) with a small constant | Benchmark empirically; attend to constants and cache effects |
| Ignoring space complexity | A time-efficient algorithm may exhaust memory; DFS needs O(n) but BFS needs O(2^n) | Analyze both time and space |
| Premature optimization | Optimizing before proving correctness; the direction may be entirely wrong | Prove correctness first → analyze complexity → then optimize |
| Ignoring input distribution | Average-case complexity depends on distributional assumptions; random input ≠ real input | State distributional assumptions explicitly; analyze real-world scenarios |
| Serial / unfusable algorithms on GPU | Unpredictable branching, serial dependency chains, repeated memory reads/writes — "beautiful but intractable" | Adapt to parallel / fusible / sub-quadratic form; pass the GPU eight-dimension gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Input specification**: `[Input]: [description]` — e.g., `[Input]: unsorted integer array A[1..n], n∈[1,10^6]`
2. **Output specification**: `[Output]: [description]` — e.g., `[Output]: A sorted in ascending order`
3. **Algorithm paradigm**: `[Paradigm]: [divide-and-conquer/DP/greedy/backtracking/randomized] because [reason]`
4. **Complexity**: `[Time]: O([f(n)]) [Space]: O([g(n)]) [Scenario]: [worst/average]`
5. **Correctness**: `[Loop invariant/induction strategy]: [content] ✅ proved / ❌ not proved`
6. **Tractability**: `[Class]: [P/NP-hard/undecidable] [Response]: [exact/approximate/heuristic/reformulate]`
7. **Improvement suggestions**: `[Optimization direction]: [specific suggestions]`
8. **[GPU feasibility]** (if used for algorithm/operator design) — complexity order / parallelism / memory access / fusion assessment, annotate as friendly / retrofittable / anti-pattern + adaptation suggestions

**The output must not present analysis alone without a conclusion.**

## Relations to Other Skills

- **Optimization thinking**: Gradient descent, branch-and-bound, and other optimization algorithms are instances of algorithmic thinking — optimization focuses on the optimal value, while algorithms focus on the steps and cost to reach it.
- **Transformation thinking**: FFT is a paradigmatic application of algorithmic thinking to transformations — O(n²) → O(n log n); transformations map problems to easily solvable spaces, and algorithms solve them efficiently in the transformed space.
- **Logical deduction**: Correctness proofs use deductive reasoning (loop invariants, induction) — an algorithm correctness proof is essentially a chain of deductive steps.
- **Induction and analogy**: Divide-and-conquer uses structural analogy — sub-problems are isomorphic to the original problem — which is precisely the algorithmic embodiment of inductive thinking.
- **Discrete / Combinatorial thinking**: Algorithms process discrete objects, and combinatorial counting underpins complexity analysis — combinatorial explosion is the core obstacle algorithmic thinking must overcome.
- **Modern mathematics activation**: `../../references/books/matrix-analysis.md` (GEMM / low-rank decomposition for order reduction), `../../references/books/optimization-ml.md` (GPU feasibility of first-order / second-order methods), `../../references/books/abstract-algebra.md` (parallel algorithms over semirings / finite fields).
