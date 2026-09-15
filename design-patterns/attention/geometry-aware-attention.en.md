# Geometry-Aware Attention

> Rigor convention: [v] denotes a checkable formula or count under stated assumptions; [~] denotes a design/implementation requiring experiments. This prototype claims no measured GPU speedup.

## Applicable Problems
Known spatial, manifold, tree, or temporal relationships can enter attention as explicit geometric biases. Standard attention may also learn such relationships from features or positional encodings. Adding a bias is an inductive-bias choice, not an automatic guarantee of full-model invariance/equivariance.

## Mathematical Inspiration
- Lenses: `../../lenses/symmetry.en.md`, `../../lenses/geometric.en.md`.
- Knowledge: `../../knowledge-base/differential-geometry/geodesic.en.md`, `../../knowledge-base/lie-theory/equivariance.en.md`.

## Required Mathematical Knowledge
- **Distance to bias:** -alpha*delta or -delta^2/(2*sigma^2) decreases with distance when alpha>=0 and sigma>0. An arbitrary `MLP(delta)` need not be monotone.
- **RBF boundary:** exp(-delta^2/(2*sigma^2)) is a positive similarity, but an arbitrary metric/geodesic distance need not produce a PSD Gram matrix. A logit bias does not require PSD; an additional kernel-method use needs a separate proof.
- **Positions and group actions:** RoPE rotation blocks use the relative action R_i^T R_j. Under a common left action, g_i^(-1)g_j is invariant; g_i g_j^(-1) cannot be substituted arbitrarily in a noncommutative group.
- **ALiBi:** visible positions receive a linear-distance logit penalty. Exponential decay concerns the bias factor of unnormalized weights; content logits can still give a distant token more weight.

## AI Module Form

$$O=\operatorname{softmax}_{j}\left(QK^T/\sqrt d+B+M\right)V,\quad B_{ij}=-\delta(i,j)^2/(2\sigma^2).$$

The following is a dense single-head baseline. Q and K may have different token counts; distance must have shape (m,n).

```python
import math
import torch

def geometric_attention(Q, K, V, distance, sigma, allowed=None):
    assert sigma > 0
    assert distance.shape == (Q.shape[0], K.shape[0])
    assert bool(torch.isfinite(distance).all()) and bool((distance >= 0).all())
    scores = (Q.float() @ K.float().T) / math.sqrt(Q.shape[-1])
    bias = -distance.float().square() / (2 * sigma * sigma)
    scores = scores + bias  # Direct log RBF avoids exp/log underflow and epsilon bias.
    if allowed is not None:
        assert bool(allowed.any(dim=-1).all())
        scores = scores.masked_fill(~allowed, -torch.inf)
    return torch.softmax(scores, dim=-1) @ V.float()
```

- **Euclidean coordinates [v]:** delta_ij=||x_i-x_j||_2 is invariant to common translations/orthogonal transforms. `MLP(x_i-x_j)` is generally translation invariant, but not automatically rotation invariant.
- **Tree distance [v]:** in an unweighted tree, delta(i,j)=depth(i)+depth(j)-2depth(LCA(i,j)). LCA depth alone is not a distance.
- **Manifolds [~]:** compute the appropriate geodesic distances from explicit positions and pass them to the baseline. General manifolds lack a global coordinate-difference operation; derivatives near cut loci/coincident points need attention.
- **Multidimensional RoPE [~]:** SO(2) rotation blocks form a block-diagonal SO(2)^k representation embedded in SO(2k). This does not imply arbitrary SO(2k) rotations preserve the required relative-position property.

## Implementable Architectures
Ablate distance biases, tree-position biases, and molecular distance features separately. Rotation-equivariant outputs also require compatible Value representations, content scores, masks, nonlinearities, and output maps; an invariant distance term alone is insufficient.

## GPU Feasibility
- **D1/D2 [v]:** QK and AV are GEMMs and the bias is additive. **[~]** Distances may require reductions, graph algorithms, or iterative solves; they are not universally elementwise.
- **D3 [v]:** naive pairwise distances in s-dimensional Euclidean space cost O(mns); attention costs O(mnd+mnd_v). General geodesic computation has additional solver costs.
- **D4 [v]:** naive distance and bias matrices each occupy O(mn) memory. **[~]** Avoiding materialization requires tile-computable distances or a suitable precomputed-access scheme.
- **D5 [~]:** large coordinate differences, spherical arccos, hyperbolic acosh, small sigma, and squaring can be unstable. Direct negative-square bias avoids redundant exp/log but still needs finite-value checks and fp32 comparisons.
- **D6 [~]:** tiles/heads may parallelize; measure dependencies of more complex geometry solvers separately.
- **D7 [v]:** small softmax weights are not actual sparse execution. **[~]** Explicit window/block masks and compatible sparse kernels are needed for potential computation savings.
- **D8 [~]:** additive bias is mathematically compatible with tiled online softmax, but arbitrary bias MLPs/geodesics need not be supported by an existing FlashAttention API; validate the implementation and backward pass.

## Paper Phrasing
“We introduce locality using a specified metric and a nonpositive monotone bias, distinguishing invariance of the bias from equivariance of the full module. We report quality across distance scales, distance-construction plus attention costs, and the supported operations of the actual kernel.”

## Risks
Geometry may conflict with task relevance, and monotone decay can suppress necessary remote connections. Fixed discrete graph/tree structures need no forced differentiable relaxation; a gradient/estimator scheme is needed only when differentiating through distances or structure. Arbitrary learned biases remove the monotonicity guarantee and must be described accordingly.

## Sources
[RoFormer](https://arxiv.org/abs/2104.09864) and [ALiBi](https://arxiv.org/abs/2108.12409) specify concrete positional mechanisms. Arbitrary geometric extensions here need independent proofs and validation.

Metric-dependent positive definiteness: [Jayasumana et al.](https://arxiv.org/abs/1412.0265).
