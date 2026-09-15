"""An analytic diagnostic, not a Transformer or speed benchmark."""
from pathlib import Path
import json
import numpy as np

out = Path(__file__).resolve().parent
readout = np.diag([1000.0, 1.0])
errors = np.array([[.001, 0.], [0., .001]])
local = np.max(np.abs(errors), axis=1)
output = np.max(np.abs(errors @ readout.T), axis=1)
bound = np.linalg.norm(readout, ord=np.inf) * local
hidden_rule = local <= .002
output_rule = output <= .01
assert np.array_equal(hidden_rule, [True, True])
assert np.array_equal(output_rule, [False, True])
assert np.all(output <= bound + 1e-15)
report = {
    "purpose": "Equal local hidden errors can have different output consequences",
    "local_inf_errors": local.tolist(), "output_inf_errors": output.tolist(),
    "global_lipschitz_bounds": bound.tolist(),
    "hidden_threshold_skip": hidden_rule.tolist(),
    "output_budget_skip": output_rule.tolist(),
    "important_limitation": "Output errors are oracle quantities in this diagnostic. A deployed predictor sees pre-decision state only; this experiment does not validate that predictor.",
    "all_checks_passed": True,
}
(out / "skip-budget-results.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
print(json.dumps(report, indent=2))
