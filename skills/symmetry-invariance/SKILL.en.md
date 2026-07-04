---
name: symmetry-invariance
description: |
  Trigger for group theory analysis, invariant computation, Galois theory, Noether's theorem, orbit classification, quotient space reasoning, symmetry breaking; or designing equivariance/conservation/invariant structures (e.g. SO(3)/SE(3) equivariant nets, tropical semiring) for algorithms.
---

# ⚛️ Symmetry & Invariance

> "Finding the properties that remain unchanged under transformations, revealing their underlying laws."
>
> — Group Theory, Invariant Theory, Noether's Theorem
>
> Sophus Lie wanted to forge a dragon-slaying sword — to solve all differential equations. Though not every dragon was slain, the forging technique (the Lie group–Lie algebra correspondence) was passed down and later applied to linearizing nonlinear problems, describing physical symmetries, and robot state estimation. The most fascinating aspect of mathematics is that tools invented for specific problems often reveal far greater value in entirely different domains. This is the archetype of "cross-domain activation."

## Core Principle

**Find what remains unchanged amid change — this is the shortcut to understanding complex systems. Symmetry is not merely "aesthetically pleasing"; it is a manifestation of the deep structure of a system. Every symmetry corresponds to a conserved quantity (Noether's theorem), and every invariant is a key to simplifying a problem.**

> **Mathematical Formalization**
>
> A group **G** acts on a set **X**: φ: G×X→X (φ(e,x)=x, φ(g,φ(h,x))=φ(gh,x)).
>
> An **invariant** f: X→Y satisfies f(g·x)=f(x) ∀g∈G. Formally: f is G-invariant ⇔ f: X/G → Y is a function on the quotient space. Invariants distinguish only between orbits, not elements within the same orbit.
>
> An **orbit** is O(x)={g·x : g∈G}; the equivalence relation x~y ⇔ ∃g∈G, y=g·x gives X/~ = X/G. The **quotient space** X/G consists of all orbits. Classification is essentially working on X/G; finding invariants means finding functions that are constant on each orbit.
>
> The **stabilizer** is Stab(x)={g∈G : g·x=x}, and |O(x)|=|G|/|Stab(x)| — the larger the orbit, the fewer symmetries remain.
>
> Core intuition: **Invariant = function constant on orbits = function on the quotient space X/G**. A complete set of invariants embeds X/G into a simpler space, achieving full classification.
>
> Hierarchy of symmetries: geometric symmetry (O(n)/E(n), invariants: distance, area); algebraic symmetry (Galois theory, discriminant); physical symmetry (Lie groups, energy/momentum/angular momentum); structural invariance (isomorphism/homotopy equivalence).
>
> **Reynolds operator**: For a finite group G, R(f)=1/|G| Σ f(g·x), R²=R, and the image is precisely the set of all invariants. **Burnside's lemma**: |X/G|=1/|G| Σ |Fix(g)|. **Lie algebra generators**: T_a·f=0 are differential equations whose solutions yield invariants. **Noether's theorem**: Continuous symmetry → conserved current Jμ, ∂_μ Jμ=0. **Galois theory**: An equation is solvable by radicals ⇔ Gal(f) is a solvable group.
>
> See `original-texts.md` for details.

## GPU-Friendliness (Cross-Cutting Check)

Whether symmetry/invariant structures can run on GPU depends on the degree to which group operations can be "tensorized" — evaluated through the eight dimensions in `../../references/gpu-friendly-math.md`:

- **Group action is tensorizable → friendly**: If the group action is linear (matrix multiplication), then the equivariant layer = GEMM (e.g., SO(3)-equivariant layers use batched GEMM on spherical harmonics / representation matrices).
- **Reynolds averaging**: Averaging over a finite group = summing over |G| transformed results, which can be batched in parallel (friendly); however, when |G| is very large this becomes unfriendly → use continuous approximation via the Lie algebra.
- **Invariants as regularization / constraints**: As loss terms they are local and cheap (friendly); as exact symbolic computations they are unfriendly.
- **Tropical semiring**: The "symmetry" over min/+ algebra can be mapped to GEMM-like structures (friendly; see `../../references/gpu-friendly-math.md` for examples).
- **Anti-pattern**: Forcing exact classification that requires per-orbit symbolic determination into training — intractable.

Eight-dimension minimum criteria (formal terms): **Tensorization** checks whether the group action can be batched across features; **GEMM-mappability** checks whether representation matrices / spherical harmonics / projections reduce to matrix multiplication; **complexity** examines group order, number of orbits, and integration/quadrature scale; **memory and KV-cache** checks whether multiple replicas / multi-orbit features explode memory; **low-precision stability** checks whether equivariance errors, gauge choices, and normalization remain robust; **parallelism and communication** checks whether group elements / spatial points can be processed in parallel; **sparse structure** checks whether equivariant connections are block-structured; **operator fusion** checks whether group action, aggregation, and projection can be fused.

> Used together with `../../references/books/micro-lie-theory.md` (SO(3)/SE(3) equivariance), `abstract-algebra.md` (groups/semirings), `differential-geometry.md` (gauge symmetry).

## When NOT to Use

- **The system is completely asymmetric with no regularity** — no group action to exploit.
- **Exact numerical solutions are needed** — symmetry provides structural information, not specific values (it tells you "what is equal" but not "equal to what").
- **Symmetry breaking is the core mechanism** (phase transitions, spontaneous breaking) — one should analyze the breaking pattern G→H rather than search for invariants.
- **The problem scale is very small** — the overhead of symmetry analysis may exceed that of direct computation.
- **The group structure is too complex** — when |G| is very large, X/G is no simpler than X, and the invariants themselves may be more complex.

## When to Use

- Facing a complex system and seeking simplifying clues; needing to classify/identify objects (using orbits X/G).
- Searching for conserved quantities or invariants (functions constant on orbits); reducing variables / dimensionality (quotient space, fundamental domain).
- Determining equation solvability (Galois); counting symmetric configurations (Burnside/Pólya).
- Inferring symmetry from conservation laws (inverse Noether).
- **Designing equivariant/invariant networks or operators** (SO(3)/SE(3) equivariance, tropical semiring routing, conservation regularization).

## Method

### Step 1: Identify Transformations
List all transformations the system may undergo, organize them into candidate symmetry groups, and verify the four axioms (closure / associativity / identity / inverse). Spatial transformations → E(n)/O(n)/similarity group; temporal → R or Z₂; algebraic → S_n/GL(n)/SL(n); logical → Z₂/Aut; gauge → U(1)/SU(2)/SU(3) (Lie groups, paired with Lie algebras). If the axioms are not satisfied, identify the actual structure (semigroup? groupoid?) — do not blindly treat it as a group. Pitfall: projections are not invertible and thus do not form a group; compositions of reflections yield rotations (closure holds).

### Step 2: Find Invariants
For G acting on X, find f such that f(g·x)=f(x).
- **Finite groups**: Reynolds operator R(f)=1/|G| Σ f(g·x) (projection onto invariants, R²=R); Burnside's lemma |X/G|=1/|G| Σ |Fix(g)| counts orbits; elementary symmetric polynomials e_k form a complete set of invariants for S_n acting on R^n.
- **Continuous groups (Lie groups)**: Use Lie algebra generators T_a·f=0 to solve for invariants (each generator removes one degree of freedom); integrating Killing vector fields yields invariant coordinates (e.g., SO(3) → r=√(x²+y²+z²)).
- **Fixed-point analysis**: Stab(x) reveals the local degree of symmetry.
- Common invariants: geometric (length/angle/Euler characteristic), physical (energy/momentum/angular momentum), algebraic (discriminant/trace/determinant/characteristic polynomial coefficients), combinatorial (number of orbits/equivalence class sizes).

### Step 3: Use Invariants to Simplify
- **Quotient space reasoning**: Work on X/G rather than X; |X| objects → |X/G| orbits (e.g., 230 space groups → 230 types in X/G).
- **Fundamental domain** D: Each orbit intersects D in exactly one point, so one only needs to analyze D (O(2) → half-plane; SO(3) → spherical triangle; SL(2,Z) → |z|≥1, |Re(z)|≤1/2).
- **Variable reduction**: Replace constrained variables with invariants (energy conservation eliminates one dynamical variable; angular momentum conservation → only the radial part matters; central force field L²=const → one-dimensional radial equation).

### Step 4: Classify via Symmetry
**Orbit–Stabilizer** |O(x)|=|G|/|Stab(x)|: the larger the stabilizer, the more symmetric the object and the smaller the orbit. Objects in the same orbit share all G-invariant values. Key question: Are the invariants complete? That is, does f(x)=f(y) ⇒ x and y are in the same orbit? If incomplete, different orbits may share the same invariant values, requiring more invariants or a finer group. Complete examples: S_n → e₁..e_n; O(n) → r²=Σx_i²; SL(2,C) → discriminant Δ=b²-4ac.

### Step 5: Check Symmetry Breaking
- **Spontaneous breaking**: The equations possess symmetry G, but solutions satisfy only H⊂G (the vacuum selects a direction, G→H). Goldstone's theorem: continuous G→H breaking produces dim(G/H) massless Goldstone modes (ferromagnet SO(3)→SO(2) yields 2 modes; superfluid U(1)→{e} yields 1 mode).
- **Explicit breaking**: The equations themselves do not satisfy G (external forces / mass terms, e.g., quark masses break chiral symmetry SU(2)_L×SU(2)_R→SU(2)_V).
- **Key analysis points**: Identify G→H, compute the number of Goldstone modes dim(G/H), and ensure the effective theory after breaking remains H-invariant.

### Step 6: Algebraic Symmetry (Galois)
Gal(f) is the permutation group of the roots. **An equation is solvable by radicals ⇔ Gal(f) is a solvable group** (subgroup chain G=G₀⊃...⊃G_k={e}, where each quotient is cyclic). Intuition for solvability: each quotient group corresponds to one radical extraction; a non-solvable group means "irreducible complexity." General equations of degree ≥5 have Gal(f)=S_5, which is not solvable (A_5 is the smallest non-solvable simple group); degree 4 has S_4, which is solvable; cyclotomic → cyclic group, solvable. Paradigm: **problem structure → permutation group → group solvability → problem solvability**.

### Step 7: Physical Symmetry (Noether)
**Noether's theorem**: The action S=∫L dt is invariant under G ⇒ conserved current Jμ, ∂_μ Jμ=0. Correspondences: time translation → energy; spatial translation → momentum; rotation → angular momentum; gauge U(1) → charge. Quantum: symmetry G → unitary representation on Hilbert space → irreducible representations classify energy levels → Wigner–Eckart theorem → selection rules. Hierarchy: classical (Lagrangian symmetry → Noether → simplified equations) → quantum (selection rules / degeneracies / Wigner–Eckart) → field theory (gauge symmetry → particle classification → Standard Model SU(3)×SU(2)×U(1)).

## Common Errors

| Error | Critique | Correct Approach |
|-------|----------|-----------------|
| Overlooking hidden symmetries | Surface asymmetry may conceal deeper symmetry, leading to unnecessary complexity | Try different representations (coordinate / basis changes) to find deeper symmetries |
| Confusing approximate with exact symmetry | Approximate symmetry yields only approximate "conservation"; errors accumulate over time | Distinguish exact from approximate invariants; annotate the degree of approximation |
| Overextending symmetry arguments | Not every problem has symmetry; forcing it leads to incorrect conclusions | Verify that the symmetry actually exists before using it; check the group axioms |
| Ignoring symmetry breaking | Breaking may be the key mechanism | Attend to both symmetry and breaking; analyze G→H |
| Failing to verify group properties | A candidate set of transformations may not satisfy closure / inverse | Verify all four axioms; if not satisfied, identify the actual structure |
| Confusing orbit invariants with general invariants | f constant on O(x) ≠ f constant on X (the latter is trivially uninformative) | Be explicit that the invariant is G-invariant (constant on each orbit) |
| Confusing discrete and continuous symmetries | Discrete groups do not admit Reynolds averaging (|G| may be infinite); continuous groups require the Lie algebra | Use Burnside counting for discrete groups; use the Lie algebra + Noether for continuous groups |
| Intractable equivariant structures | Forcing exact classification requiring per-orbit symbolic determination into GPU training | Tensorize group actions, use linear representations to map to GEMM, pass the eight-dimension gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Transformation inventory**: `[Transformation N]: [description] [type]`, organized into candidate groups, noting which axioms were verified (closure ✓/✗ …)
2. **Invariant discovery**: `[Under group G]: [invariant Y] remains unchanged`; for finite groups write the Reynolds form; use Burnside to count orbits
3. **Simplification strategy**: `[Using invariant Y]: [how to simplify]`; note whether working on X/G or fundamental domain D, and estimate the dimensionality reduction
4. **Symmetry classification**: `[Object x]: |O(x)|=, |Stab(x)|=`, orbit classification results, assessment of invariant completeness
5. **Symmetry breaking check**: `[Symmetry Z]: [present/broken], mode [spontaneous/explicit]`; for continuous breaking note the number of Goldstone modes dim(G/H) and the effective group H
6. **Algebraic / Physical symmetry**: For equation solving, note Gal(f) and its solvability; for physical systems, note the Noether correspondence `[Symmetry group G]: [Conservation law]`
7. **Conclusion**: Which invariants were found, how much dimensionality reduction was achieved, and the classification results
8. **[GPU feasibility]** (if used for algorithm / equivariant design) — whether group actions can be tensorized to GEMM, pass the eight-dimension gate, and annotate as friendly / retrofittable / unfriendly

**The output must not present analysis alone without a conclusion.**

## Relations to Other Skills

- **Transformation thinking**: Symmetry is precisely invariance under transformations — two sides of the same coin.
- **Abstraction thinking**: Invariants are the highest level of abstraction — independent of any particular representation.
- **Modeling thinking**: Physical models are often guided by symmetry principles.
- **Axiomatic thinking**: Group theory axioms are the mathematical foundation of symmetry.
- **Topological thinking**: Topological invariants (Euler characteristic, homotopy groups) are invariants under continuous transformations.
- **Algorithmic thinking**: Group-theoretic algorithms exploit symmetry for acceleration (e.g., FFT exploits the cyclic group structure).
- **Discrete / Combinatorial thinking**: Pólya counting is the weighted generalization of Burnside's lemma.
- **Modern mathematics activation**: `../../references/books/micro-lie-theory.md` (SO(3)/SE(3) equivariance, Lie group optimization), `abstract-algebra.md` (groups/semirings), `differential-geometry.md` (gauge symmetry/fiber bundles).
