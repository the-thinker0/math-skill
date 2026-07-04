# Topology-Preserving Compression
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「✅ 已验证 / ⚠️ 可改造需验证 / ❌ 不可行」。未标注的视为理论可行，需工程验证。

## Target Problem
Use when compressing representations while homologically preserving the intrinsic topological structure of the data (connected components, loops, cavities): latent-space compression (a toroidal manifold must not collapse into a line segment), knowledge distillation (student--teacher homological equivalence), 3D mesh simplification (genus invariance), KV-Cache semantic preservation (cluster structure must not collapse). Core objective: **compress dimensions or counts while ensuring that changes in the persistence diagram of persistent homology remain controlled**.

## Mathematical Foundations
- Lenses: lenses/topological.md (topological invariants -- connected components and hole counts are invariant under continuous deformation), lenses/spectral.md (Gauss--Bonnet linking curvature and Euler characteristic), lenses/variational.md (constrained variational of compression ratio vs. topological fidelity)
- Knowledge: knowledge-base/topology/persistent-homology.md (persistent homology, Vietoris--Rips filtration, bottleneck distance), knowledge-base/topology/euler-characteristic.md (Euler characteristic for rapid topological diagnostics), knowledge-base/matrix-analysis/matrix-perturbation.md (Davis--Kahan subspace perturbation bound)

## Required Mathematical Background
- **Stability Theorem of Persistent Homology**: $d_B(D(X), D(Y)) \leq d_{GH}(X, Y)$; the Hausdorff distance bounds the change in persistence diagrams
- **Euler Characteristic Curve**: $\chi(\epsilon) = \sum_k (-1)^k \beta_k(\epsilon)$, richer in information than a single $\chi$, computable in $O(N^2)$
- **Mapping Cylinder Isomorphism**: if $f: X \to Y$ is an $\epsilon$-isometry, then $f_*$ induces an isomorphism on features with persistence intervals $> 2\epsilon$
- **Landmark Approximation**: build a witness complex on $m$ landmarks, $O(m^3)$ replacing $O(N^3)$

## AI Module Specification
```
Module: TopologyPreservingCompressor
Input: X ∈ R^{N×d}    Parameters: topological weight λ_topo, target dimension r < d

Method 1 - Euler curve matching (most practical, differentiable):
  Z = encoder(X)                              // R^{N×r}
  D_orig = cdist(X, X); D_comp = cdist(Z, Z)  // N×N distance matrices
  chi_orig = euler_curve(D_orig, eps_grid)      // |eps_grid|-dimensional vector
  chi_comp = euler_curve(D_comp, eps_grid)
  L_topo = ‖chi_orig - chi_comp‖_2²            // topological matching loss (differentiable)
  L_total = L_recon + λ_topo · L_topo

Method 2 - Persistent homology regularization (exact but expensive):
  D_orig = persistent_homology(X, max_dim=1)    // H_0 + H_1 barcode
  D_comp = persistent_homology(Z, max_dim=1)
  // differentiable surrogate: persistence landscape/image
  L_topo = ‖landscape(D_orig) - landscape(D_comp)‖_2²

Method 3 - Topology monitoring + adaptive compression ratio (at inference time):
  Z = compress(X, ratio=ρ)
  if count_components(Z, τ) < 0.8 * count_components(X, τ):
    ρ *= 1.2; Z = compress(X, ratio=ρ)          // topological collapse → reduce compression ratio
```

## Implementable Architectures
- **Euler curve matching layer**: $\chi(\epsilon)$ requires only a distance matrix + threshold counting; the $\epsilon$ sweep is parallelizable
- **Landmark sampler**: FPS (Farthest Point Sampling) in $O(Nm)$, guaranteeing coverage
- **Topology-aware distillation**: the persistence image discrepancy between teacher and student representations serves as an auxiliary distillation objective
- **Topological diagnostics dashboard**: real-time plotting of $\beta_0(\epsilon), \beta_1(\epsilon)$ curves during training

## GPU Feasibility
- Tensorization / GEMM: the distance matrix `cdist` is GEMM-dominated; $\chi(\epsilon)$ involves threshold counting + cumulative sum
- Complexity: full persistent homology $O(N^3)$ is infeasible; Euler curve $O(N^2 |\epsilon|)$ is feasible; Landmark $O(m^3)$
- Memory: the $N \times N$ distance matrix requires chunking or landmark reduction for $N > 8K$
- Low precision: distance computation is stable in bf16 (positive-number addition); $\chi$ involves integer arithmetic with no precision concerns
- Parallelism: each threshold in the $\epsilon$ sweep is independently parallel; landmark selection can be batch-parallelized
- Operator fusion: cdist + threshold + count can be fused to avoid materializing the large distance matrix

## Paper-Worthy Formulation
"Grounded in the Bottleneck stability theorem of persistent homology, we achieve $O(N^2)$-complexity topology-preserving regularization via Euler characteristic curve matching, ensuring that post-compression deviations in Betti numbers over persistence intervals are controlled by the Hausdorff distance."

## Risks
- **Persistent homology computational bottleneck**: exact boundary matrix reduction is highly serial ($O(N^3)$), necessitating reliance on Euler curve or landmark approximations
- **Information loss in the Euler curve**: $\chi = \sum(-1)^k \beta_k$ collapses multi-order Betti numbers into a single scalar; distinct topologies may share the same $\chi$
- **Topology $\neq$ semantics**: topological preservation does not imply semantic preservation -- two semantically distinct spaces may be topologically isomorphic
- **Scale parameter sensitivity**: the $\epsilon$ range for the filtration must be set manually and varies significantly across datasets
- **Landmark sampling bias**: FPS may produce non-uniform coverage in high-dimensional spaces, leading to biased topological estimates
