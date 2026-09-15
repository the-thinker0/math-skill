# Tangent Space

## Minimal Definition

The tangent space $T_pM$ is the $n$-dimensional vector space of all tangent vectors to a manifold $M$ at a point $p$, serving as the local linearization of the manifold. The differential (pushforward) of a smooth map $f: M \to N$ at $p$, denoted $df_p: T_pM \to T_{f(p)}N$, is a linear map between tangent spaces.

## Core Formulas

- Tangent vector as a derivation: $v(f) = \sum_i v^i \frac{\partial f}{\partial x^i}\bigg|_p$
- Pushforward (differential): $df_p: T_pM \to T_{f(p)}N$, with coordinate representation given by the Jacobian matrix $J_f(p)$
- Tangent bundle: $TM = \bigsqcup_{p \in M} T_pM$
- Cotangent space: a scalar function has differential $df_p\in T_p^*M$; the gradient $\operatorname{grad}_g f=(df)^\sharp$ is a tangent vector.

## Applicable Problems

- Geometric interpretation of backpropagation: the chain rule equals pullback on the cotangent bundle, i.e., VJP (vector-Jacobian product) = pullback of covectors $df_p^*(\omega) = J^T \omega$. Note: pushforward corresponds to JVP (forward-mode AD), not backpropagation
- Correct gradient direction computation: autodiff outputs are covectors (1-forms), requiring a metric to convert them into descent directions
- Gradient projection in constrained optimization: projecting the Euclidean gradient onto the tangent space of the constraint submanifold
- Linearized approximations on manifolds: using linear methods within the tangent space to handle local problems

## AI Design Translation

- **Natural gradient layer**: $\tilde{\nabla} L = g^{-1} \nabla L$, using the Fisher metric to raise the covector (autodiff output) to a tangent vector, invariant under reparameterization
- **Tangent space projection module**: for $W\in\mathrm{St}(n,p)$, tangents satisfy $W^TZ+Z^TW=0$; $W\Omega$ alone misses complement directions. Under the embedded Euclidean metric, projection is $Z-W\operatorname{sym}(W^TZ)$.
- **Jacobian-vector product (JVP) acceleration**: The pushforward $df_p(v)$ naturally corresponds to the JVP, serving as the geometric prototype for forward-mode AD
- **Tangent space feature representation**: In manifold optimization, store momentum/historical gradients in the tangent space and transport them across points via vector transport

## Engineering Feasibility

High GPU friendliness. The core operations of the tangent space are linear algebra:
- Pushforward/JVP: an explicit m×n Jacobian costs $O(mn)$ to apply. Automatic differentiation usually avoids materializing it; cost follows the original computation graph.
- Pullback $df_p^*(\omega) = J^T \omega$: transposed matrix-vector multiplication, which is backpropagation itself
- Tangent projection: $\Pi_W(Z)=Z-W\operatorname{sym}(W^TZ)$ costs $O(np^2)$; $(I-WW^T)Z$ is a Grassmann horizontal projection, not the full Stiefel tangent projection.
- Metric index raising: diagonal solves cost $O(n)$; dense factorization typically $O(n^3)$ followed by $O(n^2)$ per solve. Matrix-free cost depends on product cost and iteration count.

## Risks and Failure Conditions

- **Confusing gradient with descent direction**: Forgetting the metric index-raising and directly using the raw autodiff output (covector) as a descent direction (tangent vector) leads to incorrect directions in curved spaces
- **Large metric solves**: obtain the action $g^{-1}df$, not necessarily an explicit inverse. Matrix-free products with iterative solves or structured approximations are alternatives; check conditioning and residuals.
- **Confusing tangent space with the ambient space**: Performing tangent-space vector addition directly on a curved manifold ignores nonlinear deviations caused by curvature
- **Missing vector transport**: Tangent spaces at different points cannot be directly summed; momentum needs a suitable vector transport, not necessarily exact parallel transport; Adam second moments need their own representation and update convention

## Further References

- Distillation notes: ../../references/books/smooth-manifolds.en.md (Ch 3 Tangent Vectors, Ch 11 The Cotangent Bundle)
- Distillation notes: ../../references/books/differential-geometry.en.md (Ch 1-2, Ch 7 Tensors)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition, Ch 3 (tangent spaces, pushforward, tangent bundle)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 11 (cotangent bundle, 1-forms, pullback)


## Routing Extensions
- If gradient computation on manifolds is needed -> `../optimization/riemannian-optimization.en.md` (gradient descent on manifolds)
- If the tangent space of a group structure is involved -> `../lie-theory/lie-algebra.en.md` (the tangent space at the identity, with its Lie bracket, is the Lie algebra)
- If covariant derivative is needed -> `connection.en.md` (connection defines covariant differentiation)

## Extensible Directions
- Cotangent space: a scalar function has differential $df_p\in T_p^*M$; the gradient $\operatorname{grad}_g f=(df)^\sharp$ is a tangent vector.
- Differential / pushforward: tangent map of smooth maps
- Vector field: smooth vector fields on manifolds
- Lie bracket: commutation relations of vector fields
- Integral curve: integral curves and flows of vector fields
- Exponential map: mapping from tangent space to manifold
