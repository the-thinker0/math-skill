# Equivariant Attention
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「✅ 已验证 / ⚠️ 可改造需验证 / ❌ 不可行」。未标注的视为理论可行，需工程验证。

## Applicable Problems
When the input possesses an **explicit symmetry group $G$ action** (rotation, translation, permutation, reflection, etc.), and the desired model output should be **equivariant** (covariant) rather than invariant under the same transformations, equivariant constraints must be directly encoded into the attention mechanism. Typical scenarios include: 3D point clouds / molecules ($E(3)$ rigid-body group), image classification ($D_n$ rotation/reflection group), set data ($S_n$ permutation group), and multi-view / multi-sensor fusion.

## Mathematical Inspiration
- Lenses: [symmetry, categorical (unified framework for group actions)]
- Knowledge: [`probability/concentration-inequality.md` (sample efficiency gains under equivariant constraints -- data equivalence along orbits), `probability/entropy.md` (equivariant constraints reduce output distribution entropy, yielding stronger inductive bias)]

## Required Mathematical Knowledge
- **Group Representation Theory Basics**: Linear representation of a group $G$, $\rho: G \to GL(V)$, and irreducible representation decomposition
- **Equivariant Map Definition**: $f(g \cdot x) = \rho_{\text{out}}(g) \cdot f(x)$ for all $g \in G$
- **Orbit-Stabilizer Theorem** (see `references/books/abstract-algebra.md` Ch.5): $|orbit| = |G|/|stab|$, giving the parameter sharing multiplier
- **Schur's Lemma**: An equivariant linear map between irreducible representations is either zero or a scalar multiple

## AI Module Form

**Core Idea**: Replace the standard attention $Q, K, V$ with **steerable features**, ensuring that attention weights are invariant under group actions and that outputs are equivariant under group actions.

**Scheme A: Permutation-Equivariant Attention ($S_n$ group, set data)**:
```python
# DeepSets / Set Transformer style
# Attention weights are permutation-invariant: pi(Q)pi(K)^T = QK^T (permutations cancel)
# Output is permutation-equivariant: pi(softmax(QK^T) V) = softmax(QK^T) pi(V)
Q, K, V = W_q(X), W_k(X), W_v(X)  # pointwise linear transform
scores = Q @ K.T / sqrt(d)         # permutation-invariant
attn = softmax(scores)             # permutation-invariant
output = attn @ V                  # permutation-equivariant (V is equivariant)
```

**Scheme B: $E(3)$-Equivariant Attention (3D point clouds / molecules)**:
```python
# Decompose features into scalars + vectors + higher-order tensors (spherical harmonic basis)
# Attention weights computed using only scalar features (rotation-invariant)
scalar_Q = scalar_proj(X_scalar)   # scalars only -> rotation-invariant
scalar_K = scalar_proj(X_scalar)
scores = scalar_Q @ scalar_K.T / sqrt(d_s)  # rotation-invariant attention weights

# V contains equivariant features (scalars + vectors), weighted by invariant weights
output_scalar = softmax(scores) @ V_scalar   # scalar -> invariant
output_vector = softmax(scores) @ V_vector   # vector -> equivariant (rotation-covariant)
```

**Scheme C: $D_n$-Equivariant Attention (image rotation / reflection)**:
```python
# G-CNN style: for each group element g in D_n, transform input with rho(g) then compute attention
# Weights shared along orbits (same W_q/W_k/W_v), aggregate outputs over all group elements
output = mean(softmax((rho(g)@X@W_q) @ (rho(g)@X@W_k).T/sqrt(d)) @ (rho(g)@X@W_v) for g in D_n)
```

## Implementable Architectures
- **SE(3)-Transformer / Equiformer**: Spherical harmonic features + equivariant attention for molecular property prediction and protein structure
- **Set Transformer**: $S_n$ permutation-equivariant attention + Induced Set Attention (low-rank inducing points for complexity reduction)
- **G-CNN Attention**: $D_n$ rotation/reflection equivariance for remote sensing imagery and medical imaging

## GPU Feasibility
- **Dimension 1 Tensorization**: Group actions implemented as $\rho(g)$ matrix multiplications; equivariant features stored as batched tensors
- **Dimension 2 GEMM-mappability**: $\rho(g) X$ and $Q K^T$ are both GEMM operations; $|G|$ group elements map to batched GEMM
- **Dimension 3 Complexity**: $|G|$-fold computation overhead; acceptable for small groups ($|D_4|=8$), infeasible for large groups ($|S_n|=n!$). Remedy: use generators + Cayley graph propagation instead of full group enumeration
- **Dimension 4 Memory**: Requires storing $|G|$ copies of intermediate features; mitigated by chunking + gradient checkpointing
- **Dimension 5 Low Precision**: Orthogonal representation matrices are numerically stable under bf16
- **Dimension 6 Parallelism**: $|G|$ group elements are naturally parallelizable (along the batch dimension)
- **Dimension 7 Sparsity**: Permutation $\rho(g)$ is extremely sparse and can be encoded as gather indices
- **Dimension 8 Operator Fusion**: Group action + linear duality can be fused into a single batched GEMM

## Paper Phrasing
"We propose an equivariant attention mechanism that constrains attention weights to be group invariants and attention outputs to be group equivariants, directly encoding the inductive bias of symmetry group $G$ into the model architecture without additional data augmentation, achieving a $|G|/|stab|$-fold improvement in parameter efficiency."

## Risks
- **Cost of Incorrect Group Selection**: If the data does not possess the assumed symmetry (e.g., molecules lacking full $E(3)$ symmetry), equivariant constraints will impair expressiveness. The symmetry assumption must be validated first, or "approximate equivariance" (soft equivariance) should be used.
- **Memory Explosion of High-Order Representations**: The $L$-th order spherical harmonic representation of $SO(3)$ has dimension $(2L+1)^2$, causing storage and computation to grow rapidly for high-order features ($L \geq 3$). In practice, truncation to $L \leq 2$ is standard.
