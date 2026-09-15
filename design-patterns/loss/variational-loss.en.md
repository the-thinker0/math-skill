# Variational Loss
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
When sampling from latent variable distributions is required to generate diverse outputs. Typical scenarios: (1) Expert selection introduces discrete latent variables $z$ that need end-to-end variational; (2) Representation spaces need to model uncertainty; (3) Generative routing requires sampling from posterior distributions $p(z|x)$; (4) Bayesian mixture of experts. Core objective: **model distributions rather than point estimates in latent space, enabling uncertainty awareness and diversity**.

## Mathematical Inspiration
- Lenses: ../../lenses/variational.en.md (variational inference and ELBO), ../../lenses/probabilistic.en.md (posterior and prior)
- Knowledge: ../../knowledge-base/probability/entropy.en.md (KL divergence, variational families), ../../knowledge-base/probability/kl-divergence.en.md (ELBO derivation)

## Required Mathematical Knowledge
- **ELBO (Evidence Lower Bound)**: $\log p(x) \geq \mathbb{E}_{q(z|x)}[\log p(x|z)] - \text{KL}(q(z|x) \| p(z))$ -- the first term is reconstruction likelihood, the second regularizes the posterior toward the prior
- **Reparameterization Trick**: $z = \mu + \sigma \odot \varepsilon$, $\varepsilon \sim \mathcal{N}(0, I)$ -- enables gradient backpropagation through sampling operations
- **Closed-Form KL Divergence**: When both $q$ and $p$ are Gaussian, $\text{KL}(\mathcal{N}(\mu,\sigma^2) \| \mathcal{N}(0,1)) = -\frac{1}{2} \sum(1 + \log \sigma^2 - \mu^2 - \sigma^2)$
- **Gumbel-Softmax (Discrete Latent Variables)**: $z = \text{softmax}((\log \pi + g) / \tau)$, $g \sim \text{Gumbel}(0,1)$ -- continuous relaxation of discrete sampling

## AI Module Form

```python
# Gaussian VAE; beta_vae=1 gives the ordinary negative ELBO
mu, logvar = encoder(x)
z = mu + exp(0.5 * logvar) * randn_like(mu)
KL = 0.5 * (mu**2 + exp(logvar) - 1 - logvar).sum(-1)
recon_nll = -decoder_log_prob(x, z)
loss = (recon_nll + beta_vae * KL).mean()

# Relaxed categorical latent: this is pathwise differentiation, not automatically STE
u = clamp(rand_like(logits), min=eps, max=1-eps)
g = -log(-log(u))
z_soft = softmax((logits + g) / tau, dim=-1)
# Optional straight-through hard sample:
z_hard = one_hot(argmax(z_soft, dim=-1), num_classes=K)
z_st = z_hard - z_soft.detach() + z_soft
```
A general beta-weighted objective is not automatically a lower bound on log evidence, and annealing does not guarantee avoidance of collapse. For categorical expert outputs of shape $B\times K\times d$, combine weights as `(z_soft[..., None] * expert_outputs).sum(dim=1)`; evaluating all experts has dense cost.

For VIB, `prediction_nll + beta_comp * KL` corresponds, after rescaling, to `I(X;Z) - beta_pred * I(Z;Y)` with `beta_pred = 1/beta_comp`. Do not reuse the same beta symbol for both inverse conventions.

## Implementable Architectures
- **Dual-Head Encoder Output**: Linear(d, 2 * d_z) -> split -> (mu, log_sigma^2), sharing base parameters
- **Beta Annealing Strategy**: Increasing beta from 0 may mitigate posterior collapse; validate it rather than treating it as a guarantee
- **Free Bits**: Set a KL lower bound lambda per dimension, penalizing only the excess: $\sum \max(\text{KL}_j, \lambda)$
- **IWAE Multi-Particle**: Use log-mean-exp over $K$ samples instead of single-sample ELBO for a tighter lower bound

## GPU Feasibility
- **Tensorization**: Computation of mu and sigma^2 is a Linear layer (GEMM); KL involves element-wise operations
- **GEMM-mappability**: Encoder 1 GEMM -> split -> reparameterization -> decoder 1 GEMM
- **Complexity**: Same order as standard feedforward networks $O(B \cdot d^2)$; KL computation $O(B \cdot d_z)$ is negligible
- **Memory & KV-Cache**: Additional storage of mu and sigma^2, two $B \times d_z$ matrices; minimal overhead
- **Low Precision Stability**: log/exp operations in KL are recommended in fp32; Gumbel softmax log-log requires fp32
- **Parallelism & Communication**: The $K$ samples in multi-particle IWAE can be sampled and computed in parallel
- **Sparse Structure**: The relaxed sample approaches one-hot as $\tau \to 0$, but finite-temperature execution is dense unless a hard dispatch mechanism skips inactive branches
- **Operator Fusion**: The Linear layers for mu and sigma^2 can share a single GEMM followed by split; KL exp/sub/add can be fused

## Paper Phrasing

“We use a stated variational family and the ordinary ELBO, or explicitly identify a beta-weighted surrogate. We report posterior-collapse diagnostics, reconstruction/prediction quality and sensitivity to latent dimension and sampling count; no universal ELBO convergence rate follows from dimensionality alone.”

## Risks
- Posterior collapse: The KL term converges to 0 prematurely, causing latent variables to degenerate into prior samples and lose information
- Gumbel-Softmax temperature $\tau$ annealing requires careful scheduling; too fast causes gradient vanishing, too slow loses discreteness
- IWAE multi-particle log-mean-exp is numerically unstable in high dimensions; log-sum-exp trick is needed
- Excessively large beta in beta-VAE degrades reconstruction quality; task-specific balancing is required
