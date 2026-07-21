<p align="right">
  <a href="README.md">中文</a> | <a href="README.en-US.md">English</a>
</p>

# 📐 Math Skill: A Mathematical Research Operating System for AI and Cryptography Innovation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

> **If this project inspires you, please consider leaving a Star⭐.** Every Star is a resonance with the beauty of mathematics — and the fuel that keeps this project alive. Welcome, every fellow traveler who loves math and sails its vast ocean.

---

## 📢 Community Announcements

> **This skill is under rapid iteration — your feedback and suggestions are warmly welcome!** Your input is the core driver of our continuous evolution. Feel free to reach out via GitHub Issues or Discussions.

> **v3.3.0**: canonical entry structure, minimum-context routing, AI/cryptography isolation, mathematical and cryptographic corrections, relevance-driven GPU review, and complete bilingual pairing. Root `SKILL.md` is authoritative, and all three cryptography distillations now have dedicated English versions. See the changelog.

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

> **v3.2.1 Design Philosophy Refinement**: This skill is a mathematical-thinking activator and anchor, not a knowledge encyclopedia. `knowledge-base/` anchors describe mathematical structures (manifolds, spectra, sheaf cohomology, pseudorandom function families, etc.), not specific AI architectures (diffusion, SSM, etc.); `design-patterns/` is a paradigmatic demonstration of "math→AI module" translation, not a copy-paste template library. This ensures the skill retains guiding capacity for any research direction (diffusion, SSM, MoE, alignment, etc.) and does not become outdated as concrete architectures evolve.

---

## Three-Layer Orthogonal Architecture

| Layer | Role | Directory | Files |
|-------|------|-----------|-------|
| **Thinking Lenses** | Diagnose problem structure, recommend math perspectives | `lenses/*.md` | 15 |
| **Activation Anchors** | 33 shared-math anchors + 4 cryptography anchors; trigger Knowledge Gap Protocol when insufficient | `knowledge-base/*/*.md` | 37 |
| **Design Translation** | Bridge math to AI modules/losses/operators | `design-patterns/*/*.md` | 22 |

Supporting layers:
- `references/books/*.md`: 10 book distillations (7 AI-direction + 3 cryptography-direction) for deep context
- `references/gpu-friendly-math.en.md`: on-demand GPU checks with N/A for irrelevant dimensions
- `agents/math-critic.en.md`: 19-dimension deep critic loaded only for comprehensive or paper-grade review

### Domain Router (new in v3.2.0)

AI research and cryptography **share** mathematical foundations (probability/information/algebra/matrix/spectrum/optimization) but each has **exclusive** specialty layers. After intent diagnosis and before lens invocation, Domain Router determines the problem's domain and decides which anchors/books/design patterns to load, avoiding cross-domain pollution and token waste.

| Domain | Loaded Content | Signal Keywords |
|--------|----------------|------------------|
| **Shared Mathematics** | 33 anchors across 8 domains plus relevant lenses | probability/information/algebra/geometry/matrix/spectral/optimization/topology/complexity |
| **AI Research** | Shared math on demand + 0–2 relevant design prototypes; books only for deep checks | attention/loss/routing/representation/compression/MoE/transformer/KV-cache/LoRA/SSM/diffusion/RL |
| **Cryptography** | 4 crypto anchors; then 3 crypto books only if needed; shared math on demand | encryption/signature/MAC/PRF/PRG/PRP/OWF/CCA/CPA/AE/ZK/reduction/DL/CDH/DDH/RSA/ECC/lattice |
| **AI×Crypto** | dual-domain load + intersection annotation | "PRF for watermarking," "adversarial example reduction," "verifiable inference" |

> Rules: domain judgment precedes lens invocation; shared math is not redundantly loaded; no pollution across non-cross domains; gap-protocol temporary cards are domain-tagged.

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
| Algebraic Geometry | sheaf-cohomology, grassmannian-plucker |
| Cryptography (exclusive) | prf-prg-owf, reduction-proof-template, attack-game-framework, cca-cpa-ae-hierarchy |

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

Manual Codex install (install the whole repository as one self-contained skill; do not copy only the nested entry):

```bash
git clone https://github.com/the-thinker0/math-skill.git ~/.codex/skills/math-research-activator
```

Root `SKILL.md` is the canonical Codex entry. `skills/math-research-activator/SKILL.md` is only a Claude/plugin-style compatibility entry that forwards to the root. Copying the nested directory alone omits its anchors and design patterns.

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
│   ├── books/                      # 10 book distillations (7 AI + 3 crypto)
│   ├── gpu-friendly-math.en.md     # GPU checklist (applicable dimensions only)
│   ├── agentic-workflow.en.md      # Collaboration style
│   └── inspiration.en.md           # Inspiration
├── agents/math-critic.en.md           # Math-engineering dual critic (19 dims, with crypto security review)
├── commands/ask.en.md                 # /ask manual entry
├── math_book/                      # Local PDFs (not published)
└── README.md / LICENSE
```

---

## Recommended Books

### AI Direction (7 books)

| # | Title | Author(s) | Publisher / Edition | Year | ISBN | Distillation |
|---|-------|-----------|-------------------|------|------|-------------|
| 1 | *Contemporary Abstract Algebra* | Joseph A. Gallian | Brooks/Cole, Cengage, 8th ed. | 2013 | 978-1-133-59971-5 | `abstract-algebra.en.md` |
| 2 | *The Rising Sea: Foundations of Algebraic Geometry* | Ravi Vakil | Princeton University Press | 2025 | 978-0-691-26866-8 | `algebraic-geometry-rising-sea.en.md` |
| 3 | *Manifolds and Differential Geometry* | Jeffrey M. Lee | AMS, Graduate Studies in Math Vol. 107 | 2009 | 978-0-8218-4815-9 | `differential-geometry.en.md` |
| 4 | *Matrix Analysis* | Roger A. Horn, Charles R. Johnson | Cambridge University Press, 2nd ed. | 2013 | 978-0-521-83940-2 | `matrix-analysis.en.md` |
| 5 | *A micro Lie theory for state estimation in robotics* | Joan Solà et al. | arXiv:1812.01537v9 | 2021 | — | `micro-lie-theory.en.md` |
| 6 | *An Introduction to Optimization, With Applications to ML* | Chong, Lu, Żak | John Wiley & Sons, 5th ed. | 2024 | 978-1-119-87763-9 | `optimization-ml.en.md` |
| 7 | *Introduction to Smooth Manifolds* | John M. Lee | Springer, GTM 218, 2nd ed. | 2013 | 978-1-4419-9981-8 | `smooth-manifolds.en.md` |

### Cryptography Direction (3 books, new in v3.2.0)

| # | Title | Author(s) | Publisher / Edition | Year | ISBN | Distillation |
|---|-------|-----------|-------------------|------|------|-------------|
| 8 | *A Graduate Course in Applied Cryptography* | Dan Boneh & Victor Shoup | v0.4 online | 2017 | — | `applied-cryptography.en.md` |
| 9 | *Foundations of Cryptography, Volume 1: Basic Tools* | Oded Goldreich | Cambridge University Press | 2001 | 978-0-521-79235-9 | `foundations-of-cryptography.en.md` |
| 10 | *Introduction to Modern Cryptography* | Jonathan Katz & Yehuda Lindell | CRC Press, 2nd ed. | 2015 | 978-1-4665-7026-1 | `introduction-to-modern-cryptography.en.md` |

> All three cryptography distillations now have Chinese and English pairs. Select `.md` or `.en.md` by the user's primary language, and load them only when anchors are insufficient or book-level depth is needed.

Distillation files ship with the npm package. For full-fidelity lookups, place PDFs in the `math_book/` folder.

---

## Changelog

### v3.3.0 — Routing Convergence, Bilingual Completion & Technical Corrections

- **Canonical entry and compatibility structure**: root `SKILL.md` / `SKILL.en.md` are now complete, self-contained normative entries. `skills/math-research-activator/SKILL*.md` are thin forwarders that preserve Claude/plugin layouts without allowing two full instruction copies to drift. `commands/ask*`, the critic, indexes, and overview now reference the root entries.
- **Progressive loading and minimum token use**: Scenarios A analysis, B design, C knowledge, D verification, and E engineering receive explicit minimal paths, normally capped at 1–2 lenses, 1–3 anchors, and 0–2 prototypes. Concept questions, pure-crypto tasks, and ordinary verification no longer load the full critic, books, GPU checklist, or directory index by default, and internal loading traces are not repeated to users.
- **Domain Router rewrite**: routing now uses target object + requested guarantee instead of keyword voting. Isolated terms such as `hashing`, `attack`, and `security` no longer cause crypto false positives. Shared math, pure AI, pure crypto, and AI×crypto paths are isolated; the cross-domain four-tuple appears only for genuine transfers between a cryptographic primitive/security property and an AI object.
- **Cryptography decontamination**: the four crypto anchors are organized around security definitions, attack games, reduction loss, construction boundaries, and implementation considerations rather than forced AI translations or GPU gates. They distinguish standard-model theorems, primitive-based reductions, and empirical assumptions about concrete algorithms such as AES, and correct wording around PRF/PRG/OWF, Feistel, CPA/CCA/AE, KEM/DEM, nonces/IVs, key separation, and composition order.
- **Mathematical and engineering corrections**: corrected the Moore–Penrose conditions for general projections, the boundary between attention/QKV and linear projection, KL directionality, low-rank-gradient claims, orthogonality-loss shape/normalization assumptions, and overextended analogies in algebra and geometry notes. Claims of guarantees, equivalence, stability, or optimality now state their conditions or are downgraded to testable hypotheses.
- **Complete bilingual cryptography references**: added `applied-cryptography.en.md`, `foundations-of-cryptography.en.md`, and `introduction-to-modern-cryptography.en.md`. Commands, agents, lenses, knowledge-base, design-patterns, and references now all maintain Chinese/English pairs; only the user's primary-language side is loaded.
- **Relevance-driven GPU review**: candidates no longer mechanically fill all eight dimensions. Reviews first state shape, baseline, and deployment constraints, assess only decision-relevant dimensions, and mark others `N/A`. Judgments require checkable FLOPs, peak intermediate/state memory, byte or communication counts, or low-precision risks; “expressible as GEMM” is explicitly not equivalent to “faster.”
- **Critic and output-quality convergence**: ordinary tasks use the compact checks in the root entry, while the 19-dimension critic is reserved for paper-grade or explicitly comprehensive review. The modern-math dimension is mandatory only when a transfer claim exists; crypto prefers `knowledge-base/cryptography/` anchors before books and never uses the GPU checklist as a security gate; exploratory candidates must state assumptions, boundaries, and falsification methods.
- **Pre-release consistency fixes**: compatibility-entry descriptions re-synced with root `SKILL.md` (including math-query triggers); index workflow examples restored to the default ≤2-lens budget; CLAUDE/eval Gate terminology removed and the bilingual books fact corrected; sheaf-cohomology $H^1$ wording tightened so it is not confused with the sheaf axiom.
- **Synchronized indexes, routing examples, and language rules**: updated `skill-index`, `knowledge-base/overview`, the agentic workflow, and A/B/C/D/E eval scenarios with false-positive, intersection, knowledge-gap, and primary-language boundaries. Code, paths, formulas, and English technical terms do not vote on response language.
- **Evaluation-scope cleanup**: removed the six-dimension output score and token/cost regression specification created only for this audit, while retaining routing, isolation, bilingual, reference-integrity, and semantic-regression scenarios that directly test skill behavior.
- **Validation and package integrity**: Bash/PowerShell validation covers root frontmatter, compatibility forwarders, 37 anchors, bilingual pairing, cross-references, Domain Router isolation, the Knowledge Gap Protocol, GPU quantitative signals, and high-risk semantic regressions. The npm package explicitly includes root `SKILL*.md` and excludes PDFs, `math_book/`, tests, and the local npm cache.

### v3.2.1 — Design Philosophy Refinement & Reliability Enhancement

- **Design philosophy made explicit**: `SKILL.md` / `SKILL.en.md` add a "Design Philosophy: Activator, Not Encyclopedia" section, declaring the skill is a thinking activator and mathematical anchor; `knowledge-base/` returns to mathematical structures themselves (not concrete AI architectures); `design-patterns/` is positioned as translation-prototype demonstration rather than a template library. A new "Compatibility Principle" section declares that research problems with architectures the skill did not pre-specify are handled through the lens-routing + anchor-activation + temporary-knowledge-card pipeline.
- **Cryptography anchors backfilled**: new `knowledge-base/cryptography/` directory, with `prf-prg-owf`, `reduction-proof-template`, `attack-game-framework`, `cca-cpa-ae-hierarchy` anchor cards (CN/EN paired), giving Domain Router's cryptography layer substantive anchors (fixes v3.2.0 inconsistency: it declared loading a cryptography layer but had no structured anchors).
- **Algebraic geometry anchors backfilled**: new `knowledge-base/algebraic-geometry/` directory, with `sheaf-cohomology`, `grassmannian-plucker` anchor cards (CN/EN paired), covering mathematical structures already used by `design-patterns/` but lacking anchors (sheaf cohomology, Grassmannian).
- **Test coverage expanded**: new eval tests for Scenario A (analysis), Scenario D (verification), cross-domain routing (AI×crypto 4-tuple annotation), Knowledge Gap Protocol, and Domain Router isolation (no-pollution guarantee).
- **validate.sh structural checks**: added checks for the six required knowledge-card sections, eight GPU dimensions in design patterns, Domain Router isolation, and Knowledge Gap Protocol fields.
- **critic 19-dimension layering**: core / situational / mandatory / meta dimension layering annotations to reduce Agent cognitive load.
- **inspiration.md split**: technical-inspiration part (the dragon-slaying blade story) retained; philosophical content (life-as-optimization, etc.) moved to `musings.md` to avoid clashing with the skill's rigorous technical style.

### v3.2.0 — Cryptography Track + Domain Router

**Cryptography track officially landed**: reference layer expanded from 7 to 10 books, with 3 modern cryptography classics distilled into the same activation-index format as AI-direction books (~125-155 lines each, preserving core ideas and key bridging facts).

- **3 new crypto books**:
  - `references/books/applied-cryptography.md` (Boneh & Shoup): attack games / reduction proofs / constructions / protocols
  - `references/books/foundations-of-cryptography.md` (Goldreich): computational indistinguishability / OWF-PRG-PRF equivalence chain / simulation paradigm / meta-theorems
  - `references/books/introduction-to-modern-cryptography.md` (Katz & Lindell): formal definitions / CPA-CCA-AE / construction paradigms / implementation pitfalls
- **Domain Router** (core innovation): after intent diagnosis and before lens invocation, judges problem domain (AI/Crypto/pure-math/intersection), loads domain-specific content, shared math not redundantly loaded, avoids cross-domain pollution and token waste
- **SKILL.md / SKILL.en.md**: new Domain Router section + routing rules + decision flow diagram; main workflow integrates domain tags and domain-specific routing (AI uses design-patterns + GPU gate; crypto uses reduction templates + assumption/pitfall checks)
- **math-critic upgraded to 19 dimensions**: new dim 19 "Cryptographic Security Review" (security definitions / reduction tightness / assumption dependency / composition pitfalls / anti-patterns / cross-domain transfer validity / Domain Router consistency)
- **skill-index / overview**: added Domain Router overview table and crypto book activation-family tags; overview gained Domain Router loading note
- **Token optimization**: crypto books compressed from 2084 to 404 lines (~80% reduction); Domain Router trims output by domain, avoiding full-load; output format emphasizes "after domain judgment, only expand the domain-specific subsection". Quantified estimate: pure AI problems skip the 3 crypto books entirely (saving ~400 lines/call), pure crypto problems skip all 22 AI design-patterns (saving ~2200-3300 lines/call); the crypto books' own compression saves another ~872 lines/call
- **File cleanup**: removed duplicate `SKILL.md/SKILL.en.md/original-texts.md/original-texts.en.md` mistakenly placed in repo root by the contributor (canonical versions live in `skills/math-research-activator/`); fixed SKILL relative paths in `agents/math-critic.{en,}.md` and `knowledge-base/overview.en.md`
- **AI/Cryptography isolation guarantee**: Domain Router rule 4 explicitly states "pure AI problems do not load crypto books; pure crypto problems do not load AI design patterns," preventing conceptual confusion at the loading layer

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
