# Fisher Information

## Minimal Definition
Fisher information measures the **sensitivity of a parametric family of probability distributions to its parameters** — that is, how much information observed data provides about the parameter $\theta$. It defines a natural Riemannian metric on the statistical manifold (the Fisher information matrix = the metric tensor), and is the cornerstone of information geometry.

**Regularity conditions**: Score/Hessian identities and Cramér–Rao require differentiability, interchange of integration and differentiation, and appropriate support/integrability conditions; parameter-dependent support can invalidate them. For $n$ iid observations, total information is $n\mathcal I_1(\theta)$. Fisher is PSD, and only nonsingular identifiable directions define a Riemannian metric.

## Core Formulas

**Fisher Information (scalar parameter)**:
$$\mathcal{I}(\theta) = \mathbb{E}_\theta\left[\left(\frac{\partial}{\partial \theta} \log p(X|\theta)\right)^2\right] = -\mathbb{E}_\theta\left[\frac{\partial^2}{\partial \theta^2} \log p(X|\theta)\right]$$

**Fisher Information Matrix (vector parameter)**:
$$[\mathcal{I}(\theta)]_{ij} = \mathbb{E}_\theta\left[\frac{\partial \log p(X|\theta)}{\partial \theta_i} \frac{\partial \log p(X|\theta)}{\partial \theta_j}\right] = -\mathbb{E}_\theta\left[\frac{\partial^2 \log p(X|\theta)}{\partial \theta_i \partial \theta_j}\right]$$

**Cramér-Rao Lower Bound** (variance lower bound for unbiased estimators):
$$\text{Var}(\hat{\theta}) \geq \frac{1}{\mathcal{I}(\theta)}$$

**Relationship to KL Divergence** (Fisher information = second-order expansion coefficient of KL divergence):
$$D_{KL}(p_\theta \| p_{\theta + d\theta}) \approx \frac{1}{2} d\theta^T \mathcal{I}(\theta) d\theta$$

## Applicable Problems
- **Parameter estimation efficiency assessment**: The Cramér-Rao bound gives the theoretical limit on the precision of any unbiased estimator
- **Natural gradient descent**: Use $\mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}$ instead of the naive gradient, updating along geodesic directions on the statistical manifold (see `../information-geometry/natural-gradient.en.md`)
- **Experimental design / active learning**: Select data points that maximize Fisher information, maximizing the information gain for parameter learning

## AI Design Translation
- **Natural Gradient / K-FAC Optimizer**: Use a Kronecker approximation of the Fisher information matrix $\mathcal{I} \approx A \otimes B$ in place of the Hessian, enabling approximate second-order optimization
- **Elastic Weight Consolidation (EWC)**: $\mathcal{L}_{\text{EWC}} = \mathcal{L}_{\text{new}} + \frac{\lambda}{2} \sum_i \mathcal{I}_i (\theta_i - \theta_i^*)^2$, using Fisher information to measure the importance of each parameter to previous tasks, preventing catastrophic forgetting
- **Sensitivity analysis for pretraining-finetuning**: Parameter directions with high Fisher information = parameters sensitive to data; these should be handled more carefully during fine-tuning

## Engineering Feasibility
- **D1[~]**: The full FIM is a $d \times d$ matrix ($d$ = number of parameters); direct materialization is infeasible (LLM parameter counts $10^{10}+$). Approximations are required.
- **D2[~]**: Kronecker factors are estimated using GEMM; inverse/Cholesky operations and their refresh schedule are separate costs.
- **D3[~]**: Empirical full outer products cost $O(nd^2)$ for $n$ scores of length $d$. A layer with widths $a,b$ has K-FAC storage $O(a^2+b^2)$ and dense factor solves $O(a^3+b^3)$, not generic $O(d)$ computation.
- **D4[~]**: K-FAC's Kronecker factors require additional memory, though significantly compressed compared to the full FIM
- **D5[~]**: fp32 is a practical starting point, but conditioning and required residual accuracy may justify fp64; precision is not settled by PSD alone.
- **D6[v]**: K-FAC's Kronecker factors naturally decompose by layer, enabling parallel computation
- **D8[v]**: The EWC penalty term is element-wise and can be fused into the parameter update kernel

## Risks and Failure Conditions
- **Full FIM is intractable**: For LLM-scale parameter counts ($d > 10^9$), even K-FAC's Kronecker approximation may be too costly. In practice, diagonal Fisher ($O(d)$) or low-rank approximations are commonly used.
- **Empirical Fisher versus model Fisher**: For conditional models, the model Fisher averages labels sampled from $p_\theta(y|x)$; the empirical Fisher uses observed labels. They are different expectation targets and need not coincide even with large data. Minibatch Monte Carlo error is a separate issue; warmup does not repair this identity.

## Further References
- Distillation draft: `../../references/books/` — no dedicated information geometry distillation draft at present
- Amari. *Information Geometry and Its Applications*. Springer, 2016
- Amari & Nagaoka. *Methods of Information Geometry*. AMS, 2000
- Martens. "Optimizing Neural Networks with Kronecker-Factored Approximate Curvature." *ICML*, 2015
- Related knowledge cards: `../information-geometry/natural-gradient.en.md`, `../information-geometry/fisher-metric.en.md`


## Routing Extensions
- If a geometric perspective is needed -> `../information-geometry/fisher-metric.en.md` (Fisher information as Riemannian metric)
- If Fisher-based optimization is needed -> `../information-geometry/natural-gradient.en.md` (natural gradient driven by Fisher information)
- For Cramer-Rao bounds see this card's "Core Formulas" section (derived via score function + Cauchy-Schwarz, not via concentration inequalities); if deviation probability bounds are needed -> `concentration-inequality.en.md` (Hoeffding/McDiarmid etc.)

## Extensible Directions
- Observed vs expected Fisher: two types of Fisher information matrices
- Fisher information matrix properties: positive definiteness, chain rule, sufficient statistics
- Jeffreys prior: non-informative prior defined by Fisher information
- Fisher information distance: Fisher metric distance between distributions
- Mutual information and Fisher: relationship between Fisher information and mutual information
- Fisher in deep learning: approximation methods such as K-FAC, Shampoo
