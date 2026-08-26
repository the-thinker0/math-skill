# Natural Gradient

## Minimal Definition
The natural gradient is the steepest descent direction with respect to the **Fisher information metric** on the parameter space. Unlike the naive gradient defined under the Euclidean metric, the natural gradient is defined under the Riemannian metric of the statistical manifold, making it covariant under reparameterization (the direction as a geometric object does not change with coordinate choice) and automatically adaptive to the curvature structure of the loss surface.

## Core Formulas

**Naive Gradient Descent** (Euclidean metric):
$$\theta_{t+1} = \theta_t - \eta \nabla_\theta \mathcal{L}(\theta)$$

**Natural Gradient Descent** (Fisher metric):
$$\tilde{\nabla} \mathcal{L}(\theta) = \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$
$$\theta_{t+1} = \theta_t - \eta \, \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$

where $\mathcal{I}(\theta)$ is the Fisher information matrix (see `../probability/fisher-information.en.md`).

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
- **Natural Gradient in Variational Inference (SVI)**: For the natural parameter $\lambda$ of an exponential-family global variational distribution, the SVI natural gradient is the gap between the coordinate-optimal and the current natural parameter, $\hat\lambda - \lambda$, where $\hat\lambda = \eta_0 + N\,\mathbb{E}_q[T(X)]$ ($\eta_0$: prior hyperparameter; $N$: number of samples; not the learning rate $\eta$ above), updated as $\lambda \leftarrow (1-\rho)\lambda + \rho\,\hat\lambda$ (Hoffman et al. 2013), avoiding explicit Fisher inversion. The gap is taken relative to the **current natural parameter**, not as "$\mathbb{E}_q[T]$ minus a prior expectation of sufficient statistics"

## Engineering Feasibility
- **D1[~]**: The Kronecker factors of the FIM are dense matrices and can be tensorized; the full FIM cannot
- **D2[v]**: K-FAC's $A_l^{-1} (\nabla W_l) B_l^{-1}$ is two matrix multiplications, naturally GEMM
- **D3[~]**: K-FAC adds $O(d_A^2 + d_B^2)$ per-layer covariance estimation + $O(d_A^3 + d_B^3)$ matrix inversion; diagonal approximation is $O(d)$
- **D4[~]**: Requires additional storage of $A_l$ and $B_l$ per layer ($O(d_A^2 + d_B^2)$); acceptable for LLMs but non-trivial
- **D5[~]**: Matrix inversion may be unstable in fp16; fp32 or Tikhonov regularization $(A + \epsilon I)^{-1}$ is needed
- **D6[v]**: Kronecker factors for each layer are computed independently; fully parallel across layers
- **D8[v]**: Natural gradient updates can be fused into the parameter update kernel

## Risks and Failure Conditions
- **K-FAC's inter-layer independence assumption is overly strong**: It assumes the Fisher information is block-diagonal across layers, ignoring inter-layer correlations. In deep networks, this may underestimate the effective curvature, leading to excessively large steps. Line search or trust-region safeguards are needed.
- **Burn-in problem for covariance estimation**: In early training, $A_l, B_l$ estimates are inaccurate and the natural gradient direction may be wrong. The standard practice is to warm up with Adam/SGD for the first few hundred steps, then switch to K-FAC.

## Further References
- Distillation draft: `../../references/books/` — no dedicated information geometry distillation draft at present
- Amari. *Natural Gradient Works Efficiently in Learning.* Neural Computation, 1998
- Martens & Grosse. "Optimizing Neural Networks with Kronecker-Factored Approximate Curvature." *ICML*, 2015
- Schulman et al. "Trust Region Policy Optimization." *ICML*, 2015
- Related knowledge cards: `../probability/fisher-information.en.md`, `fisher-metric.en.md`


## Routing Extensions
- If metric definition is needed -> `fisher-metric.en.md` (Fisher metric is the foundation of natural gradient)
- If a general Riemannian optimization framework is needed -> `../optimization/riemannian-optimization.md` (natural gradient is a special case of Riemannian gradient)
- If an information-theoretic perspective is needed -> `../probability/fisher-information.en.md` (statistical interpretation of Fisher information)

## Extensible Directions
- Mirror descent as natural gradient: equivalence on dual spaces
- Amari's alpha-geometry: alpha-connection family
- Natural policy gradient (RL): natural gradient in reinforcement learning
- Natural evolution strategies (NES): NES optimizer
- Practical natural gradient: efficient implementations such as K-FAC, diagonal approximations
- Adaptive natural gradient: methods for dynamically estimating Fisher information
