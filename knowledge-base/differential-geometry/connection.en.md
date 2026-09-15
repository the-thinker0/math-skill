# Connection

## Minimal Definition

An affine connection defines covariant differentiation ∇_X Y. It is C∞(M)-linear in X, real-linear in Y, and satisfies ∇_X(fY)=X(f)Y+f∇_X Y. Its parallel-transport equation compares vectors along a chosen curve. For a specified Riemannian metric, Levi-Civita is the unique metric-compatible torsion-free connection; a general connection need not preserve lengths or angles.

## Core Formulas

- Covariant derivative: $\nabla_X Y = \left(X^i \partial_i Y^k + X^i Y^j \Gamma^k_{ij}\right) \partial_k$
- Christoffel symbols (Levi-Civita): $\Gamma^k_{ij} = \frac{1}{2} g^{kl}(\partial_i g_{jl} + \partial_j g_{il} - \partial_l g_{ij})$
- Parallel transport equation: $\frac{D V^k}{dt} = \dot V^k + \Gamma^k_{ij} \dot\gamma^i V^j = 0$
- Connection form (on a principal bundle): $\omega \in \Omega^1(P, \mathfrak{g})$; the gauge field $A_\mu$ is a local connection form
- Curvature = non-commutativity of the connection: $R(X,Y) = [\nabla_X, \nabla_Y] - \nabla_{[X,Y]}$

## Applicable Problems

- Cross-point vector comparison: tangent spaces at different points cannot be directly summed; a connection specifies the "transport rule"
- Optimization momentum can use a suitable vector transport; exact parallel transport is not required at every step.
- Gauge-equivariant networks: the freedom in choosing local coordinate frames (gauges) is aligned by the connection
- Physically constrained systems: the electromagnetic field equals the curvature of a U(1) connection; Yang-Mills equals the curvature of a non-Abelian connection

## AI Design Translation

- **Vector transport module**: In Riemannian optimizers, transport the momentum $m_k \in T_{x_k}M$ to $T_{x_{k+1}}M$; closed-form transport (e.g., projection on the Stiefel manifold) can be expressed as GEMM
- **Gauge-equivariant CNN**: local-frame changes transform both features and edge transports; kernels obey intertwiner constraints. Intermediate features are not automatically invariant.
- **Parallel transport regularization**: Penalize non-parallelism of the feature field under the connection $\|\nabla_X f\|^2$, enforcing smooth feature variation along the manifold
- **Connection learning**: parameterize coefficients within a chart, but enforce the non-tensorial Christoffel transformation law across charts. For Levi-Civita, derive from a metric or enforce torsion-free metric compatibility.

## Engineering Feasibility

GPU friendliness: the core challenge of connections is "serial ODE integration."
- **Closed-form/approximate vector transport**: depends on manifold, metric, and path; Stiefel tangent-projection transport is generally not exact parallel transport.
- **Parallel transport for general connections**: integrating $\dot{V} + \Gamma \dot\gamma V = 0$ along a curve is a serial ODE with poor parallelism
- **Christoffel computation**: all coefficients require $O(n^3)$ storage entries; computation additionally depends on metric derivatives and solves. Prefer required contractions to materializing every coefficient.
- **Connections in gauge-equivariant CNNs**: one $G$-element action per edge (matrix-times-feature-vector), expressible as sparse matmul or batched small GEMM
- Optimizer updates may combine a retraction with suitable vector transport. Retractions move points and transports move tangent vectors; they are not interchangeable.

## Risks and Failure Conditions

- **ODE integration cost**: approximation depends on accuracy requirements. Closed-form or approximate vector transport is an optimizer choice, not a substitute for every exact parallel-transport task.
- **Inconsistent left/right connection conventions**: Mixing left-invariant and right-invariant connections leads to misaligned gradients
- **Improper handling of gauge freedom**: If the connection parameterization in gauge-equivariant networks is incomplete, equivariance silently breaks
- **Numerical derivatives of Christoffel symbols**: Finite-difference estimation of $\partial_i g_{jk}$ is noisy; analytical formulas or autodiff are preferable
- **Connection does not imply metric compatibility**: A connection need not admit a compatible metric (non-metric connections); incorrectly assuming compatibility leads to inconsistencies

## Further References

- Distillation notes: ../../references/books/differential-geometry.en.md (Ch 12 Connections and Covariant Derivatives, Section 12.2 Connection Forms, Section 12.4 Ehresmann, Section 12.12 G-Connections)
- Distillation notes: ../../references/books/differential-geometry.en.md (Section 6.8 Principal Bundles, Section 9.8 Electromagnetism)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 12 (Section 12.1--Section 12.12, complete connection theory)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 13.1 Levi-Civita Connection


## Routing Extensions
- If curvature definition is needed -> `curvature.en.md` (curvature tensor derived from connection)
- If parallel transport and geodesics are needed -> `geodesic.en.md` (geodesics are auto-parallel curves of parallel transport)
- If covariant derivative computation is needed -> `tangent-space.en.md` (covariant differentiation on tangent space)

## Extensible Directions
- Levi-Civita connection: unique torsion-free metric connection on Riemannian manifolds
- Christoffel symbols: connection components in coordinate basis
- Holonomy: effect of parallel transport around closed curves
- Torsion: antisymmetric part of a connection
- Affine connection: general affine connection theory
- Ehresmann connection: horizontal distributions on fiber bundles
- Gauge connection: gauge fields as connections in physics
