# Research-task trial records

[中文](README.md)

These independent agent trials and actual CPU artifacts were collected during development to inspect usefulness and find improvements. They are not repeated blind evaluations, were not collected through a trusted runtime adapter, and do not count toward a Tier 2 behavioral pass rate. Resource access is self-reported by the executing agents. Test materials are excluded from the npm package.

## Cross-field mathematical exploration

An independent agent received the current skill and the following request, without an expected mathematical route or access to earlier trial answers. The actual request was in Chinese; this is its translation:

> I want to study an online information-fusion module: changing the arrival order of the same observations should leave the final result unchanged; updates must be incremental, without retaining the complete raw history; contradictory observations should not be averaged into an apparently certain conclusion. Find two structurally different research directions from different mathematical fields, explaining their value, key correspondence, and failure cases. Do not start from existing attention or routing templates, and do not write training code yet.

The complete [research answer](runs/transfer-answer.md) and [self-reported resource access](runs/transfer-access.md) are retained for human review. The agent read the main entry and structural-transfer guidance, looked up sources relevant to the task, and did not read design prototypes or the transfer-bridge examples.

The answer proposed two different information semantics:

| Direction | Correspondence and guarantee | Costs and failures |
|---|---|---|
| Four-valued evidence lattice | Two bits represent positive and negative evidence; bitwise OR is commutative, associative, and idempotent; unknown and conflict remain distinct | Fixed proposition vocabulary; erroneous evidence is difficult to retract; does not measure evidence quantity or reliability |
| Joint posterior over truth and source faults | Accumulated log likelihoods over a fixed hypothesis set; order independent under conditional independence and exact arithmetic; retains competing explanations | Model omissions, correlated or repeated data can create false certainty; pruning can reintroduce order dependence; hypothesis sets can be large |

The root agent checked the object mappings, update equations, and distinguishing examples: the routes differ in retained information, duplicate handling, and whether conflict can be resolved. The answer also identifies floating-point summation and fixed-bit memory limitations. It did not run training experiments or establish research novelty.

This observation supports producing concrete ideas beyond the prototype catalog on this problem. It does not establish overall superiority over the previous version or a percentage quality gain. A subsequent evaluation should freeze versions, run both on multiple unseen tasks, and use reviewers unaware of version labels to compare valid transfer, distinctness, and research value. Mentioning a particular mathematical name is not a passing criterion.

## Earlier construction and verification trials

Before the user specified cross-field exploration as the priority, two tasks were also tried: adaptive layer skipping in an autoregressive model, and a trainable iterative state with persistent input and automatic stopping. Files named `baseline` used the **previous maintenance-corrected snapshot**, not the originally published 3.3.7. Files named `after` used an **intermediate construction-workflow revision**, not the final discovery workflow. Versions were not completely frozen, and the full temporary skill copy has been removed; these runs do not support a controlled comparison.

- Maintenance snapshot: [layer-skipping answer](runs/baseline-answer.md), [iteration answer](runs/baseline-iteration.md), [CPU summary](runs/baseline-probe/summary.json). It already addressed caches, information availability, contraction, and failure controls; all 132 probe inputs converged.
- Intermediate construction revision: [layer-skipping answer](runs/after-answer.md), [iteration answer](runs/after-iteration.md), [CPU summary](runs/after-probe/iteration-results.json). It actually trained and checked stopping; all 128 test inputs met the specified residual-bound checks, with additional no-input, noncontractive, and incorrect early-stopping controls.

Both versions performed substantive work. Their dimensions, synthetic targets, tolerances, and training settings differ; comparing MSE, steps, or time cannot establish skill improvement. Neither Transformer training nor GPU timing was performed.

Run the CPU programs from the repository root to reproduce their checks (NumPy required; the first also needs Matplotlib; adjacent experiment artifacts will be overwritten):

```bash
python tests/usability/runs/baseline-probe/probe.py
python tests/usability/runs/after-probe/verify_iteration.py
python tests/usability/runs/after-probe/verify_skip_budget.py
```

The archive preserves original Chinese answers and machine outputs without translating experimental records. Only the execution commands in two answers were changed to current relative paths; old absolute paths in access reports are historical records. Runtime and floating-point trailing digits may change on reruns.
