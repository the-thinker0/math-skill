# Skill Index: Lens Library, Activation Anchors, Design Translation Prototypes, Workflow Examples

> This is the on-demand catalog for `../SKILL.md`. The main entry keeps only selection rules; do not load this index by default for a clear request.

## Domain Router Overview

> Full definition: see the Domain Router section in `../SKILL.md`. Only a summary table appears here:

| Domain | Loaded Content | Signal Keywords |
|--------|----------------|------------------|
| **Shared Mathematics** | 33 anchors across 8 non-cryptography domains plus relevant lenses | probability/information/algebra/geometry/matrix/spectral/optimization/topology/complexity |
| **AI Research** | Shared mathematics on demand + `../design-patterns/` (5 types, 22 patterns); books only for deep checks | attention/loss/routing/representation/compression/MoE/transformer/KV-cache/LoRA/SSM/diffusion/RL |
| **Cryptography** | 4 crypto anchors; only then 3 crypto books if needed; shared mathematics on demand | encryption/signature/MAC/PRF/PRG/PRP/OWF/CCA/CPA/AE/ZK/reduction/DL/CDH/DDH/RSA/ECC/lattice |
| **AI×Crypto** | dual-domain load + intersection annotation | "PRF for watermarking," "adversarial example reduction," "verifiable inference" |

> Core rules: domain judgment precedes lens invocation; shared math loads on demand by problem structure (not by domain tag); no pollution across non-cross domains; gap-protocol temporary cards are domain-tagged.

## Design Philosophy

> Full definition: see the objective, Domain Router, and progressive-loading sections in `../SKILL.md`. Key points:
>
> 1. knowledge-base/ anchors describe mathematical structures themselves (manifolds, spectra, sheaf cohomology, pseudorandom function families, etc.), not specific AI architectures (diffusion, SSM, transformer variants).
> 2. design-patterns/ is a paradigmatic demonstration of "math→AI module" translation, not a copy-paste template library; for new problems, generate temporary design candidates from the mathematical structure.
> 3. Compatibility principle: research problems with architectures the skill did not pre-specify (e.g., future paradigms) are handled through lens-routing + anchor-activation + temporary-knowledge-card pipeline, not declared "not covered."

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
   - Codex always reads canonical `../SKILL.md` and answers in the user's primary language; it does not load a second body for English input.
   - An explicit English command entry may read `../SKILL.en.md` directly, but must not also load the Chinese entry.
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

## Activation Anchors (Organized by Mathematical Domain)

Each anchor is not a closed knowledge card but answers: what math structure to activate, what deeper knowledge it connects to, what AI design actions it translates to, and how to extend when insufficient.

| Domain | Directory | Anchors |
|--------|-----------|----------------|
| Matrix Analysis | `../knowledge-base/matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| Optimization | `../knowledge-base/optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| Differential Geometry | `../knowledge-base/differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| Lie Theory | `../knowledge-base/lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance |
| Topology | `../knowledge-base/topology/` | persistent-homology, euler-characteristic, fundamental-group |
| Probability & Information | `../knowledge-base/probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| Information Geometry | `../knowledge-base/information-geometry/` | natural-gradient, fisher-metric |
| Algebraic Geometry | `../knowledge-base/algebraic-geometry/` | sheaf-cohomology, grassmannian-plucker |

## Design Pattern Library (Organized by AI Component)

Each design pattern answers: Mathematical origin, AI module form, implementable architecture, GPU feasibility, paper-level exposition, risks.

| Component Type | Directory | Patterns |
|---------------|-----------|----------|
| Attention | `../design-patterns/attention/` | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| Loss Functions | `../design-patterns/loss/` | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| Routing | `../design-patterns/routing/` | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| Representation | `../design-patterns/representation/` | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| Compression | `../design-patterns/compression/` | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

## Cryptography Book Distillations (3 New Books)

The reference layer covers 10 books, all paired in Chinese and English. The three cryptography distillations below support security definitions, constructions, reductions, and protocol analysis. English requests use the .en.md files and load them only when anchors are insufficient.

| Book | File | Primary Use | Activation Family |
|------|------|-------------|--------------------|
| Boneh & Shoup, *A Graduate Course in Applied Cryptography* | `books/applied-cryptography.en.md` | Attack games, reduction proofs, symmetric/public-key constructions, zero knowledge, and protocols | Definitions/Reductions/Primitives/Protocols |
| Goldreich, *Foundations of Cryptography, Volume 1: Basic Tools* | `books/foundations-of-cryptography.en.md` | Computational indistinguishability, OWF/PRG/PRF, zero knowledge, and commitments | Definitions/Proofs/Constructions/Meta-theorems |
| Katz & Lindell, *Introduction to Modern Cryptography*, 2nd ed. | `books/introduction-to-modern-cryptography.en.md` | Formal security definitions, IND/CCA, MACs, hashing, and digital signatures | Definitions/Proofs/Primitives/Assumptions/Constructions |

> **Domain Router note**: These three books belong to the **Cryptography Layer** and are loaded only when Domain Router determines the problem is cryptography or AI×crypto intersection. Pure AI problems do not load them. Shared math anchors (probability/information/algebra) are loaded on demand without redundancy.
>
> **Backfill note**: the knowledge-base/cryptography/ anchor directory (with prf-prg-owf, reduction-proof-template, attack-game-framework, cca-cpa-ae-hierarchy cards) and knowledge-base/algebraic-geometry/ directory (with sheaf-cohomology, grassmannian-plucker cards) give the cryptography and algebraic-geometry layers structured anchors for light consultation, not just books.

## Workflow Example

**User**: "Design a new KV Cache compression method that preserves long-range dependencies — I don't want to just do top-k."

```
Step 1 — Diagnosis: Scenario B (Mechanism Design)
  Problem type: Sequence memory compression + information preservation + long-range structure
  Core tension: Compressing token count vs. preserving long-range dependencies

Step 2 — Lens Selection (default ≤2):
  1. Spectral Decomposition (preserve dominant subspace)
  2. Probabilistic / Information (retain mutual-information-sensitive states)
  (Add Topology only if the user emphasizes connectivity/bridging; it is outside the default budget)

Step 3 — Activation Anchors:
  → low-rank-approximation (Matrix Analysis anchor)
  → information-bottleneck (Probability & Information anchor)
  → leverage-score-selection or low-rank-kv-cache (0–2 compression design patterns)
  If existing anchors are insufficient, enter Knowledge Gap Protocol to generate a temporary knowledge card.

Step 4 — Design Translation:
  Primary: Spectral KV Compression (low-rank + leverage score)
  Alternative only by decisive difference: Information-Preserving Cache (depends on future-query estimates)

Step 5 — Compact Review (do not load the full critic for ordinary tasks):
  Primary is most GPU-friendly; alternative needs future-query estimates and is more uncertain
  Conclusion: Prefer the primary design; add a lightweight gate only when query-sensitive retention is required
```
