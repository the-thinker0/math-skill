# Perturbation Lens

> Propagation of small perturbations, stability, and robustness — a system's sensitivity to tiny changes determines its reliability

## What This Perspective Is

This is a "stress-tester's" perspective — for any mathematical object or system design, ask: "If the input, parameters, or structure undergo a small change, how much does the output shift? Is the shift controllable?" The core conviction: a well-posed system's response to perturbation should be bounded and predictable; if a design collapses under infinitesimal perturbation, it is destined to fail in practice. The condition number is the precise measure of perturbation amplification.

## Problems It Diagnoses Well

- Robustness analysis of models against input noise or adversarial perturbations
- Small parameter changes causing solution jumps in optimization — is the problem ill-conditioned?
- Stability of eigenvalues and eigenvectors under matrix perturbation (Davis-Kahan theorem)
- Identifying regular vs. singular perturbations in asymptotic expansions
- Error propagation and condition number analysis in numerical algorithms

## Problems It Doesn't Fit

- Problems where the perturbation itself is the object of study (e.g., butterfly effect in chaotic systems is a feature, not a defect)
- Large-deformation or global structural analysis — perturbation theory only concerns local neighborhoods
- Discrete combinatorial problems — perturbation theory relies on continuity assumptions

## Knowledge Domains It Routes To

- **matrix-analysis/matrix-perturbation**: Weyl's inequality, Davis-Kahan theorem, perturbation bounds for eigenvalues and singular values
- **optimization/constrained-optimization**: Stability of KKT conditions, sensitivity of optimal solutions to perturbation
- **probability/concentration-inequality**: Concentration phenomena under random perturbation, sub-Gaussian tail bounds
- **differential-geometry/curvature**: Curvature as a measure of geodesic deviation — perturbation amplification in geometric terms

## AI Designs It May Inspire

- **Perturbation Regularization**: Add input or weight perturbation terms to the loss to train models insensitive to small changes
- **Condition Number Monitor**: Track the condition number of weight matrices or the Hessian in real time to warn of ill-conditioning
- **Robustness Verification Layer**: Quantify maximum output shift using epsilon-delta bounds, providing formal robustness guarantees
- **Adaptive Preconditioning**: Dynamically adjust optimizer step size based on the perturbation amplification factor

## Reasoning Protocol

1. **Identify the perturbation source**: Does the perturbation occur in the input, parameters, or structure? What is its magnitude epsilon?
2. **Compute sensitivity**: Derive the Jacobian or condition number — the ratio of output shift Delta to perturbation epsilon
3. **Classify the perturbation**: Regular perturbation (expansion converges order by order) vs. singular perturbation (leading-order term changes)
4. **Establish perturbation bounds**: Use known theorems (Weyl, Davis-Kahan, Lipschitz constants) to provide rigorous upper bounds
5. **Assess robustness**: Is the perturbation amplification within acceptable range? If not, what regularization is needed?

## Acceptance Criteria

- The perturbation source and its magnitude epsilon are clearly defined
- Sensitivity or condition number has been computed or estimated
- The perturbation type has been classified (regular or singular)
- The output shift has a quantified upper bound (not merely a heuristic estimate)
- The robustness conclusion is actionable — pass, fail, or specification of required regularization
