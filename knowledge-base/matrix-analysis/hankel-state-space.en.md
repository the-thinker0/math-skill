# Hankel Operator & State-Space Models

## Minimal Definition

The behavior of a linear time-invariant (LTI) system is fully determined by its **impulse response** (Markov parameters) $h = (CB, CAB, CA^2B, \ldots)$. The Hankel matrix $\mathcal{H}_{ij} = h_{i+j}$ turns convolution into a matrix: the Hankel rank equals the minimal state dimension (Ho–Kalman realization theorem). State-space models (SSMs) $x' = Ax + Bu,\ y = Cx + Du$ are finite parametrizations of "infinite convolution kernels" for long-sequence modeling.

## Core Formulas

- **Continuous/discrete SSM**: $\dot{x} = Ax + Bu,\ y = Cx$ (continuous); $x_{k+1} = Ax_k + Bu_k,\ y_k = Cx_k$ (discrete)
- **Convolution equivalence**: the discrete SSM output is the convolution $y = \bar{K} * u$ with kernel $\bar{K} = (C\bar{B}, C\bar{A}\bar{B}, \ldots, C\bar{A}^{L-1}\bar{B})$; a length-$L$ kernel needs only $O(N)$ state parameters
- **Hankel rank theorem**: $\operatorname{rank} \mathcal{H}$ = state dimension of the minimal realization; low-rank Hankel ⇒ a low-dimensional state-space realization exists
- **HiPPO matrix** (optimal recurrence for Legendre projection): $A_{nk} = -\begin{cases} \sqrt{(2n+1)(2k+1)} & n > k \\ n+1 & n = k \\ 0 & n < k \end{cases}$, making $x(t)$ an online compression of history into Legendre coefficients
- **Discretization** (bilinear/Tustin, step $\Delta$): $\bar{A} = (I - \Delta/2 \cdot A)^{-1}(I + \Delta/2 \cdot A)$, $\bar{B} = (I - \Delta/2 \cdot A)^{-1} \Delta B$
- **Convolution mode**: $y = \bar{K} * u$ via FFT in $O(L \log L)$; **recurrent mode**: stepwise $O(1)$ state updates, suited for autoregressive inference

## Applicable Problems

- **Long-sequence modeling**: an alternative to the $O(L^2)$ attention bottleneck; length extrapolation, streaming inference
- **System identification**: recovering $(A, B, C)$ from input-output data (Ho–Kalman / subspace identification)
- **Theoretical explanation of sequence compression**: why an $O(N)$ SSM state can approximate arbitrarily long history — approximation-theoretic guarantees of Legendre projection
- **Unified view of linear attention/RNNs**: linear RNNs, linear attention, and convolutions are different parametrizations of low-rank Hankel structure

## AI Design Translation

- **S4-style layers**: initialize $A$ as HiPPO (or its normal part); train in convolution mode (FFT, parallel over the full sequence), infer in recurrent mode ($O(N)$ state update per token). Training throughput is Transformer-comparable; inference memory does not grow with length
- **Selective SSMs (Mamba-style)**: make $B, C, \Delta$ input-dependent (time-varying system), trading the pure convolution mode for content awareness; hardware-aware parallel scan (associative scan) preserves training parallelism
- **Hankel low-rank compression**: arrange a learned long convolution kernel $\bar{K}$ into a Hankel matrix and truncate its SVD to obtain a low-dimensional state-space compression; useful for distilling long-conv layers into small RNNs

## Engineering Feasibility

- **Main operations**: training = FFT convolution (a standard GPU primitive beyond matmul) or parallel scan; inference = per-token small state updates $O(N^2)$, or $O(N)$ after diagonalization
- **GPU friendliness**: high. FFT/scan are mature primitives; diagonal SSMs (S4D/S5) reduce everything to elementwise + cumsum-like ops
- **Complexity**: training $O(L \log L \cdot N)$ (FFT convolution) vs attention $O(L^2 d)$; inference $O(N^2)$ (dense) or $O(N)$ (diagonal) per token, memory $O(N)$ independent of $L$
- **Low precision**: recurrent-mode error accumulates over time; with eigenvalue magnitudes near 1, bf16 causes visible phase drift — keep the state in fp32

## Risks and Failure Conditions

- **Numerical instability without diagonalization**: powers $\bar{A}^k$ of a dense $A$ explode when eigenvalue magnitudes exceed 1 and forget when below 1; parametrize for stability (negative real parts + exponential parametrization)
- **HiPPO initialization is not universal**: on strongly local-pattern tasks (copying, induction heads), pure SSMs underperform attention; hybrid architectures (SSM + a few attention layers) are usually the safer choice
- **Convolution/recurrent mode mismatch**: discretization error and low precision cause output drift between the two modes — train/inference inconsistency; align discretization schemes and validate at the target precision
- **Hankel rank ≠ practical identifiability**: low rank is an existence result; recovering the low-rank realization from noisy data is ill-conditioned (sensitive to Hankel singular-value gaps)

## Further References

- Distilled book: `../../references/books/matrix-analysis.md` (SVD and low rank; Hankel-specific theory is beyond that book's scope)
- Gu et al. "HiPPO: Recurrent Memory with Optimal Polynomial Projections." *NeurIPS*, 2020
- Gu, Goel, Ré. "Efficiently Modeling Long Sequences with Structured State Spaces." *ICLR*, 2022 (S4)
- Ho & Kalman. "Effective construction of linear state-variable models from input/output functions." 1966

## Routing Extensions

- For spectral initialization analysis -> `spectral-decomposition.md` (eigenvalues of $A$ set memory timescales)
- For low-rank compression of long convolutions -> `low-rank-approximation.md` (Hankel truncated SVD)
- For frequency-domain convolution -> `spectral-decomposition.md` (FFT is the spectral decomposition of circulant matrices)

## Extensible Directions

- Subspace system identification (N4SID): direct state-space estimation from data
- Balanced truncation: controllability/observability Gramian-guided model reduction
- Time-varying and input-dependent SSMs (selective SSM): Mamba-style hardware-aware scans
- Orthogonal polynomial families (HiPPO-LegS/LagT): optimal memory projection under different measures
- Nonlinear extensions (Hammerstein/Wiener systems): system theory of SSM + pointwise nonlinearity
