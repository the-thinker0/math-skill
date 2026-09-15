# GPU-Friendly Math Checklist

> This file is the **single source of truth** for the "GPU-feasibility" acceptance gate.
> The activator, the 15 thinking lenses, `books/*.md`, and `../agents/math-critic.en.md` all reference this file; no duplicate definitions elsewhere.

## Eight-Dimension Abbreviations

| Abbrev. | Full Name |
|---------|-----------|
| D1 | Tensorization |
| D2 | GEMM-mappability |
| D3 | Complexity |
| D4 | Memory & KV-Cache |
| D5 | Low-precision stability |
| D6 | Parallelism & communication |
| D7 | Sparse structure |
| D8 | Operator fusion |

Rating marks: `[v]` friendly (tensorizable/negligible cost), `[~]` partially feasible (requires approximation; approximation quality decides the outcome), `[x]` unfriendly (serial/cannot be materialized/memory-infeasible).

## Quantitative Checklist

Evaluate only dimensions relevant to the candidate and deployment target; mark others `N/A`. For decision-changing dimensions, provide concrete numbers rather than labels:

| Dimension | Quantitative Questions to Answer |
|-----------|--------------------------------|
| D1 Tensorization | What are the tensor shapes of core operations? Where is the batch dimension? |
| D2 GEMM-mappability | How many GEMM/matmul operations? What are the (M,N,K) dimensions of each? |
| D3 Complexity | Total FLOPs? Ratio vs. baseline (standard attention/MLP)? |
| D4 Memory | Peak memory (bytes)? Is an n×n matrix materialized? KV-Cache overhead? |
| D5 Low-precision | Numerical error magnitude under bf16/fp8? Mixed-precision strategy needed? |
| D6 Parallelism | Theoretical parallelism degree? Communication volume (bytes/step)? All-reduce required? |
| D7 Sparsity | Sparsity ratio (%)? Sparse format (CSR/BSR/block-sparse)? Dedicated kernel available? |
| D8 Operator Fusion | Number of fusible kernels? Reduction in kernel launches and memory transfers after fusion? |

## Core Proposition

**Mathematical beauty ≠ computability.** For a structure to truly enter training and inference on modern GPU clusters, it must simultaneously satisfy two requirements:

1. **Mathematically correct (beautiful in math)** — The structure is self-consistent and claims have explicit conditions and evidence. Differentiability or a suitable gradient estimator is needed only along a gradient path; inference and discrete algorithms need not be differentiable.
2. **Hardware-feasible (friendly to GPU)** — It can be efficiently mapped onto GPU microarchitecture (Tensor Cores, memory hierarchy, parallelism, and interconnects).

Many "beautiful on paper" modern mathematical structures cannot run at high performance once they encounter GPU parallelism and low-precision arithmetic errors. This checklist turns "GPU feasibility" into an **item-by-item scorable** engineering standard, preventing non-computable constructs from being accepted as deliverables.

## The 8-Dimension Scorecard

Rate candidate structures as `Friendly / Retrofittable / Unfriendly / N/A`. State shapes, baseline, and deployment constraints first, then select relevant dimensions. Do not force KV-cache, sparsity, or communication analysis onto an ordinary scalar loss merely to fill eight rows.

| # | Dimension | Key Question | Friendly [v] | Unfriendly [x] |
|---|-----------|-------------|------------|--------------|
| 1 | **Tensorization** | Can it be expressed as dense tensor operations, avoiding element-wise irregular control flow? | Batched tensor algebra | Scalar loops, data-dependent branches |
| 2 | **GEMM-mappability** | Can it use matrix multiplication / batched GEMM / convolution, and are shapes large enough for efficient utilization? | Large regular GEMM or mature library kernel | Irregular work, or tiny launch-bound GEMMs |
| 3 | **Complexity** | What are forward/backward FLOPs and scaling relative to the baseline? | Meets target-scale latency/throughput budgets | Exceeds deployment budgets or has an unacceptable scaling bottleneck |
| 4 | **Memory & KV-Cache** | Peak memory usage; activation / state / KV footprint; can it be compressed? | Low-rank / quantized / block-summary compressible | Must materialize large intermediate tensors |
| 5 | **Low-Precision Stability** | Is it stable under fp16/bf16/fp8 with deterministic reproducibility? | Controlled dynamic range, numerically robust | Catastrophic cancellation, ill-conditioned, requires fp64 |
| 6 | **Parallelism & Communication** | Can it be parallelized across SMs / devices? Communication-to-compute ratio; can overlap be achieved? | Highly parallel, communication overlap-able | Long serial recurrences, communication bottleneck |
| 7 | **Sparse structure** | Structured or unstructured sparsity? | Block / banded structured sparsity | Random gather/scatter |
| 8 | **Operator Fusion** | Can kernels be fused to avoid materializing large intermediates (FlashAttention-style)? | Fusible, recomputable | Frequent small kernels, divergent control flow |

**Scoring conclusion**: Separate hard constraints from optimization goals. Eliminate a candidate only when it violates a task-critical hard constraint and cannot be adapted; otherwise report the main bottleneck and validation plan. `N/A` is not a failure, and GEMM expressibility is not evidence of measured speed.

## Common "Beautiful but Non-Computable" Anti-Patterns

- **Dense global operators without a target-scale analysis**: $O(n^2)$ is not automatically infeasible, but materializing $n\times n$ tensors often exceeds long-context budgets. Compare against the baseline, target $n$, and fused implementation.
- **Unstructured sparsity / irregular graph traversal**: Random memory access destroys locality.
- **High-precision dependency**: Ill-conditioned problems that require fp64 for correctness (most training runs only bf16/fp16/fp8).
- **Serial recurrence**: Long-range dependencies that cannot be parallelized (naive RNN-style).
- **Frequent small kernels + control-flow divergence**: Launch overhead and warp divergence consume throughput.
- **Discrete operations on a gradient path**: Specify an estimator or relaxation, or move the operation off that path. Non-differentiability does not imply non-computability.

## Make-It-Computable Toolkit

Common techniques for transforming "beautiful but non-computable" into "both beautiful and computable":

- **Discrete → continuous relaxation**: Gumbel-softmax or a task-specific soft sorting relaxation. Max-plus gating is a separate piecewise-linear design; it does not automatically approximate Top-K or preserve exact sparsity.
- **Block sparsification**: Dense attention within blocks, structured sparse between blocks.
- **Low-rank / projection compression**: Restriction maps via low-rank linear transformations; **basis plus coefficients** for KV-Cache compression, or an explicitly approximate block summary. Count both factors; a subspace alone cannot reconstruct arbitrary keys or values, and the binomial Plücker coordinate count depends on ambient dimension and rank.
- **Numerical reparameterization**: log-sum-exp, normalization, and stable softmax reduce known numerical risks; precision and dynamic-range tests are still required.
- **Operator fusion / recomputation**: Fused kernels, activation recompute to save memory.
- **Embedding structure into GEMM**: Express algebraic/geometric transformations as **learnable linear maps**, then check dtype, dimensions, and kernel implementation for actual Tensor Core use.

## Worked Example: Tropical Sheaf Attention

The following exploratory composition illustrates how a **candidate design enters the 8-dimension verification**. It is not a published method or an experimental result:

| Component | Mathematical Source | GPU Friendliness |
|-----------|-------------------|-----------------|
| Tropical Gating | Tropical semiring, piecewise-linear | Element-wise max-plus gating is tensorizable but is not a GEMM; full min-plus matrix multiplication is closely related to APSP-type complexity. Kinks admit subgradients, while LogSumExp is a smoothing approximation that changes the operator. |
| Cellular Sheaf Diffusion | Algebraic geometry / topology (sheaves, restriction maps) | Edge restriction maps can be low-rank linear transforms; account for coefficients, gathers, scatter-add, and small-kernel overhead as well as GEMM (D2/D4/D7). |
| Cellular Consistency Regularizer | Algebraic topology (coboundary $d^0$) | A loss $\|d^0x\|^2$ measures compatibility under specified restriction maps. It does not establish factual truth or detect hallucinations; exact $H^1$ requires an appropriate complex and separate computation. |
| Low-Rank Basis KV Compression (Plücker/Grassmannian perspective) | Projective geometry | Store basis plus coefficients when reconstructing K/V; a subspace summary alone loses information. Count all storage and benchmark output error and throughput (D4). |

Do not treat the table above as validated conclusions. The correct approach is to enter each component into the test plan: prove or estimate complexity, measure peak memory and throughput, check bf16/fp8 stability, and confirm whether it can be mapped to GEMM / batched GEMM / fused kernels. Only after both empirical benchmarks and theoretical derivations pass should a component be labeled "math beautiful × GPU friendly."
