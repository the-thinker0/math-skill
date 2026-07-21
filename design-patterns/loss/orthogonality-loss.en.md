# Orthogonality Loss
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
In multi-expert / multi-task settings, representations learned by submodules are highly overlapping and redundant, leading to poor parameter utilization. This loss is used when the $d$-dimensional feature space needs to be partitioned into $K$ non-interfering subspaces -- such as Shared-Private separation, MoE expert differentiation, and multi-task head decorrelation. Core objective: **ensure different modules see different things**.

## Mathematical Inspiration
- Lenses: ../../lenses/projection.en.md (orthogonal projection and subspace decomposition), ../../lenses/variational.en.md (regularization and saddle points)
- Knowledge: ../../knowledge-base/matrix-analysis/projection.en.md (spectral theorem, SVD, Schur decomposition), ../../knowledge-base/probability/kl-divergence.en.md (redundancy and mutual information)

## Required Mathematical Knowledge
- **Frobenius Inner Product and Orthogonality**: $\langle A, B \rangle_F = \text{tr}(A^T B)$; when $\langle A, B \rangle_F = 0$, $A \perp B$
- **Stiefel Manifold Constraint**: $W \in \text{St}(d, k)$, i.e., $W^T W = I_k$, projecting onto the set of orthogonal matrices
- **DPP (Determinantal Point Process)**: $\det(W^T W)$ increases as column vectors become more spread out, serving as a diversity proxy
- **Off-Diagonal Elements of the Cosine Similarity Matrix**: $C_{ij} = |\langle w_i, w_j \rangle| / (\|w_i\|\|w_j\|)$, minimizing $\sum_{i \neq j} C_{ij}^2$

## AI Module Form
```
Module: OrthogonalDiversityLoss
Input: K feature matrices {W_k in R^{d x r}}_{k=1}^K (weights or features of K submodules)
  // Note: Grassmann distance requires QR decomposition of W_i first to obtain orthonormal bases Q_i

Method 1 - Frobenius Orthogonal Regularization:
  L_orth = Sum_{i<j} ||W_i^T W_j||_F^2
  // Computation: O(K^2 * d * r^2), K typically <16 so cost is manageable

Method 2 - Subspace-overlap log barrier (based on principal angles):
  sigma_k = singular values of SVD(Q_i^T Q_j) (= cos(theta_k), theta_k are principal angles)
  // ⚠ Must first orthonormalize W_i, W_j: Q_i = qr(W_i).Q, Q_j = qr(W_j).Q
  // Otherwise singular values may exceed 1, making -log(1-sigma^2+eps) undefined
  // ⚠ Original formula sigma^2*(1-sigma^2) is wrong: penalty is 0 at BOTH sigma=0 (orthogonal) AND sigma=1 (complete overlap)!
  // Fully overlapping subspaces receive zero penalty, defeating the orthogonality objective.
  // Correct formula: log-barrier, 0 at sigma=0 and → +∞ as sigma→1
  L_grass = Sum_{i<j} Sum_k -log(1 - sigma_k^2 + eps)  // = -Sum log(sin^2(theta_k)), 0 when orthogonal (theta=pi/2), →∞ when overlapping (theta→0)

Method 3 - Efficient Normalized-Gram Decorrelation:
  W_norm = column_normalize(concat([W_1,...,W_K]))       // without normalization this also penalizes norms, not only angles
  G = W_norm^T * W_norm                                  // single GEMM
  L_corr = ||G * (1 - I)||_F^2   // mask out diagonal, penalize off-diagonal elements
```

## Implementable Architectures
- **Embedded as nn.Module**: forward receives $K$ tensors and returns a scalar loss; supports direct .backward()
- **Weighted Combination with Main Loss**: L_total = L_task + lambda * L_orth; lambda can use cosine annealing or warm-up
- **Block Computation**: When $K$ is large, perform mini-batch sampling over $(i,j)$ pairs, computing only $B$ out of $\binom{K}{2}$ pairs per step

## GPU Feasibility
- **D1[~]**: The core operation is expressible as GEMM, but small $Kr$ can be launch-bound or underutilize Tensor Cores.
- **D2[v]**: Method 3 requires only 1 GEMM + 1 element-wise mask + Frobenius norm
- **D3[~]**: Method 3 costs $O(d(Kr)^2)$ for the GEMM and stores both $O(dKr)$ inputs and an $O((Kr)^2)$ Gram matrix. It is negligible only when $Kr$ is small enough.
- **D4[~]**: It avoids an explicit $d\times d$ projector but materializes a $(Kr)\times(Kr)$ Gram matrix. KV-cache is not an applicable metric here.
- **D5[~]**: Square sums can overflow or accumulate error in fp16; use fp32 accumulation. Run QR/SVD in at least fp32 and test gradients near repeated singular values.
- **D6[~]**: The $\binom K2$ pairs are parallel. A reduction is needed only if this auxiliary loss is split across devices; keeping it local is usually cheaper.
- **D7[N/A]**: This loss normally uses small dense matrices. Removing the Gram diagonal does not create useful structured sparsity, and sparse $W_k$ does not in general imply a sparse Gram matrix.
- **D8[~]**: Masking and square-sum reduction can use a fused epilogue or a separate fused reduction, but they do not automatically fuse into a vendor GEMM kernel. Verify launch and memory-traffic savings with a profiler.

## Paper Phrasing
"We introduce an orthogonality regularizer L_orth = Sum_{i<j} ||Q_i^T Q_j||_F^2, where Q_i is an orthonormal basis for W_i, to penalize overlap between feature subspaces of different submodules. This can reduce linear redundancy, but any redundancy-decay rate requires random-subspace or data-distribution assumptions and should be reported through principal angles, mutual-information estimates, or downstream ablations."

## Risks
- Excessively large lambda causes variational difficulties (orthogonal constraint conflicts with task objective); requires careful tuning or adaptive lambda
- The SVD in Method 2 produces unstable gradients during backpropagation; epsilon-regularization on singular values is needed
- When $K \cdot r > d$, strict orthogonality is impossible; dimensionality reduction or acceptance of approximate orthogonality is required
