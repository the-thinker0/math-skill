# Proximal Methods

## Minimal Definition

For non-smooth or non-differentiable objective functions $f(x) = g(x) + h(x)$ ($g$ smooth, $h$ possibly non-differentiable but "simple"), uses the proximal operator $\text{prox}_{\eta h}(v) = \arg\min_x \{h(x) + \frac{1}{2\eta}\|x - v\|^2\}$ in place of the gradient of $h$. Proximal methods encapsulate the non-differentiable part as a closed-form subproblem.

## Core Formulas

- Proximal operator: $\text{prox}_{\eta h}(v) = \arg\min_x \left\{h(x) + \frac{1}{2\eta}\|x - v\|^2\right\}$
- Proximal gradient descent (ISTA): $x_{k+1} = \text{prox}_{\eta h}(x_k - \eta \nabla g(x_k))$
- Accelerated proximal gradient (FISTA): $y_k = x_k + \frac{k-1}{k+2}(x_k - x_{k-1})$, $x_{k+1} = \text{prox}_{\eta h}(y_k - \eta \nabla g(y_k))$, convergence rate $O(1/k^2)$ vs. ISTA's $O(1/k)$
- Soft-thresholding ($\ell_1$ proximal): $\text{prox}_{\eta\|\cdot\|_1}(v)_i = \text{sign}(v_i)\max(|v_i| - \eta, 0)$
- Projection (proximal of indicator function): $\text{prox}_{\eta \delta_\mathcal{C}}(v) = \text{proj}_\mathcal{C}(v)$
- Nuclear norm proximal (singular value soft-thresholding): $\text{prox}_{\eta\|\cdot\|_*}(A) = U(\Sigma - \eta I)_+ V^H$
- Moreau envelope: $h_\eta(v) = \min_x \{h(x) + \frac{1}{2\eta}\|x-v\|^2\}$ (smooth approximation of $h$)
- ADMM splitting: $\min f(x) + g(z)$ s.t. $Ax + Bz = c$, alternating updates of $x, z, u$ (dual variable)

## Applicable Problems

- Sparse training / $\ell_1$ regularization: weight sparsification, feature selection
- Low-rank matrix recovery: nuclear norm regularization (matrix completion, robust PCA)
- Group sparsity / Group Lasso: $\sum_g \|w_g\|_2$ regularization (structured pruning)
- Operator splitting for constrained optimization: ADMM decomposes complex constraints into simple subproblems
- Quantization-aware training: modeling weight quantization as a proximal operator (round + straight-through gradient)

## AI Design Translation

- **Soft-thresholding for sparse training**: $\text{prox}_{\eta\lambda\|\cdot\|_1}(w) = \text{sign}(w) \odot \max(|w| - \eta\lambda, 0)$, implemented as `w.sign() * (w.abs() - eta * lam).clamp(min=0)`, pure elementwise, $O(d)$, zero additional memory. Applying soft-thresholding after each SGD update yields sparse weights.
- **Singular value soft-thresholding for low-rank regularization**: $\text{prox}_{\eta\|\cdot\|_*}(W) = U(\Sigma - \eta)_+ V^H$. Requires SVD; for large matrices, approximate with randomized SVD: first perform randomized SVD to rank $r$, then apply elementwise soft-thresholding to $\Sigma$, and reconstruct. Core operations are matmul chains + elementwise.
- **Group Lasso structured pruning**: $\text{prox}_{\eta\sum_g\|w_g\|_2}(w)_g = w_g \cdot \max(1 - \eta/\|w_g\|_2, 0)$. After grouping by channel/head, each group undergoes independent soft-thresholding (norm + elementwise scale), $O(d)$. Implemented as reshape + norm(dim) + clamp + mul.
- **ADMM for distributed training**: $\min \sum_i f_i(x_i) + g(z)$ s.t. $x_i = z$. Each node independently updates $x_i$ (local SGD), the server updates $z = \text{prox}_{g/\rho}(\bar{x} + u)$ (aggregation + proximal), and $u$ is updated as the dual variable. More communication-efficient than all-reduce (only $x_i$ and $z$ need to be transmitted).
- **Quantization proximal operator**: Models weight quantization as $\text{prox}(w) = \Delta \cdot \text{round}(w/\Delta)$, with backpropagation using the straight-through estimator (STE): $\partial \text{prox}/\partial w \approx 1$. Implemented as `w_q = (w / delta).round() * delta`; the forward pass is elementwise round + mul, the backward pass is identity.

## Engineering Feasibility

- **Primary operations**: Most proximal operators are elementwise (soft-thresholding, clamp, group norm) or matmul + small SVD (nuclear norm). Gradient steps = standard backpropagation.
- **GPU friendliness**: Extremely high. $\ell_1$ proximal = elementwise; group lasso proximal = reshape + norm + scale = elementwise; nuclear norm proximal = matmul + small SVD. FISTA's momentum term is also elementwise. ADMM's communication pattern is compatible with data parallelism.
- **Complexity**: ISTA/FISTA per step = one gradient computation + one proximal operator ($O(d)$ elementwise); nuclear norm proximal = $O(nd^2)$ (reduced to $O(ndk)$ via randomized SVD); ADMM per node = local SGD + $O(d)$ communication.
- **Low precision**: Elementwise proximal operators are stable under bf16 (no delicate numerical operations). SVD-based proximals must be computed in fp32. FISTA's momentum accumulation may lose precision under bf16; storing $y_k$ in fp32 is recommended.

## Risks and Failure Conditions

- **SVD overhead of nuclear norm proximal**: Full SVD of large matrices at every step is $O(n^3)$, infeasible. Solution: (1) randomized SVD approximation; (2) factorize $\|W\|_* = \min_{W=UV^T} \frac{1}{2}(\|U\|_F^2 + \|V\|_F^2)$, converting to smooth optimization over $U, V$, eliminating the need for SVD.
- **FISTA restart issues**: FISTA's $y_k$ sequence may oscillate (non-monotonically), causing actual convergence to be slower than theory predicts. Solution: adaptive restart (reset momentum $t_k = 1$ when $f(x_{k+1}) > f(x_k)$), implemented as a simple if-condition.
- **Sensitivity of ADMM's $\rho$ parameter**: $\rho$ too large causes ill-conditioning of subproblems; $\rho$ too small causes slow dual convergence. Solution: adaptive $\rho$ (automatically adjusted based on the primal/dual residual ratio), updating every several steps as $\rho \leftarrow \rho \cdot \tau$ ($\tau > 1$ if primal residual $>$ dual residual).
- **No closed-form proximal operator**: Not all $h(x)$ have closed-form prox. Complex regularizers (e.g., TV regularization, overlapping group lasso) require inner-loop iterative solvers. Solution: use Dykstra's algorithm to decompose into compositions of simple prox operators, or switch to ADMM splitting.
- **Bias of the straight-through estimator**: The STE gradient for the quantization proximal is biased ($\partial \text{round}/\partial w = 0$ almost everywhere), and long-term training may diverge. Solution: compensate with a learnable scale factor, or use stochastic rounding (noisy quantization).

## Further References

- Distilled notes: references/books/optimization-ml.md (Ch 8 Gradient Methods Section 8.3 Convergence Analysis, Ch 11 Quasi-Newton Section 11.5 BFGS, Ch 24 Constrained Algorithms Section 24.5 Augmented Lagrangian)
- Original text: Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 24 (Constrained Algorithms Section 24.5 Augmented Lagrangian) + Parikh & Boyd, *Proximal Algorithms*, Foundations and Trends in Optimization, 2014


## Routing Extensions
- If the smooth part dominates -> `convex-optimization.md` (convex optimization for smooth parts)
- If the proximal operator corresponds to a constraint -> `constrained-optimization.md` (equivalence of indicator functions and constraints)
- If used for variational loss regularization -> `variational-loss` (design pattern layer for proximal regularization)

## Extensible Directions
- Proximal gradient (ISTA / FISTA): fast proximal methods for L1 regularization
- Douglas-Rachford splitting: optimizing sums of two non-smooth functions
- Primal-dual hybrid gradient (PDHG): first-order methods for saddle point problems
- Alternating minimization: block-wise optimization for block-separable objectives
- Block coordinate descent: block update strategies for high-dimensional problems
- Proximal neural networks: embedding proximal operators into network architecture
