# Grassmannian and Plücker Embedding

## Minimal Definition
The Grassmannian $\mathsf{Gr}(k,n)$ is the parameter space of all $k$-dimensional linear subspaces of an $n$-dimensional vector space, a smooth projective variety of dimension $k(n-k)$. It parameterizes "subspaces" as geometric points, making subspace operations (projection, intersection, distance) representable as geometric operations.

The Plücker embedding $\mathsf{Gr}(k,n)\hookrightarrow\mathbb{P}(\Lambda^k\mathbb{C}^n)$ maps each subspace $V=\mathsf{span}(v_1,\ldots,v_k)$ to the exterior product of its basis $[v_1\wedge\cdots\wedge v_k]$ (a highest-weight vector), representing subspaces as projective homogeneous coordinates. This is the standard way to turn geometric objects (subspaces) into algebraic objects (exterior algebra elements).

## Core Formulas
- **Grassmannian definition**: $\mathsf{Gr}(k,n)=\{k\text{-dim subspaces of }\mathbb{C}^n\}$
- **Dimension**: $\dim\mathsf{Gr}(k,n)=k(n-k)$
- **Plücker embedding**: $V=\mathsf{span}(v_1,\ldots,v_k)\mapsto[v_1\wedge\cdots\wedge v_k]\in\mathbb{P}(\Lambda^k\mathbb{C}^n)$
- **Plücker coordinates**: $p_{i_1\cdots i_k}=\det(v_{i_j}^{(i)})$ (the minor of basis vectors at rows $i_1,\ldots,i_k$), totaling $\binom{n}{k}$
- **Plücker relations** (quadratic relations satisfied by Plücker coordinates): $\sum_{j=1}^{k+1}(-1)^j p_{i_1\cdots\hat{i_j}\cdots i_{k+1}}\cdot p_{j_1\cdots j_{k-1}i_j}=0$
- **Schubert cell decomposition**: $\mathsf{Gr}(k,n)=\bigsqcup_\lambda\Omega_\lambda$ (stratified by the subspace's relative position to a fixed flag)
- **Plücker coordinates expand at low rank**: when $k$ approaches $n/2$, $\binom{n}{k}$ explodes; storing the basis $O(nk)$ is far smaller than storing Plücker coordinates $O(\binom{n}{k})$ — the fundamental reason for "store basis, not Plücker coordinates, at low rank"
- **Metric**: $\mathsf{Gr}(k,n)$ carries a natural Riemannian metric (projection metric); subspace distance $d(V,W)=\|\sin\Theta\|_F$ ($\Theta$ is the diagonal matrix of principal angles)

## Applicable Problems
- **Subspace representation compression**: KV-Cache, LoRA, low-rank attention's subspace parameterization — turning "store an $L\times d$ matrix" into "store a $k$-dim subspace point"
- **Subspace clustering**: union of multiple low-rank subspaces
- **Geometric structure analysis of representation learning**: feature spaces as subspace families, measuring inter-subspace distances
- **Distance/metric definitions in feature spaces**: use projection metrics instead of Euclidean distance
- **Multi-modal alignment**: alignment of per-modality representation subspaces
- **Principal angles and vectors**: "angles" between subspaces as similarity measures

## AI Design Translation
- **Subspace representation parameterized by Grassmannian points**: treat KV-Cache, LoRA low-rank subspaces as points on $\mathsf{Gr}(k,d)$, storing basis vectors rather than full matrices
- **Store basis, not Plücker coordinates, to avoid low-rank expansion**: when low-rank, $\binom{d}{k}\gg dk$; storing Plücker coordinates expands, storing the basis (factors of the exterior product vector) is more economical
- **Principal angles as subspace similarity**: $d(V,W)=\|\sin\Theta\|_F$ as subspace distance for multi-view alignment
- See `../../design-patterns/compression/low-rank-kv-cache.en.md`, `../../design-patterns/representation/shared-private-decomposition.en.md`, `../../design-patterns/representation/subspace-alignment.en.md` for corresponding patterns; if no match, label as "temporary design translation."

## Engineering Feasibility
Grassmannian has moderate GPU friendliness:
- **D1[v]**: subspaces are represented by basis matrices $V\in\mathbb{R}^{n\times k}$, perfectly tensorizable
- **D2[v]**: Plücker coordinate computation is exterior products (small matrix determinants), can use batched GEMM
- **D3[~]**: Plücker coordinate count $\binom{n}{k}$ explodes at $k\approx n/2$; storing basis $O(nk)$ is far smaller than storing Plücker $O(\binom{n}{k})$
- **D4[v]**: storing basis $O(Lk+kd)$ has high compression ratio; storing Plücker coordinates expands
- **D5[v]**: orthogonal basis computation (QR) is stable under bf16; Plücker determinants should use fp32
- **D6[v]**: multiple subspace points are fully parallel
- **D7[~]**: subspace distance computation involves SVD (principal angles), can use randomized approximations
- **D8[v]**: QR + exterior products + determinants are fusable
**Key point**: store basis, not Plücker coordinates; use principal angles as similarity metric; low-rank compression ratio depends on the $k/d$ ratio

## Risks and Failure Conditions
- **Plücker coordinates explode when $k$ is large**: $\binom{n}{k}$ peaks at $k\approx n/2$ at $\sim 2^n/\sqrt{n}$, unstoreable
- **Storing Plücker instead of basis expands at low rank**: this is the anti-pattern explicitly warned in `../../design-patterns/compression/low-rank-kv-cache.en.md` — at low rank, Plücker coordinate count far exceeds the basis dimension
- **Subspace distance definition depends on metric choice**: projection metric, chordal metric, Fubini-Study metric give different results; the choice must be explicit
- **Non-unique subspace representation**: the same subspace can be represented by different bases (basis choice freedom); must use equivalence classes or canonical forms (e.g., orthonormal bases after QR)
- **Numerical instability of principal angle computation**: when subspaces nearly coincide, principal angles approach 0, and $\sin\Theta$ is numerically unstable
- **Schubert cell stratification depends on flag choice**: Schubert decomposition depends on a fixed flag; different flags give different stratifications

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
- Quantum Grassmannian: Grassmannian under quantum group action
- Non-commutative geometry: non-commutative Grassmannian
- Tannakian reconstruction: reconstructing a group from its representation category
- Moduli spaces: curve moduli, vector bundle moduli
- Hall algebra: Hall algebra structure on the Grassmannian
- Persistent Grassmannian: subspace evolution combined with persistent homology
