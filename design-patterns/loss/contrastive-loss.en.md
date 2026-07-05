# Contrastive Loss
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

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

Representation quality in contrastive learning decomposes into two independent objectives (Wang & Isola, 2020):

- **Alignment**: Positive pairs should have similar representations
  $L_{\text{align}} = \mathbb{E}_{(x, x^+)}[\|f(x) - f(x^+)\|^2]$
- **Uniformity**: Representations should be uniformly distributed on the unit hypersphere $S^{d-1}$
  $L_{\text{uniform}} = \log \mathbb{E}_{x, x'}[\exp(-2\|f(x) - f(x')\|^2)]$

**InfoNCE and alignment-uniformity**: As $N \to \infty$ with appropriate temperature $\tau$, the InfoNCE loss asymptotically decomposes into alignment + uniformity. For finite $N$, InfoNCE provides a lower bound on $I(X;Z)$, with tightness increasing in $N$.

**Conditions for uniformity to hold**:
- Sufficiently large negative sample count $N$ (theory requires $N \to \infty$; in practice $N \geq 1024$ is typically sufficient)
- Temperature $\tau$ not too large ($\tau \to \infty$ causes loss to degenerate to a constant, eliminating the uniformity-driving force)
- Representation dimension $d$ sufficient to support the intrinsic dimension of the data

**Conditions for uniformity to fail**:
- Insufficient negatives $\rightarrow$ weak uniformity pressure; representations may cluster on a local region of the sphere
- Representation collapse: all inputs map to the same (or few) points, trivially minimizing alignment but completely destroying uniformity
- Temperature $\tau$ too large $\rightarrow$ softmax degenerates to uniform distribution, gradients vanish, no uniformity guarantee
- Severe positive/negative imbalance within the batch without queue compensation

**What can be guaranteed at most**: Under ideal conditions (sufficiently large $N$, appropriate $\tau$, no collapse), minimizing contrastive loss is equivalent to jointly maximizing positive-pair alignment and representation uniformity.

**What cannot be guaranteed**: Optimality of learned representations for downstream tasks (uniformity $\neq$ task relevance); semantic-level alignment (only geometric-level positive-pair proximity is guaranteed).

## AI Module Form
```
Module: ContrastiveLoss
Input: anchors z_a in R^{B x d}, positives z_p in R^{B x d}, negative pool z_n in R^{N x d}

Core formula (InfoNCE + temperature scaling):
  sim(q, k) = q^T k / (||q|| * ||k||)       // cosine similarity
  logits_i = [sim(z_a_i, z_p_i)] (+) [sim(z_a_i, z_n_j)]_{j=1}^N  // concatenation
  L_contrast = -1/B * Sum_i log( exp(logits_i[0]/tau) / Sum_j exp(logits_i[j]/tau) )

Queue mechanism (MoCo style):
  z_n = FIFO_queue.enqueue(z_p.detach())   // negative sample queue, capacity N >> B
  // Queue stores encodings from historical batches, increasing negative count without additional memory

Hard Negative Mining:
  top-k indices = argsort(sim(z_a, z_n), descending=True)[:k]
  z_n_hard = z_n[top-k indices]            // retain only the k hardest negatives
```

## Implementable Architectures
- **Dual-Tower Encoder + Projection Head**: encoder -> projection_head (2-layer MLP) -> normalize -> loss
- **Negative Sample Queue**: Maintain a FIFO queue of momentum encoder outputs, capacity N=65536
- **Symmetric Loss**: $L = L(a \to p) + L(p \to a)$, swapping positive/negative roles for enhanced training stability
- **Multi-Granularity Contrast**: Apply contrastive objectives simultaneously at token-level, sequence-level, and expert-level

## GPU Feasibility
- **D1[v]**: Similarity computation is $z_a @ z_n^T$ -- standard GEMM $(B \times d) @ (d \times N) = B \times N$
- **D2[v]**: Core computation is 1-2 matrix multiplications, perfectly mapped to cuBLAS
- **D3[v]**: $O(B \cdot N \cdot d)$ computation + $O(B \cdot N)$ storage for the logits matrix; approximately 64MB when B=256, N=65536
- **D4[v]**: Negative sample queue occupies $N \cdot d \cdot 4$ bytes, approximately 65536 * 256 * 4 = 64MB, fixed overhead
- **D5[v]**: Cosine similarity + softmax under fp16 requires caution for exp overflow; use log-sum-exp trick
- **D6[v]**: On multiple GPUs, use all-gather to collect negatives from other GPUs to enlarge $N$ (MoCo v3 strategy)
- **D7[v]**: After hard negative mining, only $k \ll N$ negatives are retained, effectively sparsifying the logits
- **D8[v]**: L2-norm -> matmul -> scale -> log-softmax -> nll_loss can be fused

## Paper Phrasing
"We employ temperature-scaled InfoNCE contrastive loss with a momentum encoder maintaining a negative-sample queue, optimizing proxies for positive-pair alignment and representation uniformity on the unit sphere. Mutual-information lower bounds and sampling-error rates depend on the negative-sample distribution, independence assumptions, and queue staleness; report ablations over queue size, temperature, negative-mining strategy, and downstream metrics."

## Risks
- Too small $\tau$ causes training instability (excessively large gradients); too large $\tau$ makes all samples indistinguishable (degenerates to uniform distribution)
- Stale encodings in the negative sample queue introduce representation bias
- False negative problem: unsupervised negative sampling may select samples that are semantically similar but differently labeled
- When $B$ is too small, the positive/negative pair imbalance within the batch must be compensated by the queue
