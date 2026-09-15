# Spectral Attention
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
When the input signal exhibits **frequency-domain/spectral structure** (periodicity, cyclic symmetry, graph structure), computing attention in the spectral domain rather than the spatial domain can dramatically reduce complexity while exploiting the signal's intrinsic structure. Typical scenarios include: time series forecasting (periodic signals), graph neural networks (graph Laplacian spectral decomposition), positional encoding (frequency-domain interpretation of RoPE/ALiBi), and $O(n \log n)$ acceleration of long-sequence **position-dependent** attention (requires circulant/Toeplitz structure assumption; does not apply to general content-dependent softmax attention).

## Mathematical Inspiration
- Lenses: [duality (frequency-domain transform), symmetry (cyclic/translation invariance)]
- Knowledge: [`../../knowledge-base/probability/entropy.en.md` (spectral entropy for measuring signal complexity), `../../knowledge-base/probability/concentration-inequality.en.md` (frequency-domain concentration inequalities)]

## Required Mathematical Knowledge

- The DFT diagonalizes circulant operators. A finite Toeplitz convolution can be applied with FFT through zero-padding/circulant embedding; the original Toeplitz matrix is not generally diagonalized by the same-size DFT.
- $\operatorname{ifft}(\operatorname{fft}(Q)\overline{\operatorname{fft}(K)})$ is circular **cross-correlation**, not ordinary convolution and not an attention output on $V$.
- Graph spectral filters $Ug(\Lambda)U^T$ are basis-independent within repeated eigenvalues when the filter acts consistently on each eigenspace. Generic nonlinear attention on arbitrary eigenvector coordinates need not have this invariance.
- RoPE is a block-diagonal rotation representation of additive positions. RoPE/ALiBi added to content attention do not make the full attention matrix Toeplitz.

## AI Module Form

**Exact circular position-only weighted aggregation**:
```python
# w[r] depends only on relative position r modulo n; w >= 0 and sum(w) = 1
w = softmax(relative_position_logits, dim=0)
output = irfft(rfft(w, n=n)[:, None] * rfft(V, n=n, dim=0), n=n, dim=0)
# output[i] = sum_j w[(i-j) % n] * V[j]
```
For a finite causal/nonperiodic position-only kernel $w$, use zero-padded linear convolution. If attention requires row normalization, compute both `conv(w, V)` and `conv(w, ones)` and divide; boundary-dependent denominators mean the normalized matrix need not remain Toeplitz. Mask patterns beyond the declared convolutional structure need separate handling.

**Content-derived correlation proposal**: FFT cross-correlation of Q/K can produce a lag score, followed by a lag-softmax and convolution of V. This is a different attention operator; compare against ordinary softmax attention, not an algebraic identity.

**Graph spectral alternative**: For a fixed symmetric graph Laplacian, retain low-frequency eigenvectors $U_k$, project features with $U_k^T$, apply a declared spectral filter or coordinate-dependent learned module, and reconstruct with $U_k$. Include projection cost and test sign/rotation changes of the basis. Truncation and nonlinear spectral attention generally change the original attention operator.

## Implementable Architectures
- **Spectral Transformer**: Replace $O(n^2)$ attention with FFT, suitable for periodic sequence data (meteorological, financial, audio)
- **Graph Spectral Attention**: Leverage the first $k$ eigenvectors of the graph Laplacian for low-dimensional attention, suitable for large-scale graphs ($n > 10^5$)
- **Frequency-Aware Positional Encoding**: The essence of RoPE is the unitary representation of the cyclic group $\mathbb{Z}$ (see Abstract Algebra Ch.4), generalizable to other groups

## GPU Feasibility

- **D1/D2[~]**: FFT is a separate primitive from GEMM; graph projection uses GEMM.
- **D3[~]**: Convolutional aggregation costs $O(nd_v\log n)$ after kernel construction. Graph projection/reconstruction costs $O(nkd)$ plus the spectral module and eigensolver; spectral-coordinate attention costs $O(k^2d)$.
- **D4[~]**: FFT avoids an $n^2$ matrix but stores complex workspaces; bytes depend on transforms, precision and padding. Graph bases store $O(nk)$.
- **D5[~]**: Verify the actual FFT dtype/shape support; compare fp32 output and relative error at target length. A real FFT is not by itself a precision fix.
- **D6/D7[~]**: Batch/head transforms parallelize; frequency truncation changes the kernel and must be evaluated for aliasing and task error.
- **D8[~]**: FFT/pointwise fusion is implementation-specific. Report measured latency and workspace, and distinguish multiply-accumulates from FLOPs.

## Paper Phrasing
"We propose a spectral-domain attention mechanism that transforms attention computation into the Fourier/Laplacian spectral domain, leveraging the cyclic convolution theorem to reduce **translation-invariant** sequence attention complexity from $O(n^2)$ to $O(n \log n)$ while preserving the ability to model dependencies at multiple scales through frequency-adaptive weights. Note: this acceleration **requires position-dependent (not content-dependent) attention structure**; for general content-dependent softmax attention, the spectral-domain equivalence does not hold."

## Applicability Conditions

- Exact FFT aggregation requires the declared circulant or embedded-convolution kernel, with boundary normalization handled explicitly.
- Arbitrary content attention, causal masking and positional embeddings do not automatically satisfy that structure.
- Correlation-based and graph-coordinate modules are separate model families, requiring operator-level and task-level comparisons.

## Risks
- **[x] Content-dependent attention incompatibility**: The core assumption of FFT spectral methods (circulant/Toeplitz structure) is **fundamentally incompatible** with the mainstream content-dependent softmax attention used in NLP. Applying FFT methods indiscriminately to general attention mechanisms constitutes a mathematical error -- they compute different quantities. Any usage must explicitly declare the position-dependence assumption being made.
- **Violation of Periodicity Assumption**: FFT implicitly assumes periodic boundary conditions, causing spectral leakage for non-periodic signals such as natural language. Windowing functions or zero-padding are needed.
- **Graph Laplacian Precomputation Cost**: Eigendecomposition $O(n^3)$ is infeasible for large-scale graphs, requiring approximations (Nystrom/Lanczos), and dynamic graphs necessitate recomputation.
