# Positive Semidefinite Matrices

## Minimal Definition

A Hermitian matrix $A$ is positive semidefinite (PSD) if $x^HAx \geq 0$ for all nonzero vectors $x$, denoted $A \succeq 0$. Equivalent conditions: all eigenvalues $\geq 0$; there exists $B$ such that $A = B^HB$ (Gram representation); **all principal minors** $\geq 0$ (note: ALL principal minors, not just the leading ones). Positive definite (PD) requires strict $> 0$, denoted $A \succ 0$.

## Core Formulas

- PSD equivalence: $A \succeq 0 \iff \lambda_i(A) \geq 0 \ \forall i \iff A = B^HB \iff$ all principal minors $\geq 0$ (note: **all** principal minors, not just the leading ones)
- PD equivalence (Sylvester's criterion): $A \succ 0 \iff \lambda_i(A) > 0 \ \forall i \iff$ all leading principal minors $> 0$ (checking only leading principal minors suffices; this is necessary and sufficient for PD)
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
- Attention matrix analysis: a row-stochastic softmax attention matrix is generally not a Gram/PSD matrix; PSD tools apply only after explicitly constructing a symmetric PSD kernel (e.g. $K_{ij}=k(x_i,x_j)$) or symmetrizing and projecting to the PSD cone.

## AI Design Translation

- **PSD kernel engineering (learnable kernels)**: Use the Schur product theorem to combine multiple PSD kernels: $K = K_1 \circ K_2 \circ \cdots$ (Hadamard product), guaranteeing the result remains PSD. Implemented as elementwise tensor multiplication `K = K1 * K2`, $O(n^2)$ elementwise, extremely GPU-friendly. Can parameterize $K_\theta(x,y) = \exp(-\|f_\theta(x)-f_\theta(y)\|^2)$ to guarantee PSD.
- **Covariance whitening**: $\hat{x} = \Sigma^{-1/2}x$, where $\Sigma^{-1/2}$ can be approximated via scaled Newton-Schulz iteration (pure matmul). A common coupled form uses $Y_0=A/\alpha, Z_0=I$, $T_k=\frac{1}{2}(3I-Z_kY_k)$, $Y_{k+1}=Y_kT_k, Z_{k+1}=T_kZ_k$, with $A^{-1/2}\approx Z_k/\sqrt{\alpha}$; an equivalent single-variable form is $X_{k+1}=\frac{1}{2}X_k(3I-AX_k^2)$. Convergence requires spectral scaling and positive definiteness; in low precision, residual checks are needed. 5-6 steps is an engineering budget, not a universal guarantee. BatchNorm can be viewed as an approximation to diagonal whitening.
- **Cholesky solve**: For **positive-definite** $H=LL^H$, solve $Lz=g$ then $L^Hx=z$, giving $H^{-1}g=L^{-H}L^{-1}g$. The inverse factor order matters; a merely PSD singular Hessian needs damping or a pseudoinverse.
- **Nearest PSD approximation (Higham)**: Given a symmetric matrix $A$, find the nearest PSD matrix $A_+ = \arg\min_{X \succeq 0} \|A - X\|_F$. Solution: EVD $A = U\Lambda U^H$, clamp negative values in $\Lambda$ to zero, $A_+ = U\Lambda_+ U^H$. Used to correct loss of positive definiteness in covariance matrices due to floating-point errors.
- **Diagonal loading**: $A+\epsilon I$ is PD iff $\epsilon> -\lambda_{\min}(A)$ for Hermitian $A$. Choose margin relative to scale and precision; a fixed $10^{-6}$ need not suffice. In-place diagonal updates cost $O(n)$; constructing a full identity allocates $O(n^2)$.

## Engineering Feasibility

- **Primary operations**: Cholesky decomposition $O(n^3/3)$ (cuSOLVER batched available); Gram matrix construction $O(n^2d)$ (matmul); Newton-Schulz iteration $O(n^3)$/step (pure matmul); Hadamard product $O(n^2)$ (elementwise).
- **GPU friendliness**: High. Gram matrix = matmul; Hadamard product = elementwise; Newton-Schulz = pure matmul chain; Cholesky has cuSOLVER batched versions for parallel execution across multiple groups.
- **Complexity**: Gram construction $O(n^2d)$; Cholesky $O(n^3/3)$; Newton-Schulz 5 steps $O(5n^3)$; jitter $O(n)$.
- **Low precision**: Cholesky and Newton–Schulz require well-scaled inputs, sufficient precision and residual checks. Pure matmul does not ensure bf16 convergence; near-singular inputs may need fp32/fp64 and regularization.

## Risks and Failure Conditions

- **Loss of PSD in floating point**: Symmetrize and inspect the smallest eigenvalue before Cholesky; use scale-aware jitter and fp32/fp64. Newton–Schulz also needs a suitably scaled positive-definite input and convergence checks, and does not repair an arbitrary indefinite matrix.
- **Near-singularity**: As $\lambda_{\min} \to 0$, the condition number $\kappa \to \infty$, and the entries of $A^{-1}$ blow up in magnitude. Solution: truncate small eigenvalues (spectral cutoff) or apply ridge regularization $A + \lambda I$.
- **Misuse of the Schur product theorem**: $A \circ B \succeq 0$ requires **both** $A$ and $B$ to be PSD; if either is not PSD, the result is not guaranteed. Each factor must be verified for PSD property in learnable kernel design.
- **Differentiating an SDP solution**: Implicit differentiation through cone-program layers is possible under regularity and a well-defined local solution map. Degeneracy, active-set changes and inaccurate solves can invalidate or destabilize gradients; PSD projection solves a different problem and is not a general replacement for an SDP. [Differentiable convex optimization layers](https://papers.neurips.cc/paper/9152-differentiable-convex-optimization-layers.pdf).

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Ch 7 Positive Definite and Semidefinite Matrices, Section 7.5 Schur Product Theorem, Section 7.7 Loewner Partial Order)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 7 (Positive Definite and Semidefinite Matrices Section 7.1-7.8)


## Routing Extensions
- If solving SDP problems -> `../optimization/convex-optimization.en.md` (semidefinite programming as convex optimization)
- If PSD matrix conditioning and perturbation are involved -> `matrix-perturbation.en.md` (eigenvalue perturbation bounds)
- If used for Fisher information matrix -> `../probability/fisher-information.en.md` (PSD property of Fisher information)

## Extensible Directions
- Semidefinite programming (SDP): solution methods and applications
- PSD completion: completing partially known PSD matrices
- Matrix square root: unique square root of PSD matrices
- Lowner order: partial order on the PSD cone
- Operator monotone functions: Loewner-Heinz theorem
- Completely positive matrices: CP decomposition and cone structure
