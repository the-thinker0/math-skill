<div align="center">

# 📐 Math Skill

### A Mathematical Research Operating System for AI and Cryptography Innovation

<a href="README.md">中文</a> | <a href="README.en-US.md">English</a>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

</div>

> Math Skill does not store mathematics. It activates, routes, and translates mathematics for AI and cryptography research.

A math reasoning skill for **Claude Code / Codex / Cursor and more** — automatically activates the right mathematical lenses, knowledge anchors, and design prototypes for AI architecture design, math-to-AI transfer, and cryptographic proof review, delivering conditional, falsifiable conclusions with counterexamples.

If this skill inspires you, please consider leaving a Star⭐. Your support keeps the project evolving.

---

## How is this different from just asking the AI?

### [AI] Case 1: Analysis — "KAN's mathematical foundations and risks"

**User**: "KAN uses learnable B-splines instead of ReLU, claiming better accuracy and interpretability than MLPs. I want to analyze its mathematical foundations and potential risks."

**Without Skill**:
> KAN is based on the Kolmogorov-Arnold representation theorem, using B-splines as learnable activation functions on edges. Advantages include parameter efficiency and interpretable activations. Risks are mainly that spline computation is slower than ReLU and fine grids may overfit. Suggest running ablation experiments on specific tasks.

**With Skill** (activated: Perturbation + Spectral lenses → `low-rank-approximation` anchor):

> **Conclusion**: The KA theorem guarantees **existence** of a representation, not **learnability**. Two overlooked mathematical quantities determine KAN's actual performance: the effective rank of the spline basis and the Fisher curvature of the parameter space.
>
> - **Existence ≠ Learnability**: The KA theorem guarantees ∑φ_q(∑ψ_{q,p}(x_p)) can represent any continuous function, but—like the universal approximation theorem for MLPs—it does not guarantee that gradient descent finds the representation
> - **Spline basis effective rank**: B-spline basis functions' support overlap causes effective rank to lag far behind parameter growth; if grids refine but bases remain highly correlated, actual expressive capacity stalls—monitor singular value decay curves, not just parameter counts
> - **Fisher curvature**: Spline's second-order differentiability makes the Hessian more regular, but the Fisher information matrix's condition number may be far larger than in ReLU networks; natural gradient has theoretical advantages but higher estimation cost
> - **Falsifiable experiment**: Compare KAN vs. same-parameter-budget MLP on spline basis effective rank decay; if rank growth stalls while parameters keep growing, the "interpretability" advantage is offset by redundancy

### [Crypto] Case 2: Verification — "Is this PRF watermarking reduction tight?"

**User**: "I use a PRF to watermark model weights. The reduction proof says 'removing watermark ≥ breaking PRF'. Is this reduction tight?"

**Without Skill**:
> If removing the watermark is equivalent to distinguishing PRF output from truly random, then the reduction is tight when the PRF security assumption holds. Suggest choosing an AES-based PRF for stronger assumptions.

**With Skill** (activated: `reduction-proof-template` + `prf-prg-owf` anchors):

> **Conclusion**: The reduction direction is correct, but tightness depends on query count Q and simulation quality—cannot claim "tight" just from "PRF assumption holds."
>
> - **Reduction loss**: Adv^scheme ≤ Q · Adv^PRF + δ, where Q is the adversary's query count. If Q grows linearly with model parameters, concrete security degrades significantly—must report Q's magnitude, not just write "polynomial loss"
> - **Simulation quality**: The reduction must construct simulator B to answer adversary oracle queries; if B's simulation distribution has non-negligible statistical distance from the real game, the entire reduction fails
> - **Assumption hierarchy**: AES-as-PRF is a widely adopted empirical assumption, not a theorem unconditionally proven from the spec—standard model, ROM, and concrete security are three levels that must not be conflated
> - **Multi-user degradation**: After deployment, multiple users query independently; birthday bound and hybrid steps amplify advantage loss
> - **Falsifiable check**: Write out B's complete simulation (parameter generation, query answering, challenge embedding, abort handling), plug in concrete parameters to estimate Q and δ

---

## Quick Start

### Installation

**npx** (recommended):

```bash
npx -y math-skill@latest install --all
```

**Or give the project URL to your AI and let it install itself**:

```
Please help me install math-skill: https://github.com/the-thinker0/math-skill, and show me how to use it
```

> Also supports: `install --codex` / `--claude` (individual), `update --all` (upgrade), `doctor --all` (check for duplicates)
> The installer automatically excludes the nested `skills/` directory, ensuring only one entry per platform.

### Usage

**Auto-trigger**: The system auto-diagnoses user intent and routes to the appropriate layer:

| Scenario | Signal | Path |
|----------|--------|------|
| Analysis | "Is this design sound?" | Lenses → compact review |
| Design | "Design a new attention" | Lenses → anchors → design translation → compact review |
| Knowledge query | "How does tangent space relate to gradient optimization?" | Activate anchor |
| Verification | "Is this reduction tight enough?" | Anchors → conditions/boundaries |
| Pure engineering | debug, refactoring, tuning | **Not triggered** |

**Manual trigger**:

```
/ask <your question>     # Smart diagnosis: auto-detect scenario and route
```

### Language

Auto-detects Chinese/English: Chinese messages get Chinese output, English messages get English output. Technical terms, code, and formulas do not determine language.

---

## Three-Layer Orthogonal Architecture

```
Problem → Lenses (what perspective?) → Anchors (which math structures?) → Design Translation (what module?) → Review (does it hold?)
```

| Layer | Role | Directory | Files |
|-------|------|-----------|-------|
| **Thinking Lenses** | Diagnose problem structure, recommend math perspectives | `lenses/*.md` | 15 |
| **Activation Anchors** | 33 shared-math anchors + 4 cryptography anchors; trigger Knowledge Gap Protocol when insufficient | `knowledge-base/*/*.md` | 37 |
| **Design Translation** | Bridge math to AI modules/losses/operators | `design-patterns/*/*.md` | 22 |

Supporting layers:
- `references/books/*.md`: 10 book distillations (7 AI-direction + 3 cryptography-direction) for deep context
- `references/gpu-friendly-math.en.md`: on-demand GPU checks with N/A for irrelevant dimensions
- `agents/math-critic.en.md`: 19-dimension deep critic loaded only for comprehensive or paper-grade review

### Domain Router

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

## Inspiration

The Lie group–Lie algebra machinery invented to solve differential equations ultimately became the universal language for describing symmetry and robot state estimation—the value of mathematical tools far exceeds their original intent. This is the prototype of "cross-domain activation." See [`references/inspiration.en.md`](references/inspiration.en.md).

---

## Routing Example

**User**: "Design a new KV Cache compression method that preserves long-range dependencies without just doing top-k"

```
Step 1  Diagnosis: Scenario B (Mechanism Design)
  Problem type: sequence memory compression + information preservation + long-range structure
  Core tension: compress token count vs. preserve long-range dependencies

Step 2  Lens Selection (default ≤2):
  1. Spectral (preserve dominant subspace)
  2. Probabilistic/Information (preserve mutual-information-sensitive states)
  (Add Topological only when the user stresses connectivity/bridge structure; not in default budget)

Step 3  Activation Anchors:
  → low-rank-approximation (Matrix Analysis anchor)
  → information-bottleneck (Probability & Information anchor)
  → leverage-score-selection or low-rank-kv-cache (0–2 compression design patterns)
  If existing anchors are insufficient, enter Knowledge Gap Protocol to generate a temporary knowledge card.

Step 4  Design Translation:
  Primary: Spectral KV Compression (low-rank + leverage score)
  Alternative (key difference only): Information-Preserving Cache (relies on future query estimation)

Step 5  Compact Review (ordinary tasks do not load the full critic):
  Primary is most GPU-friendly; alternative needs future query estimation, higher uncertainty
  Conclusion: prioritize primary; add a lightweight gate only if query-sensitive retention is needed
```

---

## Directory Structure

```
math-skill/
├── skills/
│   └── math-research-activator/    # Orchestrator: intent diagnosis + routing
├── lenses/                         # 15 thinking lenses (reasoning methodology)
├── knowledge-base/                 # Activation anchors by math domain, not a closed encyclopedia (37 cards total)
│   ├── matrix-analysis/            # Matrix analysis (5 cards)
│   ├── optimization/               # Optimization (5 cards)
│   ├── differential-geometry/      # Differential geometry (6 cards)
│   ├── lie-theory/                 # Lie theory (5 cards)
│   ├── topology/                   # Topology (3 cards)
│   ├── probability/                # Probability & information (5 cards)
│   ├── information-geometry/       # Information geometry (2 cards)
│   ├── algebraic-geometry/         # Algebraic geometry (2 cards)
│   └── cryptography/               # Cryptography (4 cards, domain-exclusive)
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
│   ├── inspiration.en.md           # Inspiration
│   ├── musings.en.md               # Musings (philosophical reflections, not auto-loaded)
│   └── skill-index.en.md           # Index (on-demand directory, not loaded by default)
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

### Cryptography Direction (3 books)

| # | Title | Author(s) | Publisher / Edition | Year | ISBN | Distillation |
|---|-------|-----------|-------------------|------|------|-------------|
| 8 | *A Graduate Course in Applied Cryptography* | Dan Boneh & Victor Shoup | v0.4 online | 2017 | — | `applied-cryptography.en.md` |
| 9 | *Foundations of Cryptography, Volume 1: Basic Tools* | Oded Goldreich | Cambridge University Press | 2001 | 978-0-521-79172-4 | `foundations-of-cryptography.en.md` |
| 10 | *Introduction to Modern Cryptography* | Jonathan Katz & Yehuda Lindell | CRC Press, 2nd ed. | 2015 | 978-1-4665-7026-9 | `introduction-to-modern-cryptography.en.md` |

Distillation files ship with the npm package. For full-fidelity lookups, place PDFs in the `math_book/` folder.

---

## Changelog

### v3.3.4 — Hotfix for v3.3.3

- **Installer hotfix**: fixed `update --all` failing with `ENOTDIR` on Claude when a stale non-directory (e.g. a leftover from a broken install) occupied the skill target; the installer now relocates the artifact safely before swapping, so upgrades no longer abort

### v3.3.3 — Knowledge Fixes · Lean Loading

- **Knowledge content corrections (bilingual)**: fixed two invalid ISBNs in book distillations & README (Goldreich, Katz & Lindell — check-digit verified); fixed the topological lens's false claims ("same χ ⇒ same surface", "same π₁ ⇒ same homotopy type") and the orphan `tda` route; fixed the CN mistranslation of monodromy as "单值化定理" in local-to-global; corrected categorical-lens routing; restored the missing β in the VIB objective
- **Lean-loading protocol (saves tokens, no output template)**: read anchors by section (skip the tail by default), skip a pattern's math that duplicates an already-loaded anchor, prefer the smallest-sufficient path; output structure follows the task — no fixed format imposed
- **Engineering fixes**: validate.ps1 version + parity aligned with validate.sh; the npx installer now rejects incomplete installs (content-integrity check); removed repo-only `skills/` dead weight (and duplicate `name` declaration) from the published package
- **Validation**: `validate.sh` 529 → 537 all green; new content and lean-loading guards prevent regression

### v3.3.2 — Productization & npx Installer

- **npx CLI installer**: Added `bin/math-skill.cjs` supporting `npx -y math-skill@latest install/update/doctor/uninstall`; atomic version replacement, excludes nested `skills/` to prevent double entries, `doctor` checks for duplicates
- **README product-first restructure**: Centered title + subtitle; demos and Quick Start on first screen (was buried at L128); Star plea moved to top; npm upgraded to npx; platforms tagged with "and more" (not framework-limited)
- **Case updates**: KAN analysis (AI) + PRF watermark reduction verification (Crypto) replace old FFT/orthogonality-loss cases; "without Skill" answers made realistic; case headers tagged `[AI]`/`[Crypto]`
- **Changelog compression**: v3.3.0–v3.1.1 compressed from 7-13 points to 5 each (~62% reduction); restored Sophus Lie inspiration section and 4-step flow diagram

### v3.3.1 — Documentation-Discipline Patch

- **README directory tree completed**: added `algebraic-geometry/`, `cryptography/`, `musings.md`, `skill-index.md`; card total aligned to 37
- **README workflow example corrected**: lenses default ≤2, design patterns separated from anchors, Step 5 changed to compact review — consistent with `SKILL.md` budgets
- **Changelog slimmed**: v1/v2 compressed to one-line summaries; removed stale "37 .en.md" / "16 thinking weapons" numbers
- **Entry phrasing & counting caliber unified**: three entries use consistent "when to load .en" wording; repo-wide count standardized as 33 shared + 4 crypto = 37
- **Metadata & hygiene**: `package.json` description/keywords trimmed; `CLAUDE.md` dir tree and Node.js note fixed; `validate.sh` gained 20 documentation-discipline checks; `original-texts` gained purpose note and v2 terminology fix

### v3.3.0 — Routing Convergence, Bilingual Completion & Technical Corrections

- **Canonical entry & progressive loading**: Root `SKILL.md`/`SKILL.en.md` become self-contained normative entries; five scenarios (A/B/C/D/E) get minimal load paths (default 1-2 lenses, 1-3 anchors, 0-2 prototypes); concept queries and pure-crypto tasks no longer load full critic/books/GPU checklist by default
- **Domain Router rewrite**: Switched from keyword voting to "target object + requested guarantee" domain judgment; isolated terms like `hashing`/`attack`/`security` no longer trigger crypto false positives; pure-AI, pure-crypto, shared-math, and AI×crypto paths explicitly isolated
- **Crypto decontamination & math corrections**: Four crypto anchors reorganized around security definitions/attack games/reduction loss, no forced AI translations or GPU gates; corrected projection pseudoinverse conditions, KL directionality, low-rank gradient claims, orthogonality-loss formula; all guarantees/equivalence/optimality claims now state conditions
- **Bilingual & GPU review convergence**: Crypto books completed in Chinese-English pairs; GPU review switched to relevance-driven (assess only decision-relevant dimensions, mark others N/A); ordinary tasks use compact checks, 19-dim critic reserved for paper-grade review
- **Index, eval & validation sync**: Updated skill-index/overview/agentic-workflow and A/B/C/D/E eval scenarios; Bash/PowerShell validation covers frontmatter, 37 anchor pairs, cross-references, Domain Router isolation

### v3.2.1 — Design Philosophy Refinement & Reliability Enhancement

- **Design philosophy clarified**: Skill declared as a thinking activator, not an encyclopedia; `knowledge-base/` returns to mathematical structures (not fixed AI architectures); `design-patterns/` positioned as translation-paradigm demos, not template library
- **Crypto & algebraic-geometry anchors backfilled**: Added `knowledge-base/cryptography/` (4 cards) and `knowledge-base/algebraic-geometry/` (2 cards), giving Domain Router substantive crypto anchors
- **Testing & validation expanded**: Added scenario A/D eval, cross-domain routing, Knowledge Gap Protocol, Domain Router isolation tests; validate.sh checks card six-section structure and GPU eight-dimension coverage
- **Critic 19-dim layering**: Core/contextual/mandatory/meta four-tier labeling, reducing agent cognitive burden
- **inspiration.md split**: Technical inspiration retained; philosophical content moved to `musings.md`

### v3.2.0 — Cryptography Direction + Domain Router

- **3 crypto books added**: Boneh & Shoup, Goldreich, Katz & Lindell distillations (bilingual pairs), compressed to ~125-155 lines/book activation-index format
- **Domain Router routing layer**: After intent diagnosis, before lens invocation, judges problem domain (AI/crypto/pure-math/intersection), loads domain-specific content, shared math not redundantly loaded
- **math-critic upgraded to 19 dims**: New crypto security review dimension (security definitions/reduction tightness/assumption dependency/composition pitfalls/anti-patterns/cross-domain transfer)
- **Token optimization**: Crypto books compressed from 2084 to 404 lines (~80%); pure-AI problems skip crypto books (saving ~400 lines/call), pure-crypto problems skip AI design-patterns (saving ~2200 lines/call)
- **AI & cryptography isolation**: Domain Router explicitly states "pure-AI problems do not load crypto books; pure-crypto problems do not load AI design patterns"

### v3.1.1 — Terminology Consistency Cleanup

- **"Activation anchors" caliber unified**: skill-index, README, SKILL.md "math knowledge/knowledge cards" uniformly changed to "activation anchors"
- **README corrections**: Workflow example step 3 from "knowledge query" to "activation anchors"; `leverage-score-selection` label corrected
- **SKILL.md architecture table update**: Three-layer architecture table and intent diagnosis table terminology aligned
- **English README book links**: Distillation files changed from `.md` to `.en.md`
- **validate keywords**: Changed from "math knowledge" to "activation anchors"

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
- **Knowledge Base** (31 cards, expanded to 37 in v3.2): concrete math tools organized by domain, with definitions/formulas/AI design translation/GPU feasibility
- **Design Translation Layer** (new): the bridge from math to AI modules, organized by AI component (attention/loss/routing/representation/compression)
- **Activator rewrite**: from environment-signal matching to intent diagnosis (5 scenarios: analysis/design/query/verification/engineering)
- **Knowledge activation protocol**: fixed output format for knowledge cards (minimal definition → formula → applicable problems → AI translation → engineering feasibility → risks)

### v2.1.0 — Full Bilingual Support
- Full bilingual support, auto language routing, same commands for both languages, no double token cost

### v2.0.0–v2.0.1
- 16 thinking weapons (v2 naming, replaced by 15 lenses in v3), modern math activation layer, GPU 8-D cross-cut; tightened auto-trigger conditions and exclusion gate

### v1.0.0
- Initial release: early "thinking-weapon arsenal + dual research/life paths" form (restructured into three-layer architecture in v3.0.0)

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
