# Low-Rank Approximation

## Minimal Definition

Given a matrix $A \in \mathbb{R}^{m \times n}$, find a matrix $B$ with rank at most $k$ that minimizes $\|A - B\|$. The Eckart-Young-Mirsky theorem guarantees that the truncated SVD provides an optimal solution under both the Frobenius norm and the spectral norm; the principal subspace is unique when $\sigma_k > \sigma_{k+1}$: $B_k = \sum_{i=1}^k \sigma_i u_i v_i^H$.

## Core Formulas

- SVD: $A = U\Sigma V^H = \sum_{i=1}^r \sigma_i u_i v_i^H$, $\sigma_1 \geq \sigma_2 \geq \cdots \geq \sigma_r > 0$
- Truncated SVD (optimal rank-$k$ approximation): $A_k = U_k \Sigma_k V_k^H$
- Eckart-Young error: $\|A - A_k\|_F = \sqrt{\sum_{i=k+1}^r \sigma_i^2}$, $\|A - A_k\|_2 = \sigma_{k+1}$
- Randomized SVD: $A \approx Q(Q^HA)$, where $Q$ is the $Q$-factor from the QR decomposition of $A\Omega$ ($\Omega$ random Gaussian)
- Effective rank: $r_{\text{eff}}(A) = \|A\|_F^2 / \|A\|_2^2 = \sum \sigma_i^2 / \sigma_1^2$
- Nuclear norm (convex relaxation of rank): $\|A\|_* = \sum \sigma_i$, the dual of the spectral norm

## Applicable Problems

- LoRA weight compression: $W \approx W_0 + BA$, $B \in \mathbb{R}^{d \times r}, A \in \mathbb{R}^{r \times d}$, $r \ll d$
- KV-Cache compression: projecting Key/Value caches into a low-rank factor format, reducing memory from $O(Ld)$ to $O(Lk + kd)$; standard softmax still has sequence length $L$
- PCA / whitening: the top $k$ principal components of the data covariance matrix correspond to the truncated SVD
- Gradient compression: the effective rank of gradient matrices in large models is often much lower than the nominal rank, allowing safe truncation
- Recommender systems / matrix completion: low-rank factorization $R \approx UV^H$

## AI Design Translation

- **LoRA (Low-Rank Adaptation)**: Freeze $W_0$, train $\Delta W = BA$ ($r \ll d$), and merge $W = W_0 + BA$ at inference time. Forward pass = two matmul operations ($x \to Ax \to BAx$), reducing trainable parameters from $O(d^2)$ to $O(dr)$. Implemented via `torch.mm(B, torch.mm(A, x))` or merged into a single matmul.
- **Randomized SVD operator**: For a large matrix $A \in \mathbb{R}^{m \times n}$, first sample $Y = A\Omega$ ($\Omega \in \mathbb{R}^{n \times (k+p)}$ random Gaussian), compute QR decomposition $Y = QR$, then form $B = Q^HA$ (small matrix $O(k \times n)$), and perform SVD on $B$. Total complexity $O(mnk)$ instead of $O(mn^2)$; all core operations are matmul.
- **KV-Cache low-rank reduction**: Maintain $K$ in factored low-rank form $K \approx U_k \Sigma_k V_k^H$ (storing $U_k \in \mathbb{R}^{L \times k}$ and $\Sigma_k V_k^H \in \mathbb{R}^{k \times d}$, totaling $O(Lk + kd)$ instead of $O(Ld)$). Perform incremental PCA or streaming SVD updates for each new token. **Note**: for standard softmax attention, low-rank factors cannot be treated as $k$ compressed tokens; softmax is still normalized over length $L$. However, one can compute $qK^T = (q(\Sigma_k V_k^H)^T)U_k^T$ in factored form, avoiding materialized $L \times d$ reconstruction and reducing the QK inner dimension from $d$ to $k$. Only in linear attention, and only when compressing additive statistics such as $\phi(K)^T V$ and $\phi(K)^T\mathbf{1}$, can the historical state truly shrink from $L$ tokens to $k$ statistical factors.
- **Nuclear norm regularization**: $\mathcal{L} = \mathcal{L}_{\text{task}} + \lambda \|W\|_*$ promotes low-rank solutions. However, nuclear norm computation requires full SVD ($O(n^3)$). Alternatives: (1) approximate with truncated SVD; (2) factorize $\|W\|_* = \min_{W=UV^H} \frac{1}{2}(\|U\|_F^2 + \|V\|_F^2)$, converting to Frobenius regularization on $U, V$.
- **Gradient low-rank compression (distributed training)**: For a gradient matrix $G \in \mathbb{R}^{m \times n}$, transmit top-$k$ SVD factors before all-reduce, reducing communication from $O(mn)$ to $O(k(m+n))$ (if $m \approx n \approx d$, this is $O(d^2) \to O(kd)$). Use randomized SVD locally on each device, then merge.

## Engineering Feasibility

- **Primary operations**: matmul + small-matrix SVD. LoRA forward = two matmul operations; randomized SVD = several matmuls + one thin QR + one small SVD, typically $O(mnk)$ (also depending on oversampling, power iterations, and spectral gaps). Lanczos / randomized truncated SVD is usually far cheaper than full SVD, but should not be summarized as an $O(k/n)$ fraction of full SVD.
- **GPU friendliness**: Extremely high. LoRA forward/backward are all tensor core matmul operations; the dominant cost of randomized SVD is also matmul. Small-matrix SVD has cuSOLVER batched implementations.
- **Complexity**: LoRA forward $O(dk)$ per sample vs. $O(d^2)$ full rank; randomized SVD $O(mnk)$; full SVD $O(\min(m^2n, mn^2))$.
- **Memory**: LoRA storage $O(dr)$ vs. $O(d^2)$; KV-Cache low-rank factor storage $O(Lk + kd)$ vs. $O(Ld)$.

## Risks and Failure Conditions

- **Incorrect rank selection**: $k$ too small causes information loss ($\sigma_{k+1}$ is non-negligible); $k$ too large negates the compression benefit. Solution: monitor the singular value decay curve and select the elbow point where $\sum_{i>k}\sigma_i^2 / \sum\sigma_i^2 < \epsilon$.
- **Insufficient randomized SVD accuracy**: When oversampling $p$ is too small (typically $p = 5 \sim 10$) or the number of power iteration steps is insufficient, low-order singular value estimates can be significantly biased. Solution: add $q = 1 \sim 2$ power iteration steps $Y = (AA^H)^q A\Omega$, at the cost of additional matmul operations.
- **LoRA not applicable to all layers**: Q/K/V in attention is typically effectively low-rank, but the effective rank of FFN layers and embeddings may be close to full rank, and applying LoRA forcefully degrades accuracy. Layer-by-layer effective rank diagnosis is required.
- **SVD overhead of nuclear norm proximal**: Soft-thresholding $\text{prox}_{\lambda\|\cdot\|_*}(A) = U(\Sigma - \lambda I)_+ V^H$ requires SVD, which is prohibitively expensive for large matrices at every step. Solution: use factorization alternatives or randomized approximations.

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Section 2.6 SVD, Section 7.4 Polar Decomposition and SVD, nuclear norm-spectral norm duality Section 5.5)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 2 Section 2.6 (SVD) + Chapter 7 Section 7.3-7.4 (Polar Decomposition & SVD)


## Routing Extensions
- If subspace projection implementation is needed -> `projection.en.md` (projection operators)
- If detailed decomposition tools are needed -> `spectral-decomposition.en.md` (SVD/EVD)
- If the goal is information-preserving compression -> `../probability/information-bottleneck.en.md` (information bottleneck theory)

## Extensible Directions
- Tensor decomposition (CP / Tucker / TT): low-rank decomposition of higher-order tensors
- Structured low-rank (Toeplitz / Hankel): structure-preserving low-rank approximation
- Online / streaming low-rank: incrementally updated low-rank estimation
- Matrix completion: recovering low-rank matrices from partial observations
- Robust PCA: low-rank + sparse decomposition
