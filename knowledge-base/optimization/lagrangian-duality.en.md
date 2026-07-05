# Lagrangian Duality

## Minimal Definition

Transforms a constrained optimization problem (primal) into a maximization problem over dual variables (dual). The dual function $g(\lambda, \nu) = \inf_x L(x, \lambda, \nu)$ provides a lower bound on the primal optimal value (weak duality); when the duality gap is zero (strong duality), the dual optimal value equals the primal optimal value.

## Core Formulas

- Primal problem: $\min_x f(x) \quad \text{s.t.} \quad g_i(x) \leq 0, \ h_j(x) = 0$
- Lagrangian: $L(x, \lambda, \nu) = f(x) + \sum_i \lambda_i g_i(x) + \sum_j \nu_j h_j(x)$
- Dual function: $g(\lambda, \nu) = \inf_x L(x, \lambda, \nu)$ (pointwise infimum over $x$, naturally concave)
- Weak duality: $d^* \leq p^*$ (dual optimum $\leq$ primal optimum, always holds)
- Strong duality condition (Slater): convex problem + existence of a strictly feasible point $g_i(x_0) < 0 \implies d^* = p^*$
- Complementary slackness: $\lambda_i^* g_i(x^*) = 0$ (at optimality, either the constraint is tight or the multiplier is zero)
- Minimax equivalence: strong duality $\iff \min_x \max_{\lambda \geq 0} L = \max_{\lambda \geq 0} \min_x L$

## Applicable Problems

- GAN / adversarial training: $\min_G \max_D V(D,G)$ is a minimax game; under strong duality, the saddle point = Nash equilibrium
- SVM dual: primal $O(d)$ dimensions converted to dual $O(n)$ dimensions + kernel Gram matrix; profitable when the number of samples $\ll$ dimensionality
- Constraint decomposition: large-scale problems decomposed by constraints into subproblems that can be solved in parallel after dual decomposition
- Dual interpretation of regularization parameters: $\lambda$-regularization $\iff$ a constrained primal problem (e.g., $\|w\|_2^2 \leq C$)
- Resource allocation / federated learning: global constraints decomposed into Lagrangian relaxations of local subproblems

## AI Design Translation

- **Minimax framework for adversarial training**: $L(\theta, \phi) = \mathbb{E}[\log D_\phi(x)] + \mathbb{E}[\log(1 - D_\phi(G_\theta(z)))]$. $G$ and $D$ alternate between gradient ascent and descent; the core operations are forward + backward passes (matmul chains). Gradient penalty / spectral norm can control the Lipschitz constant of $D$ and improve training stability, but it does not guarantee that a non-convex minimax problem has, or converges to, a benign saddle point.
- **SVM dual + kernel trick**: Primal $\min_w \frac{1}{2}\|w\|^2 + C\sum\xi_i$ converted to dual $\max_\alpha \sum\alpha_i - \frac{1}{2}\alpha^T(K \circ yy^T)\alpha$. The kernel Gram matrix $K_{ij} = k(x_i, x_j)$ is computed via matmul (linear kernel) or elementwise operations (RBF kernel). Dual variables $\alpha \in \mathbb{R}^n$ are solved using SMO or gradient projection.
- **Augmented Lagrangian constrained training**: $\mathcal{L}_{\text{AL}} = f(x) + \sum \lambda_i g_i(x) + \frac{\rho}{2}\sum g_i(x)^2$. The inner loop optimizes $x$ via SGD; the outer loop updates $\lambda$ via gradient ascent: $\lambda \leftarrow [\lambda + \rho g(x)]_+$. The $\rho$ term improves the concavity of the dual function (making the dual problem easier to solve), but does NOT guarantee global convergence for non-convex original problems. Convergence depends on: (a) constraint qualifications (e.g., LICQ/MFCQ), (b) second-order sufficient conditions, (c) $\rho$ being large enough to satisfy local convexity conditions.
- **Dual decomposition**: $\min \sum_k f_k(x_k)$ s.t. $\sum x_k \leq b$ decomposes into independent subproblems $\min_{x_k} f_k(x_k) + \lambda^T x_k$, with the master problem $\max_\lambda g(\lambda)$ solved via subgradient ascent. Naturally parallelizable, suitable for distributed training.
- **Dual perspective on the information bottleneck**: $\min I(Z;X) - \beta I(Z;Y)$ can be formulated as constrained optimization, where $\beta$ is the dual variable. The variational IB relaxes this via the ELBO, reducing to standard VAE training (reparameterization trick + SGD).

## Engineering Feasibility

- **Primary operations**: Lagrangian evaluation = primal objective + weighted sum of constraint terms (elementwise + reduce); dual gradient ascent = standard gradient update; SMO (SVM) = coordinate-descent-style $2 \times 2$ subproblems.
- **GPU friendliness**: High (dual function evaluation) to moderate (sequential solvers such as SMO). The inner-loop optimization of the augmented Lagrangian is entirely standard SGD (matmul chains), and dual variable updates are elementwise. SMO uses coordinate-wise updates, which are not GPU-friendly, but CPU-sufficient when $n$ is not large.
- **Complexity**: Dual function evaluation = one forward pass $O(\text{model FLOPs})$; dual gradient ascent per step $O(n)$ (number of constraints); SMO $O(n^2 d)$.
- **Low precision**: Dual variables $\lambda$ should be kept in fp32 (multipliers span a wide range, with overflow risk under low precision); model parameters can use bf16.

## Risks and Failure Conditions

- **Duality gap for non-convex problems**: Strong duality is only guaranteed for convex problems + Slater's condition. In non-convex neural network training, $d^* < p^*$ is common, and the dual solution does not yield a primal-feasible solution. Solution: for convex problems, augmented Lagrangian (with the exact penalty property when $\rho$ is sufficiently large, which can eliminate the duality gap); for non-convex problems, the duality gap may persist regardless of $\rho$, and the augmented Lagrangian only guarantees local convergence to KKT points -- alternatively, use SQP.
- **Dual variable oscillation**: Improper step sizes for gradient ascent on $\lambda$ can cause dual variable oscillation and primal infeasibility. Solution: use adaptive step sizes (Adam updates for $\lambda$) or an increasing $\rho$ schedule in the augmented Lagrangian.
- **Numerical determination of complementary slackness**: $\lambda_i g_i(x) = 0$ can only be satisfied to $\sim 10^{-6}$ in floating point; strict complementary slackness is unattainable. This affects SVM support vector identification; a threshold must be set.
- **Mode collapse in minimax training**: The non-convex-non-concave game in GAN $\min\max$ leads to mode collapse or training instability. Additional regularization such as gradient penalty (WGAN-GP) or spectral normalization is required.

## Further References

- Distilled notes: ../../references/books/optimization-ml.en.md (Ch 23 Lagrangian Duality, Section 23.5 Strong Duality, Section 23.6.3 Slater's Condition)
- Original text: Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 23 (Lagrangian Duality Section 23.1-23.6) + Chapter 17 (LP Duality)


## Routing Extensions
- If starting from the primal problem -> `constrained-optimization.en.md` (primal constrained optimization)
- If strong duality conditions are needed -> `convex-optimization.en.md` (strong duality theorem for convex problems)
- If the dual form of IB objective is involved -> `../probability/information-bottleneck.md` (variational dual of information bottleneck)

## Extensible Directions
- Augmented Lagrangian: penalty-enhanced Lagrangian methods
- Saddle point theory: existence and computation of Lagrangian saddle points
- KKT condition regularity: constraint qualifications and KKT necessary conditions
- Conic duality: duality theory for conic programming
- Fenchel duality: convex conjugates and Fenchel-Rockafellar duality
- Minimax duality: min-max theorems and duality gaps
