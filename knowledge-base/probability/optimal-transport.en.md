# Optimal Transport

## Minimal Definition

Optimal transport studies how to move one probability distribution into another at minimal total cost: given a cost function $c(x, y)$, minimize $\int c\, d\pi$ over couplings $\pi \in \Pi(\mu, \nu)$ with prescribed marginals. The optimal value defines the **Wasserstein distance** — a metric between distributions that respects the geometry of the base space and, unlike KL, does not require overlapping supports.

## Core Formulas

- **Kantorovich relaxation**: $W_c(\mu, \nu) = \min_{\pi \in \Pi(\mu, \nu)} \langle C, \pi \rangle$, $\Pi(\mu, \nu) = \{\pi \geq 0 : \pi \mathbf{1} = \mu,\ \pi^T \mathbf{1} = \nu\}$
- **Wasserstein-$p$ distance**: $W_p(\mu, \nu) = \left(\inf_{\pi \in \Pi(\mu,\nu)} \int \|x - y\|^p d\pi\right)^{1/p}$
- **Dual form**: $W_1(\mu, \nu) = \sup_{\|f\|_{\text{Lip}} \leq 1} \mathbb{E}_\mu[f] - \mathbb{E}_\nu[f]$ (Kantorovich–Rubinstein), the theoretical source of the WGAN critic
- **Entropic regularization (Sinkhorn)**: $\min_{\pi \in \Pi} \langle C, \pi \rangle - \epsilon H(\pi)$, with solution $\pi^* = \operatorname{diag}(u)\, e^{-C/\epsilon}\, \operatorname{diag}(v)$, solved by alternating row/column scaling at $O(n^2)$ per round
- **Displacement interpolation (McCann)**: the Wasserstein geodesic $\mu_t = ((1-t)\,\mathrm{id} + tT)_\# \mu$ — the "straight line" between distributions is uniform per-particle motion

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

- **Bias–compute trade-off in $\epsilon$**: large $\epsilon$ is fast but biased away from true OT (entropic bias); small $\epsilon$ converges slowly and is numerically unstable. The Sinkhorn divergence removes the bias but is not the true $W$
- **Sample-complexity curse**: empirical estimates of $W_p$ degrade exponentially with dimension ($n^{-1/d}$); systematic bias of mini-batch estimates in high dimensions is non-negligible
- **Unbalanced/partial transport**: standard OT requires equal total mass on both sides; real data has outliers — use unbalanced OT (KL-relaxed marginals) or partial OT
- **WGAN's Lipschitz constraint is only an approximate dual**: weight clipping / gradient penalty are heuristic enforcements of 1-Lipschitz, not the exact dual

## Further References

- Distilled book: `../../references/books/optimization-ml.md` (duality and convex optimization foundations; OT proper is beyond that book's scope)
- Peyré & Cuturi. *Computational Optimal Transport*. NOW, 2019 (standard reference for Sinkhorn and numerics)
- Villani. *Optimal Transport: Old and New*. Springer, 2009 (theory monograph)
- Santambrogio. *Optimal Transport for Applied Mathematicians*. Birkhäuser, 2015

## Routing Extensions

- For duality theory -> `../optimization/lagrangian-duality.md` (Kantorovich duality is LP duality)
- For understanding entropic regularization -> `entropy.md` (role of the $-\epsilon H(\pi)$ term)
- For comparing distribution divergences -> `kl-divergence.md` (support/geometry differences between KL and Wasserstein)
- For routing design -> `../../design-patterns/routing/optimal-transport-routing.en.md` (OT routing prototype for MoE)

## Extensible Directions

- Unbalanced OT: relaxations without mass conservation (HK distance)
- Gromov–Wasserstein: comparing distributions/graphs without a common base space
- Wasserstein gradient flows (JKO scheme): optimization and PDEs in distribution space
- Sliced Wasserstein: fast approximation via one-dimensional projections, $O(n \log n)$
- Wasserstein barycenters: averaging and ensembling multiple distributions
