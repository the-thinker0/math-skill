# Worked example: where does attention equivariance fail?

Use for AI equivariant design/verification with the [equivariance anchor](../../knowledge-base/lie-theory/equivariance.en.md). Specify the action first: token permutations and channel rotations are different symmetries.

## Exact case

Let $X\in\mathbb R^{n\times d}$ and let $P$ permute tokens. Shared linear projections give $Q=XW_Q,K=XW_K,V=XW_V$ and $S=QK^T/\sqrt{d_k}+B$.

Transforming input to $PX$ and bias/mask to $PBP^T$ gives $S'=PSP^T$. Row softmax obeys $\operatorname{softmax}(PSP^T)=P\operatorname{softmax}(S)P^T$, hence $Y'=PY$. Scores transform by conjugation; generally $PSP^T\ne S$.

Assume each row has at least one finite logit. For masks containing $-\infty$, $PBP^T$ denotes simultaneous row/column indexing, not literal dense arithmetic with $0\cdot(-\infty)$.

## Two failure points

- Fixed position encoding $E$: $PX+E$ generally differs from $P(X+E)$. A token-only equivariance claim must change the group, move position labels, or remove the offending term.
- Fixed causal mask: arbitrary permutations do not preserve temporal order. The proof requires transforming the mask or restricting to its symmetry subgroup. Temporal order may be essential to the task and need not be removed.

## Correct finite-group averaging

For a finite group and real/complex linear representations, equivariantize arbitrary $f$ by

$$\bar f(x)=\frac1{|G|}\sum_{g\in G}\rho_Y(g)^{-1}f(\rho_X(g)x).$$

Substitute $h=ga$ to obtain $\bar f(\rho_X(a)x)=\rho_Y(a)\bar f(x)$. Omitting the inverse output action generally produces invariant averaging, not the desired equivariant map. Large-group enumeration is infeasible; group-sampled averages only approximate this projection.

## Validation

- On small inputs compare $f(PX;PBP^T)$ and $Pf(X;B)$, then hold position encodings or the mask fixed as failure controls.
- Report normalized and absolute residuals; zero outputs can distort relative errors.
- Use evaluation mode for random layers. In training mode transform dropout masks consistently and distinguish samplewise from distributional equivariance.
- Finite enumeration verifies the specified finite set; sparse sampling of a continuous group does not replace a proof over the whole group.

The [group-action anchor](../../knowledge-base/lie-theory/group-action.en.md) supplies definitions; the matrix and change-of-variable arguments here are repository derivations.

## Runnable check

Run the following JavaScript with Node.js 18+. The repository test `node --test tests/math-examples.test.mjs` executes both language versions. These finite checks verify this example only; they do not replace the argument above.

```javascript
// Q = K = V = X, with a causal mask; all rows have a finite logit.
const x = [[1, 0], [0, 2], [-1, 1]];
const p = [2, 0, 1];
const mask = x.map((_, i) => x.map((_, j) => j <= i ? 0 : -Infinity));
function attention(z, bias) {
  return z.map((query, i) => {
    const logits = z.map((key, j) => query.reduce((s, q, k) => s + q * key[k], 0) / Math.SQRT2 + bias[i][j]);
    const max = Math.max(...logits);
    const weights = logits.map(s => Math.exp(s - max));
    const sum = weights.reduce((a, b) => a + b, 0);
    return query.map((_, k) => z.reduce((s, value, j) => s + weights[j] * value[k] / sum, 0));
  });
}
const px = p.map(i => x[i]);
const expected = p.map(i => attention(x, mask)[i]);
const transformedMask = p.map(i => p.map(j => mask[i][j]));
const error = (a, b) => Math.max(...a.flatMap((row, i) => row.map((v, j) => Math.abs(v - b[i][j]))));
if (error(attention(px, transformedMask), expected) > 1e-12) {
  throw new Error('Joint permutation equivariance failed');
}
if (error(attention(px, mask), expected) < 1e-3) {
  throw new Error('The fixed-mask failure control did not distinguish the cases');
}
```
