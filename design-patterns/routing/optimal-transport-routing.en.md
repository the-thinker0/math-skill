# Optimal Transport Routing
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

## Applicable Problems
Use when a set of input tokens/samples must be assigned to a set of experts/sub-modules while pursuing globally optimal matching cost.
Typical scenarios: (1) Load-balanced MoE routing -- assigning N tokens to K experts with a cost matrix defined as negative similarity; (2) Cross-layer feature alignment -- transporting layer-l features to the optimal subset of layer-(l+1); (3) Multi-task sample assignment -- assigning samples in a batch to the most appropriate task head.
Core requirement: **globally optimal assignment, rather than greedy per-point decisions**.

## Mathematical Inspiration
- Lenses: ../../lenses/variational.en.md (convex variational, duality theory), ../../lenses/geometric.en.md (Wasserstein distance)
- Knowledge: ../../knowledge-base/optimization/lagrangian-duality.en.md (duality theory, constrained optimization),
  ../../knowledge-base/probability/entropy.en.md (entropy regularization, marginal constraints)

## Required Mathematical Background
- **Discrete Optimal Transport**: min_{P in Pi(mu,nu)} <C, P> = sum_{ij} C_{ij} P_{ij}
  where Pi(mu,nu) = {P >= 0 : P * 1 = mu, P^T * 1 = nu} is the set of couplings with marginal constraints
- **Entropy-Regularized Sinkhorn**: min <C,P> - eps * H(P) => P* = diag(u) * exp(-C/eps) * diag(v)
  Solved by alternating row/column scaling (Sinkhorn-Knopp), convergence rate O(1/eps^2)
- **Wasserstein-1 Distance**: W_1(mu,nu) = min_{pi in Pi} E_pi[||x-y||] = sup_{||f||_L <= 1} E_mu[f] - E_nu[f]
  Kantorovich-Rubinstein duality, used for continuous distribution matching
- **Gromov-Wasserstein**: When source/target spaces have different dimensions, minimizes the structure-preserving transport cost

## AI Module Form
```
Module: OptimalTransportRouter
Input: token representations X in R^{N x d}, expert embeddings E in R^{K x d}, capacity constraint cap in R^K

Cost matrix: C_{ik} = -sim(X_i, E_k)  or  ||X_i - E_k||^2  (N x K)

Sinkhorn routing (entropy-regularized):
  K_mat = exp(-C / eps)              // Gibbs kernel, eps = 0.05 ~ 0.1
  for t = 1..T:                       // T = 5 ~ 20 iterations
    u = a / (K_mat @ v)              // row scaling, a = 1/N
    v = b / (K_mat^T @ u)            // column scaling, b = cap / sum(cap)
  P = diag(u) @ K_mat @ diag(v)     // optimal transport plan (satisfies marginal constraints; doubly stochastic only when N = K with uniform marginals)
  assignment = argmax(P, dim=1)      // hard assignment (at inference)
  // At training: weighted_features = P @ E  (soft assignment, differentiable)

Capacity constraint (b vector):
  b_k = total_tokens / K             // uniform allocation
  b_k = alpha * uniform + (1 - alpha) * learned  // learned non-uniform allocation
```

## Implementable Structures
- **Sinkhorn layer**: Custom autograd Function; forward pass performs Sinkhorn iterations, backward pass uses the implicit function theorem for gradients
- **Fixed iteration count**: T = 10 fixed iterations => can be unrolled into a computation graph (unrolled variational)
- **Log-domain stabilization**: Convert Sinkhorn to log domain to avoid exp overflow:
  log_u = log_a - logsumexp(log_K + log_v, dim=1)
- **Batch OT**: Solve independently per micro-batch, parallelize Sinkhorn iterations

## GPU Feasibility
- **Tensorization**: Sinkhorn core is matrix-vector multiplication K @ v of shape (N x K) * (K x 1), standard GEMV
- **GEMM-mappable**: Computation of C via X @ E^T is GEMM (N x d) @ (d x K); Sinkhorn iterations are GEMV
- **Complexity**: O(N * K * T) where T = 10 ~ 20; for N = 2048, K = 64 approximately 2.6M FLOPs, negligible
- **Memory & KV-Cache**: Storing C (N x K) and P (N x K); for N = 2048, K = 64 approximately 1 MB
- **Low-precision stability**: Sinkhorn in fp16 may cause exp(-C/eps) overflow; log-domain + fp32 recommended
- **Parallelism & Communication**: Batch dimension is independent; Sinkhorn iterations have sequential dependencies, but each iteration's matvec is highly parallel
- **Sparse structure**: As eps -> 0, P approaches sparsity (permutation matrix); top-k approximation can be used for acceleration
- **Operator fusion**: The exp -> matvec -> division pipeline in a single Sinkhorn step can be fused into a CUDA kernel

## Paper-Worthy Formulation
"We formulate token-to-expert routing as an entropy-regularized optimal transport problem, obtaining an approximate transport plan via the Sinkhorn-Knopp algorithm within T = 10 iterations. Finite Sinkhorn iterations yield an approximate solution to the entropy-regularized problem (not the exact global optimum); approximation quality depends on the iteration count T and regularization parameter eps. Marginal constraints b control the load upper bound per expert."

## Risks
- Excessively small eps causes numerical instability in Sinkhorn (exp overflow); requires log-domain or increasing eps
- Fixed unrolling of T iterations limits solution precision; too many iterations increase latency
- The N x K cost matrix creates significant memory pressure when both N and K are large (N = 32K, K = 256 => 32 MB)
- Training-inference discrepancy: performance gap between soft assignment and hard assignment
