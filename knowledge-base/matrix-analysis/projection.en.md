# Orthogonal Projection

## Minimal Definition

Maps a vector $v$ onto a subspace $\mathcal{S}$ such that the residual $v - Pv$ is orthogonal to $\mathcal{S}$. The projection matrix $P$ satisfies $P^2 = P$ and $P = P^H$ (idempotent + Hermitian), and is the unique linear operator that determines the nearest point.

## Core Formulas

- Projection matrix: $P = A(A^HA)^{-1}A^H$, where the columns of $A$ span the subspace $\mathcal{S}$
- If the columns of $A$ are orthonormal ($A^HA = I$), then $P = AA^H$
- Nearest distance after projection: $\|v - Pv\|^2 = \|v\|^2 - \|A^Hv\|^2$
- Courant-Fischer variational characterization: $\lambda_k = \max_{\dim(S)=k} \min_{x \in S, \|x\|=1} x^HAx$
- Orthogonal complement projection: $P^\perp = I - P$

## Applicable Problems

- Least squares regression: $\hat{x} = \arg\min \|Ax - b\|^2$ is equivalent to projecting $b$ onto $\text{Col}(A)$
- PCA dimensionality reduction: projecting data onto the subspace spanned by the top $k$ principal components
- Feasible directions in constrained optimization: projecting the gradient onto the constraint tangent space (projected gradient method)
- Orthogonal decomposition in residual networks: decomposing a signal into an explained component + residual

## AI Design Translation

- **Low-rank bottleneck analysis for linear layers**: The truncation $W = U_k \Sigma_k V_k^H$ is a projection onto a rank-$k$ subspace; implemented via `torch.mm(U_k, torch.mm(Sigma_k, V_k.t()))` as three matmul steps, reducing memory from $O(mn)$ to $O(k(m+n))$
- **Subspace projection in attention heads**: The Q/K/V matrices essentially project inputs into different subspaces for similarity computation; multi-head = parallel projection subspaces, directly implementable as batched matmul
- **Projection head (contrastive learning)**: The projection head in SimCLR/MoCo = a multi-layer MLP followed by $L_2$-normalize, equivalent to projecting onto the unit sphere; implemented as `F.normalize(self.mlp(x), dim=-1)`, an elementwise norm operation
- **Gradient projection / Orthogonal Gradient Descent (OGD)**: In continual learning, projecting the new-task gradient onto the orthogonal complement of the old-task gradient space to avoid catastrophic forgetting; requires maintaining a basis matrix $G$ and computing $(I - G(G^TG)^{-1}G^T)\nabla$, with the core being two matmul operations
- **Orthogonal residuals in ResNet**: The residual connection $x + F(x)$ can be interpreted as a projection onto the identity subspace + orthogonal correction; spectral normalization constrains the Lipschitz constant of $F$ to stabilize the projection

## Engineering Feasibility

- **Primary operations**: Matrix multiplication (matmul) + matrix inversion/Cholesky. When the subspace dimension $k$ is much smaller than $n$, $(A^HA)^{-1}$ only requires inverting a $k \times k$ matrix, at negligible cost.
- **GPU friendliness**: High. $P = AA^H$ (orthonormal columns case) is two matmul operations, perfectly mapped to tensor cores. The Cholesky decomposition for the non-orthogonal case has cuSOLVER batched implementations.
- **Complexity**: Projection operation $O(nk)$ per vector (orthonormal basis case), basis construction $O(nk^2)$ (Gram-Schmidt) or $O(n^2k)$ (QR decomposition).
- **Low precision**: Under bf16, $A^HA$ may lose positive definiteness; a jitter $\epsilon I$ ($\epsilon \sim 10^{-6}$) must be added.

## Risks and Failure Conditions

- **Ill-conditioned basis matrix**: When the condition number $\kappa(A) \gg 1$, $(A^HA)^{-1}$ suffers catastrophic cancellation under low precision. Solution: first perform QR decomposition to obtain an orthonormal basis $Q$, then use $P = QQ^H$, avoiding explicit inversion.
- **Excessively high subspace dimension**: When $k$ approaches $n$, the projection degenerates to the identity mapping, wasting computation. A randomized SVD should first be performed to confirm the effective rank.
- **Non-stationary subspace**: In online/continual learning, the projection basis drifts with the data; the basis matrix must be periodically updated (incremental QR), otherwise the projection directions become stale.
- **Non-orthogonal projection**: Oblique projections where $P^2 = P$ but $P \neq P^H$ are numerically unstable in floating point and should be avoided; if they must be used, monitor $\|P - P^H\|_F$.

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Section 2.1 QR Decomposition, Section 4.2 Courant-Fischer Variational Characterization, Section 2.6 SVD)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 2 (Unitary Similarity) + Chapter 4 (Hermitian Matrices Section 4.2 Variational Characterizations)


## Routing Extensions
- If the goal is compression / dimensionality reduction -> `low-rank-approximation.en.md` (truncated SVD implementation)
- If projection constraints are needed on a manifold -> `riemannian-optimization.md` (constrained optimization on Riemannian manifolds)
- If shared vs. private subspace separation is involved -> `shared-private-decomposition` (design pattern layer)

## Extensible Directions
- Oblique projection: non-orthogonal projection operators
- Alternating projection: Von Neumann alternating projection convergence theorem
- Projection onto convex sets (POCS): projecting onto intersections of convex sets
- Randomized projection: Johnson-Lindenstrauss lemma and random projections
- Subspace tracking: online subspace estimation methods
