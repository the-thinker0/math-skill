# Low-Rank KV-Cache
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Target Problem
Use when KV-Cache memory consumption becomes the bottleneck during LLM inference: long-context inference ($L > 8K$), multi-turn conversation accumulation, edge deployment, speculative decoding / beam search. Core objective: **compress the KV-Cache from $O(Ld)$ to low-rank factor storage $O(Lk + kd)$ with $k \ll d$, under controlled information loss**.

## Mathematical Foundations
- Lenses: ../../lenses/spectral.en.md (spectral component identification and truncation), ../../lenses/variational.en.md (Pareto trade-off between compression ratio and reconstruction error), ../../lenses/duality.en.md (nuclear norm--spectral norm duality)
- Knowledge: ../../knowledge-base/matrix-analysis/low-rank-approximation.en.md (Eckart--Young optimal approximation, randomized SVD), ../../knowledge-base/matrix-analysis/projection.en.md (orthogonal projection onto principal subspace), ../../knowledge-base/matrix-analysis/matrix-perturbation.en.md (Weyl perturbation bound)

## Required Mathematical Background
- **Eckart--Young--Mirsky Theorem**: $A_k = U_k \Sigma_k V_k^H$, $\|A - A_k\|_F = \sqrt{\sum_{i>k} \sigma_i^2}$; truncated SVD = optimal rank-$k$ approximation
- **Randomized SVD**: $Y = A\Omega$ ($\Omega$ random Gaussian), $Y = QR$, $B = Q^H A$, perform SVD on $B$; complexity $O(Ldk)$, dominated by matrix multiplications
- **Eckart--Young spectral-norm error**: $\|A - A_k\|_2 = \sigma_{k+1}$ (bounds only the optimal rank-$k$ compression error of the matrix itself; Weyl is for singular-value changes under perturbation). Extending this to attention output error requires additional conditions: bounding $\|\text{Attn}(Q,K,V) - \text{Attn}(Q,K_k,V_k)\|$ requires (a) bounded $\|Q\|$, (b) the softmax Lipschitz constant (which depends on temperature and score range), and (c) compression errors for **both** K and V. Roughly: error $\lesssim C \cdot (\|Q\| \cdot \|K - K_k\| \cdot \|V\| + \|Q\| \cdot \|K_k\| \cdot \|V - V_k\|) / \tau$, where $C$ depends on the softmax Lipschitz constant and $\tau$ is the temperature parameter. Directly using $\sigma_{k+1}$ to bound attention score deviation **holds only under the simplifying assumptions of fixed Q and ignoring V compression error**.
- **Effective Rank**: $r_{\text{eff}}(K) = \|K\|_F^2 / \|K\|_2^2$, guides adaptive selection of $k$

## AI Module Specification
```
Module: LowRankKVCompressor
Input: K ∈ R^{L×d}, V ∈ R^{L×d}    Parameters: target rank k << L, update frequency M

Method 1 - Offline periodic compression (most practical):
  Omega = randn(d, k+p)                    // random projection, p=5 oversampling
  Q_base = qr(K @ Omega)[0]                // L×(k+p) oversampled orthonormal basis (GEMM + QR)
  B_k = Q_base^T @ K                       // (k+p)×d small matrix GEMM
  U_r, S_r, Vt_r = svd(B_k)               // small matrix SVD
  Q_final = Q_base @ U_r[:, :k]            // L×k final left factor
  K_comp = S_r[:k] * Vt_r[:k, :]           // k×d compressed Key (low-rank factor)
  // V_comp definition: apply analogous truncated SVD to V, V_comp = Σ_k^{(V)} · Vt_k^{(V)} (k×d compressed Value)
  // Alternatively, if K and V share the left factor Q_final, then V_comp = Q_final^T @ V (project onto the same low-rank subspace)
  //
  // ⚠ Critical distinction -- low-rank factors CANNOT directly replace the original sequence in softmax attention:
  //   K ≈ Q_final @ K_comp (L×d reconstruction); softmax is a nonlinear operation, so
  //   softmax(Q @ K_comp^T / √d) @ V_comp ≠ softmax(Q @ K^T / √d) @ V
  //   The "k compressed tokens" interpretation is only valid for linear attention, not softmax attention.
  //
  // Mode A - Standard softmax attention (saves memory; may reduce inner dimension, not sequence length):
  //   K_recon need not be materialized. If K ≈ Q_final @ K_comp, then
  //   logits = (Q @ K_comp^T) @ Q_final^T / √d // for Q in R^{m×d}: O(mdk + mLk)
  //   attn = softmax(logits)                   // softmax is still normalized over L positions
  //   If V ≈ Q_final @ V_comp, output = (attn @ Q_final) @ V_comp
  //   // Advantage: storage reduced from O(Ld) to O(Lk + kd); QK/AV inner dimension goes from d to k
  //   // Limitation: the attention matrix is still m×L; the k factors are not k tokens
  //
  // Mode B - Linear attention (kernel feature map φ; compress additive statistics of φ(K), V):
  //   Replace softmax with kernel feature map φ: Attn = φ(Q) @ (φ(K)^T @ V) / (φ(Q) @ φ(K)^T @ 1)
  //   History can shrink from L tokens to k statistical factors only if the compressed objects are
  //   additive statistics such as φ(K)^T V and φ(K)^T 1, or if low-rank/aggregation is performed
  //   directly in φ(K) space. Applying φ directly to K_comp is not generally equivalent.

Method 2 - Streaming incremental compression (low latency):
  Maintain basis (U_basis ∈ R^{k×d}), on new token arrival:
    residual p = k_new - U_basis^T @ (U_basis @ k_new)
    if ‖p‖ > τ: brand_update + truncate_to_rank(k)  // expand basis
    else: coeff = U_basis @ k_new                    // project onto existing basis

Method 3 - Layer-wise adaptive: allocate per-layer, per-head k based on effective rank r_eff[l,h]
```

## Implementable Architectures
- **Periodic compression layer**: trigger randomized SVD every $M=64$ steps, $L \times d \to (L \times k) + (k \times d)$
- **Double buffering**: compressed basis + recent $w$ raw tokens, balancing accuracy and compression ratio
- **Shared basis**: multi-head sharing of the Key column-space basis, each head stores only coefficients
- **Quantized basis**: further INT8/FP8 quantization after compression, achieving dual compression

## GPU Feasibility
- Tensorization / GEMM: randomized SVD = 3 GEMMs + 1 small SVD, maps perfectly onto Tensor Cores
- Complexity: $O(Ldk)$ is far superior to $O(Ld^2)$ full SVD; overhead negligible for $k \sim 256$
- Memory: Key-Cache stored in low-rank factor form ($Q_{\text{final}} \in \mathbb{R}^{L \times k}$ + $B_k \in \mathbb{R}^{k \times d}$), total parameters $Lk + kd$, compression ratio $Ld/(Lk+kd) \approx d/k$ (when $L \gg k$). Note $Q_{\text{final}}$ still has $L$ dimension, so sequence length is NOT reduced; softmax attention can compute length-$L$ logits with factorized GEMMs without materializing a full $L \times d$ reconstruction. V-Cache requires independent compression. End-to-end compression ratio depends on K/V storage format and rank selection
- Low precision: SVD recommended in fp32 (acceptable for small matrices); compressed KV can be stored back in bf16
- Parallelism: compression across layers / heads is fully independent; incremental update $O(kd)$ with very low latency
- Operator fusion: $K\Omega$ + QR can be partially fused; in the softmax path, QK/AV inner dimension can drop from $d$ to $k$, but softmax is still normalized over length $L$; linear attention only shrinks history to $k$ when compressing additive statistics

**Quantitative assessment example** (standard transformer, d=128, n=2048, rank k=64):
- D3: SVD computation O(n·d·k) ≈ 2048·128·64 ≈ 16.8M FLOPs (one-time); softmax inference per query with factors is about O(dk + n·k), with a length-n softmax still required; linear attention removes n only when compressed statistics are used
- D4: KV-Cache from O(n·d) = 2048·128·2B ≈ 512KB; factor format O(n·k + k·d) ≈ 2048·64·2B + 64·128·2B ≈ 278KB (compression ratio ~1.8x); final-left-factor + coefficient format ($Q_{\text{final}} \in \mathbb{R}^{n \times k}$ columns + $B_k \in \mathbb{R}^{k \times d}$) total parameters $nk + kd$, compression ratio $nd/(nk+kd) = d/k \cdot 1/(1+d/n) \approx d/k = 2x$, V-Cache requires independent compression
- D5: Truncated SVD under bf16 amplifies singular value errors near σ_k by ~κ(A), requires caution
- D8: SVD → matmul can be fused; online updates use incremental SVD to avoid full recomputation

## Paper-Worthy Formulation
"Building on the Eckart--Young--Mirsky theorem, we employ randomized SVD to project the KV-Cache onto a rank-$k$ subspace, compressing storage from $O(Ld)$ to $O(Lk + kd)$ (basis+coefficient format) at $O(Ldk)$ complexity. For standard softmax attention, low-rank factors cannot be interpreted as $k$ compressed tokens; softmax is still normalized over length $L$, but factorized GEMMs can compute logits and value aggregation without materializing a full $L \times d$ reconstruction, reducing the QK/AV inner dimension from $d$ to $k$. Only in linear attention, and only when compressing additive statistics such as $\phi(K)^T V$ and $\phi(K)^T\mathbf{1}$, can the historical state truly shrink from $L$ tokens to $k$ statistical factors. The Eckart--Young spectral-norm error gives $\sigma_{k+1}$ as the optimal rank-$k$ compression error for the K/V matrices themselves; the end-to-end attention output error bound further depends on query norms, the softmax Lipschitz constant, and the temperature parameter. The actual memory compression ratio depends on storage format and the independent V-Cache compression strategy."

## Risks
- **Improper rank selection**: $k$ too small causes $\sigma_{k+1}$ to be non-negligible, degrading long-range recall; singular value decay curves must be monitored
- **Incremental SVD error accumulation**: repeated Brand updates drift away from the true SVD, requiring periodic re-compression for correction
- **Positional encoding distortion**: RoPE is coupled with Keys, and compression may disrupt relative positional information; separate handling or re-injection is needed
- **Double-buffer seam**: attention score scales differ between the compressed region and the raw region, requiring unified normalization
