# Lie Algebra

## Minimal Definition

The Lie algebra $\mathfrak{g}$ is the tangent space $T_e G$ of a Lie group $G$ at the identity element $e$, equipped with a Lie bracket $[\cdot, \cdot]: \mathfrak{g} \times \mathfrak{g} \to \mathfrak{g}$ satisfying bilinearity, antisymmetry, and the Jacobi identity. It is the linear space of "infinitesimal generators" -- locally linearizing the curved, nonlinear group into a flat vector space.

## Core Formulas

- Lie bracket: $[X, Y] = XY - YX$ (for matrix groups), satisfying $[X,[Y,Z]] + [Y,[Z,X]] + [Z,[X,Y]] = 0$
- $\text{so}(3)$: skew-symmetric matrices, $[\omega]_\times = \begin{pmatrix} 0 & -\omega_3 & \omega_2 \\ \omega_3 & 0 & -\omega_1 \\ -\omega_2 & \omega_1 & 0 \end{pmatrix}$
- hat/vee operators: $\hat{\cdot}: \mathbb{R}^n \to \mathfrak{g}$ (vector to skew-symmetric matrix), $\check{\cdot}: \mathfrak{g} \to \mathbb{R}^n$ (inverse)
- Baker-Campbell-Hausdorff formula: $\log(\exp(X)\exp(Y)) = X + Y + \frac{1}{2}[X,Y] + \cdots$
- Adjoint representation: $\text{ad}_X(Y) = [X,Y]$, which is the differential of $\text{Ad}$

## Applicable Problems

- Local linearization of rotations/poses: approximate nonlinear group variations in a small neighborhood using Lie algebra vectors $\delta \in \mathbb{R}^n$
- Reparameterization for constrained optimization: convert orthogonality/rotation constraints into unconstrained Lie algebra parameters + exp map
- Infinitesimal description of symmetries: continuous symmetry groups are fully characterized by a small set of generators
- Error-state estimation: covariances are defined on the tangent space $\mathbb{R}^n$ rather than on the group

## AI Design Translation

- **Lie algebra parameterization layer**: The network outputs $\delta \in \mathbb{R}^3$ (so(3)), then applies $\exp$ to obtain a valid rotation matrix; replaces quaternion normalization or 6D representations
- **Error-state EKF/optimization layer**: Parameterize the error around a nominal state $X$ as $\delta \in \mathfrak{g}$ with $X_{\text{true}} = X \oplus \delta$; Kalman filtering proceeds in the linear tangent space
- **Lie bracket regularization**: Penalize $[\xi_i, \xi_j] \neq 0$ to constrain the commutativity of generators, or use as a symmetry consistency loss
- **Generator learning**: Learn a Lie algebra basis $\{E_1, \ldots, E_n\}$ as trainable parameters, enabling data-driven symmetry discovery

## Engineering Feasibility

High GPU friendliness. The core advantage of the Lie algebra is that it is a "linear space":
- **hat/vee maps**: Pure index operations + sign flips, $O(n)$, perfectly GPU-friendly
- **Lie bracket $[X,Y] = XY - YX$**: Two small matrix multiplications + subtraction, $O(n^3)$ for small matrices, batchable
- **Linear combination $\sum c_i E_i$**: Vector addition + scalar multiplication, $O(nd)$, perfectly GPU-friendly
- **BCH approximation**: The first few terms suffice for engineering precision; $[X,Y]$ computation is a small matrix multiplication
- Main cost lies in $\exp$ rather than algebra operations: algebra operations are all linear; the bottleneck is the subsequent exp map

## Risks and Failure Conditions

- **BCH series truncation error**: Higher-order terms are non-negligible at large angles; the first-order approximation $X+Y$ is valid only for small perturbations
- **Misinterpreting non-zero Lie brackets**: $[X,Y] \neq 0$ for non-commutative groups means group composition is order-sensitive; operations cannot be freely interchanged
- **Basis selection affects optimization**: The choice of Lie algebra basis is not unique; poor conditioning leads to optimization difficulties
- **Using the Lie algebra as global coordinates**: The exp map is only a local diffeomorphism; global coverage requires multiple charts (an atlas)
- **Inconsistent left/right conventions**: Right Jacobian vs. left Jacobian, local vs. global frame -- inconsistency leads to misaligned gradients and covariances

## Further References

- Distillation notes: references/books/micro-lie-theory.md (Section II-C Tangent Space and Lie Algebra, hat/vee operators)
- Distillation notes: references/books/differential-geometry.md (Ch 5 Lie Groups, Lie algebra section)
- Original text: Joan Sola et al., *A micro Lie theory*, Section II-C (Lie algebra definition and hat/vee), Section II-D (exp/log bridge)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 5 (Lie groups and Lie algebras)


## Routing Extensions
- If the corresponding global group is needed -> `lie-group.md` (integrating Lie algebra yields Lie group)
- If algebra representations are needed -> `representation.md` (representation theory of Lie algebras)
- If acting as the tangent space of a group -> `tangent-space.md` (Lie algebra structure on tangent space)

## Extensible Directions
- Structure constants: components of Lie bracket in a basis
- Jacobi identity: fundamental axiom of Lie algebras
- Ideal / subalgebra: substructures of Lie algebras
- Nilpotent / solvable / semisimple classification: structure theorems for Lie algebras
- Killing form: invariant bilinear form of Lie algebras
- Cartan subalgebra: maximal toral subalgebra of semisimple Lie algebras
- Root system: root system classification of semisimple Lie algebras
