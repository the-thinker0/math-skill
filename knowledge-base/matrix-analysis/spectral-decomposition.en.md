# Spectral Decomposition

## Minimal Definition

Decomposes a matrix into a linear combination of eigenvalue-eigenvector pairs. For a Hermitian matrix $A$, there exists a unitary matrix $U$ such that $A = U \Lambda U^H$, where $\Lambda = \text{diag}(\lambda_1, \ldots, \lambda_n)$ contains real eigenvalues. For general matrices, the Schur decomposition $A = QTQ^H$ ($T$ upper triangular) serves as a numerically reliable alternative.

## Core Formulas

- Hermitian spectral decomposition: $A = \sum_{i=1}^{n} \lambda_i u_i u_i^H = U\Lambda U^H$
- Spectral mapping: $f(A) = U f(\Lambda) U^H$ (matrix exponential, logarithm, powers, etc.)
- Spectral radius: $\rho(A) = \max_i |\lambda_i|$
- Normal matrix criterion: $A^HA = AA^H \iff A$ is unitarily diagonalizable
- Schur decomposition (general matrices): $A = QTQ^H$, $T$ upper triangular, diagonal entries = eigenvalues
- Trace-eigenvalue relations: $\text{tr}(A) = \sum \lambda_i$, $\det(A) = \prod \lambda_i$

## Applicable Problems

- Hessian analysis: at a stationary point of a twice-differentiable loss, positive definiteness implies a strict local minimum; an indefinite Hessian implies a saddle. A negative eigenvalue alone may instead indicate a local maximum.
- Gradient covariance spectra diagnose anisotropy; stability must be analyzed from the actual update operator, step size, and noise model.
- Spectral normalization: constraining $\sigma_{\max}(W) \leq 1$ to stabilize GAN/diffusion model training
- State space model (SSM) stability: spectral radius of the discretization matrix $< 1$ guarantees non-divergence
- Graph neural networks: Laplacian spectral decomposition = Fourier basis on graphs

## AI Design Translation

- **Power iteration**: $u\leftarrow Au/\|Au\|$ estimates a dominant eigenvector only with a strict dominant-magnitude eigenvalue and nonzero initial overlap. To estimate $\sigma_{\max}(W)$, alternate $u\leftarrow Wv/\|Wv\|$, $v\leftarrow W^Tu/\|W^Tu\|$ and use $u^TWv$; do not confuse this with the spectral radius of a non-normal matrix.
- **Hessian-vector products**: Obtain an HVP with nested autodiff without materializing the Hessian. Standard CG requires a symmetric positive-definite operator; use damping with a suitable PSD curvature approximation, or a solver/trust-region method that explicitly handles negative curvature.
- **K-FAC**: Approximate per-layer Fisher (or an explicitly specified generalized Gauss–Newton) block by $A\otimes B$. Dense $d\times d$ factor inversion is $O(d^3)$ with $O(d^2)$ storage, often amortized across updates; it is not an arbitrary Hessian factorization. [Original K-FAC paper](https://arxiv.org/abs/1503.05671).
- **Spectral regularization loss**: $\mathcal{L}_{\text{spec}} = \max(0, \rho(A) - 1)^2$ or $\mathcal{L}_{\text{spec}} = \|\sigma_{\max}(W) - 1\|^2$, estimated via power iteration and added to the total loss. Implemented as an additional scalar loss term without affecting the main computational graph structure.
- **Graph Fourier transform**: The eigendecomposition of the graph Laplacian $L = D - A$, $L = U\Lambda U^H$, provides the graph frequency domain basis. Spectral convolution in GCN = $U g(\Lambda) U^H x$, three matmul operations. For large-scale graphs, Chebyshev polynomial approximation avoids explicit decomposition.

## Engineering Feasibility

- **Primary operations**: Full EVD costs $O(n^3)$ time and $O(n^2)$ storage; power iteration on a dense matrix costs $O(n^2)$ per step. Count K-FAC factor construction, cubic factor solves, and refresh frequency separately.
- **GPU feasibility**: Matvecs and factorizations have GPU implementations, but throughput depends on matrix size, batching, precision and device. Benchmark the required spectrum rather than declaring full EVD impossible at a universal dimension cutoff.
- **Low precision**: Weyl bounds control absolute eigenvalue error from a Hermitian input perturbation; they do not guarantee small relative error near zero, stable eigenvectors, or low-precision solver support. Accumulate Gram/Hessian quantities and run sensitive decompositions in fp32/fp64; test residuals and eigengaps.

## Risks and Failure Conditions

- **Non-normal matrix trap**: When $A^HA \neq AA^H$, eigenvalues do not predict transient behavior (pseudospectra may be much larger than the spectral radius), and using eigenvalues to assess stability can be seriously misleading. Solution: use SVD to examine singular values instead.
- **Numerical sensitivity of repeated eigenvalues**: When algebraic multiplicity > geometric multiplicity (defective matrices), eigenvectors are extremely sensitive to perturbation, and Jordan blocks are uncomputable in floating point. Solution: use the Schur decomposition instead.
- **Slow power iteration convergence**: When $\lambda_1 / \lambda_2 \approx 1$, convergence is extremely slow (requiring $O(1/(1-\lambda_2/\lambda_1))$ steps). Solution: block iteration or Lanczos acceleration.
- **Numerical precision of HVP**: Floating-point errors in $Hv$ accumulate during CG iteration, potentially preventing CG convergence. Periodic re-orthogonalization or restart is needed.

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Ch 1 Eigenvalues and Similarity, Section 2.4-2.5 Schur Triangularization and Normal Matrices, Section 4.2 Courant-Fischer)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 1 (Eigenvalues, Eigenvectors, Similarity) + Chapter 2 (Unitary Similarity Section 2.4-2.5)


## Routing Extensions
- If truncation approximation is needed -> `low-rank-approximation.en.md` (SVD-based low-rank approximation)
- If used for attention mechanism design -> `spectral-attention` (design pattern layer)
- If spectral concentration bounds are needed -> `../probability/concentration-inequality.en.md` (concentration inequalities for random matrix spectra)

## Extensible Directions
- SVD variants (truncated / randomized SVD): fast decomposition for large-scale matrices
- CUR decomposition: interpretable matrix approximation via column/row sampling
- Nystrom method: low-rank approximation of kernel matrices
- Spectral graph theory (Laplacian eigenvalues): graph Laplacian eigenvalues and graph structure analysis
- Random matrix theory: spectral distributions of large random matrices
