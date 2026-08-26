# Mathematical Activation Anchor Index

> knowledge-base/ is not a closed encyclopedia but an activation entry point for high-frequency mathematical structures. Each card is an activation anchor that answers: what mathematical concept to activate, what deeper knowledge it connects to, what AI design actions it translates to, and where to extend when it is insufficient.

## Knowledge Base Structure

The knowledge base has 9 domain directories and 41 cards: 37 shared-math anchors across 8 domains, plus 4 domain-specific cryptography anchors. Shared-math cards may include AI/engineering translations when relevant; cryptography cards preserve security-definition, construction, and reduction semantics without forcing AI or GPU sections.

| Domain | Directory | Cards | Typical Applications |
|--------|-----------|-------|---------------------|
| Matrix Analysis | `matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation, random-matrix, hankel-state-space | LoRA, spectral normalization, spectral health monitoring, S4 long-sequence layers |
| Optimization | `optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method | GAN minimax, weight constraints, Muon optimizer |
| Differential Geometry | `differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection | Natural gradient, manifold optimization, K-FAC |
| Lie Theory | `lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance | Equivariant networks, SO(3) parameterization, spherical harmonics |
| Topology | `topology/` | persistent-homology, euler-characteristic, fundamental-group | Topological regularization, latent space monitoring |
| Probability & Information | `probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information, optimal-transport, score-matching-sde | VAE, diffusion models, Sinkhorn routing, generalization bounds |
| Information Geometry | `information-geometry/` | natural-gradient, fisher-metric | Natural gradient descent, Fisher-Rao metric |
| Algebraic Geometry | `algebraic-geometry/` | grassmannian-plucker, sheaf-cohomology | Subspace parameterization, local-to-global consistency |
| Cryptography (domain-specific) | `cryptography/` | prf-prg-owf, attack-game-framework, cca-cpa-ae-hierarchy, reduction-proof-template | Security definitions, constructions, games, and reductions |

## From Problem to Knowledge Card

| Problem Type | Recommended Cards |
|-------------|-------------------|
| Need dimensionality reduction/compression | low-rank-approximation, projection |
| Need constrained optimization | constrained-optimization, lagrangian-duality |
| Need equivariance/symmetry | group-action, equivariance, representation |
| Need stable training | matrix-perturbation, positive-semidefinite, fisher-information |
| Need manifold parameterization | manifold, riemannian-optimization, tangent-space |
| Need information compression | information-bottleneck, entropy, kl-divergence |
| Need topological regularization | persistent-homology, euler-characteristic |

## When Anchors Are Not Enough

The current 37 shared-math anchors and 4 cryptography anchors cover high-frequency structures. When a problem requires a tool not among them:

1. Check the corresponding domain's `*/index.en.md` (e.g., `topology/index.en.md`) for extended concepts and reference book directions
2. Enter the **Knowledge Gap Protocol** in root `../SKILL.en.md` to generate a temporary knowledge card
3. Never respond with "knowledge base does not cover this" or force-fit the closest card

> **Domain Router note**: For pure cryptography, load the smallest relevant card under `cryptography/` first; consult `../references/books/` only when the anchors are insufficient or literature-level depth is requested. Shared-math anchors are loaded on demand without duplicating cryptographic semantics. A pure AI request does not enter the crypto route merely because it contains words such as “hash,” “attack,” or “security.”

## Domain Extension Index

Each domain has an `*/index.en.md` that lists: domain trigger signals, core anchors, extended concepts, reference book directions, and temporary activation rules.

| Domain | Extension Index |
|--------|----------------|
| Matrix Analysis | `matrix-analysis/index.en.md` |
| Optimization | `optimization/index.en.md` |
| Differential Geometry | `differential-geometry/index.en.md` |
| Lie Theory | `lie-theory/index.en.md` |
| Topology | `topology/index.en.md` |
| Probability & Information | `probability/index.en.md` |
| Information Geometry | `information-geometry/index.en.md` |
| Algebraic Geometry | `algebraic-geometry/index.en.md` |
| Cryptography | `cryptography/index.en.md` |
