# Equivariant Split
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use when the input possesses symmetries (e.g., permutations, rotations, translations) and the representation should preserve or reflect those symmetries.
Typical scenarios: (1) Token permutation equivariance -- representation should change accordingly when token order in a sentence changes (positional encoding);
(2) Symmetry-based grouping of feature dimensions -- certain feature dimensions are invariant under specific transformations, while others are equivariant;
(3) Multi-expert symmetry specialization -- different experts process different symmetry subspaces;
(4) Geometric deep learning -- SE(3) equivariance in 3D molecular/protein structures.
Core requirement: **encode symmetry priors into network architecture to reduce learning burden and improve generalization**.

## Mathematical Inspiration

- Lenses: `../../lenses/symmetry.en.md`, `../../lenses/categorical.en.md`.
- Knowledge: `../../knowledge-base/lie-theory/representation.en.md`, `../../knowledge-base/lie-theory/equivariance.en.md`.

## Required Mathematical Background

- Start from a specified representation $\rho:G\to GL(V)$, not just a group name and feature dimension. For finite groups over characteristic zero and continuous finite-dimensional representations of compact groups, complete reducibility supplies an irrep basis.
- In that basis, $V=\bigoplus_\lambda \mathbb C^{m_\lambda}\otimes V_\lambda$, with complex-linear equivariant maps $\bigoplus_\lambda W_\lambda\otimes I_{\dim V_\lambda}$. Channel multiplicities can mix; inequivalent irreps cannot mix through a linear intertwiner. Real representations need the appropriate real commutant.
- Arbitrarily slicing learned features is not an irrep decomposition. Obtain/change to the basis from the known action or design features with declared types from the start.
- Every nonlinearity, normalization, bias and residual must respect types. Elementwise ReLU on a rotating vector is generally not rotation-equivariant.

## AI Module Form

```python
# Known representation rho, and basis_change diagonalizes its isotypic blocks
X_typed = X @ basis_change
Y_blocks = []
for block, multiplicity_map in typed_blocks(X_typed):
    # block shape N x multiplicity x irrep_dimension
    Y_blocks.append(mix_multiplicity_only(block, multiplicity_map))
Y = concatenate_typed_blocks(Y_blocks) @ inverse_output_basis
```
For token sets $X\in\mathbb R^{N\times d}$, `X.mean(dim=0, keepdim=True)` is permutation-invariant and may be broadcast back to an equivariant token output. Raw per-token “content” remains permutation-equivariant, not invariant. A fixed absolute positional assignment or causal mask changes the allowed symmetry.

Finite-group convolution uses all required group-indexed features and the group multiplication rule. Applying shared linear maps only to generator-transformed inputs and averaging is **not** a generic exact group convolution/equivariance construction. Use the full finite-group symmetrization in `../attention/equivariant-attention.en.md` as a reference, or a proven generator-constrained parameterization.

## Implementable Structures
- **e3nn / lie_learn integration**: Use existing libraries for SO(3)/SE(3) irreducible representations and spherical harmonics
- **Blocked feature storage**: Organize feature dimensions by irreducible representations; each block independently normalized and processed
- **Precomputed group operations**: Group multiplication tables, Clebsch-Gordan coefficients, etc., computed once and cached
- **Symmetry augmentation**: Apply random group elements g in G to inputs during training (data augmentation) to encourage equivariance

## GPU Feasibility

- **D1/D2[~]**: Typed linear maps are batched channel GEMMs; general tensor products and CG coefficients add non-GEMM work.
- **D3/D4[~]**: Costs depend on irrep dimensions, multiplicities and product paths. Explicit group-indexed features can add a $|G|$ factor; parameter sharing alone does not determine runtime.
- **D5[~]**: Compute sensitive harmonics/normalizations in fp32 and test whole-module equivariance at the target precision.
- **D6/D8[~]**: Independent blocks can batch; small blocks may underutilize the GPU, and typed nonlinear interactions couple blocks.
- **D7[~]**: Permutations are usually gathers, not a reason to materialize sparse permutation matrices; representation sparsity does not imply fast sparse attention.

## Paper-Worthy Formulation
"Leveraging Schur's lemma from group representation theory, we decompose the d-dimensional feature space into a direct sum of irreducible representations of the symmetry group G, with each component processed by equivariance-constrained linear layers. Under the assumed group action this enforces equivariance and reduces learnable degrees of freedom; the exact parameter savings depend on the representation decomposition and channel multiplicities. Generalization gains must be measured on tasks with the corresponding symmetry and should not be stated as an unconditional O(1/sqrt(|G|)) rate."

## Risks
- Improper group selection (too large constrains cause underfitting, too small fails to capture symmetries)
- Irreducible representation decomposition requires domain knowledge; implementation is complex for non-standard groups
- The |G|-fold feature storage in group convolution becomes infeasible for large groups (e.g., S_10 has 3.6M elements)
- The trade-off between approximate equivariance (soft equivariance) and strict equivariance is difficult to control
