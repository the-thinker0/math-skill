# Mathematical Sources and Classic Texts

## Bayes' Theorem (Bayes, 1763)

> P(H|E) = P(E|H) × P(H) / P(E)
>
> Posterior = Likelihood × Prior / Evidence

**Meaning**: When we observe new evidence E, our belief about hypothesis H is updated from the prior P(H) to the posterior P(H|E).

**The core of Bayesian thinking**:
1. Start with a belief (prior probability)
2. Observe data (evidence)
3. Update the belief (posterior probability)
4. Repeat the process

**Mathematical background**: Thomas Bayes's paper "An Essay towards solving a Problem in the Doctrine of Chances" was published posthumously in 1763 by Richard Price. Bayes' theorem is essentially a rearrangement of the definition of conditional probability P(A∩B) = P(A|B)P(B) = P(B|A)P(A), yet its philosophical significance far transcends the mathematics itself — it provides a rigorous mathematical framework for "learning from data."

## Law of Large Numbers (Bernoulli, 1713)

> As the number of trials n approaches infinity, the sample mean converges in probability to the expected value.

**Meaning**: A single observation is unreliable, but a large number of observations reveals the true pattern. This is the theoretical foundation of statistical inference.

**Mathematical background**: Jacob Bernoulli proved the weak law of large numbers in *Ars Conjectandi* (1713): for any ε>0, P(|X̄ₙ - μ| ≥ ε) → 0. Borel (1909) and Kolmogorov subsequently strengthened this to the strong law of large numbers — almost sure convergence: P(lim X̄ₙ = μ) = 1.

## Central Limit Theorem (De Moivre-Laplace, 1733 – Lindeberg-Feller, 20th century)

> The sum of a large number of i.i.d. random variables is approximately normally distributed, regardless of the original distribution.

**Meaning**: The normal distribution is ubiquitous because it is the natural result of "the superposition of many small factors."

**Mathematical background**: De Moivre (1733) first discovered the normal approximation to the binomial distribution; Laplace (1810) generalized it to the general case. The Lindeberg-Feller conditions give the most precise convergence conditions for independent but non-identically distributed settings. Lyapunov (1901) introduced the characteristic function approach, which became a core tool of modern probability theory.

## Kolmogorov Axioms (1933)

> The foundational axioms of probability theory:
> 1. Non-negativity: P(A) ≥ 0
> 2. Normalization: P(Ω) = 1
> 3. Countable additivity: If A₁, A₂, ... are mutually disjoint, then P(∪Aₖ) = ΣP(Aₖ)

**Meaning**: Probability is defined as a measure — probability theory thereby became a rigorous branch of mathematics rather than a collection of empirical rules.

**Mathematical background**: In *Grundbegriffe der Wahrscheinlichkeitsrechnung* (1933), Andrey Kolmogorov embedded probability theory within the measure-theoretic framework (Ω, F, P), i.e., the triple of sample space, event space (σ-algebra), and probability measure. This axiomatization gave precise definitions to concepts such as the law of large numbers, conditional probability, and random variables, and is the cornerstone of modern probability theory.

## Neyman-Pearson Lemma (1928/1933)

> At a given significance level α, the likelihood ratio test is the most powerful test:
> Reject H₀ when L(x|H₁)/L(x|H₀) > k, where k is determined by α.

**Meaning**: Statistical testing is not a matter of subjective judgment; it can be made optimal under the constraint of "controlling the probability of error."

**Mathematical background**: Jerzy Neyman and Egon Pearson systematized hypothesis testing theory between 1928 and 1933, introducing the concepts of Type I error (α, false positive), Type II error (β, false negative), and test power (power = 1-β). The Neyman-Pearson lemma proves the optimality of the likelihood ratio test in the simple-vs-simple hypothesis setting. This framework became the standard paradigm for modern statistical testing.

## Fisher's Statistical Inference (1920s–1930s)

- **Maximum likelihood estimation**: Choose the parameter θ̂ = argmax L(θ; x) that maximizes the probability of observing the data
- **p-value**: The probability of observing the current or more extreme data under the assumption that the null hypothesis is true
- **Significance testing**: Deciding whether to reject the null hypothesis via the p-value
- **Sufficiency principle**: A statistic T(X) is sufficient if P(X|T) does not depend on θ

**Mathematical background**: R.A. Fisher's contributions extend far beyond the p-value. He proposed criteria for evaluating estimators such as consistency and efficiency; Fisher information I(θ) = E[(∂log L/∂θ)²] measures the information content of data about the parameter and is closely linked to the Cramér-Rao lower bound: Var(θ̂) ≥ 1/I(θ).

## Fisher's Experimental Design (1935)

> Randomization does not ignore causality — it makes causal inference possible.

**Meaning**: The credibility of a scientific experiment comes not from "precise control" but from "random assignment."

**Mathematical background**: In *The Design of Experiments* (1935), Fisher proposed three fundamental principles — randomization, blocking, and factorial designs. Randomization ensures that estimates of treatment effects are free from systematic bias; blocking controls for known nuisance variables; factorial designs such as 2² and 2³ allow simultaneous estimation of multiple main effects and interaction effects, far more efficient than one-factor-at-a-time experimentation.

## Student's t-Distribution (Gosset, 1908)

> When the sample size n is small and the population standard deviation is unknown:
> t = (X̄ - μ) / (S/√n), which follows a t(n-1) distribution.

**Meaning**: Small samples cannot be approximated directly by the normal distribution — the t-distribution has heavier tails, reflecting the additional uncertainty from estimating the standard deviation itself.

**Mathematical background**: William Sealy Gosset published this result under the pen name "Student" in 1908. He worked at the Guinness brewery and could not use his real name due to confidentiality requirements. The t-distribution is the ratio of a standard normal to √(χ²/(n-1)), and converges to the normal distribution as n→∞. Fisher (1925) provided a rigorous proof and generalized the result.

## Chi-Squared Test (Karl Pearson, 1900)

> χ² = Σ(Oₖ - Eₖ)² / Eₖ, which approximately follows a χ²(k-1-p) distribution under the null hypothesis.

**Meaning**: Does the discrepancy between observed and expected frequencies exceed what can be explained by random fluctuation?

**Mathematical background**: Karl Pearson proposed the goodness-of-fit test in 1900, the first formal statistical test. The degrees-of-freedom correction to k-1-p (where k is the number of categories and p is the number of estimated parameters) was completed by Fisher (1922). The χ² test is widely used in contingency table independence testing, distribution fitting, and related areas.

## Regression and Least Squares (Legendre 1805, Gauss 1809)

> min Σ(yₖ - (a + bxₖ))² → least squares estimate β̂ = (X'X)⁻¹X'y

**Meaning**: Among all fitted lines, least squares minimizes the sum of squared residuals; under the assumption of normal errors, it is equivalent to maximum likelihood estimation.

**Mathematical background**: Legendre (1805) was the first to publish the method of least squares; Gauss (1809) claimed to have used the method as early as 1795 and provided a probabilistic argument under the normal error assumption. The term "regression" was coined by Galton (1886) in his study of the intergenerational regression of height. The modern linear regression model Y = Xβ + ε is the core framework of statistical modeling.

## Markov Chains (Markov, 1906)

> P(Xₙ₊₁ = j | Xₙ = i, Xₙ₋₁, ...) = P(Xₙ₊₁ = j | Xₙ = i)
>
> The future depends only on the present, not on the past — the memoryless property.

**Meaning**: Many real-world processes have the property that "the current state determines the future trajectory," and historical details can be disregarded.

**Mathematical background**: Andrey Markov (1906) first defined Markov chains by studying vowel/consonant sequences in Pushkin's *Eugene Onegin*. The ergodic theorem guarantees that for an irreducible, aperiodic, positive recurrent chain, π(j) = lim P(Xₙ = j) exists and is the unique stationary distribution. Markov chains are the theoretical foundation of MCMC (Metropolis 1943, Hastings 1970, Gelfand-Smith 1990) and also underpin Google PageRank (Brin-Page 1998).

## Stochastic Processes (Brownian Motion, Wiener Process)

> W(t) satisfies: (1) W(0)=0, (2) W(t)-W(s) ~ N(0, t-s), (3) independent increments, (4) continuous paths

**Meaning**: Brownian motion is the macroscopic mathematical model of microscopic random fluctuations — from pollen motion to stock price fluctuations.

**Mathematical background**: Brown (1827) observed the irregular motion of pollen particles; Bachelier (1900) was the first to use it to model stock prices; Wiener (1923) gave the rigorous mathematical construction. Itô (1944) developed stochastic integration dX = μdt + σdW and Itô's formula, which became the theoretical foundation of financial mathematics (Black-Scholes 1973) and stochastic differential equations.

## Shannon Information Theory (1948)

> H(X) = -Σ p(x) log p(x) — entropy, the measure of uncertainty of a random variable
> I(X;Y) = H(X) - H(X|Y) — mutual information, the amount of information Y provides about X
> C = max I(X;Y) — channel capacity, the upper bound on the rate of reliable communication

**Meaning**: Information can be quantified; the fundamental limits of communication are determined by mathematical laws, not by engineering technology.

**Mathematical background**: Claude Shannon founded information theory in "A Mathematical Theory of Communication" (1948). The source coding theorem: average code length ≥ H(X); the channel coding theorem: when the transmission rate R < C, reliable coding schemes exist. The deep connection between entropy and probability — H(X) = -E[log p(X)] — makes information theory a natural extension of probability theory.

## Pearl's Causal Inference (2000)

> The causal hierarchy:
> 1. Association P(y|x) — seeing
> 2. Intervention P(y|do(x)) — doing
> 3. Counterfactual P(yₓ|x', y') — imagining

**Meaning**: Causality is not a strengthened version of association — "do(x)" and "observe x" are mathematically distinct.

**Mathematical background**: In *Causality* (2000), Judea Pearl systematized causal inference using directed acyclic graphs (DAGs) and the do-calculus. The three rules of the do-calculus allow transformation of interventional probabilities among observable variables; the front-door and back-door criteria specify conditions under which causal effects can be computed from observational data. Causal inference answers "what would happen to y if I did x," which goes beyond the expressive power of probability theory alone.

## Bootstrap (Efron, 1979)

> Resample with replacement from X₁,...,Xₙ a total of B times to obtain B bootstrap samples;
> use the bootstrap distribution to approximate the true distribution.

**Meaning**: When theoretical derivation is difficult, use the data itself to simulate the sampling process — "validate yourself with yourself."

**Mathematical background**: Bradley Efron (1979) proposed the bootstrap; its theoretical guarantees were established by Bickel-Freedman (1981) and Singh (1981): under mild conditions, the bootstrap distribution converges uniformly to the true sampling distribution. The bootstrap can estimate standard errors, confidence intervals (percentile method / BCa method), p-values, and more, making it a general-purpose tool for nonparametric inference.

## Bayesian vs Frequentist Debate

> Bayesian: Probability is degree of belief; parameter θ is a random variable → P(θ|data)
> Frequentist: Probability is long-run frequency; parameter θ is a fixed unknown constant → sampling distribution of the estimator θ̂

**Meaning**: This is not a technical disagreement but a philosophical one about "what probability is."

**Core comparison**:
- Bayesian: Prior + Likelihood → Posterior; naturally suited to sequential updating and small samples
- Frequentist: Unbiasedness, consistency, power; naturally suited to large-scale repeatable experiments
- In practice: Bayesian methods dominate in machine learning and causal inference; frequentist methods dominate in clinical trials and quality control

**Mathematical background**: The debate has continued from Laplace vs Fisher to the present day. Jeffreys (1939) proposed the non-informative prior p(θ) ∝ |I(θ)|^(1/2); de Finetti (1937) proved that coherence of subjective probability is equivalent to additivity; Bernardo-Smith (1994) developed reference prior theory.

## Monty Hall Problem

> Three doors, one with a prize. You choose one; the host opens another, revealing it to be empty.
> Question: Should you switch doors? Answer: switching wins with probability 2/3; staying wins with probability 1/3.

**Meaning**: Intuition fails here — the host's action conveys information (he avoids opening the door with the prize).

**Mathematical background**: This problem is an excellent introduction to Bayesian thinking. By Bayes' theorem: P(prize behind remaining door | host opened empty door) = 2/3, because the host selectively avoids the prize, which is itself information. Analogous structures appear in medical diagnosis and legal reasoning — "selective observation" alters probabilities.

## Common Statistical Fallacies and Cognitive Biases

**Survivorship Bias**:
During World War II, the military analyzed bullet-hole distributions on returning aircraft and found the most holes on the wings, recommending reinforcement of the wings. Statistician Abraham Wald pointed out: the areas without bullet holes should be reinforced — because the planes hit in those areas never came back. Wald's insight is essentially about conditional probability: the observed data are conditioned on "the aircraft returned," not the full data set.

**Base Rate Neglect**:
A rare disease has a prevalence of 0.1%, and the diagnostic test has 99% accuracy. If you test positive, what is the probability you actually have the disease?
- Intuitive answer: 99%
- Bayesian calculation: P(disease|positive) = 0.99 × 0.001 / (0.99 × 0.001 + 0.01 × 0.999) ≈ 9%
- The prior probability (base rate) is severely underestimated by intuition

**Regression to the Mean**:
Individuals who perform exceptionally well tend to be closer to average on the next measurement, not because of "declining ability" but because extreme performance is partly due to luck. Galton (1886) found that children of tall parents tend to be shorter than their parents — this is not "degeneration" but a statistical law.

## The Value of Probabilistic Thinking in Everyday Life

> "The core of probabilistic thinking is not computing exact probabilities, but cultivating the habit of 'thinking under uncertainty.'"

- Don't be swayed by a single anecdote — consider the base rate
- Update your beliefs when new information arrives — Bayesian updating
- Distinguish signal from noise — the law of large numbers
- Be wary of extreme values — regression to the mean
- Distinguish "seeing" from "doing" — the causal hierarchy (Pearl)
- Quantify uncertainty — entropy and information (Shannon)