# Composable Mathematical Construction Moves

Read the relevant section only when the [design workbench](design-workbench.en.md) calls for a mechanism. These moves derive operators from equations or conditions; they are not five fixed models and make no claim of novelty. For purely cryptographic constructions, use the relevant security anchors. The presence of probability or guarantees here is not a reason to apply AI operators to cryptography.

| Practical bottleneck | Move to try first | Interface that must remain explicit |
|---|---|---|
| Many pairwise interactions are repeatedly evaluated | 1. Separate the interaction function | The function being approximated, the query domain, and output error |
| A cheap approximation is available but insufficiently accurate | 2. Add sampled residuals to a cheap baseline | A computable baseline mean and full sampling support |
| Fixed depth cannot express the required solution process | 3. Define a layer through a fixed point with input injection | The state space, contraction condition, and stopping residual |
| A local modification affects a distant output | 4. Allocate error budgets through propagation | The actual state, sources of perturbation, and downstream amplification |
| Whether to continue computing depends on information not yet available | 5. Treat observation as a costly sequential decision | Information available before the decision, transitions, and costs |

## 1. Separate the Interaction Function

**Define the interaction function before compressing it.** For queries $q$, keys $k_j$, and column vectors $v_j\in\mathbb R^{d_v}$, the target is

$$y(q)=\frac1n\sum_{j=1}^n\kappa(q,k_j)v_j.$$

If we construct $\kappa_r(q,k)=\phi(q)^T\psi(k)$, with $\phi,\psi\in\mathbb R^r$, then

$$S=\frac1n\sum_j\psi(k_j)v_j^T\in\mathbb R^{r\times d_v},\qquad y_r(q)=S^T\phi(q).$$

This rearrangement of the sum is exact for the finite feature representation. Approximating $\kappa$ by $\kappa_r$ is a separate issue. If $\sup|\kappa-\kappa_r|\le\epsilon$ on a specified domain and $\|v_j\|\le B$, the triangle inequality directly gives $\|y-y_r\|\le B\epsilon$. The domain must cover the queries encountered at deployment.

**Construct a module from this:** replace token or edge interactions with an accumulated statistic $S$ and query features. Excluding feature computation, building the statistic costs $O(nrd_v)$ and reading out one query costs $O(rd_v)$. For a streaming mean, maintain the unnormalized sum and a count; removing items from a window also requires the corresponding data. Sharing the statistic across multiple queries is what can amortize its construction cost. Changing feature parameters generally requires rebuilding old statistics.

One established feature construction is random Fourier features (RFF). For a continuous, real-valued, shift-invariant PSD kernel on $\mathbb R^d$, normalized so that $\kappa(0)=1$, let $p$ be its Bochner spectral probability distribution. Draw $\omega_\ell\sim p$ and $b_\ell\sim U[0,2\pi]$, and set $\phi_\ell(x)=\sqrt{2/r}\cos(\omega_\ell^Tx+b_\ell)$. The expected feature inner product equals the kernel. This is not a general formula for arbitrary interaction functions, and the expectation identity alone does not provide a uniform approximation bound. [Rahimi–Recht paper](https://proceedings.neurips.cc/paper_files/paper/2007/hash/013a006f03dbc5392effeb8f18fda755-Abstract.html)

**Check first:** agreement between explicit pairwise summation and the factorized implementation; function and output error on independent queries; and queries outside the assumed domain. Ordinary RFF can produce negative similarities, so they cannot be treated directly as probabilities. Normalized attention additionally requires a denominator bounded away from zero and a new error derivation.

## 2. Add Sampled Residuals to a Cheap Baseline

**Spend exact computation on what the approximation fails to explain.** For a finite set of vectors $a_j$ under a fixed input, the target is $\mu=n^{-1}\sum_j a_j$. Construct cheap vectors $b_j$ whose mean $\bar b=n^{-1}\sum_jb_j$ can be computed exactly and cheaply. Draw $J_i\overset{iid}{\sim}p$, with all $p_j>0$:

$$\hat\mu=\bar b+\frac1{mn}\sum_{i=1}^m\frac{a_{J_i}-b_{J_i}}{p_{J_i}}.$$

Conditional on the fixed baseline and input, taking expectations term by term gives $\mathbb E\hat\mu=\mu$. Under uniform sampling, $\operatorname{Cov}(\hat\mu)=\operatorname{Cov}_J(a_J-b_J)/m$. The estimator improves on direct sampling only when the residual covariance is sufficiently small; choosing a baseline coefficient of 1 does not automatically reduce variance. [Owen, Monte Carlo, Section 8.9](https://artowen.su.domains/mc/Ch-var-basic.pdf)

**Construct a module from this:** use separable statistics, a low-rank approximation, or a cheap predictor trained offline to compute the baseline, then evaluate exact residuals only for sampled edges or experts. Account for baseline construction, sample count, exact interactions, and gather operations. If the method still needs access to the original keys or edges, it cannot also claim to eliminate their storage.

**Check first:** enumerate sampling outcomes on a small complete set to verify the expectation; compare variance using strongly correlated and negatively correlated baselines; and compare error under the same total budget. Computing every $a_j$ before selecting the optimal sampling distribution is not free. Fitting baseline coefficients on the same samples used in the estimator can introduce bias; fit them independently or redo the proof.

Unbiasedness applies only to the linear mean above. Dividing by another random denominator, applying softmax or argmax, or evaluating a nonlinear loss generally does not preserve it. Parameter-dependent sampling also requires a separate derivation of the gradient estimator. Do not infer “unbiased attention” or “unbiased training” from this result.

## 3. Define a Layer Through a Fixed Point with Input Injection

**Replace a prescribed number of layers with a target residual.** For a fixed input $x$, define

$$z_{t+1}=T_\theta(z_t,x)=\phi(Az_t+Bx),\qquad z^*=T_\theta(z^*,x).$$

For example, a coordinatewise 1-Lipschitz activation $\phi$ and $\|A\|_\infty\le c$, with $0\le c<1$, guarantee contraction on the complete space $\mathbb R^d$ under the infinity norm. Here the matrix infinity norm is the maximum absolute row sum. The parameterization $A=cM/\max(1,\|M\|_\infty)$ enforces this sufficient condition. An estimated spectral radius below 1 cannot replace this global condition on the nonlinear map.

From $\|z-z^*\|\le\|z-T(z,x)\|+c\|z-z^*\|$, we obtain

$$\|z-z^*\|\le\frac{\|T(z,x)-z\|}{1-c}.$$

**Construct a module from this:** stop using a computable residual, with a maximum iteration count and an explicit flag for failure to converge. Injecting $Bx$ at every iteration allows the equilibrium to depend on the input. However, $B=0$, a non-injective projection, or activation saturation may still collapse different inputs to the same state. Test whether inputs remain distinguishable; contraction does not imply that they do.

If $T$ is differentiable and $I-J_zT$ is locally invertible, the exact equilibrium satisfies $(I-J_zT)\,dz^*/d\theta=\partial_\theta T$. Implicit backpropagation requires solving the corresponding transposed linear system. Truncated backpropagation and an unconverged forward solve introduce additional errors. See the [DEQ paper](https://proceedings.neurips.cc/paper/8358-deep-equilibrium-models.pdf) for an established approach to defining networks through solution problems. The contraction parameterization here is simply an easily checked construction, not an assumption shared by all DEQs.

**Check first:** when $\phi=I$, compare against the analytical linear solution; verify the residual bound, equilibria for different inputs, and iteration cost as $c\to1$; and violate the norm condition to test failure cases. Account for forward iterations, the backward solve, and the slowest sample in a batch before deciding whether the design suits the target hardware.

## 4. Allocate Error Budgets Through Propagation

**Translate a small local change into error in the output that matters.** Let the full state update be $h_{k+1}=F_k(h_k)$ and the candidate update be $\hat h_{k+1}=\hat F_k(\hat h_k)$. If $F_k$ is $L_k$-Lipschitz on the relevant domain and we can control $\delta_k=\|F_k(\hat h_k)-\hat F_k(\hat h_k)\|$, define $e_k=\|h_k-\hat h_k\|$. Then

$$e_{k+1}\le L_ke_k+\delta_k,\qquad e_L\le\sum_{k=0}^{L-1}\delta_k\prod_{j=k+1}^{L-1}L_j\quad(e_0=0).$$

This conditional bound follows by applying the triangle inequality at each layer. If the output readout is $L_{out}$-Lipschitz, multiply by that factor as well.

**Construct a module from this:** allocate compression, skipping, or solver error budgets according to their effect after propagation to the output. Prioritize computation where errors will be amplified. The actual state must include caches and history that affect future computation. An analysis of only the current token vector does not cover subsequent generation after changing the KV cache.

A crucial limitation is that evaluating $\delta_k$ exactly before the decision may already incur the cost of the operation being omitted. Use a bound available from the structure, or a predictor that depends only on the existing state. Teacher trajectories can supply offline labels, but a prediction is not a deterministic certificate. If products of global constants make the bound too large, use it as a diagnostic or investigate tighter bounds under explicit assumptions about the data.

**Check first:** construct a case with small local error and strong downstream amplification, and compare against a baseline that allocates budget using only hidden-state distance. Observations or calibration on a small domain do not automatically establish a guarantee for every input. Related anchor: [matrix-perturbation](../knowledge-base/matrix-analysis/matrix-perturbation.en.md).

## 5. Treat Observation as a Costly Sequential Decision

**Replace a gate score with the value of continuing computation.** The state $s_t$ contains only information available before the decision. A finite-horizon stopping problem can be written as

$$V_t(s)=\min\{\ell_{stop,t}(s),\ c_t(s)+\mathbb E[V_{t+1}(s')\mid s,continue]\},$$

where the stopping cost is itself a conditional expectation when needed, and the terminal value is $V_T=\ell_{stop,T}$. Given a sufficient state, specified transitions, additive expected costs, and available actions, this recursion defines the optimal policy. It does not guarantee that a fitted value network is optimal. [MIT lecture on optimal stopping](https://ocw.mit.edu/courses/6-231-dynamic-programming-and-stochastic-control-fall-2015/resources/mit6_231f15_lec5/)

**Construct a module from this:** compare the expected risk reduction from another computation step against its cost, and train conditional value or benefit predictors. If the action skips one sublayer rather than exiting permanently, use an action-based Bellman equation with successor states for both skip and compute. The stopping recursion cannot be applied directly.

**Check first:** compare with a dynamic programming oracle on a small state system that can be enumerated, and also test a myopic rule. Check for access to features whose acquisition cost has not yet been paid or outputs of layers supposedly skipped. Complete offline trajectories have a different state distribution from execution under a new policy; check coverage and perform rollouts. A hard latency limit also requires an explicit budget state or constraint. A penalty on average cost does not guarantee a budget for every sample.

## Which Conclusions Survive Composition?

For example, move 1 provides a cheap baseline whose mean can be computed exactly, and move 2 corrects it using sampled residuals. Together they define a candidate aggregation mechanism. Unbiasedness of its linear mean requires full sampling support and a fixed baseline. It does not extend to arbitrary normalized outputs and does not automatically eliminate storage of the original data.

The residual in move 3 can provide a stopping rule, while move 5 can optimize average cost. If the value network permits stopping before the residual meets its threshold, the original error requirement for each sample has been abandoned. State which risk objective replaces it.

Composition requires more than joining two mathematical terms: derive the interface, construct a counterexample that breaks it, and then decide whether implementation is worthwhile.
