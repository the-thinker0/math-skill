# 案例：低秩误差能保证 attention 误差吗？

仅用于 AI 压缩设计或数学验证；先读 [低秩锚点](../../knowledge-base/matrix-analysis/low-rank-approximation.md)，不默认加载其他案例。

## 要验证的主张

设 $K\in\mathbb R^{n\times d}$、$V\in\mathbb R^{n\times d_v}$、$q\in\mathbb R^d$，$a=\operatorname{softmax}(Kq/\sqrt d)$、$y=V^Ta$。rank-$r$ SVD 优化的是矩阵重构误差，不直接优化所有 query 的输出误差。

## 二维反例

取 $0<\epsilon<1$，$K=\operatorname{diag}(1,\epsilon)$，$\hat K=\operatorname{diag}(1,0)$，$V=(0,1)^T$，$q=(0,\sqrt2/\epsilon)^T$。

- $\|K-\hat K\|_2=\|K-\hat K\|_F=\epsilon\to0$，且 $\hat K$ 是最优 rank-1 截断。
- 原 logits 为 $(0,1)$，近似 logits 为 $(0,0)$。
- $y=e/(1+e)$、$\hat y=1/2$，误差约 $0.2311$，不随 $\epsilon$ 消失。

这里 query 范数随 $1/\epsilon$ 增长；反例推翻的是没有 query 约束的全称保证。

## 可成立的条件界

以下是本案例的推导，不是引用论文的新定理。softmax Jacobian 为 $J=\operatorname{diag}(a)-aa^T$；每行绝对和 $2a_i(1-a_i)\le1/2$，故对称矩阵 $\|J\|_2\le1/2$。由均值积分形式，若 $\hat y=\hat V^T\hat a$，

$$\|y-\hat y\|_2\le\frac{\|V\|_2\|q\|_2}{2\sqrt d}\|K-\hat K\|_2+\|V-\hat V\|_2.$$

用到 $\|\hat a\|_2\le1$；给统一界需另有 $\|q\|_2\le B$ 和可控 $\|V\|_2$。这仍只是单层输出界，不自动保证生成质量或多层误差。

## 可执行研究方案

1. 在校准 query 上选秩/子空间，在独立 query 与长程检索样本上比较输出误差与任务质量；增加对谱尾方向敏感的 query。
2. 对照完整 cache、相同内存预算的截断 SVD 与 query 加权候选；同时报告基底构造/刷新开销。
3. 两个 $n\times d$ cache 各存 $n\times r$ 系数和 $d\times r$ 基底时，共 $2r(n+d)$ 个元素，对比原 $2nd$；仅存基底无法恢复各 token 系数。
4. 固定设备、dtype、batch 与上下文长度；预热后报告延迟分布、峰值显存、构建与 decode 分项。FLOPs 降低不能替代吞吐实测。

## 何时采用

只在独立数据达到用户质量预算且端到端资源收益覆盖构建成本时采用。若单层误差界松，继续验证 query 分布假设，不把 SVD 最优性写成任务最优性。

[Attention Is All You Need](https://arxiv.org/abs/1706.03762) 提供 scaled dot-product attention 定义；上面的反例和误差推导为本仓库构造。

## 可运行检查

下面的 JavaScript 可用 Node.js 18+ 运行；仓库中的 `node --test tests/math-examples.test.mjs` 会执行中英两个版本。有限检查只核对本例，不替代上面的论证。

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
