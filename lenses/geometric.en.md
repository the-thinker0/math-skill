# 🌉 Geometric Lens

> Translate real-world problems into mathematical structures, and explain and predict reality by solving mathematical problems. All models are wrong, but some are useful.

## What Perspective It Offers

This is a "translator's" perspective — converting the chaotic real world into the precise language of mathematics, solving problems in mathematical space, and then translating the results back into reality. Its focus is not on "what the answer is," but rather on "what mathematical structure should be used to describe this problem." Every real-world problem is a round-trip journey from the concrete to the abstract, and back again.

## What Problems It Is Suited to Diagnose

- Translating vague real-world requirements into computable mathematical formulations
- Selecting the bias-variance-optimal model from among multiple candidates
- Assessing whether a given parameterization scheme is genuinely computationally feasible
- Conducting sensitivity analysis on a system to identify which assumptions are most critical

## What Problems It Is Not Suited For

- Problems that cannot be quantified or lack basic data — a model without data is merely speculation
- Situations requiring only qualitative understanding ("what's roughly going on") — modeling would be excessively precise
- Pure logical deduction problems — no translation from reality is needed; reasoning proceeds directly within a formal system

## Which Knowledge Domains It Routes To

- Differential equations / Difference equations: dynamical systems describing causal relationships among variables
- Probabilistic models and statistics: modeling and parameter estimation under uncertainty
- Optimization theory: mathematical foundations for model parameterization and bias-variance trade-offs
- Linear algebra and matrix analysis: low-rank parameterization, condition numbers, compressibility

## What AI Designs It May Produce

- Golden-loop design: reality → mathematics → solution → back-translation → verification, forming a closed feedback loop
- Assumption inventory + sensitivity dashboard: explicitly recording every assumption and annotating its impact on outputs
- Model selection pipeline: automated comparison of candidate models via AIC/BIC/CV to prevent overfitting

## Reasoning Protocol

1. **Define problem boundaries**: What are the system's inputs, outputs, and objectives (prediction / explanation / optimization)?
2. **Document the assumption inventory**: Which factors are important and which can be neglected? What is the real-world justification for each assumption?
3. **Select a mathematical framework**: Match mathematical structures to the phenomena's characteristics (ODE/PDE/graph/probabilistic/optimization); perform dimensional consistency checks
4. **Solve and back-translate**: Obtain analytical solutions / numerical solutions / qualitative analysis; translate mathematical conclusions back into real-world language
5. **Validate and iterate**: Compare against independent data, conduct sensitivity analysis, and annotate the scope of applicability and failure conditions

## Acceptance Criteria

- Every assumption is explicitly documented with a plausibility rating (high / medium / low)
- Dimensional consistency has been verified — both sides of every equation match dimensionally
- A validation plan exists (independent data or experimental comparison)
- The scope of applicability is clearly stated — specifying the conditions under which the model is valid and those under which it fails
- The output includes not only the analytical process but also actionable conclusions
