# Knowledge Base Navigation

> This file is the v3 knowledge base index, helping you find specific knowledge cards from problem types.

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

## Relationship to Thinking Lenses

Thinking lenses (`../lenses/`) handle "what perspective to use"; the knowledge base provides "concrete mathematical tools." Typical chain:

```
Lens diagnosis → Knowledge card provides tools → Design pattern translates to AI module
```

For deeper study, `../references/books/*.md` provides 7 book distillations.
