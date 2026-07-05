# Spectral Attention
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
When the input signal exhibits **frequency-domain/spectral structure** (periodicity, cyclic symmetry, graph structure), computing attention in the spectral domain rather than the spatial domain can dramatically reduce complexity while exploiting the signal's intrinsic structure. Typical scenarios include: time series forecasting (periodic signals), graph neural networks (graph Laplacian spectral decomposition), positional encoding (frequency-domain interpretation of RoPE/ALiBi), and $O(n \log n)$ acceleration of long-sequence **position-dependent** attention (requires circulant/Toeplitz structure assumption; does not apply to general content-dependent softmax attention).

## Mathematical Inspiration
- Lenses: [duality (frequency-domain transform), symmetry (cyclic/translation invariance)]
- Knowledge: [`../../knowledge-base/probability/entropy.en.md` (spectral entropy for measuring signal complexity), `../../knowledge-base/probability/concentration-inequality.en.md` (frequency-domain concentration inequalities)]

## Required Mathematical Knowledge
- **Discrete Fourier Transform (DFT/FFT)**: $O(n \log n)$ frequency-domain transform and the cyclic convolution theorem
- **Graph Laplacian Spectral Decomposition**: $L = U \Lambda U^T$, where $U$ is the graph Fourier basis
- **Irreducible Representations of the Cyclic Group $\mathbb{Z}_n$**: The DFT matrix is precisely the representation matrix of the cyclic group (see `references/books/abstract-algebra.en.md` Ch.4, Ch.11)

## AI Module Form

**Core Idea**: Transform attention from the spatial-domain $Q K^T$ into diagonal/sparse operations in the spectral domain:

> **Critical Prerequisite**: The equivalence "spectral-domain diagonalization = attention" **holds only when the attention matrix is circulant or Toeplitz**, i.e., attention weights depend solely on relative position $a_{ij} = f(i-j)$ and are independent of token content. In this case, the cyclic convolution theorem guarantees that FFT diagonalizes the convolution kernel. For standard content-dependent softmax attention $\text{softmax}(QK^T/\sqrt{d})$, the attention matrix is determined by query/key content and is generally **not** circulant or Toeplitz; therefore FFT element-wise multiplication **cannot** equivalently replace the $QK^T$ computation. Schemes A/C are essentially position-dependent convolutional attention approximations, not exact substitutes for general softmax attention.

**Scheme A: FFT-Accelerated Attention (Time Series)**:
```python
# Express cyclic convolution as element-wise multiplication in the frequency domain
Q_hat = fft(Q, dim=seq)        # (n, d) -> (n, d) frequency domain
K_hat = fft(K, dim=seq)
# Attention ~ frequency-domain filtering: independent weighting per frequency component
attn_hat = Q_hat * conj(K_hat)  # element-wise multiply = cyclic convolution
attn = ifft(attn_hat, dim=seq)
# Complexity: O(n log n * d) vs. standard O(n^2 * d)
```

**Scheme B: Graph Spectral Attention (GNN)**:
```python
# Precompute graph Laplacian spectral decomposition L = U Lambda U^T (offline)
U = eigenvectors(L)  # (n, k), take top-k low-frequency eigenvectors
# Spectral-domain attention: compute in the low-frequency subspace
Q_spec = U^T @ Q   # (k, d) project to spectral domain
K_spec = U^T @ K
scores = (Q_spec @ W_q) @ (K_spec @ W_k).T / sqrt(d)
attn_spec = softmax(scores) @ (U^T @ V)
output = U @ attn_spec  # back-project to spatial domain
```

**Scheme C: Frequency-Adaptive Attention Weights**:
```python
freq_weights = learnable_parameter(num_freq_bands)  # learnable spectral weights
Q_hat, K_hat = fft(Q), fft(K)
scores_freq = freq_weights.unsqueeze(-1) * (Q_hat * conj(K_hat))
attn = ifft(scores_freq)
```

## Implementable Architectures
- **Spectral Transformer**: Replace $O(n^2)$ attention with FFT, suitable for periodic sequence data (meteorological, financial, audio)
- **Graph Spectral Attention**: Leverage the first $k$ eigenvectors of the graph Laplacian for low-dimensional attention, suitable for large-scale graphs ($n > 10^5$)
- **Frequency-Aware Positional Encoding**: The essence of RoPE is the unitary representation of the cyclic group $\mathbb{Z}$ (see Abstract Algebra Ch.4), generalizable to other groups

## GPU Feasibility
- **D1**: FFT and matrix multiplication are both standard tensor operations
- **D2**: Spectral projection $U^T Q$ is a standard GEMM; although FFT is not GEMM, highly optimized cuFFT implementations are available
- **D3[~]**: FFT attention $O(n \log n \cdot d)$, far superior to $O(n^2 d)$ -- **but only when attention has translation-invariant / position-dependent structure** (e.g., convolutional attention). General content-dependent softmax attention remains $O(n^2 d)$; linear attention approximations can achieve $O(n d^2)$, but via a different mechanism unrelated to FFT spectral methods.
- **D4**: Frequency-domain representation introduces no extra dimensions; spectral projection can reduce to $k \ll n$ dimensions
- **D5**: Complex-valued FFT suffers precision loss under fp16; fp32 or real-valued FFT (RFFT) is required
- **D6**: FFT can be parallelized across batch/head; cuFFT supports multi-stream execution
- **D7**: High-frequency components can be truncated in the spectral domain (structured sparsity), retaining only top-k frequencies
- **D8**: Fusing FFT with attention requires custom kernels; no ready-made fusion exists in standard libraries

**Quantitative assessment example** (standard transformer, d=128, n=2048, h=16):
- D3: FFT path FLOPs ≈ 2·n·log₂(n)·d ≈ 2·2048·11·128 ≈ 5.8M vs standard attention 2·n²·d ≈ 1.1G (only when attention is convolutional)
- D4: No n×n attention matrix materialization; FFT intermediates O(n·d) ≈ 1MB
- D5: FFT under bf16 has twiddle factor error ~10⁻³, acceptable
- D8: FFT + pointwise can be fused into a single CUDA kernel

## Paper Phrasing
"We propose a spectral-domain attention mechanism that transforms attention computation into the Fourier/Laplacian spectral domain, leveraging the cyclic convolution theorem to reduce **translation-invariant** sequence attention complexity from $O(n^2)$ to $O(n \log n)$ while preserving the ability to model dependencies at multiple scales through frequency-adaptive weights. Note: this acceleration **requires position-dependent (not content-dependent) attention structure**; for general content-dependent softmax attention, the spectral-domain equivalence does not hold."

## Applicability Conditions
- **Core restriction of FFT spectral attention**: The FFT acceleration in Schemes A/C **requires the attention matrix to be circulant or Toeplitz**, i.e., attention weights depend only on relative position $a_{ij} = f(i-j)$ and are independent of the specific token content (query/key vectors).
- **When the condition is NOT satisfied**: Standard softmax attention $\text{softmax}(QK^T/\sqrt{d})$ in most NLP tasks is content-dependent -- attention weights are jointly determined by query and key content, and the resulting attention matrix generally lacks circulant/Toeplitz structure. In this case, FFT element-wise multiplication **cannot** replace the $QK^T$ operation, and the $O(n \log n)$ complexity advantage does not hold.
- **When the condition IS satisfied**: Positional encoding (e.g., frequency components of RoPE/ALiBi), periodic convolutional kernels for time series, fixed-pattern attention with translation-invariant priors. Scheme B (graph spectral attention) is not subject to this restriction, as it projects onto graph Laplacian eigenbases rather than exploiting the cyclic convolution theorem.

## Risks
- **[x] Content-dependent attention incompatibility**: The core assumption of FFT spectral methods (circulant/Toeplitz structure) is **fundamentally incompatible** with the mainstream content-dependent softmax attention used in NLP. Applying FFT methods indiscriminately to general attention mechanisms constitutes a mathematical error -- they compute different quantities. Any usage must explicitly declare the position-dependence assumption being made.
- **Violation of Periodicity Assumption**: FFT implicitly assumes periodic boundary conditions, causing spectral leakage for non-periodic signals such as natural language. Windowing functions or zero-padding are needed.
- **Graph Laplacian Precomputation Cost**: Eigendecomposition $O(n^3)$ is infeasible for large-scale graphs, requiring approximations (Nystrom/Lanczos), and dynamic graphs necessitate recomputation.
