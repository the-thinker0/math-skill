# Algebraic Geometry (The Rising Sea)

> *The Rising Sea: Foundations of Algebraic Geometry*, Ravi Vakil, Princeton University Press, 2025 edition (ISBN 978-0-691-26866-8).
> The title is taken from Grothendieck's "rising tide" (la mer monte) metaphor: rather than attacking nut-like problems head-on, let the waters of abstraction (categories, sheaves, cohomology) slowly rise, silently submerging and dissolving the problems.
> This file distills this "rising-tide abstraction" into activatable algorithmic structures for AI/GPU -- taking only the most transferable skeleton, not restating the original proofs.

## Overview

This book builds modern Grothendieck-school algebraic geometry from scratch across roughly 30 chapters: the core is to **translate geometric objects into commutative algebra**, then use **sheaves + cohomology** to measure "whether local data can be glued into global data."

For AI, what is truly transferable is not elliptic curves or divisors, but three pieces of abstract machinery:

- **Sheaves = local data + consistent gluing** -- the ontology of geometry-aware aggregation on graphs.
- **Cohomology = obstruction measure for global consistency** -- an algebraic criterion for hallucination/inconsistency.
- **Categories = unified interface for different constructions** -- gathering heterogeneous operators into a single set of adjoint relationships.

In one sentence: **sheaves govern "how to assemble local into global," cohomology governs "what goes wrong when assembly fails," and categories govern "saying all of this in one unified language."**

### Actual Chapter Map

By the book's chapter numbers (`*`/`**` denote advanced sections):

- **Part I Preliminaries**
  - **Sec. 1 Just Enough Category Theory to Be Dangerous**: Sec. 1.1 categories and functors, Sec. 1.2 universal properties, Sec. 1.3 limits and colimits, Sec. 1.4 adjoints, Sec. 1.5 abelian categories, Sec. 1.6* spectral sequences.
  - **Sec. 2 Sheaves**: Sec. 2.1 motivation (sheaf of smooth functions), Sec. 2.2 sheaf and presheaf definitions, Sec. 2.3 morphisms, Sec. 2.4 stalks & sheafification, Sec. 2.5 sheaf on a base, Sec. 2.6 OX-modules form an abelian category, Sec. 2.7 inverse image sheaf.
- **Part II Schemes**: Sec. 3 sets and topological spaces of affine schemes (Zariski topology, generic point), Sec. 4 structure sheaf and scheme definition, Sec. 5 properties of schemes, Sec. 6 quasicoherent sheaves.
- **Part III Morphisms of Schemes**: Sec. 7 morphisms of schemes (Sec. 7.7 Grassmannian first construction), Sec. 8 various finiteness morphisms (Sec. 8.4 Chevalley's theorem and elimination theory), Sec. 9 closed embeddings, Sec. 10 fiber products and base change (Sec. 10.6 Segre embedding), Sec. 11 separated and proper morphisms, varieties.
- **Part IV "Geometric" Properties of Schemes**: Sec. 12 dimension, Sec. 13 regularity and smoothness (Sec. 13.1 Zariski tangent space).
- **Part V Quasicoherent Sheaves on Schemes and Applications**: Sec. 14 vector bundles "=" locally free sheaves, Sec. 15 line bundles, maps to projective space, and divisors (Sec. 15.4 line bundles and Weil divisors), Sec. 16 line bundle properties (Sec. 16.2 ample/very ample, Sec. 16.4 Grassmannian as moduli space), Sec. 17 projective morphisms and relative Spec/Proj.
  - **Sec. 18 Cech Cohomology of Quasicoherent Sheaves**: Sec. 18.1 desired properties, Sec. 18.2 definition and proofs, Sec. 18.3 cohomology of line bundles on projective space, Sec. 18.4 Riemann-Roch and arithmetic genus, Sec. 18.5 Serre duality first glimpse.
  - Sec. 19 applications: curves, Sec. 20* intersection theory glimpse, Sec. 21 differentials, Sec. 22 Riemann-Hurwitz formula.
- **Part VI More Cohomological Tools**: **Sec. 23 Derived functors (Sec. 23.5 Cech cohomology agrees with derived-functor cohomology)**, Sec. 24 flatness, Sec. 25 cohomology and base change.

> Note: **Tropical geometry** is the "skeletonization" of algebraic geometry over the tropical/min-plus semiring, the tropicalization of the projective varieties in Sec. 15-17; the book does not have a dedicated chapter for it. The "tropical gating" below draws on this as a mathematical source, and references are **not tied to specific chapter numbers** (to avoid fabrication).

## Core Structures Transferable to AI/Infra

First the overview mapping, then detailed expansion:

| Mathematical concept (book section) | AI/ML correspondence | Engineering implementation |
|---|---|---|
| Sheaf (Sec. 2) | Geometry-aware information aggregation on graphs | Node = section, edge = transformation in message passing |
| Restriction map (Sec. 2.3, 14) | Directional feature transformation on edges | One low-rank linear map per edge = small GEMM |
| Sheaf Laplacian (Sec. 2, 14) | Geometric attention/diffusion operator | Propagation on L = delta^T delta |
| Cohomology H^0/H^1 (Sec. 18, 23) | Global consistency / hallucination criterion | Cech H^1 regularizer |
| Category + adjoint (Sec. 1.3-1.4) | Unified operator interface | pullback = alignment, pushforward = aggregation |
| Grassmannian + Plucker (Sec. 7.7, 16.4) | Subspace compression encoding | Plucker coordinate block summaries to compress KV-Cache |
| Flatness (Sec. 24) | Smooth distribution transition criterion | Fiber without jumps -> no rank collapse signal |

**1. Sheaf -> geometry-aware information aggregation on graphs** (Sec. 2)

- **Ontology**: a sheaf systematically assigns "to each open set/node a data space (stalk/section) + restriction maps along inclusion relations + a gluing axiom (local consistency implies global gluing)."
- **Mapping**: node features = sections, edges = restriction maps, message passing = enforcing consistency of adjacent sections under restrictions.
- **Implementation**: this is precisely the ontology of **cellular sheaf diffusion / sheaf neural networks**; standard GNNs are the "trivial sheaf" special case -- the sheaf structure injects directional geometric inductive bias into every edge.

**2. Restriction map -> one low-rank linear transformation per edge** (Sec. 2.3, 14)

- **Ontology**: each edge carries a learned linear map F(U) -> F(V).
- **Operator**: this defines the **sheaf Laplacian** L = delta^T delta (where delta is the coboundary operator); diffusion/attention is propagation on L; when all restriction maps are identity, this reduces to the standard graph Laplacian.
- **Implementation**: each edge map is low-rank -> a sequence of **small GEMMs**, naturally landing on Tensor Cores; the rank is a tunable expressivity knob.

**3. Cohomology -> global consistency / hallucination criterion** (Sec. 18, 23)

- **H^0** = global sections: all locally consistent data that can truly be glued into a global solution.
- **H^1** = **gluing obstruction**: pairwise locally consistent yet unable to assemble globally -- i.e., "self-consistent contradictions." Formally H^1 = ker delta^1 / im delta^0.
- **Criterion**: gives hallucination an **algebraic criterion** -- H^1 != 0 <=> the model is locally confident but globally conflicting.
- **Computability boundary**: **Cech cohomology (Sec. 18.2)** is computed directly from the overlaps of a cover, locally and cheaply; Sec. 23.5 proves that under good conditions it agrees with the expensive derived-functor cohomology -- this boundary line determines "which cohomology can run on a GPU."

**4. Category + universal properties + adjoints -> unified abstract interface** (Sec. 1)

- **Ontology**: pullback / pushforward (f^*, f_*) are an adjoint pair (Sec. 1.4); products, coproducts, fiber products are unified as (co)limits (Sec. 1.3).
- **Implementation**: using one abstract interface to unify different operators -- **pullback = feature alignment/resampling, pushforward = aggregation/pooling** -- with the adjoint relationship automatically guaranteeing compatibility, reducing hyperparameters and alignment bugs.

**5. Proj / projective + Plucker coordinates -> subspace compression encoding** (Sec. 7.7, 16.4, 15)

- **Ontology**: the Grassmannian parameterizes "k-dimensional subspaces," embedded into projective space via the **Plucker embedding (explicitly appearing in this book)** using exterior product coordinates (Plucker coordinates).
- **Implementation**: the subspace spanned by a set of KV vectors can be summarized by a small number of Plucker/exterior-product coordinates as **block summaries**, thereby compressing the KV-Cache -- storing "the subspace" rather than individual vectors.

**6. Flatness -> geometric criterion for smooth distribution transitions** (Sec. 24)

- **Ontology**: fibers of a flat morphism vary continuously without jumps over the base.
- **Implementation**: can serve as a geometric correctness signal for "smooth distribution transfer, no rank collapse" during training/fine-tuning (somewhat theoretical; implementation requires careful validation).

## Problem Types Suited for Activation

- **Attention and message passing on graph/set structures**: nodes carry heterogeneous feature spaces, edges carry directional transformations -> sheaf diffusion is more expressive than plain GNNs.
- **Multi-source/multi-view consistency**: multimodal, multi-agent, retrieval-augmented (RAG) local evidence to be glued into global answers -> H^0/H^1 measures consistency.
- **Hallucination / self-consistency detection and regularization**: need a differentiable penalty for "locally self-consistent but globally contradictory" -> Cech H^1 regularizer.
- **Memory compression for long-context inference**: KV subspace redundancy is high -> Plucker-style block summaries.
- **Sparse routing / gating (MoE, Top-K)**: need differentiable approximation of discrete choices -> tropical semiring piecewise-linear gating.
- **Need a framework unifying heterogeneous operators**: using the pullback/pushforward adjoint pair to unify alignment and aggregation.

## Possible Algorithmic Inspirations

**Tropical Sheaf Attention Trilogy** (consistent with the candidate validation examples in `../gpu-friendly-math.en.md`):

1. **Tropical Gating**
   - Replace hard Top-K routing with **piecewise-linear** scoring on the max-plus semiring.
   - Sub-differentiable (kink points need LogSumExp softening; after softening it reverts to standard softmax), tensorizable but **not Tensor Core GEMM** (max/min falls on CUDA cores) -- replacing non-differentiable discrete choices.
2. **Cellular Sheaf Diffusion**
   - Attention = diffusion on a learnable sheaf Laplacian.
   - One **low-rank restriction map per edge (= small GEMM)**, injecting edge-direction geometric inductive bias into attention.
3. **Cech Cohomology Regularizer**
   - Compute first-order Cech H^1 on a **fixed finite cover** of attention maps.
   - Serves as a hallucination/inconsistency penalty term; local and cheap. Differentiability requires a proxy (e.g., H^1-component projection norm ||(I - P_{im delta^0}) c||^2, differentiable via SVD/pseudoinverse, non-smooth at rank jumps), not exact Betti numbers.

**Other point inspirations:**

- **Low-rank basis KV compression (Grassmannian/Plucker perspective)**: represent each block's KV subspace by its **low-rank basis** (low-rank decomposition, kn or k(n-k) parameters) to compress memory. Note: Plucker coordinates themselves, at low rank, number C(n,k) and actually **expand** rather than compress, so the true compression comes from the low-rank basis rather than Plucker coordinates -- "Plucker" is a borrowed name. Compression ratio depends on the block's original redundancy and must be measured empirically.
- **Tropical-semiring MoE routing**: routing logits are piecewise-linear on max-plus, yielding **structured sparse** and differentiable expert selection.
- **Adjoint Pull/Push operator pair**: implementing up/downsampling and alignment/aggregation as an adjoint pair, enforcing compatibility and reducing hyperparameters.

## GPU Friendliness Warning

> **Required reading and sole authority**: `../gpu-friendly-math.en.md`
> Eight-dimension scorecard: D1 Tensorization, D2 GEMM-mappability, D3 Complexity, D4 Memory/KV, D5 Low-precision stability, D6 Parallelism & communication, D7 Sparse structure, D8 Operator fusion.
> **Mathematical beauty != computable**; any dimension that is "unfriendly and not reformable" means elimination.

**Can land as GEMM / sub-quadratic (friendly [v]):**

| Construction | Dimensions hit | Notes |
|---|---|---|
| Low-rank restriction maps | D1, D2, D4 | Batched small GEMM, saturates Tensor Cores, low-rank saves memory |
| Tropical gating | D1, D3 (not D2) | Tensorizable, per-token gating is sub-quadratic; **not GEMM** (does not land on Tensor Cores); sub-differentiable, max kink points need LogSumExp softening |
| Cech H^1 regularizer (fixed cover) | D3, D8 | Locally cheap, fusible with attention kernel (FlashAttention-style) |
| Low-rank basis block summaries (Plucker perspective) | D4 | Low-rank decomposition compresses KV, large inference memory reduction (compression ratio needs empirical measurement) |

**Beautiful but not computable (unfriendly [x], prohibited from training forward pass):**

- **Derived functor cohomology for general sheaf cohomology (Sec. 23)**
  - Requires injective resolutions + spectral sequences, belonging to **symbolic algebra**.
  - No tensorization, no GEMM, not sub-quadratic, not differentiable -> violates D1, D2, D3, D5, D8.
  - Can only be done offline, small-scale, for analysis; **use only the Cech version that agrees with it (Sec. 23.5) and restrict to fixed covers**.
- **Topological layers of Spec/Proj (Zariski topology, generic point, Sec. 3-4)**: discrete non-numerical structures, not differentiable -> violates D1. Serve only as conceptual scaffolding.
- **Ideal elimination / Groebner bases (Chevalley's theorem and elimination theory, Sec. 8.4)**: combinatorial explosion, serial, unstructured -> violates D3, D6, D7.
- **Dynamic / unstructured Cech covers**: if the cover changes with input or overlaps are irregular, H^1 computation degenerates into random gather/scatter -> violates D7. **Must use fixed finite covers + structured (block/banded) overlaps.**

## Which Design Lens to Invoke

- **topological (primary)**: cohomology, H^1 obstructions, invariants under continuous deformation -- precisely the motivating theme of sheaf/cohomology activation.
- **categorical**: extracting the essence of message passing via "sheaf = local data + gluing," abstracting engineering operators as restriction maps.
- **duality**: tropicalization, Plucker embedding, pullback/pushforward -- using equivalence transformations to move hard-to-compute problems into computable coordinate systems.
- **symmetry**: projective invariance, gauge symmetry, sheaf covariance, constraining the model's equivariant structure.
- **axiomatization**: treating the sheaf axioms (locality + gluing) and the cohomology long exact sequence as correctness constraints, auditing "whether the required consistency is violated."

## Anti-patterns

- **Putting abstract/derived-functor cohomology directly into a training forward pass** usually lacks a direct differentiable and efficient implementation. A Cech complex or fixed cover is only a problem-dependent discrete proxy; its scale complexity, approximation semantics, and empirical value must still be validated.
- **Introducing the full Scheme/Proj machinery to "look advanced"** when the task only needs a graph Laplacian: over-engineering, violating "Simplicity First." Ask first: "does a trivial sheaf (= standard GNN) suffice?"
- **Treating Zariski topology / generic points and other discrete structures as differentiable objects** to optimize: type error.
- **Making Cech covers dynamic with unstructured overlaps**: degenerates into random memory access, destroying GPU parallelism (D7).
- **Using the max-plus semiring as an exact semiring** without relaxing at non-differentiable points: gradient breaks, training stalls.
- **Blindly trusting H^1=0 to mean "no hallucination"**: it only guarantees local gluing consistency under the chosen cover, not factual correctness; it is a structural consistency signal, not a truth criterion.

## Deep Dive Entry

> **Bibliographic info**: Ravi Vakil, *The Rising Sea: Foundations of Algebraic Geometry*, Princeton University Press, 2025. ISBN 978-0-691-26866-8.
>
> **Activation method**: Place `The Rising Sea Foundations of Algebraic Geometry.pdf` in the `math_book/` folder at the project root; the Agent can then automatically search the original text. The PDF is not distributed via npm/git (copyright reasons); obtain it independently.

**Full-fidelity lookup**: when the summary is insufficient to support design, have the Agent automatically retrieve the local PDF
`math_book/The Rising Sea Foundations of Algebraic Geometry.pdf`
(using `pdftotext -f <start> -l <end>` for targeted pages, **do not dump the entire book**).

Actual chapter numbers worth deep reading:

1. **Sec. 2 Sheaves** (focus on Sec. 2.2 definitions, Sec. 2.4 stalks and sheafification, Sec. 2.5 sheaf on a base, Sec. 2.7 inverse image sheaf) -- the mathematical foundation for cellular sheaf diffusion and restriction maps.
2. **Sec. 18 Cech Cohomology of Quasicoherent Sheaves** (Sec. 18.1 desired properties, Sec. 18.2 definition and proofs, Sec. 18.4 Riemann-Roch, Sec. 18.5 Serre duality first glimpse) -- the source and computability boundary for H^1 hallucination regularization.
3. **Sec. 23 Derived Functors** (Sec. 23.5 Cech cohomology agrees with derived-functor cohomology) -- drawing the red line between "computable Cech vs. non-computable derived functors."
4. **Sec. 7.7 + Sec. 16.4 Grassmannian** (together with Sec. 15 line bundles and divisors; Plucker embedding appears within this framework) -- the geometric basis for Plucker KV compression.
5. **Sec. 1 Category Theory** (Sec. 1.3 limits/colimits, Sec. 1.4 adjoints) -- the pullback/pushforward adjoint pair and unified operator interfaces.
