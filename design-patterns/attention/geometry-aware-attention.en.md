# Geometry-Aware Attention
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
When **known geometric relationships** exist between tokens/keys (spatial distance, manifold geodesic distance, hierarchical structure, temporal interval), the position-agnostic inner product of standard attention cannot exploit this structural information. Geometry-aware attention **directly injects geometric priors into attention weight computation**, enabling the model to naturally respect the metric structure of the underlying space. Typical scenarios include: 3D scene understanding, molecular conformation, temporal forecasting, hierarchical text structure (paragraph-sentence-word), and knowledge graphs.

## Mathematical Inspiration
- Lenses: [symmetry (metric invariance), duality (coordinate-system-independent representation)]
- Knowledge: [`../../knowledge-base/information-geometry/fisher-metric.md` (geometric metrics on distribution spaces), `../../knowledge-base/probability/concentration-inequality.md` (concentration behavior under geometric constraints)]

## Required Mathematical Knowledge
- **Metric Spaces and Distance Functions**: Euclidean distance, geodesic distance, tree distance, Wasserstein distance
- **RBF / Kernel Methods**: $k(x, y) = \exp(-d(x,y)^2 / 2\sigma^2)$, converting distance to similarity
- **Geometric Interpretation of Positional Encoding**: RoPE = action of the rotation group $SO(2)$ (relative distance encoded as rotation angle difference); ALiBi = exponentially decaying distance bias

## AI Module Form

**Core Idea**: Explicitly introduce a geometric distance term into attention scores so that attention to distant tokens naturally decays:

$$\text{GeoAttn}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d}} + \text{GeoBias}(i, j)\right) V$$

**Scheme A: Distance-Biased Attention (General Metric Spaces)**:
```python
# d_ij is the geometric distance between token i and j (precomputed or computed online)
# Learnable distance bias function
distance_bias = MLP(d_ij)  # or simply -alpha * d_ij
scores = (Q @ K.T) / sqrt(d) + distance_bias
attn = softmax(scores) @ V
```

**Scheme B: Relative Positional Encoding (Geometric Generalization of RoPE / ALiBi)**:
```python
# Generalize RoPE: position -> group element g_i, relative position -> g_i g_j^{-1}
# Learnable relative position bias on arbitrary metric spaces
def geo_attention(Q, K, V, positions):
    rel_pos = pairwise_difference(positions)       # (n, n, coord_dim)
    geo_bias = geo_encoder(rel_pos)               # (n, n) learnable mapping
    scores = (Q @ K.T) / sqrt(d) + geo_bias
    return softmax(scores) @ V
```

**Scheme C: Manifold-Aware Attention (Non-Euclidean Spaces)**:
```python
# When tokens reside on a non-Euclidean manifold (hyperbolic space, sphere),
# use geodesic distance instead of Euclidean distance
def manifold_attention(Q, K, V, manifold):
    geodist = manifold.geodesic_distance_matrix(positions)  # (n, n)
    geo_kernel = exp(-geodist^2 / (2 * sigma^2))  # RBF kernel
    scores = (Q @ K.T) / sqrt(d) + log(geo_kernel + eps)
    return softmax(scores) @ V
```

## Implementable Architectures
- **RoPE Extensions**: From $SO(2)$ rotations to higher-dimensional rotation groups $SO(2k)$, encoding multi-dimensional positional information (2D image patches, 3D voxels)
- **Hierarchical Positional Bias**: Use LCA (Lowest Common Ancestor) depth as distance in tree structures, suitable for hierarchical geometric of documents and code
- **Molecular Conformation Attention**: 3D atomic coordinates -> distance matrix -> geometric bias, used in molecular GNNs and protein structure prediction

## GPU Feasibility
- **D1**: Distance matrices and bias matrices are dense tensors with element-wise operations
- **D2**: The main body $Q K^T$ is standard GEMM; geometric bias is additive and does not interrupt GEMM
- **D3**: Pairwise distance matrix construction and storage are $O(n^2)$; however, block-wise computation + online softmax can avoid materializing the full matrix
- **D4**: The $n \times n$ distance matrix occupies GPU memory; mitigated by block/streaming computation (compatible with FlashAttention)
- **D5**: Distance computation and bias addition are stable under bf16; the exp in RBF requires overflow caution (clamp distances)
- **D6**: Distance computation and attention can be pipelined; pairwise distances can be computed in parallel blocks
- **D7**: Distant biases tend toward $-\infty$ (approaching zero after softmax), naturally inducing structured sparsity (local attention windows)
- **D8**: Geometric bias can be fused into FlashAttention's online softmax loop (added after $QK^T$, before softmax)

## Paper Phrasing
"We propose geometry-aware attention, which explicitly injects learnable geometric distance bias terms into attention scores, enabling the model to naturally respect the metric structure of the input space. This achieves exponential decay of attention to distant tokens without increasing parameter count, while maintaining compatibility with FlashAttention."

## Risks
- **Geometric Prior Conflicting with Data**: If geometric distance is inconsistent with semantic relevance (e.g., distant but semantically related tokens in text), strong geometric bias will impair model expressiveness. The bias should be learnable and overridable by content-based attention.
- **Non-Differentiability of Distance Computation**: Certain distances (graph shortest path, tree LCA depth) are non-differentiable or computationally expensive. Differentiable relaxations (softmin instead of min) or precomputed distance matrices are needed.
