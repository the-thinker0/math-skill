# Low-Rank KV-Cache
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Target Problem
Use when KV-Cache memory consumption becomes the bottleneck during LLM inference: long-context inference ($L > 8K$), multi-turn conversation accumulation, edge deployment, speculative decoding / beam search. Core objective: **compress the KV-Cache from $O(Ld)$ to $O(kd)$ with $k \ll L$, under controlled information loss**.

## Mathematical Foundations
- Lenses: lenses/spectral.md (spectral component identification and truncation), lenses/variational.md (Pareto trade-off between compression ratio and reconstruction error), lenses/duality.md (nuclear norm--spectral norm duality)
- Knowledge: knowledge-base/matrix-analysis/low-rank-approximation.md (Eckart--Young optimal approximation, randomized SVD), knowledge-base/matrix-analysis/projection.md (orthogonal projection onto principal subspace), knowledge-base/matrix-analysis/matrix-perturbation.md (Weyl perturbation bound)

## Required Mathematical Background
- **Eckart--Young--Mirsky Theorem**: $A_k = U_k \Sigma_k V_k^H$, $\|A - A_k\|_F = \sqrt{\sum_{i>k} \sigma_i^2}$; truncated SVD = optimal rank-$k$ approximation
- **Randomized SVD**: $Y = A\Omega$ ($\Omega$ random Gaussian), $Y = QR$, $B = Q^H A$, perform SVD on $B$; complexity $O(Ldk)$, dominated by matrix multiplications
- **Weyl Perturbation Bound**: $\|A - A_k\|_2 = \sigma_{k+1}$; maximum deviation of attention scores after compression $\leq \sigma_{k+1}$
- **Effective Rank**: $r_{\text{eff}}(K) = \|K\|_F^2 / \|K\|_2^2$, guides adaptive selection of $k$

## AI Module Specification
```
Module: LowRankKVCompressor
Input: K ∈ R^{L×d}, V ∈ R^{L×d}    Parameters: target rank k << L, update frequency M

Method 1 - Offline periodic compression (most practical):
  Omega = randn(d, k+p)                    // random projection, p=5 oversampling
  Q_k = qr(K @ Omega)[0]                   // L×(k+p) orthonormal basis (GEMM + QR)
  B_k = Q_k^T @ K                          // (k+p)×d small matrix GEMM
  U_r, S_r, Vt_r = svd(B_k)               // small matrix SVD
  K_comp = S_r[:k] * Vt_r[:k, :]           // k×d compressed Key
  // Attention: softmax(Q @ K_comp^T / √d) @ V_comp, sequence dimension L → k

Method 2 - Streaming incremental compression (low latency):
  Maintain basis (U_basis ∈ R^{k×d}), on new token arrival:
    residual p = k_new - U_basis^T @ (U_basis @ k_new)
    if ‖p‖ > τ: brand_update + truncate_to_rank(k)  // expand basis
    else: coeff = U_basis @ k_new                    // project onto existing basis

Method 3 - Layer-wise adaptive: allocate per-layer, per-head k based on effective rank r_eff[l,h]
```

## Implementable Architectures
- **Periodic compression layer**: trigger randomized SVD every $M=64$ steps, $L \times d \to k \times d$
- **Double buffering**: compressed basis + recent $w$ raw tokens, balancing accuracy and compression ratio
- **Shared basis**: multi-head sharing of the Key column-space basis, each head stores only coefficients
- **Quantized basis**: further INT8/FP8 quantization after compression, achieving dual compression

## GPU Feasibility
- Tensorization / GEMM: randomized SVD = 3 GEMMs + 1 small SVD, maps perfectly onto Tensor Cores
- Complexity: $O(Ldk)$ is far superior to $O(Ld^2)$ full SVD; overhead negligible for $k \sim 256$
- Memory: KV-Cache reduced from $O(Ld)$ to $O(kd)$; $k/L \sim 1/16$ yields 16x compression
- Low precision: SVD recommended in fp32 (acceptable for small matrices); compressed KV can be stored back in bf16
- Parallelism: compression across layers / heads is fully independent; incremental update $O(kd)$ with very low latency
- Operator fusion: $K\Omega$ + QR can be partially fused; the QK^T dimension in attention is already reduced

## Paper-Worthy Formulation
"Building on the Eckart--Young--Mirsky theorem, we employ randomized SVD to project the KV-Cache onto the optimal rank-$k$ subspace, achieving $L/k$-fold memory compression at $O(Ldk)$ complexity, with the Weyl perturbation bound guaranteeing that attention score deviations do not exceed $\sigma_{k+1}$."

## Risks
- **Improper rank selection**: $k$ too small causes $\sigma_{k+1}$ to be non-negligible, degrading long-range recall; singular value decay curves must be monitored
- **Incremental SVD error accumulation**: repeated Brand updates drift away from the true SVD, requiring periodic re-compression for correction
- **Positional encoding distortion**: RoPE is coupled with Keys, and compression may disrupt relative positional information; separate handling or re-injection is needed
- **Double-buffer seam**: attention score scales differ between the compressed region and the raw region, requiring unified normalization
