# MoE Routing (Mixture-of-Experts Routing)
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use in large-scale models where a small number of experts must be dynamically selected to process each token, achieving parameter scaling while keeping inference cost manageable.
Typical scenarios: (1) Sparse MoE layers -- each token selects top-k experts (k << K);
(2) Shared + Private expert mixing -- shared experts handle general features, private experts handle specialized features;
(3) Multi-granularity MoE -- different layers employ different granularities of expert specialization.
Core requirement: **sparse activation, load balancing, end-to-end trainability**.

## Mathematical Inspiration
- Lenses: ../../lenses/variational.en.md (discrete variational relaxation, Gumbel-Softmax), ../../lenses/probabilistic.en.md (information-theoretic routing)
- Knowledge: ../../knowledge-base/optimization/lagrangian-duality.en.md (combinatorial variational, integer programming relaxation),
  ../../knowledge-base/probability/entropy.en.md (entropy regularization, information bottleneck)

## Required Mathematical Background
- **Mixture Model EM**: p(y|x) = sum_k pi_k(x) * p(y|x, theta_k)
  E-step estimates responsibilities gamma_{nk} = pi_k * p(y_n|x_n, theta_k) / sum_j pi_j * p(y_n|x_n, theta_j)
  M-step updates expert parameters theta_k and mixture weights pi_k
- **Top-k Sparse Gate**: G(x) = Softmax(TopK(x * W_g))
  TopK indices are discrete; selected values retain piecewise gradients. Noise/STE are optional choices, and top-1 weights need the convention below
- **Load-Balancing Auxiliary Loss**: L_aux = alpha * K * sum_k f_k * P_k
  f_k = fraction of tokens assigned to expert k, P_k = average gating probability for expert k
- **Expert Choice Routing**: Experts actively select tokens, rather than tokens selecting experts
  score_{ki} = sim(e_k, x_i), each expert selects top-C tokens

## AI Module Form

```python
# k selected experts out of K; optional noise is a separately evaluated variant
logits = (X @ W_gate).float()
p_full = softmax(logits, dim=-1)
topk_idx = topk(logits, k, dim=-1).indices
selected_p = gather(p_full, topk_idx)
# Preserve full-softmax probability for top-1 so the task loss has a router gradient.
gate_weights = selected_p if k == 1 else selected_p / selected_p.sum(-1, keepdim=True)
output = dispatch_compute_combine(X, topk_idx, gate_weights)

# Normalize assignment fractions over N*k assignments
f = one_hot(topk_idx, K).float().mean(dim=(0, 1)).detach()  # shape K
P = p_full.mean(dim=0)
L_aux = K * dot(f, P)  # equals 1 when f or P is uniform; not universally >= 1
capacity = ceil(capacity_factor * N * k / K)
```
Top-k **indices** are discrete, but selected gate values can receive ordinary piecewise gradients; noisy gates or STE are design choices, not mandatory for every sparse gate. Softmax over the single selected top-1 logit gives exactly 1 and zero task gradient through its weight. [Switch Transformer](https://arxiv.org/abs/2101.03961).

Expert-choice routes each expert's top-$C$ tokens, fixing expert loads while allowing variable numbers of experts per token; some tokens may be unselected. Specify combination weights and fallback. Shared experts add their own dense path cost. Overflow handling must be explicit: drop, residual bypass, reroute, or dropless execution.

## Implementable Structures

- Gate network plus dispatch/combine with the selected probability convention.
- Expert placement may put multiple experts on one device; count token exchange under the actual placement.
- Capacity counts selected assignments, hence scales with `N*k/K`.
- Router z-loss regularizes logsumexp magnitudes; report overflow, per-expert load and gate gradients.

## GPU Feasibility

- **D1/D2[~]**: Gate uses GEMM; expert FFNs use grouped/batched GEMM, with gather/scatter dispatch overhead.
- **D3[~]**: Gate $O(NdK)$; balanced load per expert is $Nk/K$, expert work $O((Nk/K)dd_{ff})$, total $O(Nkdd_{ff})$. Shared experts and padded capacity add cost.
- **D4[~]**: All $K$ expert parameter sets exist; activation memory depends on capacity padding, checkpointing and concurrency, not simply selected parameter fraction.
- **D5[~]**: Compute routing logits/softmax/reductions in fp32 when needed; measure top-k instability near ties.
- **D6[~]**: Communication volume is governed by remote selected assignments, approximately $O(Nkd)$ elements plus combine traffic in a fully remote case; device topology and expert placement determine per-device load.
- **D7[~]**: Sparse activation is conditional computation; it does not mean the dense expert matrices are sparse.
- **D8[~]**: Router and dispatch fusion require concrete implementations; expert computation intervenes before the final weighted sum.

## Paper-Worthy Formulation
"We employ noisy top-k gating for sparse mixture-of-experts routing, activating only k experts per token to reduce activated compute while using the load-balancing auxiliary loss L_aux = K * <f, P> and Router Z-loss to stabilize routing logits. A paper should report measured expert utilization, overflow rate, all-to-all communication share, and quality deltas against dense baselines under matched FLOPs / parameter budgets; do not use unmeasured fixed-percentage placeholders."

## Risks
- Load imbalance: A few experts are over-selected (Matthew effect), while remaining experts receive insufficient training
- Discrete selection boundaries and top-1 renormalization can remove task gradients; check the router gradient path explicitly
- All-to-all communication becomes a bottleneck in multi-GPU settings, especially when k > 1 as communication volume doubles
- Noise injection promotes exploration but increases training variance, requiring careful annealing
