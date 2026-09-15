# Low-Rank KV-Cache

> Rigor convention: [v] denotes a checkable formula or cost count; [~] denotes a compression/implementation design requiring experiments. This prototype claims no measured GPU throughput.

## Target Problem
Explore factor storage when inference KV-cache memory is a bottleneck and K/V contain useful redundancy under the actual query distribution. Low-rank approximation concerns specified matrices; it does not directly guarantee long-range retrieval or generation quality.

## Mathematical Foundations
- Lenses: `../../lenses/spectral.en.md`, `../../lenses/variational.en.md`, `../../lenses/duality.en.md`.
- Knowledge: `../../knowledge-base/matrix-analysis/low-rank-approximation.en.md`, `../../knowledge-base/matrix-analysis/projection.en.md`, `../../knowledge-base/matrix-analysis/matrix-perturbation.en.md`.

## Required Mathematical Background
- **Eckart-Young-Mirsky [v]:** exact truncated SVD attains ||A-A_k||_2=sigma_(k+1) and ||A-A_k||_F^2=sum_(i>k)sigma_i^2. Randomized SVD has additional subspace error; its actual error need not equal these optima.
- **Randomized SVD [v]:** with sketch width ell=k+p<=min(L,d), a basic dense algorithm costs approximately O(Ld ell+(L+d)ell^2), including QR and a smaller SVD. Power iterations add data passes.
- **Stable rank [v]:** ||K||_F^2/||K||_2^2 is stable rank, conventionally 0 for K=0. It is not entropy-defined effective rank and does not alone determine the rank needed for a chosen tolerance. Inspect tail spectra and query-weighted error too.

**Explicit single-query output bound [v]:** fix q, equal token-row counts for K,K_hat and V,V_hat, the same visibility mask with at least one visible key, and temperature tau>0. For o=softmax(qK^T/tau)V and o_hat=softmax(qK_hat^T/tau)V_hat,

$$\|o-\hat o\|_2\le\frac{\|q\|_2\|K-\hat K\|_2\|V\|_2}{2\tau}+\|V-\hat V\|_2.$$

The softmax Jacobian has 2-operator norm at most 1/2 and a probability vector has 2-norm at most 1; split the difference as (a-a_hat)V+a_hat(V-V_hat). Standard attention uses tau=sqrt(d). The second term does not vanish with q: even q=0 can have a changed mean output after Value approximation. Later-layer amplification and additional rounding are outside this bound.

## AI Module Specification
For K∈R^(L×d), V∈R^(L×d_v), store K_hat=U_K B_K and V_hat=U_V B_V separately, possibly with different ranks. This fp32 dense reference uses **factorized GEMMs**, not a fused kernel:

```python
import math
import torch

def low_rank_factors(A, rank, oversample=8):
    A = A.float()
    rows, cols = A.shape
    assert 1 <= rank <= min(rows, cols) and oversample >= 0
    ell = min(rank + oversample, rows, cols)
    omega = torch.randn(cols, ell, device=A.device, dtype=A.dtype)
    Q_base = torch.linalg.qr(A @ omega, mode="reduced").Q
    U_small, S, Vh = torch.linalg.svd(Q_base.T @ A, full_matrices=False)
    Q_final = Q_base @ U_small[:, :rank]
    A_comp = S[:rank, None] * Vh[:rank, :]  # Row scaling, shape (rank, cols).
    return Q_final, A_comp

def factorized_attention(Q, U_K, B_K, U_V, B_V, allowed=None):
    Q, U_K, B_K, U_V, B_V = [x.float() for x in (Q, U_K, B_K, U_V, B_V)]
    logits = ((Q @ B_K.T) @ U_K.T) / math.sqrt(Q.shape[-1])
    if allowed is not None:
        assert bool(allowed.any(dim=-1).all())
        logits = logits.masked_fill(~allowed, -torch.inf)
    weights = torch.softmax(logits, dim=-1)  # Normalize over all L positions.
    return (weights @ U_V) @ B_V
# U_K, B_K = low_rank_factors(K, rank_k)
# U_V, B_V = low_rank_factors(V, rank_v)
# output = factorized_attention(Q, U_K, B_K, U_V, B_V, allowed)
```

**Critical distinction [v]:** left factors such as Q_final retain L rows, and softmax still normalizes over L positions. Factorized GEMMs avoid full K/V reconstruction, but k factors are not k tokens. Sharing U_V=U_K requires computing B_V=U_K^T V and measuring Value projection error; the right factor of an independent V-SVD cannot be paired with U_K.

**Linear attention [v/conditional]:** for a specified finite-dimensional map phi(x)∈R^s, accumulate S=sum phi(k_i)v_i^T and z=sum phi(k_i), then output phi(q)^T S/(phi(q)^T z), with a nonzero denominator. State size is O(sd_v+s); feature dimension s is not the SVD rank k of K. Applying nonlinear phi directly to K_comp generally fails to preserve these statistics. This is not an unconditional equivalent of standard softmax.

## Implementable Architectures
- **Periodic compression [~]:** choose M by amortized cost and quality, not a universal M=64. This offline baseline needs raw A and workspaces; peak memory can exceed final factor storage.
- **Fixed streaming basis [v]:** for R∈R^(k×d), RR^T=I, the new row Key has coefficients c=k_new R^T and residual k_new-cR at O(kd) cost. **[~]** A changing basis requires rotating/recomputing historical coefficients; the full incremental-SVD update is not always O(kd).
- **Double buffering [~]:** compress old tokens and retain recent raw tokens. Preserve the common temperature, original positions, and mask; normalize logits from both regions with one shared softmax.
- **Cross-head sharing/quantization [~]:** test subspace compatibility and quantization error. Low rank does not imply exploitable zero-entry sparsity in the factors.

## GPU Feasibility
- **D1/D2 [v]:** sketching and factor application contain GEMMs; QR/SVD retain separate costs. **[~]** This does not establish full Tensor Core utilization or whole-decomposition fusion.
- **D3 [v]:** for m queries, factorized QK costs O(mdk_K+mLk_K), and AV costs O(mLk_V+mk_Vd_v), plus length-L softmax, compression, and updates. Ranks must fit the corresponding dimensions; k=256 is invalid for d=128.
- **D4 [v]:** K-only factors have Lk+kd entries and ratio Ld/[k(L+d)]; savings require k<Ld/(L+d), and the approximation d/k additionally needs L>>d. Independent Value factors add Lk_V+k_Vd_v entries.
- **D5 [~]:** use fp32 QR/SVD as a baseline and inspect orthogonality, tail spectra, logits, and output error after low precision/quantization. There is no universal “sigma_k error amplified by kappa” statement.
- **D6/D8 [~]:** independent heads may parallelize, while each decomposition/basis update has dependencies. Tiled factor-attention fusion needs an actual kernel and end-to-end benchmarks.

**Byte and FLOP accounting [v]:** L=2048, d=128, k=64, with 2-byte persistent elements: K occupies 512 KiB and its factors 272 KiB, a ratio of about 1.882x. Independently compressing V at the same rank reduces total KV from 1024 to 544 KiB; K-only compression gives 784 KiB. Workspaces/metadata are excluded. K Omega alone with ell=64 already costs about 2Ld ell=33.6M FLOPs for one GEMM; this is not the total SVD cost.

## Paper-Worthy Formulation
“We store KV as randomized low-rank factors and measure reconstruction, logit, and output errors. The Eckart--Young spectral-norm error serves as the exact truncated-SVD reference; randomized approximation error is measured separately. Standard softmax still normalizes over all historical positions. We compare end-to-end memory and latency including factorization, updates, and workspaces.”

## Risks
High-energy directions need not serve future queries. Rotating existing factors cannot recover information already lost to truncation. Post-RoPE Keys can be compressed in their actual form; pre-RoPE compression requires compatibility between projection and per-position rotations, rather than arbitrarily moving rotations past shared coefficients. Autoregressive training compressors must not access future data unavailable to the current Query.

## Sources
[Halko, Martinsson & Tropp](https://arxiv.org/abs/0909.4061) analyze randomized low-rank approximation; [Performers](https://research.google/pubs/rethinking-attention-with-performers/) discuss kernel-feature attention. The output bound above follows directly from its stated Jacobian and norm inequalities; matrix reconstruction optima are not task guarantees.
