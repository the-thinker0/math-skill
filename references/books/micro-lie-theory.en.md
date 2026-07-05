# A Micro Lie Theory

> **A micro Lie theory for state estimation in robotics** -- Joan Solà, Jeremie Deray, Dinesh Atchuthan.
> arXiv:1812.01537v9 [cs.RO], 2021-12-08, main text approx. 17 pages + appendix formula handbook. Companion open-source C++ header library **manif** (<https://github.com/artivis/manif>, implementing SO(2)/SO(3)/SE(2)/SE(3) with analytic Jacobians).
> This file is an "activation" distillation, **not a restatement of the original**; for full fidelity, consult the local PDF (see (Deep Dive Entry)).

## Overview

This paper **deliberately "amputates"** the vast edifice of Lie theory down to the minimal subset needed for robotic state estimation: it does not even introduce the Lie bracket, instead reducing the Lie algebra directly to the isomorphic vector space R^n, so that the "curved, nonlinear" Lie group becomes "flat, linear" vector algebra in the tangent space. The one-sentence thesis: **virtually every operation on the group (curved) has an exact counterpart in the Lie algebra (flat)** (Fig. 1) -- this is the modern use of Sophus Lie's "dragon-slaying sword" from inspiration.md: the dragon (solving differential equations) was never slain, yet the sword became a supreme tool for chopping vegetables (linearizing nonlinearities), carving (describing symmetries), and building houses (robotic state estimation).

Actual structure map:
- **II. A micro Lie theory (core)**: A Lie groups (group axioms + manifold) -> B group actions -> C tangent space and Lie algebra (hat `^wedge` / vee `^vee` operators) -> D **exponential map** exp/log and capital Exp/Log (Eq. 23-24) -> E **addition/subtraction operators** oplus/ominus (Eq. 25-28, left and right versions) -> F **adjoint** Ad_X and adjoint matrix (Eq. 30-35) -> G **derivatives on Lie groups**: right Jacobian (Eq. 41a-c) / left Jacobian (Eq. 44) -> H **uncertainty on manifolds and covariance propagation** (Eq. 52) -> I discrete integration on manifolds.
- **III. Manifold differentiation rules**: A chain rule, B elementary Jacobian blocks, C derived Jacobian blocks.
- **IV. Composite manifolds / bundles**: assembling heterogeneous large states into non-interacting manifold blocks, differentiating block by block (Eq. 84-90, Ex. 7 comparing SE(n) vs T(n)xSO(n) vs (R^n, SO(n))).
- **V. Applications**: landmark-based localization and mapping -- error-state Kalman filter on manifolds (Eq. 92-96), graph-optimization SLAM, sensor self-calibration.
- **VI. Conclusion + Appendix**: complete closed-form formulas for S^1/SO(2)/SE(2), S^3/SO(3), SE(3) (including right/left Jacobians, e.g. SO(3) Eq. 143-145).

## Core Structures Transferable to AI/Infra

The paper welds together the "curved nonlinear group" and the "flat linear vector space" using five tools, each of which can be directly ported into differentiable algorithms.

### 1. exp/log Maps -> Manifold Parameterization (Eq. 23-24, Fig. 1)

`Exp: R^n -> M`, `Log: M -> R^n` are the bijective bridges between the manifold and its tangent space (isomorphic to linear R^n). Transfer usage: **let the network freely predict in the unconstrained tangent space R^n, then map back to the valid manifold via Exp**. Rotations, poses, and unit quaternions thus naturally satisfy constraints (orthogonality, unit norm), eliminating the need for various ad-hoc post-hoc orthogonalization or normalization fixes on regressed matrices/quaternions.

### 2. oplus/ominus Addition/Subtraction Operators -> "Vector Algebra" on Manifolds (Eq. 25-28)

`oplus` (one Exp + one group composition) makes "adding an increment to a manifold state" look like ordinary vector addition; `ominus` computes the difference between two elements (geodesic residual). **Key pitfall**: because group composition is non-commutative, oplus/ominus come in **right versions** (increment in local frame / tangent at X) and **left versions** (increment in global frame / tangent at identity E); the paper defaults to the right version -- in engineering, one must stay consistent throughout; mixing conventions leads to errors.

### 3. Right/Left Jacobians -> Geometrically Correct Backpropagation (Eq. 41a-c, 44)

The linearization of a manifold function with respect to tangent-space perturbations is the Jacobian; the chain rule on manifolds takes the form `D(g o f)/DX = J_g . J_f` (Sec. III-A), isomorphic to the Euclidean chain rule, so it plugs directly into automatic differentiation. The **right Jacobian** (Eq. 41) and **left Jacobian** (Eq. 44) describe the same derivative in local vs. global tangent spaces, related to each other through the adjoint Ad.

### 4. Adjoint Matrix Ad_X -> Transporting Tangent Vectors Across Frames (Eq. 30-35)

`Ad_X` transports the same tangent vector between different points and left/right frames (Eq. 32: `X oplus tau = (Ad_X tau) oplus X`). It is the **algebraic realization of equivariance**, and also the transformation matrix for propagating perturbations/covariances across frames; Ex. 6 gives the closed-form adjoint matrix for SE(3).

### 5. Covariance Propagation -> Uncertainty on Manifolds (Eq. 52)

`Sigma = E[(X om Xbar)(X om Xbar)^T] in R^{m x m}` -- **the covariance lives in the tangent space R^n, not on the group**. Defining variance directly on the group is ill-posed; the tangent-space representation brings the uncertainty computations of Kalman filters / factor graphs back to familiar linear algebra.

Two additional directly usable "components":
- **SE(3) / SO(3)**: rigid body motion group / rotation group -- the unified differentiable representation of pose = rotation + translation, the standard language for cameras, point clouds, and robotic arm joints.
- **Composite manifolds (bundles, Eq. 84-90)**: assembling multi-pose + feature + calibration heterogeneous large states into non-interacting manifold blocks, with Jacobians **assembled block by block** (Eq. 89 is block-structured sparse), i.e., "assemble the Jacobian matrix block by block" in engineering practice.

## Problem Types Suited for Activation

- Prediction/regression targets carry **geometric constraints**: rotations, poses, unit vectors, SPD matrices -- forcing them into Euclidean MLPs breaks the constraints.
- Need **equivariance / invariance**: when the input undergoes rigid body transformations, the output should covary or remain invariant (point clouds, molecules, multi-view geometry).
- Need **explicit uncertainty**: pose estimation, sensor fusion, SLAM, visual odometry covariance propagation.
- **Iterative geometric optimization**: camera/point cloud registration, bundle adjustment, inverse kinematics, requiring gradient/Gauss-Newton on manifolds rather than in Euclidean space.
- States **evolve on Lie groups**: inertial pre-integration, motion models, differentiable physics/control.

## Possible Algorithmic Inspirations

- **SE(3)/SO(3) equivariant networks**: using group elements as hidden states, updating between layers via Exp/opus, transporting features via Ad; equivariance comes from group actions rather than data augmentation.
- **Manifold loss for pose regression**: using ominus (geodesic error) as the loss, rather than Euclidean MSE on rotation matrices/quaternions; naturally handles manifold topology (e.g., quaternion double cover).
- **Lie group optimizers**: rewriting Adam/Gauss-Newton in the retraction form "compute gradient in tangent space -> map back via Exp" (error-state approach, corresponding to the manifold EKF in Sec. V-A).
- **Differentiable registration / alignment**: camera pose, point cloud ICP, multi-view BA formulated as differentiable optimization layers on SE(3), trained end to end.
- **Manifold-parameterized output heads**: the network outputs an R^n tangent vector, mapped back to SO(3)/SE(3) via Exp, replacing the various ad-hoc orthogonalization schemes for 6D/9D rotation representations.
- **Uncertainty-aware fusion**: using the tangent-space covariance from Eq. 52 + Ad propagation to build learnable Kalman/factor-graph layers.

## GPU Friendliness Warning

> The sole authority for the acceptance gate: [`../gpu-friendly-math.en.md`](../gpu-friendly-math.en.md) (eight dimensions: D1 Tensorization, D2 GEMM-mappability, D3 Complexity, D4 Memory/KV, D5 Low-precision stability, D6 Parallelism & communication, D7 Sparse structure, D8 Operator fusion). Dimension-by-dimension scoring follows.

| # | Dimension | Rating | Notes |
|---|---|---|---|
| D1 | Tensorization | [v] | SO(3)/SE(3) exp/log have **closed forms** (Rodrigues), 3x3/4x4 small matrices, batched as `[B,3,3]` / `[B,4,4]` tensors, sample-independent |
| D2 | GEMM-mappability | [~] | 3x3/4x4 are too small to **saturate Tensor Cores**, bmm/batched small GEMM has low utilization and is easily memory-bandwidth-bound; fix: stack the batch dimension large, use specialized small kernels or einsum fusion |
| D3 | Complexity | [v] | O(1) per element, linear in batch |
| D4 | Memory | [v] | Elements are tiny; however, Jacobians/covariance matrices for high-DOF composite states can grow large (block-structured, still manageable) |
| D5 | Low-precision stability | [x] **critical** | exp/log contain terms like `sin(theta)/theta`, `(1-cos(theta))/theta^2`, which cause catastrophic cancellation at **theta->0** (division by zero) and **theta->pi** (log singularity); fp16/bf16 are highly prone to NaN. **Must** switch to Taylor expansion for small angles -- branching introduces warp divergence (hurts D1, D8) |
| D6 | Parallelism & communication | [~] | Per-sample exp/log is embarrassingly parallel [v]; however **discrete integration / motion chains on manifolds** (Sec. II-I, chained Exp products) are **serial recurrences**, long sequences must be rewritten as parallel scans to achieve parallelism |
| D7 | Sparse structure | [v] | Composite manifold Jacobians are **block-structured sparse** (Eq. 89), GPU-friendly |
| D8 | Operator fusion | [v] | Closed-form exp/log/Jacobians can be fused into a **single kernel**, avoiding materialization of intermediate small matrices |

**Expanded notes (closed-form vs. series / batching / whether small-matrix exponentials can be tensorized)**:

The GPU fate of `exp/log` in Lie theory depends entirely on "whether one is working with a low-dimensional group that admits a closed form."

- **Closed-form vs. series (Conclusion 1)**: The exponential map for SO(3) is precisely the **Rodrigues formula** `exp([theta]_x) = I + (sin(theta)/theta)[theta]_x + ((1-cos(theta))/theta^2)[theta]_x^2` (Ex. 4); SE(3) is similar with an additional left-Jacobian factor V(theta) -- both are **finite-term closed forms**, pure tensor algebra, per-sample independent, no data-dependent loops. The opposite case is the **general matrix exponential**: for arbitrary Lie groups there is no Rodrigues-style closed form, only Taylor series + scaling-and-squaring **iterative** approximation, with data-dependent step counts, divergent control flow, and difficult tensorization -- a classic "beautiful but not computable" case. Closed forms exist only for the small set SO(3)/SE(3)/SE(2)/S^1/S^3; **do not treat the general matrix exp as a cheap O(1) operator**.
- **Batching (Conclusion 2)**: stacking N rotations/poses into `[B,3,3]` / `[B,4,4]` for batched Exp/Log is clean element-wise + small bmm, which can be **fused with downstream operators into a single kernel**. Small-matrix exponentials **can** be tensorized -- batched stacking gives per-sample parallelism; but 3x3/4x4 are too small for bmm to saturate Tensor Cores, the value lies in "batchable and fusible" rather than "maxing out compute," and to improve utilization one should stack the batch large or use specialized small kernels.
- **Low-precision singularities (Conclusion 3, top risk)**: theta->0 (`sin(theta)/theta` division by zero) and theta->pi (log is non-unique) cause catastrophic cancellation, fp16/bf16 produce NaN directly. Before low-precision training, one **must** implement Taylor-expansion fallbacks for small angles and run deterministic reproducibility tests; the fallback branches introduce warp divergence, requiring `where`/mask implementations rather than data-dependent jumps.
- **Serial recurrence**: motion chains / discrete integration on manifolds (Sec. II-I) are serial recurrences of chained Exp products; long sequences must be rewritten as parallel scans to saturate the GPU.

## Which Design Lens to Invoke

- **symmetry (primary)**: Lie groups are by definition **continuous symmetry transformation groups**; this paper is the most direct mathematical ammunition for "symmetry/invariance -> equivariant networks."
- **duality (primary)**: exp/log equivalently transforms "curved nonlinear manifold" to "flat linear tangent space" -- a paradigmatic example of transforming a hard problem into an easy one (the dragon-slaying sword used for "chopping vegetables").
- **variational**: optimization on manifolds, retractions, error-state filtering (Sec. V-A).
- **geometric**: the modeling closed loop from reality (robotic/camera state + noise) to mathematics (manifold + covariance) to interpretation.
- **categorical**: abstracting from concrete matrices/quaternions to the unified "group" interface (the paper's own writing style -- generic formulation + grounded examples -- is itself an abstraction demonstration).

## Anti-patterns

- **Adding/subtracting rotations/poses directly in Euclidean space**: doing Euclidean MSE or linear interpolation on rotation matrices/quaternions -- breaks manifold constraints; use oplus/ominus and geodesic error instead.
- **Mixing left and right perturbations**: inconsistent conventions for right/left Jacobians, local/global frames, causing misalignment of covariances and gradients (the paper repeatedly emphasizes defaulting to the right version).
- **Assuming matrix exp is cheap and closed-form everywhere**: closed forms exist only for SO(3)/SE(3) and a few other groups; general groups require iterative series and cannot be treated as O(1) operators.
- **Not handling singularities in low precision**: failing to implement Taylor fallbacks for theta->0/pi causes fp16 training to produce NaN immediately.
- **Treating SE(3) as T(3)xSO(3)**: their tangent-space parameterizations differ (Ex. 7); whether translation and rotation are coupled changes the Jacobian, and misuse leads to systematic bias.
- **Over-application**: forcing Lie theory onto tasks that do not need uncertainty propagation or geometric constraints, adding complexity and singularity risk for no gain -- mathematical beauty does not mean it should be used.

## Deep Dive Entry

> **Bibliographic info**: Joan Sola, Jeremie Deray, Dinesh Atchuthan, *A micro Lie theory for state estimation in robotics*, arXiv:1812.01537v9, 2021. Companion open-source C++ library [manif](https://github.com/artivis/manif).
>
> **Activation method**: Place `A micro Lie theory.pdf` in the `math_book/` folder at the project root; the Agent can then automatically search the original text. The PDF is not distributed via npm/git (copyright reasons); obtain it independently.

> Full-fidelity lookup = have the Agent automatically retrieve the local PDF: `math_book/A micro Lie theory.pdf` (using `pdftotext` or Read PDF pages). The following are actual section/equation-block locations within that PDF:

1. **Sec. II-D Exponential map + Fig. 1**: exp/log and capital Exp/Log operators (Eq. 23-24) -- the manifold-to-tangent-space bridge and closed-form source; with Ex. 3 (SO(3) Lie algebra `[omega]_x`), Ex. 4 (SO(3) exp = Rodrigues).
2. **Sec. II-E Addition/subtraction operators (Eq. 25-28) + Sec. II-F Adjoint Ad_X (Eq. 30-35)**: "addition/subtraction" on manifolds and left/right perturbation conversions; Ex. 6 (SE(3) adjoint matrix).
3. **Sec. II-G Derivatives on Lie groups + Sec. III-A Chain rule**: right Jacobian (Eq. 41a-c), left Jacobian (Eq. 44), related through the adjoint -- the geometrically correct form for backpropagation/gradients.
4. **Sec. II-H Uncertainty on manifolds and covariance propagation (Eq. 52)**: Sigma defined on the tangent space; Sec. V-A manifold error-state EKF (Eq. 92-96) is the applied example.
5. **Appendix formula handbook**: SO(3) right/left Jacobian closed forms (Eq. 143-145), SE(3) Jacobians (citing Barfoot), and Sec. IV composite manifold block-wise Jacobians (Eq. 84-90, Ex. 7) -- direct lookup tables for engineering implementation, cross-referenced with the manif library.
