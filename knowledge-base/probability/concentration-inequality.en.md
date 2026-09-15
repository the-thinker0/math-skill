# Concentration Inequality

## Minimal Definition
Concentration inequalities bound the **probability that a sum of independent random variables (or a Lipschitz function) deviates from its expectation**. The core intuition: when many independent random factors are superimposed, the outcome is highly concentrated around the mean, with tail probabilities decaying exponentially. They serve as a "quantitative strengthening of the law of large numbers."

**Check before use**: Markov needs $a>0$ and finite expectation; Hoeffding needs independent $X_i\in[a_i,b_i]$ almost surely; McDiarmid needs independent inputs and a uniform bounded-difference condition. Exponential concentration requires distributional/dependence assumptions and does not follow merely from summing many random terms. Matrix concentration is a separate theorem, not scalar concentration applied entrywise without a dimension factor.

## Core Formulas

**Markov's Inequality** (weakest, most general):
$$P(X \geq a) \leq \frac{\mathbb{E}[X]}{a}, \quad X \geq 0$$

**Hoeffding's Inequality** (sum of bounded independent variables):
$$P\left(\left|\frac{1}{n}\sum_{i=1}^n X_i - \mathbb{E}\left[\frac{1}{n}\sum X_i\right]\right| \geq t\right) \leq 2\exp\left(-\frac{2n^2 t^2}{\sum(b_i - a_i)^2}\right)$$

**Bernstein's Inequality** (exploits variance information, tighter tails): Let $X_i$ be independent, zero-mean, with $|X_i| \leq M$, and write $\sigma^2 = \sum_i \mathrm{Var}(X_i)$. Then
$$P\left(\sum X_i \geq t\right) \leq \exp\left(-\frac{t^2/2}{\sigma^2 + Mt/3}\right)$$

**McDiarmid's Inequality** (bounded-difference functions): If $f$ has sensitivity $c_i$ to changes in the $i$-th variable, then
$$P(|f(X_1,\ldots,X_n) - \mathbb{E}[f]| \geq t) \leq 2\exp\left(-\frac{2t^2}{\sum c_i^2}\right)$$

## Applicable Problems
- **Generalization bound derivation**: Given training set size $n$, with what probability does the gap between model predictions and true risk fall within $\epsilon$
- **Stochastic algorithm reliability**: Probabilistic control of the deviation between mini-batch gradients and full-batch gradients
- **Sampling estimation accuracy**: Quantitative computation of confidence intervals for Monte Carlo estimators

## AI Design Translation
- **Generalization**: A fixed-predictor concentration bound does not automatically cover a predictor fitted on the same sample. Add a uniform bound/complexity measure, stability argument or independent hold-out protocol.
- **Stochastic regularization**: Bound dropout/stochastic-depth output only after specifying independence, bounded increments or tail assumptions and the nonlinear propagation of noise.
- **Gradient compression**: Concentration can bound a defined estimator error; distributed convergence additionally requires optimization assumptions, compression bias handling and communication/update rules.

## Engineering Feasibility
- **D1[v]**: The bounds themselves are scalar formulas with no tensor operations; zero overhead as an analytical tool
- **D2[v]**: Does not directly participate in GEMM, but can serve as a theoretical basis for hyperparameter selection (batch size, compression ratio)
- **D3[v]**: Computing the bound itself is $O(1)$ or $O(n)$, very low cost
- **D5[v]**: Bounds can be computed in fp32; does not enter the training backbone
- **D8[v]**: Does not enter the computation graph; no fusion overhead

## Risks and Failure Conditions
- **Independence assumption violated**: In sequential data and autoregressive models, tokens are strongly correlated, and Hoeffding's exponential decay guarantee fails. Martingale versions (Azuma-Hoeffding) or mixing-time corrections are required.
- **Heavy tails**: Neither bounded-variable Hoeffding nor the displayed bounded-variable Bernstein applies directly to unbounded heavy tails. Use appropriate finite-moment bounds, robust estimators or truncation with an explicit bias term.

## Further References
- Distillation draft: `../../references/books/` — no dedicated probability distillation draft at present; this card is based on standard probability theory textbooks
- Boucheron, Lugosi, Massart. *Concentration Inequalities: A Nonasymptotic Theory of Independence*. Oxford, 2013
- Vershynin. *High-Dimensional Probability*. Cambridge, 2018 (Chapters 2-3)
- Related knowledge cards: `entropy.en.md`, `fisher-information.en.md`


## Routing Extensions
- If information-theoretic bounds are needed -> `entropy.en.md` (entropy-based concentration inequalities)
- If Donsker-Varadhan representation is needed -> `kl-divergence.en.md` (variational representation of KL divergence)
- If random matrix bounds are involved -> `../matrix-analysis/random-matrix.en.md` (MP law, non-asymptotic bounds for spectral norms and smallest singular values)

## Extensible Directions
- Martingale concentration (Azuma / Freedman): concentration inequalities for martingale differences
- Log-Sobolev inequalities: implying hypercontractivity and concentration
- Transportation inequalities: relationship between Wasserstein distance and relative entropy
- Talagrand's inequality: dimension-free concentration on product spaces
- Concentration on product spaces: concentration of functions of independent variables
- Dimension-free bounds: concentration bounds that do not degrade with dimension
