# Manifold Representation
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use when input data resides in a high-dimensional space but is actually distributed on a low-dimensional manifold. Typical scenarios:
(1) Semantic space of natural language tokens -- although dimensionality d = 4096, the effective degrees of freedom are far less than d;
(2) Multi-modal alignment -- text and image distributions lie on different manifolds that need to be aligned;
(3) Expert feature spaces -- each expert processes a different local region of the manifold;
(4) Dimensionality reduction / compression -- exploit the low-dimensional manifold nature to reduce parameter count.
Core requirement: **leverage the low-dimensional manifold structure of data to improve representation efficiency and generalization**.

## Mathematical Inspiration
- Lenses: ../../lenses/geometric.en.md (Riemannian geometry, geodesics, curvature), ../../lenses/probabilistic.en.md (intrinsic dimensionality)
- Knowledge: ../../knowledge-base/differential-geometry/manifold.en.md (manifolds, tangent spaces, exponential maps),
  ../../knowledge-base/matrix-analysis/projection.en.md (SVD, low-rank approximation, PCA)

## Required Mathematical Background
- **Manifold Hypothesis**: Data x in R^D actually lies on a smooth d-dimensional manifold M with d << D
  Locally approximable by the tangent space T_pM isomorphic to R^d
- **Local Coordinate Chart**: phi: U subset M -> R^d, mapping a manifold patch to low-dimensional Euclidean space
  Multiple charts {phi_i} form an atlas covering the entire manifold
- **Geodesic Distance**: d_M(p, q) = inf integral ||gamma'(t)|| dt, the shortest path between two points on the manifold
  Approximate computation: Dijkstra/Isomap on a k-NN graph
- **Exponential Map / Logarithmic Map**:
  exp_p: T_pM -> M (tangent space to manifold), log_p: M -> T_pM (manifold to tangent space)
  Used to perform linear operations in the tangent space and map back to the manifold

## AI Module Form

```python
# Chart mixture: local affine approximations, not automatically a geometric atlas
z = zeros(N, d)
for k in range(K):
    z += gate(X)[:, k:k+1] * (X @ W[k].T + bias[k])
# If chart coordinates differ, align/transition them before blending.

# Euclidean-metric Stiefel update: W in R^{D x r}, W.T @ W = I
G = euclidean_gradient(loss, W)
M = W.T @ G
grad_R = G - W @ ((M + M.T) / 2)
W_next = qr(W - learning_rate * grad_R, mode='reduced').Q
```
`G - W @ (W.T @ G)` is the horizontal Grassmann projection, not the general Stiefel gradient; it loses within-frame rotations.

Geodesic stress `mean((D_graph-D_latent)**2)` is unweighted metric stress, not Sammon's weighted stress. Estimate graph distances on a connected sampled graph and state the metric; curved manifolds need not admit globally distance-preserving Euclidean coordinates of the intrinsic dimension. Sparse Laplacian regularization $\operatorname{tr}(Z^TLZ)$ is an edge-smoothness penalty and by itself admits collapsed constant representations.

## Implementable Structures
- **Chart MoE**: K local linear projections + softmax gating => natural integration with the MoE framework
- **Manifold regularization**: L_manifold = tr(Z^T L Z) / N^2, where L is the graph Laplacian and Z is the representation
  Encourages nearby samples to have similar representations
- **Intrinsic dimension estimation**: Use MLE or two-norm methods to estimate the effective dimensionality d* of the data
- **Adaptive d**: Local dimensionality varies across regions; estimate locally via PCA

## GPU Feasibility

- **D1/D2[~]**: Local projections use GEMM; sparse Laplacian loss uses SpMM/edge differences.
- **D3[~]**: Brute-force exact k-NN costs $O(N^2D)$; approximate indexing has method/data-dependent build, query and recall trade-offs. Sparse Laplacian loss costs $O(|E|d)$, not inherently $O(N^2)$. All-pairs geodesics have a separate potentially large cost.
- **D4[~]**: Chart weights store $O(KdD)$ numbers; sparse edges need endpoints and weights, $O(Nk_{nn})$. No universal 10 MB bound applies.
- **D5[~]**: fp32 distances and QR; monitor orthogonality, neighborhood recall and disconnected components.
- **D6/D8[~]**: Chart projections can batch; routing and index construction add overhead. Profile complete encode/routing/regularization work.
- **D7[~]**: Sparse graph regularization preserves the chosen edge set, not a guarantee of the unknown manifold topology.

## Paper-Worthy Formulation
"Based on the manifold hypothesis, we model D-dimensional token representations as a low-intrinsic-dimensional structure, approximate it with K local coordinate charts (Chart MoE), and use graph-Laplacian regularization to encourage local-neighborhood consistency. Embedding-error or geodesic-preservation bounds require assumptions on sampling density, manifold smoothness, graph construction, and estimator choice; in practice report neighborhood preservation, reconstruction error, and downstream metrics."

## Risks

- The manifold hypothesis and intrinsic dimension require evidence; local PCA may confuse noise with curvature.
- Chart mixtures require overlap and coordinate consistency; smooth gates alone do not create valid transition maps.
- Neighborhood errors or disconnected graphs distort graph geodesics.
- Pair smoothness with a task/reconstruction or variance constraint to avoid collapse.
