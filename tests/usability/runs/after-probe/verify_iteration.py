"""CPU-only reproducible contraction, stopping, trainability and failure checks.

Only NumPy is needed. Outputs are written beside this script. All vector errors
use infinity norm; rows in data arrays are samples. No downloaded data/model.
"""
from pathlib import Path
import json
import platform
import time
import numpy as np

OUT = Path(__file__).resolve().parent
SEED = 20260907
Q = 0.7
EPS = 1e-6
rng = np.random.default_rng(SEED)


def norminf(a):
    return np.max(np.abs(a), axis=-1)


def constrain(a, q=Q):
    # Feasibility-preserving row rescaling, not a Euclidean projection.
    sums = np.sum(np.abs(a), axis=1, keepdims=True)
    return a / np.maximum(1.0, sums / q)


def update(z, x, a, b, nonlinear=True, inject=True):
    phi = np.tanh(z) if nonlinear else z
    return phi @ a.T + (x if inject else np.zeros_like(x)) + b


def solve(x, a, b, q=Q, eps=EPS, cap=1000,
          nonlinear=True, inject=True, start=None):
    if not 0 <= q < 1:
        raise ValueError("A contraction certificate requires 0 <= q < 1")
    if np.max(np.sum(np.abs(a), axis=1)) > q + 1e-14:
        raise ValueError("The actual matrix violates the claimed contraction")
    z = np.zeros_like(x) if start is None else np.broadcast_to(start, x.shape).copy()
    calls = np.zeros(len(x), dtype=int)
    active = np.ones(len(x), dtype=bool)
    bounds = np.full(len(x), np.inf)
    traces = []
    for _ in range(cap):
        ids = np.flatnonzero(active)
        if not len(ids):
            break
        new = update(z[ids], x[ids], a, b, nonlinear, inject)
        r = norminf(new - z[ids])
        # z is the point whose residual was just evaluated; return THAT z.
        bounds[ids] = r / (1 - q)
        calls[ids] += 1
        done = bounds[ids] <= eps
        active[ids[done]] = False
        z[ids[~done]] = new[~done]
        traces.append(float(np.max(bounds[ids])))
    return z, calls, bounds, ~active, traces


def reference(x, a, b, nonlinear=True):
    if not nonlinear:
        return np.linalg.solve(np.eye(a.shape[0]) - a, (x + b).T).T
    z = np.zeros_like(x)
    for _ in range(10000):
        new = update(z, x, a, b)
        if np.max(np.abs(new - z)) < 2e-15:
            return new
        z = new
    raise RuntimeError("Reference did not converge")


def unroll_loss_grad(x, target, a, b, steps=40):
    states = [np.zeros_like(x)]
    for _ in range(steps):
        states.append(update(states[-1], x, a, b))
    residual = states[-1] - target
    loss = np.mean(residual**2)
    adj = 2 * residual / residual.size
    da = np.zeros_like(a)
    db = np.zeros_like(b)
    for t in range(steps - 1, -1, -1):
        phi = np.tanh(states[t])
        da += adj.T @ phi
        db += np.sum(adj, axis=0)
        adj = (adj @ a) * (1 - phi**2)
    return float(loss), da, db


def main():
    started = time.perf_counter()
    report = {"seed": SEED, "python": platform.python_version(),
              "numpy": np.__version__, "device": "CPU", "norm": "infinity",
              "q": Q, "eps": EPS}
    d = 4
    a_target = np.array([[.28, .13, -.07, .06],
                         [-.1, .30, .14, .06],
                         [.05, -.12, .31, .08],
                         [.11, .06, -.08, .29]])
    b_target = np.array([.13, -.09, .07, -.11])
    x_train = rng.uniform(-1, 1, (256, d))
    x_test = rng.uniform(-1.2, 1.2, (128, d))
    targets = reference(x_train, a_target, b_target)
    test_targets = reference(x_test, a_target, b_target)
    a = constrain(rng.normal(0, .035, (d, d)))
    b = np.zeros(d)

    # Check one coordinate of each manual derivative against independent
    # centered finite differences before running the optimization.
    loss0, da, db = unroll_loss_grad(x_train[:8], targets[:8], a, b)
    h = 1e-6
    ap, am = a.copy(), a.copy()
    ap[1, 2] += h
    am[1, 2] -= h
    fd_a = (unroll_loss_grad(x_train[:8], targets[:8], ap, b)[0]
            - unroll_loss_grad(x_train[:8], targets[:8], am, b)[0]) / (2*h)
    bp, bm = b.copy(), b.copy()
    bp[2] += h
    bm[2] -= h
    fd_b = (unroll_loss_grad(x_train[:8], targets[:8], a, bp)[0]
            - unroll_loss_grad(x_train[:8], targets[:8], a, bm)[0]) / (2*h)
    grad_error = max(abs(fd_a-da[1, 2]), abs(fd_b-db[2]))
    assert grad_error < 1e-7, grad_error
    history = []
    initial_mse = float(np.mean((reference(x_test, a, b)-test_targets)**2))
    for step in range(600):
        loss, da, db = unroll_loss_grad(x_train, targets, a, b)
        a = constrain(a - .12 * da)
        b -= .12 * db
        if step % 50 == 0 or step == 599:
            history.append({"step": step, "train_mse": loss})
    exact = reference(x_test, a, b)
    z, calls, bounds, certified, trace = solve(x_test, a, b)
    errors = norminf(z - exact)
    pair_idx = [(i, j) for i in range(len(x_test)) for j in range(i)]
    ratios = np.array([norminf(z[i]-z[j]) / norminf(x_test[i]-x_test[j])
                       for i, j in pair_idx])
    separation_slack = np.array([
        norminf(z[i]-z[j]) - norminf(x_test[i]-x_test[j])/(1+Q) + 2*EPS
        for i, j in pair_idx])
    assert certified.all()
    assert np.max(errors) <= EPS
    assert np.all(errors <= bounds + 1e-13)
    assert np.min(separation_slack) >= -1e-12
    final_mse = float(np.mean((exact-test_targets)**2))
    assert final_mse < initial_mse / 100
    report["trained_nonlinear"] = {
        "train_samples": len(x_train), "test_samples": len(x_test),
        "dimension": d, "training_steps": 600, "unroll_steps": 40,
        "gradient_finite_difference_abs_error": float(grad_error),
        "initial_test_mse": initial_mse, "final_test_mse": final_mse,
        "actual_matrix_inf_norm": float(np.max(np.sum(np.abs(a), axis=1))),
        "all_certified": bool(certified.all()),
        "max_error_to_high_precision_reference": float(np.max(errors)),
        "max_reported_bound": float(np.max(bounds)),
        "max_error_over_own_bound": float(np.max(errors/bounds)),
        "update_calls_min_median_max": [int(np.min(calls)), float(np.median(calls)), int(np.max(calls))],
        "num_distinct_call_counts": int(len(np.unique(calls))),
        "pairwise_separation_ratio_min": float(np.min(ratios)),
        "theoretical_exact_ratio_lower_bound": 1/(1+Q),
        "min_finite_tolerance_separation_slack": float(np.min(separation_slack)),
        "state_variance_mean": float(np.mean(np.var(z, axis=0))),
        "training_history": history,
        "convergence_max_active_bound_trace": trace,
        "A": a.tolist(), "b": b.tolist(),
    }

    # Exact linear oracle; same actual learned matrix, phi = identity.
    linear_exact = reference(x_test, a, b, nonlinear=False)
    zl, nl, bl, ok, _ = solve(x_test, a, b, nonlinear=False)
    err_l = norminf(zl-linear_exact)
    assert ok.all() and np.all(err_l <= bl+1e-12)
    report["linear_analytic"] = {
        "max_error_to_numpy_solve": float(np.max(err_l)),
        "max_error_over_own_bound": float(np.max(err_l/bl)),
        "all_certified": bool(ok.all()),
        "update_calls_min_median_max": [int(np.min(nl)), float(np.median(nl)), int(np.max(nl))],
    }

    # Different starts must lead to the same equilibrium for EACH fixed x.
    starts = [np.full(d, -20.), np.full(d, 20.), np.arange(d)*10.]
    start_errors = []
    for start in starts:
        zi, _, _, oki, _ = solve(x_test, a, b, start=start)
        assert oki.all()
        start_errors.append(float(np.max(norminf(zi-exact))))
    report["initialization_check"] = {"max_errors": start_errors}

    # Removing the immutable input injection is a perfectly convergent collapse.
    z_bad, n_bad, b_bad, ok_bad, _ = solve(x_test, a, b, inject=False)
    collapse_spread = float(np.max(np.ptp(z_bad, axis=0)))
    assert ok_bad.all() and collapse_spread == 0.0
    report["failure_no_input"] = {
        "all_certified": bool(ok_bad.all()), "state_coordinate_spread": collapse_spread,
        "test_task_mse": float(np.mean((z_bad-test_targets)**2)),
        "max_reported_bound": float(np.max(b_bad)),
    }

    # Breaking contraction in a linear example makes iteration diverge.
    a_bad = 1.05 * np.eye(d)
    x_bad = np.ones((1, d)) * .2
    z_bad = np.zeros_like(x_bad)
    divergence = []
    for step in range(100):
        next_bad = update(z_bad, x_bad, a_bad, np.zeros(d), nonlinear=False)
        divergence.append(float(norminf(next_bad-z_bad)[0]))
        z_bad = next_bad
    rejected = False
    try:
        solve(x_bad, a_bad, np.zeros(d), q=Q, nonlinear=False)
    except ValueError:
        rejected = True
    assert divergence[-1] > divergence[0] * 100 and rejected
    report["failure_no_contraction"] = {
        "matrix_inf_norm": 1.05, "first_residual": divergence[0],
        "residual_after_100_calls": divergence[-1],
        "state_norm_after_100_calls": float(norminf(z_bad)[0]),
        "certificate_routine_rejected_bad_matrix": rejected,
    }

    # Near-one contraction makes raw small-step stopping misleading.
    c = .99
    aa = c * np.eye(d)
    xx = np.array([[.001, 0., 0., 0.]])
    zs, ns, bs, oks, _ = solve(xx, aa, np.zeros(d), q=c, eps=1e-6,
                              cap=2000, nonlinear=False)
    zs_cap, ns_cap, bs_cap, oks_cap, _ = solve(xx, aa, np.zeros(d), q=c,
                                              eps=1e-6, cap=100, nonlinear=False)
    raw_z = np.zeros_like(xx)
    raw_calls = 0
    while True:
        raw_new = update(raw_z, xx, aa, np.zeros(d), nonlinear=False)
        raw_calls += 1
        if norminf(raw_new-raw_z)[0] <= 1e-6:
            break
        raw_z = raw_new
    star = reference(xx, aa, np.zeros(d), nonlinear=False)
    report["near_one_and_cap"] = {
        "q": c, "certified_call_count": int(ns[0]),
        "certified_actual_error": float(norminf(zs-star)[0]),
        "raw_residual_rule_call_count": raw_calls,
        "raw_residual_rule_actual_error": float(norminf(raw_z-star)[0]),
        "cap_100_certified": bool(oks_cap[0]),
        "cap_100_last_evaluated_bound": float(bs_cap[0]),
    }
    assert oks[0] and not oks_cap[0]
    assert norminf(raw_z-star)[0] > EPS * 90
    report["elapsed_seconds"] = time.perf_counter() - started
    report["all_checks_passed"] = True
    (OUT / "iteration-results.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    np.savetxt(OUT / "per-sample-stopping.csv",
               np.column_stack([np.arange(len(x_test)), calls, errors, bounds]),
               delimiter=",", header="sample,update_calls,actual_inf_error,certified_inf_bound",
               comments="", fmt=["%d", "%d", "%.15g", "%.15g"])
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
