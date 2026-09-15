# Grassmannian and Plücker Embedding

## Minimal Definition
The Grassmannian $\mathsf{Gr}(k,n)$ is the parameter space of all $k$-dimensional linear subspaces of an $n$-dimensional vector space, a smooth projective variety of dimension $k(n-k)$ over its base field (complex dimension here; real dimension $2k(n-k)$ for the complex Grassmannian). It parameterizes "subspaces" as geometric points, making subspace operations (projection, intersection, distance) representable as geometric operations.

The Plücker embedding $\mathsf{Gr}(k,n)\hookrightarrow\mathbb{P}(\Lambda^k\mathbb{C}^n)$ maps each subspace $V=\mathsf{span}(v_1,\ldots,v_k)$ to the exterior product of its basis $[v_1\wedge\cdots\wedge v_k]$ , representing subspaces as projective homogeneous coordinates. This is the standard way to turn geometric objects (subspaces) into algebraic objects (exterior algebra elements).

## Core Formulas
- **Grassmannian definition**: $\mathsf{Gr}(k,n)=\{k\text{-dim subspaces of }\mathbb{C}^n\}$
- **Dimension**: $\dim_{\mathbb C}\mathsf{Gr}_{\mathbb C}(k,n)=k(n-k)$; its real dimension is $2k(n-k)$.
- **Plücker embedding**: $V=\mathsf{span}(v_1,\ldots,v_k)\mapsto[v_1\wedge\cdots\wedge v_k]\in\mathbb{P}(\Lambda^k\mathbb{C}^n)$
- **Plücker coordinates**: $p_{i_1\cdots i_k}=\det(v_{i_j}^{(i)})$ (the minor of basis vectors at rows $i_1,\ldots,i_k$), totaling $\binom{n}{k}$
- **Plücker relations** (quadratic relations satisfied by Plücker coordinates): $\sum_{j=1}^{k+1}(-1)^j p_{i_1\cdots\hat{i_j}\cdots i_{k+1}}\cdot p_{j_1\cdots j_{k-1}i_j}=0$
- **Schubert cell decomposition**: $\mathsf{Gr}(k,n)=\bigsqcup_\lambda\Omega_\lambda$ (stratified by the subspace's relative position to a fixed flag)
- **Storage comparison**: Plücker uses $\binom nk$ homogeneous coordinates versus $nk$ basis entries. The former can be large at intermediate k, but expansion is not universal at k=1 or near n.
- **Chordal distance (not geodesic distance)**: for principal angles $\Theta$ of orthonormal/unitary bases, $d_{chord}(V,W)=\|\sin\Theta\|_F$; canonical Grassmann geodesic distance is $\|\Theta\|_F$.

## Applicable Problems
- **Subspace representation compression**: distinguish tasks depending only on a subspace from matrix reconstruction. Reconstruction also needs coefficients; a Grassmann point cannot replace a complete KV cache.
- **Subspace clustering**: union of multiple low-rank subspaces
- **Geometric structure analysis of representation learning**: feature spaces as subspace families, measuring inter-subspace distances
- **Distance/metric definitions in feature spaces**: use projection metrics instead of Euclidean distance
- **Multi-modal alignment**: alignment of per-modality representation subspaces
- **Principal angles and vectors**: "angles" between subspaces as similarity measures

## AI Design Translation
- **Grassmann parameterization**: a KV-cache/LoRA subspace basis must be accompanied by token/matrix coefficients for reconstruction; the subspace alone loses amplitudes and row identity.
- **Choose by actual size**: compare $dk$ with $\binom dk$ before claiming a basis is cheaper. Factors of an exterior product do not preserve the original matrix coefficients.
- **Principal angles as subspace similarity**: $d(V,W)=\|\sin\Theta\|_F$ as subspace distance for multi-view alignment
- See `../../design-patterns/compression/low-rank-kv-cache.en.md`, `../../design-patterns/representation/shared-private-decomposition.en.md`, `../../design-patterns/representation/subspace-alignment.en.md` for corresponding patterns; if no match, label as "temporary design translation."

## Engineering Feasibility

Use a real orthonormal basis $U\in\mathbb R^{n\times k}$ (or a complex unitary basis with conjugate transpose). QR costs $O(nk^2)$, and principal-angle computation involves $U^TV$ plus a $k\times k$ SVD. Precision, conditioning, and kernel fusion need measurement; bf16 QR is not automatically accurate.

For $A\in\mathbb R^{L\times d}$, rank-$k$ reconstruction needs coefficients and basis, $O(Lk+dk)$ storage. A Grassmann point alone is insufficient. Plücker coordinates number $\binom dk$; compare actual dimensions rather than asserting expansion at every low rank ($k=1$ is an exception). Prefer basis-invariant distances; $\|\sin\Theta\|_F=\|UU^T-VV^T\|_F/\sqrt2$ is chordal, while the canonical geodesic distance is $\|\Theta\|_F$.

## Risks and Failure Conditions

- Distinguish real and complex Grassmannians and their dimensions.
- Replacing a matrix by its subspace discards coefficients; prove that the task depends only on that subspace before doing so.
- QR does not produce a unique basis for a subspace; use basis-invariant comparisons.
- Plücker coordinate counts peak near $k=d/2$, but actual expansion depends on $d,k$.
- Recovering tiny angles with acos near 1 can lose accuracy; use stable SVD/CS or residual formulations.
- Truncated subspace energy is not automatically attention/task fidelity.

## Further References
- Distilled notes: `../../references/books/algebraic-geometry-rising-sea.en.md`
- Distilled notes: `../../references/books/matrix-analysis.en.md` (§2.6 SVD, principal angles)
- Original book: Ravi Vakil, *The Rising Sea*, chapters on Grassmannians
- Original book: Horn & Johnson, *Matrix Analysis* 2nd Ed., §2.5 (angles between subspaces)

## Routing Extensions
- If low-rank approximation is needed → `../matrix-analysis/low-rank-approximation.en.md` (Eckart-Young, randomized SVD)
- If subspace projection is needed → `../matrix-analysis/projection.en.md` (orthogonal projection)
- If matrix perturbation is needed → `../matrix-analysis/matrix-perturbation.en.md` (Davis-Kahan principal angle perturbation bounds)
- If a geometric view is needed → `../../lenses/geometric.en.md` (metric/curvature)
- If a symmetry view is needed → `../../lenses/symmetry.en.md` (GL(n) action)

## Extensible Directions

Riemannian optimization, subspace tracking, perturbation bounds under spectral gaps, and basis-invariant alignment.
