# Convex Optimization

## Minimal Definition

Optimization problems that minimize a convex function over a convex set. Convexity guarantees that a local optimum is also a global optimum, and the first-order condition ($\nabla f = 0$) is both necessary and sufficient. Convex problems are the only class in optimization theory that guarantees global optimality with efficient solvability.

## Core Formulas

- Convex set: $\forall x, y \in C, \theta \in [0,1]: \theta x + (1-\theta)y \in C$
- Convex function: $f(\theta x + (1-\theta)y) \leq \theta f(x) + (1-\theta)f(y)$
- First-order condition: $f(y) \geq f(x) + \nabla f(x)^T(y-x)$ (tangent line lies below the function)
- Second-order condition: $\nabla^2 f(x) \succeq 0$ (Hessian is positive semidefinite)
- Standard convex problem form: $\min f(x)$ s.t. $g_i(x) \leq 0$ ($g_i$ convex), $Ax = b$
- Convergence rate (strongly convex + smooth): $\|x_k - x^*\|^2 \leq (1 - \mu/L)^k \|x_0 - x^*\|^2$, condition number $\kappa = L/\mu$
- Semidefinite programming (SDP): $\min \langle C, X \rangle$ s.t. $\langle A_i, X \rangle = b_i, X \succeq 0$

## Applicable Problems

- Linear/logistic regression: cross-entropy + linear model is a convex problem with a unique global optimum
- Weight decay / regularization: $\|w\|_2^2$ and $\|w\|_1$ are both convex regularizers
- SVM: hinge loss + quadratic regularization = convex problem
- PCA: the maximum eigenvalue problem for the covariance matrix = a special case of SDP
- Gram matrix optimization in kernel methods: SDP constraint $K \succeq 0$

## AI Design Translation

- **Convexity diagnosis of loss functions**: Cross-entropy is convex with respect to logits (softmax + NLL), and MSE is convex with respect to linear outputs. However, once composed with nonlinear layers (ReLU, attention), the overall problem becomes non-convex. Maintaining convexity from the last layer to the loss provides a convergence guarantee when designing losses.
- **Learning rate scheduling and convex optimization convergence rates**: Under strong convexity + smoothness, SGD converges at rate $O(1/T)$; without strong convexity, $O(1/\sqrt{T})$. The condition number $\kappa = L/\mu$ determines convergence speed: the role of BatchNorm / LayerNorm is to reduce $\kappa$ (making the Hessian more isotropic), equivalent to preconditioning. Implemented as standard normalization layers.
- **Convex relaxation**: Relaxing a non-convex problem into a convex one. Examples: $\ell_0$ sparsity $\to \ell_1$ (LASSO); matrix rank minimization $\to$ nuclear norm minimization; integer programming $\to$ LP relaxation. Implemented by substituting the regularizer or constraint.
- **Projection onto convex sets**: $\text{proj}_C(x) = \arg\min_{y \in C} \|y - x\|^2$. $\ell_2$-ball projection = $x / \max(1, \|x\|_2/R)$ (elementwise + norm); $\ell_1$-ball projection = soft-thresholding + sort ($O(n\log n)$); box constraints = clamp (elementwise). All are GPU-friendly operations.
- **Mirror descent**: In non-Euclidean geometries, replaces Euclidean distance with Bregman divergence in gradient updates. For $\ell_1$ constraints (sparse weights), uses exponential gradient $x_{k+1} \propto x_k \exp(-\eta \nabla f)$, implemented as elementwise exp + normalize.

## Engineering Feasibility

- **Primary operations**: Gradient computation = backpropagation (matmul chains); projection = elementwise + norm; convex function evaluation = forward pass. Overall isomorphic to the standard training loop.
- **GPU friendliness**: Extremely high. First-order methods for convex optimization (gradient descent, projected gradient, mirror descent) map entirely to GPU operators. Second-order methods (Newton, interior point) are viable at moderate scale ($d < 10000$) via cuSOLVER.
- **Complexity**: Gradient descent per step $O(d)$ (gradient computation $O(\text{model FLOPs})$); projection $O(d)$ to $O(d\log d)$; interior-point methods per step $O(d^3)$.
- **Low precision**: Strongly convex problems are stable under bf16 (gradients are Lipschitz); when the condition number is large, normalization/preconditioning is needed, otherwise low precision amplifies ill-conditioning.

## Risks and Failure Conditions

- **False convexity**: A seemingly convex loss becomes non-convex after composition with nonlinearities (e.g., $f(W_2 \sigma(W_1 x))$ is non-convex in $W_1, W_2$). Convexity from the last layer to the loss does not imply global convexity.
- **Condition number degradation**: As $\kappa = L/\mu \to \infty$ ($\mu \to 0$, weakly convex or flat directions), the convergence rate degrades to $O(1/\sqrt{T})$. Solution: add $\ell_2$ regularization to make the problem strongly convex ($\mu \geq \lambda$), or use normalization layers to improve $\kappa$.
- **Poor scalability of SDP solvers**: Interior-point SDP solvers have complexity $O(n^6)$ ($n$ being the matrix dimension), becoming infeasible beyond $n = 500$. Large-scale settings require first-order methods (ADMM) or approximate convex relaxations.
- **Convex relaxation gap**: $\ell_1$ relaxation does not necessarily recover the $\ell_0$ sparse solution (requires RIP conditions); nuclear norm relaxation does not necessarily yield the lowest-rank solution. Relaxation quality depends on problem structure.

## Further References

- Distilled notes: references/books/optimization-ml.md (Ch 22 Convex Optimization, Section 22.2 Convex Functions, Section 22.3 Convex Problems, Section 22.4 SDP/LMI)
- Original text: Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 22 (Convex Optimization Problems Section 22.1-22.4)
