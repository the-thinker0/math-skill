# Representation

## Minimal Definition

A representation of a group $G$ on a vector space $V$ is a group homomorphism $\rho: G \to GL(V)$, realizing abstract group elements as computable linear transformations (matrices). The core problem of representation theory is decomposing a complex group action into a direct sum of irreducible representations (irreps), analogous to factoring integers into primes.

## Core Formulas

- Representation: $\rho(g_1 g_2) = \rho(g_1)\rho(g_2)$, $\rho(e) = I$
- Character: $\chi_\rho(g) = \text{tr}(\rho(g))$, a class function encoding the essential information of the representation
- Peter-Weyl theorem (compact groups): $L^2(G) \cong \bigoplus_{\pi \in \hat{G}} \dim(\pi) \cdot \pi$
- Schur's lemma: $\rho_1, \rho_2$ irreducible and inequivalent $\Rightarrow$ $\text{Hom}_G(\rho_1, \rho_2) = 0$
- Irreducible representations of SO(3): dimension $2l+1$, $l = 0,1,2,\ldots$, with spherical harmonics $Y_l^m$ as basis functions
- Clebsch-Gordan decomposition: $\rho_1 \otimes \rho_2 \cong \bigoplus_k m_k \rho_k$

## Applicable Problems

- Signals defined on groups/spheres: require spherical harmonic expansion for frequency-domain analysis
- Constructing equivariant feature spaces: each feature channel corresponds to an irreducible representation
- Accelerating group convolutions: using the Fourier transform (irreducible representations) to convert convolution into pointwise multiplication in the frequency domain
- Molecular/crystal symmetries: representations of point groups/space groups determine orbital symmetries and selection rules

## AI Design Translation

- **Spherical harmonic feature layer**: Expand 3D point cloud/molecular features into a spherical harmonic basis $Y_l^m$; each $(l,m)$ channel transforms according to an SO(3) irreducible representation, achieving strict rotational equivariance
- **Group Fourier transform layer**: Transform a finite group signal $f: G \to \mathbb{R}$ to the frequency domain via $\hat{f}(\pi) = \sum_g f(g)\pi(g)$, converting convolution into per-irrep matrix multiplication
- **Schur-constrained weight matrices**: Equivariant inter-layer maps $W: V_1 \to V_2$ must commute with the group action $W\rho_1(g) = \rho_2(g)W$; Schur's lemma forces $W$ to be block-diagonal/scalar, drastically reducing parameters
- **Character pooling**: Extract invariants using $\chi_\rho(g) = \text{tr}(\rho(g))$ as input features for classification/regression

## Engineering Feasibility

GPU friendliness depends on the group size and representation dimension:
- **Finite group representations**: Each irrep is a small matrix ($d \times d$); the group Fourier transform equals a batch of small GEMMs, $O(|G| \cdot d^2)$, batchable
- **SO(3) spherical harmonic transform**: Fast algorithms exist ($O(L^2 \log L)$), but implementation is complex; the real-space to frequency-domain transform can be expressed as sparse matmul
- **Clebsch-Gordan coefficients**: Once precomputed, they are fixed sparse tensors; contraction with features can be expressed as GEMM
- **Sparsity from Schur constraints**: Weight matrices of equivariant layers are constrained to be block-diagonal/scalar, greatly reducing parameters but requiring sparse/block GEMM
- Key bottleneck: the Clebsch-Gordan tensor size grows rapidly for high-dimensional irreps (large $l$ spherical harmonics)

## Risks and Failure Conditions

- **High-frequency spherical harmonic numerical instability**: $Y_l^m$ for large $l$ oscillates violently near the poles, causing severe precision loss under fp16
- **Irrep completeness truncation**: Keeping only up to $l_{\max}$ spherical harmonics loses high-frequency information; truncation error must be determined experimentally
- **Infinite-dimensional representations of non-compact groups**: Irreducible representations of groups such as the Lorentz group are infinite-dimensional and must be truncated in practice
- **Freedom in representation selection**: Which irreps participate and to what order are hyperparameters with no automatic selection method
- **Clebsch-Gordan tensor storage**: The number of CG coefficients grows as $O(l^3)$ with increasing $l$, increasing precomputation and storage costs

## Further References

- Distillation notes: references/books/micro-lie-theory.md (Section II-F Adjoint $\text{Ad}_X$ and Adjoint Matrix)
- Distillation notes: references/books/differential-geometry.md (Ch 5 Lie Groups, adjoint representation section)
- Original text: Joan Sola et al., *A micro Lie theory*, Section II-F (adjoint representation, equations 30--35)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 5 (representations of Lie groups)


## Routing Extensions
- If equivariant network design is needed -> `equivariance.md` (representation theory drives equivariant network construction)
- If the specific form of group action is needed -> `group-action.md` (representations are linear group actions)
- If irreducible decomposition is needed -> `spectral-decomposition.md` (analogous to spectral decomposition of matrices)

## Extensible Directions
- Irreducible representation: basic building blocks of representations
- Character: trace function and classification of representations
- Schur's lemma: morphisms between irreducible representations
- Peter-Weyl theorem: decomposition of regular representation for compact groups
- Induced representation: constructing representations of large groups from subgroups
- Tensor product of representations: combining multi-particle systems
- Clebsch-Gordan coefficients: transformation coefficients for tensor product decomposition into irreducibles
