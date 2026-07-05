# Probabilistic Lens

> Uncertainty is quantifiable — probability is quantified belief, data is quantified evidence

## What Perspective It Offers

The probabilistic perspective is a way of "making rational decisions under uncertainty": the world is full of uncertainty, and rational decision-making does not mean pursuing certainty but rather making choices that optimize expected value amid uncertainty. Bayesian updating is the core operation — a prior, upon encountering new data, becomes a posterior; the posterior, upon encountering further data, becomes the new prior. A critical distinction must be maintained: statistical significance is not the same as practical significance (p < 0.05 does not mean a large effect), and correlation is not causation (P(Y|X) is not P(Y|do(X))).

## What Problems It Is Suited to Diagnose

- Quantifying uncertainty — probability distributions, confidence intervals, and effect-size estimation
- Bayesian inference — step-by-step belief updating through the prior–likelihood–posterior cycle
- Hypothesis testing and experimental design — significance tests, power analysis, and sample-size planning
- Causal effect estimation — distinguishing statistical association from causal effect

## What Problems It Is Not Suited For

- Deterministic problems — the answer is known or can be obtained by deduction; probabilistic tools are unnecessary
- Extremely small sample sizes (n < 5) with no possibility of increase — report the data itself rather than inferences from it
- Data that is entirely missing or severely corrupted — no meaningful statistical operation can be performed

## Which Knowledge Domains It Routes To

- `probability/entropy`: Kolmogorov axioms, distribution families, and the law of large numbers / CLT — the mathematical foundations of uncertainty
- `probability/kl-divergence`: MLE, hypothesis testing, Bayesian inference, and regression modeling — extracting patterns from data
- causal inference (no KB card yet, use critic): DAGs, the back-door criterion, and do-calculus — the reasoning framework from association to causation

## What AI Designs It May Inspire

- **Belief-Updating Engine**: Implements an automatic chain of Bayesian prior-to-posterior updates
- **Experiment Design Advisor**: Automatically computes the minimum sample size based on effect size and statistical power
- **Causal Identification Module**: Constructs a DAG from variable relationships and identifies back-door paths and adjustment sets

## Reasoning Protocol

1. **Define the Random Phenomenon**: Specify the random variables, sample space, event space, and probability measure
2. **Select a Probabilistic Model**: Choose a distribution based on data type, sample size, and the underlying physical mechanism
3. **Statistical Inference**: Point estimation / MLE, confidence intervals, hypothesis testing, or Bayesian updating
4. **Causal Assessment** (where applicable): Construct a DAG, identify confounders, and apply the back-door criterion
5. **Quantify Uncertainty**: Provide confidence or credible intervals, report effect sizes, and distinguish statistical significance from practical significance

## Acceptance Criteria

- Random variables and distributions have been explicitly defined
- The inference method (frequentist or Bayesian) has been selected with stated rationale
- The meaning of p-values has been correctly understood (not "degree of confidence")
- Correlation and causation have been distinguished, and confounders have been checked
- Effect sizes and uncertainty have been reported, not merely point estimates
