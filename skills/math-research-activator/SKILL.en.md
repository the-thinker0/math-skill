---
name: math-research-activator
description: |
  Auto-trigger (requires BOTH environment AND task signals): only when **designing/improving** new model architectures/operators/attention mechanisms, **analyzing** algorithm theoretical properties (complexity, convergence, expressivity), or **transferring** modern math structures (algebraic geometry, differential geometry, Lie theory, abstract algebra, matrix analysis, optimization) into algorithm/GPU co-design. Does NOT trigger for: code review, debugging, parameter tracing, refactoring, hyperparameter tuning, or loss implementation edits. Also the manual /ask entry (weapon selector).
---

# 🧭 Math Research Activator

> "The model already holds enough mathematics inside; what's missing is a cross-domain activation. The human picks the direction; the agent searches, enumerates, verifies."

## Core Principle

**No lengthy math tutorials.** Once triggered, immediately enter the three-step pipeline: "Diagnose → Map → GPU Screen," activating modern mathematics into algorithm/hardware design, and passing every output through the **dual acceptance gate**:

1. **Mathematically correct (beautiful in math)** — self-consistent, differentiable (or relaxable to differentiable), with correctness guarantees.
2. **GPU-feasible (friendly to GPU)** — see `../../references/gpu-friendly-math.md` eight dimensions.

> This is the **sole automatic entry point** of the skill pack. It loads the methodology layer (`../../references/agentic-workflow.md`, `../../references/gpu-friendly-math.md`), the book activation layer (`../../references/books/*.md`), and the 16 thinking weapons (sibling directories `../*/SKILL.md`) on demand, keeping only the minimal trigger and diagnostic logic resident at all times — progressive disclosure to save tokens.

## When to Auto-Engage

**Both the "environment signal" AND the "task signal" must be satisfied simultaneously (neither alone is sufficient):**

### Gate 0 · Exclusion Gate (evaluated first; if hit, do not engage)

The following tasks must **never** trigger this activator, regardless of what code is in the workspace:
- Code review / debugging / parameter-passing chain verification / interface consistency checks
- Refactoring, renaming, removing redundant code, dead code cleanup
- Build / packaging / CI / deployment / environment configuration
- Pure factual queries ("what does this function do," "who receives this parameter")
- General software engineering (file I/O, networking, data loading, logging)
- Training script hyperparameter tuning, hyperparameter search, experiment comparison
- Adding / modifying loss implementation details (as opposed to designing the mathematical structure of a new loss)

**Rule of thumb: if the task can be accomplished by "reading code → tracing call chains → reporting results," no mathematical weapon is needed.**

### Gate 1 · Environment Signal (necessary condition, not sufficient)

The workspace contains at least one of the following:
- Core model architecture code (not training scripts / data pipelines): attention/transformer/MoE implementations, `*.cu`/`*.cuh`/kernels, Triton/CUDA operators.
- Algorithm research notes / paper review documents.
- Design drafts or mathematical derivations for new architectures / new operators.

> The mere presence of `model.py`, `trainer.py`, `config.json`, or similar routine ML engineering files **does not constitute an environment signal**.

### Gate 2 · Task Signal (necessary condition, not sufficient)

The user's current task explicitly involves at least one of the following:
- **Designing or improving** a new model architecture / operator / attention mechanism (not fixing an existing implementation).
- **Selecting or justifying** the applicability of a mathematical structure (e.g., "should we use manifold constraints," "does this structure have equivariance").
- **Analyzing** theoretical properties of an algorithm (complexity lower bounds, convergence, expressivity, information bottleneck).
- **Transferring** a mathematical structure from some field into algorithm/GPU design.

> If the task signal is merely "code doesn't run," "parameter wasn't passed," "loss didn't take effect," or similar engineering issues, the activator does **not trigger** even if the environment signal is hit.

**When NOT to engage:**
- Gate 0 is hit (exclusion gate).
- Either Gate 1 or Gate 2 is not satisfied.
- The problem is not in a domain where mathematics can help.

## The Activation Loop

> See `../../references/agentic-workflow.md` for detailed working methodology (Human-in-the-Agent-Loop).

1. **Diagnose**: What is the algorithmic structure or bottleneck? (complexity? memory/KV? numerics? parallelism? expressivity?)
2. **Map**: Use the "Modern Math Toolbox" (below) to scan for transferable structures, **enumerating multiple candidates** (leverage the large context window — don't just give one).
3. **Route**: Select 1–3 thinking weapons for deeper analysis (decision tree below).
4. **GPU Screen**: Pass each candidate through the eight dimensions of `../../references/gpu-friendly-math.md`, rating "friendly / retrofittable / unfriendly" + adaptation recommendations.
5. **Dual Acceptance Gate**: Retain only candidates that are **mathematically correct AND (eight-dimension friendly or retrofittable)**.
6. **Track**: For complex explorations, use a markdown testplan table (template in agentic-workflow.md) to iterate toward convergence.

The eight-dimension terminology must remain consistent: **Tensorization / GEMM-Mappability / Complexity / Memory & KV-Cache / Low-Precision Stability / Parallelism & Communication / Sparsity Structure / Operator Fusion**. Do not substitute vague judgments covering only a subset of dimensions for the full eight-dimension gate.

## Weapon Routing

Match by the core characteristic of the problem (select up to 3, label primary/secondary):

1. **Multi-agent interaction** (my optimum depends on others) → `/game-theory` (primary); resource allocation + `/optimization`; information asymmetry + `/information-theory`
2. **Uncertainty / randomness** → `/probability-statistics` (primary); need causal rather than correlational + `/causal-inference`
3. **Optimization under constraints** → `/optimization` (primary); need to model first + `/modeling` (prerequisite)
4. **Current form is intractable, need change of perspective / simplification** → `/transformation` (primary)
5. **Need to extract essential structure** → `/abstraction` (primary); verify assumptions + `/axiomatization`; simplify + `/symmetry-invariance`
6. **Need rigorous reasoning and verification** → `/logic-deduction` (primary); verify premises + `/axiomatization`
7. **Finding patterns from data / experience** → `/induction-analogy` (primary); cross-domain transfer + `/abstraction`
8. **Building predictive / explanatory models** → `/modeling` (primary); optimization + `/optimization`; uncertainty + `/probability-statistics`
9. **Invariance / conservation / equivariance under change** → `/symmetry-invariance` (primary); connected structure + `/topological-thinking`
10. **Reducing to executable steps / evaluating feasibility and complexity** → `/algorithmic-thinking` (primary)
11. **Compression / encoding / information bottleneck / KV-Cache compression / quantization** → `/information-theory` (primary); representation transforms + `/transformation`; routing information gain + `/game-theory`
12. **Counting / enumeration / structure of finite objects** → `/discrete-combinatorial` (primary)

> **Modern math priority hint**: When the problem is "designing/improving an operator or structure," **always open the modern math toolbox first** while routing weapons — many breakthroughs come from transferring structures from algebraic geometry / differential geometry / Lie theory, rather than circling within classical tools alone.

## Modern-Math Toolbox (Layer 3 · Loaded on Demand)

Load the corresponding book activation file (`../../references/books/`) by problem type:

| Trigger Signal | Load | Typical Activation |
|---------|------|---------|
| Operator = matrix multiply / spectrum / low-rank / numerical stability | `matrix-analysis.md` | GEMM formulation, low-rank compression, spectral normalization, preconditioning |
| Training / convergence / optimizer / constraints | `optimization-ml.md` | Feasibility of adaptive / second-order optimization, dual solving |
| Symmetry / equivariance / semiring / permutation invariance | `abstract-algebra.md` | Group-equivariant layers, tropical semiring routing, finite-field encoding |
| Manifold constraints / latent-space geometry / differentiable structure | `smooth-manifolds.md` | Manifold optimization, Stiefel/orthogonal constraints, geodesic interpolation |
| Metric / curvature / natural gradient / gauge / fiber bundle | `differential-geometry.md` | Natural gradient / K-FAC, information geometry, gauge equivariance |
| Pose / SO(3) / SE(3) / state estimation / equivariance | `micro-lie-theory.md` | Lie group optimization, SE(3) equivariance, manifold loss |
| Attention / sparsity / global consistency / KV compression | `algebraic-geometry-rising-sea.md` | Sheaf attention, Čech cohomology regularization, Plücker KV, tropical gating |

## Deep-Dive Protocol

- **Light**: Read `../../references/books/<book>.md` (distilled notes, shipped with the release, self-contained).
- **Deep (full fidelity to original text required)**: If a local `math_book/<corresponding PDF>` exists, **let the agent search automatically** — `pdftotext "math_book/<file>.pdf" -` → grep keywords → Read the matching page. **No reliance on pre-embedded anchors.**
- No PDF available (e.g., npm-installed on a different machine): Stay at the distilled-notes layer, which remains self-contained and usable.

## Worked Example: Tropical Sheaf Attention

A research candidate template (see `../../references/gpu-friendly-math.md` for details): tropical gating (semiring piecewise-linear replacing Top-K) + cellular sheaf diffusion (low-rank restriction maps per edge = small GEMMs) + Čech cohomology regularization (H¹ as a structural consistency signal) + Plücker KV compression. Treat this as an exploration template for "math beautiful x GPU friendly": verify complexity, memory, low-precision stability, and kernel fusibility dimension by dimension before claiming passage through the eight-dimension gate.

## Operating Procedure

Once triggered, the output must contain:
1. **[Diagnosis]**: One sentence identifying the algorithmic structure/bottleneck (interaction / uncertainty / constraints / structure / dynamics / complexity / memory / numerics / parallelism).
2. **[Mapping]**: Enumerate transferable modern math structure candidates (>=2, annotated with source book).
3. **[Weapon Routing]**: 1–3 thinking weapons, labeled primary/secondary + trigger commands.
4. **[GPU Screen]**: Each candidate evaluated against the eight dimensions, rated "friendly / retrofittable / unfriendly" + adaptation recommendations.
5. **[Conclusion]**: Retain only candidates passing the dual acceptance gate; provide a testplan table when necessary.

**A conclusion must always be provided — never output analysis alone without convergence.**

## Relations

- This entry point routes all 16 thinking weapons and loads the methodology layer and book activation layer on demand.
- The manual entry `/ask` is equivalent to invoking this activator (weapon selector mode).
- Review of outputs can be delegated to `agents/math-critic.md` (including the GPU feasibility dimension) for a second pass.
