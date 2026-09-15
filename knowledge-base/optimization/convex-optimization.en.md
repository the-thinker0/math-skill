# Convex Optimization

## Minimal Definition

Minimize a convex function over a convex set: every local minimum is global, but existence and uniqueness need additional assumptions. For an unconstrained differentiable problem, $\nabla f(x^*)=0$ characterizes a minimizer. For a constrained convex problem, $0\in\partial(f+\delta_C)(x^*)$ is exact; writing the sum $\partial f+N_C$ needs a subdifferential sum rule. KKT necessity requires constraint qualifications; KKT sufficiency follows from convexity. Polynomial-time guarantees also depend on representation, oracle access, accuracy and conditioning.

## Core Formulas

- Convex set: $\forall x, y \in C, \theta \in [0,1]: \theta x + (1-\theta)y \in C$
- Convex function: $f(\theta x + (1-\theta)y) \leq \theta f(x) + (1-\theta)f(y)$
- First-order condition: $f(y) \geq f(x) + \nabla f(x)^T(y-x)$ (tangent line lies below the function)
- Second-order condition: $\nabla^2 f(x) \succeq 0$ (Hessian is positive semidefinite)
- Standard convex problem form: $\min f(x)$ s.t. $g_i(x) \leq 0$ ($g_i$ convex), $Ax = b$
- Gradient descent rate: for $\mu$-strongly convex, $L$-smooth $f$, full-gradient steps of size $1/L$ yield $f(x_k)-f^*\le(1-\mu/L)^k(f(x_0)-f^*)$. This is an algorithm-and-step-size statement, not a property of every optimizer.
- Semidefinite programming (SDP): $\min \langle C, X \rangle$ s.t. $\langle A_i, X \rangle = b_i, X \succeq 0$

## Applicable Problems

- Linear/logistic regression with convex loss is convex in linear-model parameters; uniqueness requires appropriate strict/strong convexity, and unregularized separable logistic regression may have no finite minimizer.
- Weight decay / regularization: $\|w\|_2^2$ and $\|w\|_1$ are both convex regularizers
- SVM: hinge loss + quadratic regularization = convex problem
- PCA: the maximum eigenvalue problem for the covariance matrix = a special case of SDP
- Gram matrix optimization in kernel methods: SDP constraint $K \succeq 0$

## AI Design Translation

- **Convexity diagnosis of loss functions**: Cross-entropy is convex with respect to logits (softmax + NLL), and MSE is convex with respect to linear outputs. However, once composed with nonlinear layers (ReLU, attention), the overall problem becomes non-convex. Maintaining convexity from the last layer to the loss provides a convergence guarantee when designing losses.
- **Stochastic versus deterministic rates**: SGD rates require unbiased gradients, noise/moment bounds, steps and averaging conventions; deterministic smooth convex GD gives $O(1/T)$ objective error and acceleration can give $O(1/T^2)$. BatchNorm/LayerNorm can alter optimization but do not universally reduce the Hessian condition number.
- **Convex relaxation**: Relaxing a non-convex problem into a convex one. Examples: $\ell_0$ sparsity $\to \ell_1$ (LASSO); matrix rank minimization $\to$ nuclear norm minimization; integer programming $\to$ LP relaxation. Implemented by substituting the regularizer or constraint.
- **Projection onto convex sets**: $\text{proj}_C(x) = \arg\min_{y \in C} \|y - x\|^2$. $\ell_2$-ball projection = $x / \max(1, \|x\|_2/R)$ (elementwise + norm); $\ell_1$-ball projection = soft-thresholding + sort ($O(n\log n)$); box constraints = clamp (elementwise). All are GPU-friendly operations.
- **Mirror descent**: On the probability simplex with negative-entropy mirror map, exponentiated gradient has $x_i^+\propto x_i\exp(-\eta\nabla_i f)$. This is not the generic update for a signed $\ell_1$ ball; specify the domain and mirror map.

## Engineering Feasibility

- **Primary operations**: Gradient computation = backpropagation (matmul chains); projection = elementwise + norm; convex function evaluation = forward pass. Overall isomorphic to the standard training loop.
- **GPU friendliness**: Extremely high. First-order methods for convex optimization (gradient descent, projected gradient, mirror descent) map entirely to GPU operators. Second-order methods (Newton, interior point) are viable at moderate scale ($d < 10000$) via cuSOLVER.
- **Complexity**: Gradient descent per step $O(d)$ (gradient computation $O(\text{model FLOPs})$); projection $O(d)$ to $O(d\log d)$; interior-point methods per step $O(d^3)$.
- **Low precision**: Strong convexity/Lipschitz gradients do not guarantee bf16 accuracy. Finite precision introduces an error floor depending on scale, condition number and stopping tolerance; monitor objective and optimality residuals in fp32/fp64.

## Risks and Failure Conditions

- **False convexity**: A seemingly convex loss becomes non-convex after composition with nonlinearities (e.g., $f(W_2 \sigma(W_1 x))$ is non-convex in $W_1, W_2$). Convexity from the last layer to the loss does not imply global convexity.
- **Weak curvature**: As strong convexity vanishes, the linear-convergence guarantee disappears; the replacement rate depends on smoothness, stochastic noise and algorithm. Adding an $\ell_2$ term ensures strong convexity for a convex base objective, not for an arbitrary nonconvex neural-network objective.
- **SDP cost**: Interior-point cost depends on matrix size, number of constraints, sparsity and required accuracy. Dense problems can be expensive, but there is no universal 500-dimensional infeasibility threshold; compare first-order, low-rank and structured alternatives on the actual problem.
- **Convex relaxation gap**: $\ell_1$ relaxation does not necessarily recover the $\ell_0$ sparse solution (requires RIP conditions); nuclear norm relaxation does not necessarily yield the lowest-rank solution. Relaxation quality depends on problem structure.

## Further References

- Distilled notes: ../../references/books/optimization-ml.en.md (Ch 22 Convex Optimization, Section 22.2 Convex Functions, Section 22.3 Convex Problems, Section 22.4 SDP/LMI)
- Original text: Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 22 (Convex Optimization Problems Section 22.1-22.4)


## Routing Extensions
- If the problem has constraints -> `constrained-optimization.en.md` (constrained convex optimization methods)
- If the objective is non-smooth -> `proximal-method.en.md` (proximal methods for non-smooth parts)

## Extensible Directions
- Self-concordant functions: convergence guarantees for Newton's method
- Interior point methods: polynomial-time methods for large-scale convex optimization
- First-order method convergence rates: optimal convergence rates for gradient descent
- Accelerated methods (Nesterov acceleration): Nesterov momentum and optimal first-order methods
- Online convex optimization: regret analysis for sequential decision-making
- Bandit convex optimization: convex optimization with zeroth-order information
