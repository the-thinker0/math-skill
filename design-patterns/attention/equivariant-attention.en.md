# Equivariant Attention
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
When the input possesses an **explicit symmetry group $G$ action** (rotation, translation, permutation, reflection, etc.), and the desired model output should be **equivariant** (covariant) rather than invariant under the same transformations, equivariant constraints must be directly encoded into the attention mechanism. Typical scenarios include: 3D point clouds / molecules ($E(3)$ rigid-body group), image classification ($D_n$ rotation/reflection group), set data ($S_n$ permutation group), and multi-view / multi-sensor fusion.

## Mathematical Inspiration

- Lenses: `../../lenses/symmetry.en.md`, `../../lenses/categorical.en.md`.
- Knowledge: `../../knowledge-base/lie-theory/equivariance.en.md`, `../../knowledge-base/lie-theory/representation.en.md`.

## Required Mathematical Knowledge

- Specify input/output representations: $f(\rho_{in}(g)x)=\rho_{out}(g)f(x)$.
- For token permutation $P$, scores transform as $S'=PSP^T$, attention weights as $A'=PAP^T$, and outputs as $O'=PO$. Weights are not an unchanged matrix; their indices are relabeled.
- Schur's lemma: between inequivalent irreducible representations an intertwiner is zero; between copies of the same finite-dimensional complex irrep it is scalar on the irrep factor, with arbitrary mixing between multiplicity channels. Real irreps need not have a scalar commutant.
- A single $SO(3)$ degree-$\ell$ irrep has $2\ell+1$ components; one copy of every degree through $L$ has $(L+1)^2$. Reflection equivariance additionally requires parity types.

## AI Module Form

**Permutation equivariance** (row-wise shared maps; masks and positions must transform consistently):
```python
Q, K, V = W_q(X), W_k(X), W_v(X)
A = softmax(Q @ K.T / sqrt(d), dim=-1)
output = A @ V
# For X' = P @ X: A' = P @ A @ P.T and output' = P @ output
```
A fixed causal mask or absolute positions generally break arbitrary token-permutation symmetry.

**Rotation/translation equivariance**: Build scalar scores from invariant features such as relative distances and invariant tensor contractions; aggregate typed equivariant values with those scalar weights. Translation-invariant scalar inputs alone do not make absolute vector coordinates translation-equivariant. Audit positional inputs, value projections, nonlinearities, residuals, and output type.

**Finite-group symmetrization** (generic, expensive reference construction):
$$F(x)=\frac1{|G|}\sum_{g\in G}\rho_{out}(g)^{-1} f(\rho_{in}(g)x).$$
For equivariant outputs, inverse output transforms are essential. Averaging $f(\rho_{in}(g)x)$ without undoing the output action instead builds an invariant map. A 24-element rotation subgroup is finite-group equivariance, not exact $SO(3)$ or $E(3)$ equivariance.

## Implementable Architectures
- **SE(3)-Transformer / Equiformer**: Spherical harmonic features + equivariant attention for molecular property prediction and protein structure
- **Set Transformer**: $S_n$ permutation-equivariant attention + Induced Set Attention (low-rank inducing points for complexity reduction)
- **G-CNN Attention**: $D_n$ rotation/reflection equivariance for remote sensing imagery and medical imaging

## GPU Feasibility

- **D1/D2[~]**: Shared pointwise maps and attention use GEMM; tensor products and irrep mixing require type-aware kernels. Permutation equivariance requires no enumeration of $n!$ elements.
- **D3/D4[~]**: Generic finite-group symmetrization costs roughly $|G|$ base evaluations; peak activation memory depends on batching/chunking. Exact continuous-group constructions use representation constraints rather than enumerating an infinite group.
- **D5[~]**: Test the relative equivariance residual $\|F(gx)-\rho_{out}(g)F(x)\|/(\|F(x)\|+\epsilon)$ in fp32 and target precision, including reflections and rotations near numerical singularities.
- **D6/D8[~]**: Independent group evaluations can batch, but batching does not imply a $|G|$ wall-clock speedup. Measure launch, bandwidth, and tensor-product overhead.
- **D7[N/A]**: Representation sparsity does not by itself create useful sparse attention kernels.

## Paper Phrasing

“Invariant scalar scores and type-preserving value maps enforce the specified equivariance. We report equivariance residuals and measured parameter, memory, latency, and task-quality changes; orbit size alone does not determine parameter savings.”

## Risks

- Validate the symmetry against the prediction target: energy may be rotation-invariant while force is rotation-equivariant; chirality may make reflections inappropriate.
- High-degree tensor products and channel multiplicities increase cost; choose truncation by task ablations.
- Shared unconstrained linear maps, normalization, biases, or nonlinearities can break nontrivial group equivariance. Test the entire module, not only its attention weights.
