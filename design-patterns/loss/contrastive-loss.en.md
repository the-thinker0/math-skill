# Contrastive Loss

## Applicable Problems
When the model needs to learn "what is similar to what and what is different from what." Typical scenarios: (1) Different augmented views of the same input should be pulled closer (positive pairs), while different inputs should be pushed apart (negative pairs); (2) Shared representations should capture cross-task commonalities, while Private representations should distinguish task-specific features; (3) In the expert embedding space, similar inputs should be routed to the same expert. Core objective: **learn relative relationships rather than absolute values**.

## Mathematical Inspiration
- Lenses: lenses/geometric.md (metric spaces and distance functions), lenses/probabilistic.md (mutual information maximization)
- Knowledge: knowledge-base/probability/entropy.md (conditional distributions and likelihood), knowledge-base/differential-geometry/manifold.md (geodesics and curvature)

## Required Mathematical Knowledge
- **InfoNCE Loss**: $L = -\log[\exp(\text{sim}(q,k^+)/\tau) / \sum_j \exp(\text{sim}(q,k_j)/\tau)]$ -- essentially a lower-bound estimate of mutual information in contrastive learning; $\tau$ is the temperature parameter controlling distribution sharpness
- **Margin-Based Metric Learning**: Triplet Loss $= \max(0, d(a,p) - d(a,n) + \text{margin})$ -- explicitly widens the distance gap between positive and negative pairs in metric space
- **NT-Xent (Normalized Temperature-scaled Cross Entropy)**: Softmax contrastive loss on the unit sphere $S^{d-1}$, with normalization eliminating scale effects
- **Debiased Contrastive Learning**: Corrects for false negatives in negative samples, using prior $\tau^+$ to estimate the true negative sample distribution

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
- **Tensorization**: Similarity computation is $z_a @ z_n^T$ -- standard GEMM $(B \times d) @ (d \times N) = B \times N$
- **GEMM-mappability**: Core computation is 1-2 matrix multiplications, perfectly mapped to cuBLAS
- **Complexity**: $O(B \cdot N \cdot d)$ computation + $O(B \cdot N)$ storage for the logits matrix; approximately 64MB when B=256, N=65536
- **Memory & KV-Cache**: Negative sample queue occupies $N \cdot d \cdot 4$ bytes, approximately 65536 * 256 * 4 = 64MB, fixed overhead
- **Low Precision Stability**: Cosine similarity + softmax under fp16 requires caution for exp overflow; use log-sum-exp trick
- **Parallelism & Communication**: On multiple GPUs, use all-gather to collect negatives from other GPUs to enlarge $N$ (MoCo v3 strategy)
- **Sparse Structure**: After hard negative mining, only $k \ll N$ negatives are retained, effectively sparsifying the logits
- **Operator Fusion**: L2-norm -> matmul -> scale -> log-softmax -> nll_loss can be fused

## Paper Phrasing
"We employ temperature-scaled InfoNCE contrastive loss with a momentum encoder maintaining a negative sample queue of N=65536, maximizing the lower bound of positive-pair mutual information on the unit sphere. Theoretical analysis shows this lower bound converges at rate $O(1/\sqrt{N})$."

## Risks
- Too small $\tau$ causes training instability (excessively large gradients); too large $\tau$ makes all samples indistinguishable (degenerates to uniform distribution)
- Stale encodings in the negative sample queue introduce representation bias
- False negative problem: unsupervised negative sampling may select samples that are semantically similar but differently labeled
- When $B$ is too small, the positive/negative pair imbalance within the batch must be compensated by the queue
