# Tangent Space

## Minimal Definition

The tangent space $T_pM$ is the $n$-dimensional vector space of all tangent vectors to a manifold $M$ at a point $p$, serving as the local linearization of the manifold. The differential (pushforward) of a smooth map $f: M \to N$ at $p$, denoted $df_p: T_pM \to T_{f(p)}N$, is a linear map between tangent spaces.

## Core Formulas

- Tangent vector as a derivation: $v(f) = \sum_i v^i \frac{\partial f}{\partial x^i}\bigg|_p$
- Pushforward (differential): $df_p: T_pM \to T_{f(p)}N$, with coordinate representation given by the Jacobian matrix $J_f(p)$
- Tangent bundle: $TM = \bigsqcup_{p \in M} T_pM$
- Cotangent space (the true gradient): $df \in T_p^*M$, which requires the metric to raise the index via $\sharp$ to obtain a tangent vector

## Applicable Problems

- Geometric interpretation of backpropagation: the chain rule equals pullback on the cotangent bundle, i.e., VJP (vector-Jacobian product) = pullback of covectors $df_p^*(\omega) = J^T \omega$. Note: pushforward corresponds to JVP (forward-mode AD), not backpropagation
- Correct gradient direction computation: autodiff outputs are covectors (1-forms), requiring a metric to convert them into descent directions
- Gradient projection in constrained optimization: projecting the Euclidean gradient onto the tangent space of the constraint submanifold
- Linearized approximations on manifolds: using linear methods within the tangent space to handle local problems

## AI Design Translation

- **Natural gradient layer**: $\tilde{\nabla} L = g^{-1} \nabla L$, using the Fisher metric to raise the covector (autodiff output) to a tangent vector, invariant under reparameterization
- **Tangent space projection module**: Under orthogonality/Stiefel constraints, project the gradient onto the tangent space $W\Omega$ (where $\Omega$ is skew-symmetric) to maintain constraints
- **Jacobian-vector product (JVP) acceleration**: The pushforward $df_p(v)$ naturally corresponds to the JVP, serving as the geometric prototype for forward-mode AD
- **Tangent space feature representation**: In manifold optimization, store momentum/historical gradients in the tangent space and transport them across points via vector transport

## Engineering Feasibility

High GPU friendliness. The core operations of the tangent space are linear algebra:
- Pushforward $df_p(v) = Jv$: matrix-vector multiplication, $O(n^2)$, naturally batched GEMM
- Pullback $df_p^*(\omega) = J^T \omega$: transposed matrix-vector multiplication, which is backpropagation itself
- Tangent space projection $P = I - WW^T$ (Stiefel): a chain of matrix multiplications, GPU-friendly
- Metric index raising $g^{-1}\nabla L$: depends on the structure of $g$ -- diagonal/Kronecker-factored yields $O(n)$ to $O(n^2)$, full matrix $O(n^3)$ is infeasible

## Risks and Failure Conditions

- **Confusing gradient with descent direction**: Forgetting the metric index-raising and directly using the raw autodiff output (covector) as a descent direction (tangent vector) leads to incorrect directions in curved spaces
- **Large matrix inversion**: Natural gradients require $g^{-1}$; the full Fisher matrix $O(N^3)$ is infeasible and necessitates Kronecker/block-diagonal/low-rank factorization
- **Confusing tangent space with the ambient space**: Performing tangent-space vector addition directly on a curved manifold ignores nonlinear deviations caused by curvature
- **Missing vector transport**: Tangent spaces at different points cannot be directly summed; momentum/Adam states require parallel transport to be carried across steps

## Further References

- Distillation notes: ../../references/books/smooth-manifolds.en.md (Ch 3 Tangent Vectors, Ch 11 The Cotangent Bundle)
- Distillation notes: ../../references/books/differential-geometry.en.md (Ch 1-2, Ch 7 Tensors)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition, Ch 3 (tangent spaces, pushforward, tangent bundle)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 11 (cotangent bundle, 1-forms, pullback)


## Routing Extensions
- If gradient computation on manifolds is needed -> `riemannian-optimization.md` (gradient descent on manifolds)
- If the tangent space of a group structure is involved -> `lie-algebra.md` (tangent space of a Lie group is its Lie algebra)
- If covariant derivative is needed -> `connection.en.md` (connection defines covariant differentiation)

## Extensible Directions
- Cotangent space: dual space and differential forms
- Differential / pushforward: tangent map of smooth maps
- Vector field: smooth vector fields on manifolds
- Lie bracket: commutation relations of vector fields
- Integral curve: integral curves and flows of vector fields
- Exponential map: mapping from tangent space to manifold
