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

- Hessian spectral analysis: determining loss surface curvature (positive definite = local minimum, negative eigenvalues present = saddle point)
- Gradient covariance spectrum: diagnosing training dynamics; the spectral radius determines stability
- Spectral normalization: constraining $\sigma_{\max}(W) \leq 1$ to stabilize GAN/diffusion model training
- State space model (SSM) stability: spectral radius of the discretization matrix $< 1$ guarantees non-divergence
- Graph neural networks: Laplacian spectral decomposition = Fourier basis on graphs

## AI Design Translation

- **Power iteration for spectral radius / largest singular value estimation**: $u_{k+1} = Au_k / \|Au_k\|$, each step requiring only one matvec + norm, $O(n^2)$. Standard approach in spectral normalization (SN-GAN); built into PyTorch as `torch.nn.utils.spectral_norm`. Note: single-vector iteration has low parallelism; block iteration is needed for parallelization.
- **Hessian-free optimization (HVP + CG)**: Without materializing the Hessian, computes $Hv$ via autodiff (one forward + one backward pass), then feeds it to CG to solve $Hd = -g$. The core operations are two backward passes (matvec), fully GPU-friendly.
- **Kronecker-factored approximate curvature (K-FAC)**: Approximates the Hessian as $H \approx A \otimes B$ (Kronecker product), where each factor is a small matrix (on the order of the layer dimension), reducing inversion to small GEMM operations. Each layer is independent, naturally parallelizable.
- **Spectral regularization loss**: $\mathcal{L}_{\text{spec}} = \max(0, \rho(A) - 1)^2$ or $\mathcal{L}_{\text{spec}} = \|\sigma_{\max}(W) - 1\|^2$, estimated via power iteration and added to the total loss. Implemented as an additional scalar loss term without affecting the main computational graph structure.
- **Graph Fourier transform**: The eigendecomposition of the graph Laplacian $L = D - A$, $L = U\Lambda U^H$, provides the graph frequency domain basis. Spectral convolution in GCN = $U g(\Lambda) U^H x$, three matmul operations. For large-scale graphs, Chebyshev polynomial approximation avoids explicit decomposition.

## Engineering Feasibility

- **Primary operations**: Full EVD is $O(n^3)$, but full decomposition is rarely needed in AI. Power iteration is $O(n^2)$/step matvec; K-FAC factors are $O(d^2)$ small-matrix inversions.
- **GPU friendliness**: Medium to high (method-dependent). Power iteration / HVP = matvec = friendly; full EVD is infeasible for $n > 1000$. cuSOLVER provides `syevd` (symmetric EVD) and `gesvd` (SVD), but the $O(n^3)$ cost limits scalability.
- **Low precision**: Hermitian matrix EVD is relatively stable under bf16 (eigenvalues are Lipschitz continuous, Weyl bound). Eigenvalues of non-normal matrices may be severely distorted under low precision; SVD should be used instead.

## Risks and Failure Conditions

- **Non-normal matrix trap**: When $A^HA \neq AA^H$, eigenvalues do not predict transient behavior (pseudospectra may be much larger than the spectral radius), and using eigenvalues to assess stability can be seriously misleading. Solution: use SVD to examine singular values instead.
- **Numerical sensitivity of repeated eigenvalues**: When algebraic multiplicity > geometric multiplicity (defective matrices), eigenvectors are extremely sensitive to perturbation, and Jordan blocks are uncomputable in floating point. Solution: use the Schur decomposition instead.
- **Slow power iteration convergence**: When $\lambda_1 / \lambda_2 \approx 1$, convergence is extremely slow (requiring $O(1/(1-\lambda_2/\lambda_1))$ steps). Solution: block iteration or Lanczos acceleration.
- **Numerical precision of HVP**: Floating-point errors in $Hv$ accumulate during CG iteration, potentially preventing CG convergence. Periodic re-orthogonalization or restart is needed.

## Further References

- Distilled notes: references/books/matrix-analysis.md (Ch 1 Eigenvalues and Similarity, Section 2.4-2.5 Schur Triangularization and Normal Matrices, Section 4.2 Courant-Fischer)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 1 (Eigenvalues, Eigenvectors, Similarity) + Chapter 2 (Unitary Similarity Section 2.4-2.5)
