# MoE Routing (Mixture-of-Experts Routing)

## Applicable Problems
Use in large-scale models where a small number of experts must be dynamically selected to process each token, achieving parameter scaling while keeping inference cost manageable.
Typical scenarios: (1) Sparse MoE layers -- each token selects top-k experts (k << K);
(2) Shared + Private expert mixing -- shared experts handle general features, private experts handle specialized features;
(3) Multi-granularity MoE -- different layers employ different granularities of expert specialization.
Core requirement: **sparse activation, load balancing, end-to-end trainability**.

## Mathematical Inspiration
- Lenses: lenses/optimization.md (discrete optimization relaxation, Gumbel-Softmax), lenses/information.md (information-theoretic routing)
- Knowledge: knowledge-base/fundamentals/optimization.md (combinatorial optimization, integer programming relaxation),
  knowledge-base/fundamentals/probability.md (mixture models, EM algorithm)

## Required Mathematical Background
- **Mixture Model EM**: p(y|x) = sum_k pi_k(x) * p(y|x, theta_k)
  E-step estimates responsibilities gamma_{nk} = pi_k * p(y_n|x_n, theta_k) / sum_j pi_j * p(y_n|x_n, theta_j)
  M-step updates expert parameters theta_k and mixture weights pi_k
- **Top-k Sparse Gate**: G(x) = Softmax(TopK(x * W_g))
  TopK is non-differentiable; during training, use noisy top-k or straight-through estimator
- **Load-Balancing Auxiliary Loss**: L_aux = alpha * K * sum_k f_k * P_k
  f_k = fraction of tokens assigned to expert k, P_k = average gating probability for expert k
- **Expert Choice Routing**: Experts actively select tokens, rather than tokens selecting experts
  score_{ki} = sim(e_k, x_i), each expert selects top-C tokens

## AI Module Form
```
Module: MoERouter
Input: X in R^{N x d}, K experts {E_k}_{k=1}^K, k experts activated per token

Method 1 - Standard Top-K Gate (Switch/ST-MoE):
  logits = X @ W_gate                  // N x K, standard GEMM
  noise = randn(N, K) * softplus(X @ W_noise)  // learnable noise to encourage exploration
  logits_noisy = logits + noise
  topk_vals, topk_idx = topk(logits_noisy, k, dim=-1)  // select top-k
  gate_weights = softmax(topk_vals, dim=-1)    // weights for k experts
  // output = sum_{j in top-k} gate_weights_j * E_j(X)

Method 2 - Shared + Private Dual-Path Routing:
  // Shared expert always activated; Private experts selected via top-k
  shared_out = E_shared(X)             // all tokens pass through shared expert
  private_logits = X @ W_private_gate  // N x K_private
  private_topk = topk(private_logits, k_p)
  private_out = sum_j gate_j * E_private_j(X)
  output = shared_out + private_out    // or concat + linear

Method 3 - Expert Choice (Google 2022):
  // Reverse perspective: each expert selects top-C tokens
  affinity = E_embeddings @ X^T        // K x N, expert-token affinity
  for k in range(K):
    chosen_tokens = topk(affinity[k], C)  // each expert selects C = N/K tokens
    expert_k.process(chosen_tokens)
  // Natural load balancing: each expert processes exactly C tokens

Auxiliary loss:
  f = onehot(topk_idx).float().mean(dim=0)   // K-dim, per-expert load
  P = softmax(logits, dim=-1).mean(dim=0)    // K-dim, per-expert average probability
  L_aux = K * dot(f, P)                      // equals 1 when uniform, > 1 when non-uniform
```

## Implementable Structures
- **Gate network**: Single-layer Linear(d, K) + optional noise network
- **Expert parallelism**: Each expert on a separate GPU, all-to-all communication to exchange tokens
- **Capacity factor**: cap = C_factor * N/K; tokens exceeding capacity go through residual (not dropped)
- **Router Z-loss**: L_z = alpha * mean(logsumexp(logits)^2) stabilizes logit magnitudes

## GPU Feasibility
- **Tensorization**: Gate logits = X @ W_gate is standard GEMM (N x d) @ (d x K); expert computation is batched GEMM
- **GEMM-mappable**: Gate requires 1 GEMM; each expert internally is a standard FFN (2 GEMMs + activation)
- **Complexity**: Gate O(N * d * K); per expert O(N * d * d_ff / k); total FLOPs approximately standard FFN x k
- **Memory and KV-Cache**: All K expert parameters stored but only k activated; activation memory approximately standard FFN x k
- **Low-precision stability**: Gate softmax + top-k is safe in fp16; Router Z-loss requires fp32 logsumexp
- **Parallelism and communication**: Expert parallelism requires all-to-all communication (each GPU sends/receives N/K tokens); bandwidth-sensitive
- **Sparse structure**: Top-k routing is naturally sparse (activates k/K fraction of parameters); sparsity = 1 - k/K
- **Operator fusion**: Gate -> top-k -> softmax -> weighted-sum can be fused; intra-expert FFN can be fused

## Paper-Worthy Formulation
"We employ noisy top-k gating for sparse mixture-of-experts routing, activating a k/K fraction of parameters to achieve O(K) parameter capacity at O(k) inference cost. Combined with the load-balancing auxiliary loss L_aux = K * <f, P> and Router Z-loss, expert utilization exceeds 95%, yielding X% performance improvement over dense models under the same FLOPs budget."

## Risks
- Load imbalance: A few experts are over-selected (Matthew effect), while remaining experts receive insufficient training
- Top-k operation is non-differentiable; straight-through estimation introduces gradient bias
- All-to-all communication becomes a bottleneck in multi-GPU settings, especially when k > 1 as communication volume doubles
- Noise injection promotes exploration but increases training variance, requiring careful annealing
