# Fisher Information

## Minimal Definition
Fisher information measures the **sensitivity of a parametric family of probability distributions to its parameters** — that is, how much information observed data provides about the parameter $\theta$. It defines a natural Riemannian metric on the statistical manifold (the Fisher information matrix = the metric tensor), and is the cornerstone of information geometry.

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
- **Natural gradient descent**: Use $\mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}$ instead of the naive gradient, updating along geodesic directions on the statistical manifold (see `information-geometry/natural-gradient.md`)
- **Experimental design / active learning**: Select data points that maximize Fisher information, maximizing the information gain for parameter learning

## AI Design Translation
- **Natural Gradient / K-FAC Optimizer**: Use a Kronecker approximation of the Fisher information matrix $\mathcal{I} \approx A \otimes B$ in place of the Hessian, enabling approximate second-order optimization
- **Elastic Weight Consolidation (EWC)**: $\mathcal{L}_{\text{EWC}} = \mathcal{L}_{\text{new}} + \frac{\lambda}{2} \sum_i \mathcal{I}_i (\theta_i - \theta_i^*)^2$, using Fisher information to measure the importance of each parameter to previous tasks, preventing catastrophic forgetting
- **Sensitivity analysis for pretraining-finetuning**: Parameter directions with high Fisher information = parameters sensitive to data; these should be handled more carefully during fine-tuning

## Engineering Feasibility
- **D1[~]**: The full FIM is a $d \times d$ matrix ($d$ = number of parameters); direct materialization is infeasible (LLM parameter counts $10^{10}+$). Approximations are required.
- **D2[v]**: K-FAC uses Kronecker factors $A \otimes B$; $A$ and $B$ can each be computed and inverted using GEMM
- **D3[~]**: Exact FIM computation is $O(nd^2)$; K-FAC reduces this to $O(d)$ scale but requires per-layer maintenance
- **D4[~]**: K-FAC's Kronecker factors require additional memory, though significantly compressed compared to the full FIM
- **D5[v]**: FIM estimation can use fp32; fp64 is not required
- **D6[v]**: K-FAC's Kronecker factors naturally decompose by layer, enabling parallel computation
- **D8[v]**: The EWC penalty term is element-wise and can be fused into the parameter update kernel

## Risks and Failure Conditions
- **Full FIM is intractable**: For LLM-scale parameter counts ($d > 10^9$), even K-FAC's Kronecker approximation may be too costly. In practice, diagonal Fisher ($O(d)$) or low-rank approximations are commonly used.
- **Empirical Fisher ≠ True Fisher**: Replacing the expectation with a training set average introduces significant estimation bias when the sample size is insufficient, potentially causing the natural gradient direction to point in the wrong direction. This should be paired with learning rate warmup.

## Further References
- Distillation draft: `references/books/` — no dedicated information geometry distillation draft at present
- Amari. *Information Geometry and Its Applications*. Springer, 2016
- Amari & Nagaoka. *Methods of Information Geometry*. AMS, 2000
- Martens. "Optimizing Neural Networks with Kronecker-Factored Approximate Curvature." *ICML*, 2015
- Related knowledge cards: `information-geometry/natural-gradient.md`, `information-geometry/fisher-metric.md`


## Routing Extensions
- If a geometric perspective is needed -> `fisher-metric.md` (Fisher information as Riemannian metric)
- If Fisher-based optimization is needed -> `natural-gradient.md` (natural gradient driven by Fisher information)
- If Cramer-Rao bounds are needed -> `concentration-inequality.md` (Fisher information and estimation accuracy bounds)

## Extensible Directions
- Observed vs expected Fisher: two types of Fisher information matrices
- Fisher information matrix properties: positive definiteness, chain rule, sufficient statistics
- Jeffreys prior: non-informative prior defined by Fisher information
- Fisher information distance: Fisher metric distance between distributions
- Mutual information and Fisher: relationship between Fisher information and mutual information
- Fisher in deep learning: approximation methods such as K-FAC, Shampoo
