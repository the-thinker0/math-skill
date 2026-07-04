# Spectral Token Pruning

## Target Problem
Use when pruning must be based on the structural importance of tokens (rather than raw attention scores alone): KV-Cache eviction, long-document summarization, inference acceleration (reducing $O(L^2)$), multimodal vision token compression. Core objective: **quantify the structural importance of each token via spectral methods, achieving pruning with minimal information loss**.

## Mathematical Foundations
- Lenses: lenses/spectral.md (identifying dominant spectral components, discarding redundant ones), lenses/algorithmic.md (complexity classification and approximation algorithms), lenses/perturbation.md (pruning = sparse perturbation, Weyl bound for spectral drift estimation)
- Knowledge: knowledge-base/matrix-analysis/spectral-decomposition.md (spectral radius, eigenvector centrality), knowledge-base/matrix-analysis/matrix-perturbation.md (Geršgorin discs, perturbation bounds), knowledge-base/matrix-analysis/positive-semidefinite.md (Gram matrix PSD structure)

## Required Mathematical Background
- **Eigenvector Centrality**: the principal eigenvector of the attention matrix $A$ satisfies $Ax = \lambda_1 x$; component $x_i$ quantifies the global influence of token $i$ (Perron--Frobenius guarantees non-negativity)
- **Spectral Gap**: $\Delta = \lambda_1 - \lambda_2$ governs the rate of information diffusion; large $\Delta \Rightarrow$ a few tokens dominate $\Rightarrow$ safe to prune
- **Fiedler Vector**: the second-smallest eigenvector of the Laplacian $L_{\text{sym}}$ yields the optimal bipartition; small magnitude = partition boundary = important
- **Weyl Perturbation Bound**: pruning = removing rows/columns = rank-1 perturbation $E$, $|\lambda_i(A) - \lambda_i(A_{\text{pruned}})| \leq \|E\|_2$

## AI Module Specification
```
Module: SpectralTokenPruner
Input: K ∈ R^{L×d}    Parameters: retention ratio ρ ∈ (0,1]

Method 1 - Spectral centrality pruning (power iteration):
  A = softmax(K @ K^T / √d)                  // L×L similarity graph
  v = ones(L) / √L
  for t in range(5): v = A @ v; v = v / ‖v‖  // power iteration O(L²·T)
  indices = topk(v, ceil(ρ * L))              // retain tokens with highest centrality

Method 2 - Geršgorin cheap pruning (zero iterations):
  A = softmax(K @ K^T / √d)
  gersh_score = |diag(A)| + sum(|A|, dim=1)    // disc upper bound, O(L²) elementwise
  indices = topk(gersh_score, ceil(ρ * L))

Method 3 - Differentiable spectral pruning (end-to-end):
  v = power_iteration(A, T=5)
  gate = sigmoid(v @ W_gate / τ)               // soft gating, τ annealing
  K_gated = gate * K                            // per-token scaling
  L_sparse = ‖gate‖_1 / L                       // sparsity regularization
```

## Implementable Architectures
- **Power iteration centrality**: 5-step matvec to estimate the principal eigenvector, $O(L^2 \cdot 5)$, suitable for moderate-length sequences
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
"We cast token pruning as spectral sparsification of a directed graph: leveraging the Perron--Frobenius principal eigenvector of the attention matrix to quantify global centrality, with the Weyl perturbation bound guaranteeing that post-pruning spectral drift does not exceed the $\ell_2$ norm of the removed tokens, while Geršgorin discs provide an $O(L^2)$ inexpensive alternative."

## Risks
- **$L \times L$ matrix memory bottleneck**: for long sequences the similarity matrix itself may exceed available memory, necessitating sampling or chunking
- **Slow power iteration convergence**: when $\lambda_1 / \lambda_2 \approx 1$, $O(1/\Delta)$ iterations are required, reducing efficiency
- **Semantics $\neq$ spectral importance**: certain tokens (e.g., punctuation) have low spectral centrality yet are semantically critical; purely spectral methods may prune them erroneously
- **Hard pruning is non-differentiable**: top-k blocks gradients; end-to-end training requires softmax relaxation or Gumbel-topk
