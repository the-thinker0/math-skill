# Spectral Clustering Routing
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use when routing needs to be based on the intrinsic similarity structure of tokens/samples. Typical scenarios:
(1) Unsupervised expert assignment -- when no routing labels are available, spectral clustering automatically discovers natural token clusters;
(2) Adaptive expert initialization -- use spectral clustering results to initialize expert parameters at the beginning of training;
(3) Input-aware dynamic clustering -- different batches have different token distributions, requiring adaptive routing;
(4) Multi-granularity clustering -- different layers use spectral clustering at different granularities (coarse to fine).
Core requirement: **discover the intrinsic cluster structure of data for routing or expert initialization**.

## Mathematical Inspiration
- Lenses: ../../lenses/geometric.en.md (spectral graph theory, Laplacian eigenmaps), ../../lenses/variational.en.md (relaxation and approximation)
- Knowledge: ../../knowledge-base/matrix-analysis/projection.en.md (eigendecomposition, Rayleigh quotient),
  ../../knowledge-base/differential-geometry/manifold.en.md (manifold learning, graph cuts)

## Required Mathematical Background

- For symmetric nonnegative affinities $W$, form $S=D^{-1/2}WD^{-1/2}$ and $L=I-S$. The smallest algebraic eigenvalues of $L$ correspond to largest **algebraic** eigenvalues of $S$, not generally those of raw $W$.
- Ng–Jordan–Weiss row-normalizes the selected eigenvector matrix before k-means. Degenerate zero-degree nodes need an explicit convention.
- Plain power iteration targets largest magnitude. For potentially indefinite $S$, use a suitable shift such as $(I+S)/2$ or a solver requesting the largest algebraic eigenvalues; do not use unqualified SVD as an eigenvalue-order substitute.
- Eigenvectors carry sign and repeated-eigenspace rotation ambiguity. A learned linear map on raw eigenvectors is not automatically invariant to this choice; use projectors, alignment, invariant features or stable stored bases.
- Nyström for a normalized kernel must use normalized cross-affinities and the eigenvalues of $S$, namely $1-\lambda_j(L)$; near-zero denominators require truncation.

## AI Module Form

```python
# Fixed landmarks X_ref; frozen reference graph and normalization
W_ref = rbf_affinity(X_ref, X_ref)
d_ref = W_ref.sum(-1)
S_ref = W_ref / sqrt(d_ref[:, None] * d_ref[None, :])
lam, U = largest_algebraic_eigenpairs(S_ref, K)
keep = abs(lam) > eigenvalue_tolerance
lam, U = lam[keep], U[:, keep]
centers = kmeans(row_normalize(U), K)

W_cross = rbf_affinity(X_new, X_ref)
d_new = W_cross.sum(-1)          # extension degree convention, reference degrees frozen
S_cross = W_cross / sqrt(d_new[:, None] * d_ref[None, :])
embedding = (S_cross @ U) / lam[None, :]
assignment = nearest_center(row_normalize(embedding), centers)
```
This is an extension of the **frozen reference** normalized kernel; inserting all new points and recomputing full graph degrees gives a different operator. Compare held-out extensions against a recomputed small graph.

**Anchor graph alternative**: For nonnegative $Z\in\mathbb R^{N\times m}$ with nonzero row/column sums, set $B=D_{row}^{-1/2}ZD_{col}^{-1/2}$. Compute leading eigensystem $(V,\Lambda)$ of $B^TB$; the point eigenvectors of $BB^T$ are $U=BV\Lambda^{-1/2}$ on retained positive eigenvalues. Row-normalize $U$ before clustering. This explicitly defines a normalized bipartite operator rather than treating unnormalized $ZV$ as an exact Nyström extension.

## Implementable Structures
- **Periodic offline clustering**: Every N_step steps, collect token representations => offline spectral clustering => update routing table
- **Nystrom sampling**: Randomly sample m = 1024 representative points, reducing the N x N problem to m x m
- **Power iteration implementation**: 5-10 power iteration steps + Gram-Schmidt orthogonalization, GPU-friendly
- **Progressive training**: Early stage uses k-means coarse routing => mid-stage spectral clustering refinement => late-stage fine-tuning of routing network

## GPU Feasibility

- **D1/D2[~]**: Affinity construction and normalization are tensor operations; eigensolvers include global reductions and orthogonalization.
- **D3[~]**: Dense affinities cost $O(N^2d)$; block iterations $O(TN^2K)$ plus orthogonalization. Forming an anchor Gram costs $O(Nm^2)$, its full EVD $O(m^3)$, extension $O(NmK)$, in addition to $O(Nmd)$ affinities.
- **D4[~]**: An fp32 dense $N^2$ matrix uses $4N^2$ bytes (64 MiB at $N=4096$). Anchor storage is $O(Nm+m^2)$ unless streamed.
- **D5[~]**: Compute eigenspaces in fp32/fp64, report eigengaps and residuals, and avoid differentiating arbitrary bases across multiplicities.
- **D6/D7[~]**: k-NN sparsity can help, but graph construction and nearest-neighbor recall have separate costs; fixed iteration count does not certify convergence.
- **D8[~]**: Elementwise affinity scaling may fuse; eigensolver and global k-means stages retain dependencies.

## Paper-Worthy Formulation
"We implement routing through a continuous relaxation of spectral clustering: construct the normalized Laplacian of the token similarity graph, use Nystrom / anchor approximations plus power iteration to avoid a full O(N^3) eigendecomposition, and express the main work as GEMM, matvecs, and k-means. Normalized Cut can be reported as a clustering-quality metric, but approximation ratios depend on graph-model, sampling, and solver assumptions and should not be claimed unconditionally."

## Risks

- Kernel bandwidth, disconnected components and zero degrees can change the inferred cluster count.
- Eigenvector derivatives become unstable near repeated eigenvalues; invariant subspace quantities may remain well-defined if their boundary gap stays open.
- Re-clustering can permute expert labels; align labels/bases before updating a trained router.
- Report exact-small-graph versus approximate routing disagreement, extension error, latency and downstream quality.
