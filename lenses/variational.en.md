# Variational Lens

> Pursue the best among the feasible under constraints — convexity determines difficulty, duality reveals structure

## What Perspective It Offers

The variational perspective (formerly "Optimization") is a way of viewing "rational decision-making under constraints": any decision problem can be formulated as maximizing or minimizing an objective subject to constraints. The core idea is not to pursue an abstract "best," but to find the optimum within the feasible region. Convexity is the critical watershed — for convex problems, a local optimum is the global optimum; for non-convex problems, one must guard against local traps. Shadow prices (Lagrange multipliers) reveal which constraints truly matter.

## What Problems It Is Suited to Diagnose

- Resource allocation and trade-off decisions — maximizing or minimizing a quantifiable objective under constraints
- Convexity determination — assessing problem difficulty and selecting solution strategies
- Duality structure analysis — when the primal problem is hard, the dual may be more tractable
- Sensitivity analysis — how the optimal solution responds to changes in constraints

## What Problems It Is Not Suited For

- Problems with no clear evaluation criterion — define the objective before optimizing
- Purely executional tasks — there is no room for optimization
- Problems that are inherently qualitative rather than quantitative extrema — model first, then optimize

## Which Knowledge Domains It Routes To

- `optimization/convex-optimization`: Convexity determination, properties of convex sets and functions — determines the difficulty class of the problem
- **optimization**: Solution methods for LP, QP, convex, non-convex, combinatorial, and stochastic optimization
- **matrix-analysis**: Condition numbers, preconditioning, and low-rank approximation — feasibility analysis for second-order methods

## What AI Designs It May Inspire

- **Objective–Constraint Decomposer**: Automatically extracts the objective function, hard and soft constraints, and the feasible region from a problem description
- **Dual-Solution Router**: Detects whether the primal or dual problem is more tractable and selects the optimal solution path
- **Sensitivity Monitor**: Tracks active constraints and shadow prices, triggering re-optimization when constraints change

## Reasoning Protocol

1. **Define the Objective**: Specify what to maximize or minimize; determine convexity (if convex, local = global)
2. **List Constraints**: Distinguish hard from soft constraints, inequality from equality, linear from nonlinear
3. **Classify Problem Type**: LP, QP, convex, non-convex, combinatorial, or stochastic — match to an appropriate solution method
4. **Solve and Verify**: Exploit convexity or employ global search; check feasibility and optimality
5. **Sensitivity Analysis**: Compute shadow prices, identify active constraints, and assess robustness

## Acceptance Criteria

- The objective function and its convexity status have been explicitly annotated
- All constraints (including implicit ones) have been exhaustively listed
- The problem type has been classified and a solution method has been matched
- Sensitivity analysis has been provided (at minimum, active constraints are identified)
- Multi-objective scenarios have been subjected to Pareto analysis
