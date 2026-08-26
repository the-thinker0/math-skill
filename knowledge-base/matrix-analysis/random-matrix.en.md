# Random Matrix Theory

## Minimal Definition

Random matrix theory studies the statistical regularities of the spectrum (eigenvalues/singular values) of matrices with random entries. The core phenomenon: in the high-dimensional limit, the empirical spectral distribution converges to a **deterministic limiting law** (Marchenko–Pastur, semicircle), while individual fluctuations of edge eigenvalues follow the Tracy–Widom law. It turns "randomness" into computable "determinism" and underlies high-dimensional statistics and spectral analysis of deep learning.

## Core Formulas

- **Marchenko–Pastur law**: For $X \in \mathbb{R}^{n \times d}$ with iid entries (mean 0, variance $\sigma^2$), the sample covariance $S = \frac{1}{n}XX^T$ has spectral distribution converging, as $n, d \to \infty$ with $d/n \to c \in (0,1]$, to the MP law supported on $[\sigma^2(1-\sqrt{c})^2,\ \sigma^2(1+\sqrt{c})^2]$
- **Semicircle law**: For a symmetric Wigner matrix $W$ (iid upper triangle), the spectrum of $W/\sqrt{n}$ converges to the semicircle density $\frac{1}{2\pi\sigma^2}\sqrt{4\sigma^2 - \lambda^2}$ on $[-2\sigma, 2\sigma]$
- **Tracy–Widom fluctuation**: The largest eigenvalue deviates from the spectral edge by $O(n^{-2/3})$, following the TW distribution — edge fluctuations are much smaller than bulk spacings
- **BBP phase transition (spiked covariance)**: a signal spike of strength $\ell$ escapes the MP bulk only if $\ell > \sqrt{c}$, landing at $(1+\ell)(1+c/\ell)$; for $\ell \leq \sqrt{c}$ the signal is swallowed by noise (PCA failure threshold)
- **Smallest singular value**: for Gaussian $X \in \mathbb{R}^{n \times d}$ ($n \geq d$): $\sigma_{\min}(X) \approx \sqrt{n} - \sqrt{d}$; concentration $P(\sigma_{\min}(X/\sqrt{n}) \leq 1 - \sqrt{d/n} - t) \leq e^{-nt^2/2}$
- **Non-asymptotic spectral norm bound** (sub-Gaussian): $\sqrt{n} - C\sqrt{d} - t \leq \sigma_{\min}(X) \leq \sigma_{\max}(X) \leq \sqrt{n} + C\sqrt{d} + t$ with probability $\geq 1 - 2e^{-ct^2}$

## Applicable Problems

- **Weight spectrum diagnosis**: does the trained weight spectrum deviate from the MP law (heavy tail, outlier spikes = learned structure); the theoretical basis of weight-watcher-style analysis
- **Legitimacy of random projections**: high-dimensional probabilistic justification for Johnson–Lindenstrauss and randomized numerical linear algebra error bounds
- **Covariance spectrum estimation**: bias correction of effective rank and condition number under finite samples (when $c = d/n$ is non-negligible, sample eigenvalues spread systematically outward)
- **Overparameterized generalization**: random-feature/NTK spectra = MP bulk + signal spikes, determining ridge-regression generalization error
- **Initialization design**: orthogonal vs Gaussian initialization; spectral conditions for dynamical isometry

## AI Design Translation

- **Spectral health monitor**: fit the ESD of each layer's weights against the MP law. Poor fit plus a heavy-tail exponent $\alpha \in (2,4)$ usually indicates well-trained layers; outlier spikes indicate learned low-rank structure. Implement as periodic (every N steps) Lanczos spectral-density estimation on sampled submatrices
- **Random projection layer**: projecting $d$ dimensions to $k = O(\epsilon^{-2}\log n)$ preserves distances, justified by singular-value concentration of Gaussian projections; implemented as a single matmul with a fixed (untrained) random matrix
- **Signal detectability check**: estimate whether the spectral SNR exceeds the BBP threshold $\sqrt{c}$ to decide whether PCA/spectral clustering is feasible at the current sample size before committing more batch or switching methods

## Engineering Feasibility

- **Main operations**: spectral density estimation = Lanczos stochastic trace (Hutchinson) with $O(k)$ matvecs; full EVD of small matrices $O(d^3)$ only per-layer; full-parameter LLM EVD infeasible
- **GPU friendliness**: high. Spectral monitoring stays out of the training backbone and reads weight snapshots; Lanczos/matvec are all matmuls
- **Complexity**: full spectrum per layer $O(d^3)$ (acceptable for $d \leq 10^4$); stochastic trace estimation $O(kd^2)$ with $k \sim 10^2$, far cheaper than full EVD
- **Low precision**: run spectral monitoring in fp32; outside the backward graph, so no gradient stability concerns

## Risks and Failure Conditions

- **iid assumption of the MP law**: trained weights are not iid random matrices. MP fitting is a **diagnostic tool, not a theorem** — deviation from MP is exactly where the signal lives; do not force-fit MP as the "correct" baseline
- **Finite-size correction to the BBP threshold**: $\sqrt{c}$ is asymptotic; at finite $n, d$ the transition band widens and conclusions near the threshold are unreliable
- **Heavy-tailed spectra are not MP**: well-trained networks often show power-law tails $\rho(\lambda) \sim \lambda^{-\alpha}$, contradicting MP's compact support; use the HTSR (heavy-tailed self-regularization) classification framework instead
- **Products of random matrices**: the deep-network Jacobian is a matrix product whose spectrum is governed by product laws (free probability); single-layer MP conclusions do not extrapolate

## Further References

- Distilled book: `../../references/books/matrix-analysis.md` (classical spectral and perturbation results; RMT itself is beyond that book's scope)
- Vershynin. *High-Dimensional Probability*. Cambridge, 2018 (non-asymptotic bounds, Ch. 4, 7)
- Tao. *Topics in Random Matrix Theory*. AMS, 2012 (asymptotic spectral laws)
- Potters & Bouchaud. *A First Course in Random Matrix Theory*. Cambridge, 2020 (with ML applications)

## Routing Extensions

- For deterministic perturbation bounds -> `matrix-perturbation.md` (Weyl/Davis-Kahan; random matrices are the randomized counterpart)
- For spectral decomposition tools -> `spectral-decomposition.md` (EVD/SVD themselves)
- For deviation probability bounds -> `../probability/concentration-inequality.en.md` (scalar concentration inequalities)

## Extensible Directions

- Free probability: spectra of sums/products of independent random matrices; deep Jacobian analysis
- Products of random matrices: relation between depth and spectral explosion/vanishing
- Dyson Brownian motion: stochastic dynamics of eigenvalues, connection to diffusion processes
- RMT for kernel methods: kernel matrix spectra and generalization
- Sparse random matrices: spectra of graph adjacency matrices (Bordenave–Chafaï)
