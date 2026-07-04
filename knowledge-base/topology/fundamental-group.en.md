# Fundamental Group

## Minimal Definition

The fundamental group $\pi_1(X, x_0)$ is the group of equivalence classes of loops in a topological space $X$ based at a point $x_0$, under homotopy equivalence. The group operation is loop concatenation (first traverse $\alpha$, then $\beta$). It is the first homotopy group, detecting "non-contractible holes" in the space -- whether loops can be continuously shrunk to a point.

## Core Formulas

- Fundamental group: $\pi_1(X, x_0) = \{[\gamma] \mid \gamma: [0,1] \to X, \gamma(0)=\gamma(1)=x_0\}$
- Group operation: $[\alpha] \cdot [\beta] = [\alpha * \beta]$, $(\alpha * \beta)(t) = \begin{cases} \alpha(2t) & t \leq 1/2 \\ \beta(2t-1) & t \geq 1/2 \end{cases}$
- Simply connected: $\pi_1(X) = \{e\}$ (all loops can be contracted to a point)
- Common fundamental groups: $\pi_1(S^1) = \mathbb{Z}$, $\pi_1(T^2) = \mathbb{Z}^2$, $\pi_1(S^n) = 0 \, (n \geq 2)$
- Covering space correspondence: subgroups of $\pi_1$ $\leftrightarrow$ covering spaces (Galois correspondence)
- Seifert-van Kampen theorem: $\pi_1(X) = \pi_1(U) *_{\pi_1(U \cap V)} \pi_1(V)$ (computation via cover decomposition)

## Applicable Problems

- Detecting "holes" in a space: $\pi_1 \neq 0$ implies the existence of non-contractible loops
- Covering spaces and multi-valued functions: subgroups of $\pi_1$ determine the Riemann surface structure of multi-valued functions
- Robotic path planning: $\pi_1$ of the configuration space determines the number of topological equivalence classes of paths
- Molecular configuration analysis: the topology of the configuration space of cyclic molecules affects conformational sampling

## AI Design Translation

- **Topological regularization (non-contractible loop penalty)**: In the latent space, if the data has a loop-like structure (e.g., periodic signals), penalize the collapse of $\pi_1$ to maintain loop connectivity in the latent space
- **Covering-space-inspired multi-hypothesis tracking**: Non-trivial subgroups of $\pi_1$ correspond to multiple "covers," which can be used for parallel multi-hypothesis tracking in multi-modal prediction
- **Path equivalence class classifier**: In robotics/motion planning, label paths of different topological classes using elements of $\pi_1$, training a classifier to distinguish path topology types
- **Simply-connected regularization**: Enforce simple connectivity of the latent space ($\pi_1 = 0$), ensuring that interpolation paths between any two points can be continuously deformed, preventing "tearing" in the latent space

## Engineering Feasibility

Low GPU friendliness. Computation of the fundamental group is inherently combinatorial/algebraic rather than numerically linear:
- **Computing the fundamental group itself**: For a simplicial complex, $\pi_1$ is isomorphic to the edge group modulo face relations (Wirtinger presentation); requires a group presentation, **not tensorizable**
- **Loop detection**: Finding non-contractible loops on a graph/mesh is equivalent to finding non-trivial cycles, solvable via BFS/DFS, $O(V+E)$, but unsuitable for GPU parallelism (data-dependent graph traversal)
- **Differentiable alternatives**: Convert "loop contractibility" into a differentiable proxy -- such as loop integrals $\oint \omega$ (de Rham cohomology); a non-zero closed-form integral implies non-contractibility, which is differentiable
- **Numerical implementation of covering spaces**: For known group structures (e.g., $\mathbb{Z}^n$), covering spaces can be explicitly parameterized as periodic identifications, which is tensorizable
- Overall assessment: exact computation of $\pi_1$ belongs to the "beautiful but incomputable" category; differentiable proxies (loop integrals/cohomology) are required

## Risks and Failure Modes

- **Not tensorizable**: The group presentation of $\pi_1$ is symbolic computation with no GEMM representation; it cannot be directly inserted into a training forward pass
- **Base-point dependence**: $\pi_1(X, x_0)$ is independent of the base point (up to isomorphism) in path-connected spaces, but different components of disconnected spaces have different $\pi_1$
- **Non-Abelianness**: $\pi_1$ is generally a non-Abelian group (e.g., free groups); the group operation is non-commutative, increasing computational and representational complexity
- **High-dimensional blind spot**: $\pi_1$ only detects 1-dimensional holes (non-contractible loops); higher-dimensional holes (e.g., "voids" in $S^2$) require higher homotopy groups $\pi_k$ ($k \geq 2$)
- **Robustness of numerical loop detection**: The definition of a "loop" in discretized/sampled point clouds is ambiguous and requires scale analysis from persistent homology

## Further References

- Distillation notes: references/books/smooth-manifolds.md (Ch 17--18 De Rham Cohomology, cohomology and topological invariants)
- Distillation notes: references/books/algebraic-geometry-rising-sea.md (Section 18 Cech Cohomology, local gluing and global obstructions)
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 17 (de Rham cohomology, the loop integral perspective)
- Extended reading: Hatcher, *Algebraic Topology*, Ch 1 (standard textbook treatment of the fundamental group, including the Seifert-van Kampen theorem)
