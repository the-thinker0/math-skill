# Constrained Optimization

## Minimal Definition

Minimizes an objective $f(x)$ over a constraint set $\mathcal{C} = \{x : g_i(x) \leq 0, h_j(x) = 0\}$. The optimal solution satisfies the KKT conditions (first-order necessary conditions): stationarity of the gradient (in the Lagrangian sense), primal feasibility, dual feasibility, and complementary slackness. Constrained optimization systematically incorporates "hard restrictions" into the optimization framework.

## Core Formulas

- KKT conditions (inequality constraints):
  - $\nabla_x L = \nabla f + \sum \lambda_i \nabla g_i + \sum \nu_j \nabla h_j = 0$ (stationarity)
  - $g_i(x) \leq 0, \ h_j(x) = 0$ (primal feasibility)
  - $\lambda_i \geq 0$ (dual feasibility)
  - $\lambda_i g_i(x) = 0$ (complementary slackness)
- Projected gradient method: $x_{k+1} = \text{proj}_{\mathcal{C}}(x_k - \alpha \nabla f(x_k))$
- Penalty function method: $\min_x f(x) + \frac{\rho}{2}\sum [\max(0, g_i(x))]^2 + \frac{\rho}{2}\sum h_j(x)^2$
- Augmented Lagrangian: $\mathcal{L}_\rho(x,\lambda) = f(x) + \sum \lambda_i g_i(x) + \frac{\rho}{2}\sum g_i(x)^2$
- Armijo line search (constrained version): $\alpha$ satisfies $f(\text{proj}_\mathcal{C}(x - \alpha \nabla f)) \leq f(x) - \sigma \alpha \|\nabla f\|^2$

## Applicable Problems

- Weight norm constraints: $\|w\|_2 \leq R$ (weight clipping / norm ball)
- Spectral norm constraints: $\sigma_{\max}(W) \leq 1$ (spectral normalization, stabilizing GAN/diffusion models)
- Safety constraints / RLHF: $\mathbb{E}[r_{\text{safety}}] \geq \tau$ (KL-constrained policy optimization)
- Fairness constraints: $|P(\hat{y}|A=0) - P(\hat{y}|A=1)| \leq \epsilon$
- Resource constraints: performance optimization under model size / FLOPs / inference latency budgets

## AI Design Translation

- **Weight clipping (WGAN)**: $W \leftarrow \text{clamp}(W, -c, c)$ is projection onto an $\ell_\infty$-box constraint. Implemented as `torch.clamp(W, -c, c)`, an elementwise operation with zero additional computation. Simple but coarse, less refined than spectral normalization.
- **Spectral normalization**: Constrains $\sigma_{\max}(W) \leq 1$, i.e., projects onto the operator norm ball. Uses power iteration to estimate $u \leftarrow W^T W u / \|W^T W u\|$, then normalizes $W \leftarrow W / \sigma_{\max}$. Two matvec + norm operations per step; built into PyTorch as `torch.nn.utils.spectral_norm`.
- **Projected gradient for $\ell_2$-ball constraints**: $\text{proj}(w) = w \cdot \min(1, R/\|w\|_2)$, implemented as `w * min(1, R / w.norm())`, one norm + elementwise operation, $O(d)$. Used in trust regions and adversarial robustness $\epsilon$-ball constraints.
- **Augmented Lagrangian for RLHF/PPO**: $\mathcal{L} = -\mathbb{E}[r] + \lambda(\text{KL}(\pi\|\pi_{\text{ref}}) - \epsilon) + \frac{\rho}{2}(\text{KL} - \epsilon)^2$. The inner loop optimizes $\pi$ via PPO; the outer loop updates $\lambda \leftarrow \lambda + \rho(\text{KL} - \epsilon)$. KL computation involves softmax + elementwise log-ratio, GPU-friendly.
- **Penalty method for sparsity/low-rank constraints**: $\mathcal{L}_{\text{penalty}} = \mathcal{L}_{\text{task}} + \rho \sum_i \max(0, \|w_i\|_1 - \tau)^2$ constrains per-layer sparsity to not exceed $\tau$. The penalty term is elementwise + reduce, differentiable and GPU-friendly. $\rho$ increasing schedule: $\rho \leftarrow \beta \rho$ ($\beta > 1$), doubling every several steps.

## Engineering Feasibility

- **Primary operations**: Projection = elementwise + norm ($O(d)$); penalty term = elementwise + reduce ($O(d)$); KKT gradient = standard backpropagation; power iteration = matvec ($O(d^2)$ or $O(nd)$).
- **GPU friendliness**: High. Projection steps in projected gradient methods are mostly cheap elementwise operations (norm-ball, box, $\ell_1$-ball); penalty terms / augmented Lagrangian only add elementwise computation; power iteration for spectral normalization is matvec.
- **Complexity**: Projection $O(d)$ (norm-ball / box) to $O(d \log d)$ ($\ell_1$-ball); penalty evaluation $O(d)$; spectral normalization $O(nd)$ per iteration; interior-point methods per step $O(d^3)$ (avoid in the inner training loop).
- **Low precision**: Projection operations are stable under bf16 (norm and clamp do not involve delicate numerical operations); the penalty coefficient $\rho$ must be range-controlled to avoid overflow (use fp32 when $\rho > 10^6$).

## Risks and Failure Conditions

- **Non-differentiability of projection**: $\text{proj}_\mathcal{C}(x)$ is non-differentiable at constraint boundaries (e.g., gradient discontinuity when $\|x\|_2 = R$), affecting backpropagation. Solution: smooth via the Moreau envelope, or replace hard projection with penalty methods / augmented Lagrangian.
- **Ill-conditioning of penalty methods**: As $\rho \to \infty$, the Hessian condition number $\kappa \sim \rho$, slowing gradient descent convergence. Solution: augmented Lagrangian ($\rho$ need not go to infinity to exactly satisfy constraints), or dual ascent methods.
- **Expensive projection onto general polyhedra**: Projection onto $\mathcal{C} = \{x : Ax \leq b\}$ requires solving a QP with complexity $O(d^3)$, infeasible at every step. Solution: switch to penalty methods or augmented Lagrangian to avoid explicit projection.
- **KKT is only a necessary condition**: For non-convex problems, KKT points are not necessarily local optima (they may be saddle points). Second-order sufficient conditions (positive definiteness of the Lagrangian Hessian on the constraint tangent space) are needed for verification.
- **Numerical precision of complementary slackness**: $\lambda_i g_i(x) = 0$ can only be satisfied to $\sim \epsilon$ in floating point, making active set identification difficult. The augmented Lagrangian naturally avoids this issue (it does not rely on exact complementary slackness).

## Further References

- Distilled notes: references/books/optimization-ml.md (Ch 20-21 Equality/Inequality Constraints and KKT, Ch 24 Constrained Algorithms Section 24.3 Projected Gradient, Section 24.5 Augmented Lagrangian, Section 24.6 Penalty Methods)
- Original text: Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 20-21 (Equality & Inequality Constraints) + Chapter 24 (Algorithms for Constrained Optimization Section 24.2-24.6)


## Routing Extensions
- If a dual perspective is needed -> `lagrangian-duality.md` (Lagrangian duality theory)
- If constraints are on a manifold -> `riemannian-optimization.md` (Riemannian optimization for manifold constraints)
- If penalty term design is needed -> `constraint-penalty` (design pattern layer for constraint penalties)

## Extensible Directions
- Penalty / barrier methods: converting constraints to penalty terms
- Sequential quadratic programming (SQP): second-order methods for constrained optimization
- Active set methods: identifying the active constraint set
- Constraint qualification: LICQ, MFCQ and other regularity conditions
- Exact penalty: exact solutions with finite penalty parameters
- Augmented Lagrangian methods: combining duality and penalty functions
