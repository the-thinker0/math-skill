# Constraint Penalty
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

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

```python
# Equality g(x)=0, inequality h(x)<=0; multipliers are state, not primal-optimizer params.
L_eq = dot(nu, g) + 0.5 * rho * (g**2).sum()
L_ineq = ((relu(lam + rho*h)**2 - lam**2) / (2*rho)).sum()
primal_loss = task_loss + L_eq + L_ineq
# Perform specified primal inner updates, then update multipliers without autograd:
with no_grad():
    nu += rho * equality_violation(x)
    lam = clamp(lam + rho * inequality_violation(x), min=0)
```
Finite quadratic penalties need not exactly enforce constraints. ALM convergence needs its own regularity, solve accuracy and update assumptions; report primal/dual/KKT residuals for the chosen regime.

`softmax(logits/tau)` **parameterizes the interior of the simplex**; it is not Euclidean projection onto it. Euclidean simplex projection instead has $p_i=\max(v_i-\theta,0)$ with $\theta$ chosen so $\sum_i p_i=1$. Individual uniform token probabilities and aggregate expert load balancing are distinct constraints.

For full-column-rank $W\in\mathbb R^{d\times r}$, $d\ge r$, the polar factor $W(W^TW)^{-1/2}$ has orthonormal columns. Rank deficiency requires a deliberate completion/regularization policy; adding jitter makes this only approximately orthogonal.

## Implementable Architectures

- Loss wrapper separates task and constraint residuals with explicit scales.
- Store multipliers in buffers or a separate ascent optimizer; avoid undocumented negative learning rates and `.data` mutation.
- Adapt penalty weights using measured residuals, not automatic aggressive growth.
- Keep a feasible construction when exact constraints are required at every iterate.

## GPU Feasibility

- **D1/D2[~]**: Scalar penalties are reductions; computing the constraints themselves may require GEMM, decompositions or network evaluations.
- **D3/D4[~]**: $m$ already-computed scalar residuals cost $O(m)$ to penalize, but an orthogonality residual for $W\in\mathbb R^{d\times r}$ costs $O(dr^2)$ and stores $O(r^2)$ intermediates. Count the constraint work separately.
- **D5[~]**: Squaring in fp16 can overflow; accumulate penalties/multipliers in fp32 and scale constraints consistently.
- **D6[~]**: Independent residuals can parallelize; global constraints need reduction before multiplier updates, while local constraints need not communicate.
- **D7/D8[~]**: Zero gradients on satisfied inequality penalties do not create block-sparse forward computation. Elementwise penalties can fuse, but expensive constraint evaluation remains.

## Paper Phrasing
"We employ the augmented Lagrangian method to convert hard constraints $g(x)=0$ into differentiable penalty terms $\lambda^T g(x) + \rho/2 \|g(x)\|^2$, using alternating dual ascent updates of $\lambda$ rather than relying only on $\rho \to \infty$. Under convexity, constraint qualifications such as LICQ/MFCQ, and sufficiently accurate inner solves, ALM can converge to KKT solutions; in non-convex training, report the measured constraint-violation curve instead of claiming a universal $O(1/\rho)$ rate."

## Risks
- Excessively fast rho growth leads to ill-conditioned variational landscapes (deteriorating condition numbers), causing gradient vanishing or explosion
- ALM lambda update frequency and step size require tuning; too fast causes oscillation, too slow impedes convergence
- When multiple constraints coexist, the relative ratios of their rho values influence the variational trajectory
- Projection operations (e.g., matrix square root inverse) are computationally expensive and numerically unstable
