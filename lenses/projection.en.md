# Projection & Decomposition Lens

> Complex wholes can be orthogonally decomposed into independent components — conflicts are exposed in subspaces, signal and noise are separated under projection.

## What Perspective It Offers

This is a "separator's" perspective — projecting mixed wholes onto orthogonal subspaces, splitting shared information from conflicting information, signal from noise, global structure from local detail. The core conviction: any vector can be decomposed into a parallel component plus an orthogonal component, and this decomposition is the first step toward understanding conflicts, eliminating redundancy, and compressing information.

## What Problems It Is Suited to Diagnose

- Multiple information sources are mixed; need to separate shared components from specific components (multi-domain learning, multimodal fusion)
- Representations contain conflicting gradients or contradictory signals (multi-task learning, adversarial training)
- Need to reduce dimensions or compress while preserving key structure (KV-Cache compression, feature selection)
- Need to eliminate redundancy or orthogonalize multiple objectives (decorrelation, diversity constraints)

## What Problems It Is Not Suited For

- The problem itself is an indecomposable whole (strongly coupled systems, chaotic dynamics)
- The subspace assumption is too strong — data does not lie on a low-dimensional subspace
- Scenarios that require retaining all information with zero loss

## Which Knowledge Domains It Routes To

- **matrix-analysis/projection**: Orthogonal projection matrices, Courant-Fischer variational characterization
- **matrix-analysis/spectral-decomposition**: EVD/SVD, principal component analysis
- **matrix-analysis/low-rank-approximation**: Eckart-Young theorem, truncated SVD
- **optimization/constrained-optimization**: Orthogonality-constrained optimization, Stiefel manifold

## What AI Designs It May Inspire

- **Shared-Private Decomposition**: Project multi-domain representations into a shared subspace plus domain-specific orthogonal complements
- **Orthogonal Gradient Projection**: In multi-task learning, project new-task gradients onto the orthogonal complement of old-task gradients
- **Low-Rank KV-Cache Compression**: Project K/V into a low-dimensional subspace, truncating weak components
- **Head Diversity Constraint**: Force different attention heads to project onto approximately orthogonal subspaces

## Reasoning Protocol

1. **Identify mixed sources**: Which information, gradients, or representations are mixed together? Where do conflicts arise?
2. **Define subspaces**: How are the dimensions of the shared space versus the specific space determined? What is the effective rank?
3. **Construct projection operators**: $P = AA^H$ (orthonormal basis) or $P = A(A^HA)^{-1}A^H$ (general basis)
4. **Perform decomposition**: $x = Px + (I-P)x$; evaluate the contribution of each component separately
5. **Verify orthogonality**: Are $P^2 = P$ and $P = P^H$ satisfied? Is the condition number well-controlled?

## Acceptance Criteria

- The subspace decomposition is explicitly defined (dimensions, basis vectors, projection matrices)
- The contributions of both components after projection have been separately quantified
- Orthogonality conditions have been verified ($P^2 = P$, numerical condition number checked)
- Compression/discard decisions are supported by quantified information-loss evidence
- The output includes actionable conclusions, not merely the decomposition process
