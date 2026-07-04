# Variational Loss
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as ✅ verified / ⚠️ retrofittable (needs validation) / ❌ infeasible. Unmarked claims are theoretically possible but require engineering validation.
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「✅ 已验证 / ⚠️ 可改造需验证 / ❌ 不可行」。未标注的视为理论可行，需工程验证。

## Applicable Problems
When sampling from latent variable distributions is required to generate diverse outputs. Typical scenarios: (1) Expert selection introduces discrete latent variables $z$ that need end-to-end variational; (2) Representation spaces need to model uncertainty; (3) Generative routing requires sampling from posterior distributions $p(z|x)$; (4) Bayesian mixture of experts. Core objective: **model distributions rather than point estimates in latent space, enabling uncertainty awareness and diversity**.

## Mathematical Inspiration
- Lenses: lenses/probabilistic.md (variational inference and ELBO), lenses/probabilistic.md (posterior and prior)
- Knowledge: knowledge-base/probability/entropy.md (KL divergence, variational families), knowledge-base/probability/kl-divergence.md (ELBO derivation)

## Required Mathematical Knowledge
- **ELBO (Evidence Lower Bound)**: $\log p(x) \geq \mathbb{E}_{q(z|x)}[\log p(x|z)] - \text{KL}(q(z|x) \| p(z))$ -- the first term is reconstruction likelihood, the second regularizes the posterior toward the prior
- **Reparameterization Trick**: $z = \mu + \sigma \odot \varepsilon$, $\varepsilon \sim \mathcal{N}(0, I)$ -- enables gradient backpropagation through sampling operations
- **Closed-Form KL Divergence**: When both $q$ and $p$ are Gaussian, $\text{KL}(\mathcal{N}(\mu,\sigma^2) \| \mathcal{N}(0,1)) = -\frac{1}{2} \sum(1 + \log \sigma^2 - \mu^2 - \sigma^2)$
- **Gumbel-Softmax (Discrete Latent Variables)**: $z = \text{softmax}((\log \pi + g) / \tau)$, $g \sim \text{Gumbel}(0,1)$ -- continuous relaxation of discrete sampling

## AI Module Form
```
Module: VariationalLoss
Input: encoder outputs (mu, log_sigma^2) in R^{B x d_z}, reconstruction output x_hat in R^{B x d_x}, original input x

Method 1 - Gaussian VAE Loss:
  KL = -0.5 * sum(1 + log_sigma^2 - mu^2 - exp(log_sigma^2), dim=-1)   // closed form
  recon = -log p(x|x_hat)  // MSE or BCE depending on data distribution
  L_vae = recon + beta * KL    // beta-VAE controls disentanglement

Method 2 - Gumbel-Softmax (discrete expert selection):
  logits = encoder(x)  in R^{B x K}    // logits for K experts
  g = -log(-log(uniform(B x K) + eps) + eps)   // Gumbel noise sampling
  z_soft = softmax((logits + g) / tau)       // temperature tau annealed from 1.0 to 0.1
  L_gumbel = CE(task_head(z_soft * features), y)  // straight-through estimator backprop

Method 3 - Variational Information Bottleneck:
  L_IB = -I(X; Z) + beta * I(Z; Y)  // maximize MI between Z and X, minimize redundancy between Z and Y
  ~ E[-log q(x|z)] + beta * KL(q(z|x) || p(z))  // variational approximation
```

## Implementable Architectures
- **Dual-Head Encoder Output**: Linear(d, 2 * d_z) -> split -> (mu, log_sigma^2), sharing base parameters
- **Beta Annealing Strategy**: Linearly increase beta from 0 to the target value to prevent KL collapse (posterior collapse)
- **Free Bits**: Set a KL lower bound lambda per dimension, penalizing only the excess: $\sum \max(\text{KL}_j, \lambda)$
- **IWAE Multi-Particle**: Use log-mean-exp over $K$ samples instead of single-sample ELBO for a tighter lower bound

## GPU Feasibility
- **Tensorization**: Computation of mu and sigma^2 is a Linear layer (GEMM); KL involves element-wise operations
- **GEMM-mappability**: Encoder 1 GEMM -> split -> reparameterization -> decoder 1 GEMM
- **Complexity**: Same order as standard feedforward networks $O(B \cdot d^2)$; KL computation $O(B \cdot d_z)$ is negligible
- **Memory & KV-Cache**: Additional storage of mu and sigma^2, two $B \times d_z$ matrices; minimal overhead
- **Low Precision Stability**: log/exp operations in KL are recommended in fp32; Gumbel softmax log-log requires fp32
- **Parallelism & Communication**: The $K$ samples in multi-particle IWAE can be sampled and computed in parallel
- **Sparse Structure**: Discrete latent variables (Gumbel) degenerate to one-hot as $\tau \to 0$, naturally sparse
- **Operator Fusion**: The Linear layers for mu and sigma^2 can share a single GEMM followed by split; KL exp/sub/add can be fused

## Paper Phrasing
"We adopt the variational inference framework, geometric expert selection as posterior inference over discrete latent variables $z$. End-to-end variational is achieved through Gumbel-Softmax relaxation, combined with a beta annealing strategy that effectively prevents posterior collapse. The ELBO lower bound converges at rate $O(\sqrt{d/n})$ with respect to latent variable dimensionality."

## Risks
- Posterior collapse: The KL term converges to 0 prematurely, causing latent variables to degenerate into prior samples and lose information
- Gumbel-Softmax temperature $\tau$ annealing requires careful scheduling; too fast causes gradient vanishing, too slow loses discreteness
- IWAE multi-particle log-mean-exp is numerically unstable in high dimensions; log-sum-exp trick is needed
- Excessively large beta in beta-VAE degrades reconstruction quality; task-specific balancing is required
