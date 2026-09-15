# Worked example: does low-rank error control attention error?

Use for AI compression design or mathematical verification. Start with the [low-rank anchor](../../knowledge-base/matrix-analysis/low-rank-approximation.en.md); do not load other examples by default.

## Claim

Let $K\in\mathbb R^{n\times d}$, $V\in\mathbb R^{n\times d_v}$, $q\in\mathbb R^d$, $a=\operatorname{softmax}(Kq/\sqrt d)$, and $y=V^Ta$. Rank-$r$ SVD minimizes matrix reconstruction error, not output error for every query.

## Two-dimensional counterexample

Take $0<\epsilon<1$, $K=\operatorname{diag}(1,\epsilon)$, $\hat K=\operatorname{diag}(1,0)$, $V=(0,1)^T$, and $q=(0,\sqrt2/\epsilon)^T$.

- $\|K-\hat K\|_2=\|K-\hat K\|_F=\epsilon\to0$; $\hat K$ is the optimal rank-1 truncation.
- Original logits are $(0,1)$; approximated logits are $(0,0)$.
- $y=e/(1+e)$ and $\hat y=1/2$, giving error about $0.2311$ independent of $\epsilon$.

The query norm grows as $1/\epsilon$. This refutes the universal claim without a query constraint.

## A conditional bound

The following is a derivation for this example, not a cited new theorem. The softmax Jacobian is $J=\operatorname{diag}(a)-aa^T$; its row absolute sums are $2a_i(1-a_i)\le1/2$, so symmetry gives $\|J\|_2\le1/2$. Integrating the Jacobian and writing $\hat y=\hat V^T\hat a$ yields

$$\|y-\hat y\|_2\le\frac{\|V\|_2\|q\|_2}{2\sqrt d}\|K-\hat K\|_2+\|V-\hat V\|_2.$$

This uses $\|\hat a\|_2\le1$. A uniform bound additionally needs $\|q\|_2\le B$ and controlled $\|V\|_2$. It is a single-layer bound, not a generation-quality or multilayer guarantee.

## Research plan

1. Select rank/subspace on calibration queries; evaluate independent queries and long-range retrieval. Include queries sensitive to spectral-tail directions.
2. Compare full cache, truncated SVD at equal memory, and query-weighted candidates. Include basis construction and refresh costs.
3. Storing $n\times r$ coefficients and a $d\times r$ basis for each of two $n\times d$ caches uses $2r(n+d)$ elements versus $2nd$. A basis alone cannot recover token coefficients.
4. Fix device, dtype, batch, and context length. After warmup report latency distributions, peak memory, and separate construction/decode costs; reduced FLOPs do not substitute for throughput measurements.

## Adoption criterion

Adopt only when independent-data quality meets the user's budget and resource gains cover construction costs. If the bound is loose, investigate query assumptions rather than relabeling SVD optimality as task optimality.

[Attention Is All You Need](https://arxiv.org/abs/1706.03762) defines scaled dot-product attention; the counterexample and bound above are repository derivations.

## Runnable check

Run the following JavaScript with Node.js 18+. The repository test `node --test tests/math-examples.test.mjs` executes both language versions. These finite checks verify this example only; they do not replace the argument above.

```javascript
// A finite numerical check of the documented counterexample, not a proof.
for (const epsilon of [0.1, 0.001, 0.000001]) {
  const q = [0, Math.SQRT2 / epsilon];
  const logits = [q[0] / Math.SQRT2, epsilon * q[1] / Math.SQRT2];
  const original = Math.exp(logits[1]) / (Math.exp(logits[0]) + Math.exp(logits[1]));
  const approximate = 0.5;
  const error = Math.abs(original - approximate);
  const bound = Math.hypot(...q) * epsilon / (2 * Math.SQRT2);
  if (Math.abs(error - 0.2310585786300049) > 1e-12 || error > bound) {
    throw new Error('Counterexample or conditional bound failed');
  }
}
// At q = 0, changing V can still change the output; a K-only bound is insufficient.
const zeroQueryError = Math.abs((0 + 1) / 2 - (0 + 0) / 2);
if (zeroQueryError !== 0.5) throw new Error('Value-error control failed');
```
