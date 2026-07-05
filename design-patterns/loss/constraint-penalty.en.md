# Constraint Penalty
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
When the design involves hard constraints (e.g., probability simplex, orthogonality, capacity limits, load balancing) but end-to-end training is required. Typical scenarios: (1) MoE routing probabilities must lie on the $K$-simplex with load balancing; (2) Expert activation count is constrained (top-k); (3) Subspace projection matrices must satisfy orthogonality $W^T W = I$; (4) Feature norms are bounded $\|z\| \leq R$. Core objective: **transform mathematical constraints into differentiable penalty terms integrated into gradient-based variational**.

## Mathematical Inspiration
- Lenses: ../../lenses/variational.en.md (constrained variational, Lagrangian duality, KKT conditions), ../../lenses/geometric.en.md (manifold projection)
- Knowledge: ../../knowledge-base/optimization/lagrangian-duality.en.md (augmented Lagrangian method, penalty function method), ../../knowledge-base/matrix-analysis/projection.en.md (projection operators, constraint sets)

## Required Mathematical Knowledge
- **Penalty Function Method**: $\min f(x)$ s.t. $g(x)=0 \to \min f(x) + \rho/2 \cdot \|g(x)\|^2$ -- $\rho$ is gradually increased (exterior point method), driving constraint violation $\|g(x)\| \to 0$
- **Augmented Lagrangian Method**: $\min f(x) + \lambda^T g(x) + \rho/2 \cdot \|g(x)\|^2$ -- introduces dual variable $\lambda$, alternating between updating $\lambda \leftarrow \lambda + \rho \cdot g(x)$ and optimizing $x$; converges better than pure penalty methods
- **Projected Gradient Method**: $x_{k+1} = \text{Proj}_C(x_k - \alpha \nabla f(x_k))$ -- for simple constraint sets $C$ (e.g., simplex, sphere), closed-form projection formulas exist
- **Barrier Function Method**: $\min f(x) - \mu \sum \log(-g_i(x))$ for inequality constraints $g_i(x) \leq 0$ -- as $\mu \to 0$, approaches the constrained optimum

## AI Module Form
```
Module: ConstraintPenalty
Input: constraint violations g(x) in R^m (equality constraints), h(x) in R^p (inequality constraints)

Method 1 - Adaptive Penalty Function (most commonly used):
  L_penalty = Sum_i rho_i/2 * g_i(x)^2  +  Sum_j rho_j/2 * max(0, h_j(x))^2
  // rho updated dynamically: each epoch rho_i *= gamma (gamma=2~10) until constraints are satisfied
  // Different constraints can have different rho values, adapted to violation severity

Method 2 - Augmented Lagrangian Method (ALM):
  L_ALM = lambda^T * g(x) + rho/2 * ||g(x)||^2
  // lambda is a learnable parameter (nn.Parameter), updated via gradient ascent:
  lambda.data += rho * g(x).detach()   // dual ascent step
  // Converges faster than pure penalty, avoids rho -> infinity
  For inequality constraints h(x) <= 0:
  L_ALM = Sum_j 1/(2*rho) * [max(0, lambda_j + rho*h_j(x))^2 - lambda_j^2]
  // lambda update: lambda_j <- max(0, lambda_j + rho*h_j(x))
  // Strictly feasible constraints (lambda_j + rho*h_j(x) < 0) are not penalized

Method 3 - Softmax Projection onto Simplex (load balancing special case):
  p = softmax(logits / tau)           // project onto Delta^{K-1}
  L_balance = ||p - 1/K||^2           // uniformity penalty
  // Or Switch Transformer auxiliary loss:
  L_aux = K * Sum_k f_k * P_k         // f_k = allocation fraction, P_k = average probability

Method 4 - Orthogonal Constraint Projection:
  W_proj = W * (W^T W)^{-1/2}       // project onto Stiefel manifold via matrix square root inverse
  // Or parameterize via Cayley transform: W = (I-A)(I+A)^{-1} * W_0, A is skew-symmetric
```

## Implementable Architectures
- **Loss Wrapper**: ConstraintLoss(base_loss, constraints, rho_schedule) -- forward computes base_loss + Sum constraint.penalty()
- **Dual Variable Management**: equality multipliers can use nn.Parameter with a negative learning rate for gradient ascent; inequality multipliers must satisfy $\lambda \geq 0$, so use explicit projected updates `lambda <- max(0, lambda + rho*h(x))` or clamp after optimizer steps
- **Warm-up Strategy**: Optimize only base_loss for the first $N$ steps, then progressively activate constraint penalties
- **Constraint Monitoring**: Record $\|g(x)\|$ at each step for visualization and adaptive rho adjustment

## GPU Feasibility
- **Tensorization**: Constraint violations are vector/matrix operations; penalty terms are element-wise squared sums
- **GEMM-mappability**: Load balancing $f_k$, $P_k$ computation uses softmax + reduce_sum; orthogonal constraint uses matmul
- **Complexity**: Penalty computation is $O(m)$ or $O(m^2)$, far smaller than the main network forward pass; negligible
- **Memory & KV-Cache**: Only additional storage for lambda ($m$ dimensions) and rho ($m$ dimensions); minimal overhead
- **Low Precision Stability**: Penalty terms are squaring operations, safe under fp16; ALM lambda updates are recommended in fp32 to avoid accumulated errors
- **Parallelism & Communication**: Constraints are independently computable and parallelizable; on multiple GPUs, lambda updates require all-reduce of $g(x)$
- **Sparse Structure**: $\max(0, h(x))^2$ has zero gradient when constraints are satisfied, naturally sparse activation
- **Operator Fusion**: Constraint computation + weighted summation + merging with base_loss can be fused into a single kernel

## Paper Phrasing
"We employ the augmented Lagrangian method to convert hard constraints $g(x)=0$ into differentiable penalty terms $\lambda^T g(x) + \rho/2 \|g(x)\|^2$, using alternating dual ascent updates of $\lambda$ rather than relying only on $\rho \to \infty$. Under convexity, constraint qualifications such as LICQ/MFCQ, and sufficiently accurate inner solves, ALM can converge to KKT solutions; in non-convex training, report the measured constraint-violation curve instead of claiming a universal $O(1/\rho)$ rate."

## Risks
- Excessively fast rho growth leads to ill-conditioned variational landscapes (deteriorating condition numbers), causing gradient vanishing or explosion
- ALM lambda update frequency and step size require tuning; too fast causes oscillation, too slow impedes convergence
- When multiple constraints coexist, the relative ratios of their rho values influence the variational trajectory
- Projection operations (e.g., matrix square root inverse) are computationally expensive and numerically unstable
