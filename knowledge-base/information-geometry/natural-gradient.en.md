# Natural Gradient

## Minimal Definition
The natural gradient is the steepest descent direction with respect to the **Fisher information metric** on the parameter space. Unlike the naive gradient defined under the Euclidean metric, the natural gradient is defined under the Riemannian metric of the statistical manifold, making it invariant to the choice of parameterization (reparameterization invariant) and automatically adaptive to the curvature structure of the loss surface.

## Core Formulas

**Naive Gradient Descent** (Euclidean metric):
$$\theta_{t+1} = \theta_t - \eta \nabla_\theta \mathcal{L}(\theta)$$

**Natural Gradient Descent** (Fisher metric):
$$\tilde{\nabla} \mathcal{L}(\theta) = \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$
$$\theta_{t+1} = \theta_t - \eta \, \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$

where $\mathcal{I}(\theta)$ is the Fisher information matrix (see `probability/fisher-information.md`).

**Equivalent Derivation (Constrained Optimization Perspective)**: The natural gradient is the solution to the following constrained optimization problem —
$$\min_{\Delta\theta} \mathcal{L}(\theta + \Delta\theta) \quad \text{s.t.} \quad D_{KL}(p_\theta \| p_{\theta+\Delta\theta}) \leq \epsilon$$

Using the second-order expansion $D_{KL} \approx \frac{1}{2} \Delta\theta^T \mathcal{I} \Delta\theta$, solving via Lagrangian yields the natural gradient.

**K-FAC Approximation** (Kronecker-Factored Approximate Curvature):
$$\mathcal{I}_l \approx A_l \otimes B_l$$
where $A_l = \mathbb{E}[a_l a_l^T]$ (activation covariance) and $B_l = \mathbb{E}[g_l g_l^T]$ (gradient covariance), computed and inverted independently per layer.

## Applicable Problems
- **Ill-conditioned loss surface optimization**: When the Hessian condition number is large (narrow canyon), the natural gradient updates along the canyon floor, avoiding oscillation
- **Distributional parameter learning**: Updates to posterior parameters in variational inference; the natural gradient automatically handles the curvature of the Fisher-Rao manifold
- **Policy gradient (RL)**: The trust-region constraint in TRPO/PPO is equivalent to a step-size-limited version of the natural gradient

## AI Design Translation
- **K-FAC Optimizer**: Uses Kronecker decomposition to approximate the FIM, enabling approximate second-order optimization. Each layer maintains $(A_l, B_l)$, with inverse $A_l^{-1} \otimes B_l^{-1}$, reducing matrix inversion complexity from $O(d^3)$ to $O(d_A^3 + d_B^3)$
- **TRPO Trust-Region Policy Gradient**: Policy updates under the constraint $D_{KL}(\pi_{\theta_{\text{old}}} \| \pi_\theta) \leq \delta$, essentially natural gradient + line search
- **Natural Gradient in Variational Inference**: For exponential family parameters, the natural gradient equals the difference in expected sufficient statistics, avoiding Fisher matrix inversion

## Engineering Feasibility
- **Dimension 1 Tensorization ⚠️**: The Kronecker factors of the FIM are dense matrices and can be tensorized; the full FIM cannot
- **Dimension 2 GEMM-mappability ✅**: K-FAC's $A_l^{-1} (\nabla W_l) B_l^{-1}$ is two matrix multiplications, naturally GEMM
- **Dimension 3 Complexity ⚠️**: K-FAC adds $O(d_A^2 + d_B^2)$ per-layer covariance estimation + $O(d_A^3 + d_B^3)$ matrix inversion; diagonal approximation is $O(d)$
- **Dimension 4 Memory ⚠️**: Requires additional storage of $A_l$ and $B_l$ per layer ($O(d_A^2 + d_B^2)$); acceptable for LLMs but non-trivial
- **Dimension 5 Low Precision ⚠️**: Matrix inversion may be unstable in fp16; fp32 or Tikhonov regularization $(A + \epsilon I)^{-1}$ is needed
- **Dimension 6 Parallelism ✅**: Kronecker factors for each layer are computed independently; fully parallel across layers
- **Dimension 8 Operator Fusion ✅**: Natural gradient updates can be fused into the parameter update kernel

## Risks and Failure Conditions
- **K-FAC's inter-layer independence assumption is overly strong**: It assumes the Fisher information is block-diagonal across layers, ignoring inter-layer correlations. In deep networks, this may underestimate the effective curvature, leading to excessively large steps. Line search or trust-region safeguards are needed.
- **Burn-in problem for covariance estimation**: In early training, $A_l, B_l$ estimates are inaccurate and the natural gradient direction may be wrong. The standard practice is to warm up with Adam/SGD for the first few hundred steps, then switch to K-FAC.

## Further References
- Distillation draft: `references/books/` — no dedicated information geometry distillation draft at present
- Amari. *Natural Gradient Works Efficiently in Learning.* Neural Computation, 1998
- Martens & Grosse. "Optimizing Neural Networks with Kronecker-Factored Approximate Curvature." *ICML*, 2015
- Schulman et al. "Trust Region Policy Optimization." *ICML*, 2015
- Related knowledge cards: `probability/fisher-information.md`, `information-geometry/fisher-metric.md`
