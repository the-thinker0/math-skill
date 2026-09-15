# Natural Gradient

## Minimal Definition
The natural gradient is the metric gradient for the Fisher information metric; its **negative** gives steepest descent. For a smooth invertible change of identifiable coordinates, this vector field transforms consistently. A finite Euler update, damping, or an approximate Fisher generally loses exact reparameterization invariance; Fisher describes distributional sensitivity rather than an arbitrary loss Hessian.

## Core Formulas

**Naive Gradient Descent** (Euclidean metric):
$$\theta_{t+1} = \theta_t - \eta \nabla_\theta \mathcal{L}(\theta)$$

**Natural Gradient Descent** (Fisher metric):
$$\tilde{\nabla} \mathcal{L}(\theta) = \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$
$$\theta_{t+1} = \theta_t - \eta \, \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$

where $\mathcal{I}(\theta)$ is the Fisher information matrix (see `../probability/fisher-information.en.md`).

**Equivalent Derivation (Constrained Optimization Perspective)**: The natural gradient is the solution to the following constrained optimization problem —
$$\min_{\Delta\theta} \mathcal{L}(\theta + \Delta\theta) \quad \text{s.t.} \quad D_{KL}(p_\theta \| p_{\theta+\Delta\theta}) \leq \epsilon$$

Linearize the objective as $\mathcal L(\theta)+\nabla\mathcal L^T\Delta\theta$ **and** approximate KL quadratically. For nonsingular Fisher and nonzero gradient the local trust-region solution is $\Delta\theta=-\sqrt{2\epsilon/(\nabla\mathcal L^T\mathcal I^{-1}\nabla\mathcal L)}\,\mathcal I^{-1}\nabla\mathcal L$. This is a local approximation, not the exact solution of the nonlinear constrained problem.

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
- **D2[~]**: For $W\in\mathbb R^{b\times a}$, activation factor $A\in\mathbb R^{a\times a}$, output-score factor $B\in\mathbb R^{b\times b}$ and column-vectorization convention, $(A\otimes B)^{-1}\operatorname{vec}(G)=\operatorname{vec}(B^{-1}GA^{-1})$. The factor order must match weight dimensions.
- **D3[~]**: For $B$ activation/score samples, factor estimation costs $O(B(d_A^2+d_B^2))$, dense inversion $O(d_A^3+d_B^3)$, and gradient preconditioning has additional GEMM costs. Record refresh frequency and amortization.
- **D4[~]**: Store $O(d_A^2+d_B^2)$ factors per layer plus inverses, damping state and workspaces. LLM-scale feasibility is architecture/device dependent; some layers may need diagonal or low-rank approximations.
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
- If a general Riemannian optimization framework is needed -> `../optimization/riemannian-optimization.en.md` (natural gradient is a special case of Riemannian gradient)
- If an information-theoretic perspective is needed -> `../probability/fisher-information.en.md` (statistical interpretation of Fisher information)

## Extensible Directions
- Mirror descent as natural gradient: equivalence on dual spaces
- Amari's alpha-geometry: alpha-connection family
- Natural policy gradient (RL): natural gradient in reinforcement learning
- Natural evolution strategies (NES): NES optimizer
- Practical natural gradient: efficient implementations such as K-FAC, diagonal approximations
- Adaptive natural gradient: methods for dynamically estimating Fisher information
