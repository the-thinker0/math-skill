---
name: optimization
description: |
  Trigger when a problem involves resource allocation, trade-offs, maximizing/minimizing objectives, decisions under constraints; or needs convexity analysis, Lagrangian/KKT methods, duality structure; or choosing optimization methods for algorithm/operator/training design.
---

# Optimization

> "Under the most general constraints, find extrema of the objective -- convexity determines difficulty, KKT gives necessity, duality reveals structure."
>
> -- Optimization Theory & Operations Research

## Core Principle

**Any decision problem can be formulated as an optimization problem: maximizing (or minimizing) an objective subject to constraints. The essence of optimization is not the pursuit of "the best" in the abstract, but "the best among the feasible."**

The three core elements of optimization: **Objective**, **Constraints**, **Feasible set**.

> **Mathematical Formalization**
>
> General optimization problem: $\min_{x \in \mathbb{R}^n} f(x) \quad \text{s.t.} \quad g_i(x) \leq 0,\; i=1,\dots,m; \quad h_j(x) = 0,\; j=1,\dots,p$
>
> Lagrangian: $L(x, \lambda, \mu) = f(x) + \sum_i \lambda_i g_i(x) + \sum_j \mu_j h_j(x)$
>
> KKT conditions (essential necessary conditions, under Slater-type constraint qualifications): (1) Stationarity $\nabla_x L = 0$; (2) Primal feasibility $g_i \le 0, h_j = 0$; (3) Dual feasibility $\lambda_i \ge 0$; (4) Complementary slackness $\lambda_i g_i = 0$.
>
> Convexity: If $f$ and each $g_i$ are convex and each $h_j$ is linear, the problem is convex; in this case **KKT is sufficient**, and local optimality implies global optimality.

## GPU-Friendliness (Cross-Cutting Check)

When optimization is used for **algorithm/operator/training design**, the solution method itself must pass the eight-dimensional gate in `../../references/gpu-friendly-math.md`:

- **First-order methods (SGD/Adam)**: GEMM-friendly, parallelizable, viable in low precision; pay attention to optimizer state precision and distributed communication overhead.
- **Second-order / Newton methods**: Hessian inversion $O(n^3)$, memory explosion -- the classic "beautiful but incomputable" case -- adapt to **K-FAC / low-rank / diagonal approximations** (see `../../references/books/optimization-ml.md`, `matrix-analysis.md`).
- **Constraint projection**: Does the projection admit a closed form and is it tensorizable? Iterative projection requires caution regarding serial dependencies.
- **Distribution**: Can computation and communication overlap? Is gradient compression needed?

Eight-dimensional minimum assessment (formal terms): **Tensorization** -- whether objectives / constraints / gradients can be batched; **GEMM-mappability** -- whether the primary computation is matrix multiplication, HVP, or small K-FAC matrices; **Complexity** -- order of first-order / second-order / combinatorial solvers; **Memory & KV-Cache** -- optimizer states, Hessian storage, activation retention; **Low-precision stability** -- condition numbers, damping, loss scaling; **Parallelism & communication** -- gradient synchronization and communication overlap; **Sparse structure** -- whether preconditioners / constraints are block-structured; **Operator fusion** -- whether updates, clipping, and regularization can be fused.

> Cross-reference `../../references/books/optimization-ml.md` (Chong/Lu/Żak) and `../../references/books/matrix-analysis.md`.

## When NOT to Use

- **No clear evaluation criterion** (one does not know what "good" means) -- define the objective before optimizing.
- **Purely execution-oriented tasks** (e.g., formatting code) -- there is no optimization space.
- **The user has already decided on a plan** -- optimization is already complete.
- **The problem is essentially qualitative judgment rather than quantitative extremum** -- model first, then optimize.

## When to Use

- When one needs to determine whether a problem is convex in order to assess solution difficulty.
- Choosing optimization methods for algorithm/operator/training design and evaluating their GPU viability.
- Making rational decisions with quantifiable objectives under constraints.
- Systematic optimization of experimental design, resource allocation, and hyperparameter / architecture search.
- When one is uncertain whether the current strategy is optimal and wishes to perform a systematic analysis (convexity, duality, sensitivity).

## Method

### Step 1: Define the Objective
Clarify what is to be maximized / minimized. Key questions: Single-objective or multi-objective? Is it quantifiable (otherwise, find proxy variables)? Static or dynamic? **Is $f$ convex** (convex implies local = global; non-convex requires vigilance against local extrema)? A wrong objective leads further astray the further one proceeds.

### Step 2: List the Constraints
Distinguish **hard constraints** (physical / budget / deadline) from **soft constraints** (preferences / quality floors); mathematically classify: inequality $g_i(x)\le 0$ (defines the boundary of the feasible set), equality $h_j(x)=0$ (reduces dimensionality), linear (feasible set is a convex polyhedron) vs. nonlinear (may be non-convex).

### Step 3: Classify the Problem Type

| Type | Objective | Constraints | Key Property | Typical Method |
|------|-----------|-------------|--------------|----------------|
| LP (Linear Programming) | Linear | Linear inequalities | Optimum at a vertex | Simplex method |
| QP (Quadratic Programming) | Quadratic | Linear | Positive-definite QP is convex | Interior-point method |
| Convex optimization | Convex | Convex inequalities + linear equalities | Local = global | Gradient descent, interior-point methods |
| Non-convex optimization | Non-convex | Arbitrary | Multiple local extrema | Global search, simulated annealing |
| Combinatorial optimization | Discrete domain | Arbitrary | Frequently NP-hard | Branch-and-bound, heuristics |
| Stochastic optimization | Contains random terms | May include stochastic constraints | Expected optimum vs. stochastic feasibility | SAA, robust optimization |

### Step 4: Find the Optimal Solution
- **LP/QP/Convex**: Exploit convexity; gradient-based or interior-point methods guarantee convergence to the global optimum.
- **Non-convex**: Multi-start strategies, global search, or relaxation to convex approximations.
- **Combinatorial**: Exact solutions are often NP-hard -- branch-and-bound for small scale, heuristics / approximations for large scale.
- **Stochastic**: Sample Average Approximation (SAA) converts to a deterministic approximation.
- **Insufficient information**: A satisficing solution suffices.

### Step 5: Sensitivity Analysis
The Lagrange multiplier $\lambda_i^*$ is the **shadow price** of the $i$-th constraint -- relaxing the constraint by one unit improves the objective by approximately $\lambda_i^*$. Complementary slackness: $\lambda_i^*=0$ indicates an inactive constraint (no effect on the optimal solution); $\lambda_i^*>0$ indicates an active constraint (the optimal solution lies precisely at its boundary). Focus on: how the optimal solution changes under small perturbations of constraints / objective, and which constraints are active.

### Step 6: Multi-Objective & Pareto
Multi-objective problems $f_1,\dots,f_k$ generally have no single optimal solution. Pareto optimality: no feasible solution exists that improves all objectives simultaneously. Methods: **Weighted sum** $\min\sum w_i f_i$ (different weights trace different points on the Pareto front); **$\epsilon$-constraint method** $\min f_1$ s.t. $f_i\le\epsilon_i$ (sweep $\epsilon_i$ to cover the front).

### Step 7: Monitor Constraint Changes
The optimal solution depends on the constraints -- when constraints change, re-optimization is required. Changes in active constraints have the greatest impact (high shadow prices); small changes in inactive constraints typically do not affect the optimal solution.

## Common Errors

| Error | Critique | Correct Approach |
|-------|----------|------------------|
| Optimizing without a clear objective | Direction is undefined | Precisely define the objective first |
| Ignoring implicit constraints | The "optimal solution" is actually infeasible | Exhaustively verify all constraints |
| Getting trapped in local optima | Greedy methods on non-convex problems do not guarantee global optimality | Verify convexity; use multi-start / global methods for non-convex problems |
| Treating the optimum as unique | The optimal solution may not be unique | Check for the existence of multiple equivalent optima |
| Using single-objective methods for multi-objective problems | Different objectives require trade-offs | Employ Pareto analysis |
| Failing to verify convexity | Applying convex methods to non-convex problems | Determine convexity before selecting a method |
| Ignoring duality theory | The dual problem may be easier to solve | Construct the dual and exploit strong duality |
| Confusing feasibility with optimality | Feasible does not imply optimal | Verify feasibility first, then verify optimality |
| Ignoring computational / GPU complexity | Second-order methods / combinatorial optimization may be incomputable | Assess complexity, pass the GPU eight-dimensional gate, approximate when necessary |
| Forgetting to re-optimize | Failing to update when constraints change | Periodically check for constraint changes |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Objective function**: `[Objective]: [Description]` + `[Convexity]: [Convex / Non-convex / Unknown]`
2. **Constraint list**: Each labeled `[Hard / Soft]` and `[Inequality / Equality]` `[Linear / Nonlinear]`
3. **Problem type classification**: `[Type]: [LP / QP / Convex / Non-convex / Combinatorial / Stochastic]`
4. **Feasible set analysis**: Which options are feasible? Which constraints are active?
5. **Optimal / satisficing solution**: `[Strategy]: [Gradient method / Interior-point / Global search / Satisficing / Pareto]`
6. **Sensitivity analysis**: Shadow prices of key constraints? How do conclusions change under X% variation?
7. **GPU viability** (if used for algorithm/operator/training): Does the solution method pass the eight-dimensional gate? Label as friendly / retrofittable / unfriendly, with adaptation recommendations.
8. **Action recommendations**: Explicitly state "Next, I will..."

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Modeling**: Optimization requires prior modeling -- defining objectives and constraints is itself an act of modeling.
- **Probability and statistics**: Optimization under uncertainty requires stochastic / robust optimization.
- **Transformation**: Transforming to the dual problem often makes optimization easier; duality is the most profound transformation in optimization.
- **Game-theoretic thinking**: Multiple decision-makers simultaneously optimizing constitutes a game; the Nash equilibrium is the stable point of multi-player optimization.
- **Algorithmic thinking**: Solution methods depend on algorithm design -- convex optimization uses gradient methods, combinatorial optimization requires branch-and-bound / heuristics.
- **Modern mathematics activation**: `../../references/books/optimization-ml.md` (GPU-friendly optimizers, feasibility of second-order methods), `matrix-analysis.md` (condition numbers, low-rank, preconditioning).
