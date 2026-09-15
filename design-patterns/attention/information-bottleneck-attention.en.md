# Information Bottleneck Attention
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
When the attention mechanism needs to **selectively transmit useful information while suppressing redundant/noisy information**, information bottleneck theory can guide the learning of attention weights -- maximizing the mutual information $I(Z;Y)$ of the attention distribution with respect to the target $Y$, while minimizing the mutual information $I(X;Z)$ with respect to the input $X$. Typical scenarios include: long-document summarization (filtering large numbers of irrelevant tokens), multimodal alignment (cross-modal noise suppression), and interpretability (attention weights as visualization of information flow).

## Mathematical Inspiration
- Lenses: [categorical (information-theoretic framework unifying attention design), variational (constrained variational and Lagrangian duality)]
- Knowledge: [`../../knowledge-base/probability/information-bottleneck.en.md` (IB objective and variational lower bound), `../../knowledge-base/probability/kl-divergence.en.md` (implementation of KL regularization), `../../knowledge-base/probability/entropy.en.md` (mutual information estimation)]

## Required Mathematical Knowledge
- **Information Bottleneck Objective**: $\min I(X;Z) - \beta I(Z;Y)$, balancing compression and prediction
- **Variational Information Bottleneck (VIB)**: Replacing intractable mutual information with variational lower bounds
- **Correspondence Between Mutual Information and Attention**: Softmax attention weights $\alpha_{ij}$ can be interpreted as information channel allocations from key $j$ to query $i$

## AI Module Form

**Attention entropy proxy**:
```python
log_attn = log_softmax(Q @ K.T / sqrt(d), dim=-1)
attn = exp(log_attn)
entropy = -(attn * log_attn).sum(-1).mean()
kl_to_uniform = log(n) - entropy
loss_uniform = task_loss + beta * kl_to_uniform  # encourages diffuse attention
loss_concentrated = task_loss + beta * entropy   # encourages concentration, not exact zeros
output = attn @ V
```
A categorical channel $J\sim\operatorname{Cat}(a(X))$ satisfies $\mathbb E_X KL(a(X)\|r)=I(X;J)+KL(p_J\|r)$. This bounds the information of the **sampled index** $J$, not automatically the continuous context $Z=a(X)V(X)$, since $V$ also depends on $X$. Calling attention entropy a context information bottleneck needs this missing channel definition.

**Actual stochastic context bottleneck**:
```python
context = attn @ V
mu, logvar = linear_mu(context), linear_logvar(context)
z = mu + exp(0.5 * logvar) * randn_like(mu)
kl = 0.5 * (mu**2 + exp(logvar) - logvar - 1).sum(-1).mean()
loss = prediction_loss(task_head(z), target) + beta_comp * kl
```
A Gaussian KL on pre-softmax logits can upper-bound downstream simplex MI by data processing; it is not generally the exact KL of logistic-normal simplex distributions. If `infonce_loss` returns the usual nonnegative loss, **minimize it**; the MI lower bound is `log(num_candidates) - infonce_loss`. MINE/NWJ lower bounds cannot certify compression when minimized.

## Implementable Architectures

- Entropy-regularized attention for a measured concentration/uniformity preference.
- Stochastic context VIB for a declared input–latent information bound.
- Different head weights are design hyperparameters; dropout rates have no universal one-to-one mapping to IB beta.
- Executable sparsity requires explicit masks/top-k or sparse probability transforms and a supported kernel.

## GPU Feasibility

- **D1/D2[~]**: KL/entropy are elementwise reductions; Gaussian statistics require additional linear maps with their own GEMM costs.
- **D3/D4[~]**: Dense attention entropy costs $O(n^2)$ per head and can defeat memory savings if the full attention matrix is exposed. Context VIB statistics use $O(nd_z)$ storage, not a fixed doubling of attention-weight memory.
- **D5[~]**: Use fp32 log-softmax/reductions and bounded log-variance; masked probabilities need safe $0\log0$ handling.
- **D6/D8[~]**: Entropy depends on attention scores; a streaming implementation may accumulate it within the attention kernel, but backward and actual kernel support need validation.
- **D7[~]**: Low entropy is not block sparsity. Report retained blocks, dropped mass, output error and actual latency if sparsifying.

## Paper Phrasing

“We distinguish attention-entropy regularization from a stochastic context bottleneck. The former controls categorical weight concentration; the latter has an explicitly defined variational information upper bound. We report the corresponding entropy/KL, predictive quality, and measured implementation cost.”

## Risks
- **High Variance of Mutual Information Estimators**: The MINE/NWJ/InfoNCE estimators in Scheme C exhibit high variance in high-dimensional spaces, potentially causing training instability. It is recommended to first validate the basic effect of IB attention with Scheme A (KL regularization) before attempting the full IB objective.
- **Difficulty of $\beta$ Tuning**: $\beta$ controls the compression-prediction trade-off, and the optimal $\beta$ varies significantly across tasks. Too small a $\beta$ degenerates to standard attention; too large a $\beta$ causes underfitting. Adaptive $\beta$ scheduling or information plane monitoring is recommended.
