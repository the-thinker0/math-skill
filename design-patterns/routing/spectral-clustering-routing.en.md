# Spectral Clustering Routing
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「✅ 已验证 / ⚠️ 可改造需验证 / ❌ 不可行」。未标注的视为理论可行，需工程验证。

## Applicable Problems
Use when routing needs to be based on the intrinsic similarity structure of tokens/samples. Typical scenarios:
(1) Unsupervised expert assignment -- when no routing labels are available, spectral clustering automatically discovers natural token clusters;
(2) Adaptive expert initialization -- use spectral clustering results to initialize expert parameters at the beginning of training;
(3) Input-aware dynamic clustering -- different batches have different token distributions, requiring adaptive routing;
(4) Multi-granularity clustering -- different layers use spectral clustering at different granularities (coarse to fine).
Core requirement: **discover the intrinsic cluster structure of data for routing or expert initialization**.

## Mathematical Inspiration
- Lenses: lenses/geometric.md (spectral graph theory, Laplacian eigenmaps), lenses/variational.md (relaxation and approximation)
- Knowledge: knowledge-base/matrix-analysis/projection.md (eigendecomposition, Rayleigh quotient),
  knowledge-base/differential-geometry/manifold.md (manifold learning, graph cuts)

## Required Mathematical Background
- **Spectral Clustering (Ng-Jordan-Weiss)**:
  1. Construct similarity graph W_{ij} = exp(-||x_i - x_j||^2 / (2 sigma^2))
  2. Compute normalized Laplacian L_sym = I - D^{-1/2} W D^{-1/2}
  3. Extract the k smallest eigenvectors U_k in R^{N x k}
  4. Apply k-means to the rows of U_k to obtain k clusters
- **Nystrom Approximation**: When N is too large for the full W matrix, sample m << N points
  W approximately C * W_m^{-1} * C^T, reducing eigendecomposition to m x m
- **Spectral Relaxation Continuation**: Discrete cluster assignment => continuous eigenvectors => differentiable routing
  Use softmax(U_k * W_proj) instead of hard k-means assignment
- **Power Iteration Acceleration**: Full eigendecomposition is unnecessary; only the top k eigenvectors are needed
  Use Lanczos/Arnoldi iteration O(N^2 * k * iter) or randomized SVD O(N * k * log k)

## AI Module Form
```
Module: SpectralClusterRouter
Input: X in R^{N x d}, number of clusters K

Method 1 - Online Spectral Clustering Routing (periodic updates during training):
  // Update cluster centers every M steps; use nearest neighbor at inference
  W = exp(-cdist(X_sample, X_sample) / (2 sigma^2))  // m x m sampled similarity
  L = I - D^{-1/2} W D^{-1/2}                         // normalized Laplacian
  U_k = eigsh(L, k=K, which='SM')                     // K smallest eigenvectors
  centers = kmeans(U_k, K)                             // K cluster centers
  // Routing: project new tokens into spectral space and assign
  proj = X @ W_proj                                    // N -> K dimensional projection (learnable)
  assignment = argmin(cdist(proj, centers))             // nearest center assignment

Method 2 - Differentiable Spectral Routing (end-to-end):
  // Use softmax relaxation instead of hard assignment
  sim_matrix = X @ X^T                                 // N x N (or sampled m x m)
  A = exp(sim_matrix / tau)                            // similarity graph (learnable tau)
  D_inv_sqrt = diag(1 / sqrt(sum(A, dim=1) + eps))
  L_norm = I - D_inv_sqrt @ A @ D_inv_sqrt             // normalized Laplacian
  // Approximate top K eigenvectors (power iteration + orthogonalization)
  U_k = power_iteration_approx(L_norm, K, steps=5)    // N x K
  // Soft assignment
  cluster_logits = U_k @ W_cluster                     // N x K (learnable projection)
  route_probs = softmax(cluster_logits / tau_route)     // soft routing probabilities

Method 3 - Anchor Spectral Clustering (large-scale):
  anchors = kmeans_pp(X, m)                             // m anchor points, m << N
  Z = exp(-cdist(X, anchors) / (2 sigma^2))             // N x m affinity matrix
  L_anchor = I - D_z^{-1/2} Z^T Z D_z^{-1/2}            // m x m Laplacian
  U_k = eigsh(L_anchor, K)                             // m x K eigenvectors
  route = Z @ U_k @ W_proj                              // N x K routing scores
```

## Implementable Structures
- **Periodic offline clustering**: Every N_step steps, collect token representations => offline spectral clustering => update routing table
- **Nystrom sampling**: Randomly sample m = 1024 representative points, reducing the N x N problem to m x m
- **Power iteration implementation**: 5-10 power iteration steps + Gram-Schmidt orthogonalization, GPU-friendly
- **Progressive training**: Early stage uses k-means coarse routing => mid-stage spectral clustering refinement => late-stage fine-tuning of routing network

## GPU Feasibility
- **Tensorization**: Similarity matrix X @ X^T is GEMM; Laplacian construction is element-wise + diagonal matrix operations
- **GEMM-mappable**: Z^T @ Z in Method 3 is GEMM (m x N) @ (N x m); Z @ U_k is GEMM (N x m) @ (m x K)
- **Complexity**: Full spectral clustering O(N^2 * K) does not scale; Nystrom O(N * m * K + m^3); power iteration O(N^2 * K * T)
- **Memory & KV-Cache**: N x N similarity matrix exceeds 64 MB when N > 4096; sampling-based dimensionality reduction is essential
- **Low-precision stability**: Eigendecomposition recommended in fp32; exp(-dist/sigma^2) in fp16 requires distance clipping
- **Parallelism & Communication**: Power iteration matvec is highly parallel; k-means assign + update steps can be batch-parallelized
- **Sparse structure**: k-NN graph replaces fully connected graph; W sparsity > 95%, enabling SpMM acceleration
- **Operator fusion**: Diagonal scaling in D^{-1/2} @ A @ D^{-1/2} can be fused; cdist + exp + normalize can be fused

## Paper-Worthy Formulation
"We achieve differentiable routing via continuous relaxation of spectral clustering: constructing the normalized Laplacian of the token similarity graph, reducing the O(N^2) eigendecomposition to O(Nm + K^3) through Nystrom approximation, and enabling GPU-friendly online spectral clustering via power iteration. Clustering quality, measured by Normalized Cut, guarantees an O(sqrt(log(N/K))) approximation ratio."

## Risks
- The memory and computation cost of the N x N similarity matrix does not scale for long sequences; sampling or k-NN sparsification is mandatory
- Eigendecomposition is non-differentiable (gradients undefined when eigenvalues coincide); end-to-end training requires relaxation or stop-gradient
- The number of clusters K must be specified a priori, and re-clustering is needed when K changes
- The bandwidth parameter sigma is sensitive to clustering quality: too small causes isolated points, too large causes cluster merging
