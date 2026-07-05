# Skill Index: Lens Library, Knowledge Base, Design Pattern Library, Workflow Examples

> This file is extracted from `../skills/math-research-activator/SKILL.en.md` for reference when the full catalogs are needed. SKILL.en.md retains condensed summaries with links to this file.

## Language Routing & Mixed-Input Rules (Full Version)

Language routing only determines "which language version to read" and "what language to respond in." It does NOT affect whether the math system triggers or the A/B/C/D/E scenario classification.

### Decision Rules

1. **Judge the natural-language frame first**
   - If the user's sentence structure, verbs, and mood particles are primarily Chinese, treat as Chinese even if English technical terms are interspersed.
   - E.g., "帮我 design 一个 attention" / "这个 loss 有没有理论问题" / "能不能用 manifold 做 routing" → Chinese.

2. **English technical terms do not count as English primary language**
   - attention, loss, routing, embedding, manifold, operator, kernel, KV-cache, transformer, MoE, and similar AI/math/engineering terms are domain terms and do not trigger a switch to English.

3. **Code, paths, and formulas are excluded from language detection**
   - File paths, function names, variable names, LaTeX formulas, and CLI arguments do not count toward language ratio.

4. **When primary language is unclear, follow the user's last clear language**
   - If the CN/EN ratio is close and indeterminate, use the user's most recent unambiguous natural language.
   - If there is no prior context, default to Chinese.

5. **Output language matches primary language**
   - Chinese primary → read `../skills/math-research-activator/SKILL.md`, respond in Chinese, retaining necessary English terms.
   - English primary → read `../skills/math-research-activator/SKILL.en.md`, respond in English.
   - If the user explicitly requests "in English" / "in Chinese," follow the explicit request.

## Lens Library (15 Mathematical Perspectives)

Each lens answers: What is this perspective? What kinds of problems is it suited to diagnose? Which knowledge domains does it route to?

| Lens | File | Core Perspective |
|------|------|-----------------|
| Axiomatization | `../lenses/axiomatization.en.md` | Examine consistency/independence/completeness of assumptions |
| Duality | `../lenses/duality.en.md` | Transform to the dual space to expose constraints and invariants |
| Symmetry | `../lenses/symmetry.en.md` | Invariants and conservation laws under transformations |
| Spectral Decomposition | `../lenses/spectral.en.md` | Eigenvalues/singular values reveal dominant structure |
| Geometric | `../lenses/geometric.en.md` | Metric/curvature/spatial structure on manifolds |
| Projection & Decomposition | `../lenses/projection.en.md` | Orthogonal decomposition, subspace separation, conflict elimination |
| Variational | `../lenses/variational.en.md` | Constrained extrema, energy minimization |
| Local-to-Global | `../lenses/local-to-global.en.md` | Patching local properties into global ones, cohomological obstructions |
| Topological | `../lenses/topological.en.md` | Invariants under continuous deformation, connectedness, holes |
| Categorical | `../lenses/categorical.en.md` | Universal properties, functors, natural transformations |
| Perturbation | `../lenses/perturbation.en.md` | Propagation of small perturbations, stability, robustness |
| Causal | `../lenses/causal.en.md` | Correlation ≠ causation, interventions, counterfactuals |
| Game-Theoretic | `../lenses/game.en.md` | Multi-agent strategic interaction, equilibria, mechanism design |
| Probabilistic & Statistical | `../lenses/probabilistic.en.md` | Quantifying uncertainty, Bayesian updating |
| Algorithmic | `../lenses/algorithmic.en.md` | Complexity, feasibility, parallelizability |

## Knowledge Base (Organized by Mathematical Domain)

Each knowledge card answers: Minimal definition, core formulas, applicable problems, AI design translation, engineering feasibility, risks.

| Domain | Directory | Knowledge Cards |
|--------|-----------|----------------|
| Matrix Analysis | `../knowledge-base/matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| Optimization | `../knowledge-base/optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| Differential Geometry | `../knowledge-base/differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| Lie Theory | `../knowledge-base/lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance |
| Topology | `../knowledge-base/topology/` | persistent-homology, euler-characteristic, fundamental-group |
| Probability & Information | `../knowledge-base/probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| Information Geometry | `../knowledge-base/information-geometry/` | natural-gradient, fisher-metric |

## Design Pattern Library (Organized by AI Component)

Each design pattern answers: Mathematical origin, AI module form, implementable architecture, GPU feasibility, paper-level exposition, risks.

| Component Type | Directory | Patterns |
|---------------|-----------|----------|
| Attention | `../design-patterns/attention/` | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| Loss Functions | `../design-patterns/loss/` | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| Routing | `../design-patterns/routing/` | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| Representation | `../design-patterns/representation/` | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| Compression | `../design-patterns/compression/` | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

## Workflow Example

**User**: "Design a new KV Cache compression method that preserves long-range dependencies — I don't want to just do top-k."

```
Step 1 — Diagnosis: Scenario B (Mechanism Design)
  Problem type: Sequence memory compression + information preservation + long-range structure
  Core tension: Compressing token count vs. preserving long-range dependencies

Step 2 — Lens Selection:
  1. Spectral Decomposition (preserve dominant subspace)
  2. Information Theory (retain states with maximum mutual information)
  3. Topological (preserve critical connectivity points of sequential structure)

Step 3 — Knowledge Query:
  → low-rank-approximation (Matrix Analysis)
  → leverage-score-selection (Design Pattern: compression)
  → information-bottleneck (Probability & Information)

Step 4 — Design Translation:
  Candidate A: Spectral KV Compression (low-rank + leverage score)
  Candidate B: Information-Preserving Cache (query sensitivity)
  Candidate C: Topology-Preserving Cache (graph bridge-node retention)

Step 5 — Critic Review:
  A is most GPU-friendly; B requires estimating future queries with inherent uncertainty; C has prohibitive graph construction cost
  Recommendation: Prioritize A; use B as a lightweight gate
```
