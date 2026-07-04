# GPU-Friendly Math Checklist

> This file is the **single source of truth** for the "GPU-feasibility" acceptance gate.
> The activator, the 16 thinking weapons, `books/*.md`, and `../agents/math-critic.md` all reference this file; no duplicate definitions elsewhere.
>
> This file is the single source of truth for the "GPU-feasibility" acceptance gate. The activator, the 16 weapons, the book references, and the math-critic all point here.

## Core Proposition

**Mathematical beauty ≠ computability.** For a structure to truly enter training and inference on modern GPU clusters, it must simultaneously satisfy two requirements:

1. **Mathematically correct (beautiful in math)** — The structure is self-consistent, differentiable (or relaxable to differentiable), with correctness guarantees.
2. **Hardware-feasible (friendly to GPU)** — It can be efficiently mapped onto GPU microarchitecture (Tensor Cores, memory hierarchy, parallelism, and interconnects).

Many "beautiful on paper" modern mathematical structures cannot run at high performance once they encounter GPU parallelism and low-precision arithmetic errors. This checklist turns "GPU feasibility" into an **item-by-item scorable** engineering standard, preventing non-computable constructs from being accepted as deliverables.

## The 8-Dimension Scorecard

For any candidate structure (operator, attention variant, routing mechanism, regularization term, compression scheme…) rate each dimension as `Friendly / Adaptable / Unfriendly` and provide adaptation recommendations.

| # | Dimension | Key Question | Friendly ✅ | Unfriendly ❌ |
|---|-----------|-------------|------------|--------------|
| 1 | **Tensorization** | Can it be expressed as dense tensor operations, avoiding element-wise irregular control flow? | Batched tensor algebra | Scalar loops, data-dependent branches |
| 2 | **GEMM Mappability** | Can it be reduced to matrix multiplication / batched GEMM / convolution to fully utilize Tensor Cores? | Expressible as a GEMM chain | Irregular computations that cannot be expressed as matrix operations |
| 3 | **Complexity** | Is the forward/backward pass sub-quadratic? How does it scale with sequence length / model size? | Linear / sub-quadratic, blockable | $O(n^2)$ or worse memory/compute blowup |
| 4 | **Memory & KV-Cache** | Peak memory usage; activation / state / KV footprint; can it be compressed? | Low-rank / quantized / block-summary compressible | Must materialize large intermediate tensors |
| 5 | **Low-Precision Stability** | Is it stable under fp16/bf16/fp8 with deterministic reproducibility? | Controlled dynamic range, numerically robust | Catastrophic cancellation, ill-conditioned, requires fp64 |
| 6 | **Parallelism & Communication** | Can it be parallelized across SMs / devices? Communication-to-compute ratio; can overlap be achieved? | Highly parallel, communication overlap-able | Long serial recurrences, communication bottleneck |
| 7 | **Sparsity** | Structured or unstructured sparsity? | Block / banded structured sparsity | Random gather/scatter |
| 8 | **Kernel Fusion** | Can kernels be fused to avoid materializing large intermediates (FlashAttention-style)? | Fusible, recomputable | Frequent small kernels, divergent control flow |

**Scoring conclusion**: Retain only candidates that are **mathematically beautiful AND (all eight dimensions friendly or adaptable)**; any dimension rated "unfriendly and non-adaptable" means the candidate must be adapted or eliminated.

## Common "Beautiful but Non-Computable" Anti-Patterns

- **Dense global $O(n^2)$ operators**: Naive softmax attention explodes with context length.
- **Unstructured sparsity / irregular graph traversal**: Random memory access destroys locality.
- **High-precision dependency**: Ill-conditioned problems that require fp64 for correctness (most training runs only bf16/fp16/fp8).
- **Serial recurrence**: Long-range dependencies that cannot be parallelized (naive RNN-style).
- **Frequent small kernels + control-flow divergence**: Launch overhead and warp divergence consume throughput.
- **Non-differentiable / requiring discrete search**: Breaks end-to-end gradient-based training.

## Make-It-Computable Toolkit

Common techniques for transforming "beautiful but non-computable" into "both beautiful and computable":

- **Discrete → continuous relaxation**: Gumbel-softmax; **piecewise-linear** gating on the **tropical semiring** as a replacement for hard Top-K.
- **Block sparsification**: Dense attention within blocks, structured sparse between blocks (e.g., DeepSeek CSA-style blocking).
- **Low-rank / projection compression**: Restriction maps via low-rank linear transformations; **low-rank basis-style block summaries** for KV-Cache compression (store the basis rather than Plücker coordinates — the latter expands when low-rank).
- **Numerical reparameterization**: log-sum-exp, normalization, stable softmax — ensuring low-precision stability.
- **Kernel fusion / recomputation**: Fused kernels, activation recompute to save memory.
- **Embedding structure into GEMM**: Express algebraic/geometric transformations as **learnable linear maps** so they naturally map onto Tensor Cores.

## Worked Example: Tropical Sheaf Attention

Drawn from the auto-research directions cited in `agentic-workflow.md`, demonstrating how a **candidate design enters the 8-dimension verification**:

| Component | Mathematical Source | GPU Friendliness |
|-----------|-------------------|-----------------|
| Tropical Gating | Tropical semiring, piecewise-linear | Replaces Top-K: element-wise max-plus — dim 1 ✅ Tensorization / dim 2 ❌ Not a Tensor Core GEMM (runs on CUDA cores) / dim 3 ✅ Per-token gating only, sub-quadratic (min-plus matmul is APSP-hard, not sub-quadratic); sub-differentiable, kinks require LogSumExp smoothing (smoothing recovers standard softmax) |
| Cellular Sheaf Diffusion | Algebraic geometry / topology (sheaves, restriction maps) | Each edge is a low-rank linear transform = small GEMM (dim 2/4) |
| Čech Cohomology Regularization | Algebraic topology (first cohomology $H^1$) | Local, inexpensive; serves as an algebraic criterion for hallucination (dim 3/8) |
| Low-Rank Basis KV Compression (Plücker/Grassmannian perspective) | Projective geometry | Store the basis rather than Plücker coordinates (the latter expands when low-rank); block-summary candidate — compression ratio / error / throughput must be benchmarked (dim 4) |

Do not treat the table above as validated conclusions. The correct approach is to enter each component into the test plan: prove or estimate complexity, measure peak memory and throughput, check bf16/fp8 stability, and confirm whether it can be mapped to GEMM / batched GEMM / fused kernels. Only after both empirical benchmarks and theoretical derivations pass should a component be labeled "math beautiful × GPU friendly."
