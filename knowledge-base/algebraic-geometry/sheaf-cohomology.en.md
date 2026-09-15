# Sheaf Cohomology

## Minimal Definition

A sheaf $\mathcal F$ assigns sections and restriction maps to open sets; compatible local sections glue uniquely. For abelian sheaves, $H^i(X,\mathcal F)=R^i\Gamma(X,\mathcal F)$ derives the global-section functor. Obstruction of current data depends on its particular class, not merely whether the containing group is nonzero.

## Core Formulas

- Čech complex: $C^p(\mathcal U,\mathcal F)=\prod_{i_0<\cdots<i_p}\mathcal F(U_{i_0\cdots i_p})$, with $\delta^{p+1}\delta^p=0$.
- A fixed cover yields $\check H^p(\mathcal U,\mathcal F)=\ker\delta^p/\operatorname{im}\delta^{p-1}$, not unconditionally $H^p(X,\mathcal F)$. The Leray-cover comparison applies when every nonempty finite intersection is acyclic for this sheaf.
- For $f:X\to Y$, the Leray spectral sequence is $E_2^{p,q}=H^p(Y,R^qf_*\mathcal F)\Rightarrow H^{p+q}(X,\mathcal F)$.
- On the usual smooth manifolds, $H^k_{\mathrm{dR}}(M)\cong H^k(M,\underline{\mathbb R})\cong\mathbb H^k(M,\Omega_M^\bullet)$. Here $\mathbb H$ is hypercohomology of a complex, not ordinary cohomology of a single differential-form sheaf.
- Quasi-coherent sheaves on affine schemes have vanishing higher cohomology. Cartan B concerns coherent analytic sheaves on Stein spaces; keep the categories distinct.

## Applicable Problems

- Separate local residuals, global sections, and obstructions to a specified lifting/trivialization problem.
- Model multi-view or graph data with explicit stalks, restrictions, and consistency equations.
- Finite-dimensional cellular sheaves permit linear algebra; general sheaf theory needs an additional computable representation.

## AI Design Translation

- **Consistency proxy:** for graph data $x\in C^0$, $\|\delta^0x\|^2=0$ means that $x$ is a global section of the selected model. It does not mean $H^1=0$.
- **Solvability for given edge data:** $\delta^0x=b$ requires $b\in\operatorname{im}\delta^0$. If $\delta^1b=0$, its obstruction is $[b]\in H^1$; $H^1\ne0$ does not prevent this particular class from vanishing.
- **Minimal counterexample:** a cycle graph with constant real coefficients has nonzero $H^1$, yet $b=0$ is solved by constant node features. A nonzero group does not imply failure of current fusion data.
- Validate the mapping from data to sheaf structure before using it diagnostically; structural consistency proves neither semantic nor factual correctness.

## Engineering Feasibility

- With $n_p=\dim C^p$, finite real complexes admit sparse multiplication, SVD/QR, or linear solves. Costs depend on shapes, nonzero counts, rank, and tolerance, not only the number of covering sets.
- Computing $\|\delta x\|^2$ is often much cheaper than computing cohomology. Differentiable regularization and discrete rank certification are different operations.
- Finite-field elimination, integer Smith normal form, and real rank estimation have different costs and semantics. Integers still incur overflow and bit complexity.
- Near-zero singular values make real Betti-number estimates unstable; bf16 is not a default rank/nullspace certification format.

## Risks and Failure Conditions

- Check $\delta^2=0$, cover/cell definitions, and coefficient field before computing cohomology.
- Approximate covers and landmark sampling need error analysis; higher intersections may grow combinatorially.
- $H^1=0$ eliminates the associated first-order obstruction classes, not every local-to-global problem.
- Changing coefficients can lose torsion; consistency residuals, cohomology, and truth are not interchangeable.

## Further References

- [Book notes](../../references/books/algebraic-geometry-rising-sea.en.md).
- [Stacks: Čech/sheaf comparison](https://stacks.math.columbia.edu/tag/01FP), [de Rham complex](https://stacks.math.columbia.edu/tag/0FL6), and [H¹ and torsors](https://stacks.math.columbia.edu/tag/02FQ).

## Routing Extensions

- Local-to-global: `../../lenses/local-to-global.en.md`.
- Topological diagnostics: `../topology/persistent-homology.en.md`.

## Extensible Directions

Persistent cellular sheaves, Hodge decomposition, Picard groups, and higher obstructions; specify the mathematical object and computational representation before expansion.
