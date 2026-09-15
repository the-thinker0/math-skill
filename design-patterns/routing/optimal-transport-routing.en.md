# Optimal Transport Routing
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use when a set of input tokens/samples must be assigned to a set of experts/sub-modules while pursuing globally optimal matching cost.
Typical scenarios: (1) Load-balanced MoE routing -- assigning N tokens to K experts with a cost matrix defined as negative similarity; (2) Cross-layer feature alignment -- transporting layer-l features to the optimal subset of layer-(l+1); (3) Multi-task sample assignment -- assigning samples in a batch to the most appropriate task head.
Core requirement: **globally optimal assignment, rather than greedy per-point decisions**.

## Mathematical Inspiration
- Lenses: ../../lenses/variational.en.md (convex variational, duality theory), ../../lenses/geometric.en.md (Wasserstein distance)
- Knowledge: ../../knowledge-base/probability/optimal-transport.en.md (Kantorovich relaxation, Sinkhorn, Wasserstein distance),
  ../../knowledge-base/optimization/lagrangian-duality.en.md (duality theory, constrained optimization),
  ../../knowledge-base/probability/entropy.en.md (entropy regularization, marginal constraints)

## Required Mathematical Background

- For $N$ tokens and $K$ experts, choose probability marginals $a_i=1/N$, $b_k\ge0$, $\sum_k b_k=1$. Balanced OT enforces **equalities** $P\mathbf1=a$, $P^T\mathbf1=b$.
- Sinkhorn solves $\min_{P\in\Pi(a,b)}\langle C,P\rangle-\epsilon H(P)$ with a positive Gibbs kernel. Finite iteration error depends on cost range, marginals, regularization and tolerance; there is no universal $O(1/\epsilon^2)$ iteration count without a specified theorem.
- A capacity upper bound $c_k$ corresponds to $\sum_i P_{ik}\le c_k/N$, requiring an inequality-constrained/unbalanced or capacitated formulation. Setting $b=c/\sum c$ instead enforces normalized target loads, not just capacities.
- Rowwise argmax/top-k can violate capacities even when the soft plan satisfies its marginals. Use capacity-aware rounding or a min-cost-flow/assignment step for hard feasibility.
- Gromov–Wasserstein compares pairwise relational costs when spaces lack a common metric correspondence; differing coordinate dimension alone does not force its use.

## AI Module Form

```python
C = -X @ E.T                         # N x K; scale costs explicitly
log_K = -C.float() / epsilon
log_a = full((N,), -log(N))
log_b = log(target_load_probs)       # positive K-vector summing to 1
log_v = zeros(K)
for _ in range(T):
    log_u = log_a - logsumexp(log_K + log_v[None, :], dim=1)
    log_v = log_b - logsumexp(log_K + log_u[:, None], dim=0)
P = exp(log_u[:, None] + log_K + log_v[None, :])
row_error = norm(P.sum(1) - exp(log_a), p=1)
col_error = norm(P.sum(0) - exp(log_b), p=1)
route_probs = P / exp(log_a)[:, None] # conditional expert weights, about row-sum 1
soft_output = route_probs @ E
hard_assignment = capacity_aware_round(P, integer_capacities)
```
Check total integer capacity and rounding feasibility. Balanced uniform marginals give $b_k=1/K$, not $N/K$. For square uniform marginals, $NP$ is doubly stochastic; $P$ itself has row/column sums $1/N$. Small $\epsilon$ may approach a sparse unregularized plan, but a permutation occurs only in the appropriately scaled square assignment setting.

## Implementable Structures
- **Sinkhorn layer**: Custom autograd Function; forward pass performs Sinkhorn iterations, backward pass uses the implicit function theorem for gradients
- **Fixed iteration count**: T = 10 fixed iterations => can be unrolled into a computation graph (unrolled variational)
- **Log-domain stabilization**: Convert Sinkhorn to log domain to avoid exp overflow:
  log_u = log_a - logsumexp(log_K + log_v, dim=1)
- **Batch OT**: Solve independently per micro-batch, parallelize Sinkhorn iterations

## GPU Feasibility

- **D1/D2[~]**: Cost construction uses GEMM; stable Sinkhorn uses sequential row/column log-sum-exp reductions.
- **D3[~]**: Cost $O(NKd)$ plus iterations $O(TNK)$ and rounding cost; measure iterations needed for the target residual, not a fixed universal $T$.
- **D4[~]**: Two fp32 $N\times K$ matrices use $8NK$ bytes before saved iterates. Unrolled backprop may store $O(TNK)$; implicit differentiation needs regularity and accurate solves.
- **D5[~]**: Use log-domain fp32 and monitor marginal residuals as $\epsilon$ shrinks.
- **D6[~]**: Independent batches parallelize; row and column updates depend on each other. Global load constraints across devices require communication.
- **D7/D8[~]**: Sparse approximations and fused reductions change implementation and may change feasibility; validate both marginals and final hard capacities.

## Paper-Worthy Formulation

“We solve an entropy-regularized transport relaxation with declared marginal targets and report residuals after finite iterations. Capacity-aware rounding provides the separately checked hard assignment; we report its cost increase, overflow, latency, and task-quality effects.”

## Risks
- Excessively small eps causes numerical instability in Sinkhorn (exp overflow); requires log-domain or increasing eps
- Fixed unrolling of T iterations limits solution precision; too many iterations increase latency
- The N x K cost matrix creates significant memory pressure when both N and K are large (N = 32K, K = 256 => 32 MB)
- Training-inference discrepancy: performance gap between soft assignment and hard assignment
