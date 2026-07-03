<p align="right">
  <a href="README.md">中文</a> | <a href="README.en-US.md">English</a>
</p>

# ⚔️ Math Skill — Math Research Activator

> **Activating modern mathematics (algebraic geometry / differential geometry / Lie theory / category theory / matrix analysis / optimization) into algorithm × GPU co-design — beautiful in math, friendly to GPUs.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/math-skill.svg)](https://www.npmjs.com/package/math-skill)
[![npm downloads](https://img.shields.io/npm/dt/math-skill.svg)](https://www.npmjs.com/package/math-skill)

---

## Philosophy

The mathematical foundation of this AI revolution is **20th-century mathematics stepping onto the commercial computing stage for the first time** — category theory, algebraic topology, algebraic geometry. Most mainstream algorithms today still rest on the 1800–1900s calculus / linear algebra. Activating modern mathematics into algorithm design is the most important thing in the algorithm exploration phase.

This skill packages sixteen core mathematical ideas into callable thinking frameworks, and **steps in automatically** when the workspace contains ML / model code, CUDA / kernels, or algorithm research notes: diagnose the problem → map modern mathematical structures → route thinking weapons → GPU feasibility screening. Every deliverable must pass a **double acceptance gate**:

1. **Beautiful in math** — self-consistent, differentiable (or relaxable to differentiable), with correctness guarantees.
2. **Friendly to GPU** — passes the eight-dimensional gate in `references/gpu-friendly-math.md`.

> "The model already has enough math inside; what's missing is a single cross-domain activation. Humans pick direction; the agent searches, enumerates, and verifies."

---

## What v2.0.1 Does

- **Auto-trigger entry**: `math-research-activator` only intervenes when both environment signals (workspace contains architecture core code / CUDA kernel / research notes) AND task signals (designing new architectures / operators, analyzing theoretical properties, transferring mathematical structures) are hit. Pure engineering tasks (debugging, code review, refactoring, hyperparameter tuning) do NOT trigger.
- **Modern math activation layer**: `references/books/*.md` × 7 (algebraic geometry, differential geometry, Lie theory, abstract algebra, matrix analysis, optimization, manifolds) serve as low-token activation indices, loaded by problem type — they do not replace the full books.
- **GPU 8-D cross-cut**: all 15 thinking weapons are explicitly mapped to the formal eight dimensions of `references/gpu-friendly-math.md`: tensorization / GEMM-mappability / complexity / memory & KV-Cache / low-precision stability / parallelism & communication / sparse structure / operator fusion.
- **Single research path**: oriented toward research, algorithms, operators, and training/inference infra; the life-advice mode has been dropped.
- **Progressive disclosure**: resident layer (activator + description) → methodology layer (on demand) → book layer (on demand), keeping irrelevant context out of the prompt.

---

## Sixteen Thinking Weapons

| # | Thinking Weapon | Core Idea | Algorithm / GPU Application |
|---|----------------|-----------|----------------------------|
| 0 | 🧭 [Math Research Activator](skills/math-research-activator/SKILL.md) | Auto-trigger entry: diagnose → map → route → GPU filter, with a double acceptance gate | Intervenes only when both environment AND task signals hit; pure engineering tasks are excluded |
| 1 | 📐 [Axiomatization](skills/axiomatization/SKILL.md) | Build rigorous logic from the fewest assumptions | Review algorithm assumptions; pin down axioms and invariants for structures |
| 2 | 🧩 [Abstraction](skills/abstraction/SKILL.md) | Grasp the essence, ignore non-essential detail | Extract transferable structures; discover cross-domain commonalities |
| 3 | 🧠 [Logic Deduction](skills/logic-deduction/SKILL.md) | Rigorously derive new truths from existing truths | Formally verify algorithm correctness; loop invariants |
| 4 | 🌉 [Modeling](skills/modeling/SKILL.md) | Real problem → math problem → explain reality | Build computable models; parameterized selection |
| 5 | ⚖️ [Optimization](skills/optimization/SKILL.md) | Find the optimum under constraints | Optimizer selection; second-order GPU feasibility; duality |
| 6 | 🎲 [Probability & Statistics](skills/probability-statistics/SKILL.md) | Quantify uncertainty; extract patterns from data | Randomized algorithms, sampling, quantization, training dynamics |
| 7 | 🔄 [Transformation](skills/transformation/SKILL.md) | Complex problem → equivalent simpler problem | Conv → GEMM, spectral transforms, KV frequency-domain compression |
| 8 | ⚛️ [Symmetry & Invariance](skills/symmetry-invariance/SKILL.md) | Properties preserved under transformations | Equivariant networks (SO(3)/SE(3)), tropical semiring routing |
| 9 | 📈 [Induction & Analogy](skills/induction-analogy/SKILL.md) | From special to general, known to unknown | Cross-domain structure transfer; inductive bias design |
| 10 | 🖥️ [Algorithmic Thinking](skills/algorithmic-thinking/SKILL.md) | Reduce to finite steps; evaluate cost and feasibility | Sub-quadratic complexity, parallelism, operator fusion |
| 11 | 📡 [Information Theory](skills/information-theory/SKILL.md) | Information is the reduction of uncertainty | Compression, pruning, quantization, KV compression, routing |
| 12 | 🎯 [Game Theory](skills/game-theory/SKILL.md) | Optimal strategy depends on others' choices | Multi-agent, adversarial training, routing games |
| 13 | 🔗 [Causal Inference](skills/causal-inference/SKILL.md) | Correlation ≠ causation, but causation can be formalized | Interpretability, OOD generalization, DGP modeling |
| 14 | 🌀 [Topological Thinking](skills/topological-thinking/SKILL.md) | Properties preserved under continuous deformation | Čech cohomology regularization, sheaf attention, TDA |
| 15 | 🧮 [Discrete & Combinatorial Thinking](skills/discrete-combinatorial/SKILL.md) | Counting, enumeration, laws of finite objects | Sparse structure, routing, finite-field / semiring algorithms |

---

## Quick Start

### Installation

Just paste the following into Claude Code or any other terminal-style AI assistant:

```
Please help me install math-skill: https://github.com/the-thinker0/math-skill, and show me how to use it
```

Manual-install alternative (downloads the source; does not register the skill automatically):

```bash
git clone https://github.com/the-thinker0/math-skill.git
```

Claude Code / Codex-style platforms: copy or symlink `skills/` and `commands/` according to the platform's skills / commands directory conventions, keeping `references/` at the same repo depth. Don't copy a single `SKILL.md` in isolation — `../../references/*` won't resolve.

Cursor / other Markdown-rule platforms: treat `commands/*.md` as the manual entry points and `skills/*/SKILL.md` as the rule / skill body, and keep `references/`. If the platform has no auto-trigger mechanism, fire manually with `/ask` or the matching command.

You can also inspect the npm package first:

```bash
npm pack math-skill --dry-run
```

### Usage

**Auto-trigger**: fires only when both conditions hold — (1) the workspace contains architecture core code (attention / transformer / MoE, `*.cu` / kernel, Triton) or research notes, AND (2) the user's task involves **designing / improving** new architectures / operators, **analyzing** theoretical properties, or **transferring** mathematical structures. Pure engineering tasks (debugging, argument-passing checks, refactoring, hyperparameter tuning, loss implementation tweaks) do not trigger.

### Does it auto-trigger in normal chat?

Yes, but it depends on whether the install platform supports **skill metadata auto-routing**. In skills-aware environments like Claude Code / Codex, you don't need `/ask` on every turn after installing. As of v2.0.1 the trigger has been tightened: the skill loads only when **both environment and task signals hit** — routine code review, debugging, and refactoring will not fire it.

For example, you can simply ask:

```
I want to design a long-context attention that uses less KV-Cache — any modern math angle?
```

Or:

```
Can the memory access and fusion pattern of this Triton kernel be improved at the algorithmic-structure level?
```

Such questions trigger `math-research-activator`, which loads `references/gpu-friendly-math.md` and `references/books/*.md` on demand. `/ask` and the slash commands below are the **explicit / fallback entry**: use them only when the platform has no auto-trigger, or when you want to force a specific thinking weapon.

**Manual fallback** (when in doubt, start with `/ask`):

```
/ask <your question>                     # activator: diagnose + map + route + GPU filter
/axiomatization <your question>          # axiomatization
/abstraction <your question>             # abstraction
/logic-deduction <your question>         # logic deduction
/modeling <your question>                # modeling
/optimization <your question>            # optimization
/probability-statistics <your question>  # probability & statistics
/transformation <your question>          # transformation
/symmetry-invariance <your question>     # symmetry & invariance
/induction-analogy <your question>       # induction & analogy
/algorithmic-thinking <your question>    # algorithmic thinking
/information-theory <your question>      # information theory
/game-theory <your question>             # game theory
/causal-inference <your question>        # causal inference
/topological-thinking <your question>    # topological thinking
/discrete-combinatorial <your question>  # discrete & combinatorial thinking
```

### Language Switching

Default output is **Chinese**. For **English** output, append `in English` to a command:

```
/optimization Is K-FAC feasible on H100 with this batch size? in English
```

---

## Usage Examples

### Auto-trigger (research / algorithm / GPU)

The activator steps in only when the workspace contains a kernel or attention core implementation **and the task involves design / analysis / transfer**: problem diagnosis, transferable modern-math structure candidates, weapon routing, 8-D GPU screening. Pure engineering tasks (debugging, code review, hyperparameter tuning) do not trigger. See the **Tropical Sheaf Attention** example in `skills/math-research-activator/SKILL.md`: it is a candidate exploration template, not a pre-baked benchmark result — it has to be validated on complexity, memory, low-precision stability, and kernel fusibility before adoption.

### Manual trigger (research scenarios)

**Review an algorithm's theoretical assumptions**:
```
/axiomatization This attention variant claims permutation invariance, yet its positional encoding smuggles in an implicit total order — is it self-consistent?
```

**Check a proof / invariant**:
```
/logic-deduction Does the step from line 5 to line 6 in this convergence proof skip a premise? Does the loop invariant hold?
```

**Optimizer / second-order feasibility**:
```
/optimization I want to replace Adam with K-FAC but memory is tight — is this second-order method feasible on GPU? Is there a retrofittable low-rank approximation?
```

**Change representation via transformation**:
```
/transformation Can this custom convolution operator be rewritten as a GEMM that fully saturates Tensor Cores? Is the inverse transform numerically stable?
```

**Equivariance / symmetry**:
```
/symmetry-invariance Design an SO(3)-equivariant feature layer — can the group action be tensorized into a GEMM?
```

---

## Progressive Disclosure

| Layer | Content | Load timing |
|-------|---------|-------------|
| Resident trigger | `skills/math-research-activator/SKILL.md` + each weapon's short `description` | Loaded on auto / manual trigger |
| Methodology | `references/agentic-workflow.md` (Human-in-the-Agent-Loop), `references/gpu-friendly-math.md` (8-D gate) | Referenced by activator on demand |
| Book activation | `references/books/*.md` × 7 (modern-math structure distillations) | Loaded by problem type on demand |

**Deep dive / look-up**: the distillations are self-sufficient. When you need the full original text and have `math_book/<PDF>` locally, let the agent run `pdftotext` + grep + Read on the matching page (no pre-embedded anchors required). PDFs are never bundled into npm / git (copyright + 110MB).

---

## Directory Structure

```
math-skill/
├── package.json             # v2.0.1, files[] includes references/
├── .gitignore / .npmignore  # excludes math_book/ PDFs
├── commands/                # manual slash-command entries (15 weapons + ask)
├── skills/                  # 16 thinking weapons (15 weapons + math-research-activator)
│   ├── math-research-activator/   # auto-trigger entry
│   └── <weapon>/{SKILL.md, original-texts.md}
├── references/              # v2 addition: methodology + book activation layer
│   ├── agentic-workflow.md        # collaboration style
│   ├── gpu-friendly-math.md       # 8-D GPU acceptance gate
│   ├── inspiration.md             # inspiration
│   └── books/                     # 7 modern-math distillations
├── agents/math-critic.md    # critic agent (18 dimensions, incl. GPU + modern-math activation)
├── knowledge-base/overview.md
├── tests/{validate.sh, validate.ps1}
├── math_book/               # local PDFs (ignored by git/npm, not published)
└── README.md / LICENSE
```

---

## What Each Skill Contains

Each `skills/*/SKILL.md` (v2 single research / algorithm path):

1. **Core principle** + blockquote sub-section **Mathematical Formalization** (definitions / theorems / formulas)
2. **GPU friendliness (cross-cut check)** — how this weapon's structure maps to GPU, passing the 8-D gate
3. **When NOT to use** / **When to use** (research trigger, including algorithm / operator-design usage)
4. **Method flow** — single research path (all math retained)
5. **Common mistakes** — including a one-liner on GPU computability
6. **Operating procedure** — single output format, ending with a `[GPU Feasibility]` item
7. **Relationship to other skills** — includes a "modern math activation" row, pointing to `references/books/*`

Each weapon also ships an `original-texts.md` (math sources and classical references). Outputs can be sent to `agents/math-critic.md` (18 dimensions, including GPU feasibility + modern-math activation) for a second pass.

---

## Mathematical Knowledge System

`knowledge-base/overview.md` provides a math knowledge map: three pillars (algebra / geometry / analysis), main branches, knowledge layers (foundation → algebra → synthesis → frontier), and the mapping from thinking weapons to math branches.

---

## Inspiration

The story of Sophus Lie forging a "dragon-slaying blade" tells us this: the Lie group–Lie algebra machinery invented to solve differential equations ended up becoming the lingua franca for describing symmetry and robot state estimation — the value of a mathematical tool far outlives its original intent, which is exactly the prototype of "cross-domain activation." See [`references/inspiration.md`](references/inspiration.md).

---

## Changelog

### v2.0.1
- **Tightened auto-trigger conditions**: `math-research-activator` changed from "any environment OR conversation signal hits → trigger" to "environment AND task signals must both hit" (Gate 1 + Gate 2 as dual necessary conditions).
- **Added an exclusion gate (Gate 0)**: pure engineering tasks — code review, debugging, argument-passing checks, refactoring, hyperparameter tuning, loss implementation tweaks — are now on an explicit exclusion list with the highest priority.
- **Narrowed environment signals**: mere `model.py`, `trainer.py`, `config.json` and other routine ML engineering files no longer count as environment signals; architecture core code (attention / transformer / MoE, CUDA / Triton kernel) or research notes is required.
- **Updated `description` field**: explicitly lists "does not trigger on" scenarios, reducing skill metadata mis-matches on AI platforms.

### v2.0.0
- Initial v2 release: 16 thinking weapons, modern-math activation layer, 8-D GPU cross-cut, progressive disclosure.

### v1.0.0
- Initial release: fifteen thinking weapons (axiomatization / abstraction / logic deduction / modeling / optimization / probability & statistics / transformation / symmetry & invariance / induction & analogy / algorithmic thinking / information theory / game theory / causal inference / topology / discrete & combinatorial) + dual research-and-life paths.
- Fifteen `skills/*/SKILL.md` files (core principle, when-not-to-use, method flow, common mistakes, operating procedure) + matching `original-texts.md` (math sources and classical references).
- Fifteen manual slash-command entries (`commands/*.md`).
- `knowledge-base/overview.md` (three pillars / main branches / knowledge layers / weapon mapping).
- `agents/math-critic.md` critic agent.
- Validation scripts `tests/{validate.sh, validate.ps1}`.
- Published to npm (`math-skill`), MIT license.

---

## License

MIT License. See `LICENSE`.

---

## Contributing

Issues and Pull Requests are welcome — let's learn and build together!

---

## Star History

<a href="https://www.star-history.com/?repos=the-thinker0%2Fmath-skill&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=the-thinker0/math-skill&type=date&legend=top-left" />
 </picture>
</a>
