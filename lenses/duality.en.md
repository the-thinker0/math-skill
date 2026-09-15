# Duality Lens

> Change representation, take a dual, or relax — identify whether solutions, bounds, or partial structure are preserved

## What Perspective It Offers

Duality (formerly "Transform") is a way of "looking at a problem through a different representation": the same problem can admit multiple representations, and choosing a good transform can make a difficult problem simple. The essence of a transform is not to change the problem itself, but to change the vantage point from which it is viewed — differentiation becomes multiplication, convolution becomes pointwise multiplication, constrained optimization becomes a dual problem. Invertible transforms, dual problems, and lossy relaxations are distinct tools. Lagrange duality generally supplies bounds; strong duality requires conditions. Neither an inverse nor equivalence can be assumed for every tool.

## What Problems It Is Suited to Diagnose

- A problem is difficult to analyze or solve in its current form — a change of representation space is needed
- Variables are coupled and need decoupling — transform to an independent coordinate system
- Hidden structure needs to be revealed — periodicity invisible in the time domain becomes obvious in the frequency domain
- Finding an equivalent but computationally friendlier representation

## What Problems It Is Not Suited For

- The problem is already simple enough — no transform is needed
- Exact recovery is required but the transform loses essential information — use a recoverable representation or state approximation error
- Convergence conditions are not satisfied — forcing a transform produces meaningless results

## Which Knowledge Domains It Routes To

- `matrix-analysis/spectral-decomposition`: Fourier, Laplace, and Z-transforms — equivalent mappings from the time domain to the frequency domain
- **matrix-analysis**: Spectral decomposition and low-rank approximation — transforms and simplifications in matrix space
- **optimization/lagrangian-duality**: Legendre and Fenchel transforms — conversion from constrained optimization to dual problems

## What AI Designs It May Inspire

- **Difficulty Diagnoser**: Analyzes the type of difficulty in the current representation (computational complexity, unclear structure, variable coupling)
- **Transform Selector**: Matches the most appropriate transform to the diagnosed difficulty type and checks convergence conditions
- **Equivalence Verifier**: Confirms that no information is lost during the forward-transform and inverse-transform round trip

## Reasoning Protocol

1. **Diagnose the Difficulty**: Why is the current representation hard to work with — computational complexity, unclear structure, or variable coupling?
2. **Select a Transform**: Choose a transform based on the difficulty type; specify the formula, domain mapping, and convergence conditions
3. **Execute the Transform**: Map the problem into the new representation space, strictly following the formula
4. **Verify the Region of Convergence**: Before applying transformed results, validate that convergence conditions are satisfied
5. **Return to the Original Problem**: Invert reversible transforms; report feasibility, primal/dual bounds and gap for duality; describe recovery and error for relaxations

## Acceptance Criteria

- The difficulty of the current representation has been clearly diagnosed
- The transform selection is justified with clear reasoning, and convergence conditions have been verified
- The solution or bound is expressed in the original problem; inability to recover a primal solution is explicit
- Equivalence, weak/strong duality, and approximation are distinguished, with domain, convergence, gap, and recovery conditions checked
