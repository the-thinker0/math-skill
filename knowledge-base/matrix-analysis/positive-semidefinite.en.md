# Positive Semidefinite Matrices

## Minimal Definition

A Hermitian matrix $A$ is positive semidefinite (PSD) if $x^HAx \geq 0$ for all nonzero vectors $x$, denoted $A \succeq 0$. Equivalent conditions: all eigenvalues $\geq 0$; there exists $B$ such that $A = B^HB$ (Gram representation); all leading principal minors $\geq 0$. Positive definite (PD) requires strict $> 0$, denoted $A \succ 0$.

## Core Formulas

- PSD equivalence: $A \succeq 0 \iff \lambda_i(A) \geq 0 \ \forall i \iff A = B^HB$
- PD equivalence: $A \succ 0 \iff \lambda_i(A) > 0 \ \forall i \iff$ all leading principal minors $> 0$ (Sylvester's criterion)
- Cholesky decomposition: $A \succ 0 \implies A = LL^H$, $L$ lower triangular
- Loewner partial order: $A \succeq B \iff A - B \succeq 0$
- Schur product theorem: $A \succeq 0, B \succeq 0 \implies A \circ B \succeq 0$ (Hadamard product preserves PSD)
- Simultaneous diagonalization: $A, B \succ 0 \implies \exists C$ such that $C^HAC = I, C^HBC = \Lambda$
- Polar decomposition: $A = UP$, $P = (A^HA)^{1/2} \succeq 0$

## Applicable Problems

- Kernel methods: The Gram matrix $K_{ij} = k(x_i, x_j)$ must be PSD to guarantee the existence of an RKHS
- Covariance matrices: $\Sigma = \mathbb{E}[xx^H] \succeq 0$; PCA/whitening relies on positive definiteness
- Second-order optimization preconditioning: The PSD structure of the Hessian/Fisher information matrix guarantees descent directions
- Semidefinite programming (SDP): optimizing a linear objective subject to $X \succeq 0$ constraints
- Attention matrix analysis: Gram structure of the row-stochastic matrix output by softmax

## AI Design Translation

- **PSD kernel engineering (learnable kernels)**: Use the Schur product theorem to combine multiple PSD kernels: $K = K_1 \circ K_2 \circ \cdots$ (Hadamard product), guaranteeing the result remains PSD. Implemented as elementwise tensor multiplication `K = K1 * K2`, $O(n^2)$ elementwise, extremely GPU-friendly. Can parameterize $K_\theta(x,y) = \exp(-\|f_\theta(x)-f_\theta(y)\|^2)$ to guarantee PSD.
- **Covariance whitening**: $\hat{x} = \Sigma^{-1/2}x$, where $\Sigma^{-1/2}$ is approximated via Newton-Schulz iteration (pure matmul). Newton-Schulz: $X_{k+1} = \frac{1}{2}X_k(3I - AX_k)$, two matmul operations per step, converging in 5-6 steps. BatchNorm can be viewed as an approximation to diagonal whitening.
- **Cholesky preconditioner**: For a PSD Hessian $H$, use the $H = LL^H$ decomposition and solve $L^{-1}L^{-H}g$ instead of $H^{-1}g$. cuSOLVER provides batched Cholesky `potrf`. In K-FAC, the inversion of each Kronecker factor proceeds via Cholesky.
- **Nearest PSD approximation (Higham)**: Given a symmetric matrix $A$, find the nearest PSD matrix $A_+ = \arg\min_{X \succeq 0} \|A - X\|_F$. Solution: EVD $A = U\Lambda U^H$, clamp negative values in $\Lambda$ to zero, $A_+ = U\Lambda_+ U^H$. Used to correct loss of positive definiteness in covariance matrices due to floating-point errors.
- **Jitter / diagonal loading**: $A_{\text{stable}} = A + \epsilon I$ ($\epsilon \sim 10^{-6}$), ensuring numerical positive definiteness. Standard practice in Gaussian processes, kernel methods, and Cholesky decomposition. Implemented as `A + eps * torch.eye(n)`, a zero-cost operation.

## Engineering Feasibility

- **Primary operations**: Cholesky decomposition $O(n^3/3)$ (cuSOLVER batched available); Gram matrix construction $O(n^2d)$ (matmul); Newton-Schulz iteration $O(n^3)$/step (pure matmul); Hadamard product $O(n^2)$ (elementwise).
- **GPU friendliness**: High. Gram matrix = matmul; Hadamard product = elementwise; Newton-Schulz = pure matmul chain; Cholesky has cuSOLVER batched versions for parallel execution across multiple groups.
- **Complexity**: Gram construction $O(n^2d)$; Cholesky $O(n^3/3)$; Newton-Schulz 5 steps $O(5n^3)$; jitter $O(n)$.
- **Low precision**: Cholesky may fail under bf16 (diagonal entries becoming negative); jitter must be added or the decomposition performed in fp32. Newton-Schulz is stable under bf16 (since it involves pure matmul without division).

## Risks and Failure Conditions

- **Loss of positive definiteness in floating point**: Covariance/Gram matrices may lose PSD property under bf16 ($\lambda_{\min} < 0$), causing Cholesky to fail outright. Solution: add jitter $\epsilon I$, compute the decomposition in fp32, or use Newton-Schulz (which does not involve square roots or division).
- **Near-singularity**: As $\lambda_{\min} \to 0$, the condition number $\kappa \to \infty$, and the entries of $A^{-1}$ blow up in magnitude. Solution: truncate small eigenvalues (spectral cutoff) or apply ridge regularization $A + \lambda I$.
- **Misuse of the Schur product theorem**: $A \circ B \succeq 0$ requires **both** $A$ and $B$ to be PSD; if either is not PSD, the result is not guaranteed. Each factor must be verified for PSD property in learnable kernel design.
- **Non-differentiable SDP solvers**: Interior-point SDP solvers (e.g., SCS, MOSEK) cannot be integrated into the gradient graph and do not support end-to-end training. Solution: use a differentiable PSD projection layer (EVD + truncation + reconstruction) as a replacement.

## Further References

- Distilled notes: references/books/matrix-analysis.md (Ch 7 Positive Definite and Semidefinite Matrices, Section 7.5 Schur Product Theorem, Section 7.7 Loewner Partial Order)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 7 (Positive Definite and Semidefinite Matrices Section 7.1-7.8)
