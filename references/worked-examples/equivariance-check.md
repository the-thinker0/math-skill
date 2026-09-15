# 案例：attention 的等变性在哪里失效？

用于 AI 等变设计/验证，配 [等变性锚点](../../knowledge-base/lie-theory/equivariance.md)。先指定群作用，不把 token 置换与通道旋转混为一谈。

## 精确成立的情形

$X\in\mathbb R^{n\times d}$，$P$ 为 token 置换矩阵。共享线性投影产生 $Q=XW_Q,K=XW_K,V=XW_V$，令 $S=QK^T/\sqrt{d_k}+B$。

若输入变为 $PX$ 且偏置/掩码同步变为 $PBP^T$，则 $S'=PSP^T$。逐行 softmax 满足 $\operatorname{softmax}(PSP^T)=P\operatorname{softmax}(S)P^T$，所以 $Y'=PY$。注意 score 矩阵是共轭变换，并非 $PSP^T=S$。

每行需至少有一个有限 logit。对含 $-\infty$ 的掩码，$PBP^T$ 表示同步重排行列索引，不能字面执行含 $0\cdot(-\infty)$ 的稠密乘法。

## 两个常见破坏点

- 固定位置编码 $E$：重排后用 $PX+E$ 通常不等于 $P(X+E)$。若声称只重排 token 仍等变，就必须改变对称群、移动位置标签或移除破坏项。
- 固定 causal mask：一般置换不保留时间顺序；仅在掩码同步置换或限制到保掩码子群时上述证明成立。因果顺序本来就是任务结构，不必为了任意置换等变而删除它。

## 有限群平均的正确公式

对有限群、实/复线性表示，任意 $f$ 的等变化为

$$\bar f(x)=\frac1{|G|}\sum_{g\in G}\rho_Y(g)^{-1}f(\rho_X(g)x).$$

令 $h=ga$ 换元可得 $\bar f(\rho_X(a)x)=\rho_Y(a)\bar f(x)$。少了输出端逆变换，一般只能得到不变平均，不能得到所需等变映射。大群枚举不可取；群采样平均只近似该投影。

## 验证方法

- 在小输入上比较 $f(PX;PBP^T)$ 与 $Pf(X;B)$，再分别固定位置编码或掩码，构造应当失效的对照。
- 报告归一化残差与绝对残差，避免零输出使相对误差失真。
- 随机层先用推理模式；若检验训练模式，需同步变换 dropout mask，并区分逐样本与分布等变性。
- 有限枚举可验证指定有限集合；对连续群的少量采样不能替代全群证明。

[群作用](../../knowledge-base/lie-theory/group-action.md) 提供所需定义；此处矩阵变换与换元证明为本仓库推导。

## 可运行检查

下面的 JavaScript 可用 Node.js 18+ 运行；仓库中的 `node --test tests/math-examples.test.mjs` 会执行中英两个版本。有限检查只核对本例，不替代上面的论证。

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
