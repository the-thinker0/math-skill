# Mathematical Activation Anchor Index

> knowledge-base/ is not a closed encyclopedia but an activation entry point for high-frequency mathematical structures. Each card is an activation anchor that answers: what mathematical concept to activate, what deeper knowledge it connects to, what AI design actions it translates to, and where to extend when it is insufficient.

## Knowledge Base Structure

The knowledge base is organized by mathematical domain, with 7 domains and 31 knowledge cards. Each card contains: minimal definition, core formulas, applicable problems, AI design translation, engineering feasibility, risks and failure conditions.

| Domain | Directory | Cards | Typical Applications |
|--------|-----------|-------|---------------------|
| Matrix Analysis | `matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation | LoRA, spectral normalization, condition number monitoring |
| Optimization | `optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method | GAN minimax, weight constraints, Muon optimizer |
| Differential Geometry | `differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection | Natural gradient, manifold optimization, K-FAC |
| Lie Theory | `lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance | Equivariant networks, SO(3) parameterization, spherical harmonics |
| Topology | `topology/` | persistent-homology, euler-characteristic, fundamental-group | Topological regularization, latent space monitoring |
| Probability & Information | `probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information | VAE, knowledge distillation, generalization bounds |
| Information Geometry | `information-geometry/` | natural-gradient, fisher-metric | Natural gradient descent, Fisher-Rao metric |

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

The current 31 anchors cover the most commonly used mathematical structures in AI research. When a problem requires mathematical tools not among them:

1. Check the corresponding domain's `index.md` (e.g., `topology/index.md`) for extended concepts and reference book directions
2. Enter the **Knowledge Gap Protocol** defined in SKILL.md to generate a temporary knowledge card
3. Never respond with "knowledge base does not cover this" or force-fit the closest card

## Domain Extension Index

Each domain has an `index.md` that lists: domain trigger signals, core anchors, extended concepts, reference book directions, and temporary activation rules.

| Domain | Extension Index |
|--------|----------------|
| Matrix Analysis | `matrix-analysis/index.md` |
| Optimization | `optimization/index.md` |
| Differential Geometry | `differential-geometry/index.md` |
| Lie Theory | `lie-theory/index.md` |
| Topology | `topology/index.md` |
| Probability & Information | `probability/index.md` |
| Information Geometry | `information-geometry/index.md` |
