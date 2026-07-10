<p align="right">
  <a href="README.md">中文</a> | <a href="README.en-US.md">English</a>
</p>

# 📐 Math Skill — A Mathematical Research Operating System for AI Architecture Design

> **The thinking system does not hand out theorems. The knowledge system does not improvise inspiration. The design layer does not fake profundity.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

> **If this project inspires you, please consider leaving a Star⭐.** Every Star is a resonance with the beauty of mathematics — and the fuel that keeps this project alive. Welcome, every fellow traveler who loves math and sails its vast ocean.

---

## 📢 Community Announcements

> **This skill is under rapid iteration — your feedback and suggestions are warmly welcome!** Your input is the core driver of our continuous evolution. Feel free to reach out via GitHub Issues or Discussions.

> **【Coming Soon】** Cryptography-related content will be added to support cryptography research — including number theory foundations, finite fields, coding theory, lattice-based cryptography, and more. Stay tuned!

---

## Inspiration

The story of Sophus Lie forging a "dragon-slaying blade" tells us this: the Lie group–Lie algebra machinery invented to solve differential equations ended up becoming the lingua franca for describing symmetry and robot state estimation — the value of a mathematical tool far outlives its original intent, which is exactly the prototype of "cross-domain activation." See [`references/inspiration.en.md`](references/inspiration.en.md).

> The most fascinating thing about mathematics: a tool invented for one problem reveals unforeseen power in an entirely different domain.

---

> Math Skill does not store mathematics. It activates, routes, and translates mathematics for AI research.

## Philosophy

When you face an AI research problem, this system helps you answer four questions:

1. **What mathematical perspective should I use?** → Thinking Lenses
2. **Which mathematical structures to activate?** → Activation Anchors / Temporary Knowledge Cards
3. **How do I turn math into model design?** → Design Translation Prototypes
4. **Is it mathematically sound and engineering-feasible?** → Critic

```
Problem
 ↓
Thinking Lenses: What perspective fits this problem?
 ↓
Activation Anchors: Which math structures to activate? Enter Knowledge Gap Protocol if insufficient
 ↓
Design Translation: How do these tools become model structures / losses / operators?
 ↓
Critic: Mathematically sound? Engineering-feasible?
```

---

## Three-Layer Orthogonal Architecture

| Layer | Role | Directory | Files |
|-------|------|-----------|-------|
| **Thinking Lenses** | Diagnose problem structure, recommend math perspectives | `lenses/*.md` | 15 |
| **Activation Anchors** | Activate high-frequency math structures; trigger Knowledge Gap Protocol when insufficient | `knowledge-base/*/*.md` | 31 |
| **Design Translation** | Bridge math to AI modules/losses/operators | `design-patterns/*/*.md` | 22 |

Supporting layers:
- `references/books/*.md`: 7 book distillations for deep context
- `references/gpu-friendly-math.en.md`: GPU 8-dimension acceptance gate
- `agents/math-critic.en.md`: Math-engineering dual critic

### 15 Thinking Lenses

| Lens | File | Core Perspective |
|------|------|-----------------|
| Axiomatization | `lenses/axiomatization.en.md` | Audit assumptions for consistency/independence/completeness |
| Duality | `lenses/duality.en.md` | Transform to dual space to expose constraints and invariants |
| Symmetry | `lenses/symmetry.en.md` | Invariants and conservation laws under transformations |
| Spectral | `lenses/spectral.en.md` | Eigenvalues/singular values reveal dominant structure |
| Geometric | `lenses/geometric.en.md` | Metric/curvature/manifold spatial structure |
| Projection | `lenses/projection.en.md` | Orthogonal decomposition, subspace separation, conflict elimination |
| Variational | `lenses/variational.en.md` | Constrained extrema, energy minimization |
| Local-to-Global | `lenses/local-to-global.en.md` | Assemble local properties into global structure |
| Topological | `lenses/topological.en.md` | Continuous-deformation invariants, connectivity, holes |
| Categorical | `lenses/categorical.en.md` | Universal properties, functors, natural transformations |
| Perturbation | `lenses/perturbation.en.md` | Propagation of small perturbations, stability, robustness |
| Causal | `lenses/causal.en.md` | Correlation ≠ causation, interventions, counterfactuals |
| Game | `lenses/game.en.md` | Multi-agent strategic interaction, equilibrium, mechanism design |
| Probabilistic | `lenses/probabilistic.en.md` | Quantify uncertainty, Bayesian updating |
| Algorithmic | `lenses/algorithmic.en.md` | Complexity, feasibility, parallelism |

### Activation Anchors (by math domain)

| Domain | Anchors |
|--------|-------|
| Matrix Analysis | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| Optimization | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| Differential Geometry | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| Lie Theory | group-action, lie-group, lie-algebra, representation, equivariance |
| Topology | persistent-homology, euler-characteristic, fundamental-group |
| Probability & Information | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| Information Geometry | natural-gradient, fisher-metric |

### Design Patterns (by AI component)

| Component | Patterns |
|-----------|----------|
| Attention | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| Loss | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| Routing | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| Representation | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| Compression | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

---

## Quick Start

### Installation

```
Please help me install math-skill: https://github.com/the-thinker0/math-skill, and show me how to use it
```

Manual install:

```bash
git clone https://github.com/the-thinker0/math-skill.git
```

### Usage

**Auto-trigger**: The system auto-diagnoses user intent and routes to the appropriate layer:

| Scenario | Signal | Path |
|----------|--------|------|
| Problem Analysis | "Is this design sound?" | Lenses → Critic |
| Mechanism Design | "Design a new attention" | Lenses → Anchors / Temporary Card → Design → Critic |
| Knowledge Query | "What is tangent space and how does it relate to gradient optimization?" | Anchors; Knowledge Gap Protocol if insufficient |
| Verification | "Does this formula hold?" | Anchors / Temporary Card → Critic |
| Pure Engineering | debug, refactoring, tuning | **Not triggered** |

**Manual trigger**:

```
/ask <your question>     # Smart diagnosis: auto-detect scenario and route
```

### Language Switching

Auto-detects user language: Chinese messages get Chinese output, English messages get English output.

---

## Workflow Example

**User**: "Design a new KV Cache compression method that preserves long-range dependencies without just doing top-k"

```
Step 1  Diagnosis: Scenario B (Mechanism Design)
  Problem type: sequence memory compression + information preservation + long-range structure
  Core tension: compress token count vs. preserve long-range dependencies

Step 2  Lens Selection:
  1. Spectral (preserve dominant subspace)
  2. Information-theoretic (preserve max mutual information states)
  3. Topological (preserve key connection points in sequence structure)

Step 3  Activation Anchors:
  → low-rank-approximation (Matrix Analysis anchor)
  → leverage-score-selection (Design Pattern: compression)
  → information-bottleneck (Probability & Information anchor)
  If existing anchors are insufficient, enter Knowledge Gap Protocol to generate a temporary knowledge card.

Step 4  Design Translation:
  Candidate A: Spectral KV Compression (low-rank + leverage score)
  Candidate B: Information-Preserving Cache (query sensitivity)
  Candidate C: Topology-Preserving Cache (graph bridge node retention)

Step 5  Critic Review:
  A is most GPU-friendly, B needs future query estimation (uncertainty), C graph construction too expensive
  Recommendation: prioritize A, use B as a lightweight gate
```

---

## Directory Structure

```
math-skill/
├── skills/
│   └── math-research-activator/    # Orchestrator: intent diagnosis + routing
├── lenses/                         # 15 thinking lenses (reasoning methodology)
├── knowledge-base/                 # Activation anchors by math domain, not a closed encyclopedia
│   ├── matrix-analysis/            # Matrix analysis (5 cards)
│   ├── optimization/               # Optimization (5 cards)
│   ├── differential-geometry/      # Differential geometry (6 cards)
│   ├── lie-theory/                 # Lie theory (5 cards)
│   ├── topology/                   # Topology (3 cards)
│   ├── probability/                # Probability & information (5 cards)
│   └── information-geometry/       # Information geometry (2 cards)
├── design-patterns/                # Design translation (by AI component)
│   ├── attention/                  # Attention mechanisms (5 patterns)
│   ├── loss/                       # Loss functions (5 patterns)
│   ├── routing/                    # Routing (4 patterns)
│   ├── representation/             # Representation (4 patterns)
│   └── compression/                # Compression (4 patterns)
├── references/                     # Reference layer
│   ├── books/                      # 7 book distillations
│   ├── gpu-friendly-math.en.md     # GPU 8-dimension gate
│   ├── agentic-workflow.en.md      # Collaboration style
│   └── inspiration.en.md           # Inspiration
├── agents/math-critic.en.md           # Math-engineering dual critic
├── commands/ask.en.md                 # /ask manual entry
├── math_book/                      # Local PDFs (not published)
└── README.md / LICENSE
```

---

## Recommended Books

| # | Title | Author(s) | Publisher / Edition | Year | ISBN | Distillation |
|---|-------|-----------|-------------------|------|------|-------------|
| 1 | *Contemporary Abstract Algebra* | Joseph A. Gallian | Brooks/Cole, Cengage, 8th ed. | 2013 | 978-1-133-59971-5 | `abstract-algebra.en.md` |
| 2 | *The Rising Sea: Foundations of Algebraic Geometry* | Ravi Vakil | Princeton University Press | 2025 | 978-0-691-26866-8 | `algebraic-geometry-rising-sea.en.md` |
| 3 | *Manifolds and Differential Geometry* | Jeffrey M. Lee | AMS, Graduate Studies in Math Vol. 107 | 2009 | 978-0-8218-4815-9 | `differential-geometry.en.md` |
| 4 | *Matrix Analysis* | Roger A. Horn, Charles R. Johnson | Cambridge University Press, 2nd ed. | 2013 | 978-0-521-83940-2 | `matrix-analysis.en.md` |
| 5 | *A micro Lie theory for state estimation in robotics* | Joan Solà et al. | arXiv:1812.01537v9 | 2021 | — | `micro-lie-theory.en.md` |
| 6 | *An Introduction to Optimization, With Applications to ML* | Chong, Lu, Żak | John Wiley & Sons, 5th ed. | 2024 | 978-1-119-87763-9 | `optimization-ml.en.md` |
| 7 | *Introduction to Smooth Manifolds* | John M. Lee | Springer, GTM 218, 2nd ed. | 2013 | 978-1-4419-9981-8 | `smooth-manifolds.en.md` |

Distillation files ship with the npm package. For full-fidelity lookups, place PDFs in the `math_book/` folder.

---

## Changelog

### v3.1.1 — Terminology Consistency Cleanup

- **skill-index alignment**: title, knowledge base section, and workflow example updated from "knowledge base / knowledge query" to "activation anchors"
- **package.json description**: updated to new positioning
- **README usage table**: mechanism design, knowledge query, and verification paths updated from "Knowledge" to "Anchors / Temporary Card"
- **README workflow example**: Step 3 changed from "Knowledge Query" to "Activation Anchors"; `leverage-score-selection` label corrected from "matrix analysis" to "Design Pattern: compression"
- **README directory structure**: `knowledge-base/` comment updated from "Math knowledge" to "Activation anchors"
- **README activation anchors table**: column header changed from "Cards" to "Anchors"
- **SKILL.md / SKILL.en.md**: three-layer architecture table and intent diagnosis table updated from "Math Knowledge" to "Activation Anchors"
- **English README book links**: distillation files changed from `.md` to `.en.md`
- **validate keywords**: checks updated from "Math Knowledge" to "Activation Anchors"

### v3.1.0 — Activation Anchors & Knowledge Gap Protocol

**Repositioning**: from "math knowledge base" to "math activation system" — the knowledge base is not a closed encyclopedia but a collection of activation anchors.

- **Core Principle**: Math Skill does not store mathematics; it activates, routes, and translates mathematics for AI research
- **Knowledge Gap Protocol**: 6-step procedure for generating temporary knowledge cards when existing anchors don't cover the problem (gap identification → lens fallback → candidate localization → temporary card → design translation → upgrade recommendation)
- **Domain Extension Indexes**: each of the 7 math domains gains an `index.md` with trigger signals, extended concepts, reference directions, and temporary activation rules
- **Knowledge Card Repositioning**: every card gains "Routing Extensions" and "Extensible Directions" sections, transforming endpoints into routing nodes
- **Design Pattern Positioning**: new `design-patterns/overview.en.md` declares the library as a math→AI translation prototype collection

### v3.0.1 — Token Optimization & Bilingual Completion

- **Emoji cleanup**: removed all emoji characters from skill files; GPU rating markers replaced with text `[v]`/`[~]`/`[x]`, saving ~1,400 tokens
- **English distillation files**: added EN translations for all 7 book distillation notes (`references/books/*.en.md`) and `commands/ask.en.md`
- **Mixed-language routing**: added 5-rule decision system for code-switched input (technical terms excluded from language detection; sentence frame determines primary language)
- **GPU dimension abbreviations**: verbose labels `**Dimension N full-name**` compressed to `**DN**` (D1-D8), defined in `gpu-friendly-math.md`, saving ~800-1,000 tokens
- Terminology unification, cross-reference fixes, and other minor improvements

### v3.0.0 — Mathematical Research Operating System

**Architecture overhaul**: from "thinking weapon arsenal" to "math general staff" — three-layer orthogonal architecture:

- **Thinking Lenses** (15): slimmed down from v2's "thinking weapons" — reasoning methodology only, no concrete math knowledge mixed in
- **Knowledge Base** (31 cards): concrete math tools organized by domain, with definitions/formulas/AI design translation/GPU feasibility
- **Design Translation Layer** (new): the bridge from math to AI modules, organized by AI component (attention/loss/routing/representation/compression)
- **Activator rewrite**: from environment-signal matching to intent diagnosis (5 scenarios: analysis/design/query/verification/engineering)
- **Knowledge activation protocol**: fixed output format for knowledge cards (minimal definition → formula → applicable problems → AI translation → engineering feasibility → risks)

### v2.1.0 — Full Bilingual Support
- 37 .en.md files, auto language routing, same commands for both languages, no double token cost

### v2.0.1
- Tightened auto-trigger conditions, added exclusion gate, narrowed environment signals

### v2.0.0
- 16 thinking weapons, modern math activation layer, GPU 8-D cross-cut

### v1.0.0
- Initial release: fifteen thinking weapons + dual research/life paths

---

## License

MIT License. See `LICENSE`.

---

## Contributing

Issues and Pull Requests are welcome!

---

## Star History

<a href="https://www.star-history.com/?repos=the-thinker0%2Fmath-skill&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&legend=top-left" />
 </picture>
</a>
