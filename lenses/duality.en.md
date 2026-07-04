# 🔄 Duality Lens

> A hard problem is equivalent to an easy problem — the key is finding the right transform and its inverse

## What Perspective It Offers

Duality (formerly "Transform") is a way of "looking at a problem through a different representation": the same problem can admit multiple representations, and choosing a good transform can make a difficult problem simple. The essence of a transform is not to change the problem itself, but to change the vantage point from which it is viewed — differentiation becomes multiplication, convolution becomes pointwise multiplication, constrained optimization becomes a dual problem. But every transform must have an inverse: a transform without an inverse is evasion, not a solution.

## What Problems It Is Suited to Diagnose

- A problem is difficult to analyze or solve in its current form — a change of representation space is needed
- Variables are coupled and need decoupling — transform to an independent coordinate system
- Hidden structure needs to be revealed — periodicity invisible in the time domain becomes obvious in the frequency domain
- Finding an equivalent but computationally friendlier representation

## What Problems It Is Not Suited For

- The problem is already simple enough — no transform is needed
- The transform discards critical information and is not invertible — choose an information-preserving transform
- Convergence conditions are not satisfied — forcing a transform produces meaningless results

## Which Knowledge Domains It Routes To

- `matrix-analysis/spectral-decomposition`: Fourier, Laplace, and Z-transforms — equivalent mappings from the time domain to the frequency domain
- **matrix-analysis**: Spectral decomposition and low-rank approximation — transforms and simplifications in matrix space
- **optimization/duality**: Legendre and Fenchel transforms — conversion from constrained optimization to dual problems

## What AI Designs It May Inspire

- **Difficulty Diagnoser**: Analyzes the type of difficulty in the current representation (computational complexity, unclear structure, variable coupling)
- **Transform Selector**: Matches the most appropriate transform to the diagnosed difficulty type and checks convergence conditions
- **Equivalence Verifier**: Confirms that no information is lost during the forward-transform and inverse-transform round trip

## Reasoning Protocol

1. **Diagnose the Difficulty**: Why is the current representation hard to work with — computational complexity, unclear structure, or variable coupling?
2. **Select a Transform**: Choose a transform based on the difficulty type; specify the formula, domain mapping, and convergence conditions
3. **Execute the Transform**: Map the problem into the new representation space, strictly following the formula
4. **Verify the Region of Convergence**: Before applying transformed results, validate that convergence conditions are satisfied
5. **Inverse-Transform Back to the Original Space**: Translate the solution back into the language of the original problem and verify equivalence

## Acceptance Criteria

- The difficulty of the current representation has been clearly diagnosed
- The transform selection is justified with clear reasoning, and convergence conditions have been verified
- The inverse transform has been executed and the solution has been returned to the original space
- Equivalence has been verified: no information loss, correct region of convergence, and correct encoding of boundary conditions
