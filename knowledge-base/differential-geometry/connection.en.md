# Connection

## Minimal Definition

A connection $\nabla$ is a rule specifying "how to transport a vector along a curve from one point to another without extraneous rotation." Formally, $\nabla: \mathfrak{X}(M) \times \mathfrak{X}(M) \to \mathfrak{X}(M)$ satisfies the Leibniz rule. The Levi-Civita connection is the unique connection that is metric-compatible ($\nabla g = 0$) and torsion-free ($T = 0$).

## Core Formulas

- Covariant derivative: $\nabla_X Y = \left(X^i \partial_i Y^k + X^i Y^j \Gamma^k_{ij}\right) \partial_k$
- Christoffel symbols (Levi-Civita): $\Gamma^k_{ij} = \frac{1}{2} g^{kl}(\partial_i g_{jl} + \partial_j g_{il} - \partial_l g_{ij})$
- Parallel transport equation: $\frac{D V^k}{dt} = \dot V^k + \Gamma^k_{ij} \dot\gamma^i V^j = 0$
- Connection form (on a principal bundle): $\omega \in \Omega^1(P, \mathfrak{g})$; the gauge field $A_\mu$ is a local connection form
- Curvature = non-commutativity of the connection: $R(X,Y) = [\nabla_X, \nabla_Y] - \nabla_{[X,Y]}$

## Applicable Problems

- Cross-point vector comparison: tangent spaces at different points cannot be directly summed; a connection specifies the "transport rule"
- Momentum/state transport in optimization: historical gradients in Riemannian Adam must be carried across steps via parallel transport
- Gauge-equivariant networks: the freedom in choosing local coordinate frames (gauges) is aligned by the connection
- Physically constrained systems: the electromagnetic field equals the curvature of a U(1) connection; Yang-Mills equals the curvature of a non-Abelian connection

## AI Design Translation

- **Vector transport module**: In Riemannian optimizers, transport the momentum $m_k \in T_{x_k}M$ to $T_{x_{k+1}}M$; closed-form transport (e.g., projection on the Stiefel manifold) can be expressed as GEMM
- **Gauge-equivariant CNN**: On manifolds/meshes, each edge carries a $G$-connection element that aligns the local frames of adjacent points, making convolution kernels invariant to local coordinate choices
- **Parallel transport regularization**: Penalize non-parallelism of the feature field under the connection $\|\nabla_X f\|^2$, enforcing smooth feature variation along the manifold
- **Connection learning parameterization**: Parameterize Christoffel symbols as neural network outputs, learning the "optimal transport rule" on the data manifold

## Engineering Feasibility

GPU friendliness: the core challenge of connections is "serial ODE integration."
- **Closed-form parallel transport** (specific manifolds such as SO(3), Stiefel): single-step matrix operations, batchable, GPU-friendly
- **Parallel transport for general connections**: integrating $\dot{V} + \Gamma \dot\gamma V = 0$ along a curve is a serial ODE with poor parallelism
- **Christoffel symbol computation**: involves partial derivatives of the metric $g$ and $g^{-1}$; if $g$ has a closed form, $O(n^3)$; otherwise more expensive
- **Connections in gauge-equivariant CNNs**: one $G$-element action per edge (matrix-times-feature-vector), expressible as sparse matmul or batched small GEMM
- Key adaptation: use a single-step retraction/closed-form transport instead of step-by-step ODE integration

## Risks and Failure Modes

- **Step-by-step ODE integration for parallel transport**: Serial recurrence kills parallelism; closed-form transport or single-step approximations must be used
- **Inconsistent left/right connection conventions**: Mixing left-invariant and right-invariant connections leads to misaligned gradients
- **Improper handling of gauge freedom**: If the connection parameterization in gauge-equivariant networks is incomplete, equivariance silently breaks
- **Numerical derivatives of Christoffel symbols**: Finite-difference estimation of $\partial_i g_{jk}$ is noisy; analytical formulas or autodiff are preferable
- **Connection does not imply metric compatibility**: A connection need not admit a compatible metric (non-metric connections); incorrectly assuming compatibility leads to inconsistencies

## Further References

- Distillation notes: references/books/differential-geometry.md (Ch 12 Connections and Covariant Derivatives, Section 12.2 Connection Forms, Section 12.4 Ehresmann, Section 12.12 G-Connections)
- Distillation notes: references/books/differential-geometry.md (Section 6.8 Principal Bundles, Section 9.8 Electromagnetism)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 12 (Section 12.1--Section 12.12, complete connection theory)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 13.1 Levi-Civita Connection
