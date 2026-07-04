# Leverage Score Selection

## Target Problem
Use when selecting the most representative rows / columns / tokens from a large-scale matrix while guaranteeing the precision of downstream linear algebra operations: KV-Cache token selection, data coreset construction, Nystrom landmark sampling, distributed gradient compression. Core objective: **sample based on statistical leverage scores derived from subspace projections, with probabilistic guarantees of approximating full-computation accuracy**.

## Mathematical Foundations
- Lenses: lenses/spectral.md (leverage scores = projection energy of row vectors onto the principal subspace), lenses/probabilistic.md (probabilistic sampling and concentration inequality guarantees), lenses/algorithmic.md (complexity--accuracy trade-offs of randomized algorithms)
- Knowledge: knowledge-base/matrix-analysis/low-rank-approximation.md (randomized SVD, nuclear norm), knowledge-base/matrix-analysis/projection.md (diagonal entries of the projection matrix = leverage scores), knowledge-base/probability/concentration-inequality.md (Bernstein matrix concentration bound)

## Required Mathematical Background
- **Statistical Leverage Scores**: $\ell_i = \|(V_k V_k^T)_i\|^2 = (V_k V_k^T)_{ii}$, the projection energy of the $i$-th row onto the rank-$k$ subspace; $\sum_i \ell_i = k$
- **Leverage Score Sampling Guarantee**: sampling $s = O(k \log k / \epsilon^2)$ rows with probabilities $p_i = \ell_i / k$ yields a $(1+\epsilon)$ approximation to full least squares (Drineas--Mahoney)
- **Bernstein Matrix Bound**: after sampling, $\|\hat{A}^T \hat{A} - A^T A\|_2 \leq \epsilon \|A\|_F^2$ with probability $\geq 1-\delta$
- **Fast Approximation**: $\tilde{\ell}_i = \|(A\Omega)_i\|^2$ ($\Omega$ random Gaussian), avoids full SVD, $O(Ndk)$
- **DPP Extension**: Determinantal Point Process $P(S) \propto \det(L_S)$ adds a diversity guarantee on top of leverage scores

## AI Module Specification
```
Module: LeverageScoreSelector
Input: A ∈ R^{N×d}    Parameters: sample size s << N, rank parameter k

Method 1 - Random projection leverage scores (online / large-scale):
  Omega = randn(d, k+p)                       // random matrix, p=5 oversampling
  Q = qr(A @ Omega)[0]                        // N×(k+p), GEMM + QR
  leverage = sum(Q ** 2, dim=1)               // N-dim, row-wise sum of squares
  indices = topk(leverage, s)                 // deterministic top-s selection
  A_selected = A[indices]

Method 2 - Exact leverage scores (offline / small matrices):
  U_k = svd(A)[:k][0]                         // truncated SVD left singular vectors
  leverage = sum(U_k ** 2, dim=1)             // exact rank-k leverage scores
  probs = leverage / leverage.sum()
  indices = multinomial_sample(N, s, probs)    // probabilistic sampling + reweighting
  weights = 1 / sqrt(s * probs[indices])

Method 3 - KV-Cache sliding-window eviction:
  Every M steps update Q = qr(K_cache @ Omega)[0]
  leverage = sum(Q ** 2, dim=1)
  Evict tokens with lowest leverage (least contribution to the subspace)

Method 4 - DPP greedy diverse selection:
  scores = leverage.clone(); L = A @ A^T       // PSD kernel matrix
  for _ in range(s):
    idx = argmax(scores); selected.append(idx)
    scores -= α * |L[:, idx]|                   // penalize neighbors of already selected tokens
```

## Implementable Architectures
- **Random projection leverage layer**: 1 GEMM + 1 QR yields approximate leverage scores in $O(Ndk)$
- **KV-Cache eviction policy**: evict by leverage score ranking, with stronger theoretical guarantees than attention-score-based eviction
- **Coreset constructor**: leverage score sampling + importance reweighting, ensuring empirical risk approximates the full-data risk
- **DPP greedy extension**: leverage scores + exclusion penalty, balancing importance and diversity

## GPU Feasibility
- Tensorization / GEMM: $A\Omega$ is a GEMM; QR via cuSOLVER; leverage scores = elementwise row-wise sum of squares
- Complexity: $O(Ndk)$ is far superior to $O(Nd^2)$ full SVD; top-s selection in $O(N \log s)$
- Memory: $\Omega$ is only $d \times k$ (KB-scale); $Q$ is the same size as $A$ but can be computed in batches
- Low precision: QR recommended in fp32 (small matrix with $k+p$ columns, negligible overhead); leverage scores can be cast back to bf16
- Parallelism: the $A\Omega$ GEMM is highly parallelizable; top-s can use parallel radix sort
- Operator fusion: $A\Omega$ + QR + row-norm² can be fused to avoid materializing intermediate matrices

## Paper-Worthy Formulation
"We adopt statistical leverage scores as the importance metric for token selection: approximating rank-$k$ subspace leverage scores via random projection in $O(Ndk)$, with the Drineas--Mahoney theory guaranteeing that $O(k \log k / \epsilon^2)$ samples suffice for a $(1+\epsilon)$ approximation of the full subspace."

## Risks
- **Rank parameter $k$ selection**: leverage scores depend on the rank-$k$ subspace; an incorrect $k$ leads to biased sampling -- the effective rank must be diagnosed first
- **Sampling variance**: probabilistic sampling introduces variance; low-probability rows occasionally selected produce large weight noise -- deterministic top-s can be used as an alternative
- **Leverage scores vs. semantic importance mismatch**: the metric measures subspace contribution, which does not necessarily reflect semantics; it can be combined with attention scores via weighted fusion
- **DPP greedy suboptimality**: exact DPP sampling is $O(N^3)$; the greedy approximation may miss the globally optimal subset
- **Stale scores under dynamic data**: in streaming scenarios leverage scores drift as data evolves, requiring periodic recomputation or incremental updates
