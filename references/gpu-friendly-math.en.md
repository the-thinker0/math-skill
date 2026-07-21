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

1. **Mathematically correct (beautiful in math)** — The structure is self-consistent, differentiable (or relaxable to differentiable), with correctness guarantees.
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
- **Non-differentiable / requiring discrete search**: Breaks end-to-end gradient-based training.

## Make-It-Computable Toolkit

Common techniques for transforming "beautiful but non-computable" into "both beautiful and computable":

- **Discrete → continuous relaxation**: Gumbel-softmax; **piecewise-linear** gating on the **tropical semiring** as a replacement for hard Top-K.
- **Block sparsification**: Dense attention within blocks, structured sparse between blocks (e.g., DeepSeek CSA-style blocking).
- **Low-rank / projection compression**: Restriction maps via low-rank linear transformations; **low-rank basis-style block summaries** for KV-Cache compression (store the basis rather than Plücker coordinates — the latter expands when low-rank).
- **Numerical reparameterization**: log-sum-exp, normalization, stable softmax — ensuring low-precision stability.
- **Operator fusion / recomputation**: Fused kernels, activation recompute to save memory.
- **Embedding structure into GEMM**: Express algebraic/geometric transformations as **learnable linear maps** so they naturally map onto Tensor Cores.

## Worked Example: Tropical Sheaf Attention

Drawn from the auto-research directions cited in `agentic-workflow.en.md`, demonstrating how a **candidate design enters the 8-dimension verification**:

| Component | Mathematical Source | GPU Friendliness |
|-----------|-------------------|-----------------|
| Tropical Gating | Tropical semiring, piecewise-linear | Element-wise max-plus gating is tensorizable but is not a GEMM; full min-plus matrix multiplication is closely related to APSP-type complexity. Kinks admit subgradients, while LogSumExp is a smoothing approximation that changes the operator. |
| Cellular Sheaf Diffusion | Algebraic geometry / topology (sheaves, restriction maps) | Each edge is a low-rank linear transform = small GEMM (D2/D4) |
| Candidate Čech Cohomology Regularizer | Algebraic topology (first cohomology $H^1$) | Unvalidated: complex construction and homology computation may be expensive. “Hallucination criterion” is a research hypothesis requiring a computable surrogate, complexity analysis, and effectiveness experiments. |
| Low-Rank Basis KV Compression (Plücker/Grassmannian perspective) | Projective geometry | Store the basis rather than Plücker coordinates (the latter expands when low-rank); block-summary candidate — compression ratio / error / throughput must be benchmarked (D4) |

Do not treat the table above as validated conclusions. The correct approach is to enter each component into the test plan: prove or estimate complexity, measure peak memory and throughput, check bf16/fp8 stability, and confirm whether it can be mapped to GEMM / batched GEMM / fused kernels. Only after both empirical benchmarks and theoretical derivations pass should a component be labeled "math beautiful × GPU friendly."
