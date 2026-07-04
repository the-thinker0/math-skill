# Graph Routing
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
Use when there exists a known or learnable topological structure among modules/experts. Typical scenarios:
(1) Hierarchical MoE -- experts organized in a tree structure, routing proceeds along tree edges;
(2) Pipeline/serial routing -- inputs pass through multiple processing stages in DAG order;
(3) Spatial/temporal correlation routing -- tokens at adjacent positions tend to be routed to similar experts (spatial continuity);
(4) Knowledge-graph-guided expert selection -- experts organized according to a concept graph.
Core requirement: **leverage structural priors to constrain routing decisions and reduce the search space**.

## Mathematical Inspiration
- Lenses: lenses/geometric.md (graph Laplacian, spectral graph theory), lenses/probabilistic.md (message passing, information flow)
- Knowledge: knowledge-base/matrix-analysis/projection.md (adjacency matrix, spectral decomposition),
  knowledge-base/optimization/lagrangian-duality.md (variational on graphs, diffusion processes)

## Required Mathematical Background
- **Graph Laplacian**: L = D - A (combinatorial) or L_sym = D^{-1/2} L D^{-1/2} (normalized)
  Eigendecomposition L = U Lambda U^T provides the graph frequency-domain basis; low-frequency components correspond to smooth signals
- **Graph Diffusion / Random Walk**: P = D^{-1} A is the transition matrix, P^t describes the distribution after t steps
  PageRank: pi = alpha * P^T * pi + (1 - alpha) * v, balancing graph structure and prior preferences
- **Graph Neural Network Message Passing**:
  h_i^{(l+1)} = sigma(sum_{j in N(i)} W^{(l)} h_j^{(l)} / sqrt(d_i * d_j))
  Equivalent to a single sparse matrix multiplication L_sym * H * W
- **Min-Cut Spectral Clustering**: min cut(A, B) s.t. vol(A) = vol(B) => approximate solution given by the Fiedler vector of L

## AI Module Form
```
Module: GraphRouter
Input: token representations X in R^{N x d}, expert graph G = (V, E) with |V| = K

Method 1 - Graph Diffusion Routing (precomputed):
  A in R^{K x K}   // expert adjacency matrix (predefined or learnable)
  P = softmax(A / tau, dim=-1)   // normalized transition probabilities
  P_t = matrix_power(P, t)       // t-step diffusion, t = 2 ~ 5
  // routing score = initial score * diffusion matrix
  score_init = X @ W_gate        // N x K, standard gate
  score_final = score_init @ P_t // N x K, graph-diffusion smoothed
  // A single GEMM (N x K) @ (K x K) incorporates graph structure

Method 2 - GNN Routing (learnable graph structure):
  H_0 = expert_embeddings        // K x d
  H_1 = ReLU(L_norm @ H_0 @ W_1) // 1-layer GCN
  H_2 = L_norm @ H_1 @ W_2      // 2-layer GCN
  score = X @ H_2^T              // N x K routing scores
  // Graph structure updated end-to-end via learnable parameterization of A

Method 3 - Hierarchical Tree Routing (O(log K) complexity):
  // Experts organized as a binary tree; each internal node is a binary classifier
  for level in range(depth):      // depth = log2(K)
    direction = sigmoid(X @ w_level + b_level)  // left/right subtree selection
    path_prob *= direction         // accumulate path probability
  // Total computation: O(N * d * log K) vs. O(N * d * K) for standard MoE
```

## Implementable Structures
- **Sparse adjacency matrix**: Use torch.sparse to store A; sparse matmul replaces dense operations
- **Precomputed diffusion kernel**: P_t fixed during early training, periodically recomputed (once per epoch)
- **Graph structure learning**: A = softmax(MLP(E_i + E_j)) parameterizes edge weights for end-to-end learning
- **Hierarchical tree implementation**: Represented as a complete binary tree array with level-wise vectorization

## GPU Feasibility
- **Tensorization**: GCN layers perform sparse matrix times dense matrix (SpMM), supported by both PyTorch and cuSPARSE
- **GEMM-mappable**: score_init @ P_t in Method 1 is standard GEMM (N x K) @ (K x K)
- **Complexity**: Method 1 O(N * K^2) diffusion + O(N * K * d) gate; Method 3 O(N * d * log K) significantly better than O(N * d * K)
- **Memory & KV-Cache**: A matrix stored sparsely at K x K; hierarchical tree parameters d x log K are negligible
- **Low-precision stability**: Probability matrix P and softmax in fp16 require attention to normalization precision
- **Parallelism & Communication**: GNN message passing can be batched in parallel; hierarchical tree nodes at the same level can be evaluated independently in parallel
- **Sparse structure**: Graph adjacency matrices are naturally sparse (degree << K); SpMM reduces from O(K^2) to O(K * avg_deg)
- **Operator fusion**: L_norm @ H @ W in GCN can be fused into a single sparse GEMM

## Paper-Worthy Formulation
"Leveraging hierarchical tree/graph topology among experts, we compress routing decisions from a flat O(N * K) search to O(N * log K) tree traversal or O(N * K * avg_deg) graph diffusion. Fiedler spectral analysis reveals that the graph's algebraic connectivity lambda_2 directly governs the diversity-coherence trade-off in routing."

## Risks
- Incorrect graph structure priors can misguide routing toward suboptimal experts
- Over-smoothing in graph diffusion (excessively large t) causes all tokens to route to the same expert
- Learnable graph structure increases parameter count and overfitting risk
- Binary classification errors in hierarchical trees accumulate layer by layer, degrading performance at greater depths
