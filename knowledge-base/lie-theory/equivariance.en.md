# Equivariance

## Minimal Definition

A map $f: X \to Y$ is equivariant with respect to the action of a group $G$ if $f(g \cdot x) = g \cdot f(x)$ holds for all $g \in G, x \in X$. Equivariance is a finer structure-preserving property than invariance ($f(g \cdot x) = f(x)$): the output "co-moves" with the input under the same group action.

## Core Formulas

- Equivariance condition: $f(\rho_X(g) x) = \rho_Y(g) f(x), \quad \forall g \in G$
- Invariance = equivariance to the trivial representation: $f(g \cdot x) = f(x)$ ($\rho_Y = \text{id}$)
- Translation equivariance of convolution: $f(T_a x) = T_a f(x)$, where $T_a$ is the translation operator
- Gauge equivariance: $f_{A^g}(\rho_X(g)x)=\rho_Y(g)f_A(x)$, transforming both features and connection. Discrete transports obey $T_{ij}\mapsto g_iT_{ij}g_j^{-1}$.
- Conjugation equivariance of exp: $\exp(\operatorname{Ad}_g\xi)=g\exp(\xi)g^{-1}$; this is not a property of arbitrary $f$.

## Applicable Problems

- 3D point clouds/molecules: when the input is rotated, the output (segmentation/forces/pose) should rotate accordingly
- Signal processing on spheres/manifolds: the choice of local coordinates should not affect prediction results
- Multi-view/multi-sensor: when camera orientation changes, features should covary rather than require relearning
- Physical simulation: vector quantities such as forces and velocities should rotate correctly under coordinate transformations

## AI Design Translation

- **E(n)-equivariant GNN**: $x_i\mapsto x_i+\sum_j\phi(r_{ij})(x_i-x_j)$ is equivariant when coefficients depend on invariant scalars such as distances and adjacency/aggregation are compatible. Arbitrary directional coefficients do not share this guarantee.
- **Gauge-equivariant CNN**: edge transports and features follow local-frame transformation laws; kernels satisfy intertwiner constraints. Intermediate features are usually equivariant, with invariant readouts constructed separately.
- **Steerable CNN**: Feature fields are direct sums of group representations $\bigoplus_l \rho_l$; convolution kernels are constrained by Schur's lemma to block structure, yielding few parameters with strict equivariance
- **Pose output head**: distinguish left-action equivariance $f(gX)=g f(X)$ from conjugation equivariance. Exp alone does not guarantee left-equivariant pose prediction; prove the complete encoding/action/output construction.
- **Equivariance verification loss**: $L_{\text{eq}} = \|f(g \cdot x) - g \cdot f(x)\|^2$ as an auxiliary regularizer, enforcing approximate equivariance

## Engineering Feasibility

GPU friendliness depends on the degree of group discretization:
- **Discrete groups ($C_n$, octahedral group, etc.)**: Group convolution can be expanded into GEMM; equivariance constraints block-diagonalize weights (reducing parameters), GPU-friendly
- **Translation group (CNN)**: stride-one convolution on infinite/periodic grids with compatible boundaries is translation equivariant. Padding, subsampling and finite cropping change the set of translations covered by the guarantee.
- **SO(3)/SE(3)**: harmonic representations are one option; invariant scalar coefficients with relative vectors also construct equivariant layers. Continuous groups do not require discrete enumeration.
- **Gauge-equivariant**: One $G$-element action per edge equals small matrix-times-feature-vector, expressible as sparse matmul
- **Approximate equivariance (regularization)**: The equivariance loss $L_{\text{eq}}$ is a standard MSE, fully GPU-friendly, but equivariance is not exact
- Key trade-off: strict equivariance (structural constraints) vs. approximate equivariance (regularization) -- the former has fewer parameters but complex implementation, the latter is simple but not guaranteed

## Risks and Failure Conditions

- **Continuous group discretization error**: Improper sampling causes equivariance to silently break, passing verification but failing at inference
- **Equivariance-expressiveness trade-off**: Strict equivariance constraints reduce the parameter space, potentially insufficient for fitting complex functions
- **Combinatorial explosion of multiple group actions**: Simultaneously requiring rotation + translation + permutation equivariance leads to complex cross-constraints
- **Data noise breaking equivariance**: Sensor noise makes the exact computation of $g \cdot x$ unreliable, invalidating the equivariance premise
- **Numerical precision in equivariant layers**: Floating-point errors in spherical harmonics/CG coefficients at large $l$ break equivariance, requiring fp32 accumulation
- **Over-constraining with equivariance**: When a task only requires approximate symmetry, enforcing strict equivariance is inferior to using soft regularization constraints

## Further References

- Distillation notes: ../../references/books/micro-lie-theory.en.md (Section II-F Adjoint $\text{Ad}_X$, algebraic realization of equivariance)
- Distillation notes: ../../references/books/differential-geometry.en.md (Section 6.8 Principal Bundles, Section 12.12 G-Connections, gauge equivariance)
- Distillation notes: ../../references/books/differential-geometry.en.md (Ch 5 Lie Groups, continuous symmetry as prior)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 6.8 + Section 12.12 (geometric foundations of gauge equivariance)


## Routing Extensions
- If representation theory foundations are needed -> `representation.en.md` (equivariant maps are morphisms between representations)
- If group action structure is needed -> `group-action.en.md` (equivariance definition depends on group action)
- If used for attention mechanism design -> `equivariant-attention` (design pattern layer for equivariant attention)

## Extensible Directions
- Steerable features: steerable feature representations under SO(3)
- Spherical harmonics: basis functions for SO(3) irreducible representations
- Wigner D-matrices: matrix elements of SO(3) representations
- Equivariant map algebra: complete characterization of equivariant linear maps
- Universal equivariant architectures: universal approximation of equivariant functions
- Symmetry breaking: approximate equivariance or controlled symmetry breaking
- Approximate equivariance: approximate equivariance under noise or discretization
