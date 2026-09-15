# Information Bottleneck Loss
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
When a representation $Z$ must achieve an optimal balance between "retaining task-relevant information" and "compressing input redundancy." Typical scenarios: (1) Shared representations should retain only cross-task common information, discarding task-specific noise; (2) Private representations should retain only single-task unique information; (3) Routing features should maximize expert-task matching information. Core objective: **optimal information compression -- nothing more, nothing less, retaining only what is useful**.

## Mathematical Inspiration
- Lenses: ../../lenses/probabilistic.en.md (information bottleneck principle, mutual information variational), ../../lenses/variational.en.md (Lagrangian duality)
- Knowledge: ../../knowledge-base/probability/kl-divergence.en.md (IB theory, rate-distortion function), ../../knowledge-base/probability/entropy.en.md (mutual information and conditional entropy)

## Required Mathematical Knowledge

- For the Markov chain $Y-X-Z$, classic IB minimizes $I(X;Z)-\beta_{pred}I(Z;Y)$. Equivalently, rescale to $-I(Z;Y)+\beta_{comp}I(X;Z)$ with $\beta_{comp}=1/\beta_{pred}$.
- With encoder $q_\theta(z|x)$ and reference prior $r(z)$, $\mathbb E_x KL(q_\theta(z|x)\|r)=I(X;Z)+KL(q_\theta(z)\|r)\ge I(X;Z)$.
- A predictive decoder yields $I(Z;Y)\ge H(Y)+\mathbb E\log q_\phi(y|z)$. Cross-entropy estimates **positive** conditional entropy plus approximation error.
- MINE/NWJ/InfoNCE with restricted critics are lower bounds/estimators of MI, not certified upper bounds for a compression penalty. Minimizing a loose lower bound can hide information without reducing true MI. A neural-critic supremum equals true MI only with adequate function-class and optimization conditions.
- Orthogonality controls linear overlap; it does not guarantee shared/private statistical independence. [Deep VIB](https://arxiv.org/abs/1612.00410).

## AI Module Form

```python
# Stochastic Gaussian bottleneck, expectation approximated by a minibatch/sample
mu, logvar = encoder(X)
z = mu + exp(0.5 * logvar) * randn_like(mu)
kl_upper = 0.5 * (mu**2 + exp(logvar) - 1 - logvar).sum(-1).mean()
prediction_ce = cross_entropy(decoder(z), Y)
loss = prediction_ce + beta_comp * kl_upper
# Larger beta_comp increases compression pressure; beta_pred = 1 / beta_comp.
```
For shared/private branches use separate stochastic encoders, predictive targets, and compression weights. A decorrelation term is an additional proxy, not an information decomposition theorem. Deterministic continuous encoders can have infinite $I(X;Z)$; introduce noise/quantization or state a finite-data information model.

If a learned MI critic is used, maximize its bound for a fixed encoder before using it as a diagnostic. Compression via adversarial critic minimization remains a heuristic with an optimization gap; do not report its lower bound as a compression certificate.

## Implementable Architectures

- Dual encoder plus predictive heads; explicitly declare which labels define “shared” and “private.”
- Warm up `beta_comp` from zero if appropriate; report both prediction and KL curves.
- Audit Gaussian-posterior mismatch with richer encoder families or held-out likelihood diagnostics.
- Use a separate optimizer for an MI critic; a gradient-reversal sign must match the declared minimax objective.

## GPU Feasibility

- **D1/D2[~]**: Encoder/decoder use GEMM; diagonal-Gaussian KL is elementwise plus reduction.
- **D3/D4[~]**: KL costs $O(Bd_z)$ and stores $O(Bd_z)$ statistics. A learned critic adds its actual network cost and activations; there is no universal memory cap.
- **D5[~]**: Evaluate exp/log and KL reductions in fp32, constrain pathological log-variance, and monitor posterior collapse.
- **D6[~]**: Latent samples may batch; decoder/critic evaluations depend on encoder outputs, and alternating updates are sequential.
- **D7[N/A]**: Low MI or a small KL does not imply zero tensor entries or executable sparse channels.
- **D8[~]**: Elementwise KL can fuse; full encoder/critic fusion requires a concrete kernel and measurement.

## Paper Phrasing

“We optimize predictive cross-entropy plus a variational upper bound on input–representation mutual information. We report the compression-weight convention, bound gap diagnostics, predictive quality, and sensitivity to posterior family; this objective alone does not establish a generalization-error bound.”

## Risks
- Mutual information estimators (MINE/NWJ) have high variance, causing training instability; large batches or moving averages are needed
- Improper beta selection leads to over-compression (underfitting) or insufficient compression (overfitting)
- VIB assumes Gaussian posteriors, which may be inadequate for complex posterior distributions
- When optimizing multiple IB objectives jointly, the relative ratio of $\beta_1$ and $\beta_2$ is sensitive
