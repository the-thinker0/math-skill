# Group Action

## Minimal Definition

A group $G$ acting on a set $X$ is a homomorphism $\rho: G \to \text{Bij}(X)$ satisfying $\rho(e) = \text{id}$ and $\rho(g_1 g_2) = \rho(g_1) \circ \rho(g_2)$. It converts group elements into transformations on the set, providing the mathematical realization of "symmetry": the algebraic structure of the group determines the structure of geometric transformations.

## Core Formulas

- Group action: $g \cdot x = \rho(g)(x)$, satisfying $e \cdot x = x$ and $(gh)\cdot x = g \cdot (h \cdot x)$
- Orbit: $\text{Orb}(x) = \{g \cdot x \mid g \in G\}$
- Stabilizer subgroup: $\text{Stab}(x) = \{g \in G \mid g \cdot x = x\}$
- Orbit-stabilizer theorem: $|G| = |\text{Orb}(x)| \cdot |\text{Stab}(x)|$
- Invariant function: $f(g \cdot x) = f(x), \forall g \in G$
- Equivariant map: $\phi(g \cdot x) = g \cdot \phi(x)$

## Applicable Problems

- Data possesses known symmetries: rotations, translations, permutations, scale transformations; the model must respect these symmetries
- Output should covary with input: in pose estimation, when the object rotates, the output pose should rotate accordingly
- Theoretical foundation for data augmentation: sampling along group orbits is equivalent to traversing the group action
- Quotient space construction: modding out by the stabilizer subgroup yields an invariant feature space

## AI Design Translation

- **Equivariant network layer**: $f(g \cdot x) = g \cdot f(x)$, hard-coding the group action into the network structure to obtain equivariance without data augmentation
- **Invariant pooling layer**: Average/max over orbits $\frac{1}{|G|}\sum_g f(g \cdot x)$ to extract invariants from equivariant features
- **Group convolution**: $(f * h)(g) = \sum_{g'} f(g') h(g'^{-1} g)$, performing convolution directly on the group itself, applicable when signals are defined on the group
- **Orbit-sampling data augmentation**: Use group actions to generate symmetry-equivalent training samples, effectively enlarging the training set

## Engineering Feasibility

GPU friendliness depends on the type of group:
- **Finite/discrete groups**: Group convolution can be expanded into batched GEMM or sparse matmul, $O(|G|^2)$ or $O(|G| \cdot d)$, GPU-friendly
- **Continuous compact groups SO(n)/SU(n)**: Require discrete sampling or frequency-domain expansion (Peter-Weyl theorem); fast algorithms exist for spherical harmonic transforms
- **Permutation group $S_n$**: Order $n!$, cannot be enumerated; use sort pooling, symmetric functions, and other approximate invariants
- **Fourier-accelerated group convolution**: The FFT on finite groups reduces convolution from $O(|G|^2)$ to $O(|G| \log |G|)$, but implementation is complex
- Key bottleneck: if the discretization of a continuous group is not exact, equivariance silently breaks

## Risks and Failure Conditions

- **Naive discretization of continuous groups**: Improper sampling leads to broken equivariance and irregular gather/scatter patterns, GPU-unfriendly
- **Incorrect group action definition**: Confusing left and right actions or inconsistent group multiplication order causes equivariance verification to pass but inference to fail
- **Infeasible orbit enumeration**: Orbits of large/continuous groups cannot be fully enumerated; approximate invariants introduce bias
- **Over-constraining**: Not all tasks require strict equivariance; enforcing group actions on weakly symmetric tasks may sacrifice expressiveness

## Further References

- Distillation notes: references/books/micro-lie-theory.md (Section II-B Group Actions)
- Distillation notes: references/books/smooth-manifolds.md (Ch 7 Lie Groups)
- Original text: Joan Sola et al., *A micro Lie theory*, Section II-B (group action definition and applications in robotics)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 7 (Lie groups and group actions)
