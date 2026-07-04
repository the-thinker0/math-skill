---
name: abstraction
description: |
  Trigger when extracting mathematical structures from complex problems, discovering cross-domain commonalities, building general theories; or finding transferable abstract structures (category/algebra/topology) for algorithm/operator design.
---

# 🧩 Abstraction

> "The power of mathematics lies in abstraction: ignoring contingent details to reveal necessary structures."
>
> — Algebra, Topology, Category Theory

## Core Principle

**Abstraction is not distancing from reality but penetrating into it — by stripping away superficial, contingent details, one reveals deep, essential structures. Problems from different domains often share the same abstract structure.** In the context of this skill pack, abstraction is the core operation of "cross-domain activation": transferring structures from algebraic geometry / topology to algorithm design relies on identifying the abstract structures shared by both.

Three progressive levels of abstraction: **Distillation** (identifying common structure across multiple instances) → **Generalization** (extending theorems from special to general cases) → **Structurization** (reconstructing the entire problem domain in the language of structure).

> **Mathematical Formalization**
>
> Category-theoretic perspective: Objects and morphisms form a category **C**; functors **F, G : C → D** preserve structure; natural transformations **η : F ⇒ G** relate functors; **Yoneda Lemma**: Hom(Hom(−, A), F) ≅ F(A), i.e., an object is completely determined by all morphisms pointing to it.
>
> Algebraic perspective: Groups (closure, associativity, identity, inverse); rings (additive group + multiplicative semigroup + distributivity); fields (ring + multiplicative inverses); modules (vector spaces over a ring); lattices (partially ordered set + meet and join).

## GPU-Friendliness (Cross-Cutting Check)

Whether an abstract structure can be deployed on GPU depends on the computational form it takes once "concretized" — pass the eight dimensions of `../../references/gpu-friendly-math.md`:

- **Category / algebraic structure → GEMM**: If the abstract structure can be concretized as linear maps (e.g., restriction maps, group representations), it naturally maps to Tensor Core GEMM (friendly).
- **Universal constructions (products / coproducts / limits)**: If materialized as large intermediate tensors, memory explodes (unfriendly) → refactor into chunked / streaming or low-rank approximations.
- **Yoneda perspective**: Replace internal structure with Hom-behavior — if the Hom-sets themselves are huge, the construction is non-computable; friendly only when Hom can be batch-tensorized.
- **Anti-pattern**: Forcing an essentially discrete/symbolic abstraction (e.g., exact computation of general cohomology) into training is often "beautiful but not computable."

Eight-dimension minimum assessment (formal terminology): **Tensorization** — whether abstract objects can be concretized as batched tensors; **GEMM-Mappability** — whether morphisms / representations / restriction maps can reduce to linear maps; **Complexity** — whether the abstraction layer introduces super-linear global constructions; **Memory & KV-Cache** — whether products / limits / Hom tables are materialized; **Low-Precision Stability** — whether concretization depends on ill-conditioned inversion or exact symbolic equalities; **Parallelism & Communication** — whether the construction is locally block-decomposable; **Sparsity Structure** — whether it yields block/banded structure rather than random access; **Operator Fusion** — whether abstract interfaces can converge into a small number of fused kernels.

> In conjunction with `../../references/books/algebraic-geometry-rising-sea.md`, `abstract-algebra.md`, `smooth-manifolds.md`.

## When NOT to Use

- **Every detail is critical** (e.g., debugging a specific bug) — abstraction would discard key information.
- **A specific numerical answer is needed** (e.g., "what is this integral equal to") — abstraction does not provide concrete calculations.
- **The problem is already in its simplest form** — no further abstraction is needed.

## When to Use

- When facing a complex problem and not knowing where to start — first abstract out the core structure.
- When two seemingly different problems share similarities — seek a common abstract framework.
- When generalizing specific experience into general rules, or building cross-domain general models/theories.
- **Transferring modern math structures to algorithm/operator design** — identifying the abstract structure the problem shares with algebraic geometry / topology / Lie theory.

## Method

### Step 1: Describe the Concrete Problem
Precisely describe all elements of the problem in mathematical language — objects, relations, constraints, objectives. Abstraction begins with the concrete: before abstracting, one must fully understand the concrete objects.

### Step 2: Distinguish Essential from Non-Essential Features
Examine each feature one by one: if this feature is changed, does the core structure of the problem change? **Essential features** (those whose change fundamentally alters the nature of the problem) must be retained; **non-essential features** (those whose change leaves the structure invariant) can be ignored. Example: when studying matrix invertibility, the specific entries are non-essential (invariant under similarity transformations), while rank is essential.

### Step 3: Extract the Abstract Structure
Choose the best-matching perspective from four mathematical viewpoints and execute its operations:

- **Category-theoretic perspective** (focus on relations between objects): Identify "objects" and "morphisms/relations"; check that morphisms compose and have identities → forming a category; further check for functors to known categories, natural transformations relating different functors.
- **Algebraic perspective** (focus on operations and axioms): Identify "operations" and their properties (closure / associativity / commutativity / distributivity); match axioms against group / ring / field / module / lattice; determine the best-matching structure.
- **Topological perspective** (focus on continuity and connectedness): Identify "continuous change / proximity / connected-separated"; construct open-set structure and verify topological axioms; identify topological invariants (connectedness, compactness, fundamental group).
- **Analytic perspective** (focus on metrics and norms): Identify "distance / size / convergence"; verify metric/norm axioms; determine properties such as completeness/boundedness, and invoke the corresponding theorems (e.g., Banach space theory).

### Step 4: Solve at the Abstract Level
Leverage existing theory of the abstract structure. Key tools:
- **Universal constructions**: Products (unified projections), coproducts (unified embeddings), limits/colimits (merging and gluing under compatibility conditions).
- **Yoneda Lemma insight**: An object is completely determined by all morphisms pointing to it; to understand X, examine Hom(A,X) / Hom(X,A); to prove two objects are isomorphic, it suffices to show their morphism behavior is identical.

### Step 5: Concretize Back
Precisely translate each element of the abstract solution back into the mathematical language of the original problem, ensuring every step has a correspondence. After abstraction, one must return to the concrete; otherwise abstraction loses its meaning.

### Step 6: Verify
Is key information fully preserved through the round trip? Does the answer to the original problem have a clear counterpart in the abstract solution? After translating back to the concrete, does it indeed solve the original problem? Has any essential feature been accidentally overlooked?

### Step 7: Level Progression
- **Distillation → Generalization**: When the distilled concept has been verified across multiple instances, and the theorem's natural extension appears to hold under broader conditions → generalize.
- **Generalization → Structurization**: When generalized theorems have accumulated enough to support a self-consistent system, and different generalizations are systematically related → structurize.
- **No premature leaps**: If distilled concepts have not been verified across enough instances, do not rashly generalize; if generalized theorems are scattered and unsystematic, do not rashly structurize.

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Over-abstraction | Abstracting away essential details, distorting the problem (e.g., dropping group inverses and retaining only a semigroup) | After each abstraction, check whether key information is preserved |
| Under-abstraction | Retaining too many non-essential details, failing to achieve simplification | Repeatedly ask: is this detail truly necessary? |
| Abstracting to the wrong level | Using category theory for a problem that only needs group theory; or using only set theory for a problem with group structure | Choose the level matching the problem's complexity |
| Forgetting the functorial perspective | Looking only at internal object structure while ignoring morphisms, losing half the information | Simultaneously examine Hom(A,X) and Hom(X,A) |
| Forgetting to return to the concrete | Staying at the abstract level without translating back to the original problem | After abstraction is complete, concretization is mandatory |
| Abstract structure is non-computable | Forcing an essentially discrete/symbolic abstraction into GPU training | After concretization, pass the GPU eight-dimension gate; if non-computable, adapt or abandon |

## Operating Procedure

When this skill is triggered, the output must contain:

1. **[Problem Description]:[Concrete]** — Precisely describe all elements of the problem in mathematical language
2. **[Essential / Non-Essential]:[Distinction]** — List essential and non-essential features, annotating for each whether changing it affects the core structure
3. **[Perspective Choice]:[One of Four]** — Select the best match from category-theoretic / algebraic / topological / analytic, and execute its operational steps
4. **[Abstract Solution]:[Construction]** — Using universal constructions or the Yoneda perspective, provide a solution direction at the abstract level
5. **[Concretization]:[Translation]** — Precisely translate the abstract solution back into the mathematical language of the original problem
6. **[Verification]:[Check]** — Is key information fully preserved through the round trip?
7. **[Level Assessment]:[Progression]** — Indicate which level (distillation / generalization / structurization) is current, and assess whether a leap is warranted
8. **[GPU Feasibility]** (if used for algorithm/operator design) — After concretizing the abstract structure, pass the eight-dimension gate, rating friendly / retrofittable / unfriendly

**Output must never provide analysis alone without a conclusion.**

## Relations to Other Skills

- **Axiomatization**: Abstraction is the precursor to axiomatization — first abstract the essentials, then choose the axioms.
- **Modeling**: Modeling is the concrete application of abstraction — abstracting real-world problems into mathematical ones.
- **Transformation**: A transformation can be seen as a form of abstraction — finding simple structure in a new representation.
- **Induction and Analogy**: Analogy is essentially identifying the shared abstract structure between two different domains.
- **Topological Thinking**: Topological abstraction focuses on continuity and connectedness; it is the concrete form of abstraction in spatial problems.
- **Algorithmic Thinking**: Algorithmic abstraction focuses on the structure of computational processes, abstracting concrete implementations into algorithmic patterns and complexity classes.
- **Modern Math Activation**: `../../references/books/algebraic-geometry-rising-sea.md` (sheaves/categories → attention), `abstract-algebra.md` (groups/semirings → equivariance and routing), `smooth-manifolds.md` (manifold structure → latent-space geometry).
