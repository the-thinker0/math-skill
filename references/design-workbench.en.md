# Construct Mathematical Mechanisms from Research Goals

Use this for new mechanisms, loosely specified research ideas, or problems that do not fit existing prototypes. Conceptual queries and verification of a given formula do not need this resource. The workbench should produce a candidate whose behavior can be explained, expressed as an operator, and checked; mathematical terminology and temporary knowledge cards are intermediate materials.

When the main request is for cross-field mathematical ideas, first use [structural transfer](structural-transfer.en.md) to find a mapping worth developing, then return here. Do not treat the construction moves as a predefined candidate menu.

## Find the distinction that determines the construction

Express the behavior the user wants and the behavior they want to avoid as two concrete situations. For example: “Allow experts to retain real disagreements, while removing coordinate differences in their representations of the same information.” Use this pair to determine:

- **Objects and available information:** Identify the inputs, states, outputs, and decisions, and when each quantity becomes available: during training, before a decision, or after it.
- **The quantity that actually needs to be preserved:** Parameters, state distances, outputs, rankings, task risk, and success probabilities in security experiments are different targets. Express the intended target through a minimal comparison relation.
- **What can change:** Determine which representations, update rules, objectives, solvers, or observation strategies are open to design, and identify the existing model and the user's hard constraints.

Ask only for missing information that would change the construction. If symbols or explicit assumptions allow progress, proceed without first making the user complete a questionnaire. When the user already has a proposal, start from it and locate the parts that actually need to change.

If the goal admits two materially different mathematical formulations, first compare the behavior they imply. Expert disagreement might reflect coordinate transformations of the same latent variable, or incompatible modes of a predictive distribution. The former may call for estimating alignment maps; the latter calls for retaining conditional distributions or decision branches. Construct an input on which the formulations give different answers to clarify the user's intent, or state which interpretation you are adopting and continue. Do not manufacture a second candidate when the goal is already clear.

## Derive an operator from the relation

Read the relevant section of [Construction Moves](construction-moves.en.md) for the current bottleneck, or directly use the mathematical tools the problem requires. These moves help generate mechanisms. Existing `../design-patterns/` provide implementation references without limiting the mechanisms that may be proposed.

1. State the relation between objects: invariance or equivariance, approximation, constraints, iterative equilibrium, an error budget, conditional expectation, or decision cost.
2. Choose mathematical objects that express this relation, then derive an update, objective, solver, or decision rule. Attaching terminology to an ordinary gate, MLP, or regularizer is insufficient.
3. Explain which observable behavior the added structure changes. If removing it leaves the same algorithm, reconsider the contribution rather than rename the method.
4. Combine moves only when their interfaces are compatible: objects and dimensions, information availability over time, constraints, and error definitions must agree. Two theorems that hold separately do not automatically remain valid after composition.

When a required structure is absent from the library, use the Knowledge Gap Protocol to supply the necessary definitions and sources, then return to the derivation. Producing a temporary card does not complete the user's design task.

## Implement the theorem's objects and assumptions

Substitute the current model's tensors, maps, or security experiments for the variables in the theorem. For each assumption that affects the conclusion, determine how it is realized:

| How the assumption is realized | What to specify in the implementation |
|---|---|
| Enforced by construction | How parameterization, projection, shared weights, or access rules guarantee the property, and whether this restricts expressiveness |
| Controlled by solver accuracy | The residual, computable error bound, or stopping criterion, and how the error propagates to the required output |
| Supported only empirically | What is measured, calibration and independent data, and distribution changes; weaken the corresponding conclusion to an assumption or statistical statement |

For example, realize a contractive update map through norm-constrained weights and input injection, then derive a residual-based stopping criterion. A code comment saying “assume contraction” does not establish it. If a decision about whether to perform a computation assumes sufficient current information, implement it using states actually available at that point. A teacher's complete trajectory may supply training labels, but it cannot serve as a free input to the inference-time decision.

Provide enough detail to reproduce the candidate: tensor shapes and axes, the core forward equations, learnable quantities and training signals, the solver or approximation, and the gradient path. An exact solution, a finite number of solver steps, and truncated backpropagation are different objects. State which is used and which conclusion is relinquished. Do not expand already obvious details merely to fill a format.

Pure cryptographic constructions remain centered on security experiments and reductions: what the actual oracles represent, whether the simulator can obtain the required information, and how the bound changes with the assumptions. Do not apply AI or GPU construction moves to them.

## Use a minimal check to make a design decision

If the user requests implementation or verification and local execution is available, create and run a minimal probe for **the current candidate** in the authorized working directory. If the request is only for a concept or an experimental plan, deliver that. Inexpensive numerical checks can support a derivation, but do not independently start training or download large datasets.

Choose a check that distinguishes the candidate from a simple baseline rather than accumulating tests:

- A small object with an analytic solution, to check the formulas and approximation residuals.
- A control that deliberately violates a key assumption, to check whether the mechanism actually depends on it.
- A degenerate-solution control, such as zero outputs, constant states, or uniform routing. A decreasing objective alone does not demonstrate that the task has been solved.

Act on the observations. If the property fails, revise the parameterization, objective, or assumptions and check again. If it holds on the small object, state which local conclusion this supports, then plan the task experiment most likely to distinguish the alternatives. If execution is unavailable, provide a runnable check and explicit decision criteria, and state that it has not been run.

Account for added computation, teacher or offline preprocessing costs, states or bases, solver iterations, and dynamic batching. Before measuring the full model, report only theoretical costs and a measurement plan; fewer operator calls do not establish a latency benefit.

## Deliver and continue the research

Lead with the chosen mechanism and why it resolves the current tension, then provide the necessary derivation, implementation mapping, actual observations or untested assumptions, and the next experiment that could change the decision. Do not expose the workbench's internal steps or complete tables by default.

In follow-up requests, preserve existing objects, established conditions, failed candidates, and measurements; update only what new evidence changes. If a long task already has research notes, update them in place. Otherwise, save a brief state record when the user asks for one; do not create project documentation for a one-off conceptual query.

Combining standard structures does not automatically establish publication novelty. When novelty needs to be assessed, search primary literature and distinguish existing components, the current derivation, and transfers that remain unverified.
