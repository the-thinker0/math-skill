# Matrix Perturbation Theory

## Minimal Definition

Studies how the eigenvalues, singular values, and eigenspaces of a matrix $A$ change under a small perturbation $E$. Core results: eigenvalues of Hermitian matrices are Lipschitz continuous with respect to perturbation (Weyl bound), while the stability of eigenvectors/eigenspaces is governed by the eigengap.

## Core Formulas

- **Weyl eigenvalue perturbation bound** (Hermitian): $|\lambda_i(A+E) - \lambda_i(A)| \leq \|E\|_2$
- **Bauer-Fike theorem** (diagonalizable matrices): $\min_j |\lambda_i(A+E) - \lambda_j(A)| \leq \kappa(V) \|E\|_2$, where $V$ is the eigenvector matrix
- **Davis–Kahan (safe top-$k$ form)**: For Hermitian $A,\hat A=A+E$, descending eigenvalues and $\gamma=\lambda_k(A)-\lambda_{k+1}(A)>0$, if $\|E\|_2<\gamma/2$, their top-$k$ spaces satisfy $\|\sin\Theta(\hat U,U)\|_2\le2\|E\|_2/\gamma$. A constant-one form needs precisely defined cross-spectrum separation, not an unspecified gap.
- **Singular value perturbation (Mirsky)**: $|\sigma_i(A+E) - \sigma_i(A)| \leq \|E\|_2$
- **Geršgorin discs**: $\lambda_i(A) \in \bigcup_j \{z : |z - a_{jj}| \leq \sum_{k \neq j} |a_{jk}|\}$
- **Linear-system perturbation**: If $Ax=b$, $(A+E)\hat x=b$, $A$ is invertible and $\kappa(A)\|E\|/\|A\|<1$, then $\|\hat x-x\|/\|x\|\le\kappa(A)(\|E\|/\|A\|)/(1-\kappa(A)\|E\|/\|A\|)$. The product without the denominator is only a first-order approximation.

## Applicable Problems

- Spectral drift analysis under quantization/low-precision training: how much do singular values of weight matrices shift under bf16/fp8?
- Error bounds for model pruning/distillation: how large is the spectral change after removing $k$ parameters?
- LoRA approximation error: how does the perturbation $\|W - W_0 - BA\|_2$ affect downstream outputs?
- Training stability certificates: when gradient noise $\|E\|_2 \leq \epsilon$, eigenvalue drift is bounded by $\epsilon$
- Numerical diagnostics: cheaply estimating spectral location via Geršgorin discs without running full EVD

## AI Design Translation

- **Geršgorin cheap spectral radius monitoring**: Every $N$ steps in the training loop, compute $\rho_{\text{est}} = \max_j (|a_{jj}| + \sum_{k\neq j}|a_{jk}|)$ as an upper bound on the spectral radius, requiring only $O(n^2)$ row-wise absolute-value summation. Implemented as `torch.sum(torch.abs(A), dim=1)`, an elementwise + reduce operation, extremely cheap, and embeddable in the training loop as a stability gate.
- **Quantization perturbation**: Singular-value drift is at most $\|E\|_2$. For a bias-free composition of linear layers and 1-Lipschitz activations satisfying $\phi(0)=0$, one conservative output bound is $\|x\|[\prod_i(\|W_i\|_2+\|E_i\|_2)-\prod_i\|W_i\|_2]$. Biases, normalization, attention and residual branches need separate propagation terms.
- **Davis-Kahan subspace stability**: The reliability of subspaces in PCA/LoRA is determined by the eigengap $\delta = \lambda_k - \lambda_{k+1}$. Larger $\delta$ yields a more stable truncated subspace; as $\delta \to 0$, the subspace becomes extremely sensitive to noise. This serves as a diagnostic tool for selecting the LoRA rank $r$: choose $r$ that maximizes $\delta_r$.
- **Perturbation modeling for pruning**: Unstructured pruning = sparse perturbation $E$, $\|E\|_2 \leq \|E\|_F = \sqrt{\sum e_{ij}^2}$. The Weyl bound provides an upper bound on spectral drift, guiding the pruning ratio: maintain $\|E\|_2 / \sigma_1(W) < \tau$ (e.g., $\tau = 0.05$).
- **Spectral robustness proxy**: Penalizing $\max(0,\|E\|_2-\epsilon)^2$ discourages a chosen perturbation. It does not certify the worst case over an adversarial set. Finite power iteration generally gives a lower estimate of the spectral norm; a certificate needs a valid upper bound and optimization/rounding error accounting.

## Engineering Feasibility

- **Primary operations**: Geršgorin = elementwise abs + row-sum ($O(n^2)$); Weyl bound only requires $\|E\|_2$ (power iteration $O(n^2)$/step); Davis-Kahan requires eigengap (partial EVD, $O(n^2 k)$).
- **GPU friendliness**: High. Geršgorin is pure elementwise + reduce; $\|E\|_2$ estimation is a matvec chain; eigengap uses the Lanczos algorithm (matmul + tridiagonal EVD). All operations support batching.
- **Complexity**: Geršgorin $O(n^2)$; single power iteration $O(n^2)$; Lanczos $k$ steps $O(kn^2)$; full EVD $O(n^3)$ (should be avoided).
- **Low precision**: Perturbation theorems concern exact matrices and norms; computed residuals/norm estimates have scale- and algorithm-dependent error. Use conservative upper bounds or fp32/fp64 checks when interpreting a stability certificate.

## Risks and Failure Conditions

- **Bauer-Fike amplification for non-normal matrices**: $\kappa(V)$ can be extremely large (high condition number of the eigenvector matrix for non-normal matrices), the Weyl bound no longer applies, and perturbations are amplified by a factor of $\kappa(V)$. Solution: use SVD singular values instead (the Mirsky bound does not depend on normality), or employ pseudospectral analysis.
- **Overly loose Geršgorin bounds**: The union of discs may be much larger than the actual spectral range (especially for sparse matrices), yielding overly conservative bounds. Solution: apply a diagonal similarity transformation $D^{-1}AD$ to shrink the discs (Osborne balancing), or incorporate sparse structure corrections.
- **Davis-Kahan gap assumption**: As $\delta \to 0$, the bound degenerates to $\infty$ (subspace becomes unidentifiable), and the low-rank approximation itself is no longer unique. The eigengap must be checked first to confirm that the subspace is well-defined.
- **Weyl bound not directly applicable to non-Hermitian components**: The perturbation bound for $A + A^H$ does not directly yield eigenvalue perturbation bounds for $A$ itself. For non-symmetric matrices, one must revert to Bauer-Fike or pseudospectral analysis.

## Further References

- Distilled notes: ../../references/books/matrix-analysis.en.md (Section 4.3 Eigenvalue Inequalities Weyl/Interlacing, Section 6.1-6.3 Geršgorin Discs and Perturbation Theorems, Section 5.8 Condition Numbers)
- Original text: Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 4 Section 4.3 (Eigenvalue Inequalities) + Chapter 6 (Location and Perturbation of Eigenvalues Section 6.1-6.3)


## Routing Extensions
- If focusing on eigenvalue sensitivity -> `spectral-decomposition.en.md` (perturbation analysis of spectral decomposition)
- If random perturbation bounds are involved -> `../probability/concentration-inequality.en.md` (random matrix concentration inequalities)

## Extensible Directions
- Pseudospectra: spectral sensitivity analysis for non-normal matrices
- Structured perturbation: perturbation analysis preserving matrix structure
- Davis-Kahan theorem variants: multiple bounds for subspace perturbation
- Eigenvalue interlacing: relationship between submatrix and eigenvalues
- Wilkinson polynomial: condition numbers and sensitivity of polynomial roots
