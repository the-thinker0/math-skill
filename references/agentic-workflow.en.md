# Agentic Research Workflow / Human-in-the-Agent-Loop

> Distilled from frontline auto-research practice (Infra / Algorithms / Chip Co-design). It defines the **collaborative mindset** this skill expects: what humans do, what the agent does, and what loop grounds "activating mathematical capability" in practice.
> The activator references this file at runtime. This file defines the collaboration style the skill expects.

## Creed

1. **The mathematical foundation of this AI revolution is the first time 20th-century mathematics has stepped onto the commercial computing stage** — category theory, algebraic topology, algebraic geometry. The mathematical foundations of most mainstream algorithms still largely rest on the calculus and linear algebra of 1800–1900. Activating modern mathematics in algorithm design is the most important task during the algorithm exploration phase.
2. **Humility**: The breadth of knowledge from the pre-training stage already surpasses any individual. **More knowledge is learned from the model than taught to it.** Letting go of the bias toward "teaching the model" usually yields better results.
3. **Mathematical beauty ≠ computability**: Many mathematically elegant constructs break down in the face of GPU parallelism and low-precision arithmetic errors. Every deliverable must pass the acceptance gate defined in `gpu-friendly-math.en.md`.

## Division of Labor

**Humans are responsible for (what humans excel at and find most valuable):**
- **Cross-domain activation**: Transferring the structure of one domain to another. The model already contains sufficient internal knowledge, but "without someone to activate it, that knowledge is unlikely to be developed." Example: applying algebraic geometry perspectives to study model architectures; historically, the correspondence between fiber bundles and gauge fields — the structure was already there, awaiting only a single cross-domain activation.
- **Avoid hard-coding subjective bias**: The more rules you add, the more you constrain the model's ability to explore alternatives. To get good results, **do not impose human subjective preferences by force.**
- **Expanding cognitive context with the model**: The human brain can manually compare at most 2–3 variables simultaneously, while the model's long context window can weigh many at once. Leveraging the model to expand an individual's cognitive context is a core principle of agentic development.
- **Choosing directions and setting acceptance gates**: Deciding which path to explore and what standards to apply for acceptance.

**The Agent is responsible for (what the model excels at):**
- **Large-context search and enumeration**: Enumerating large numbers of candidate structures, comparing multi-parameter combinations in parallel.
- **Verification**: Checking mathematical correctness + GPU feasibility.
- **Building and executing test plans**: Recording research tasks as trackable markdown tables, autonomously adding new cases, fixing compilation errors, and retrying on failure.

## The Activation Loop

> The activator's `Diagnosis → Mapping → GPU Filtering` main pipeline is a distillation of this loop.

1. **Diagnosis**: What is the algorithmic structure / bottleneck of the problem? (Do not start by piling on math tutorials.)
2. **Cross-domain activation**: Scan `books/*.md` for transferable modern mathematical structures, **enumerate multiple candidates** (leveraging the model's large-context advantage).
3. **Dual acceptance gate**: Each candidate passes two gates — (1) Mathematically correct (differentiable, self-consistent, with correctness guarantees); (2) GPU-feasible (the eight dimensions of `gpu-friendly-math.en.md`).
4. **Iterative tracking**: Record candidates, scores, and status in a markdown test plan, converging step by step.

## Markdown Test Plan Template / Tracking Template

Record research tasks in a table that the Agent can continuously update:

```markdown
| Candidate Structure | Math Correctness | GPU 8-Dim | Complexity | Status | Notes / Next Steps |
|--------------------|-----------------|-----------|------------|--------|-------------------|
| Tropical gating replacing TopK | [v] Differentiable relaxation | 1[v]2[x]3[v]… | Sub-quadratic (per-token) | Verifying | Compare with SWA baseline |
| …                  |                 |           |            | Todo   |                   |
```

The Agent is responsible for tracking execution and updating this table; the human is responsible for reading the table and adjusting direction.

## Operating Principles

- **Diagnose first, then map, then filter** — do not produce lengthy math tutorials; go straight to structural mapping and GPU feasibility.
- **Preserve exploratory freedom**: Add fewer hard rules; leave room for the model to explore.
- **Humans should be "lazy"**: Delegate all tedious work to the Agent; humans focus only on cross-domain activation and directional judgment.
- **Progressive disclosure**: The methodology layer, GPU checklist, and book layer are all loaded on demand; only the minimal trigger and diagnostic logic stays resident, to save tokens.
- **Do not create a pile of skills / rules right away**: The model already has many capabilities; use them fully first, then add structure.
