# Algebraic Geometry / The Rising Sea

Ravi Vakil, *The Rising Sea: Foundations of Algebraic Geometry*, Princeton University Press, 2025, ISBN 978-0-691-26866-8. Bibliography and chapter locations below were checked against the user-provided local 2025 contents (2026-09-07). AI mappings are repository derivations/hypotheses, not algorithmic theorems from the book.

## When to read

Use for sheaves, cohomology, categories, or Grassmannians when the [sheaf card](../../knowledge-base/algebraic-geometry/sheaf-cohomology.en.md) or [Grassmannian card](../../knowledge-base/algebraic-geometry/grassmannian-plucker.en.md) is insufficient. Ordinary graph Laplacians or matrix decompositions do not require scheme theory.

## Verified chapter routes

| Structure | 2025 location | Check |
|---|---|---|
| Categories, universal properties, adjunctions | Chapter 1 | Objects, morphisms, preserved structure; adjoints are not inverses |
| Sheaves and restrictions | Chapter 2 | Gluing of compatible local sections |
| Grassmannians | §§7.7, 16.4 | Subspace parameterization and moduli meaning |
| Vector bundles and locally free sheaves | Chapter 14 | Trivializations and transition functions |
| Čech cohomology | Chapter 18 | Coefficients, covers, complexes, obstruction classes |
| Derived functors and comparison | Chapter 23 | Conditions for Čech/derived cohomology agreement |
| Flatness | Chapter 24 | Exactness for modules, not ML distribution smoothness |

## Three actionable transfers

**1. Finite cellular-sheaf consistency proxies.** Assign finite-dimensional spaces to vertices/edges. Restrictions form $\delta^0:C^0\to C^1$, so $L=(\delta^0)^T\delta^0$ is PSD and $x^TLx=\|\delta^0x\|^2$. This measures a section residual in the selected model. Global sections are $H^0=\ker\delta^0$; $H^1=\ker\delta^1/\operatorname{im}\delta^0$ is a different object. Neither directly measures hallucination or truth.

**2. Subspace geometry for alignment/compression analysis.** Compare bases using principal angles while distinguishing subspace preservation from token-coefficient preservation. Plücker embedding provides projective coordinates, not a compression guarantee. Matrix reconstruction needs both basis and coefficients; QR does not select a unique subspace representative.

**3. Category language for composition interfaces.** Specify objects, morphisms, composition, and identities; check that a proposed functor preserves composition. Use adjunction/equivalence properties only after establishing them. Pullback/pushforward depend on the category and are not automatically engineering gather/scatter.

## Hypotheses and counterexamples

- A cycle graph with constant coefficients can have $H^1\ne0$ while zero edge data is realized by constant vertex data. A nonzero group does not obstruct every instance.
- Graph restriction networks are finite cellular models, not direct computation of arbitrary scheme-theoretic sheaf cohomology.
- Flatness does not guarantee stable rank for ML feature matrices; first construct an actual module family and valid correspondence.
- Tropical geometry/semirings may warrant a gap investigation; the book supplies no established tropical-gating algorithm. Min/max are differentiable almost everywhere; optional LogSumExp smoothing changes operator semantics.

## Engineering validation

Estimate cost from complex dimension, dimensions of $C^p$, and restriction sparsity, not a blanket $O(N^3)$ in the number of open sets. Time residuals, sparse diffusion, and full rank/cohomology computations separately. Real nullspaces require tolerance/precision analysis; integer/finite-field arithmetic has different bit complexity.

Relaxations, fixed covers, and landmarks are particular approximations with explicit lost guarantees. Small GEMM form does not prove efficiency; a proposed regularizer need not be a differentiable exact topological invariant. Pure theory has no GPU gate.

## Lookup and sources

- [Stacks Čech comparison](https://stacks.math.columbia.edu/tag/01FP) and [H¹/torsors](https://stacks.math.columbia.edu/tag/02FQ) support the definitional boundaries.
- Local `math_book/The Rising Sea Foundations of Algebraic Geometry.pdf` is optional repository input, excluded from the package. Do not search unrelated user directories when an installed package lacks it.
- Cite exact editions, sections, and hypotheses after retrieval; leave inaccessible claims unverified and do not attribute repository AI hypotheses to Vakil.
