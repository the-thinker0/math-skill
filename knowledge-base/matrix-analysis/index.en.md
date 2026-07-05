# Matrix Analysis Activation Index

## Domain Signals
Activate this domain direction when the problem involves:
- Dimensionality reduction / compression: need to compress high-dimensional data or parameters into a low-dimensional subspace
- Low-rank approximation: need to approximate large matrices with low-rank ones
- Condition number / ill-conditioning: numerical stability issues in matrix computations
- Orthogonal decomposition: need to decompose space into orthogonal subspaces
- Spectral structure: need to analyze eigenvalue / singular value distributions
- Subspace separation: need to measure or control relationships between subspaces

## Core Anchors
- `projection.en.md` — Projection operators and subspace projection
- `spectral-decomposition.en.md` — Spectral decomposition and eigendecomposition
- `low-rank-approximation.en.md` — Low-rank approximation and truncated SVD
- `positive-semidefinite.en.md` — Positive semidefinite matrices and PSD cone
- `matrix-perturbation.en.md` — Matrix perturbation theory and error bounds

## Extended Concepts
When core anchors are insufficient, the following concepts may need temporary activation:
- SVD variants (truncated SVD, randomized SVD): fast decomposition methods for large-scale matrices
- PCA / kernel PCA: principal component analysis and its kernelized version
- condition number: computation and control of condition numbers
- pseudoinverse: Moore-Penrose generalized inverse and its applications
- matrix equation (Sylvester / Lyapunov): solution methods and stability for matrix equations
- Schur decomposition: Schur decomposition and invariant subspaces
- Jordan form: Jordan canonical form and generalized eigenspaces
- matrix function: definition and computation of matrix functions
- Kronecker product / vectorization: tensor product and vectorization operations
- randomized linear algebra: randomized linear algebra methods
- CUR decomposition: column/row sampling-based matrix approximation
- Nystrom approximation: low-rank approximation of kernel matrices
- matrix concentration inequalities: concentration inequalities for random matrices

## Reference Book Directions
- `../../references/books/matrix-analysis.en.md`: comprehensive coverage of matrix analysis, especially spectral decomposition, perturbation theory, and matrix function chapters

## AI Translation Directions
- projection → subspace attention / conflict removal / shared-private split
- spectral decomposition → low-rank KV cache / token pruning / stability monitor
- low-rank approximation → LoRA / adapter modules / memory-efficient attention
- positive-semidefinite → covariance-aware regularization / PSD-constrained loss
- matrix perturbation → condition number monitoring / robustness-aware training

## Temporary Activation Rules
When the problem requires mathematics not in the core anchors:
1. First check whether extended concepts contain a match
2. If yes, generate a temporary knowledge card based on the lens
3. If no, enter the Knowledge Gap Protocol
