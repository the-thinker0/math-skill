# Skill Index: Lens Library, Activation Anchors, Design Translation Prototypes, Workflow Examples

> This is the on-demand catalog for `../SKILL.md`. The main entry keeps only selection rules; do not load this index by default for a clear request.

For cross-field idea discovery, start with [structural transfer](structural-transfer.en.md) and generate candidates from task relations rather than the file catalog. A useful bridge may produce a mechanism, a guarantee, an impossibility result, or a new research question.

## From a research objective to a mechanism

For an underspecified goal or a mechanism outside the existing patterns, use the [construction workbench](design-workbench.en.md). Read only the relevant section of [mathematical construction moves](construction-moves.en.md): separable interactions, residual sampling, input-driven fixed points, propagated error budgets, or sequential decisions. Return to construction after filling a knowledge gap; a temporary card is not the design deliverable. Continue experiments using the [research loop](agentic-workflow.en.md).

## Domain Router Overview

> Full definition: see the Domain Router section in `../SKILL.md`. Only a summary table appears here:

| Domain | Loaded Content | Signal Keywords |
|--------|----------------|------------------|
| **Shared Mathematics** | 37 anchors across 8 non-cryptography domains plus relevant lenses | probability/information/algebra/geometry/matrix/spectral/optimization/topology/complexity |
| **AI Research** | Shared mathematics on demand + `../design-patterns/` (5 types, 22 patterns); books only for deep checks | attention/loss/routing/representation/compression/MoE/transformer/KV-cache/LoRA/SSM/diffusion/RL |
| **Cryptography** | 4 crypto anchors; only then 3 crypto books if needed; shared mathematics on demand | encryption/signature/MAC/PRF/PRG/PRP/OWF/CCA/CPA/AE/ZK/reduction/DL/CDH/DDH/RSA/ECC/lattice |
| **AI×Crypto** | dual-domain load + intersection annotation | "PRF for watermarking," "adversarial example reduction," "verifiable inference" |

> Core rules: domain judgment precedes lens invocation; shared math loads on demand by problem structure (not by domain tag); no pollution across non-cross domains; gap-protocol temporary cards are domain-tagged.

## Design Philosophy

> Full definition: see the objective, Domain Router, and progressive-loading sections in `../SKILL.md`. Key points:
>
> 1. knowledge-base/ anchors describe mathematical structures themselves (manifolds, spectra, sheaf cohomology, pseudorandom function families, etc.), not specific AI architectures (diffusion, SSM, transformer variants).
> 2. design-patterns/ is a paradigmatic demonstration of "math→AI module" translation, not a copy-paste template library; for new problems, generate temporary design candidates from the mathematical structure.
> 3. For architectures not specified in advance, start from a concrete missing relation and seek mathematical correspondences that change the research decision. Use lenses, anchors, and temporary notes as needed; catalog gaps do not put the problem out of scope.

## Lean loading and size tiers (save tokens)

- **Read by section, not whole file:** read an anchor's `Minimal Definition + Core Formulas + Applicable Problems` and relevant risk/validity conditions first; for a design pattern whose anchor is already loaded, skip `Mathematical Origins / Required Math` and read `AI Module Form / GPU Feasibility / Risks` directly.
- **Size tiers** (per file, approximate): books **L** (~4k tokens); design patterns **M** (~1.7–2.1k); knowledge anchors **M** (~1.3–1.7k); lenses **S** (~0.7–1.0k).
- **Path preference:** prefer S over M over L; prefer one card over a book; do not re-read math already covered by a loaded anchor (Eckart-Young, randomized SVD, spectral clustering, etc.).
- Read the `Routing / Extension / Deep References` tail only for citation or routing; output structure follows the task (see `../SKILL.md` output quality check).

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
| Matrix Analysis | `../knowledge-base/matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation, random-matrix, hankel-state-space |
| Optimization | `../knowledge-base/optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| Differential Geometry | `../knowledge-base/differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| Lie Theory | `../knowledge-base/lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance |
| Topology | `../knowledge-base/topology/` | persistent-homology, euler-characteristic, fundamental-group |
| Probability & Information | `../knowledge-base/probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information, optimal-transport, score-matching-sde |
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

**User**: “Design a new KV Cache compression method that preserves long-range dependencies without just doing top-k.”

Turn “preserve long-range dependencies” into a testable object. Let $D$ be the historical keys and values, and $F_D(q)$ the full-cache response to a future query. A compressor stores $s(D)$ and a readout returns $g(s(D),q)$. Lossless recovery requires:

$$s(D)=s(D')\quad\Longrightarrow\quad F_D(q)=F_{D'}(q)\quad\text{for every allowed }q.$$

This connects compression to a statistic sufficient for a family of queries: two histories with the same summary but different required answers refute a lossless claim. This query-relative sufficiency does not automatically establish Fisher–Neyman sufficiency for a statistical model.

Let the actual constraints determine alternative formulations. A guarantee over an entire query set may lead to uniform function approximation; accepting average loss under a specified query distribution may lead to decision risk under that distribution. These objectives can treat rare but important queries differently, so their guarantees cannot be interchanged. Do not silently assume future queries are predictable when the user has supplied no distribution.

After choosing an objective, derive the summary and update. For example, investigate whether a separable kernel permits additive query statistics and what conditions its normalization denominator needs; consult [mathematical construction moves](construction-moves.en.md) for relevant details. Compare existing low-rank prototypes after the candidate mapping holds. Use distinguishing queries and distribution shifts to examine tradeoffs; retained spectral energy alone does not establish retained task information.
## Temporary card and verification record

Use only when existing cards cannot support the current conclusion; a short paragraph may replace the table.

| Field | Minimum content |
|---|---|
| Domain and objects | Shared math / AI / crypto / AI×crypto; variables, spaces, quantifiers |
| Claim and conditions | Definition/theorem/derivation/hypothesis; conditions and target |
| Source and verification | Original paper or author-book link, theorem/section; explicitly label agent inference or external verification needed |
| Confidence | Evidence for this claim; verifying a theorem does not verify its AI transfer |
| Counterexample or experiment | Minimal falsification, or independent validation data and metrics |
| Unverified conclusions | Missing assumptions, proofs, or data; a temporary card is not a guarantee |

## On-demand worked examples

- AI compression: [query-aware-compression](worked-examples/query-aware-compression.en.md).
- AI equivariance: [equivariance-check](worked-examples/equivariance-check.en.md).
- Pure crypto: [security-reduction](worked-examples/security-reduction.en.md).

Read these separately; exploring examples is not a reason to load unrelated domains.
