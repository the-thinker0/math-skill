---
name: axiomatization
description: |
  Trigger when examining the reasonableness of a theory's assumptions, constructing an axiom system, discovering internal contradictions, verifying consistency/independence/completeness; or defining axioms and invariants for an algorithm/operator/structure and checking their computability.
---

# 📐 Axiomatization

> "Starting from minimal assumptions, building through rigorous logic — examining premises matters more than checking conclusions"
>
> — Euclid's *Elements*, Hilbert's *Foundations of Geometry*, Axiomatic Set Theory

## Core Principle

**Any theoretical system can (and should) be reduced to a set of fundamental axioms, from which all theorems in that domain can be derived through rigorous logical inference. Examining premises matters more than checking conclusions — if premises are wrong, no amount of elegant reasoning can save the conclusion.**

> **Mathematical Formalization**
>
> The quality of an axiom system is judged by the following core criteria:
>
> - **Consistency**: The axioms must not contradict one another. If the axiom set is contradictory, then by the principle of explosion (*ex falso quodlibet*) any proposition can be derived, and the system collapses.
> - **Independence**: No axiom should be derivable from the others.
> - **Completeness**: All true propositions in the domain should be provable from the axioms (note: completeness varies with the order of the logical system; see Method).
>
> **Categoricity**: An axiom system is categorical if all its models are isomorphic to one another. A categorical system uniquely determines the structure of its subject — for example, the second-order Peano axioms are categorical (the unique model is the natural number structure ℕ), whereas the first-order Peano axioms are not (non-standard models exist).
>
> **Relative Consistency**: If all axioms of system A can be embedded as true propositions in system B, and system B is known to be consistent, then system A is consistent. This is the standard method for proving consistency — for example, the consistency of PA can be proved within ZFC (the axioms of PA are all true in ZFC), but the consistency of ZFC itself can only be relatively proved in a stronger system (e.g., ZFC + the existence of an inaccessible cardinal).
>
> See `original-texts.md` for detailed mathematical foundations.

## GPU-Friendliness (Cross-Cutting Check)

When axiomatization is used to **define axioms and invariants for an algorithm/operator/structure**, the defined structures must pass the eight-dimension gate of `../../references/gpu-friendly-math.md` — "axiomatically self-consistent" does not mean "computable":

- **Friendly**: The axiom system naturally reduces to linear algebra — group action axioms → equivariant layers = GEMM (weight sharing along orbits); ring axioms relaxed to semirings → generalized GEMM (min-plus / tropical). Passes dimensions 1/2/3.
- **Adaptable**: Essentially discrete/symbolic axioms (hard Top-K, exact finite-field arithmetic, symbolic proof search) block gradients → relax the axioms: tropical semiring piecewise-linear gating, Gumbel-softmax, differentiable surrogates.
- **Anti-pattern**: Invariants requiring global symbolic reasoning or exact discrete satisfaction (e.g., exact Čech cohomology, exact orbit-equality testing) → "beautiful but not computable"; switch to local/continuous approximations.

Eight-dimension minimum assessment (formal terminology): **Tensorization** — whether axiom instances can be batch-checked; **GEMM-Mappability** — whether operational axioms can reduce to linear/semiring matrix multiplication; **Complexity** — whether consistency/independence checking degenerates to undecidable or exponential search; **Memory & KV-Cache** — whether invariants require a global state table; **Low-Precision Stability** — whether axioms tolerate approximate equalities; **Parallelism & Communication** — whether local axioms can be verified in blocks; **Sparsity Structure** — whether the constraint graph is structured; **Operator Fusion** — whether axiom checks can be compiled into lightweight loss/guard kernels.

> In conjunction with `../../references/books/abstract-algebra.md` (group/ring/field axioms, ring→semiring relaxation) and `../../references/books/algebraic-geometry-rising-sea.md` (sheaf/category/cohomology axioms).

## When NOT to Use

- **Pure factual queries** (e.g., "what is this formula") — no theoretical system needs examination.
- **The user has already accepted a theoretical framework and only needs to apply it** — the axioms are already chosen.
- **Empirical questions** (requiring experimental data rather than logical reasoning) — axiomatization cannot substitute for empirical evidence.
- **Defaulting to classical tools in a constructive context** — if the user requires constructive proofs, the law of excluded middle or the axiom of choice should not be assumed by default.

## When to Use

- When reading a paper, examining whether its theoretical assumptions are reasonable and self-consistent.
- When building a theoretical framework, starting from the minimal axiom set.
- When discovering contradictions or inconsistencies within a theoretical system.
- When determining whether a formal system is decidable or complete.
- When comparing the consequences of different axiom choices (constructive vs. classical, first-order vs. second-order).
- **Defining axioms and invariants for an operator/structure** and checking their computability on GPU.

## Method

### Step 1: Identify the Axioms
Find all fundamental assumptions (axioms) of the theoretical system, distinguishing: **explicit axioms** (clearly stated by the author), **implicit axioms** (unstated but actually used in the argument), **background axioms** (default assumptions of the larger framework, e.g., defaulting to ZFC).

> "Every science truly matures only after it has been axiomatized." — Hilbert

### Step 2: Specify the Formal Language
The expressive power of an axiom system depends on the chosen formal language; before axiomatizing, one must specify:

- **First-order Logic**: Quantifiers range only over individual elements. Expressive power is limited, but it admits a complete proof theory (Gödel's Completeness Theorem: the provable coincides with the valid). Models of a first-order theory are not unique (non-categoricity), but the proof system is sound and complete.
- **Second-order Logic**: Quantifiers may range over subsets and functions. Greater expressive power (can express categoricity, e.g., second-order Peano uniquely characterizes ℕ), but no complete proof system exists — its semantics cannot be fully captured by any recursive axiom set.
- **Constructive / Intuitionistic Logic**: Rejects the law of excluded middle (∀P, P∨¬P). Existential proofs must provide an explicit witness: proving ∃x.φ(x) requires constructing a specific x₀ such that φ(x₀) holds. Inference rules are stricter, but all proofs are guaranteed to be computable.

> Choosing a language is not merely a technical detail but a fundamental philosophical decision: first-order logic commits to an exhaustible proof system, second-order logic commits to structural uniqueness, constructive logic commits to computability.

### Step 3: Check Consistency
Check whether the axioms contradict one another. If the axiom set is contradictory, then by the principle of explosion any proposition can be derived, and the system collapses. Methods:

- Look for two axioms P and ¬P that hold simultaneously.
- Attempt to construct a model in which all axioms are simultaneously true (model existence ⇒ consistency).
- **Relative consistency proof**: Embed the axioms of system A as true propositions in system B; if B is known consistent, then A is consistent. For example, PA is consistent (the PA axioms are all true in the von Neumann natural number model within ZFC).
- **Finite model method**: For weaker formal systems (propositional logic, certain finitely axiomatized weak arithmetics), construct a finite model to directly verify consistency.

### Step 4: Check Independence
Check whether any axiom can be derived from the others. If so, it is not a true axiom but a theorem. Methods:

- For each axiom A, construct a model in which A fails but all other axioms hold.
- If such a model exists, then A is independent of the other axioms.
- Classical examples: the parallel postulate is independent of the remaining axioms of Euclidean geometry (non-Euclidean geometry models); the Axiom of Choice is independent of ZF (Cohen's forcing method).

### Step 5: Assess Completeness
Check whether the axiom system is strong enough to derive all important results in the domain. Completeness properties vary with the logical order and the content of the theory:

- **First-order theories can be complete**: Dense Linear Order (DLO), Algebraically Closed Fields of fixed characteristic (ACF_p), and other first-order theories are complete and decidable. Completeness ≠ absence of open problems; completeness means that for every sentence φ, either φ or ¬φ is provable from the axioms.
- **Scope of Gödel's Incompleteness Theorems**: Incompleteness specifically applies to first-order recursively enumerable theories containing sufficient arithmetic (PA, ZFC, etc.), in which there necessarily exist undecidable propositions (e.g., the Gödel sentence in PA, CH in ZFC).
- **Decidability is an independent question**: A complete first-order theory is typically decidable (there exists an algorithm to determine whether any formula is a theorem), but an incomplete theory is not necessarily undecidable — decidability depends on whether an algorithm for deciding theorems exists, not on whether all propositions have proofs.

### Step 6: Analyze the Impact of Axiom Choice
What happens to the theory if an axiom is changed or relaxed? Many branches of mathematics developed precisely through altering axioms:

- Changing the parallel postulate → non-Euclidean geometries (hyperbolic geometry, elliptic geometry).
- **Constructive vs. Classical**: Removing the law of excluded middle → constructive mathematics (Brouwer, Heyting), where existence proofs must provide explicit constructions; adding the Axiom of Choice → stronger classical mathematics, but yielding non-constructive proofs (e.g., the Banach-Tarski paradox).
- **Zorn's Lemma, the Well-Ordering Theorem, and the Axiom of Choice**: These three are equivalent within ZF — accepting any one means accepting all; this equivalence itself is non-constructive.
- Changing the induction axiom → non-standard analysis.

### Step 7: Apply and Conclude
Synthesize the above analysis and give an overall assessment of the axiom system: Is it suitable for its intended domain of application? Are there axioms that need to be supplemented or revised? What are the limitations of the system (undecidable propositions, non-categoricity, lack of constructivity, etc.)?

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Confusing axioms with theorems | Treating a proposition that needs proof as a self-evident axiom | Clearly distinguish: axioms are the starting point, theorems are the endpoint |
| Overlooking implicit assumptions | Using unstated assumptions in the argument, making the reasoning imprecise | Scrutinize every step of reasoning, exposing all hidden assumptions |
| Accepting a contradictory axiom set | From contradictory axioms, any conclusion can be derived (principle of explosion) | Verify the consistency of the axiom set |
| Treating axioms as truths | Axioms are merely conventions about starting points, not absolute truths | The value of axioms lies in the usefulness of their consequences |
| Ignoring the possibility of axiom change | Assuming axioms are the only possible choice | Consider what new theories arise from changing axioms |
| Confusing first-order and second-order completeness | First-order logic has a complete proof system (Gödel completeness); second-order does not; "completeness" has different meanings in each | Distinguish proof-theoretic completeness from model-theoretic completeness; specify the logical order |
| Neglecting constructive obligations | Using the law of excluded middle in a constructive context, or proving only ¬¬∃x.φ(x) without providing a witness | Constructive proofs of ∃x.φ(x) must provide an explicit witness x₀; the law of excluded middle is prohibited in constructive contexts |
| Assuming all incomplete theories are equally incomplete | Different incomplete theories vary enormously in the number and nature of their undecidable propositions | Analyze the specific theory: which propositions are undecidable, and what are their structural properties |
| Forcing discrete/symbolic axioms into training | Essentially discrete/symbolic axiom systems are non-differentiable and non-computable | Pass the eight-dimension gate; relax to differentiable/approximate forms when necessary (tropical semiring, Gumbel-softmax) |

## Operating Procedure

When this skill is triggered, the output must contain:

1. **Axiom Inventory**: `[Axiom N]: [content] (source: explicit / implicit / background)`
2. **Formal Language Specification**: `[Language type]: [first-order / second-order / constructive] (rationale: ...)`
3. **Consistency Check**: `✅ Consistent` or `❌ Contradiction found: [specific contradiction]`; if using relative consistency, note the target system of the embedding
4. **Independence Analysis**: Flag any redundant axioms `⚠️ [Axiom N] may be derivable from [Axiom M]`
5. **Completeness Assessment**: `✅ Complete` / `⚠️ Incomplete: missing [X]`; note whether Gödel's incompleteness theorems apply, and indicate decidability
6. **Axiom Change Analysis**: If a particular axiom is changed (removing excluded middle, adding/removing the Axiom of Choice), how does the theory change?
7. **Conclusion**: Overall assessment of the system's consistency, independence, completeness, categoricity, and decidability
8. **[GPU Feasibility]** (if used for algorithm/operator/structure design) — structures derived from the defined axioms and invariants pass the eight-dimension gate of `../../references/gpu-friendly-math.md`, rated friendly / retrofittable / unfriendly + adaptation recommendations

**Output must never provide analysis alone without a conclusion. Every item must receive a definitive verdict — no hedging.**

## Relations to Other Skills

- **Logic Deduction**: Axiomatization requires logical deduction as its inference tool; formal inference rules are the proof mechanism of the axiom system.
- **Abstraction**: Axiomatization is abstraction at the highest level — reducing everything to minimal assumptions.
- **Modeling**: An axiom system is itself a kind of model, whose applicability to reality must be verified; model theory directly serves consistency and independence checks.
- **Induction and Analogy**: The choice of axioms is often inspired through induction and analogy.
- **Algorithmic Thinking**: Formal systems and decidability are directly linked — decidable theories admit algorithmic theorem-decision procedures; undecidable theories do not.
- **Modern Math Activation**: `../../references/books/abstract-algebra.md` (axiom systems / groups, rings, fields; ring→semiring relaxation), `../../references/books/algebraic-geometry-rising-sea.md` (sheaf/category/cohomology foundations).
