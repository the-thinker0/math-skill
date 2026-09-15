# Design Translation Pattern Library

> The design pattern library is not a complete model repository but a collection of "math → AI design" translation prototypes.
> When existing patterns are insufficient, generate a temporary design candidate from the mathematical source and label it as a temporary design pattern, rather than refusing or force-fitting existing patterns.
> Evidence labels distinguish a supported claim [v], a proposal needing validation [~], an incompatibility under stated conditions [x], and a nonapplicable dimension [N/A]. See the review contract below.

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

Generate a temporary design candidate only when the user is designing/adapting a module and the existing patterns do not fit; a knowledge query alone does not require a new design.

## By Component Type

| Component | Directory | Count |
|-----------|-----------|-------|
| Attention | `attention/` | 5 |
| Loss Functions | `loss/` | 5 |
| Routing | `routing/` | 4 |
| Representation | `representation/` | 4 |
| Compression | `compression/` | 4 |

## From Prototype to a Reviewable Module

A pattern is a candidate operator, not a measured architecture result. `[v]` needs an explicit theorem with assumptions or a recorded check; `[~]` is a proposal to validate, `[x]` an incompatibility under stated conditions, and `[N/A]` an irrelevant dimension. Unmarked prose is not a proof or benchmark.

For each adaptation record: tensor shapes and axes; the mathematical identity or approximation; a small exact reference and a failure case; numerical residuals at fp32 and target precision; full forward/backward or prefill/decode costs; and a task baseline at matched budget. Avoid copying paper phrasing as if experiments had been run.

| Intended guarantee | Minimal useful check |
|---|---|
| Projection / low-rank approximation | Orthogonality and reconstruction residual; downstream query/output error |
| Equivariance | Whole-module transformed-input residual, including masks/positions and output types |
| IB / contrastive loss | Random-variable definition, bound direction, beta convention and sampling distribution |
| Balanced routing | Soft marginal residual and separate hard-capacity/overflow check |
| Topology preservation | Filtration, coefficient field, dimension/simplex limits; diagram or Betti diagnostics |

Worked examples: `../references/worked-examples/query-aware-compression.en.md` and `../references/worked-examples/equivariance-check.en.md`. GPU methodology: `../references/gpu-friendly-math.en.md`.
