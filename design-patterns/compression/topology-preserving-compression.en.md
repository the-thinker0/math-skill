# Topology-Preserving Compression
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Target Problem
Use when compressing representations while homologically preserving the intrinsic topological structure of the data (connected components, loops, cavities): latent-space compression (a toroidal manifold must not collapse into a line segment), knowledge distillation (student--teacher homological equivalence), 3D mesh simplification (genus invariance), KV-Cache semantic preservation (cluster structure must not collapse). Core objective: **compress dimensions or counts while constraining and measuring changes in the persistence diagram of persistent homology**.

## Mathematical Foundations
- Lenses: ../../lenses/topological.en.md (topological invariants -- connected components and hole counts are invariant under continuous deformation), ../../lenses/spectral.en.md (Gauss--Bonnet linking curvature and Euler characteristic), ../../lenses/variational.en.md (constrained variational of compression ratio vs. topological fidelity)
- Knowledge: ../../knowledge-base/topology/persistent-homology.en.md (persistent homology, Vietoris--Rips filtration, bottleneck distance), ../../knowledge-base/topology/euler-characteristic.en.md (Euler characteristic for rapid topological diagnostics), ../../knowledge-base/matrix-analysis/matrix-perturbation.en.md (Davis--Kahan subspace perturbation bound)

## Required Mathematical Background

- **State the filtration**: For finite metric spaces with Rips simplices defined by diameter $\le\epsilon$, fixed homology degree and field coefficients, $d_B(D_{VR}(X),D_{VR}(Y))\le2d_{GH}(X,Y)$. For tame sublevel functions on the same domain, $d_B(D(f),D(g))\le\|f-g\|_\infty$. Constants change with the filtration parameter convention. [Persistence stability for geometric complexes](https://arxiv.org/abs/1207.3885).
- **What stability gives**: An $\eta$ bottleneck bound matches diagram points within $\eta$; a finite interval of lifetime $>2\eta$ cannot be matched to the diagonal. This is not a generic isomorphism of all features at one scale.
- **Euler curve**: $\chi(\epsilon)=\sum_q(-1)^q c_q(\epsilon)$ must count simplices in every included dimension. Vertices minus edges gives the Euler characteristic of the graph-only complex, not of a full Rips complex with triangles and higher simplices.
- **Complexity variable**: Reduction is worst-case $O(M^3)$ for $M$ simplices, not $O(N^3)$ for $N$ points. The number of Rips simplices can be exponential in $N$ if dimension is unbounded.
- **Differentiability**: Hard thresholded Euler counts are piecewise constant with zero gradients almost everywhere. Smoothed indicators are surrogates; persistence landscapes/images still require differentiable birth/death computations and handling pairing changes.

## AI Module Specification

```python
# Option A: cheap graph-only smooth Euler surrogate; does NOT include filled triangles
D_x, D_z = cdist(X, X), cdist(encoder(X), encoder(X))
upper = strictly_upper_triangle_mask(N)
for eps in eps_grid:
    chi_x = N - sigmoid((eps - D_x) / temperature)[upper].sum()
    chi_z = N - sigmoid((eps - D_z) / temperature)[upper].sum()
    loss += (chi_x - chi_z)**2
# Validate hard Betti/persistence diagnostics separately on sampled data.
```
For a fixed sparse/cubical complex, specify its cells, filtration, and smooth surrogate explicitly. For differentiable persistent homology, cap dimension and simplex count, use a library with verified input gradients, and compare birth/death and pairing changes against finite differences away from ties.

At inference, let $\rho$ mean **retained fraction**. If diagnostics fail, set $\rho\leftarrow\min(1,1.2\rho)$ and recompress; report the monitored dimensions, scales, and tolerance. An Euler match alone is not a topology-preservation certificate.

## Implementable Architectures

- Sampled graph/cubical Euler diagnostics with a declared complex.
- Landmark Rips/witness approximations with coverage and approximation error reported.
- Teacher/student persistence losses with the same scale and metric conventions.
- Separate cheap training surrogates from held-out topology and downstream-quality evaluation.

## GPU Feasibility

- **D1/D2[~]**: Pairwise distances and smooth graph counts are tensor operations; higher-dimensional complex construction and reduction are irregular.
- **D3[~]**: Dense distances cost $O(N^2d)$; graph-only threshold sweeps cost $O(N^2|\epsilon|)$. Higher-dimensional Euler/PH requires counting the actual simplices. FPS costs $O(Nmd)$ and is sequential over $m$ landmark choices.
- **D4[~]**: A dense fp32 distance matrix uses $4N^2$ bytes (256 MiB at $N=8192$), before complexes or gradients. Cap simplex count, not only point count.
- **D5[~]**: Squared-distance GEMM formulas can suffer cancellation; use fp32, check small/negative computed distances and threshold sensitivity.
- **D6/D8[~]**: Thresholds can batch, but hard PH reduction and landmark selection have dependencies; any custom fusion needs profiling.
- **D7[~]**: Sparse complexes help only when neighborhood structure and approximation conditions are controlled.

## Paper-Worthy Formulation
"Grounded in the Bottleneck stability theorem of persistent homology, we build a computable topology-preserving regularizer via Euler-characteristic curves or landmark approximations. Bottleneck distance can bound persistence-diagram changes when the filtration-function perturbation is controlled; Euler curves are incomplete proxies and do not by themselves guarantee per-degree Betti-number deviations, so persistence / Betti-curve deviations should be measured."

## Risks

- Equal Euler characteristics or diagrams do not imply homeomorphism or semantic equivalence.
- Sampling, landmarks, scale choice and surrogate temperature can erase or create apparent features.
- Long persistence is a robustness heuristic, not proof of meaningful signal; use null controls.
- Exact PH may be dominated by complex size even when the distance matrix fits in memory.
