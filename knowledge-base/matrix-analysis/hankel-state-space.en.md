# Hankel Operator & State-Space Models

## Minimal Definition

For a causal discrete LTI system with zero initial state, the impulse response determines its input–output map, including direct feedthrough $D$. With strictly proper Markov parameters $h_j=CA^jB$ ($j\ge0$), the block Hankel matrix $\mathcal H_{ij}=h_{i+j}$ maps past inputs to future outputs. Convolution itself is represented by a Toeplitz matrix. The infinite Hankel rank equals the minimal finite realization dimension; finite sections must be sufficiently large to expose that rank.

## Core Formulas

- **Index convention**: $x_{k+1}=\bar A x_k+\bar B u_k$, $y_k=Cx_k+Du_k$, $x_0=0$. Then $y_k=Du_k+\sum_{j=0}^{k-1}C\bar A^{k-1-j}\bar B u_j$. Reading the updated state instead gives kernel $(C\bar B,C\bar A\bar B,\ldots)$ at lag zero; state the shift explicitly.
- **Parameter count**: An $N$-dimensional dense SISO realization uses $O(N^2)$ parameters, while a diagonal/structured realization can use $O(N)$. Both have $O(N)$ recurrent state, independent of sequence length $L$; state memory and parameter count are different quantities.
- **Hankel rank theorem**: $\operatorname{rank} \mathcal{H}$ = state dimension of the minimal realization; low-rank Hankel ⇒ a low-dimensional state-space realization exists
- **HiPPO-LegS matrix**: $A_{nk}=-\begin{cases}\sqrt{(2n+1)(2k+1)}&n>k\\n+1&n=k\\0&n<k\end{cases}$. The original scaled-history projection uses $\dot x(t)=A x(t)/t+B u(t)/t$, with specified measure and basis normalization; a fixed-step LTI S4 parameterization derived from this matrix does not inherit every original projection identity.
- **Discretization** (bilinear/Tustin, step $\Delta$): $\bar{A} = (I - \Delta/2 \cdot A)^{-1}(I + \Delta/2 \cdot A)$, $\bar{B} = (I - \Delta/2 \cdot A)^{-1} \Delta B$
- **Convolution mode**: Given a length-$L$ scalar kernel, FFT convolution costs $O(L\log L)$; count kernel construction and channel mixing separately. **Recurrent mode** costs $O(N^2)$ per token for dense $A$ or $O(N)$ for diagonal $A$; it is constant only with respect to $L$.

## Applicable Problems

- **Long-sequence modeling**: an alternative to the $O(L^2)$ attention bottleneck; length extrapolation, streaming inference
- **System identification**: recovering $(A, B, C)$ from input-output data (Ho–Kalman / subspace identification)
- **History compression**: Polynomial-projection error depends on the history function, approximation order, measure and smoothness; a fixed-size state cannot losslessly retain every arbitrary long input history.
- **Recurrent-operator comparison**: Linear time-invariant RNNs and fixed convolutions share realization theory. Content-dependent linear attention and selective SSMs are generally time-varying/nonlinear input–output maps, so fixed LTI Hankel-rank theorems do not apply directly.

## AI Design Translation

- **S4-style layers**: Use structured state matrices and FFT convolution for training; use a suitable recurrent realization for streaming inference. State memory is independent of length, while throughput and crossover against attention require measurements. [S4 original paper](https://arxiv.org/abs/2111.00396).
- **Selective SSMs (Mamba-style)**: make $B, C, \Delta$ input-dependent (time-varying system), trading the pure convolution mode for content awareness; hardware-aware parallel scan (associative scan) preserves training parallelism
- **Hankel compression**: Use truncated SVD to estimate a dominant realization subspace, then perform a structured realization/model-reduction step. An arbitrary rank-truncated Hankel matrix need not remain Hankel; validate the reconstructed impulse response and stability.

## Engineering Feasibility

- **Main operations**: training = FFT convolution (a standard GPU primitive beyond matmul) or parallel scan; inference = per-token small state updates $O(N^2)$, or $O(N)$ after diagonalization
- **GPU friendliness**: high. FFT/scan are mature primitives; diagonal SSMs (S4D/S5) reduce everything to elementwise + cumsum-like ops
- **Complexity**: For one diagonal SISO channel, direct kernel construction costs $O(LN)$ and FFT application $O(L\log L)$; structured fast construction can differ. Recurrent inference is $O(N)$ per token with $O(N)$ state. Dense state updates cost $O(N^2)$; report channel count and mixing separately.
- **Low precision**: recurrent-mode error accumulates over time; with eigenvalue magnitudes near 1, bf16 causes visible phase drift — keep the state in fp32

## Risks and Failure Conditions

- **Stability and transients**: $\rho(\bar A)<1$ ensures asymptotic decay of a fixed LTI state, but non-normal matrices can have large transient amplification. Diagonalization does not itself ensure stability and an ill-conditioned eigenbasis can worsen numerics; inspect powers/norm growth and perturbation sensitivity.
- **Task-dependent approximation**: Compare retrieval, copying, long-range recall and throughput on the actual task. HiPPO initialization and hybrid attention do not provide universal accuracy orderings.
- **Convolution/recurrent mode mismatch**: discretization error and low precision cause output drift between the two modes — train/inference inconsistency; align discretization schemes and validate at the target precision
- **Hankel rank ≠ practical identifiability**: low rank is an existence result; recovering the low-rank realization from noisy data is ill-conditioned (sensitive to Hankel singular-value gaps)

## Further References

- Distilled book: `../../references/books/matrix-analysis.en.md` (SVD and low rank; Hankel-specific theory is beyond that book's scope)
- Gu et al. "HiPPO: Recurrent Memory with Optimal Polynomial Projections." *NeurIPS*, 2020
- Gu, Goel, Ré. "Efficiently Modeling Long Sequences with Structured State Spaces." *ICLR*, 2022 (S4)
- Ho & Kalman. "Effective construction of linear state-variable models from input/output functions." 1966

## Routing Extensions

- For spectral initialization analysis -> `spectral-decomposition.en.md` (eigenvalues of $A$ set memory timescales)
- For low-rank compression of long convolutions -> `low-rank-approximation.en.md` (Hankel truncated SVD)
- For frequency-domain convolution -> `spectral-decomposition.en.md` (FFT is the spectral decomposition of circulant matrices)

## Extensible Directions

- Subspace system identification (N4SID): direct state-space estimation from data
- Balanced truncation: controllability/observability Gramian-guided model reduction
- Time-varying and input-dependent SSMs (selective SSM): Mamba-style hardware-aware scans
- Orthogonal polynomial families (HiPPO-LegS/LagT): optimal memory projection under different measures
- Nonlinear extensions (Hammerstein/Wiener systems): system theory of SSM + pointwise nonlinearity
