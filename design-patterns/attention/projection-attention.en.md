# Projection Attention

> Rigor convention: [v] denotes a directly checkable mathematical relation or cost count; [~] denotes a design requiring task/hardware validation. Throughput, fusion, and low-precision quality are not verified without benchmarks.

## Applicable Problems
Explore feature projection when Q/K have measurable redundancy or Key-cache storage is a bottleneck. High dimension alone does not imply uniform attention: the dot product of independent zero-mean unit-variance coordinates has variance d, which the standard 1/sqrt(d) scaling controls. Compressible directions require data, logit-error, and task measurements.

## Mathematical Inspiration
- Lenses: `../../lenses/projection.en.md`, `../../lenses/spectral.en.md`, `../../lenses/probabilistic.en.md`.
- Knowledge: `../../knowledge-base/matrix-analysis/projection.en.md`, `../../knowledge-base/probability/concentration-inequality.en.md`, `../../knowledge-base/probability/entropy.en.md`.

## Required Mathematical Knowledge
- **JL boundary:** Euclidean distances of a finite point set independent of the random map are approximately preserved under the appropriate map, dimension, and failure-probability conditions. This does not establish softmax-output or task preservation. CountSketch and SRHT need their own dimension guarantees.
- **Two different objectives:** learning independent P_Q and P_K defines a new bilinear metric; approximating existing inner products with a shared scaled random P requires retaining the original temperature. These do not share one unconditional guarantee.
- **Subspace truncation:** right singular vectors of K minimize its uncentered reconstruction error. K^T K/n is a second moment; covariance requires mean subtraction and reconstruction must then handle the mean term.

## AI Module Form
Let Q∈R^(m×d), K∈R^(n×d), V∈R^(n×d_v), and P_Q,P_K∈R^(d×r):

$$O=\operatorname{softmax}_{j}\left(\frac{(QP_Q)(KP_K)^T}{\tau}+M\right)V.$$

M is the same visibility mask, with at least one allowed key per row.

```python
import math
import torch

def projected_attention(Q, K, V, P_Q, P_K, temperature, allowed=None):
    assert temperature > 0
    Q, K, P_Q, P_K = [x.float() for x in (Q, K, P_Q, P_K)]
    scores = ((Q @ P_Q) @ (K @ P_K).T) / temperature
    if allowed is not None:
        assert bool(allowed.any(dim=-1).all())
        scores = scores.masked_fill(~allowed, -torch.inf)
    return torch.softmax(scores, dim=-1) @ V.float()

# Approximate original QK^T / sqrt(d); keep P fixed throughout cache use.
def gaussian_projection(d, r, *, device, dtype):
    return torch.randn(d, r, device=device, dtype=dtype) / math.sqrt(r)
# P = gaussian_projection(...)
# output = projected_attention(Q, K, V, P, P, math.sqrt(Q.shape[-1]))
```

**Random-map scale [v]:** for P_ab~N(0,1/r), E[PP^T]=I and E[(qP)(kP)^T]=qk^T. Retain sqrt(d) to approximate the original attention; dividing by sqrt(r) changes its temperature. The dot-product expectation identity does not make softmax unbiased.

**Learnable projection [~]:** use two `torch.nn.Linear(d, r, bias=False)` layers and call them as `P_Q(Q)` and `P_K(K)`, rather than multiplying tensors by a layer object. sqrt(r) is one temperature choice for the new architecture and needs training/calibration.

**Data-adaptive subspace [~]:** truncated SVD of K can supply orthogonal P. Updating P online invalidates historical Key coefficients: reproject, update old coefficients, or retain block-specific bases. Updating only Query projection while keeping stale KP is inconsistent.

## Implementable Architectures
- Choose r per head and record the Q/K maps and temperature; sum costs across heads.
- Storing only KP compresses Key; Value remains n×d_v.
- Data-adaptive subspaces in autoregressive training must not read future tokens unavailable to the current Query. Freeze an offline calibration basis or update by prefix.

## GPU Feasibility
- **D1/D2 [v]:** dense QP, KP, and projected QK use GEMM; **[~]** Tensor Core utilization depends on shape, dtype, and implementation.
- **D3 [v]:** single-head cost is O((m+n)dr+mnr+mnd_v), including projection, scores, and AV. Lower r removes neither the quadratic sequence term nor the uncompressed AV cost.
- **D4 [v]:** Key entries fall from nd to nr, plus dr projection parameters. Total KV ratio is n(d+d_v)/(nr+nd_v+projection overhead). **[~]** Releasing original K, workspaces, peak memory, and cache layout require measurement.
- **D5 [~]:** orthogonality limits some amplification but does not guarantee bf16 logit, softmax, or task accuracy; retain fp32 accumulation/softmax references.
- **D6/D7 [~]:** heads can parallelize, but attention depends on the projection; sparse maps may introduce gather/scatter.
- **D8 [~]:** projecting before a compatible attention kernel is one option; fusion into online softmax requires separate kernel implementation and validation.

## Paper Phrasing
“We compare learned and fixed-random Q/K feature projections, specifying their temperatures and approximation targets separately. We report projection cost, Key and total KV bytes, attention/output error, and task metrics. JL claims are restricted to finite-set distance preservation under the stated assumptions.”

## Risks
- Low rank can discard query-relevant directions with little Key variance; retained variance alone is insufficient.
- Orthogonal regularization is optional, not a universal anti-collapse requirement; ablate it separately.
- A residual mixture that computes both original and projected attention reintroduces original computation and cache costs.

## Sources
Standard scaling: [Attention Is All You Need](https://arxiv.org/abs/1706.03762). This pattern projects the **feature dimension**; [Linformer](https://arxiv.org/abs/2006.04768) compresses the sequence dimension, so its linear-complexity claim cannot be transferred directly.

JL conditions: [Dasgupta & Gupta](https://cseweb.ucsd.edu/~dasgupta/papers/jl.pdf).
