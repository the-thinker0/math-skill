# Contrastive Loss
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
When the model needs to learn "what is similar to what and what is different from what." Typical scenarios: (1) Different augmented views of the same input should be pulled closer (positive pairs), while different inputs should be pushed apart (negative pairs); (2) Shared representations should capture cross-task commonalities, while Private representations should distinguish task-specific features; (3) In the expert embedding space, similar inputs should be routed to the same expert. Core objective: **learn relative relationships rather than absolute values**.

## Mathematical Inspiration
- Lenses: ../../lenses/geometric.en.md (metric spaces and distance functions), ../../lenses/probabilistic.en.md (mutual information maximization)
- Knowledge: ../../knowledge-base/probability/entropy.en.md (conditional distributions and likelihood), ../../knowledge-base/differential-geometry/manifold.en.md (geodesics and curvature)

## Required Mathematical Knowledge
- **InfoNCE Loss**: $L = -\log[\exp(\text{sim}(q,k^+)/\tau) / \sum_j \exp(\text{sim}(q,k_j)/\tau)]$ -- essentially a lower-bound estimate of mutual information in contrastive learning; $\tau$ is the temperature parameter controlling distribution sharpness
- **Margin-Based Metric Learning**: Triplet Loss $= \max(0, d(a,p) - d(a,n) + \text{margin})$ -- explicitly widens the distance gap between positive and negative pairs in metric space
- **NT-Xent (Normalized Temperature-scaled Cross Entropy)**: Softmax contrastive loss on the unit sphere $S^{d-1}$, with normalization eliminating scale effects
- **Debiased Contrastive Learning**: Corrects for false negatives in negative samples, using prior $\tau^+$ to estimate the true negative sample distribution

## Alignment-Uniformity Framework

For unit-normalized features, alignment and uniformity are useful population diagnostics:
$$L_{align}=\mathbb E_{(x,x^+)}\|f(x)-f(x^+)\|^2,\qquad L_{uniform}=\log\mathbb E_{x,x'}e^{-t\|f(x)-f(x')\|^2},\ t>0.$$
The infinite-negative analysis links contrastive objectives to these properties under its sampling and distributional assumptions. It does not guarantee exact uniformity for a finite batch, nor a universal threshold such as 1024 negatives. Temperature, positive construction, model capacity, and attainable distributions affect the trade-off. [Wang & Isola, original analysis](https://proceedings.mlr.press/v119/wang20k.html).

With one joint positive pair and $M-1$ iid negatives from the appropriate marginal, the population bound is $I(U;V)\ge\log M-\mathbb E[L_{NCE}]$. The loss itself is **not** the MI lower bound, and the bound concerns the variables forming the positive pair. It saturates at $\log M$; finite-sample estimator bias, hard-negative selection, dependent queues and critic restriction require separate treatment. More negatives do not guarantee a tighter realized estimate for a fixed learned critic. [CPC source](https://arxiv.org/abs/1807.03748).

Alignment/uniformity do not guarantee downstream semantic usefulness. Report positive-pair distance, empirical uniformity, collapse indicators and downstream metrics alongside InfoNCE.

## AI Module Form

```python
anchors = normalize(encoder_q(x), dim=-1)
positives = normalize(encoder_k(x_positive), dim=-1)
negatives = queue.snapshot()               # read before inserting current positives
positive_logits = (anchors * positives).sum(-1, keepdim=True)
negative_logits = anchors @ negatives.T
logits = cat([positive_logits, negative_logits], dim=-1) / tau
loss = cross_entropy(logits.float(), zeros(B, dtype=long))
queue.enqueue(positives.detach())          # stores O(M*d), it is not free memory
```
Exclude exact positives/self-pairs from the negative pool where required. Historical queues trade larger pools for staleness/dependence; they save repeated encoder work but consume memory. Hard-negative mining changes the sampling distribution, and finding hard negatives may still require scoring the full pool. If using sampled hard negatives, report the rule and do not silently retain the iid-marginal MI guarantee.

## Implementable Architectures
- **Dual-Tower Encoder + Projection Head**: encoder -> projection_head (2-layer MLP) -> normalize -> loss
- **Negative Sample Queue**: Maintain a FIFO queue of momentum encoder outputs, capacity N=65536
- **Symmetric Loss**: $L = L(a \to p) + L(p \to a)$, swapping positive/negative roles for enhanced training stability
- **Multi-Granularity Contrast**: Apply contrastive objectives simultaneously at token-level, sequence-level, and expert-level

## GPU Feasibility

- **D1/D2[~]**: Similarity uses $B\times d$ by $d\times M$ GEMM; normalization and cross-entropy add reductions.
- **D3/D4[~]**: Similarity $O(BMd)$; materialized logits $O(BM)$ and queue $O(Md)$. At fp32, $B=256,M=65536$ logits use 64 MiB; a $65536\times256$ queue separately uses 64 MiB.
- **D5[~]**: Use stable log-softmax/log-sum-exp with fp32 accumulation; tiny temperature amplifies score error and gradients.
- **D6[~]**: Cross-device negatives require all-gather (and potentially its gradient communication); a momentum queue has a different communication profile.
- **D7[~]**: Retaining hard negatives reduces downstream logits only after selection; full-pool search cost remains unless an approximate index is used.
- **D8[~]**: Tiled similarity/cross-entropy can reduce memory, but a single fused kernel is not implied by writing the operator chain.

## Paper Phrasing
"We employ temperature-scaled InfoNCE contrastive loss with a momentum encoder maintaining a negative-sample queue, optimizing proxies for positive-pair alignment and representation uniformity on the unit sphere. Mutual-information lower bounds and sampling-error rates depend on the negative-sample distribution, independence assumptions, and queue staleness; report ablations over queue size, temperature, negative-mining strategy, and downstream metrics."

## Risks
- Too small $\tau$ causes training instability (excessively large gradients); too large $\tau$ makes all samples indistinguishable (degenerates to uniform distribution)
- Stale encodings in the negative sample queue introduce representation bias
- False negative problem: unsupervised negative sampling may select samples that are semantically similar but differently labeled
- When $B$ is too small, the positive/negative pair imbalance within the batch must be compensated by the queue
