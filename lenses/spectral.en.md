# Spectral Decomposition Lens

> Identify the operator class first: normal matrices admit unitary diagonalization; general finite matrices admit SVD/Schur decompositions.

## What Perspective It Offers

This is a "decomposer's" perspective — breaking complex linear operators (matrices, kernel functions, graph Laplacians) into spectra of eigenvalues and singular values, using dominant eigencomponents to capture global behavior and tail eigenvalues to quantify noise and redundancy. Eigenvalues, singular values, and eigenspaces answer different questions. Non-normal matrices can have arbitrarily large norms, condition numbers, and transient amplification at fixed eigenvalues. Spectral tails are not automatically noise.

## What Problems It Is Suited to Diagnose

- What is the dominant structure of a matrix or operator? What is its effective rank?
- Optimizer convergence is slow — is the condition number too large? How should a preconditioner be designed?
- Where are the critical bottlenecks in a graph or network? Is the spectral gap too small?
- Need to reduce dimensions while preserving maximum variance — are the first k principal components sufficient?
- How large is the spectral drift after quantization or pruning? Has stability been compromised?

## What Problems It Is Not Suited For

- Problems dominated by nonlinear effects — spectral decomposition is a linear tool
- Operators that are non-diagonalizable or non-normal — Jordan form is mainly theoretical; for numerical / engineering use prefer Schur decomposition, SVD, or pseudospectral stability analysis
- Problems that require preserving global topological structure — spectral methods may destroy topology

## Which Knowledge Domains It Routes To

- **matrix-analysis/spectral-decomposition**: EVD, Schur decomposition, normal matrices
- **matrix-analysis/low-rank-approximation**: Eckart-Young theorem, randomized SVD
- **matrix-analysis/matrix-perturbation**: Weyl's inequality, Davis-Kahan theorem
- **matrix-analysis/random-matrix**: spectral statistics of high-dimensional random matrices (MP law, BBP transition, Tracy–Widom)
- **matrix-analysis/positive-semidefinite**: Spectral properties of PSD matrices, Cholesky factorization

## What AI Designs It May Inspire

- **Spectral Normalization**: Constrain the largest singular value of weight matrices to stabilize training
- **Low-Rank Adaptation (LoRA)**: Learn a low-rank update BA; standard LoRA requires neither truncated SVD nor fixed singular subspaces
- **Spectral Graph Attention**: Use graph Laplacian eigenvectors for positional encoding
- **Spectral Clustering Routing**: Use the smallest-eigenvalue Laplacian subspace for candidate grouping; hard routing still needs capacity constraints
- **Effective Rank Monitoring**: Track stable rank as a structural diagnostic; overfitting needs independent validation evidence

## Reasoning Protocol

1. **Identify the operator**: Which matrix, kernel, or graph requires spectral analysis? What are its dimensions?
2. **Compute or estimate the spectrum**: Full EVD (small matrices) / power iteration for dominant eigenvalues / randomized SVD
3. **Analyze the spectral distribution**: Condition number, spectral gap, effective rank, decay rate
4. **Identify dominant components**: How much covariance variance do the leading eigenvalues explain? For a general matrix, what fraction of squared Frobenius norm do the leading squared singular values retain?
5. **Assess truncation impact**: Eckart–Young characterizes truncated-SVD error in spectral/Frobenius norm; eigenspace bounds additionally need gaps, and task-output error requires a separate derivation

## Acceptance Criteria

- The target operator is clearly defined
- The spectrum (or dominant eigenvalues/singular values) has been computed or estimated
- Spectral distribution metrics are reported (condition number, spectral gap, effective rank)
- Truncation and approximation decisions are backed by quantitative error bounds (Weyl / Davis-Kahan / Eckart-Young)
- The output includes actionable conclusions (preconditioner design, dimensionality selection, stability guarantees)
