# Spectral Token Pruning
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Target Problem
Use when pruning must be based on the structural importance of tokens (rather than raw attention scores alone): KV-Cache eviction, long-document summarization, inference acceleration (reducing $O(L^2)$), multimodal vision token compression. Core objective: **quantify the structural importance of each token via spectral methods, achieving pruning with minimal information loss**.

## Mathematical Foundations
- Lenses: ../../lenses/spectral.en.md (identifying dominant spectral components, discarding redundant ones), ../../lenses/algorithmic.en.md (complexity classification and approximation algorithms), ../../lenses/perturbation.en.md (pruning = sparse perturbation, Cauchy interlacing theorem / Bauer-Fike pseudospectral analysis for spectral drift bounds)
- Knowledge: ../../knowledge-base/matrix-analysis/spectral-decomposition.en.md (spectral radius, eigenvector centrality), ../../knowledge-base/matrix-analysis/matrix-perturbation.en.md (Geršgorin discs, perturbation bounds), ../../knowledge-base/matrix-analysis/positive-semidefinite.en.md (Gram matrix PSD structure)

## Required Mathematical Background
- **Eigenvector Centrality**: For an unmasked, positive, irreducible row-stochastic attention matrix $A$, the right principal eigenvector $Ax = \lambda_1 x$ degenerates to the all-ones vector (since $A \mathbf{1} = \mathbf{1}$), making it useless for distinguishing token importance; the left principal eigenvector $x^T A = \lambda_1 x^T$ (equivalently $A^T x = \lambda_1 x$) can be used as a stationary-distribution / PageRank-like score. For causal or heavily masked attention, the chain is often reducible and the stationary distribution may collapse toward early tokens; use a K/V similarity graph, a symmetrized graph, or teleportation $A_\alpha=\alpha A+(1-\alpha)\mathbf{1}\pi^T$ before interpreting PageRank.
- **Spectral Gap**: $\Delta = \lambda_1 - \lambda_2$ governs the rate of information diffusion; large $\Delta \Rightarrow$ a few tokens dominate $\Rightarrow$ safe to prune
- **Fiedler Vector**: the second-smallest eigenvector of the Laplacian $L_{\text{sym}}$ yields the optimal bipartition; small magnitude = partition boundary = important
- **Spectral Perturbation Analysis**: Pruning changes the matrix dimension and cannot directly apply the Weyl theorem. For a principal submatrix of a fixed Hermitian matrix (e.g., a symmetrized matrix $S=(A+A^T)/2$ without re-normalization), Cauchy interlacing bounds eigenvalue interlacing. If the Laplacian / attention graph is re-normalized after pruning, the matrix itself has changed, so this bound no longer applies directly. For non-symmetric row-stochastic matrices, spectral radius perturbation can be bounded via Bauer--Fike or pseudospectral analysis, though the bounds are less tight than in the Hermitian case.

## AI Module Specification
```
Module: SpectralTokenPruner
Input: K ∈ R^{L×d}    Parameters: retention ratio ρ ∈ (0,1]

Method 1 - Spectral centrality pruning (power iteration, left eigenvector):
  A = softmax(K @ K^T / √d)                  // L×L row-stochastic similarity graph; handle causal/masked cases separately
  // ⚠ A is row-stochastic: right principal eigenvector = all-ones (degenerate); must use left eigenvector
  // Left principal eigenvector = right eigenvector of A^T; PageRank interpretation is stable only for irreducible/teleported chains
  v = ones(L) / √L
  for t in range(5): v = A^T @ v; v = v / ‖v‖  // power iteration on A^T (not A), O(L²·T)
  indices = topk(v, ceil(ρ * L))              // retain tokens with highest left-eigenvector centrality

Method 2 - Geršgorin cheap pruning (zero iterations):
  S = K @ K^T / √d                         // L×L raw similarity matrix (pre-softmax, so row sums vary)
  gersh_score = sum(|S|, dim=1) - |diag(S)|  // Geršgorin disc radius R_i = sum_{j!=i}|S_{ij}|, measures connectivity
  indices = topk(gersh_score, ceil(ρ * L))    // O(L²) elementwise, no power iteration needed

Method 3 - Differentiable spectral pruning (end-to-end):
  v = power_iteration(A^T, T=5)               // left principal eigenvector (power iteration on A^T)
  gate = sigmoid(v @ W_gate / τ)               // soft gating, τ annealing
  K_gated = gate * K                            // per-token scaling
  L_sparse = ‖gate‖_1 / L                       // sparsity regularization
```

## Implementable Architectures
- **Power iteration centrality**: 5-step matvec to estimate the principal eigenvector of $A^T$ (i.e., the left principal eigenvector / stationary distribution of $A$), $O(L^2 \cdot 5)$, suitable for moderate-length sequences
- **Sampling approximation**: for $L > 4096$, sample $m$ anchor points and construct an $m \times m$ submatrix for spectral analysis
- **Multi-head fusion**: average the attention graphs across different heads before performing spectral analysis
- **Progressive pruning**: incrementally increase the pruning ratio across layers (light pruning in shallow layers, heavy pruning in deep layers)

## GPU Feasibility
- Tensorization / GEMM: $A = KK^T$ is a GEMM; power iteration is a chain of matvecs; Geršgorin is elementwise
- Complexity: power iteration $O(L^2 T)$, $T \leq 10$; Geršgorin $O(L^2)$ elementwise, zero iterations
- Memory: the $L \times L$ similarity matrix exceeds 256 MB for $L > 8K$, requiring chunking or sampling
- Low precision: power iteration is stable in bf16 (normalization prevents overflow); Geršgorin is purely elementwise with no precision concerns
- Parallelism: spectral analysis across heads / layers is independently parallel; matvec is highly parallelizable
- Operator fusion: $KK^T$ + row-sum + topk can be fused into a single kernel

## Paper-Worthy Formulation
"We cast token pruning as spectral sparsification of a directed graph: on unmasked irreducible row-stochastic graphs, left-eigenvector / PageRank-like centrality can quantify global token importance; for causal or heavily masked attention, use a K/V similarity graph, a symmetrized graph, or teleported PageRank to avoid stationary-mass collapse toward early tokens. Cauchy interlacing applies to principal submatrices of fixed Hermitian matrices; after re-normalization or for non-symmetric graphs, use weaker but applicable diagnostics such as pseudospectral analysis, Bauer--Fike, or Geršgorin discs."

## Risks
- **$L \times L$ matrix memory bottleneck**: for long sequences the similarity matrix itself may exceed available memory, necessitating sampling or chunking
- **Slow power iteration convergence**: when $\lambda_1 / \lambda_2 \approx 1$, $O(1/\Delta)$ iterations are required, reducing efficiency
- **Semantics $\neq$ spectral importance**: certain tokens (e.g., punctuation) have low spectral centrality yet are semantically critical; purely spectral methods may prune them erroneously
- **Hard pruning is non-differentiable**: top-k blocks gradients; end-to-end training requires softmax relaxation or Gumbel-topk
