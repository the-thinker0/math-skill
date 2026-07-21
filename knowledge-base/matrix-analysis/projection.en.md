# Orthogonal Projection

## Minimal Definition

Maps a vector $v$ onto a subspace $\mathcal{S}$ such that the residual $v - Pv$ is orthogonal to $\mathcal{S}$. The projection matrix $P$ satisfies $P^2 = P$ and $P = P^H$ (idempotent + Hermitian), and is the unique linear operator that determines the nearest point.

## Core Formulas

- If $A$ has full column rank and column space $\mathcal{S}$, then $P=A(A^HA)^{-1}A^H$; in general use the Moore--Penrose pseudoinverse, $P=AA^\dagger$
- If the columns of $A$ are orthonormal ($A^HA = I$), then $P = AA^H$
- If $Q$ is an orthonormal basis, then $\|v-QQ^Hv\|^2=\|v\|^2-\|Q^Hv\|^2$
- Courant-Fischer variational characterization: $\lambda_k = \max_{\dim(S)=k} \min_{x \in S, \|x\|=1} x^HAx$
- Orthogonal complement projection: $P^\perp = I - P$

## Applicable Problems

- Least squares regression: $\hat{x} = \arg\min \|Ax - b\|^2$ is equivalent to projecting $b$ onto $\text{Col}(A)$
- PCA dimensionality reduction: projecting data onto the subspace spanned by the top $k$ principal components
- Feasible directions for smooth equality constraints/manifolds: project the gradient onto the tangent space. General projected-gradient methods for convex constraints instead project the updated point back onto the feasible set.
- Orthogonal decomposition in residual networks: decomposing a signal into an explained component + residual

## AI Design Translation

- **Low-rank bottleneck analysis for linear layers**: Truncated SVD $W_k=U_k\Sigma_kV_k^H$ is a best rank-$k$ approximation under the standard unitarily invariant norms and can be stored as factors using $O(k(m+n))$ parameters. This does not make $W_k$ a projection operator.
- **Subspace maps in attention heads**: Q/K/V are generally learned linear maps, not orthogonal projections unless idempotence and Hermitian symmetry hold. Batched GEMM still implements multiple heads, but orthogonal head subspaces require an explicit constraint and verification.
- **Projection heads in contrastive learning**: A SimCLR/MoCo projection head is an MLP. Final $L_2$ normalization maps nonzero vectors radially to the unit sphere; it is neither a linear projection nor Euclidean projection onto a convex set.
- **Gradient projection / Orthogonal Gradient Descent (OGD)**: In continual learning, projecting the new-task gradient onto the orthogonal complement of the old-task gradient space to avoid catastrophic forgetting; requires maintaining a basis matrix $G$ and computing $(I - G(G^TG)^{-1}G^T)\nabla$, with the core being two matmul operations

## Engineering Feasibility

- **Primary operations**: Given an orthonormal basis $Q\in\mathbb{R}^{n\times k}$, apply the projection as $Q(Q^Hx)$ rather than materializing an $n\times n$ matrix. To obtain a basis from non-orthogonal $A$, prefer QR/SVD over explicitly forming $(A^HA)^{-1}$.
- **GPU friendliness**: Projection application is two GEMV/GEMM operations. Large batches can use Tensor Cores; small $k$ or single-vector workloads may be launch- or memory-bound, so matmul expressibility alone does not imply high utilization.
- **Complexity**: Applying the projection costs $O(nk)$ per vector. Thin QR of an $n\times k$ matrix with $n\ge k$ is typically $O(nk^2)$.
- **Low precision**: Normal equations square the condition number. Jitter must be scaled to the data, dtype, and error tolerance; $10^{-6}$ is not universal. Prefer fp32 accumulation and QR/SVD.

## Risks and Failure Conditions

- **Ill-conditioned basis matrix**: When the condition number $\kappa(A) \gg 1$, $(A^HA)^{-1}$ suffers catastrophic cancellation under low precision. Solution: first perform QR decomposition to obtain an orthonormal basis $Q$, then use $P = QQ^H$, avoiding explicit inversion.
- **Excessively high subspace dimension**: When $k$ approaches $n$, the projection degenerates to the identity mapping, wasting computation. A randomized SVD should first be performed to confirm the effective rank.
- **Non-stationary subspace**: In online/continual learning, the projection basis drifts with the data; the basis matrix must be periodically updated (incremental QR), otherwise the projection directions become stale.
- **Oblique projection**: If $P^2=P$ but $P\ne P^H$, the map no longer gives Euclidean nearest points. Stability depends on the angle/conditioning between its range and null space; $\|P-P^H\|_F$ alone is not a sufficient diagnostic. Monitor the operator norm or basis conditioning.

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Section 2.1 QR Decomposition, Section 4.2 Courant-Fischer Variational Characterization, Section 2.6 SVD)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 2 (Unitary Similarity) + Chapter 4 (Hermitian Matrices Section 4.2 Variational Characterizations)


## Routing Extensions
- If the goal is compression / dimensionality reduction -> `low-rank-approximation.en.md` (truncated SVD implementation)
- If projection constraints are needed on a manifold -> `../optimization/riemannian-optimization.md` (constrained optimization on Riemannian manifolds)
- If shared vs. private subspace separation is involved -> `shared-private-decomposition` (design pattern layer)

## Extensible Directions
- Oblique projection: non-orthogonal projection operators
- Alternating projection: Von Neumann alternating projection convergence theorem
- Projection onto convex sets (POCS): projecting onto intersections of convex sets
- Randomized projection: Johnson-Lindenstrauss lemma and random projections
- Subspace tracking: online subspace estimation methods
