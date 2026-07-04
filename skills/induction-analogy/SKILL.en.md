---
name: induction-analogy
description: |
  Trigger when finding patterns from data/experience, specific→general, known→unknown, mathematical induction proofs (weak/strong/structural/transfinite), cross-domain analogical transfer of structures, or borrowing structures from other fields for algorithm/operator design.
---

# 📈 Induction & Analogy

> "From the specific to the general, from the known to the unknown — induction discovers patterns, analogy transfers experience, but neither equals proof."
>
> — Pólya, *Mathematics and Plausible Reasoning*; Lakatos, *Proofs and Refutations*

## Core Principle

**Induction discovers general patterns from limited instances — the engine of new knowledge; analogy transfers understanding across domains. Neither is rigorous proof, but both are fundamental to discovering theorems, proposing hypotheses, and generating innovation. Rigor is a tool of verification, not of discovery — Pólya.**

The distinction between induction and analogy: **Induction** moves from N specific cases → a general rule (vertical deepening); **analogy** moves from the structure of domain A → the structure of domain B (lateral transfer); both produce hypotheses rather than theorems and require subsequent verification.

> **Mathematical Formalization**
>
> The critical distinction between inductive reasoning and inductive proof:
> - Inductive reasoning: empirical, proposing hypotheses from observations
> - Inductive proof: logical, mathematical induction is a rigorous deductive proof scheme
> - Key: inductive reasoning generates conjectures; inductive proof verifies them — the two must not be conflated
>
> Variants of inductive proof and their applicable scenarios:
> - **Weak Induction**: Prove P(1) holds + prove ∀k(P(k)→P(k+1)) → conclude ∀n P(n); applicable when P(k+1) depends only on P(k)
> - **Strong / Complete Induction**: Assume P(1), P(2), …, P(k) all hold, prove P(k+1); applicable when P(k+1) depends on multiple predecessors
> - **Structural Induction**: Prove P(base) holds + P(composite) follows from P(components); applicable to recursively defined structures (trees, lists, expressions)
> - **Transfinite Induction**: For a well-ordered set (W, <), prove ∀α∈W(∀β<α P(β) → P(α)) → ∀α∈W P(α); applicable to well-ordered sets indexed beyond the natural numbers
>
> Formal description of Lakatos's methodology:
> - **Monster-barring**: Treating a counterexample as an object outside the intended scope of the hypothesis and explicitly excluding it — the simplest form of revision, but one must guard against over-exclusion that renders the hypothesis vacuous
> - **Lemma-incorporation**: Incorporating the hidden condition exposed by the counterexample into the hypothesis as a new lemma — makes the hypothesis more precise
> - **Proof-strategy revision**: The counterexample reveals a fundamental flaw in the original proof approach, requiring a different proof framework — the most profound form of revision
>
> Structural similarity measure for analogies:
> - Structural similarity = (number of successfully mapped relations + number of successfully mapped components) / (total source relations + total source components)
> - High validity (homomorphism): most structures have correspondents, key relations are preserved
> - Medium validity (partial homomorphism): some structures and relations are preserved, some are distorted
> - Low validity (surface similarity): only appearance or terminology is similar; deep structures differ

## GPU-Friendliness (Cross-Cutting Check)

Induction and analogy are inherently **meta-heuristic** — they generate conjectures and transfer structures, but do not directly prescribe computations. What must actually pass the GPU eight-dimension gate is their **product**: the structure being transferred into algorithm/operator design. If the analogically transferred structure is intractable, it must be adapted.

- **Friendly**: The transferred structure can be expressed as dense GEMM chains or low-rank linear maps — e.g., structural induction ideas mapped to fusable implementations of recursive operators, algebraic homomorphism analogies mapped to low-rank GEMM (dimensions 1/2/4).
- **Adaptable**: Transferred global/serial structures (naive cohomology computations, unstructured graph traversals, naive RNN-style recurrence) → adapt via block sparsification, low-rank projection, or tropical semiring relaxation (see adaptation techniques in `../../references/gpu-friendly-math.md`).
- **Anti-pattern**: Adopting a structure solely because it is isomorphic/homomorphic and elegant, while ignoring O(n²) memory, fp64 dependence, or long serial recurrences — "mathematical beauty ≠ tractability"; an analogical conclusion may be mathematically correct yet hardware-infeasible.

Eight-dimension minimum criteria (formal terms): **Tensorization** checks batch-expressibility of the transferred structure; **GEMM-mappability** checks whether the core operator after analogy maps to matrix multiplication; **complexity** checks whether global constructions brought from the source domain explode; **memory and KV-cache** checks whether large tables or long caches are introduced; **low-precision stability** checks whether the analogical structure depends on exact symbolic or high-precision computation; **parallelism and communication** checks whether recurrences or interactions can be chunked; **sparse structure** checks whether sparsity is regular; **operator fusion** checks whether the transferred structure can be realized as a small number of fused ops.

> Used together with `../../references/gpu-friendly-math.md` (eight-dimension gate), `../../references/books/abstract-algebra.md` (homomorphism/isomorphism structures), `../../references/books/algebraic-geometry-rising-sea.md` (cross-domain structure transfer and compression).

## When NOT to Use

- **Rigorous proof is required** — inductive reasoning and analogy can only produce hypotheses, not proofs; however, mathematical induction itself is a proof method.
- **There is only one or very few samples** — inductive reasoning needs a sufficient number of instances for support.
- **The two domains are too different** — analogy requires structural similarity, not mere surface resemblance.
- **The conclusion must have zero error** — inductive reasoning carries uncertainty; analogy carries distortion risk.
- **The problem can be solved directly by deduction** — there is no need to detour through induction.

## When to Use

- Multiple cases have been observed sharing a common pattern, and one wishes to propose a general hypothesis.
- Attempting to discover new theorems or new regularities in research.
- Properties of recursively defined structures (trees, lists, expressions) need to be proved — use structural induction.
- Propositions involving decomposition (e.g., prime factorization of integers) need to be proved — use strong induction.
- Arguments over well-ordered sets beyond the natural numbers are needed — use transfinite induction.
- Cross-disciplinary borrowing — can methods from other fields be applied to one's own problem?
- **Borrowing structures from other fields for algorithm/operator design** — cross-domain analogical transfer of structures (e.g., algebraic homomorphism → low-rank mapping, sheaf diffusion → block summary), passing the GPU eight-dimension gate before adoption.

## Method

### Step 1: Collect Concrete Cases
Systematically collect and observe concrete instances: extract key cases from the literature, gather patterns from experimental data, and organize known theorems. Ensure cases cover boundary values, typical values, and extreme values. The diversity and coverage of cases determine the quality of induction — too few or too homogeneous cases will be misleading.

### Step 2: Identify Patterns
Compare commonalities and differences across cases: what features appear in all (or most) cases? What appears only in some? Are the differences themselves patterned? Be aware that patterns may suddenly break after a number of cases (as in the Borwein integral phenomenon) — focusing only on commonalities can cause one to miss counterexamples.

### Step 3: Formulate a Hypothesis
Based on the observed pattern, formulate a general hypothesis: **strong hypothesis** ∀n P(n) (holds in all cases); **weak hypothesis** P(n) holds for sufficiently large n (with exceptions); **conditional hypothesis** ∀n∈S P(n) (on a specific subset). Selection principle: try the strong hypothesis first, then weaken it stepwise with counterexamples. The hypothesis must be specific enough to be falsifiable.

### Step 4: Search for Counterexamples
Actively seek counterexamples that falsify the hypothesis — the hallmark distinguishing science from pseudoscience. If a counterexample is found, revise (weaken or add conditions); if none is found, the hypothesis stands provisionally. Pay special attention to boundary conditions, extreme values, and whether the pattern suddenly fails when parameters change.

### Step 5: Attempt a Proof
For mathematical hypotheses, attempt a rigorous proof; selecting the correct induction variant is key:

- **Weak Induction**: Prove P(1) + ∀k(P(k)→P(k+1)) → ∀n P(n); applicable when P(k+1) depends only on P(k) (summation formulas, simple recurrences); example: 1+2+…+n = n(n+1)/2.
- **Strong Induction**: Assume P(1)..P(k) all hold and prove P(k+1); applicable when P(k+1) depends on multiple predecessors (decomposition, partition propositions); example: every integer greater than 1 is a product of primes, Fibonacci properties. Key: when P(k+1) must invoke P(j) for j<k, strong induction is required.
- **Structural Induction**: Prove P(base) + P(composite) follows from P(components); applicable to recursively defined structures (trees, lists, expressions, formulas, program semantics); example: the number of leaf nodes in a binary tree equals the number of internal nodes plus 1. It is the natural extension of mathematical induction to recursive structures.
- **Transfinite Induction**: For a well-ordered set (W,<), prove ∀α∈W(∀β<α P(β)→P(α)) → ∀α∈W P(α); applicable to well-ordered sets indexed beyond the natural numbers (ordinals, partially ordered sets, topological transitive closures); example: applications of Zorn's lemma, recursive constructions in set theory.
- **Well-ordering principle equivalence**: Every non-empty subset has a least element ↔ natural number induction ↔ strong induction ↔ transfinite induction on well-ordered sets. Practical implication: choose the most natural formulation.

### Step 6: Analogical Transfer
Using analogy requires quantitative evaluation rather than relying solely on intuition:

- **Structural similarity measure**: Structural similarity = (number of successfully mapped relations + number of successfully mapped components) / (total source relations + total source components).
- **Analogy validity grading**: **High validity (homomorphism)** — most structures have correspondents, key relations are preserved, conclusions have high credibility; **Medium validity (partial homomorphism)** — some are preserved and some are distorted, conclusions must be revised before use; **Low validity (surface similarity)** — only appearance/terminology is similar, deep structures differ, conclusions are essentially unreliable.
- **Systematic verification checklist**: (i) Does every component in the source domain have a correspondent in the target domain? (ii) Does every relation hold in the target domain? (iii) Is every operation defined in the target domain? (iv) Mapping consistency: if a↦a', b↦b', does R(a,b) imply R'(a',b')?

### Step 7: Hypothesis Revision
Revise the hypothesis based on counterexamples and proof attempts, following Lakatos's methodology: **Monster-barring** — treating the counterexample as outside the intended scope and explicitly excluding it (simplest; guard against over-exclusion leading to vacuity); **Lemma-incorporation** — incorporating the hidden condition exposed by the counterexample as a new lemma (makes the hypothesis more precise); **Proof-strategy revision** — the counterexample reveals a fundamental flaw in the original proof approach, requiring a different proof framework (most profound). After revision, return to Step 4 and iterate until the hypothesis stabilizes.

## Common Errors

| Error | Critique | Correct Approach |
|-------|----------|-----------------|
| Induction from insufficient samples | "Patterns" induced from 2–3 cases are extremely unreliable | Sample size must be large enough and cover diverse cases |
| Treating inductive reasoning as proof | Inductive reasoning only produces hypotheses, not proofs; mathematical induction is a proof method | Distinguish inductive reasoning from inductive proof: the former generates conjectures, the latter verifies them |
| Confirmation bias | Only seeing cases that support the hypothesis while ignoring counterexamples | Actively search for counterexamples — the most critical step |
| Surface analogy | Analogy based on surface similarity rather than structural similarity | The basis of analogy is structural isomorphism/homomorphism, not surface resemblance |
| Overextending analogy | Two domains are not fully isomorphic; analogical conclusions are not fully valid | Quantitatively evaluate analogy strength using structural similarity |
| Failing to verify after induction | Proposing a hypothesis without testing it | The hypothesis must be tested against counterexamples and/or proved |
| Using weak induction when strong induction is needed | When P(k+1) depends on multiple predecessors, weak induction cannot complete the inductive step | Identify the dependency structure: if P(k+1) must invoke P(j) for j<k, use strong induction |
| Evaluating analogy by surface features alone | Surface feature similarity does not imply structural similarity; conclusions may be entirely wrong | Use systematic mapping to compare components, relations, and operations one by one |
| Conflating inductive reasoning with inductive proof | Inductive reasoning is empirical; inductive proof is deductive — they are fundamentally different in nature | Distinguish clearly: reasoning → hypothesis; proof → theorem |
| Ignoring pattern disruption (Borwein integrals) | Patterns that hold for the first several cases may suddenly break down; inductive reasoning has blind spots | Check sufficiently many cases; watch for sudden pattern changes at boundaries and under parameter variations |
| Transferring intractable structures via analogy | Adopting a structure solely because the isomorphism is elegant, while ignoring O(n²) memory or fp64 dependence — "mathematical beauty ≠ tractability" | Run the transferred structure through the GPU eight-dimension gate first; if intractable, adapt (low-rank / block-sparse / relaxation) before adoption |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Case inventory**: `[Case N]: [description] [key features]`, ensuring coverage of boundary and extreme values.
2. **Pattern identification**: `[Common pattern]: [description] [frequency: N/M] [Difference pattern]: [description]`, noting whether Borwein-type sudden disruption occurs.
3. **Hypothesis statement**: `[Hypothesis]: [content] [type: strong/weak/conditional]`, trying the strong hypothesis first.
4. **Counterexample search**: `[Counterexample]: [found/not found]. If found: [description], hypothesis revision: [new statement]`.
5. **Proof direction**: `[Induction type: weak/strong/structural/transfinite]` with a proof outline; explain why this variant was chosen.
6. **Analogy mapping**: `[Source domain A] → [Target domain B]: [correspondence] [structural similarity: X/Y] [validity: high/medium/low]`, verifying components, relations, and operations item by item.
7. **Hypothesis revision**: `[Revision method: monster-barring/lemma-incorporation/strategy revision] [Revised hypothesis]`.
8. **[GPU feasibility]** (if the transferred structure is used for algorithm/operator design) — run the transferred structure through `../../references/gpu-friendly-math.md` eight-dimension gate, annotate as friendly / retrofittable / unfriendly + adaptation suggestions.

**The output must not present analysis alone without a conclusion; when further execution is needed, state in one sentence at the end what will be done next.**

## Relations to Other Skills

- **Logical deduction**: Induction generates hypotheses; deduction proves them — the two wings of discovery and verification.
- **Abstraction thinking**: Analogy is essentially identifying the common abstract structure of two domains.
- **Probability and statistics**: The probabilistic version of inductive reasoning is statistical inference.
- **Modeling thinking**: The inductive process of discovering patterns from data is also part of modeling.
- **Algorithmic thinking**: Induction as a correctness proof paradigm — loop invariants are induction hypotheses, and the correctness of recursive programs relies on structural induction.
- **Discrete / Combinatorial thinking**: Combinatorial induction — inductive arguments on combinatorial objects, such as graph-theoretic induction and inductive recurrences in generating function methods.
- **Modern mathematics activation**: `../../references/books/abstract-algebra.md` (structural analogy: homomorphism/isomorphism as formalization of analogy), `../../references/books/algebraic-geometry-rising-sea.md` (cross-domain structure transfer: sheaves/restriction maps/Plücker compression).
