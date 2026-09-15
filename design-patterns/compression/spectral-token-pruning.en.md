# Spectral Token Pruning

> Rigor convention: [v] denotes a checkable graph/matrix relation or count; [~] denotes a heuristic requiring task and hardware validation. Centrality is not an information-preservation guarantee.

## Target Problem
Explore token selection based on graph centrality, connectivity, or spectral representations for KV eviction, visual-token compression, and long documents. These are candidate pruning scores; without a separate proof, they are neither minimum-information-loss pruning nor spectrally guaranteed sparsification.

## Mathematical Foundations
- Lenses: `../../lenses/spectral.en.md`, `../../lenses/algorithmic.en.md`, `../../lenses/perturbation.en.md`.
- Knowledge: `../../knowledge-base/matrix-analysis/spectral-decomposition.en.md`, `../../knowledge-base/matrix-analysis/matrix-perturbation.en.md`, `../../knowledge-base/matrix-analysis/positive-semidefinite.en.md`.

## Required Mathematical Background
- **Left versus right eigenvectors [v]:** row-stochastic A always satisfies A1=1. On an unmasked irreducible, aperiodic chain, a left stationary probability vector supplies one centrality score. Causal/masked graphs may be reducible; teleportation A_alpha=alpha A+(1-alpha)1 pi^T gives a unique stationary distribution for 0<alpha<1 and strictly positive pi.
- **This example needs no power iteration [v]:** for S=KK^T/sqrt(d) and W_ij=exp(S_ij), W is symmetric and positive. The row-normalized A has stationary p_i=s_i/sum_j s_j, where s_i=sum_j W_ij, since p_i A_ij=W_ij/sum_j s_j=p_j A_ji. Compute this directly with logsumexp instead of assuming five iterations converge.
- **Spectral-gap boundary [v]:** mixing involves nonprincipal eigenvalue moduli, graph assumptions, and nonnormal transients. A large gap does not imply concentration on a few tokens: A=11^T/L has gap 1 and a completely uniform stationary distribution.
- **Fiedler vector [v/conditional]:** for a suitable undirected nonnegative graph it solves a continuous spectral-partition relaxation. Thresholding need not yield the optimal discrete bipartition, and small component magnitudes are not a universal token-importance criterion.
- **Perturbation boundary [v]:** Cauchy interlacing applies to principal submatrices of a fixed Hermitian matrix; renormalization changes the object. Bauer-Fike needs equal dimensions, a diagonalizable reference, and an eigenvector condition number; it is not directly a node-deletion bound. Gershgorin radii locate spectra, not semantic information loss.

## AI Module Specification
These are dense single-head references. The first directly computes stationary mass on a symmetric Key-similarity graph; the second handles a supplied directed row-stochastic graph and reports convergence residual.

```python
import math
import torch

def symmetric_key_centrality(K):
    scores = (K.float() @ K.float().T) / math.sqrt(K.shape[-1])
    log_degree = torch.logsumexp(scores, dim=-1)
    return torch.softmax(log_degree, dim=0)  # Exact stationary mass for this graph.

def teleported_pagerank(A, alpha=0.85, max_steps=100, tolerance=1e-6):
    A = A.float()
    assert A.ndim == 2 and A.shape[0] == A.shape[1] and A.shape[0] > 0
    assert 0 < alpha < 1 and bool(torch.isfinite(A).all()) and bool((A >= 0).all())
    assert torch.allclose(A.sum(dim=-1), torch.ones(A.shape[0], device=A.device), atol=1e-5)
    prior = torch.full((A.shape[0],), 1 / A.shape[0], device=A.device)
    v = prior.clone()
    for _ in range(max_steps):
        next_v = alpha * (A.T @ v) + (1 - alpha) * prior
        change = (next_v - v).abs().sum()
        v = next_v
        if change <= (1 - alpha) * tolerance:
            break
    residual = (alpha * (A.T @ v) + (1 - alpha) * prior - v).abs().sum()
    return v, residual  # In exact arithmetic: l1 error <= residual/(1-alpha).

def keep_by_score(K, V, score, retention):
    assert 0 < retention <= 1 and K.shape[0] == V.shape[0] > 0
    assert score.shape == (K.shape[0],)
    count = math.ceil(retention * K.shape[0])
    indices = torch.topk(score, count).indices.sort().values
    return K[indices], V[indices], indices  # Retain original token order.
```

**Gershgorin heuristic [~]:** rank raw S by sum_(j!=i)|S_ij|. This measures absolute connection weight in that matrix; graph construction still costs O(L^2 d), and high-norm/repeated tokens may dominate.

**Soft gates [~]:** for score∈R^L, use scalar w,b to form g=sigmoid((w*score+b)/tau)∈R^L. To reduce a token's attention mass, add log(g_j) to column j of the logits using stable log-sigmoid, then normalize. Scaling K_j by g_j is not deletion: a zero Key has score 0 and still receives mass. Soft gates retain L positions and save no computation/cache automatically; hard gathering needs separate validation.

## Implementable Architectures
- **Full graph [~]:** use where construction can be amortized; choose sequence thresholds from measurements.
- **Anchor approximation [~]:** an m×m subgraph scores only anchors. Scoring all L tokens additionally requires L×m cross-similarities and an explicit extension/assignment rule, with its own approximation error.
- **Multi-head/progressive pruning [~]:** averaging graphs changes the centrality being measured. Evaluate accumulated layer errors; successive layers are not automatically concurrent.
- **Deployment constraints [~]:** preserve K/V correspondence, original positions, required special/recent tokens, and masks. Autoregressive training selectors must not access future content unavailable to a Query.

## GPU Feasibility
- **D1/D2 [v]:** KK^T is a GEMM; softmax, row reductions, and top-k are distinct operations. **[~]** Matvec can be bandwidth bound, so tensor notation does not imply high utilization.
- **D3 [v]:** dense graph construction costs O(L^2 d), symmetric-graph row sums O(L^2), and general PageRank an additional O(TL^2). Choose T by residual, not a universal five- or ten-step rule.
- **D4 [v]:** at L=8192, one L×L bf16 matrix occupies 128 MiB, or 256 MiB in fp32, excluding workspaces/gradients. **[~]** Blocking lowers peak storage, but repeated propagation may require recomputing blocks.
- **D5 [~]:** low-precision reductions, spectral gaps, softmax dynamic range, and near-ties affect ranking. Normalization does not guarantee bf16 accuracy, and Gershgorin sums also round.
- **D6/D8 [~]:** graph blocks and some head tasks can parallelize, but graph construction, reductions, and global top-k have dependencies. Fusion and advantages over simple scores need real kernels and total-latency benchmarks.

## Paper-Worthy Formulation
“We use graph-centrality heuristics to select tokens, distinguishing exact stationary scores for symmetric-similarity graphs from approximate PageRank on directed graphs. We report total graph, selection, cache-reordering, and subsequent-attention cost alongside task loss and retention rules. Node deletion is not claimed to satisfy a Laplacian quadratic-form spectral-sparsification guarantee.”

## Risks
Spectral centrality can conflict with semantic importance, and uniform graphs/repeated vectors can create ties. PageRank interpretation depends on edge direction and the teleportation prior; Query-independent Key graphs need not predict future access. Hard selection indices are nondifferentiable, but selected K/V values still receive gradients. A frozen selector does not require a differentiable relaxation.

## Sources
See [von Luxburg's tutorial](https://arxiv.org/abs/0711.0189) for spectral-partition assumptions and relaxations. The direct stationary-score algorithm follows from the detailed-balance identity above; it establishes centrality computation, not safe pruning.
