# Subspace Alignment
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use when two or more representation spaces need to be aligned to a common subspace. Typical scenarios:
(1) Multi-modal alignment -- aligning text and image representations to a shared semantic subspace;
(2) Cross-layer alignment -- aligning shallow features to the subspace of deep features for residual connections or distillation;
(3) Expert output alignment -- different experts produce outputs with different dimensions/distributions that must be aligned before fusion;
(4) Domain adaptation -- source and target domain feature distributions differ, requiring subspace alignment.
Core requirement: **find the optimal linear/nonlinear mapping between two spaces such that corresponding semantics are aligned**.

## Mathematical Inspiration
- Lenses: ../../lenses/geometric.en.md (Grassmann manifold, principal angles), ../../lenses/variational.en.md (Procrustes problem)
- Knowledge: ../../knowledge-base/matrix-analysis/projection.en.md (SVD, orthogonal Procrustes),
  ../../knowledge-base/differential-geometry/manifold.en.md (Grassmann distance, geodesics)

## Required Mathematical Background

- Square orthogonal Procrustes assumes paired $A,B\in\mathbb R^{N\times d}$ and $W\in O(d)$; if $A^TB=U\Sigma V^T$, $W^*=UV^T$ minimizes $\|AW-B\|_F^2$. Unequal source/target dimensions require a separately specified rectangular constraint or projection into a common dimension.
- CCA requires **both** constraints $W_X^T\Sigma_{XX}W_X=I$ and $W_Y^T\Sigma_{YY}W_Y=I$; center samples and regularize singular covariances.
- Principal angles satisfy $\cos\theta_i=\sigma_i(Q_X^TQ_Y)$ for orthonormal bases in the **same ambient space**. Maximizing sums of cosines is a proxy, not literally the squared geodesic distance $\sum_i\theta_i^2$.
- Grassmann/Oja subspace updates use $G=(I-WW^T)xx^TW$ with re-orthonormalization. Subtracting only the diagonal normalization can let multiple components collapse onto the same direction.

## AI Module Form

```python
# Matched-dimension paired Procrustes
A0, B0 = A - A.mean(0), B - B.mean(0)  # optional translation alignment, stated explicitly
assert A0.shape == B0.shape
U, s, Vh = svd(A0.T @ B0, full_matrices=False)
W = U @ Vh
loss_align = ((A0 @ W - B0)**2).sum() / N

# Deep CCA after projecting both modalities to r dimensions and centering
F, G = center(encoder_A(A)), center(encoder_B(B))
Sxx, Syy = F.T @ F / N + ridge*eye(r), G.T @ G / N + ridge*eye(r)
Sxy = F.T @ G / N
T = inverse_sqrt(Sxx) @ Sxy @ inverse_sqrt(Syy)
loss_cca = -svdvals(T)[:k].sum()  # sum, not matrix trace of a vector
```
Full whitening needs covariance information; per-coordinate mean/variance normalization is only diagonal normalization. CCA correlation and Grassmann angle metrics are related in suitable whitened spaces but are not interchangeable objectives in general.

For expert output $X_i\in\mathbb R^{N\times d_i}$, left singular vectors compare sample-space subspaces and require the same paired samples; right singular vectors compare feature-space subspaces and require a common feature dimension. Declare which one is intended.

An online update `W += eta * outer(x, y - x @ W)` is unconstrained least-squares SGD, not Oja or orthogonality-preserving Procrustes; project/retract if an orthogonal constraint is required.

## Implementable Structures

- Orthogonal alignment in a common dimension, with the constraint retained after initialization.
- Regularized full whitening, or an explicitly named diagonal approximation.
- Barlow-Twins-style correlation penalties as alternative objectives, not guarantees of CCA optimality.
- Randomized spectral approximations validated on residuals and principal angles.

## GPU Feasibility

- **D1/D2[~]**: Cross-covariances use GEMM; CCA also needs two covariance estimates, inverse square roots and SVD.
- **D3/D4[~]**: For common width $d$, costs include $O(Nd^2)$ statistics, $O(d^3)$ factorizations and $O(d^2)$ storage; online unconstrained SGD is $O(d^2)$ but retraction adds cost.
- **D5[~]**: Use fp32/fp64, ridge regularization and residual checks. Epsilon inside an angle formula does not resolve eigenbasis nonidentifiability.
- **D6/D8[~]**: Independent pairs can batch; covariance reduction and factorization stages have dependencies, so profile actual fusion.
- **D7[N/A]**: Sparse features do not generally have sparse covariance; inspect the covariance before choosing sparse solvers.

## Paper-Worthy Formulation
"Based on orthogonal Procrustes theory, we obtain the optimal isometric mapping W* = UV^T (where USV^T = SVD(A^T B)) between source and target representations. Extending this to Deep CCA for nonlinear subspace alignment, principal angles on the Grassmann manifold can measure pre/post alignment distance. Convergence rates depend on sample independence, spectral gaps, and covariance-estimation assumptions; the Barlow Twins objective penalizes cross-correlation but does not by itself guarantee semantic disentanglement, so report principal angles, CCA correlations, and downstream transfer metrics."

## Risks
- SVD during backpropagation produces undefined gradients when singular values coincide; epsilon regularization is needed
- CCA whitening requires matrix inversion; numerically unstable when the covariance matrix is near-singular
- Nonlinear CCA (Deep CCA) may overfit, particularly on small datasets
- Online subspace tracking learning rate eta requires a decay schedule to prevent continuous drift
