# 🔗 Causal Lens

> Correlation does not imply causation — but causation can be clarified. The crucial distinction: "how Y behaves when X is observed" is not the same as "what would happen if X were done."

## What Perspective It Offers

This is an "interventionist's" perspective — unsatisfied with observed associations, it asks "if I actively change X, what happens to Y?" Pearl's causal hierarchy divides reasoning into three tiers: association (seeing), intervention (doing), and counterfactuals (imagining), each requiring stronger modeling assumptions. The core of causal inference is not "discovering" causation from data, but encoding assumptions in an explicit causal model (DAG) and then using the do-calculus to reduce interventional effects to observable quantities.

## What Problems It Is Suited to Diagnose

- Distinguishing genuine causal effects from spurious associations in observational data
- Evaluating the effect of interventions, policies, or treatments ("what would happen if X were done")
- Counterfactual reasoning ("what would have happened if A had not been done")
- Modeling the data-generating process for model interpretability or out-of-distribution generalization

## What Problems It Is Not Suited For

- Pure prediction tasks with no causal question — only P(y|x) is needed; association suffices, and causation is superfluous
- Problems where no causal assumptions can be encoded — if a plausible DAG cannot be drawn, no causal conclusions can be reached
- Deterministic systems with no variation — causation is already fully described by the mechanism

## Which Knowledge Domains It Routes To

- Structural causal models (DAG / SCM / do-calculus): the formal framework for encoding causal assumptions and rendering interventional effects observable
- Potential outcomes framework (Neyman-Rubin): definitions and estimation of ATE and individual treatment effects
- Probability and statistics: conditional probability is the foundation of the association tier; causal effects require additional structural assumptions
- Experimental design (RCT / IV / DD): validation tools for causal conclusions — randomization severs confounding paths

## What AI Designs It May Inspire

- DAG builder: encoding causal directions among variables, automatically identifying confounding paths and back-door / front-door conditions
- Interventional effect calculator: back-door adjustment / do-calculus → P(y|do(x)), compared with P(y|x) to quantify confounding bias
- Sensitivity analyzer: E-value / Rosenbaum Gamma to quantify the fragility of conclusions to unobserved confounding

## Reasoning Protocol

1. **Construct a causal DAG**: Identify all variables, draw causal arrows encoding direct-cause assumptions, and verify acyclicity
2. **Identify confounders**: Find all common ancestors of X and Y; distinguish observed from unobserved confounders
3. **Select an identification strategy**: Based on confounder observability, choose back-door / front-door / do-calculus to reduce P(y|do(x)) to observable quantities
4. **Compute the interventional effect**: Apply the adjustment formula; compare with observational P(y|x) to measure confounding bias
5. **Sensitivity analysis**: Quantify how strong an unobserved confounder would need to be to overturn the conclusion (E-value / Rosenbaum Gamma)

## Acceptance Criteria

- The DAG has been constructed with a justification for every arrow; acyclicity has been confirmed
- Confounders have been listed, annotated as observed or unobserved
- P(y|do(x)) has been computed and compared with P(y|x); confounding bias has been quantified
- Counterfactual analysis (if required) states the necessary structural equations
- Sensitivity analysis has been performed and the fragility of conclusions has been quantified
