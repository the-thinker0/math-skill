# Lie Group

## Minimal Definition

A Lie group $G$ is a space endowed with both a smooth manifold structure and a group structure, such that group multiplication $\mu: G \times G \to G$ and inversion $\iota: G \to G$ are smooth maps. It is the precise mathematical object of "continuous symmetry transformation groups" -- simultaneously a differentiable space and a multiplicative algebra.

## Core Formulas

- Exponential map: $\exp: \mathfrak{g} \to G$, $\exp(\xi) = \gamma_\xi(1)$, where $\gamma_\xi$ is the one-parameter subgroup
- SO(3) Rodrigues formula: $\exp([\theta]_\times) = I + \frac{\sin\|\theta\|}{\|\theta\|}[\theta]_\times + \frac{1-\cos\|\theta\|}{\|\theta\|^2}[\theta]_\times^2$
- SE(3): $\exp\begin{pmatrix} [\omega]_\times & v \\ 0 & 0 \end{pmatrix} = \begin{pmatrix} \exp([\omega]_\times) & V(\theta)v \\ 0 & 1 \end{pmatrix}$
- $\oplus/\ominus$ operators (right version): $X \oplus \tau = X \cdot \exp(\tau)$, $X \ominus Y = \log(Y^{-1} X)$
- Adjoint map: $\text{Ad}_X(\tau) = X \tau X^{-1}$ (for matrix groups), satisfying $X \oplus \tau = (\text{Ad}_X \tau) \oplus X$

## Applicable Problems

- Predictions/regression targets carry geometric constraints: rotations, poses, unit quaternions -- forcing them into a Euclidean MLP violates constraints
- Equivariance/invariance is required: when the input undergoes a rigid-body transformation, the output should covary or remain invariant (point clouds, molecules, multi-view geometry)
- State evolves on a Lie group: inertial preintegration, motion models, differentiable physics/control
- Orthogonal/unitary constraints on weight matrices: optimization on the Stiefel manifold

## AI Design Translation

- **Manifold-parameterized output head**: The network makes unconstrained predictions in the tangent space $\mathbb{R}^n$, then projects back to SO(3)/SE(3) via $\exp$, replacing the ad-hoc orthogonalization of 6D/9D rotation representations
- **Manifold loss function**: Use $\ominus$ (geodesic error) as the loss, $L = \|X_{\text{pred}} \ominus X_{\text{gt}}\|^2$, naturally handling manifold topology
- **Lie group RNN/ODE**: Hidden state $h_t \in G$, updated as $h_{t+1} = h_t \oplus f_\theta(h_t, x_t) = h_t \cdot \exp(f_\theta(h_t, x_t))$
- **Orthogonal weight constraints**: $W = \exp(A)$ where $A$ is skew-symmetric, guaranteeing $W^T W = I$; alternatively, the Cayley transform $W = (I-A)(I+A)^{-1}$

## Engineering Feasibility

GPU friendliness: the key factor is whether exp/log has a closed form.
- **SO(3)/SE(3) closed forms**: The Rodrigues formula is a finite algebraic expression on 3x3/4x4 small matrices, batchable as $[B,3,3]$/ $[B,4,4]$ tensors, per-sample independent, GPU-friendly
- **General matrix exponential**: Taylor series + scaling-and-squaring iteration, with data-dependent step counts and divergent control flow, difficult to tensorize, GPU-unfriendly
- **Small-matrix GEMM**: 3x3/4x4 matrices are too small to saturate Tensor Cores; value lies in "batchable and fusible" rather than "maximizing compute throughput"
- **Low-precision critical issue**: $\sin\theta/\theta$ produces division by zero as $\theta \to 0$; $\log$ is singular as $\theta \to \pi$; fp16/bf16 yields NaN directly -- **must** implement Taylor expansion switching for small angles
- **Kinematic chain seriality**: Discrete integration via successive $\exp$ multiplication is serial; rewriting as a parallel scan is required for parallelism

## Risks and Failure Modes

- **Low-precision singularities**: Without Taylor expansion fallbacks at $\theta \to 0/\pi$, fp16 training produces NaN directly; fallback branches introduce warp divergence
- **Mixing left and right perturbations**: Mixing $\oplus_R$ (right version / local frame) with $\oplus_L$ (left version / global frame) causes misalignment of covariances and gradients
- **Treating SE(3) as T(3)xSO(3)**: Their tangent-space parameterizations differ; whether translation and rotation are coupled affects the Jacobian, and misuse introduces systematic bias
- **Treating general matrix exp as an $O(1)$ operator**: Closed forms exist only for a few groups such as SO(3)/SE(3)/SE(2)/S1/S3; general groups require iterative series
- **Over-application**: Imposing Lie group parameterization on tasks that do not need geometric constraints merely adds complexity and singularity risk

## Further References

- Distillation notes: references/books/micro-lie-theory.md (Section II-A Lie Group Definition, Section II-D Exponential Map, Section II-E Plus/Minus Operators)
- Distillation notes: references/books/differential-geometry.md (Ch 5 Lie Groups)
- Distillation notes: references/books/smooth-manifolds.md (Ch 7 Lie Groups)
- Original text: Joan Sola et al., *A micro Lie theory*, Section II-A through Section II-F (complete Lie group toolkit)
