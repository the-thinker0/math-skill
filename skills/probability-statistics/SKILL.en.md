---
name: probability-statistics
description: |
  Trigger when a problem involves quantifying uncertainty, probability distributions, Bayesian inference, hypothesis testing, regression modeling, experimental design, causal effect estimation; or designing probabilistic mechanisms for random algorithms/sampling/quantization/training dynamics.
---

# Probability & Statistics

> "Uncertainty is quantifiable -- probability is not just a mathematical formula, but a way to understand the random world. Quantifying uncertainty, extracting patterns from data, and making rational inferences and decisions."
>
> -- Probability Theory, Mathematical Statistics

## Core Principle

**The world is full of uncertainty. Rational decision-making is not the pursuit of certainty, but the pursuit of expected-value-optimal choices under uncertainty -- probability is quantified belief, and data is quantified evidence.**

> **Mathematical Formalization**
>
> A probability space $(\Omega, \mathcal{F}, P)$ is defined by the Kolmogorov axioms: (1) **Non-negativity** $P(A) \ge 0$; (2) **Normalization** $P(\Omega) = 1$; (3) **Countable additivity**: for a countable family of mutually disjoint events $A_i$, $P(\cup_i A_i) = \sum_i P(A_i)$. From these follow the complement rule $P(A^c)=1-P(A)$ and the law of total probability $P(B)=\sum_i P(B|A_i)P(A_i)$.
>
> **Bayesian updating**: $P(\theta|D) = P(D|\theta)\cdot P(\theta)/P(D)$; prior -> likelihood -> posterior; the posterior becomes the new prior upon encountering new data.
>
> **Expectation and variance**: $E[X] = \sum x\cdot P(x)$ (discrete) or $\int x\cdot f(x)\,dx$ (continuous); $\text{Var}(X) = E[(X-\mu)^2] = E[X^2] - (E[X])^2$.
>
> **Law of Large Numbers / CLT**: As $n \to \infty$, the sample frequency $f/n \to P(A)$ and the sample mean $\bar{X} \to \mu$ (convergence in probability); $\sqrt{n}\cdot(\bar{X} - \mu)/\sigma \xrightarrow{d} N(0,1)$, so the superposition of many independent small factors tends toward normality.
>
> **Bias-variance trade-off**: Total error $= \text{Bias}^2 + \text{Variance} + \sigma^2$ (irreducible noise).

## GPU-Friendliness (Cross-Cutting Check)

When probabilistic methods are used for **random algorithm / sampling / training dynamics design**, they must pass the eight-dimensional gate in `../../references/gpu-friendly-math.md`:

- **Batch sampling / Monte Carlo**: i.i.d. sampling is naturally parallelizable and GEMM-friendly (reparameterization trick, Gumbel-Softmax); viable in low precision, but RNG state and cross-device consistency must be managed.
- **MLE / log-likelihood**: Element-wise likelihood is fusible and batchable (friendly); softmax cross-entropy should use logsumexp for numerical stability.
- **Exact Bayesian integration / marginalization**: In high dimensions, the normalization constant $Z=P(D)$ and marginalization of $P(\theta|D)\propto P(D|\theta)P(\theta)$ admit no closed form -- adapt to **MCMC (HMC/NUTS) / variational inference ELBO** (see `../../references/books/optimization-ml.md`).
- **Large posterior tables / covariances**: Incomputable -- use mean-field / low-rank factorized approximations (see `../../references/books/matrix-analysis.md`).
- **Anti-patterns**: Sample-sequential MCMC, exact inference requiring global normalization, "beautiful but incomputable" high-dimensional integrals.

Eight-dimensional minimum assessment (formal terms): **Tensorization** -- whether samples, particles, and distribution parameters can be batched; **GEMM-mappability** -- whether likelihood, regression, and covariance computations fall into matrix operations; **Complexity** -- number of sampling steps, integration dimension, posterior table size; **Memory & KV-Cache** -- whether particles, covariances, and sufficient statistics can be low-rank / streaming; **Low-precision stability** -- logsumexp, probability normalization, tail probabilities; **Parallelism & communication** -- RNG and cross-device reductions; **Sparse structure** -- whether the graphical model / covariance is structured; **Operator fusion** -- whether sampling, scoring, and normalization can be fused.

> Cross-reference `../../references/books/optimization-ml.md` (variational / SAA / stochastic optimization) and `../../references/books/matrix-analysis.md` (low-rank covariance).

## When NOT to Use

- **Deterministic problems** (the answer is known or obtainable by deductive reasoning) -- probabilistic tools are unnecessary.
- **Extremely small sample sizes ($n < 5$) that cannot be increased** -- one should report the data itself rather than draw inferences.
- **Purely qualitative descriptive needs** -- data analysis is not required.
- **Causal mechanisms are already well-established and require no probabilistic modeling** -- use deterministic causal chains directly.
- **Data is entirely missing or severely corrupted** -- no meaningful statistical operations can be performed.

## When to Use

- Reviewing whether the statistical methods in a paper / experiment are correct and whether conclusions are significant.
- Experimental data analysis, significance testing, effect-size assessment, regression modeling, and prediction.
- Experimental design and power analysis (randomization, blocking, factorial designs).
- Causal effect estimation (DAG + back-door criterion / do-calculus).
- Bayesian inference and prior-posterior updating, goodness-of-fit tests ($\chi^2$/F).
- **Designing probabilistic mechanisms for random algorithms / sampling / quantization / training dynamics** (Monte Carlo, reparameterization, probabilistic quantization) and evaluating their GPU viability.

## Method

### Step 1: Define the Random Phenomenon
Identify the **random variable $X$** (the quantity to be measured), the **sample space $\Omega$** (all possible outcomes), the **event space $\mathcal{F}$** ($\sigma$-algebra on $\Omega$: contains $\Omega$, closed under complementation, closed under countable union), and the **probability measure $P$**: $\Omega\to[0,1]$ (satisfying the Kolmogorov axioms). Distinguish between discrete and continuous random variables.

### Step 2: Choose the Probability Model
Select a distribution based on data type, sample size, and physical mechanism:

| Distribution | Use Case | Key Parameters |
|---|---|---|
| Binomial | Number of successes in $N$ independent Bernoulli trials | $n, p$ |
| Poisson | Count of rare events per unit time/space | $\lambda$ (mean rate) |
| Normal | Superposition of many independent small factors (CLT) | $\mu, \sigma^2$ |
| Exponential | Waiting times; memoryless property $P(X>t+s\|X>s)=P(X>t)$ | $\lambda$ (rate) |
| Bayesian | Prior + likelihood -> posterior; incremental belief updating | Prior parameters, likelihood function |
| Student's $t$ | Small-sample mean inference; heavier tails than normal | $df = n - 1$ |
| $\chi^2$ | Goodness-of-fit tests, contingency tables, variance estimation | $df$ |
| $F$ | Comparing two variances, ANOVA | $df_1, df_2$ |
| Uniform | Equally likely events, non-informative default | $a, b$ |

Selection principles: discrete vs. continuous; large samples tend toward normal (use $t$ for small samples); physical mechanism (Poisson = rare independent events, Exponential = waiting times).

### Step 3: Collect Data
Verify that the **sample size** is sufficient (power analysis determines the minimum $n$), check for **sample bias** (selection / survivorship / voluntary response bias), assess **data quality** (measurement error / missing values / outliers), examine the **collection method** (random sampling vs. convenience sampling), and identify **block structure**. Representativeness is more important than volume -- a biased large sample is more dangerous than an unbiased small one.

### Step 4: Statistical Inference
**Point estimation / MLE**: $\hat{\theta} = \arg\max_\theta L(\theta;x)$, where $L(\theta;x)=f(x|\theta)$; asymptotically normal and asymptotically efficient for large samples. **Confidence intervals** provide an interval estimate at a given confidence level (e.g., 95%); the frequentist interpretation is that 95% of such intervals from repeated sampling contain the true value. **Hypothesis testing**: $H_0$ vs. $H_1$; p-value $= P(\text{data this extreme or more} \mid H_0)$; reject $H_0$ if $p < \alpha$. **Bayesian updating**: $P(\theta|D) = P(D|\theta)\cdot P(\theta)/P(D)$.

### Step 5: Regression Modeling
**Linear regression**: $Y = \beta_0 + \beta_1 X + \varepsilon$, $\varepsilon \sim N(0,\sigma^2)$; least-squares estimate $\hat{\beta} = (X^TX)^{-1}X^TY$; assumptions include linearity, independence, homoscedasticity, and normality of residuals. **Multiple / logistic regression**: $P(Y=1|X) = 1/(1+e^{-(\beta_0+\sum\beta_i X_i)})$; MLE estimation yields output probabilities. **Model selection**: AIC $= -2\ln L + 2k$ (favors predictive fit), BIC $= -2\ln L + k\cdot\ln n$ (favors parsimony), adjusted $R^2 = 1 - (1-R^2)(n-1)/(n-k-1)$. **Bias-variance trade-off**: Total error $= \text{Bias}^2 + \text{Variance} + \sigma^2$; use cross-validation to select complexity.

### Step 6: Experimental Design
**Randomization** ensures that treatment and control groups are equal in expectation on all variables (known and unknown). **Blocking** groups similar units together and compares within blocks to reduce confounding variation. **Power analysis**: $\text{Power} = 1 - \beta = P(\text{reject } H_0 \mid H_1 \text{ is true})$; given effect size $\delta$ and $\alpha$, compute the minimum required $n$; low power implies high false-negative rate. **Factorial designs**: $2^k$ designs study $k$ factors and their interactions simultaneously.

### Step 7: Causal Inference
**Confounding variables**: $Z$ affects both $X$ and $Y$, so $P(Y|X) \neq P(Y|do(X))$; without adjustment, the estimated effect is biased. **DAGs**: Nodes represent variables, arrows represent direct causal effects; identify back-door and mediating paths. **Do-calculus / back-door criterion**: If $S$ blocks all back-door paths from $X$ to $Y$ and contains no descendants of $X$, then $P(Y|do(X)) = \sum_s P(Y|X,S=s)\cdot P(S=s)$. **Randomization** directly blocks all back-door paths and is the gold standard for causal effect estimation.

### Step 8: Interpret Results
Distinguish **statistical significance** from **practical significance** ($p<0.05$ does not mean the effect is large; with large samples, even tiny differences become "significant"). Report **effect sizes**: Cohen's $d = (\mu_1-\mu_2)/\sigma$, odds ratio $= (P_1/(1-P_1))/(P_2/(1-P_2))$. Remember that **correlation does not imply causation** ($P(Y|X) \neq P(Y|do(X))$) and beware of **multiple comparisons** (for $m$ tests, the expected number of false positives is $m\cdot\alpha$; apply Bonferroni $\alpha_{\text{adj}}=\alpha/m$ or BH-FDR correction).

### Step 9: Quantify Uncertainty
Provide **confidence intervals** (frequentist: repeated-sampling coverage) or **credible intervals** (Bayesian: the probability that the parameter lies in this interval); state the reliability and statistical power of conclusions; identify sources of residual uncertainty (model assumptions, measurement error, unobserved confounders); report effect-size intervals rather than point estimates alone.

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Treating the p-value as truth | $p=0.05$ does not mean "95% certainty"; it is the probability of observing this data or more extreme data under $H_0$ | Understand $p = P(\text{data or more extreme} \mid H_0)$ |
| Confusing probability with frequency | Probability is a theoretical quantity $P(A)$; frequency is an empirical quantity $f(A)/n$ | Connect them via the law of large numbers: $f/n \to P$ as $n\to\infty$ |
| Neglecting prior probabilities | Base-rate neglect: focusing only on new evidence while ignoring background probability; especially dangerous for rare-disease screening | Bayesian reasoning: $P(H\|E) = P(E\|H)\cdot P(H)/P(E)$ |
| Survivorship bias | Looking only at survivors truncates the sample space | Consider the full sample space $\Omega$, including failures |
| Small-sample trap | "Patterns" from $n=3$ are unreliable; variance estimates are unstable | Check sample size, compute power, use the $t$-distribution |
| Confusing correlation with causation | Correlation between two variables does not mean one causes the other | Search for confounders; use DAGs + back-door criterion |
| Ignoring regression to the mean | After extreme performance, values tend to regress toward $E[X]$ | Use regression analysis rather than intuitive trend judgment |
| Using the normal distribution instead of $t$ for small samples | For $n<30$, the normal approximation underestimates uncertainty | Use the $t$-distribution with $df=n-1$ for $n<30$ |
| Confusing AIC with BIC | AIC favors predictive fit; BIC favors parsimony | Use AIC for prediction, BIC for explanation |
| Inferring causation from observational data | Without randomization, confounding cannot be eliminated; $P(Y\|X) \neq P(Y\|do(X))$ | Apply DAG + back-door criterion adjustment, or restrict claims to association only |
| Ignoring multiple-comparison corrections | For $m$ tests, the expected number of false positives is $m\cdot\alpha$ | Apply Bonferroni $\alpha/m$ or BH-FDR |
| Ignoring power and effect size | Low power may fail to detect a real effect; reporting only $p$ without effect size is incomplete | Compute required sample size before the study; report Cohen's $d$ / odds ratio |
| Exact integration / large posterior tables are incomputable | High-dimensional normalization $Z=P(D)$ and marginalization have no closed form; sample-sequential MCMC is not parallelizable | Use MCMC / variational ELBO / low-rank approximations; pass the GPU eight-dimensional gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Random variable definitions**: `[Variable]: [Meaning] [Type: Discrete / Continuous]`, specifying the sample space $\Omega$ and event space $\mathcal{F}$
2. **Probability model**: `[Distribution]: [Choice] because [Reason]`, noting $df$ or key parameters
3. **Data assessment**: `[Sample size]: N, [Bias check]: [Result], [Collection method]: [Random / Convenience]`
4. **Statistical inference**: `[Estimate]: [\hat{\theta}], [Confidence interval]: [a,b], [p-value]: [value], [Method]: [MLE / Bayesian]`
5. **Regression / experimental design (if applicable)**: `[Model]: [Linear / Logistic] [Coefficients]: [\hat{\beta}] [Criterion]: [AIC / BIC]`; `[Design]: [Randomization / Block / Factorial] [Power]: [Power] [Minimum n]: [n]`
6. **Causal assessment (if applicable)**: `[DAG]: [Paths], [Confounders]: [List], [Adjustment set]: [S], [Causal effect]: [P(Y|do(X))]`
7. **Effect size and uncertainty**: Cohen's $d$ / odds ratio with confidence intervals, statistical power, and residual uncertainty
8. **Bias check**: Systematically review the common-errors table, marking each as "None found" or "Warning: [issue found]"
9. **[GPU viability]** (if used for random algorithms / sampling / training): Whether inference requires sampling / variational approximation; pass the eight-dimensional gate; label as friendly / amenable to adaptation / anti-pattern, with adaptation recommendations
10. **Action recommendations**: Explicitly state "Next, I will..."

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Modeling**: Probabilistic models are essential modeling tools -- uncertainty requires a probabilistic framework.
- **Optimization**: Optimization under uncertainty requires expected-value optimization or robust optimization; stochastic optimization / SAA converts expected objectives to deterministic approximations.
- **Induction and analogy**: Discovering patterns in data is the probabilistic version of inductive reasoning.
- **Logic and deduction**: Classical logic is deterministic; probabilistic logic is its generalization to uncertainty.
- **Causal inference**: $P(Y|X)$ is a statistical association; $P(Y|do(X))$ is a causal effect; causal claims require mechanistic assumptions (DAGs) and cannot be derived from data alone.
- **Information theory**: Entropy $H(X)=-\sum P(x)\ln P(x)$ quantifies uncertainty; information gain $I(X;Y)=H(X)-H(X|Y)$; the maximum-entropy principle selects the distribution that maximizes entropy subject to constraints.
- **Modern mathematics activation**: `../../references/books/optimization-ml.md` (stochastic optimization / SAA, variational inference ELBO), `../../references/books/matrix-analysis.md` (low-rank covariance, factorized approximations).
