"""Small CPU experiment for an input-injected contractive trainable state module.

Only NumPy and Matplotlib are required. Results concern this synthetic instance;
the exact-arithmetic theorem is separate from floating-point measurements.
"""
from pathlib import Path
import csv
import json
import os
import platform
import time

OUT = Path(__file__).resolve().parent
os.environ.setdefault("MPLCONFIGDIR", str(OUT / ".mplconfig"))
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

SEED = 20260907
Q = 0.8
ETA = 0.25
D = 3
EPS = 1e-8
UNROLL = 60
EPOCHS = 400
rng = np.random.default_rng(SEED)


def project_spectral(M, radius):
    u, s, vt = np.linalg.svd(M, full_matrices=False)
    return (u * np.minimum(s, radius)) @ vt


def forward(A, B, x, steps=UNROLL, keep=False):
    z = np.zeros_like(x)
    drive = x @ B.T
    states, activations = [z], []
    for _ in range(steps):
        activation = np.tanh(z @ A.T)
        z = activation + drive
        if keep:
            states.append(z)
            activations.append(activation)
    return (z, states, activations) if keep else z


def loss_and_grad(A, B, x, y):
    pred, states, acts = forward(A, B, x, keep=True)
    loss = np.mean((pred - y) ** 2)
    grad_z = 2 * (pred - y) / pred.size
    grad_A, grad_B = np.zeros_like(A), np.zeros_like(B)
    for i in reversed(range(UNROLL)):
        grad_B += grad_z.T @ x
        grad_pre = grad_z * (1 - acts[i] ** 2)
        grad_A += grad_pre.T @ states[i]
        grad_z = grad_pre @ A
    return float(loss), grad_A, grad_B


def finite_difference_check(A, B, x, y):
    _, ga, gb = loss_and_grad(A, B, x, y)
    errors = []
    for matrix, expected in ((A, ga), (B, gb)):
        for index in np.ndindex(matrix.shape):
            old = matrix[index]
            step = 1e-6
            matrix[index] = old + step
            plus = np.mean((forward(A, B, x) - y) ** 2)
            matrix[index] = old - step
            minus = np.mean((forward(A, B, x) - y) ** 2)
            matrix[index] = old
            errors.append(abs((plus - minus) / (2 * step) - expected[index]))
    return float(max(errors))


def root_newton(A, B, x):
    """Independent high-accuracy root estimate, checked by equation residual."""
    z = np.zeros(D, dtype=np.float64)
    for _ in range(100):
        t = np.tanh(A @ z)
        residual = z - t - B @ x
        if np.linalg.norm(residual) < 1e-14:
            return z
        jac = np.eye(D) - (1 - t * t)[:, None] * A
        z = z - np.linalg.solve(jac, residual)
    raise RuntimeError("Newton reference failed its residual check")


def adaptive(A, B, x, tolerance=EPS, max_steps=1000, initial=None):
    z = np.zeros(D) if initial is None else initial.copy()
    drive = B @ x
    trace = []
    for n in range(1, max_steps + 1):
        z_new = np.tanh(A @ z) + drive
        delta = float(np.linalg.norm(z_new - z))
        posterior_bound = Q * delta / (1 - Q)
        trace.append((n, z_new.copy(), posterior_bound))
        z = z_new
        if posterior_bound <= tolerance:
            return z, n, posterior_bound, True, trace
    return z, max_steps, posterior_bound, False, trace


def write_csv(name, rows):
    with (OUT / name).open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def main():
    started = time.perf_counter()
    x_train = rng.uniform(-1.5, 1.5, (128, D))
    x_test = rng.uniform(-1.5, 1.5, (128, D))
    target = lambda x: 1.1 * x + 0.2 * np.sin(x) + 0.03 * np.roll(x, 1, axis=1)
    y_train, y_test = target(x_train), target(x_test)
    A = project_spectral(0.65 * np.eye(D) + 0.03 * rng.normal(size=(D, D)), Q)
    B = np.eye(D)
    fd_error = finite_difference_check(A.copy(), B.copy(), x_train[:8], y_train[:8])
    assert fd_error < 1e-7, ("gradient check", fd_error)
    history = []
    initial_test_mse = float(np.mean((forward(A, B, x_test) - y_test) ** 2))
    for epoch in range(EPOCHS + 1):
        loss, ga, gb = loss_and_grad(A, B, x_train, y_train)
        if epoch % 10 == 0:
            history.append({"epoch": epoch, "train_mse": loss,
                            "test_mse": float(np.mean((forward(A, B, x_test) - y_test) ** 2)),
                            "A_norm": float(np.linalg.norm(A, 2)),
                            "B_sigma_min": float(np.linalg.svd(B, compute_uv=False)[-1])})
        if epoch == EPOCHS:
            break
        A = project_spectral(A - 0.1 * ga, Q)
        B = np.eye(D) + project_spectral(B - 0.1 * gb - np.eye(D), ETA)
        assert np.linalg.norm(A, 2) <= Q + 1e-12
        assert np.linalg.svd(B, compute_uv=False)[-1] >= 1 - ETA - 1e-12
    write_csv("training.csv", history)
    np.savez(OUT / "trained_parameters.npz", A=A, B=B)

    # Include multiple scales and exact zero; no claim that norm equals semantic difficulty.
    probes = [("zero", np.zeros(D)),
              ("small", np.array([0.01, -0.02, 0.03])),
              ("medium", np.array([0.4, -0.3, 0.2])),
              ("large", np.array([2.0, -1.5, 1.0]))]
    probes += [(f"heldout_{i}", x) for i, x in enumerate(x_test)]
    rows, trace_rows, fixed_points, input_points = [], [], [], []
    largest_ratio = 0.
    max_reference_bound = 0.
    max_multistart_spread = 0.
    for name, x in probes:
        root = root_newton(A, B, x)
        root_residual = float(np.linalg.norm(np.tanh(A @ root) + B @ x - root))
        max_reference_bound = max(max_reference_bound, root_residual / (1 - Q))
        z, steps, bound, converged, trace = adaptive(A, B, x)
        actual_error = float(np.linalg.norm(z - root))
        assert converged
        assert actual_error <= bound + 2e-13
        assert actual_error <= EPS + 2e-13
        prior_error = np.linalg.norm(root)
        for step, value, upper in trace:
            err = float(np.linalg.norm(value - root))
            if prior_error > 1e-11:
                ratio = err / prior_error
                largest_ratio = max(largest_ratio, ratio)
                assert ratio <= Q + 1e-4
            prior_error = err
            if name in {"small", "medium", "large"}:
                trace_rows.append({"input": name, "step": step,
                                   "error_to_newton_reference": err, "posterior_bound": upper})
        for init in [np.ones(D) * 5, np.ones(D) * -5]:
            alt, _, _, ok, _ = adaptive(A, B, x, initial=init)
            assert ok
            spread = float(np.linalg.norm(alt - z))
            max_multistart_spread = max(max_multistart_spread, spread)
            assert spread <= 2 * EPS + 2e-13
        rows.append({"input": name, "x_norm": float(np.linalg.norm(x)),
                     "steps": steps, "posterior_bound": bound,
                     "error_to_newton_reference": actual_error,
                     "reference_residual": root_residual, "converged": converged})
        fixed_points.append(root)
        input_points.append(x)
    write_csv("stopping.csv", rows)
    write_csv("traces.csv", trace_rows)
    min_separation_ratio = float("inf")
    for i in range(len(probes)):
        for j in range(i):
            dx = np.linalg.norm(input_points[i] - input_points[j])
            if dx > 1e-12:
                ratio = np.linalg.norm(fixed_points[i] - fixed_points[j]) / dx
                min_separation_ratio = min(min_separation_ratio, float(ratio))
    separation_lower = (1 - ETA) / (1 + Q)
    assert min_separation_ratio >= separation_lower - 1e-11

    # Failure 1: retain contraction but remove per-step input injection.
    collapse = []
    for _, x in probes:
        z = x.copy()  # Merely using x for initialization does not preserve it.
        for _ in range(300):
            z = np.tanh(A @ z)
        collapse.append(z)
    collapse_max_norm = float(np.max(np.linalg.norm(collapse, axis=1)))
    assert collapse_max_norm < 1e-12

    # Failure 2: fixed point exists, but the iteration is not contractive.
    bad_x = np.array([0.3, -0.2, 0.1])
    bad_root = -bad_x / 0.05
    z = np.zeros(D)
    divergent_errors = []
    bad_converged = False
    for _ in range(200):
        new = 1.05 * z + bad_x
        if np.linalg.norm(new - z) <= EPS:
            bad_converged = True
        z = new
        divergent_errors.append(float(np.linalg.norm(z - bad_root)))
    assert not bad_converged
    assert divergent_errors[-1] > 1e4 * divergent_errors[0]

    fig, axs = plt.subplots(1, 3, figsize=(12, 3.6), constrained_layout=True)
    for name in ["small", "medium", "large"]:
        tr = [v for v in trace_rows if v["input"] == name]
        axs[0].semilogy([v["step"] for v in tr],
                        [max(v["error_to_newton_reference"], 1e-17) for v in tr], label=name)
    axs[0].axhline(EPS, color="black", ls=":", lw=1, label="tolerance")
    axs[0].set(xlabel="Iteration", ylabel="Error to Newton reference",
               title="Contractive iteration")
    axs[0].legend(fontsize=8)
    axs[1].semilogy([v["epoch"] for v in history], [v["train_mse"] for v in history], label="train")
    axs[1].semilogy([v["epoch"] for v in history], [v["test_mse"] for v in history], label="held out")
    axs[1].set(xlabel="Projected gradient step", ylabel="MSE", title="Synthetic regression")
    axs[1].legend(fontsize=8)
    axs[2].semilogy(range(1, 201), divergent_errors, color="#b23a32")
    axs[2].set(xlabel="Iteration", ylabel="Error to known fixed point",
               title="Failure: gain 1.05")
    fig.savefig(OUT / "convergence.png", dpi=180)
    plt.close(fig)
    summary = {
        "seed": SEED, "python": platform.python_version(), "numpy": np.__version__,
        "device": "CPU", "dtype": "float64", "dimension": D, "q": Q, "eta": ETA,
        "train_samples": len(x_train), "heldout_samples": len(x_test), "epochs": EPOCHS,
        "training_unroll": UNROLL, "gradient_max_absolute_error": fd_error,
        "initial_test_mse": initial_test_mse, "final_test_mse": history[-1]["test_mse"],
        "final_train_mse": history[-1]["train_mse"],
        "A_norm": float(np.linalg.norm(A, 2)),
        "B_sigma_min": float(np.linalg.svd(B, compute_uv=False)[-1]),
        "tolerance": EPS, "probe_count": len(probes),
        "all_converged": all(r["converged"] for r in rows),
        "steps_min": min(r["steps"] for r in rows),
        "steps_median": float(np.median([r["steps"] for r in rows])),
        "steps_max": max(r["steps"] for r in rows),
        "max_actual_stop_error": max(r["error_to_newton_reference"] for r in rows),
        "max_reported_bound": max(r["posterior_bound"] for r in rows),
        "max_reference_error_bound_from_residual": max_reference_bound,
        "max_empirical_contraction_ratio_above_noise_floor": largest_ratio,
        "max_multistart_spread": max_multistart_spread,
        "min_fixed_point_separation_ratio": min_separation_ratio,
        "theoretical_separation_lower_bound": separation_lower,
        "failure_no_input_max_final_norm": collapse_max_norm,
        "failure_gain_1_05_converged": bad_converged,
        "failure_gain_1_05_final_error": divergent_errors[-1],
        "failure_gain_1_05_error_growth": divergent_errors[-1] / divergent_errors[0],
        "elapsed_seconds": time.perf_counter() - started,
        "representative_probes": rows[:4],
        "assertions": "passed"
    }
    (OUT / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
