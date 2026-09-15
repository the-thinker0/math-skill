# Random Matrix Theory

## Minimal Definition

Random matrix theory studies spectra of random matrices. Deterministic limiting laws and edge-fluctuation laws require specified ensembles, scaling, moment/tail assumptions, and asymptotic regimes; they are not universal properties of arbitrary trained weights.

## Core Formulas

- **Marchenko–Pastur law**: For iid mean-zero, variance-$\sigma^2$ entries of $X\in\mathbb R^{n\times d}$ and $d/n\to c>0$, use the feature covariance $S=X^TX/n\in\mathbb R^{d\times d}$. The limiting continuous spectrum has endpoints $\sigma^2(1\pm\sqrt c)^2$; when $c>1$ it also has an atom of mass $1-1/c$ at zero. The different Gram matrix $XX^T/n$ has the same nonzero eigenvalues but a different zero mass.
- **Semicircle law**: For a centered real-symmetric Wigner ensemble with independent upper-triangular entries, off-diagonal variance $\sigma^2$, and standard moment assumptions, $W/\sqrt n$ has limiting density $\sqrt{4\sigma^2-\lambda^2}/(2\pi\sigma^2)$ on $[-2\sigma,2\sigma]$.
- **Tracy–Widom fluctuations**: In Gaussian and suitable universality classes at a regular soft edge, properly centered/scaled largest eigenvalues have $O(n^{-2/3})$ fluctuations. This scale is **larger** than the $O(n^{-1})$ bulk spacing; heavy-tailed ensembles and outlier spikes may obey different laws.
- **BBP phase transition**: In the rank-one spiked covariance model with identity noise covariance and population spike $1+\ell$, $\ell>\sqrt c$ yields sample outlier limit $(1+\ell)(1+c/\ell)$; below the threshold, the leading sample eigenvector has asymptotically vanishing overlap with the signal. This is not a universal detectability threshold for arbitrary data.
- **Gaussian smallest singular value**: If $X_{ij}\sim N(0,1)$ independently, $n\ge d$ and $t\ge0$, then $\Pr[\sigma_{\min}(X/\sqrt n)\le1-\sqrt{d/n}-t]\le e^{-nt^2/2}$. A nonpositive lower threshold gives no useful conditioning guarantee.
- **Sub-Gaussian singular-value bound**: For independent isotropic sub-Gaussian rows with uniformly bounded sub-Gaussian norm, $\sqrt n-C\sqrt d-t\le\sigma_{\min}(X)\le\sigma_{\max}(X)\le\sqrt n+C\sqrt d+t$ with probability at least $1-2e^{-c_0t^2}$; constants depend on the sub-Gaussian norm.

## Applicable Problems

- **Weight spectrum diagnosis**: does the trained weight spectrum deviate from the MP law (heavy tail, outlier spikes = learned structure); the theoretical basis of weight-watcher-style analysis
- **Legitimacy of random projections**: high-dimensional probabilistic justification for Johnson–Lindenstrauss and randomized numerical linear algebra error bounds
- **Covariance spectrum estimation**: bias correction of effective rank and condition number under finite samples (when $c = d/n$ is non-negligible, sample eigenvalues spread systematically outward)
- **Overparameterized generalization**: random-feature/NTK spectra = MP bulk + signal spikes, determining ridge-regression generalization error
- **Initialization design**: orthogonal vs Gaussian initialization; spectral conditions for dynamical isometry

## AI Design Translation

- **Spectral diagnostic**: Fit spectra only against an explicitly normalized null model. Compare real weights with shuffled/randomized controls and task metrics; an outlier or fitted heavy-tail exponent alone does not establish learned structure or training quality.
- **Random projection layer**: projecting $d$ dimensions to $k = O(\epsilon^{-2}\log n)$ preserves distances, justified by singular-value concentration of Gaussian projections; implemented as a single matmul with a fixed (untrained) random matrix
- **Signal detectability check**: estimate whether the spectral SNR exceeds the BBP threshold $\sqrt{c}$ to decide whether PCA/spectral clustering is feasible at the current sample size before committing more batch or switching methods

## Engineering Feasibility

- **Main operations**: spectral density estimation = Lanczos stochastic trace (Hutchinson) with $O(k)$ matvecs; full EVD of small matrices $O(d^3)$ only per-layer; full-parameter LLM EVD infeasible
- **GPU friendliness**: high. Spectral monitoring stays out of the training backbone and reads weight snapshots; Lanczos/matvec are all matmuls
- **Complexity**: A dense $d\times d$ EVD costs $O(d^3)$ time and $O(d^2)$ storage; there is no hardware-independent feasible cutoff. With $s$ probes and $k$ Lanczos steps, matrix-free spectral estimates cost $sk$ matvecs plus orthogonalization.
- **Low precision**: run spectral monitoring in fp32; outside the backward graph, so no gradient stability concerns

## Risks and Failure Conditions

- **Model mismatch**: MP departures can arise from correlations, heteroscedasticity, heavy tails, or normalization choices as well as learned signal. Diagnose these alternatives before interpreting a spectrum.
- **Finite-size correction to the BBP threshold**: $\sqrt{c}$ is asymptotic; at finite $n, d$ the transition band widens and conclusions near the threshold are unreliable
- **Heavy-tail fitting**: A finite-range power-law fit is an empirical hypothesis. Compare alternative distributions, fitting ranges, and held-out diagnostics; HTSR is an optional diagnostic framework, not a replacement theorem for all trained networks.
- **Products of random matrices**: the deep-network Jacobian is a matrix product whose spectrum is governed by product laws (free probability); single-layer MP conclusions do not extrapolate

## Assumption Check

Check matrix orientation, centering, variance normalization, aspect ratio, zero eigenvalue mass, and whether the claimed result concerns the bulk, soft edge, or spike. [Vershynin: author-hosted course and notes](https://www.math.uci.edu/~rvershyn/teaching/hdp/hdp.html).

## Further References

- Distilled book: `../../references/books/matrix-analysis.en.md` (classical spectral and perturbation results; RMT itself is beyond that book's scope)
- Vershynin. *High-Dimensional Probability*. Cambridge, 2018 (non-asymptotic bounds, Ch. 4, 7)
- Tao. *Topics in Random Matrix Theory*. AMS, 2012 (asymptotic spectral laws)
- Potters & Bouchaud. *A First Course in Random Matrix Theory*. Cambridge, 2020 (with ML applications)

## Routing Extensions

- For deterministic perturbation bounds -> `matrix-perturbation.en.md` (Weyl/Davis-Kahan; random matrices are the randomized counterpart)
- For spectral decomposition tools -> `spectral-decomposition.en.md` (EVD/SVD themselves)
- For deviation probability bounds -> `../probability/concentration-inequality.en.md` (scalar concentration inequalities)

## Extensible Directions

- Free probability: spectra of sums/products of independent random matrices; deep Jacobian analysis
- Products of random matrices: relation between depth and spectral explosion/vanishing
- Dyson Brownian motion: stochastic dynamics of eigenvalues, connection to diffusion processes
- RMT for kernel methods: kernel matrix spectra and generalization
- Sparse random matrices: spectra of graph adjacency matrices (Bordenave–Chafaï)
