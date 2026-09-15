# Graph Routing
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use when there exists a known or learnable topological structure among modules/experts. Typical scenarios:
(1) Hierarchical MoE -- experts organized in a tree structure, routing proceeds along tree edges;
(2) Pipeline/serial routing -- inputs pass through multiple processing stages in DAG order;
(3) Spatial/temporal correlation routing -- tokens at adjacent positions tend to be routed to similar experts (spatial continuity);
(4) Knowledge-graph-guided expert selection -- experts organized according to a concept graph.
Core requirement: **leverage structural priors to constrain routing decisions and reduce the search space**.

## Mathematical Inspiration
- Lenses: ../../lenses/geometric.en.md (graph Laplacian, spectral graph theory), ../../lenses/probabilistic.en.md (message passing, information flow)
- Knowledge: ../../knowledge-base/matrix-analysis/projection.en.md (adjacency matrix, spectral decomposition),
  ../../knowledge-base/optimization/lagrangian-duality.en.md (variational on graphs, diffusion processes)

## Required Mathematical Background

- For symmetric nonnegative adjacency $A$, $L=D-A$ and $L_{sym}=I-D^{-1/2}AD^{-1/2}$. Specify isolated-node handling.
- GCN smoothing uses normalized **adjacency** $S=\tilde D^{-1/2}(A+I)\tilde D^{-1/2}$, not $L_{sym}$ itself; $H'=\sigma(SHW)$.
- A random walk uses $P=D^{-1}A$, with a dangling-node convention. A masked softmax can normalize learned edge logits; unmasked softmax makes absent edges positive and changes the graph.
- Fiedler vectors solve a continuous relaxation of graph-cut objectives. Thresholding does not generally yield an exact balanced minimum cut or certify routing diversity.
- A balanced binary decision tree visits $O(\log K)$ nodes per token, but generally stores $O(Kd)$ node parameters, not $O(d\log K)$.

## AI Module Form

```python
# A: nonnegative expert adjacency with explicit self-loops/dangling-node handling
P = A / A.sum(-1, keepdim=True)
route = softmax(X @ W_gate, dim=-1)  # probabilities, N x K
for _ in range(t):
    route = route @ P               # sparse diffusion without explicitly forming P**t

A_tilde = A + eye(K)
deg = A_tilde.sum(-1)
S = deg[:, None]**(-0.5) * A_tilde * deg[None, :]**(-0.5)
H1 = relu(S @ expert_embeddings @ W1)
score = X @ (S @ H1 @ W2).T

# Hard tree traversal: each token has its own visited node
node = root_index_for_each_token(N)
for level in range(tree_depth):
    p_right = sigmoid((X * node_weights[node]).sum(-1) + node_bias[node])
    take_right = p_right > 0.5
    node = where(take_right, right_child[node], left_child[node])
```
Hard traversal is conditional and nondifferentiable at decisions; use supervised routing, stochastic estimators or a declared relaxation. Evaluating every branch for differentiable soft routing generally loses the logarithmic inference cost.

## Implementable Structures
- **Sparse adjacency matrix**: Use torch.sparse to store A; sparse matmul replaces dense operations
- **Precomputed diffusion kernel**: P_t fixed during early training, periodically recomputed (once per epoch)
- **Graph structure learning**: A = softmax(MLP(E_i + E_j)) parameterizes edge weights for end-to-end learning
- **Hierarchical tree implementation**: Represented as a complete binary tree array with level-wise vectorization

## GPU Feasibility

- **D1/D2[~]**: Gate GEMM plus sparse adjacency propagation; sparse GPU benefit depends on degree distribution and batching.
- **D3[~]**: Gate $O(NdK)$ plus $t$ sparse diffusion steps $O(tN|E|)$; dense precomputed $P^t$ instead costs $O(NK^2)$ to apply and may densify. Hard balanced trees cost $O(Nd\log K)$ with irregular gathers.
- **D4[~]**: Graph storage $O(|E|)$; general binary tree parameters $O(Kd)$. Count routing probabilities $O(NK)$ where materialized.
- **D5[~]**: Accumulate probabilities in fp32; monitor drift of row sums and top-choice margins.
- **D6[~]**: Tokens and same-depth nodes can batch, but traversal levels and diffusion rounds are sequential.
- **D7/D8[~]**: Sparse propagation and dense feature GEMM are distinct operations; fusion and sparse crossover require concrete kernel measurements.

## Paper-Worthy Formulation

“We encode the declared expert graph with normalized adjacency diffusion or a conditional decision tree. We report traversal depth, visited experts, mixing behavior, graph ablations, actual compute and latency; spectral connectivity alone does not guarantee a diversity–coherence trade-off.”

## Risks
- Incorrect graph structure priors can misguide routing toward suboptimal experts
- Over-smoothing in graph diffusion (excessively large t) causes all tokens to route to the same expert
- Learnable graph structure increases parameter count and overfitting risk
- Binary classification errors in hierarchical trees accumulate layer by layer, degrading performance at greater depths
