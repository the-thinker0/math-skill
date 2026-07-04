# Mathematical Sources and Classic Texts

## Euler-Lagrange Variational Equation & Brachistochrone (1696)

> In 1696, Johann Bernoulli posed the brachistochrone problem: under gravity alone, along which curve does a particle descend from A to B in the shortest time? The answer is the cycloid.

**Core equation**: For the functional J[y] = ∫_{a}^{b} F(x, y, y') dx, the extremizing function satisfies

> ∂F/∂y - d/dx(∂F/∂y') = 0 (Euler-Lagrange equation)

For the brachistochrone, F = √(1 + y'²) / √(2g(y₀ - y)). Substituting into the Euler-Lagrange equation yields the parametric equations of the cycloid: x = a(θ - sin θ), y = a(1 - cos θ).

**Key idea**: The calculus of variations reduces "optimization over an entire class of functions" to solving a differential equation — this is the origin of infinite-dimensional optimization. Euler (1744) systematized the calculus of variations; Lagrange (1788) introduced the δ notation and the method of multipliers, both in the same lineage. The calculus of variations later evolved into optimal control theory (Pontryagin's Maximum Principle, 1961), with wide applications in spacecraft trajectory design, robotic path planning, and many other fields.

## Fermat & Weierstrass Conditions for Unconstrained Optimization

> Fermat (1636): A necessary condition for a differentiable function f to attain a local extremum at x* is ∇f(x*) = 0.
> Weierstrass (19th c.): If f is twice differentiable and ∇f(x*) = 0, then the Hessian H(x*) is positive definite ⇔ x* is a strict local minimum; H(x*) is negative definite ⇔ x* is a strict local maximum.

For convex functions, ∇f(x*) = 0 is not only necessary but also sufficient — and x* is the global minimum.

**Key idea**: First-order conditions locate stationary points; second-order conditions determine the nature of the extremum — the most fundamental theorem of unconstrained optimization. The condition ∇f = 0 is the convergence target of virtually all iterative optimization algorithms (gradient descent, Newton's method).

## Lagrange Multipliers (1788)

> Finding the extremum of f(x) subject to g(x) = 0 is equivalent to finding the unconstrained extremum of L(x,λ) = f(x) - λg(x).

**Key idea**: Transform a constrained optimization problem into an unconstrained one. At the optimal solution, the gradient of the objective function is parallel to the gradient of the constraint function: ∇f(x*) = λ∇g(x*).

## Pareto Optimality (Vilfredo Pareto, ~1906)

> In multi-objective optimization, a solution x is Pareto optimal if there does not exist y such that f_i(y) ≤ f_i(x) for all i with at least one f_j(y) < f_j(x) (strict improvement).

In *Manuale di economia politica* (1906), Pareto introduced this concept into economics: the efficiency frontier of resource allocation. The Pareto frontier {f(x) : x is Pareto optimal} characterizes all trade-off solutions that cannot be simultaneously improved. Mathematically, for objectives f₁,...,fₘ, the Pareto frontier is {y ∈ ℝᵐ : y = (f₁(x),...,fₘ(x)), x Pareto optimal} — it is a (generally non-convex) surface in objective space.

> Weighted scalarization: Convert multi-objective min f₁,...,fₘ into single-objective min Σw_i f_i (w_i > 0); each weight combination corresponds to a point on the Pareto frontier. This is a standard method for computing the Pareto frontier, but it cannot enumerate all Pareto-optimal solutions on non-convex frontiers.

**Key idea**: Multi-objective optimization has no single "optimal solution" but rather a set of Pareto-optimal solutions among which trade-offs must be made. This is ubiquitous in economics (efficiency vs. equity), engineering (performance vs. cost), and machine learning (accuracy vs. complexity).

## Game Theory & Optimization (von Neumann, 1928; Nash, 1950)

> Nash equilibrium: A strategy profile (s₁*, ..., sₙ*) such that for each player i, s_i* is the best response given the other players' strategies — i.e., no player has an incentive to unilaterally deviate.

Von Neumann (1928) proved the minimax theorem for zero-sum games: max_{x} min_{y} f(x,y) = min_{y} max_{x} f(x,y), which is essentially a precursor of linear programming duality. Nash (1950) generalized the equilibrium concept to non-zero-sum games; a Nash equilibrium is an " mutually optimal" optimization — each player's optimization problem takes the other players' strategies as constraints.

> Existence of Nash equilibrium: Nash (1950) used the Brouwer fixed-point theorem to prove that every finite game has at least one mixed-strategy Nash equilibrium. This reveals a deep connection between game theory and topology.

**Key idea**: Game theory extends optimization from "single-agent decision-making" to "multi-agent interactive decision-making" — optimality is no longer with respect to nature, but the best response to other rational agents.

## Karush-Kuhn-Tucker Conditions (1939/1951)

Necessary conditions for inequality-constrained optimization:

> For min f(x) s.t. g_i(x) ≤ 0, h_j(x) = 0, the optimal solution x* satisfies:
> - Stationarity: ∇f(x*) + Σμ_i∇g_i(x*) + Σλ_j∇h_j(x*) = 0
> - Primal feasibility: g_i(x*) ≤ 0, h_j(x*) = 0
> - Complementary slackness: μ_i · g_i(x*) = 0, μ_i ≥ 0

Karush (1939, master's thesis) first derived these conditions; Kuhn & Tucker (1951) independently rediscovered and widely disseminated them.

**Key idea**: At the optimal solution, either a constraint is inactive (μ_i = 0) or it is tight (g_i(x*) = 0). Complementary slackness is the cornerstone of duality theory — it ties the KKT conditions to a zero duality gap. When a constraint qualification holds (e.g., LICQ: the gradients of active constraints are linearly independent), the KKT conditions are necessary for optimality.

## Linear Programming Duality (Farkas, 1902; Dantzig-von Neumann, 1947)

> Farkas' Lemma (1902): Ax = b, x ≥ 0 has a solution ⟺ Aᵀy ≥ 0, bᵀy < 0 has no solution — this is the geometric foundation of LP duality.

> Strong duality theorem: If the primal LP min cᵀx s.t. Ax = b, x ≥ 0 has a feasible solution, then the optimal values of the primal and the dual max bᵀy s.t. Aᵀy ≤ c are equal. The components of the dual variable y are called shadow prices — they measure the "marginal value" of each constraint.

**Key idea**: Every LP has a "mirror" problem — the primal views the problem in terms of cost, the dual in terms of value. Zero duality gap is a profound fact: the minimum cost of resources equals the maximum revenue valued at shadow prices.

## Simplex Method (Dantzig, 1947)

The fundamental algorithm for linear programming. It searches for the optimal solution by moving along vertices of the feasible region.

> Klee-Minty cube (1973): There exist LP instances for which the simplex method visits all 2ⁿ vertices — exponential worst-case complexity.

> Interior-Point Methods: Karmarkar (1984) proposed a polynomial-time LP algorithm that converges along the central path through the interior of the feasible region, avoiding vertex enumeration. Modern interior-point methods (e.g., Mehrotra predictor-corrector) perform excellently in both practice and theory.

**Key idea**: The optimal solution of a linear program always lies at a vertex of the feasible region. The simplex method exploits this structure by moving along edges; interior-point methods approach from the inside — the two are complementary.

## Duality Theory

> Weak duality: For any optimization problem, the dual optimal value d* ≤ primal optimal value p* (duality gap = p* - d* ≥ 0).

> Strong duality (Slater's condition): If a convex optimization problem has a strictly feasible point (Slater point: g_i(x) < 0 strictly), then d* = p*, and the duality gap is zero.

> Duality provides lower bounds (the primal optimal value ≥ the dual value), which is a critical tool in branch-and-bound, cutting-plane, and related algorithms.

**Key idea**: Duality connects "minimizing cost" with "maximizing value" — two perspectives on the same problem. Slater's condition guarantees "no information loss" in convex optimization.

## Gradient Descent (Cauchy, 1847; Robbins-Monro, 1951)

> Cauchy (1847) proposed the method of steepest descent: x_{k+1} = x_k - α_k ∇f(x_k), iterating along the negative gradient direction with step size α_k. For L-smooth convex functions (Lipschitz-continuous gradient), with step size α = 1/L, f(x_k) - f(x*) ≤ L‖x₀ - x*‖² / (2k) — a convergence rate of O(1/k).

> Newton's Method: x_{k+1} = x_k - H(x_k)⁻¹ ∇f(x_k), using second-order information, achieves quadratic convergence O(‖x_k - x*‖²) near the optimum.

> Stochastic Gradient Descent (SGD): Robbins & Monro (1951) proposed stochastic approximation, replacing the true gradient with a noisy estimate g_k ≈ ∇f(x_k). The conditions Σα_k = ∞, Σα_k² < ∞ guarantee convergence. SGD converges in expectation at the cost of variance — minibatching is a trade-off between variance and efficiency.

**Key idea**: Gradient descent is the most naive form of optimization — "go where it is steepest." SGD extends this idea to large-data settings: one need not examine all the data, only a random sample suffices to approximate the direction. The training of deep neural networks relies almost entirely on SGD and its variants (Adam, AdaGrad, etc.).

## Integer Programming & NP-Hardness (Cook, 1971; Karp, 1972)

> Integer Linear Programming (ILP): min cᵀx s.t. Ax ≤ b, x ∈ ℤⁿ — variables take integer values. Even 0-1 ILP (x ∈ {0,1}ⁿ) is NP-hard.

> Cook (1971) proved that SAT is NP-complete (the Cook-Levin theorem); Karp (1972) listed 21 NP-complete problems, including integer programming, the knapsack problem, and the traveling salesman problem. ILP is NP-hard — no polynomial-time exact algorithm exists (under the assumption P ≠ NP).

> Convex relaxation: Relaxing x ∈ ℤⁿ to x ∈ ℝⁿ yields an LP whose optimal value provides a lower bound for the ILP — this is precisely the core mechanism of branch-and-bound.

**Key idea**: Discrete optimization is fundamentally harder than continuous optimization. The seemingly minor constraint of "integrality" pushes a problem from polynomial-time solvability to NP-hardness. Branch-and-bound and cutting-plane methods are the principal exact methods; heuristics are more commonly used in practice.

## Convex Optimization (Boyd & Vandenberghe, 2004)

> Convex optimization: min f(x) s.t. g_i(x) ≤ 0 (convex), h_j(x) = 0 (affine), x ∈ C (convex set). When f is convex, a local minimum is a global minimum.

> Key properties: (1) Local minimum = global minimum; (2) The feasible region is a convex set; (3) Strong duality holds under Slater's condition; (4) Interior-point methods can solve it in polynomial time.

Important subclasses encompassed by convex optimization:
- LP (Linear Programming): f linear, constraints linear
- QP (Quadratic Programming): f quadratic, constraints linear
- SOCP (Second-Order Cone Programming): constraints include second-order cones ‖Ax + b‖ ≤ cᵀx + d
- SDP (Semidefinite Programming): constraints include positive semidefinite matrix conditions X ≥ 0
- GP (Geometric Programming): convex after logarithmic transformation

Boyd & Vandenberghe's *Convex Optimization* (2004) unified all of the above problem classes and became the standard textbook and engineering reference for modern optimization. Convex optimization marks the boundary of "efficiently solvable optimization" — convexity guarantees algorithmic convergence and global optimality of solutions.

**Key idea**: Convex optimization is the "sweet spot" of optimization theory — rich enough to encompass a vast number of practical problems, yet structured enough to guarantee tractability. Non-convex problems are often approximated via convex relaxation.

## Bellman's Principle of Optimality (1957)

> "An optimal policy has the property that whatever the initial state and initial decision are, the remaining decisions must constitute an optimal policy with regard to the state resulting from the first decision."

> Recursive equation: V(s) = max_a { R(s,a) + γ · V(s') }, where s' is the result of the state transition.

**Key idea**: The core of dynamic programming — substructures of an optimal solution are themselves optimal. The Bellman equation decomposes multi-stage decision-making into single-stage subproblems and is the theoretical foundation of reinforcement learning.

## The Philosophical Significance of Optimization

The core of optimization thinking is **making the best choice under constraints** — this is not only a mathematical question but also a question about life. Most decisions in life can be formulated as optimization problems:

- **Objective function**: What do you want to maximize? (Happiness? Achievement? Freedom?)
- **Constraints**: What limitations do you face? (Time? Money? Ability?)
- **Feasible region**: What choices are available to you under the constraints?
- **Optimal solution**: Among all choices, which one maximizes the objective?
- **Dual perspective**: Viewing the problem in terms of "cost" or "value" yields the same answer — this is the philosophy of strong duality.
- **Convex vs. non-convex**: Convex optimization has a unique global optimum; non-convex optimization has multiple local optima — the predicament of life lies precisely in the fact that the world is non-convex.

## Timeline of Optimization

| Year | Event |
|------|-------|
| 1636 | Fermat proposes the necessary condition ∇f = 0 for unconstrained extrema |
| 1696 | Johann Bernoulli poses the brachistochrone problem; the seeds of the calculus of variations |
| 1744 | Euler systematizes the calculus of variations |
| 1788 | Lagrange publishes the method of multipliers in *Mécanique analytique* |
| 1902 | Farkas' Lemma — the geometric foundation of LP duality |
| ~1906 | Pareto introduces the efficiency frontier concept into economics |
| 1928 | Von Neumann proves the minimax theorem (zero-sum games) |
| 1939 | Karush derives the KKT conditions (master's thesis) |
| 1947 | Dantzig invents the simplex method; von Neumann establishes LP duality |
| 1950 | Nash proves the existence of equilibria in non-zero-sum games |
| 1951 | Kuhn & Tucker publish the KKT conditions; Robbins-Monro propose stochastic approximation |
| 1957 | Bellman publishes dynamic programming and the principle of optimality |
| 1971 | Cook proves NP-completeness (the Cook-Levin theorem) |
| 1972 | Karp lists 21 NP-complete problems |
| 1973 | Klee-Minty prove exponential worst-case complexity of the simplex method |
| 1984 | Karmarkar proposes the polynomial-time interior-point method |
| 2004 | Boyd & Vandenberghe publish *Convex Optimization* |