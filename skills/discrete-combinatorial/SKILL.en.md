---
name: discrete-combinatorial
description: |
  Trigger when you need to count, enumerate, find patterns in finite structures, or handle graph theory, combinatorial structures, generating functions, recurrences; or design combinatorial schemes for sparse/routing/topological structures.
---

# 🧮 Discrete & Combinatorial

> "Counting is the oldest mathematical activity — finite objects harbor infinite patterns."
>
> — Combinatorics, Graph Theory, Generating Functions

## Core Principle

**Combinatorial thinking systematically counts finite structures, discovers patterns governing enumeration, and uses algebraic methods (generating functions) to recast counting as algebra — finite simplicity governing infinite complexity.**

> **Mathematical Formalization**
>
> **Pigeonhole Principle**: Place $n$ items into $m < n$ boxes; then some box contains at least 2 items. Generalization: $kn+1$ items into $n$ boxes implies some box contains at least $k+1$. A powerful tool for existence proofs — proves that something must exist without constructing a specific instance.
>
> **Inclusion-Exclusion Principle**: $|A_1\cup\ldots\cup A_n| = \sum|A_i| - \sum|A_i\cap A_j| + \ldots \pm |A_1\cap\ldots\cap A_n|$; complement counting: "does not have property $P$" = total $-$ "has property $P$."
>
> **Generating Functions**: Ordinary generating function (OGF) $A(x)=\sum a_n x^n$ (unordered / combinatorial; coefficient of $A\cdot C$ is $\sum a_i\cdot c_{n-i}$); exponential generating function (EGF) $B(x)=\sum b_n x^n/n!$ (ordered / labeled; coefficient of $B\cdot D$ divided by $n!$ is $\sum (b_i/i!)\cdot(d_{n-i}/(n-i)!)$).
>
> **Polya Enumeration Theorem**: Counting orbits under group action $= (1/|G|)\sum_{g\in G}|\text{Fix}(g)|$ (Burnside's lemma), using the cycle index polynomial to count colorings of equivalence classes where "rotations / reflections are considered identical."
>
> Euler's insight: Reinterpret the "divergent series" $1+2+3+\ldots$ as the generating function for partition counting.

## GPU-Friendliness (Cross-Cutting Check)

Discrete / combinatorial structures are often "beautiful but intractable" — exact counting is frequently #P-complete (chromatic counting, matching counting), exact enumeration is NP-hard (Hamiltonian path, subset sum), making direct GPU execution infeasible. GPU deployment must pass through the eight-dimensional gate in `../../references/gpu-friendly-math.md`, reforming via tensorizable aggregation and sampling approximations:

- **Friendly**: Adjacency matrix power iteration $A^k$ for path counting (GEMM), batch-parallel dynamic programming tables, bitset-packed counting (popcount), structured-sparse graph traversal.
- **Reformable**: Inclusion-exclusion / recurrences → semiring aggregation ($(min,+)$ / $(max,+)$ / Boolean / tropical semiring) tensorized; exact counting → Monte Carlo / importance sampling estimation; enumeration → branch-and-bound pruning + batch parallelism; discrete choices → Gumbel-Softmax relaxation.
- **Anti-patterns**: Exact full enumeration ($n!$ explosion), serial backtracking search, strongly serial DP (long-range dependencies not parallelizable), unstructured graph random access — "beautiful but intractable"; must approximate or relax.

Eight-dimensional minimum assessment (formal terms): **Tensorization** — whether finite objects can be encoded as matrices / bitsets / batched tables; **GEMM-mappability** — whether recurrences admit semiring matrix formulation; **Complexity** — identify NP-hard / #P-hard problems and approximation bounds; **Memory and KV-Cache** — check whether enumeration tables, DP tables, and adjacency structures explode; **Low-precision stability** — whether relaxation sampling and semiring operations are numerically robust; **Parallelism and communication** — whether subproblems are independent or admit skewed-scan parallelism; **Sparse structure** — adopt only block / banded / regular-graph sparsity; **Operator fusion** — whether counting, masking, and sampling can be merged into a small number of kernels.

> Use in conjunction with `../../references/books/abstract-algebra.md` (semirings / finite-field aggregation), `../../references/books/matrix-analysis.md` (adjacency matrices / spectral graphs).

## When NOT to Use

- **Continuous / analytical problems with no discrete structure** — limits, derivatives, and integrals rather than counting finite objects; this is analysis, not combinatorics.
- **An exact closed-form formula directly gives the answer** — combinatorial enumeration is overhead (e.g., $n\cdot(n-1)$ is a direct algebraic computation).
- **Pure probability problems with no combinatorial structure** — continuous distribution parameter estimation, Bayesian updating do not involve counting over finite sets; probability density integration is not a combinatorial problem.

## When to Use

- Need to count the number of configurations (permutations / selections / allocations); the answer is a specific finite number, not 1 or infinity.
- Need to prove existence via the pigeonhole principle ("there must exist an object with a certain property") without constructing an instance.
- Need to discover a recurrence or closed-form formula for an enumeration sequence $\{a_n\}$ (e.g., Catalan numbers $C_n = (2n)!/(n!(n+1)!)$).
- Need to enumerate configurations satisfying constraints — classified by structure, generated by rules, not random listing.
- Need graph / network analysis (connectivity, paths, matchings, colorings, covers) — social networks, scheduling, and planning can be modeled as graph problems.
- Need to solve recurrence relations for closed-form formulas or asymptotic behavior — recurrence → generating function → algebraic solution → coefficient extraction.
- **Design combinatorial schemes for sparse / routing / topological structures** — sparse attention patterns, routing tables / topological sorting, block-structured sparse layouts.

## Method

### Step 1: Identify the Discrete Structure and Counting Problem
Specify the **counting object** (permutations / combinations / partitions / arrangements), the **goal** (total count / constrained subset / probability), and the **constraints** (mutually exclusive, ordered / unordered, labeled / unlabeled). Classification: permutations $P(n,k)=n!/(n-k)!$; combinations $C(n,k)=n!/(k!(n-k)!)$; partitions $p(n)$ (integer partitions), $B(n)$ (set partitions); arrangements (items into positions).

### Step 2: Apply Fundamental Counting Principles
- **Multiplication principle**: $k$ independent choices → $k_1\times k_2\times\ldots\times k_n$.
- **Addition principle**: Mutually exclusive options → $|A\cup B|=|A|+|B|$ ($A\cap B=\emptyset$).
- **Pigeonhole principle**: $n>m$ implies a collision is unavoidable; some box contains at least $\lceil n/m\rceil$; generalization: $kn+1$ items into $n$ boxes implies some box contains at least $k+1$.

### Step 3: Use the Inclusion-Exclusion Principle
$|A_1\cup\ldots\cup A_n| = \sum|A_i| - \sum|A_i\cap A_j| + \sum|A_i\cap A_j\cap A_k| - \ldots \pm |A_1\cap\ldots\cap A_n|$. **Complement counting**: "does not have property $P$" = total $-$ "has property $P$"; classic derangement $D(n) = n! - C(n,1)(n-1)! + C(n,2)(n-2)! - \ldots \pm C(n,n)\cdot 0!$. **Sign rule**: the $k$-th level contributes $(-1)^{k+1}\sum|A_{i_1}\cap\ldots\cap A_{i_k}|$ (odd levels positive, even levels negative).

### Step 4: Construct Generating Functions
- **OGF**: $A(x)=\sum a_n x^n$, for unordered / combinatorial structures; coefficient of $A(x)\cdot C(x)$ is $\sum a_i\cdot c_{n-i}$ (combining two independent counts).
- **EGF**: $B(x)=\sum b_n x^n/n!$, for ordered / permutation / labeled structures; coefficient of $B(x)\cdot D(x)$ divided by $n!$ is $\sum (b_i/i!)\cdot(d_{n-i}/(n-i)!)$.
- Classics: partitions $P(x)=\sum p(n)x^n = 1/((1-x)(1-x^2)(1-x^3)\ldots)$; Catalan $C(x)=\sum C_n x^n = (1-\sqrt{1-4x})/(2x)$, derived from $C_n=\sum C_i\cdot C_{n-1-i}$ yielding $C(x)=1+x\cdot C(x)^2$.

### Step 5: Analyze Graph Structure
Graph $G=(V,E)$, $|V|$ vertices, $|E|$ edges. Core concepts: degree $\deg(v)$, adjacency / incidence matrices; paths / connected components, shortest paths (Dijkstra, Floyd-Warshall); trees have exactly $n-1$ edges, spanning trees (Kruskal / Prim), binary tree counting via $C_n$; planar graphs — Euler's formula $V-E+F=2$, $E\leq 3V-6$; chromatic number $\chi(G)$, four-color theorem $\chi(\text{planar})\leq 4$; matchings (Hall's marriage theorem, Konig's theorem: maximum matching = minimum vertex cover in bipartite graphs); Eulerian circuits (connected and all degrees even), Hamiltonian circuits (NP-complete).

### Step 6: Discover Recurrences and Closed-Form Formulas
- **Recurrences**: Catalan $C_n=\sum C_i\cdot C_{n-1-i}$, Fibonacci $F_n=F_{n-1}+F_{n-2}$, derangements $D_n=(n-1)(D_{n-1}+D_{n-2})$.
- **Generating function solution**: Multiply recurrence by $x^n$ and sum → solve for $A(x)$ → extract $a_n$; Fibonacci $F(x)=x/(1-x-x^2)$, partial fractions yield $F_n=(\varphi^n-\psi^n)/\sqrt{5}$ where $\varphi=(1+\sqrt{5})/2$.
- **Direct formulas**: $C(n,k)=n!/(k!(n-k)!)$ (choose $k$ from $n$, unordered); Catalan $C_n=C(2n,n)/(n+1)$ (combinatorial argument via valid parenthesis sequences).

### Step 7: Verify and Generalize
Check small cases $n=0,1,2,3$ by manual enumeration and compare with the formula; verify that the formula counts correctly, the recurrence is self-consistent, and boundary conditions are correct (the empty structure counts as 1: $C_0=1$, $F_0=0$, $F_1=1$); generalize to broader parameters or deeper combinatorial interpretations.

> **Verification is not optional — an unverified counting formula is not trustworthy.** Manual enumeration for $n=3$ compared with the formula is the minimum verification requirement.

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Undercounting and overcounting | Undercounting: missing constraint interactions; overcounting: same configuration counted multiple times | Identify constraint interactions explicitly; use inclusion-exclusion to correct overcounting, complement to correct undercounting |
| Ignoring constraint interactions | Constraints are not independent; intersections require inclusion-exclusion | Apply inclusion-exclusion: union = sum of individual sets $-$ intersections |
| Confusing permutations with combinations | Permutations count order: $P(n,k)=n!/(n-k)!$; combinations do not: $C(n,k)=n!/(k!(n-k)!)$ | Determine ordered / unordered first, then select the formula |
| Incorrect inclusion-exclusion signs | Odd levels positive, even levels negative; wrong signs bias the result | Strictly follow $(-1)^{k+1}$ for sign assignment |
| Ignoring generating function convergence | Formal power series can ignore convergence, but closed-form extraction requires convergence domain | Distinguish formal operations from analytic operations |
| Confusing labeled / unlabeled | Labeled structures use EGF; unlabeled structures use OGF | Permutations / distributions → EGF; combinations / partitions → OGF |
| Misapplying the pigeonhole principle | Proves existence only, does not construct instances; requires $n>m$ | Confirm $n>m$; the conclusion is "at least one," not "exactly one" |
| Incorrect recurrence boundary conditions | $C_0=1$ not 0; $F_0=0$, $F_1=1$ | Empty structure = 1; check $n=0,1$ boundary conditions |
| GPU intractability | Exact enumeration / counting is #P or NP-hard and explodes | Reform via semiring aggregation / sampling approximation; pass through the GPU eight-dimensional gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Structure identification**: `[Structure]: [discrete object]` — counting object, constraints, classification.
2. **Counting type**: `[Counting type]: [permutation / combination / partition / arrangement]` — ordered / unordered, labeled / unlabeled.
3. **Principle selection**: `[Principle]: [multiplication / addition / pigeonhole / inclusion-exclusion]` — justification for choice.
4. **Generating function**: `[Generating function]: [formula]` — GF and algebraic properties (if applicable).
5. **Graph structure**: `[Graph structure]: [properties]` — vertices / edges / connectivity / coloring (if applicable).
6. **Recurrence / formula**: `[Recurrence / formula]: [content]` — recurrence and closed-form formula.
7. **Verification**: `[Verification]: [small cases]` — at minimum, manual enumeration for $n=0,1,2,3$ compared with the formula.
8. **[GPU Feasibility]** (if used for algorithm / operator design) — whether exact counting / enumeration is NP-hard / #P; whether semiring aggregation / tensorization / sampling approximation is viable; pass through the eight-dimensional gate.

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Induction and Analogy**: Combinatorial patterns are discovered by induction — from the first few terms of $\{a_n\}$, induce a recurrence, then generalize by analogy to broader structures.
- **Algorithmic Thinking**: Combinatorial counting underpins complexity analysis — $n!$, $C(n,k)$ are foundational for algorithm cost estimation.
- **Probability and Statistics**: Combinatorics is the computational foundation of probability — classical probability $P(A)=|A|/|\Omega|$, where both numerator and denominator are combinatorial counts.
- **Transformation Thinking**: Generating functions transform counting into algebra — sequences → power series, recurrences → equations, counting → coefficient extraction.
- **Axiomatic Thinking**: Combinatorial identities require rigorous proof — $C(n,k)=C(n,n-k)$ demands algebraic or combinatorial argument, not intuition alone.
- **Modern Mathematics Activation**: `../../references/books/abstract-algebra.md` (finite fields / semiring aggregation, Burnside counting), `../../references/books/matrix-analysis.md` (adjacency matrices / spectral graphs / transfer matrices).
