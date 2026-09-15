# Orthogonality Loss
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

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

```python
# W_i: d x r, full column rank; QR fixes scale-collapse in an overlap penalty
Q = [qr(W_i, mode='reduced').Q for W_i in W]
L_overlap = sum(((Q[i].T @ Q[j])**2).sum() for i, j in pairs)

# Softened overlap barrier, optional
sigma = svdvals(Q_i.T @ Q_j).clamp(0, 1)
L_barrier = -log((1 - sigma**2 + eps) / (1 + eps)).sum()
```
Without epsilon the barrier is zero at orthogonality and diverges at overlap. With epsilon it is finite at overlap; the normalized expression above remains zero at orthogonality. Epsilon does not resolve undefined singular-vector gradients at multiplicities; the Gram overlap loss avoids explicit singular vectors.

Raw `||W_i.T @ W_j||_F**2` can vanish by shrinking either matrix to zero. Normalize/control variance or use orthonormal bases, and ensure $Kr\le d$ if exact mutual orthogonality is desired. Frobenius inner product $\operatorname{tr}(A^TB)=0$ alone does **not** imply orthogonal column spaces. A determinant diversity objective needs norm constraints to prevent unbounded scale growth.

A normalized concatenated Gram penalty includes within-block decorrelation as well as between-block overlap; mask within-block terms if the intended loss is only inter-expert overlap.

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
