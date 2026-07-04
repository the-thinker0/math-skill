# Concentration Inequality

## Minimal Definition
Concentration inequalities bound the **probability that a sum of independent random variables (or a Lipschitz function) deviates from its expectation**. The core intuition: when many independent random factors are superimposed, the outcome is highly concentrated around the mean, with tail probabilities decaying exponentially. They serve as a "quantitative strengthening of the law of large numbers."

## Core Formulas

**Markov's Inequality** (weakest, most general):
$$P(X \geq a) \leq \frac{\mathbb{E}[X]}{a}, \quad X \geq 0$$

**Hoeffding's Inequality** (sum of bounded independent variables):
$$P\left(\left|\frac{1}{n}\sum_{i=1}^n X_i - \mathbb{E}\left[\frac{1}{n}\sum X_i\right]\right| \geq t\right) \leq 2\exp\left(-\frac{2n^2 t^2}{\sum(b_i - a_i)^2}\right)$$

**Bernstein's Inequality** (exploits variance information, tighter tails):
$$P\left(\sum X_i \geq t\right) \leq \exp\left(-\frac{t^2/2}{\sigma^2 + Mt/3}\right)$$

**McDiarmid's Inequality** (bounded-difference functions): If $f$ has sensitivity $c_i$ to changes in the $i$-th variable, then
$$P(|f(X_1,\ldots,X_n) - \mathbb{E}[f]| \geq t) \leq 2\exp\left(-\frac{2t^2}{\sum c_i^2}\right)$$

## Applicable Problems
- **Generalization bound derivation**: Given training set size $n$, with what probability does the gap between model predictions and true risk fall within $\epsilon$
- **Stochastic algorithm reliability**: Probabilistic control of the deviation between mini-batch gradients and full-batch gradients
- **Sampling estimation accuracy**: Quantitative computation of confidence intervals for Monte Carlo estimators

## AI Design Translation
- **PAC learning bounds / generalization bounds**: Hoeffding/McDiarmid provides probabilistic bounds on the gap between empirical risk and true risk
- **Variance control for Dropout / Stochastic Depth**: Bernstein's inequality guarantees output concentration under stochastic regularization
- **Gradient compression / communication efficiency**: Concentration bounds on gradient deviation after quantization or sparsification, ensuring convergence of distributed training

## Engineering Feasibility
- **Dimension 1 Tensorization ✅**: The bounds themselves are scalar formulas with no tensor operations; zero overhead as an analytical tool
- **Dimension 2 GEMM Mappability ✅**: Does not directly participate in GEMM, but can serve as a theoretical basis for hyperparameter selection (batch size, compression ratio)
- **Dimension 3 Complexity ✅**: Computing the bound itself is $O(1)$ or $O(n)$, very low cost
- **Dimension 5 Low Precision ✅**: Bounds can be computed in fp32; does not enter the training backbone
- **Dimension 8 Operator Fusion ✅**: Does not enter the computation graph; no fusion overhead

## Risks and Failure Conditions
- **Independence assumption violated**: In sequential data and autoregressive models, tokens are strongly correlated, and Hoeffding's exponential decay guarantee fails. Martingale versions (Azuma-Hoeffding) or mixing-time corrections are required.
- **Boundedness assumption violated**: Under heavy-tailed distributions (e.g., power laws), Hoeffding does not apply; Bernstein or truncation tricks are needed. In LLM training, when gradients occasionally take extreme values, naive concentration bounds yield a false sense of security.

## Further References
- Distillation draft: `references/books/` — no dedicated probability distillation draft at present; this card is based on standard probability theory textbooks
- Boucheron, Lugosi, Massart. *Concentration Inequalities: A Nonasymptotic Theory of Independence*. Oxford, 2013
- Vershynin. *High-Dimensional Probability*. Cambridge, 2018 (Chapters 2-3)
- Related knowledge cards: `probability/entropy.md`, `probability/fisher-information.md`
