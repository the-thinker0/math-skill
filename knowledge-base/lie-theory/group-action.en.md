# Group Action

## Minimal Definition

A group $G$ acting on a set $X$ is a homomorphism $\rho: G \to \text{Bij}(X)$ satisfying $\rho(e) = \text{id}$ and $\rho(g_1 g_2) = \rho(g_1) \circ \rho(g_2)$. It converts group elements into transformations on the set, providing the mathematical realization of "symmetry": the algebraic structure of the group determines the structure of geometric transformations.

## Core Formulas

- Group action: $g \cdot x = \rho(g)(x)$, satisfying $e \cdot x = x$ and $(gh)\cdot x = g \cdot (h \cdot x)$
- Orbit: $\text{Orb}(x) = \{g \cdot x \mid g \in G\}$
- Stabilizer subgroup: $\text{Stab}(x) = \{g \in G \mid g \cdot x = x\}$
- Orbit-stabilizer for a finite group: $|G|=|\mathrm{Orb}(x)|\,|G_x|$; for general groups the orbit is in bijection with the coset space $G/G_x$.
- Invariant function: $f(g \cdot x) = f(x), \forall g \in G$
- Equivariant map: $\phi(g \cdot x) = g \cdot \phi(x)$

## Applicable Problems

- Data possesses known symmetries: rotations, translations, permutations, scale transformations; the model must respect these symmetries
- Output should covary with input: in pose estimation, when the object rotates, the output pose should rotate accordingly
- Data augmentation samples group orbits; a finite training sample does not by itself guarantee invariance/equivariance over the entire group.
- Quotients: $X/G$ is the set of orbits; $G/G_x$ parameterizes one orbit, not the orbit space $X/G$.

## AI Design Translation

- **Equivariant network layer**: $f(g \cdot x) = g \cdot f(x)$, hard-coding the group action into the network structure to obtain equivariance without data augmentation
- **Invariant pooling layer**: Average/max over orbits $\frac{1}{|G|}\sum_g f(g \cdot x)$ to extract invariants from equivariant features
- **Group convolution**: $(f * h)(g) = \sum_{g'} f(g') h(g'^{-1} g)$, performing convolution directly on the group itself, applicable when signals are defined on the group
- **Orbit-sampling data augmentation**: Use group actions to generate symmetry-equivalent training samples, effectively enlarging the training set

## Engineering Feasibility

GPU friendliness depends on the type of group:
- **Convolution on a finite group**: naive scalar convolution costs $O(|G|^2)$; a kernel supported on s elements can reduce this to $O(|G|s)$, before channel and implementation costs.
- **Continuous compact groups SO(n)/SU(n)**: use sampling/frequency expansions (Peter-Weyl) or direct representation constraints; sampling is not required for every equivariant layer.
- **Permutation group $S_n$**: avoid enumerating $n!$ elements; sum/mean/max aggregation is exactly invariant, while sorting needs tie and differentiability handling.
- **Group FFTs**: cyclic/finite abelian groups admit efficient FFTs; arbitrary finite groups do not inherit a universal $O(|G|\log|G|)$ convolution bound. Count representation transforms and block matrix products.
- Key bottleneck: if the discretization of a continuous group is not exact, equivariance silently breaks

## Risks and Failure Conditions

- **Naive discretization of continuous groups**: Improper sampling leads to broken equivariance and irregular gather/scatter patterns, GPU-unfriendly
- **Incorrect group action definition**: Confusing left and right actions or inconsistent group multiplication order causes equivariance verification to pass but inference to fail
- **Infeasible orbit enumeration**: Orbits of large/continuous groups cannot be fully enumerated; approximate invariants introduce bias
- **Over-constraining**: Not all tasks require strict equivariance; enforcing group actions on weakly symmetric tasks may sacrifice expressiveness

## Further References

- Distillation notes: ../../references/books/micro-lie-theory.en.md (Section II-B Group Actions)
- Distillation notes: ../../references/books/smooth-manifolds.en.md (Ch 7 Lie Groups)
- Original text: Joan Sola et al., *A micro Lie theory*, Section II-B (group action definition and applications in robotics)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 7 (Lie groups and group actions)


## Routing Extensions
- If equivariant map design is needed -> `equivariance.en.md` (equivariance under group actions)
- If linearization of group action is needed -> `representation.en.md` (representations are linear group actions)
- If invariant analysis is needed -> `symmetry` (design pattern layer for symmetry analysis)

## Extensible Directions
- Orbit-stabilizer for a finite group: $|G|=|\mathrm{Orb}(x)|\,|G_x|$; for general groups the orbit is in bijection with the coset space $G/G_x$.
- Transitive / free actions: special types of group actions
- Homogeneous space G/H: a single orbit under a transitive action (with suitable conditions for a smooth structure), distinct from the general orbit set X/G.
- Quotient manifold: quotient structure under smooth group actions
- Slice theorem: local structure of compact group actions
- Momentum map: conserved quantities of Hamiltonian group actions
