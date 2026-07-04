# Geodesic

## Minimal Definition

A geodesic is a locally length-minimizing (or extremal-length) path $\gamma: [0,1] \to M$ on a manifold, satisfying the auto-parallel condition $\nabla_{\dot\gamma} \dot\gamma = 0$ -- that is, the tangent vector is parallel-transported unchanged along itself. The exponential map $\exp_p(v)$ maps a tangent vector $v \in T_pM$ to the endpoint at $t=1$ of the geodesic starting at $p$ with initial velocity $v$.

## Core Formulas

- Geodesic equation: $\ddot\gamma^k + \sum_{ij} \Gamma^k_{ij} \dot\gamma^i \dot\gamma^j = 0$
- Exponential map: $\exp_p(v) = \gamma_v(1)$, where $\gamma_v$ is the geodesic with $\gamma(0)=p, \dot\gamma(0)=v$
- Logarithmic map: $\log_p(q) = v \in T_pM$ such that $\exp_p(v) = q$ (the inverse of the exponential map)
- Retraction (engineering approximation): $R_p(v) \approx \exp_p(v)$, requiring only a first-order approximation for optimization
- Closed-form on the sphere: $\exp_p(v) = \cos(\|v\|) p + \sin(\|v\|) \frac{v}{\|v\|}$

## Applicable Problems

- Constrained optimization: performing SGD on SPD/Stiefel/Grassmann/hyperbolic manifolds, where update steps must move along geodesics
- Latent space interpolation: geodesics between two points in the latent space respect the data manifold structure better than Euclidean straight lines
- Distance computation on manifolds: $d(p,q) = \|\log_p(q)\|_g$
- Data augmentation: sampling along geodesics to generate new training samples

## AI Design Translation

- **Retraction-based optimizer**: Each step performs $x_{k+1} = R_{x_k}(-\eta \cdot \text{grad})$, using closed-form retractions instead of ODE integration; rotations for the sphere, QR/Cayley for Stiefel, Rodrigues for SO(3)
- **Geodesic interpolation layer**: Use closed-form geodesics in spherical/hyperbolic latent spaces for mixup and interpolation, $\gamma(t) = \exp_p(t \cdot \log_p(q))$
- **Momentum on manifolds**: Transport the momentum vector from $T_{x_k}M$ to $T_{x_{k+1}}M$ via vector transport (the discrete analog of parallel transport), then combine with the new gradient
- **Exponential map output head**: The network makes unconstrained predictions in the tangent space $\mathbb{R}^n$, then projects back to the valid manifold via $\exp_p$, naturally satisfying constraints

## Engineering Feasibility

GPU friendliness depends on whether a closed-form retraction exists:
- **Manifolds with closed forms** (sphere, hyperbolic, SO(3), Stiefel-QR): $\exp_p(v)$ is a finite algebraic expression, $O(1)$/sample, tensorizable in batches, GPU-friendly
- **Manifolds without closed forms**: require numerical integration of the geodesic equation (second-order ODE), serial recurrence, GPU-unfriendly
- Closed-form retractions as substitutes for exact exp: QR decomposition, Cayley transform, and other first-order approximations trade a small amount of precision for significant speedup
- Small-matrix exp for 3x3/4x4 (SO(3)/SE(3)) can be fused into a single kernel, but cannot fully saturate Tensor Cores
- **Low-precision critical issue**: $\sin\theta/\theta$ and $(1-\cos\theta)/\theta^2$ produce division by zero as $\theta \to 0$; $\log$ is singular as $\theta \to \pi$; fp16 yields NaN directly

## Risks and Failure Conditions

- **Step-by-step ODE integration for geodesics**: Serial recurrence kills GPU parallelism; closed-form retractions must be used instead
- **Small-angle / large-angle singularities**: Numerical instability at $\theta \to 0$ and $\theta \to \pi$ is catastrophically amplified at low precision; Taylor expansion fallbacks are essential
- **Retraction error accumulation**: First-order approximations may accumulate errors over multiple iterations, requiring occasional exact projection corrections
- **Cut locus problem**: Beyond the cut locus, the exponential map no longer yields the shortest path; $\log_p(q)$ may not exist or may not be unique
- **Forced manifold structure for geometric aesthetics**: Applying geodesics to tasks where Euclidean approximations suffice adds complexity and singularity risk

## Further References

- Distillation notes: references/books/differential-geometry.md (Ch 13 Section 13.4 Geodesics, Section 13.11 Rauch Comparison)
- Distillation notes: references/books/smooth-manifolds.md (Ch 20 The Exponential Map)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 13.4 Geodesics
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 20 (exponential map, retraction prototype)
