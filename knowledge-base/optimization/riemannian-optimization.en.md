# Riemannian Optimization

## Minimal Definition

Optimization on smooth manifolds $\mathcal{M}$ (e.g., the orthogonal group $O(n)$, Stiefel manifold, Grassmann manifold, hyperbolic space). Core idea: project the Euclidean gradient onto the tangent space of the manifold, update along geodesics (or retractions), and ensure iterates remain on the manifold.

## Core Formulas

- Riemannian gradient: $\text{grad} f(x) = \text{proj}_{T_x\mathcal{M}}(\nabla f(x))$ (Euclidean gradient projected onto the tangent space)
- Riemannian gradient descent: $x_{k+1} = R_{x_k}(-\alpha_k \cdot \text{grad} f(x_k))$, where $R$ is a retraction
- Tangent space of the orthogonal group $O(n)$: $T_Q O(n) = \{Q\Omega : \Omega^T = -\Omega\}$ (left multiplication by skew-symmetric matrices)
- Cayley retraction for the orthogonal group: $R_Q(\xi) = Q(I + \frac{1}{2}\Omega)^{-1}(I - \frac{1}{2}\Omega)$, $\xi = Q\Omega$; equivalently in $A$-form: let $G = \nabla f(Q)$ be the Euclidean gradient and $A = GQ^T - QG^T$ (skew-symmetric), then $R_Q(t) = (I + \frac{t}{2}A)^{-1}(I - \frac{t}{2}A)Q$, with step size $t > 0$ moving along the negative gradient (descent direction)
- Polar decomposition retraction: $R_Q(\xi) = (Q + \xi)(I + \xi^T\xi)^{-1/2}$ (projection onto the nearest orthogonal matrix)
- Newton-Schulz orthogonalization: $X_{k+1} = \frac{1}{2}X_k(3I - X_k^T X_k)$, converging to the nearest orthogonal matrix
- Hyperbolic space (Poincaré ball): $\text{grad}_{\mathcal{H}} f = \frac{(1-\|x\|^2)^2}{4} \nabla f(x)$
- Riemannian gradient on the Stiefel manifold $St(n,p) = \{W : W^TW = I_p\}$: $\text{grad} f(W) = G - W \cdot \text{sym}(W^TG)$, where $G = \nabla f(W)$ is the Euclidean gradient and $\text{sym}(A) = \frac{A + A^T}{2}$ is the symmetric correction term. Note: one cannot simply use $G - WW^TG$ (orthogonal projection); the symmetric correction is essential to ensure the gradient lies in the tangent space.

## Applicable Problems

- Orthogonal weight constraints: $W^TW = I$ preserves eigenvalue moduli at 1, stabilizing RNN/SSM training
- Muon optimizer: projects the gradient onto the nearest orthogonal matrix as the update direction (a cheap surrogate with "second-order flavor")
- Low-rank subspace tracking: online PCA on the Grassmann manifold
- Hyperbolic embeddings: Poincaré embeddings for hierarchical structures (trees, taxonomies)
- Metric learning: distance metrics on the SPD matrix manifold (covariance matrix space)

## AI Design Translation

- **Muon optimizer (orthogonalized gradient updates)**: Approximates the orthogonal polar factor of a scaled momentum matrix $M$ via Newton-Schulz / polar iteration, e.g. $X_{k+1} = \frac{1}{2}X_k(3I - X_k^TX_k)$ (after normalization and under spectral conditions). A fixed 5-step iteration is an engineering approximation, not an unconditional convergence guarantee. Update $W \leftarrow W - \alpha \cdot U$ ($U$ being the orthogonalized result). The core is a matmul chain, tensor-core-friendly, with scaling and residual checks needed in low precision.
- **Manifold perspective on spectral normalization**: The common constraint $\sigma_{\max}(W) \leq 1$ is enforced by scaling weights by the largest singular value, i.e. a reparameterization / normalization. It is not a Stiefel tangent projection and not the exact nearest projection onto the spectral-norm ball. Power iteration only estimates the top singular direction.
- **Orthogonal RNN**: Hidden state recurrence $h_t = \sigma(W h_{t-1} + U x_t)$, constraining $W \in O(n)$ to avoid vanishing/exploding gradients. During training, uses the Cayley parameterization $W = (I-A)(I+A)^{-1}$ ($A$ skew-symmetric), with backpropagation computing unconstrained gradients with respect to $A$. The core is matrix inversion $O(n^3)$ (acceptable for small layer dimensions).
- **Poincaré embeddings (hyperbolic space)**: Embeds hierarchical data into the Poincaré ball $\mathcal{B}^n = \{x : \|x\| < 1\}$. Distance $d(x,y) = \text{arcosh}(1 + 2\|x-y\|^2 / ((1-\|x\|^2)(1-\|y\|^2)))$. The gradient is simply scaled by the metric factor $(1-\|x\|^2)^2/4$. Implemented as elementwise scaling, $O(d)$.
- **Subspace learning on the Grassmann manifold**: Treats low-rank subspaces as points on the Grassmann manifold, updated online via Riemannian SGD. More suitable for streaming data than SVD. The projection $P = QQ^T$ update is implemented via QR decomposition, with the core being matmul + thin QR.

## Engineering Feasibility

- **Primary operations**: Riemannian gradient projection = matmul ($Q^T \nabla$ to obtain the tangent space component); retraction = matmul + small-matrix inversion / Newton-Schulz (pure matmul); hyperbolic metric = elementwise.
- **GPU friendliness**: High (Newton-Schulz orthogonalization = pure matmul chain) to moderate (Cayley retraction requires $n \times n$ matrix inversion, where $n$ is the layer dimension; feasible via cuSOLVER when $n \leq 1024$). The metric scaling for hyperbolic embeddings is pure elementwise.
- **Complexity**: Newton-Schulz per step $O(n^3)$ (where $n$ is the layer dimension, not total model parameters); Cayley $O(n^3)$; hyperbolic gradient $O(d)$; Grassmann QR $O(nd^2)$.
- **Low precision**: Newton-Schulz is stable under bf16 (pure matmul iteration, no division or square roots); Cayley retraction's matrix inversion may fail under bf16 (fp32 required); the hyperbolic metric's denominator approaches zero as $\|x\| \to 1$, requiring clamping to prevent overflow.

## Risks and Failure Conditions

- **Inversion overhead of Cayley / matrix exponential maps**: $O(n^3)$ matrix inversion per step becomes a bottleneck when layer dimension $> 4096$. Solution: switch to Newton-Schulz orthogonalization (pure matmul) or approximate retractions via polar decomposition.
- **Numerical overflow in hyperbolic space**: As $\|x\| \to 1$, $d(x,y) \to \infty$ and the metric factor $(1-\|x\|^2)^{-2} \to \infty$, causing gradient explosion. Solution: clamp $\|x\| \leq 1 - \epsilon$ ($\epsilon \sim 10^{-5}$), or use the Lorentz model (a numerically more stable hyperbolic parameterization).
- **Retraction vs. exponential map**: Retraction is a first-order approximation of the exponential map, with reduced accuracy at large step sizes. For learning-rate-sensitive optimization problems, the true exponential map may be needed (at higher cost).
- **Unboundedness of non-compact manifolds**: SPD manifolds / hyperbolic space are non-compact, and optimization paths may diverge to infinity. Regularization or trust-region constraints are needed.
- **Conflict between orthogonal constraints and BatchNorm**: The affine transformation in BatchNorm breaks orthogonality. Either disable BN scale/shift after orthogonally constrained layers, or switch to GroupNorm.

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Section 7.3 Polar Decomposition, Newton-Schulz Iteration, Section 2.6 SVD and Orthogonal Factors)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 7 Section 7.3 (Polar Decomposition) + Absil, Mahony, Sepulchre, *Optimization Algorithms on Matrix Manifolds*, Princeton University Press, 2008


## Routing Extensions
- If local linearization is needed -> `../differential-geometry/tangent-space.en.md` (gradient computation in tangent space)
- If retraction choice is needed -> `../differential-geometry/metric-tensor.en.md` (metric determines retraction map)
- If the metric comes from Fisher information -> `../information-geometry/natural-gradient.en.md` (natural gradient under Fisher metric)

## Extensible Directions
- Retraction types: exponential map, projection retraction, Cayley transform
- Vector transport: transporting vectors between different tangent spaces on a manifold
- Riemannian conjugate gradient: conjugate gradient method on manifolds
- Riemannian trust region: trust region methods on manifolds
- Stochastic Riemannian optimization: SGD variants on manifolds
