<p align="right">
  <a href="README.md">中文</a> | <a href="README.en-US.md">English</a>
</p>

# ⚔️ Math Skill — A Mathematical Research Operating System for AI Architecture Design

> **The thinking system does not hand out theorems. The knowledge system does not improvise inspiration. The design layer does not fake profundity.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

> **If this project inspires you, please consider leaving a Star⭐.** Every Star is a resonance with the beauty of mathematics — and the fuel that keeps this project alive. Welcome, every fellow traveler who loves math and sails its vast ocean.

---

## Inspiration

The story of Sophus Lie forging a "dragon-slaying blade" tells us this: the Lie group–Lie algebra machinery invented to solve differential equations ended up becoming the lingua franca for describing symmetry and robot state estimation — the value of a mathematical tool far outlives its original intent, which is exactly the prototype of "cross-domain activation." See [`references/inspiration.md`](references/inspiration.md).

> The most fascinating thing about mathematics: a tool invented for one problem reveals unforeseen power in an entirely different domain.

---

## Philosophy

When you face an AI research problem, this system helps you answer four questions:

1. **What mathematical perspective should I use?** → Thinking Lenses
2. **What specific math do I need?** → Knowledge Base
3. **How do I turn math into model design?** → Design Translation
4. **Is it mathematically sound and engineering-feasible?** → Critic

```
Problem
 ↓
Thinking Lenses: What perspective fits this problem?
 ↓
Math Knowledge: What specific tools does this perspective need?
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
| **Math Knowledge** | Provide concrete math tools (definitions/theorems/formulas) | `knowledge-base/*/*.md` | 26 |
| **Design Translation** | Bridge math to AI modules/losses/operators | `design-patterns/*/*.md` | 15+ |

Supporting layers:
- `references/books/*.md`: 7 book distillations for deep context
- `references/gpu-friendly-math.md`: GPU 8-dimension acceptance gate
- `agents/math-critic.md`: Math-engineering dual critic

### 15 Thinking Lenses

| Lens | File | Core Perspective |
|------|------|-----------------|
| Axiomatization | `lenses/axiomatization.md` | Audit assumptions for consistency/independence/completeness |
| Duality | `lenses/duality.md` | Transform to dual space to expose constraints and invariants |
| Symmetry | `lenses/symmetry.md` | Invariants and conservation laws under transformations |
| Spectral | `lenses/spectral.md` | Eigenvalues/singular values reveal dominant structure |
| Geometric | `lenses/geometric.md` | Metric/curvature/manifold spatial structure |
| Projection | `lenses/projection.md` | Orthogonal decomposition, subspace separation, conflict elimination |
| Variational | `lenses/variational.md` | Constrained extrema, energy minimization |
| Local-to-Global | `lenses/local-to-global.md` | Assemble local properties into global structure |
| Topological | `lenses/topological.md` | Continuous-deformation invariants, connectivity, holes |
| Categorical | `lenses/categorical.md` | Universal properties, functors, natural transformations |
| Perturbation | `lenses/perturbation.md` | Propagation of small perturbations, stability, robustness |
| Causal | `lenses/causal.md` | Correlation ≠ causation, interventions, counterfactuals |
| Game | `lenses/game.md` | Multi-agent strategic interaction, equilibrium, mechanism design |
| Probabilistic | `lenses/probabilistic.md` | Quantify uncertainty, Bayesian updating |
| Algorithmic | `lenses/algorithmic.md` | Complexity, feasibility, parallelism |

### Knowledge Base (by math domain)

| Domain | Cards |
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
| Mechanism Design | "Design a new attention" | Lenses → Knowledge → Design → Critic |
| Knowledge Query | "What is tangent space and how does it relate to gradient optimization?" | Knowledge |
| Verification | "Does this formula hold?" | Knowledge → Critic |
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

Step 3  Knowledge Query:
  → low-rank-approximation (matrix analysis)
  → leverage-score-selection (matrix analysis)
  → information-bottleneck (probability & information)

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
├── knowledge-base/                 # Math knowledge (by domain)
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
│   ├── gpu-friendly-math.md        # GPU 8-dimension gate
│   ├── agentic-workflow.md         # Collaboration style
│   └── inspiration.md              # Inspiration
├── agents/math-critic.md           # Math-engineering dual critic
├── commands/ask.md                 # /ask manual entry
├── math_book/                      # Local PDFs (not published)
└── README.md / LICENSE
```

---

## Recommended Books

| # | Title | Author(s) | Publisher / Edition | Year | ISBN | Distillation |
|---|-------|-----------|-------------------|------|------|-------------|
| 1 | *Contemporary Abstract Algebra* | Joseph A. Gallian | Brooks/Cole, Cengage, 8th ed. | 2013 | 978-1-133-59971-5 | `abstract-algebra.md` |
| 2 | *The Rising Sea: Foundations of Algebraic Geometry* | Ravi Vakil | Princeton University Press | 2025 | 978-0-691-26866-8 | `algebraic-geometry-rising-sea.md` |
| 3 | *Manifolds and Differential Geometry* | Jeffrey M. Lee | AMS, Graduate Studies in Math Vol. 107 | 2009 | 978-0-8218-4815-9 | `differential-geometry.md` |
| 4 | *Matrix Analysis* | Roger A. Horn, Charles R. Johnson | Cambridge University Press, 2nd ed. | 2013 | 978-0-521-83940-2 | `matrix-analysis.md` |
| 5 | *A micro Lie theory for state estimation in robotics* | Joan Solà et al. | arXiv:1812.01537v9 | 2021 | — | `micro-lie-theory.md` |
| 6 | *An Introduction to Optimization, With Applications to ML* | Chong, Lu, Żak | John Wiley & Sons, 5th ed. | 2024 | 978-1-119-87763-9 | `optimization-ml.md` |
| 7 | *Introduction to Smooth Manifolds* | John M. Lee | Springer, GTM 218, 2nd ed. | 2013 | 978-1-4419-9981-8 | `smooth-manifolds.md` |

Distillation files ship with the npm package. For full-fidelity lookups, place PDFs in the `math_book/` folder.

---

## Changelog

### v3.0.0 — Mathematical Research Operating System

**Architecture overhaul**: from "thinking weapon arsenal" to "math general staff" — three-layer orthogonal architecture:

- **Thinking Lenses** (15): slimmed down from v2's "thinking weapons" — reasoning methodology only, no concrete math knowledge mixed in
- **Knowledge Base** (26 cards): concrete math tools organized by domain, with definitions/formulas/AI design translation/GPU feasibility
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
