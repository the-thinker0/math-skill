# Equivariant Split
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
Use when the input possesses symmetries (e.g., permutations, rotations, translations) and the representation should preserve or reflect those symmetries.
Typical scenarios: (1) Token permutation equivariance -- representation should change accordingly when token order in a sentence changes (positional encoding);
(2) Symmetry-based grouping of feature dimensions -- certain feature dimensions are invariant under specific transformations, while others are equivariant;
(3) Multi-expert symmetry specialization -- different experts process different symmetry subspaces;
(4) Geometric deep learning -- SE(3) equivariance in 3D molecular/protein structures.
Core requirement: **encode symmetry priors into network architecture to reduce learning burden and improve generalization**.

## Mathematical Inspiration
- Lenses: ../../lenses/geometric.en.md (group actions, invariant/equivariant maps), ../../lenses/probabilistic.en.md (symmetry and information redundancy)
- Knowledge: ../../knowledge-base/matrix-analysis/projection.en.md (group representation theory, irreducible representations),
  ../../knowledge-base/differential-geometry/manifold.en.md (Lie groups, homogeneous spaces)

## Required Mathematical Background
- **Group Action and Equivariance**: A map f is equivariant with respect to group G if and only if f(g * x) = g * f(x) for all g in G
  Invariance is a special case of equivariance (g * f(x) = f(x), i.e., the trivial representation)
- **Schur's Lemma and Irreducible Representation Decomposition**:
  Any finite group representation decomposes as a direct sum of irreducible representations: V = direct_sum_i m_i * V_i
  Equivariant linear maps are diagonal/block-diagonal between irreducible components
- **Peter-Weyl Theorem**: Functions on a compact group decompose as a series of irreducible representation matrix elements
  f(x) = sum_rho sum_{ij} c_{rho,ij} * rho_{ij}(g) (generalized Fourier expansion)
- **Steerable Feature Spaces**: Features are organized according to irreducible representations of the group;
  under the action of duality g, each component transforms via the corresponding representation matrix: f_i -> sum_j rho_{ij}(g) f_j

## AI Module Form
```
Module: EquivariantSplit
Input: X in R^{N x d}, symmetry group G (e.g., S_n permutation group, Z_n cyclic group, SO(3) rotation group)

Method 1 - Split feature dimensions by irreducible representations:
  // Decompose d-dimensional features by irreducible representations of the group
  irreps = decompose(G, d)  // [(d_1, rho_1), (d_2, rho_2), ...] where sum d_i = d
  X_split = split(X, [d_1, d_2, ...], dim=-1)  // split by irreducible components
  // Process each component independently with equivariant layers:
  for (X_i, rho_i) in zip(X_split, irreps):
    Y_i = EquivariantLinear(X_i, rho_i)  // weights constrained by Schur's lemma
  Y = concat(Y_i, dim=-1)                // reassemble

Method 2 - Positional equivariant split (Token permutation group S_n):
  // Transformer self-attention is naturally permutation equivariant (without positional encoding)
  // Explicitly introduce controllable permutation equivariance:
  X_content = X[:, :d_content]            // permutation-invariant content part
  X_position = X[:, d_content:]           // position-dependent part
  // Content part uses permutation-invariant pooling:
  z_inv = mean(X_content, dim=1)          // global invariant features
  // Position part uses equivariant operations:
  z_equiv = Attention(X_position, X_position, X_position)  // permutation equivariant
  output = z_equiv + MLP(z_inv).unsqueeze(1)  // broadcast invariant signal back

Method 3 - Group convolution / group pooling:
  // Features defined on group G: f: G -> R^c
  // Group convolution: (f * psi)(g) = sum_{h in G} f(h) * psi(h^{-1} g)
  // Group pooling: pool over orbits of subgroup H < G
  // Implemented as matrix multiplication (group multiplication table -> sparse permutation matrices)
  for g in generators(G):
    X_g = permutation_matrix(g) @ X       // group generator action
    features_g = Linear(X_g)              // equivariant processing with shared weights
  output = aggregate(features_g)          // aggregate along group dimension
```

## Implementable Structures
- **e3nn / lie_learn integration**: Use existing libraries for SO(3)/SE(3) irreducible representations and spherical harmonics
- **Blocked feature storage**: Organize feature dimensions by irreducible representations; each block independently normalized and processed
- **Precomputed group operations**: Group multiplication tables, Clebsch-Gordan coefficients, etc., computed once and cached
- **Symmetry augmentation**: Apply random group elements g in G to inputs during training (data augmentation) to encourage equivariance

## GPU Feasibility
- **Tensorization**: Processing irreducible components is batched GEMM; group convolution is sparse GEMM or batched matmul
- **GEMM-mappable**: Each block of EquivariantLinear is an independent GEMM (N x d_i) @ (d_i x d_i_out), batchable
- **Complexity**: Same order as standard networks (Schur constraints actually reduce parameters); group convolution incurs an extra |G| factor
- **Memory & KV-Cache**: Group convolution requires storing |G| copies of features; significant memory pressure when |G| is large
- **Low-precision stability**: Spherical harmonics Y_l^m computations involve factorials and square roots; fp32 recommended
- **Parallelism & Communication**: Irreducible components are independent, perfectly parallel; different g in group convolution can be parallelized
- **Sparse structure**: Permutation matrices in group convolution are extremely sparse (exactly one nonzero per row/column); SpMM is efficient
- **Operator fusion**: Split -> batched matmul -> concat can be fused; group pooling scatter + reduce can be fused

## Paper-Worthy Formulation
"Leveraging Schur's lemma from group representation theory, we decompose the d-dimensional feature space into a direct sum of irreducible representations of the symmetry group G, with each component processed by equivariance-constrained linear layers. Under the assumed group action this enforces equivariance and reduces learnable degrees of freedom; the exact parameter savings depend on the representation decomposition and channel multiplicities. Generalization gains must be measured on tasks with the corresponding symmetry and should not be stated as an unconditional O(1/sqrt(|G|)) rate."

## Risks
- Improper group selection (too large constrains cause underfitting, too small fails to capture symmetries)
- Irreducible representation decomposition requires domain knowledge; implementation is complex for non-standard groups
- The |G|-fold feature storage in group convolution becomes infeasible for large groups (e.g., S_10 has 3.6M elements)
- The trade-off between approximate equivariance (soft equivariance) and strict equivariance is difficult to control
