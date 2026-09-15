# Geodesic

## Minimal Definition

A geodesic is a locally length-minimizing (or extremal-length) path $\gamma: [0,1] \to M$ on a manifold, satisfying the auto-parallel condition $\nabla_{\dot\gamma} \dot\gamma = 0$ -- that is, the tangent vector is parallel-transported unchanged along itself. The exponential map $\exp_p(v)$ maps a tangent vector $v \in T_pM$ to the endpoint at $t=1$ of the geodesic starting at $p$ with initial velocity $v$.

## Core Formulas

- Geodesic equation: $\ddot\gamma^k + \sum_{ij} \Gamma^k_{ij} \dot\gamma^i \dot\gamma^j = 0$
- Exponential map: $\exp_p(v) = \gamma_v(1)$, where $\gamma_v$ is the geodesic with $\gamma(0)=p, \dot\gamma(0)=v$
- Logarithmic map: $\log_p(q)$ is the local inverse of exp_p in a normal neighborhood; a unique global inverse cannot be assumed across branches or a cut locus.
- Retraction: $R_p(0)=p$, $DR_p(0)=\mathrm{id}_{T_pM}$, with manifold-valued output. This is local first-order agreement, not a Banach contraction.
- Sphere of radius $r>0$: $\exp_p(v)=\cos(\|v\|/r)p+r\sin(\|v\|/r)v/\|v\|$, with $\|p\|=r$, $p^Tv=0$; use the continuous limit $p$ at $v=0$.

## Applicable Problems

- Constrained optimization: a valid retraction can replace exact geodesic steps; match the update to its metric and convergence assumptions.
- Latent space interpolation: geodesics between two points in the latent space respect the data manifold structure better than Euclidean straight lines
- Manifold distance: $d(p,q)=\|\log_p(q)\|_g$ requires a minimizing geodesic branch reaching q.
- Data augmentation: sampling along geodesics to generate new training samples

## AI Design Translation

- **Retraction-based optimizer**: Each step performs $x_{k+1} = R_{x_k}(-\eta \cdot \text{grad})$, using closed-form retractions instead of ODE integration; rotations for the sphere, QR/Cayley for Stiefel, Rodrigues for SO(3)
- **Geodesic interpolation layer**: Use closed-form geodesics in spherical/hyperbolic latent spaces for mixup and interpolation, $\gamma(t) = \exp_p(t \cdot \log_p(q))$
- **Momentum on manifolds**: Transport the momentum vector from $T_{x_k}M$ to $T_{x_{k+1}}M$ via vector transport (the discrete analog of parallel transport), then combine with the new gradient
- **Exponential map output head**: The network makes unconstrained predictions in the tangent space $\mathbb{R}^n$, then projects back to the valid manifold via $\exp_p$, naturally satisfying constraints

## Engineering Feasibility

GPU friendliness depends on whether a closed-form retraction exists:
- **Closed forms/finite algebraic steps**: sphere exp costs $O(n)$; Stiefel-QR is a retraction, typically $O(np^2)$, not an exp or constant-cost operation. SO(3) group exp equals Riemannian exp only for appropriate metrics.
- **Manifolds without closed forms**: require numerical integration of the geodesic equation (second-order ODE), serial recurrence, GPU-unfriendly
- Closed-form retractions as substitutes for exact exp: QR decomposition, Cayley transform, and other first-order approximations trade a small amount of precision for significant speedup
- Small-matrix exp for 3x3/4x4 (SO(3)/SE(3)) can be fused into a single kernel, but cannot fully saturate Tensor Cores
- **Numerical branches**: sinθ/θ has a removable zero-angle singularity; SO(3) Log near π needs separate axis/branch handling, not a zero-angle Taylor fallback.

## Risks and Failure Conditions

- **ODE costs**: an exact geodesic-distance task cannot replace exp by an arbitrary retraction; optimization may compare retraction costs and convergence conditions with ODE integration.
- **Numerical branches**: use Taylor/sinc near zero; near cut loci handle log branches and nonuniqueness, which small-angle Taylor expansions cannot remove.
- **Retraction error**: valid retractions remain on the manifold at every exact-arithmetic step; local deviation from exp is not constraint drift. Measure floating-point constraint residuals separately.
- **Cut locus**: beyond the cut time along a direction a geodesic loses minimality; a minimizing log may be nonunique at the cut locus. $d(p,q)=\|\log_pq\|$ requires a minimizing branch.
- **Forced manifold structure for geometric aesthetics**: Applying geodesics to tasks where Euclidean approximations suffice adds complexity and singularity risk

## Further References

- Distillation notes: ../../references/books/differential-geometry.en.md (Ch 13 Section 13.4 Geodesics, Section 13.11 Rauch Comparison)
- Distillation notes: ../../references/books/smooth-manifolds.en.md (Ch 20 The Exponential Map)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 13.4 Geodesics
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 20 (exponential map, retraction prototype)


## Routing Extensions
- If the distance definition is needed -> `metric-tensor.en.md` (metric tensor determines geodesics)
- For optimization updates → `../optimization/riemannian-optimization.en.md` (retractions and convergence conditions).
- If deviation from flat space is needed -> `curvature.en.md` (curvature controls geodesic deviation)

## Extensible Directions
- Conjugate points: zeros of Jacobi fields along geodesics
- Cut locus: critical points where geodesics lose optimality
- Hopf-Rinow theorem: completeness and geodesic existence
- Geodesic convexity: convex sets and convex functions on manifolds
- Jacobi field: linearization of geodesic variation
- Geodesic regression: regression analysis on manifolds
