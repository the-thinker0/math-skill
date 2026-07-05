# Design Translation Pattern Library

> The design pattern library is not a complete model repository but a collection of "math → AI design" translation prototypes.
> When existing patterns are insufficient, generate a temporary design candidate from the mathematical source and label it as a temporary design pattern, rather than refusing or force-fitting existing patterns.

## Translation Paradigms

| Mathematical Structure | AI Design Direction |
|----------------------|-------------------|
| Projection / Decomposition | subspace split / conflict removal / low-rank attention |
| Spectral structure | token pruning / stability monitor / spectral filter |
| Information theory | bottleneck loss / entropy gate / uncertainty routing |
| Geometry / Metric | manifold representation / metric-aware update |
| Topology | topology-preserving compression / obstruction loss |
| Duality | constrained optimization / primal-dual training |
| Symmetry / Group | equivariant features / weight sharing / orbit aggregation |
| Variational | energy minimization / variational regularization |

## Relationship to Activation Anchors

```
Activation anchors provide math tools → Design patterns translate into AI modules
```

When an activation anchor triggers the Knowledge Gap Protocol to generate a temporary knowledge card, a corresponding temporary design candidate should also be generated here.

## By Component Type

| Component | Directory | Count |
|-----------|-----------|-------|
| Attention | `attention/` | 5 |
| Loss Functions | `loss/` | 5 |
| Routing | `routing/` | 4 |
| Representation | `representation/` | 4 |
| Compression | `compression/` | 4 |
