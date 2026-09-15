# Multi-turn research: revise candidates using evidence

Read only for continued construction, comparison, or experiment work. The main entry is `../SKILL.en.md`; use the [construction workbench](design-workbench.en.md) when first turning a vague objective into a mechanism. Do not reread it every turn.

## Reuse what is already settled

Recover from the conversation or the user's existing notes: objective and hard constraints, the candidate's core equation, verified conditions, failed counterexamples, and actual measurements. Identify the new fact to address this turn instead of relisting lenses, books, and every candidate.

“Continue,” “this experiment failed,” and “try a different approach” usually advance the existing goal. Reformulate only when the goal or constraints actually change.

## Turn the key uncertainty into one discriminating check

Prefer a check whose result changes the design. For example:

| Current uncertainty | Discriminating check | Resulting design decision |
|---|---|---|
| Does a consistency objective collapse representations to a constant? | Compare constant and input-preserving solutions on small data, checking both objective and task information | If the constant wins, change the constraint/data term and compare again |
| Does a downstream operator amplify approximation error? | Hold local error magnitude fixed and change downstream sensitive directions | If amplification matters, use output-related error or reallocate the budget |
| Is random residual correction worth computing? | Compare pure approximation, direct sampling, and residual correction at equal total cost | If residuals are less stable, change the baseline or reject the combination |
| Can an iterative state stop reliably? | Compare against an analytic solution and residual threshold, then break contraction | If the condition fails, change the parameterization or withdraw that stopping guarantee |

When implementation/verification is requested and execution is available, write and run a small probe for the current candidate. Record command, inputs, observations, and the decision. Revise a failed component and rerun the relevant check; do not simply repeat a future experiment plan. Without the needed data or compute, provide runnable code and decision criteria and identify what was not executed.

## Act on the result

- **Property refuted:** retain the counterexample; change the assumption, parameterization, or objective instead of moving thresholds until the test passes.
- **Property supported only on small objects:** record the scope, then move to independent data and the real implementation. Finite checks are not universal proofs.
- **Quality holds but resource benefit does not:** measure preprocessing, forward/backward or prefill/decode, stored state, and dynamic batching separately; decide whether to retain the mechanism or simplify its implementation.
- **User acceptance criteria met:** deliver the final design and evidence, and stop unnecessary candidate expansion.

Correct definitions, valid derivations, finite numerical support, and measured task benefit are distinct evidence states. Preserve “planned,” “not run,” and “failed” labels rather than upgrading them to success.

## Minimal state when a record is needed

Prefer the user's existing research record. When saving is requested or the task already maintains experiment files, keep the following information without requiring a new table or directory:

> Objective/constraints → current candidate and core equation → conditions and sources → executed checks and results → rejected paths and reasons → next decision-changing check.

Process only changes to that state next turn. Verify primary sources when new methods, exact constants, or novelty are at issue. Verifying one theorem does not verify the entire transfer.
