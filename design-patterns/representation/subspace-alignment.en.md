# Subspace Alignment
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
Use when two or more representation spaces need to be aligned to a common subspace. Typical scenarios:
(1) Multi-modal alignment -- aligning text and image representations to a shared semantic subspace;
(2) Cross-layer alignment -- aligning shallow features to the subspace of deep features for residual connections or distillation;
(3) Expert output alignment -- different experts produce outputs with different dimensions/distributions that must be aligned before fusion;
(4) Domain adaptation -- source and target domain feature distributions differ, requiring subspace alignment.
Core requirement: **find the optimal linear/nonlinear mapping between two spaces such that corresponding semantics are aligned**.

## Mathematical Inspiration
- Lenses: lenses/geometric.md (Grassmann manifold, principal angles), lenses/variational.md (Procrustes problem)
- Knowledge: knowledge-base/matrix-analysis/projection.md (SVD, orthogonal Procrustes),
  knowledge-base/differential-geometry/manifold.md (Grassmann distance, geodesics)

## Required Mathematical Background
- **Orthogonal Procrustes Problem**: min_{W in O(d)} ||AW - B||_F^2
  Closed-form solution: W* = UV^T, where USV^T = SVD(A^T B)
- **CCA (Canonical Correlation Analysis)**: max_{W_1, W_2} tr(W_1^T Sigma_{XY} W_2) s.t. W_1^T Sigma_{XX} W_1 = I
  Solution via generalized eigenvalue problem or SVD(Sigma_{XX}^{-1/2} Sigma_{XY} Sigma_{YY}^{-1/2})
- **Distance on the Grassmann Manifold**: Gr(d, r) = {r-dimensional subspaces of R^d}
  Distance between two points (subspaces) determined by principal angles theta_i: d_G(U, V) = sqrt(sum theta_i^2)
  cos(theta_i) = sigma_i(U^T V) (singular values of U^T V)
- **Subspace Tracking**: Online update of subspace basis
  Oja's rule: W_{t+1} = W_t + eta * (x_t x_t^T W_t - W_t diag(W_t^T x_t x_t^T W_t))

## AI Module Form
```
Module: SubspaceAligner
Input: Source representation A in R^{N x d_a}, target representation B in R^{N x d_b} (paired data)

Method 1 - Linear Procrustes Alignment (most common):
  // Find optimal linear duality W such that A @ W is close to B
  M = A^T @ B                         // d_a x d_b, single GEMM
  U, S, V^T = SVD(M)                  // singular value decomposition
  W* = U @ V^T                        // d_a x d_b optimal orthogonal duality
  // Differentiable version: parameterize W as nn.Parameter, optimize with SGD
  L_align = ||A @ W - B||_F^2 / N    // alignment loss

Method 2 - Deep CCA (nonlinear subspace alignment):
  f_A = MLP_A(A)                      // R^{d_a} -> R^r (nonlinear projection)
  f_B = MLP_B(B)                      // R^{d_b} -> R^r
  Sigma_AA = f_A^T @ f_A / N + lambda * I  // r x r auto-covariance
  Sigma_BB = f_B^T @ f_B / N + lambda * I
  Sigma_AB = f_A^T @ f_B / N         // r x r cross-covariance
  T = Sigma_AA^{-1/2} @ Sigma_AB @ Sigma_BB^{-1/2}  // whitened cross-correlation
  L_cca = -tr(SVD(T).S[:k])          // maximize sum of top k canonical correlations
  // Equivalent to minimizing Grassmann distance

Method 3 - Subspace Angle Regularization (multi-expert output alignment):
  // Outputs of multiple experts should be aligned to the same subspace
  U_k = SVD(expert_k_output)[0][:, :r]  // r-dim principal components of each expert output
  for i, j in expert_pairs:
    cos_angles = SVD(U_i^T @ U_j).S     // cosines of principal angles
    L_subspace = -mean(cos_angles)       // maximize principal angle cosines -> minimize angles
  // Or use Grassmann distance:
  L_grass = sum(angles^2)                // angles = arccos(cos_angles)

Online Subspace Tracking (adaptation at inference):
  // New samples arrive at test time; incrementally update alignment matrix
  W_new = W_old + eta * (x_new @ (y_new^T - x_new^T @ W_old))  // Oja-like
  // No need to recompute SVD; O(d^2) online update
```

## Implementable Structures
- **Alignment Layer**: nn.Linear(d_a, d_b, bias=False) initialized with the Procrustes solution
- **Whitening layer**: Use running mean/variance for online whitening, avoiding per-step Sigma^{-1/2} computation
- **CCA alternative**: Use Barlow Twins-style redundancy reduction loss instead of CCA (avoids matrix inversion)
  L_BT = ||C - I||_F^2 where C = corr(f_A, f_B)
- **Chunked SVD**: Use randomized SVD approximation at large scale; sufficient precision and faster

## GPU Feasibility
- **Tensorization**: A^T @ B is standard GEMM (d x N) @ (N x d); SVD has cuSOLVER implementations
- **GEMM-mappable**: Procrustes core requires 1 GEMM + 1 SVD; CCA requires 2 GEMMs + 1 SVD
- **Complexity**: GEMM O(N * d^2); SVD O(d^3) (d typically < 1024, acceptable); online tracking O(d^2)
- **Memory & KV-Cache**: Storing covariance matrix d x d (~4 MB for d = 1024); no KV-Cache overhead
- **Low-precision stability**: SVD strongly recommended in fp32; whitening matrix inversion requires fp32 + epsilon regularization
- **Parallelism & Communication**: Subspace angle computations for multiple expert pairs are independent and parallel; CCA GEMMs are highly parallel
- **Sparse structure**: When source/target representations are sparse, covariance matrix Sigma is sparse, enabling sparse SVD
- **Operator fusion**: Whitening (mean-sub -> cov -> inv_sqrt -> transform) can be partially fused

## Paper-Worthy Formulation
"Based on orthogonal Procrustes theory, we obtain the optimal isometric mapping W* = UV^T (where USV^T = SVD(A^T B)) between source and target representations. Extending this to Deep CCA for nonlinear subspace alignment, principal angle analysis on the Grassmann manifold shows that post-alignment subspace distance converges at rate O(r/sqrt(N)), while the Barlow Twins redundancy reduction objective ensures feature dimension decorrelation."

## Risks
- SVD during backpropagation produces undefined gradients when singular values coincide; epsilon regularization is needed
- CCA whitening requires matrix inversion; numerically unstable when the covariance matrix is near-singular
- Nonlinear CCA (Deep CCA) may overfit, particularly on small datasets
- Online subspace tracking learning rate eta requires a decay schedule to prevent continuous drift
