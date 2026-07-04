# Orthogonality Loss

## Applicable Problems
In multi-expert / multi-task settings, representations learned by submodules are highly overlapping and redundant, leading to poor parameter utilization. This loss is used when the $d$-dimensional feature space needs to be partitioned into $K$ non-interfering subspaces -- such as Shared-Private separation, MoE expert differentiation, and multi-task head decorrelation. Core objective: **ensure different modules see different things**.

## Mathematical Inspiration
- Lenses: lenses/geometry.md (orthogonal projection and subspace decomposition), lenses/optimization.md (regularization and saddle points)
- Knowledge: knowledge-base/fundamentals/linear-algebra.md (spectral theorem, SVD, Schur decomposition), knowledge-base/fundamentals/information-theory.md (redundancy and mutual information)

## Required Mathematical Knowledge
- **Frobenius Inner Product and Orthogonality**: $\langle A, B \rangle_F = \text{tr}(A^T B)$; when $\langle A, B \rangle_F = 0$, $A \perp B$
- **Stiefel Manifold Constraint**: $W \in \text{St}(d, k)$, i.e., $W^T W = I_k$, projecting onto the set of orthogonal matrices
- **DPP (Determinantal Point Process)**: $\det(W^T W)$ increases as column vectors become more spread out, serving as a diversity proxy
- **Off-Diagonal Elements of the Cosine Similarity Matrix**: $C_{ij} = |\langle w_i, w_j \rangle| / (\|w_i\|\|w_j\|)$, minimizing $\sum_{i \neq j} C_{ij}^2$

## AI Module Form
```
Module: OrthogonalDiversityLoss
Input: K feature matrices {W_k in R^{d x r}}_{k=1}^K (weights or features of K submodules)

Method 1 - Frobenius Orthogonal Regularization:
  L_orth = Sum_{i<j} ||W_i^T W_j||_F^2
  // Computation: O(K^2 * d * r^2), K typically <16 so cost is manageable

Method 2 - Grassmann Distance (based on principal angles):
  sigma_k = singular values of SVD(W_i^T W_j)
  L_grass = Sum_{i<j} Sum_k sigma_k^2 * (1 - sigma_k^2)  // penalizes singular values that are neither 0 nor 1

Method 3 - Efficient Cosine Decorrelation:
  G = concat([W_1,...,W_K])^T * concat([W_1,...,W_K])  // single GEMM
  L_corr = ||G * (1 - I)||_F^2   // mask out diagonal, penalize off-diagonal elements
```

## Implementable Architectures
- **Embedded as nn.Module**: forward receives $K$ tensors and returns a scalar loss; supports direct .backward()
- **Weighted Combination with Main Loss**: L_total = L_task + lambda * L_orth; lambda can use cosine annealing or warm-up
- **Block Computation**: When $K$ is large, perform mini-batch sampling over $(i,j)$ pairs, computing only $B$ out of $\binom{K}{2}$ pairs per step

## GPU Feasibility
- **Tensorization**: Core operation is matmul ($W^T W$) -- standard GEMM, perfectly mapped to Tensor Cores
- **GEMM Mappability**: Method 3 requires only 1 GEMM + 1 element-wise mask + Frobenius norm
- **Complexity**: $O(K \cdot d \cdot r)$ storage + $O(d \cdot r^2 \cdot K)$ or $O(K^2 \cdot d \cdot r^2)$ computation; negligible when $K < 16$
- **Memory and KV-Cache**: Intermediate matrices are on the order of $d \times r \cdot K$, adding no KV-Cache overhead
- **Low Precision Stability**: Frobenius norm is a sum of squares, safe under fp16; Grassmann SVD is recommended in fp32
- **Parallelism and Communication**: The $K$ pairs are embarrassingly parallel; can be distributed across GPUs with all-reduce
- **Sparse Structure**: If $W_k$ is itself sparse (e.g., MoE gate), masking further increases sparsity
- **Operator Fusion**: matmul -> mask -> square -> sum can be fused into a single CUDA kernel

## Paper Phrasing
"We introduce an orthogonality regularizer L_orth = Sum_{i<j} ||W_i^T W_j||_F^2 that constrains the feature spaces of submodules to the approximately orthogonal Grassmann sub-manifold, theoretically guaranteeing that redundancy across $K$ subspaces decays as $O(1/\sqrt{d})$."

## Risks
- Excessively large lambda causes optimization difficulties (orthogonal constraint conflicts with task objective); requires careful tuning or adaptive lambda
- The SVD in Method 2 produces unstable gradients during backpropagation; epsilon-regularization on singular values is needed
- When $K \cdot r > d$, strict orthogonality is impossible; dimensionality reduction or acceptance of approximate orthogonality is required
