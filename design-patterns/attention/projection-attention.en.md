# Projection Attention
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
When the token/key space dimensionality is too high, the standard attention $Q K^T$ inner product tends to become uniform in high-dimensional spaces ("attention collapse"). In such cases, key/query vectors must first be projected onto a **subspace with superior geometric structure** before computing attention. Typical scenarios include: KV-Cache compression for long-context LLMs, attention sparsification in high-dimensional embedding spaces, and attention alignment of heterogeneous features in multimodal fusion.

## Mathematical Inspiration
- Lenses: [projection, spectral, probabilistic]
- Knowledge: [`../../knowledge-base/probability/concentration-inequality.en.md` (high-dimensional concentration inequalities provide theoretical explanation for attention collapse), `../../knowledge-base/probability/entropy.en.md` (entropy of attention distributions as a quality metric)]

## Required Mathematical Knowledge
- **Johnson-Lindenstrauss Lemma**: High-dimensional point sets can be projected onto an $O(\log n / \epsilon^2)$-dimensional subspace while approximately preserving distances
- **Random Projections and Subspace Embeddings**: Sparse projection matrices (e.g., CountSketch, SRHT) approximately preserve inner products
- **SVD / PCA Truncation**: Optimal low-rank subspace projection that maximizes retained variance

## AI Module Form

**Core Idea**: Project $Q, K \in \mathbb{R}^{n \times d}$ onto an $r$-dimensional subspace ($r \ll d$) before computing attention:

$$\text{ProjAttn}(Q, K, V) = \text{softmax}\left(\frac{Q P_Q (K P_K)^T}{\sqrt{r}}\right) V$$

where $P_Q, P_K \in \mathbb{R}^{d \times r}$ are projection matrices.

**Three Projection Strategies**:

1. **Learnable Projection** ($P$ as trainable parameters):
```
P_Q = Linear(d, r, bias=False)  # r << d
P_K = Linear(d, r, bias=False)
scores = (Q @ P_Q) @ (K @ P_K).T / sqrt(r)
attn = softmax(scores) @ V
```

2. **Random Fixed Projection** (distance-preservation bound when JL conditions hold):
```
P = random_gaussian(d, r) / sqrt(r)  # fixed, not trained
scores = (Q @ P) @ (K @ P).T / sqrt(r)
```

3. **Data-Adaptive Projection** (online PCA):
```
# Maintain running covariance of K, take top-r eigenvectors
C = running_mean(K^T @ K)  # d x d
eigenvecs = top_r_eigenvectors(C)  # d x r
scores = (Q @ eigenvecs) @ (K @ eigenvecs).T / sqrt(r)
```

## Implementable Architectures
- **Multi-Head Projection**: Each head uses a different $P_h \in \mathbb{R}^{d_h \times r}$, with total computation $O(n \cdot d \cdot r + n^2 \cdot r)$. When $r \ll d$, this saves the $O(n^2 d)$ cost of $Q K^T$
- **Key-cache Compression**: The projected $K' = K P_K \in \mathbb{R}^{n \times r}$ replaces the original $K$ in storage, reducing Key-cache memory by about $d/r$. Full KV-Cache compression requires a separate V compression/reconstruction mechanism
- **Hierarchical Projection**: Shallow layers use small $r$ (coarse filtering), while deep layers use large $r$ (fine ranking)

## GPU Feasibility
- **D1**: Projection = matrix multiplication, attention = matrix multiplication chain; entirely tensor operations
- **D2**: $Q P_Q$ and $K P_K$ are both standard GEMM operations, fully utilizing Tensor Cores
- **D3**: Projection cost $O(ndr)$ is far below attention cost $O(n^2 d)$, and after projection $r \ll d$ reduces attention to $O(n^2 r)$
- **D4**: Key-cache compressed by $d/r$; V-cache must be handled separately
- **D5**: Projection matrices are orthogonal or near-orthogonal, yielding numerical stability; bf16 is acceptable
- **D6**: Projection can be pipelined with attention; Multi-Head is naturally parallel across heads
- **D7**: Projection matrices are inherently dense; sparse projections (CountSketch) may introduce gather/scatter operations
- **D8[~] Retrofittable, needs kernel-level validation**: Projection may be integrated into a FlashAttention-style kernel, but requires kernel-level verification

## Paper Phrasing
"We decompose attention computation into low-dimensional subspace projection and projected-space attention to reduce Key dimensionality; V-cache must be handled separately. With an independent random projection and the sample-size / target-dimension conditions of the Johnson-Lindenstrauss lemma, Euclidean distances of the projected objects can be approximately preserved. This does not automatically guarantee softmax-attention quality, so attention/output error and task metrics must be reported."

## Risks
- **Projection Direction Degeneracy**: Learnable projections may collapse onto a few directions (deterioration of the condition number of $P^T P$), causing attention distributions to degenerate. Orthogonal regularization $\|P^T P - I\|_F^2$ is required.
- **Irreversible Information Loss**: Projection discards $(d-r)$ dimensions of information; if the task relies on features in these dimensions, performance will degrade. It is recommended to combine with residual connections (weighted combination of original attention and projected attention).
