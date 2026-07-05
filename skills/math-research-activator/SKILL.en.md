---
name: math-research-activator
description: |
  Mathematical research OS — auto-diagnoses user intent, routes to thinking lenses, math knowledge base, or design translation layer. Triggers on architecture/operator design, theoretical analysis, math-to-AI transfer. Does NOT trigger for pure engineering tasks (debug, refactoring, hyperparameter tuning).
---


> **File routing**: When this document references any file (lenses, knowledge-base, design-patterns, references, agents), always load the `.en.md` variant if it exists. For example, `../../lenses/symmetry.en.md` → load `lenses/symmetry.en.md`.
>
> ## Language Routing & Mixed-Input Rules
>
> Language routing only determines "which language version to read" and "what language to respond in." It does NOT affect whether the math system triggers or the A/B/C/D/E scenario classification.
>
> ### Decision Rules
>
> 1. **Judge the natural-language frame first**
>    - If the user's sentence structure, verbs, and mood particles are primarily Chinese, treat as Chinese even if English technical terms are interspersed.
>    - E.g., "帮我 design 一个 attention" / "这个 loss 有没有理论问题" → Chinese.
>
> 2. **English technical terms do not count as English primary language**
>    - attention, loss, routing, embedding, manifold, operator, kernel, KV-cache, transformer, MoE, etc. are domain terms and do not trigger a switch to English.
>
> 3. **Code, paths, and formulas are excluded from language detection**
>    - File paths, function names, variable names, LaTeX formulas, and CLI arguments do not count toward language ratio.
>
> 4. **When primary language is unclear, follow the user's last clear language**
>    - If the CN/EN ratio is close and indeterminate, use the user's most recent unambiguous natural language.
>    - If there is no prior context, default to Chinese.
>
> 5. **Output language matches primary language**
>    - Chinese primary → read `SKILL.md`, respond in Chinese, retaining necessary English terms.
>    - English primary → read `SKILL.en.md`, respond in English.
>    - If the user explicitly requests "in English" / "in Chinese," follow the explicit request.

# Math Research OS

> "The thinking system does not hand out theorems, the knowledge system does not indulge in loose inspiration, and the design layer does not fake profundity."

This system is a mathematical staff office for AI architecture innovation — not an arsenal, but one that tells you: **what kind of battle this is, which arms to deploy, how to deploy them, and where things could go wrong.**

## Core Principle

> Math Skill does not store mathematics. It activates, routes, and translates mathematics for AI research.

- **knowledge-base/** is not a closed encyclopedia but a set of mathematical activation anchors
- When existing cards cannot cover a problem, the agent must NOT stop or force-fit; instead, generate a "temporary knowledge card" based on lenses, reference layers, and the agent's own mathematical knowledge, then continue with design translation
- **design-patterns/** is a collection of math→AI translation prototypes, not a complete model repository; when no matching pattern exists, generate a temporary design candidate from the mathematical structure and label it as a temporary design pattern

## Three-Layer Orthogonal Architecture

| Layer | Responsibility | Directory | Core Question |
|-------|---------------|-----------|--------------|
| **Thinking Lenses** | Diagnose problem structure, recommend mathematical perspectives | `../../lenses/*.md` | Which perspective should we view this problem through? |
| **Math Knowledge** | Provide concrete mathematical tools (definitions/theorems/formulas) | `../../knowledge-base/*/*.md` | What specific mathematics does this perspective require? |
| **Design Translation** | Translate mathematics into AI modules/losses/operators | `../../design-patterns/*/*.md` | How does this mathematics become model architecture? |

Auxiliary layers:
- `../../references/books/*.md`: Distilled notes from 7 textbooks; full context when deeper understanding is needed
- `../../references/gpu-friendly-math.en.md`: GPU Eight-Dimension Acceptance Gate (single source of truth)
- `../../agents/math-critic.en.md`: Math-engineering dual critic

## Intent Diagnosis (5 Scenarios)

| Scenario | Diagnostic Signal | Invocation Path |
|----------|------------------|-----------------|
| **A. Problem Analysis** | "Is this design sound?" "Are there gaps in the reasoning chain?" | Lenses → critic |
| **B. Mechanism Design** | "Design a new attention mechanism" "Transfer X to Y" | Lenses → Knowledge → Design → critic |
| **C. Knowledge Query** | "What is a tangent space on a manifold?" "How is the projection theorem applied?" | Knowledge |
| **D. Verification & Review** | "Does this formula hold?" "What guarantees does this loss provide?" | Knowledge → critic |
| **E. Pure Engineering** | Debugging, refactoring, hyperparameter tuning, code review | **Do not invoke the math system** |

## Lens Library (15 Mathematical Perspectives)

Each lens answers: What is this perspective? What kinds of problems is it suited to diagnose? Which knowledge domains does it route to?

| Lens | File | Core Perspective |
|------|------|-----------------|
| Axiomatization | `../../lenses/axiomatization.en.md` | Examine consistency/independence/completeness of assumptions |
| Duality | `../../lenses/duality.en.md` | Transform to the dual space to expose constraints and invariants |
| Symmetry | `../../lenses/symmetry.en.md` | Invariants and conservation laws under transformations |
| Spectral Decomposition | `../../lenses/spectral.en.md` | Eigenvalues/singular values reveal dominant structure |
| Geometric | `../../lenses/geometric.en.md` | Metric/curvature/spatial structure on manifolds |
| Projection & Decomposition | `../../lenses/projection.en.md` | Orthogonal decomposition, subspace separation, conflict elimination |
| Variational | `../../lenses/variational.en.md` | Constrained extrema, energy minimization |
| Local-to-Global | `../../lenses/local-to-global.en.md` | Patching local properties into global ones, cohomological obstructions |
| Topological | `../../lenses/topological.en.md` | Invariants under continuous deformation, connectedness, holes |
| Categorical | `../../lenses/categorical.en.md` | Universal properties, functors, natural transformations |
| Perturbation | `../../lenses/perturbation.en.md` | Propagation of small perturbations, stability, robustness |
| Causal | `../../lenses/causal.en.md` | Correlation ≠ causation, interventions, counterfactuals |
| Game-Theoretic | `../../lenses/game.en.md` | Multi-agent strategic interaction, equilibria, mechanism design |
| Probabilistic & Statistical | `../../lenses/probabilistic.en.md` | Quantifying uncertainty, Bayesian updating |
| Algorithmic | `../../lenses/algorithmic.en.md` | Complexity, feasibility, parallelizability |

## Knowledge Base (Organized by Mathematical Domain)

Each knowledge card answers: Minimal definition, core formulas, applicable problems, AI design translation, engineering feasibility, risks.

| Domain | Directory | Knowledge Cards |
|--------|-----------|----------------|
| Matrix Analysis | `../../knowledge-base/matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| Optimization | `../../knowledge-base/optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| Differential Geometry | `../../knowledge-base/differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| Lie Theory | `../../knowledge-base/lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance |
| Topology | `../../knowledge-base/topology/` | persistent-homology, euler-characteristic, fundamental-group |
| Probability & Information | `../../knowledge-base/probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| Information Geometry | `../../knowledge-base/information-geometry/` | natural-gradient, fisher-metric |

## Design Pattern Library (Organized by AI Component)

Each design pattern answers: Mathematical origin, AI module form, implementable architecture, GPU feasibility, paper-level exposition, risks.

| Component Type | Directory | Patterns |
|---------------|-----------|----------|
| Attention | `../../design-patterns/attention/` | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| Loss Functions | `../../design-patterns/loss/` | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| Routing | `../../design-patterns/routing/` | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| Representation | `../../design-patterns/representation/` | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| Compression | `../../design-patterns/compression/` | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

## Automatic Trigger Conditions

**All of Gate 1 + Gate 2 + Gate 3 must be satisfied simultaneously for intervention:**

### Gate 0 · Exclusion Gate (Highest Priority)
The following tasks **never** trigger the system regardless of workspace contents: code review, debugging, refactoring, hyperparameter tuning, build/deployment, purely factual queries, general software engineering.

### Gate 1 · Environment Signal
The workspace contains architecture-level core code (attention/transformer/MoE, `*.cu`/kernel) or research notes. Routine files like `model.py` or `trainer.py` alone **do not** constitute an environment signal.

### Gate 2 · Task Signal
The user's task involves **designing/improving** a new architecture/operator, **analyzing** theoretical properties, **transferring** mathematical structures into AI design, or **querying math knowledge relevant to AI research** (e.g., "how is tangent space used in optimization?"). Pure encyclopedic math queries (e.g., "what is a group?" with no AI context) do not auto-trigger, but can be accessed via `/ask`.

### Gate 3 · Intent Match
The user's intent matches one of scenarios A/B/C/D. Pure engineering tasks matching scenario E → no intervention.

> **`/ask` entry**: Manual invocation skips Gate 1 and Gate 2, executing only Gate 0 (exclusion) + Gate 3 (intent match), allowing direct access to any scenario including knowledge queries.

## Main Workflow

### Step 1: Diagnose Intent
1. Determine which scenario (A/B/C/D/E) the user's intent belongs to
2. Extract the core tension of the problem: what to preserve? what to suppress? what are the constraints? what is the engineering bottleneck?
3. Output a problem-type classification

### Step 2: Route Invocation

```
Scenario A (Analysis): Select 1–3 lenses → output perspective diagnosis → critic review
Scenario B (Design): Select 1–3 lenses → invoke relevant activation anchors; if no coverage, enter Knowledge Gap Protocol → generate formal/temporary design patterns → critic review
Scenario C (Query): Prefer loading relevant activation anchors; if no coverage, generate temporary knowledge card → output per knowledge activation protocol
Scenario D (Verification): Load relevant anchors or temporary knowledge cards → critic reviews conditions and boundaries
Scenario E (Engineering): No intervention
```

### Step 3: Output Format

**Scenario A/B Output**:
1. **[Diagnosis]** Problem type + core tension
2. **[Lens]** Recommend 1–3 mathematical perspectives (annotate why each is/is not suitable)
3. **[Knowledge]** (Scenario B only) Activated mathematical structures (reference activation anchors or temporary knowledge cards)
4. **[Design]** (Scenario B only) Candidate AI module drafts (reference design patterns or temporary design drafts)
5. **[GPU]** Run candidates through the Eight-Dimension Gate (friendly/retrofittable/unfriendly)
6. **[Conclusion]** Retain candidates that pass both acceptance gates + next-step recommendations

**Scenario C Output** (Knowledge Activation Protocol):
1. Minimal definition
2. Core formulas
3. Applicable problems
4. AI design translation
5. Engineering feasibility
6. Risks and failure conditions
7. Further references (distilled book notes / original book paths)

**Scenario D Output**:
1. Conditions under which it holds
2. Conditions under which it fails
3. What it can guarantee at most
4. What it cannot guarantee
5. Engineering feasibility

**A conclusion must always be provided — never output analysis alone without convergence.**

## GPU Eight-Dimension Acceptance Gate

Formal terminology (single authoritative source: `../../references/gpu-friendly-math.en.md`):
**Tensorization / GEMM-mappability / Complexity / Memory & KV-Cache / Low-Precision Stability / Parallelism & Communication / Sparse Structure / Operator Fusion**

**Quantitative assessment requirements**: For each candidate design, the GPU assessment should not only provide [v]/[~]/[x] labels but also answer:
1. FLOPs of core operations and ratio vs. baseline
2. Peak memory (bytes), whether large matrices are materialized
3. Numerical stability strategy under bf16/fp8
4. Number of fusible kernels and expected speedup

See the quantitative checklist in `../../references/gpu-friendly-math.en.md`.

## Depth-of-Consultation Protocol

- **Light**: Read knowledge cards (`../../knowledge-base/*/*.md`); self-contained and immediately usable
- **Medium**: Read distilled book notes (`../../references/books/*.md`) for more complete context
- **Deep**: When `math_book/<PDF>` is available locally, the agent automatically runs `pdftotext` + grep to locate the original page

## Knowledge Gap Protocol

When the mathematical tools required by the user's problem are not in the existing `knowledge-base/`, do NOT force-fit existing cards. Execute the following procedure:

1. **Gap Identification**: Explicitly state that no fully corresponding knowledge card exists. Classify the gap as: new domain, new theorem family, new structure, new application scenario, or combinatorial extension of existing cards.

2. **Lens Fallback**: Select 1–3 most relevant thinking lenses to determine the problem's mathematical structure. E.g., local-to-global, categorical, spectral, projection, causal, perturbation.

3. **Candidate Knowledge Localization**: Provide mathematical keywords, theorem families, concept clusters, and reference book directions to look up. Existing card coverage is not required, but explain why these concepts are relevant.

4. **Temporary Knowledge Card**: Generate a temporary knowledge summary in the same format as formal cards:
   - Minimal definition
   - Core structure
   - Applicable problems
   - AI design translation
   - GPU feasibility
   - Risks and failure conditions
   - **Source & Confidence** (required):
     - Knowledge source: label as "Agent inference / Lens derivation / Reference book extrapolation / Requires external verification"
     - Confidence: High (theorem-backed) / Medium (reasonable inference, not rigorously proven) / Low (exploratory hypothesis)
     - Unverified claims: list key conclusions requiring subsequent verification

5. **Design Translation**: If the user's goal is mechanism design, translate the temporary knowledge into candidate AI modules, losses, routing, attention, representation, or compression schemes.

6. **Upgrade Recommendation**: If this gap recurs frequently, recommend adding a formal knowledge card or design pattern.

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
