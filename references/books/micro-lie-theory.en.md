# A Micro Lie Theory

> **A micro Lie theory for state estimation in robotics** -- Joan Solà, Jeremie Deray, Dinesh Atchuthan.
> arXiv:1812.01537v9 [cs.RO], 2021-12-08, main text approx. 17 pages + appendix formula handbook. Companion open-source C++ header library **manif** (<https://github.com/artivis/manif>, implementing SO(2)/SO(3)/SE(2)/SE(3) with analytic Jacobians).
> This file is an "activation" distillation, **not a restatement of the original**; for full fidelity, consult the local PDF (see (Deep Dive Entry)).

## Overview

The paper selects Lie-group tools for state estimation and expresses small perturbations, Jacobians and uncertainty in vector coordinates of the Lie algebra. This does not turn the group into ordinary linear algebra: generally exp(A+B) ≠ exp(A)exp(B), and logarithms require local branches. Applications to AI below are design extrapolations, not performance guarantees proved by the robotics paper.

The main route is §II: group actions, tangent coordinates, Exp/Log, plus/minus operators, adjoints, derivatives and covariance; §III: differentiation rules; §IV: composite states; §V: estimation examples; appendices: formulas for rotation and rigid-motion groups.

## Core Structures Transferable to AI/Infra

### 1. Exp/Log: local coordinates, not a global bijection

After choosing a Lie-algebra basis, Exp(τ)=exp(τ^∧). Near the identity, Exp and a selected Log branch are local inverses; neither global injectivity nor global surjectivity holds for arbitrary Lie groups. SO(3) rotation vectors are periodic, and the logarithm has branch ambiguity near π. Exp enforces group constraints without removing these topological issues. The Lie-group exponential agrees with a Riemannian geodesic exponential only under suitable metric conditions. [Original §II-D and Appendix B](https://arxiv.org/html/1812.01537v9#S2.SS4)

### 2. Left/right perturbations and residuals

Fix the right convention X⊕δ = X Exp(δ), giving Y⊖X = Log(X⁻¹Y); left perturbations use δ⊕X = Exp(δ)X. Both δ coordinates live in the Lie algebra at the identity and are translated to perturbations at the state. Keep frames, multiplication order, Log branches and residual weights consistent. A general group Log-residual norm is not automatically the distance of a specified Riemannian metric.

### 3. Jacobians and backpropagation

Derivatives of group maps become ordinary Jacobians in the selected perturbation coordinates and compose by the chain rule. Left/right conversion must account for the input and output base-point adjoints. Check automatic derivatives against finite differences near small angles and Log branches.

### 4. Adjoint conversion is not arbitrary-path parallel transport

Conjugation defines Ad_X: X Exp(δ) X⁻¹ = Exp(Ad_X δ). Thus equivalent perturbations satisfy δ_left = Ad_X δ_right. This converts coordinates and covariances; it does not replace parallel transport along an arbitrary curve for a specified connection.

### 5. Local uncertainty

With δ = Log(X̄⁻¹X), covariance is Σ = E[(δ−Eδ)(δ−Eδ)ᵀ]; only zero-mean perturbations permit E[δδᵀ]. This is a local matrix representation depending on the base point, perturbation convention and Log branch. Jacobian propagation is a small-perturbation approximation. Given a metric, Fréchet means and intrinsic variances are also well-defined notions; variance on a group is not inherently ill-posed.

SO(3)/SE(3) states and perturbations suit pose tasks. SE(3) is R³×SO(3) as a manifold but has semidirect-product group multiplication. Composite-state Jacobians must follow the actual product and coupling.

## Problem Types Suited for Activation

- Prediction/regression targets carry **geometric constraints**: rotations, poses, unit vectors, SPD matrices -- forcing them into Euclidean MLPs breaks the constraints.
- Need **equivariance / invariance**: when the input undergoes rigid body transformations, the output should covary or remain invariant (point clouds, molecules, multi-view geometry).
- Need **explicit uncertainty**: pose estimation, sensor fusion, SLAM, visual odometry covariance propagation.
- **Iterative geometric optimization**: camera/point cloud registration, bundle adjustment, inverse kinematics, requiring gradient/Gauss-Newton on manifolds rather than in Euclidean space.
- States **evolve on Lie groups**: inertial pre-integration, motion models, differentiable physics/control.

## Possible Algorithmic Inspirations

- **Pose output heads**: predict Lie-algebra coordinates and map to SO(3)/SE(3). Compare against redundant rotation representations; Exp does not eliminate global branch/continuity issues.
- **Rotation losses**: use a consistent relative-Log residual or a deliberately chosen chordal distance. Quaternion q and −q represent the same rotation and still require explicit equivalence handling.
- **Manifold optimizers**: tangent updates followed by a suitable retraction; transport momentum consistently rather than copying Euclidean Adam coordinatewise.
- **Differentiable registration**: expose group actions and analytic Jacobians in pose alignment or bundle adjustment; verify derivatives and conventions.
- **Uncertainty propagation**: local perturbation covariance plus Jacobians/adjoints, with approximation validity checked against noise scale.
- **Equivariant modules**: require each map to commute with a specified group action; using Exp or Ad alone does not prove equivariance.

## GPU Friendliness Warning

Select relevant dimensions from [`../gpu-friendly-math.en.md`](../gpu-friendly-math.en.md). These are implementation analyses, not measured benchmarks.

- **D1/D2/D8 [~]**: SO(3)/SE(3) admit low-dimensional analytic expressions, batching and fusion; 3×3/4×4 matrices do not guarantee high Tensor Core utilization. General matrix exponentials can also be batched, with cost depending on size, algorithm, norm and tolerance, not a universal O(1).
- **D3/D4 [v]**: At fixed SO(3)/SE(3) dimension, state size and a single analytic operation do not grow with batch size; B independent states use O(B) storage. Composite-state covariance can grow quadratically in state dimension.
- **D5 [~]**: The θ→0 singularities in sinθ/θ and (1−cosθ)/θ² are removable; use stable series or sinc forms. The SO(3) Log near π requires separate axis/sign/branch handling, not a zero-angle Taylor fallback. Compare group residuals and gradients against fp32 at the target precision.
- **D6/D7 [~]**: Predetermined group increments admit associative prefix scans. State-dependent next increments do not directly fit that scan. Block sparsity needs matching layouts and kernels to produce a speedup.

In frameworks that evaluate both branches of where, an unselected branch can still generate invalid intermediates. Make each branch numerically safe before masking.

## Which Design Lens to Invoke

- **symmetry (primary)**: Lie groups are by definition **continuous symmetry transformation groups**; this paper is the most direct mathematical ammunition for "symmetry/invariance -> equivariant networks."
- **duality**: compare group states with local perturbation coordinates while retaining Log branches and noncommutativity.
- **variational**: optimization on manifolds, retractions, error-state filtering (Sec. V-A).
- **geometric**: the modeling closed loop from reality (robotic/camera state + noise) to mathematics (manifold + covariance) to interpretation.
- **categorical**: abstracting from concrete matrices/quaternions to the unified "group" interface (the paper's own writing style -- generic formulation + grounded examples -- is itself an abstraction demonstration).

## Anti-patterns

- Treating Exp as global singularity-free coordinates, or using exp(A+B)=exp(A)exp(B) for noncommuting matrices.
- Mixing perturbation sides, frames, quaternion signs or Log branches across residuals and covariances.
- Equating group Log residuals, Riemannian geodesic distance and Euclidean chordal distance without specifying the metric and representation.
- Using a zero-angle Taylor expansion to resolve the Log branch near π, or checking only forward values rather than derivatives.
- Assuming Exp/Ad parameterization alone guarantees network equivariance; each module must commute with the specified group action.
- Adding Lie-group operators when the task has no geometric constraints or uncertainty requirement.

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
