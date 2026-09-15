# Leverage Score Selection
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Target Problem
Use when selecting representative rows / columns / tokens from a large-scale matrix while seeking verifiable error bounds for downstream linear-algebra tasks: KV-Cache token selection, data coreset construction, Nystrom landmark sampling, distributed gradient compression. Core objective: **sample using statistical leverage scores derived from subspace projections, approximating full computation with high probability under matrix-sampling assumptions**.

## Mathematical Foundations
- Lenses: ../../lenses/spectral.en.md (leverage scores = projection energy of row vectors onto the principal subspace), ../../lenses/probabilistic.en.md (probabilistic sampling and concentration inequality guarantees), ../../lenses/algorithmic.en.md (complexity--accuracy trade-offs of randomized algorithms)
- Knowledge: ../../knowledge-base/matrix-analysis/low-rank-approximation.en.md (randomized SVD, nuclear norm), ../../knowledge-base/matrix-analysis/projection.en.md (diagonal entries of the projection matrix = leverage scores), ../../knowledge-base/probability/concentration-inequality.en.md (Bernstein matrix concentration bound)

## Required Mathematical Background

- For an orthonormal rank-$k$ **left** basis $U_k\in\mathbb R^{N\times k}$ of $A$, row leverage is $\ell_i=\|U_k[i,:]\|_2^2=(U_kU_k^T)_{ii}$ and $\sum_i\ell_i=k$. Right singular vectors give column leverage.
- Independent with-replacement sampling from $p_i\ge\beta\ell_i/k$ with row scaling $1/\sqrt{s p_i}$ embeds this fixed subspace using $s=O(k\log(k/\delta)/(\beta\epsilon^2))$ under standard matrix-concentration conditions. Low-rank basis preservation alone does not imply a relative-error full least-squares guarantee for every response vector.
- Raw sketch row norms $\|(A\Omega)_i\|^2$ measure sketch energy, not leverage: orthonormalize the range first. To target exactly rank $k$, truncate the small projected SVD after QR.
- Deterministic top-s selection does not inherit the independent randomized-sampling theorem. DPP sampling is defined by determinants of PSD principal submatrices; an arbitrary neighbor-penalty heuristic is not DPP sampling.

## AI Module Specification

```python
Omega = randn(d, k + oversampling)
Q = qr(A @ Omega, mode='reduced').Q
U_small, singular_values, Vh = svd(Q.T @ A, full_matrices=False)
U_k = Q @ U_small[:, :k]
leverage = (U_k**2).sum(-1)
probs = leverage / leverage.sum()
indices = multinomial(probs, s, replacement=True)
weights = 1 / sqrt(s * probs[indices])
A_sampled = A[indices] * weights[:, None]
```
Check the numerical rank, basis orthogonality, and embedding residual against exact small cases. Deterministic token eviction may instead use `topk(leverage, s)`, but is an attention heuristic; reweighting rows as above does not by itself preserve softmax token semantics.

For diverse selection use an actual DPP/k-DPP sampler or a declared greedy log-determinant algorithm. If using leverage plus a similarity penalty, label it “diversity heuristic” and compare it to uniform/random/attention-score baselines.

## Implementable Architectures

- Reweighted independent row sampling for a declared linear-algebra task.
- Deterministic eviction as a separately measured attention heuristic.
- Offline exact leverage for validating an online approximation.
- DPP/log-det diversity methods with their own sampling or optimization guarantees.

## GPU Feasibility

- **D1/D2[~]**: Sketching and small projected SVD use GEMM plus QR/SVD; QR is not a pure matmul.
- **D3[~]**: For sketch width $r=k+p$, cost includes $O(Ndr)$ sketch/projection, $O(Nr^2)$ QR and $O(dr^2)$ small SVD. Speedup needs $r\ll\min(N,d)$ and amortization.
- **D4[~]**: Store $Q$ of size $N\times r$, $\Omega$ of size $d\times r$ and the projected matrix $r\times d$. Independent per-batch QR is not a global orthonormal basis; use a valid streaming/TSQR algorithm if chunking.
- **D5[~]**: Use fp32/fp64 QR/SVD and check residuals near rank deficiency.
- **D6/D8[~]**: Reductions and factorization introduce synchronization; end-to-end fusion is a proposal, not demonstrated by operator availability.
- **D7[N/A]**: Low-rank subspace structure does not imply sparse factor entries.

## Paper-Worthy Formulation
"We adopt statistical leverage scores as the importance metric for token / row selection: approximate rank-$k$ subspace leverage scores via random projection in $O(Ndk)$, and use Drineas--Mahoney-style bounds to choose sample counts when the target is subspace / least-squares approximation under independent reweighted sampling and effective-rank diagnostics. For KV-cache eviction, attention/output error and task metrics must still be reported."

## Risks

- Rank choice and basis approximation affect scores; report tail energy and sketch residuals.
- High importance weights increase sampling variance; switching to deterministic selection changes the theorem.
- Spectral importance need not match semantic importance; audit rare retrieval tokens.
- Streaming basis drift requires refresh; measure refresh cost as part of decode latency.
