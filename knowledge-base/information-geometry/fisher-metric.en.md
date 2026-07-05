# Fisher-Rao Metric

## Minimal Definition
The Fisher-Rao metric is a **Riemannian metric** on the parameter space of a family of probability distributions (statistical model), whose metric tensor is precisely the Fisher information matrix. It endows the parameter space with an intrinsic geometric structure, enabling the "distance" between probability distributions to be described using geometric language (geodesics, curvature, connections). It is the core structure of information geometry.

## Core Formulas

**Metric Tensor (i.e., Fisher Information Matrix)**:
$$g_{ij}(\theta) = \mathcal{I}_{ij}(\theta) = \mathbb{E}_\theta\left[\frac{\partial \log p}{\partial \theta_i} \frac{\partial \log p}{\partial \theta_j}\right] = -\mathbb{E}_\theta\left[\frac{\partial^2 \log p}{\partial \theta_i \partial \theta_j}\right]$$

**Second-Order Taylor Expansion of KL Divergence**: The Fisher metric is precisely the Hessian of KL divergence at $\theta' = \theta$:
$$g_{ij}(\theta) = \frac{\partial^2}{\partial \theta_i' \partial \theta_j'} D_{KL}(p_\theta \| p_{\theta'})\bigg|_{\theta'=\theta}$$
That is, $D_{KL}(p_\theta \| p_{\theta+d\theta}) = \frac{1}{2} \sum_{i,j} g_{ij}(\theta) \, d\theta_i \, d\theta_j + O(\|d\theta\|^3)$.

**Line Element (infinitesimal distance between distributions)**:
$$ds^2 = \sum_{i,j} g_{ij}(\theta) \, d\theta_i \, d\theta_j \approx 2 \, D_{KL}(p_\theta \| p_{\theta+d\theta}) \quad \text{(second-order local expansion, asymptotically exact as } d\theta \to 0\text{)}$$

**Geodesic Distance (finite distance between distributions)**:
$$d(p_{\theta_1}, p_{\theta_2}) = \inf_{\gamma} \int_0^1 \sqrt{\dot{\gamma}^T \mathcal{I}(\gamma(t)) \dot{\gamma}} \, dt$$

**$\alpha$-Connection Family** (different notions of "straight lines"):
$$\Gamma_{ijk}^{(\alpha)} = \mathbb{E}\left[\left(\partial_i \partial_j \ell + \frac{1-\alpha}{2} \partial_i \ell \, \partial_j \ell\right) \partial_k \ell\right]$$
- $\alpha = 0$: Levi-Civita connection (metric-compatible), corresponding to "midpoint" symmetry
- $\alpha = 1$: $e$-connection (exponential connection), corresponding to straight lines in the natural parameters of the exponential family
- $\alpha = -1$: $m$-connection (mixture connection), corresponding to straight lines in the expectation parameters of the mixture family

**Dually Flat Structure**: $(\mathcal{M}, g, \nabla^{(e)}, \nabla^{(m)})$ forms a dually flat manifold — the $e$-connection and $m$-connection are dual to each other with respect to $g$, and the generalized Pythagorean theorem holds.

## Applicable Problems
- **Geometric distance between distributions**: Comparing the "intrinsic difference" between two probabilistic models (e.g., output distributions of two language models)
- **Statistical model complexity measurement**: The volume element $\sqrt{\det \mathcal{I}(\theta)} \, d\theta$ induced by the Fisher metric is used for model complexity penalties in MDL/BIC
- **Parameterization-invariant optimization**: Ensuring that the behavior of optimization algorithms does not depend on the specific choice of parameterization (reparameterization invariance)

## AI Design Translation
- **Wasserstein vs. Fisher-Rao in generative models**: GANs use the Wasserstein distance to measure distributional differences; the Fisher-Rao metric provides an alternative — performing geometry-aware optimization in the parameter space of the distribution family
- **Geometry of pretrained model space**: Treating different checkpoints as points on the statistical manifold, Fisher geodesic distances can be used for model selection, model merging, and interpolation path planning
- **Geometric analysis of MoE expert distributions**: The degree of separation between the output distributions of different experts under the Fisher metric can quantify expert diversity

## Engineering Feasibility
- **D1[x]**: The full metric tensor $g_{ij}$ is $d \times d$; infeasible to materialize when $d \sim 10^{10}$
- **D2[~]**: Kronecker/diagonal approximations can be mapped; the exact metric cannot
- **D3[x]**: Geodesic computation requires solving a second-order ODE; exact computation is intractable
- **D4[x]**: Full metric tensor storage is $O(d^2)$; completely impossible at LLM scale
- **D5[~]**: The condition number of the metric tensor may be very large, leading to instability under low precision
- **D6[~]**: Approximate versions (K-FAC, diagonal) can be parallelized; exact versions cannot
- **D7[~]**: The Fisher information matrix is typically dense; block-diagonal approximations (inter-layer independence) introduce structured sparsity
- **D8[v]**: Approximate versions can be fused into optimizer updates

**Conclusion**: The exact Fisher metric is infeasible at LLM scale, but **approximate versions** (K-FAC, diagonal Fisher, low-rank) are engineering-viable. The theoretical value of information geometry lies primarily in **guiding design** rather than direct computation.

## Risks and Failure Conditions
- **Computational complexity is prohibitive**: The metric tensor in a $d$-dimensional parameter space has $O(d^2)$ independent components, which is unaffordable at LLM scale. All practical approaches must use approximations (diagonal, Kronecker, low-rank), and the quality of the approximation determines the practical effectiveness.
- **Singularities of the statistical manifold**: In certain regions of the parameter space (e.g., degenerate points of mixture distributions), the Fisher metric may degenerate ($\det \mathcal{I} = 0$), causing geodesic distances to be undefined. This type of degeneracy arises in MoE when an expert's weight is zero.

## Further References
- Distillation draft: `references/books/` — no dedicated information geometry distillation draft at present
- Amari & Nagaoka. *Methods of Information Geometry*. AMS/Oxford, 2000
- Amari. *Information Geometry and Its Applications*. Springer, 2016
- Ay, Jost, Le, Schwachhofer. *Information Geometry*. Springer, 2017
- Related knowledge cards: `../probability/fisher-information.md`, `natural-gradient.md`


## Routing Extensions
- If optimization application is needed -> `natural-gradient.en.md` (natural gradient descent under Fisher metric)
- If a general Riemannian metric is needed -> `metric-tensor.md` (Fisher metric is a special case of Riemannian metric)
- If local KL analysis is needed -> `kl-divergence.md` (local KL divergence equals Fisher metric)

## Extensible Directions
- Rao's distance: geodesic distance under Fisher-Rao metric
- Fisher-Rao geodesic: shortest paths in distribution space
- Alpha-connection family: Amari's alpha-connections
- Dual flatness: e-flat and m-flat structures
- Chentsov's uniqueness theorem: uniqueness of Fisher metric
- Infinite-dimensional Fisher metric: Fisher metric on function spaces
- Fisher metric in function space: Fisher metric for neural networks
