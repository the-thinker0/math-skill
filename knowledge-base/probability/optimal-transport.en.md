# Optimal Transport

## Minimal Definition

Optimal transport minimizes a cost over couplings with prescribed marginals. For a base metric $d$, $p\ge1$, and probability measures with finite $p$-th moments, the $p$-th root of the optimal cost for $c=d^p$ defines the Wasserstein-$p$ metric. An arbitrary cost or entropy-regularized OT objective is not automatically a distance.

## Core Formulas

- **Kantorovich relaxation**: $W_c(\mu, \nu) = \min_{\pi \in \Pi(\mu, \nu)} \langle C, \pi \rangle$, $\Pi(\mu, \nu) = \{\pi \geq 0 : \pi \mathbf{1} = \mu,\ \pi^T \mathbf{1} = \nu\}$
- **Wasserstein-$p$ distance**: $W_p(\mu, \nu) = \left(\inf_{\pi \in \Pi(\mu,\nu)} \int \|x - y\|^p d\pi\right)^{1/p}$
- **Dual form**: $W_1(\mu, \nu) = \sup_{\|f\|_{\text{Lip}} \leq 1} \mathbb{E}_\mu[f] - \mathbb{E}_\nu[f]$ (Kantorovich–Rubinstein), the theoretical source of the WGAN critic
- **Entropic regularization (Sinkhorn)**: $\min_{\pi \in \Pi} \langle C, \pi \rangle - \epsilon H(\pi)$, with solution $\pi^* = \operatorname{diag}(u)\, e^{-C/\epsilon}\, \operatorname{diag}(v)$, solved by alternating row/column scaling at $O(n^2)$ per round
- **Displacement interpolation**: In Euclidean quadratic OT, if an optimal map $T$ exists (e.g. an absolutely continuous source with finite second moment), $\mu_t=((1-t)\mathrm{id}+tT)_\#\mu$ is a $W_2$ geodesic. Without a map, use an optimal coupling $\pi$ and push it forward by $(x,y)\mapsto(1-t)x+ty$.

## Applicable Problems

- **Distribution alignment and matching**: domain adaptation, multimodal alignment, model merging — whenever a geometry-aware distribution distance is needed
- **Globally optimal assignment**: MoE routing, batch allocation, feature matching — marginal constraints naturally express capacity/load balancing
- **Generative models**: WGAN's Lipschitz critic, Sinkhorn divergences as distribution-matching losses
- **Point-set comparison**: soft correspondences between two sets of embeddings / point clouds

## AI Design Translation

- **Sinkhorn routing layer**: model token→expert assignment in MoE as entropic OT with cost $C = -S$ (negative similarity) and expert capacities as marginal constraints; implement as $K$ rounds of alternating row/column normalization (log-domain stable version), all matmul + softmax-like ops
- **Wasserstein gradient flow**: view training as gradient descent of a distribution in Wasserstein geometry (e.g., mean-field Langevin dynamics), a framework for global convergence analysis
- **Distribution-matching loss**: replace MMD/KL with the Sinkhorn divergence $S_\epsilon(\mu, \nu) = W_\epsilon(\mu,\nu) - \frac{1}{2}W_\epsilon(\mu,\mu) - \frac{1}{2}W_\epsilon(\nu,\nu)$ for generative modeling or distillation
- **Batch-level optimal assignment**: replace sample→prototype assignment in contrastive learning/clustering with balanced Sinkhorn assignment (SwAV paradigm), avoiding collapse to a single prototype

## Engineering Feasibility

- **Main operations**: Sinkhorn = iterated matmuls (alternating multiplication of $e^{-C/\epsilon}$ with vectors) + row/column normalization; the cost matrix $C$ itself is an $n \times m$ pairwise-distance matrix
- **GPU friendliness**: medium-high. Sinkhorn iterations are fully tensorizable; but the cost matrix costs $O(nm)$ memory, requiring chunking or low-rank approximation for large $n$
- **Complexity**: $O(nm)$ per Sinkhorn round, with round count growing as $\epsilon$ shrinks (typically 20–100 rounds); exact LP solvers at $O(n^3)$ do not scale
- **Low precision**: log-domain Sinkhorn is stable in fp32; for small $\epsilon$ the kernel $e^{-C/\epsilon}$ underflows — a log-space implementation is mandatory

## Risks and Failure Conditions

- **Regularization bias**: Sinkhorn divergence removes entropic self-interaction terms, but finite-epsilon values remain different from unregularized Wasserstein distance. It does not remove sampling, solver or all entropic bias.
- **Sample complexity**: High-dimensional empirical Wasserstein rates can be as slow as $n^{-1/d}$ in common regimes, with rates depending on $p$, moments and support dimension. Achieving a fixed small error can require exponentially many samples in dimension; the error itself is not “exponential in dimension.”
- **Unbalanced/partial transport**: standard OT requires equal total mass on both sides; real data has outliers — use unbalanced OT (KL-relaxed marginals) or partial OT
- **WGAN's Lipschitz constraint is only an approximate dual**: weight clipping / gradient penalty are heuristic enforcements of 1-Lipschitz, not the exact dual

## Further References

- Distilled book: `../../references/books/optimization-ml.en.md` (duality and convex optimization foundations; OT proper is beyond that book's scope)
- Peyré & Cuturi. *Computational Optimal Transport*. NOW, 2019 (standard reference for Sinkhorn and numerics)
- Villani. *Optimal Transport: Old and New*. Springer, 2009 (theory monograph)
- Santambrogio. *Optimal Transport for Applied Mathematicians*. Birkhäuser, 2015

## Routing Extensions

- For duality theory -> `../optimization/lagrangian-duality.en.md` (Kantorovich duality is LP duality)
- For understanding entropic regularization -> `entropy.en.md` (role of the $-\epsilon H(\pi)$ term)
- For comparing distribution divergences -> `kl-divergence.en.md` (support/geometry differences between KL and Wasserstein)
- For routing design -> `../../design-patterns/routing/optimal-transport-routing.en.md` (OT routing prototype for MoE)

## Extensible Directions

- Unbalanced OT: relaxations without mass conservation (HK distance)
- Gromov–Wasserstein: comparing distributions/graphs without a common base space
- Wasserstein gradient flows (JKO scheme): optimization and PDEs in distribution space
- Sliced Wasserstein: fast approximation via one-dimensional projections, $O(n \log n)$
- Wasserstein barycenters: averaging and ensembling multiple distributions
