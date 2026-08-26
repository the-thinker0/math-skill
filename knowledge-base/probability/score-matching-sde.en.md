# Score Matching & SDE

## Minimal Definition

The score is the gradient of the log-density $\nabla_x \log p(x)$ — definable without knowing the normalizing constant. Score matching learns unnormalized distributions by regressing the score; diffusion models upgrade this to a **noise-scale-dependent score family** $s_\theta(x, t) \approx \nabla_x \log p_t(x)$: a forward SDE adds noise, and a reverse SDE (or probability-flow ODE) follows the score to denoise and generate samples.

## Core Formulas

- **Score**: $s(x) = \nabla_x \log p(x)$, independent of the normalizing constant
- **Fisher divergence (score-matching objective)**: $J(\theta) = \frac{1}{2}\mathbb{E}_{p}\|s_\theta(x) - \nabla_x \log p(x)\|^2$
- **Integration by parts removes the true score** (Hyvärinen): $J(\theta) = \mathbb{E}_{p}\left[\operatorname{tr}(\nabla_x s_\theta) + \frac{1}{2}\|s_\theta\|^2\right] + \text{const}$, involving only model quantities
- **Denoising score matching (DSM)**: $\mathbb{E}_{p(x)}\mathbb{E}_{q_\sigma(\tilde{x}|x)}\|s_\theta(\tilde{x}) - \nabla_{\tilde{x}} \log q_\sigma(\tilde{x}|x)\|^2$; for a Gaussian kernel $\nabla_{\tilde{x}} \log q_\sigma = -(\tilde{x} - x)/\sigma^2$, i.e., "predict the noise"
- **Forward SDE**: $dx = f(x, t)dt + g(t)dw$; **reverse SDE** (Anderson): $dx = [f - g^2 \nabla_x \log p_t(x)]dt + g\, d\bar{w}$ — knowing the score inverts time
- **Probability-flow ODE**: $dx = [f - \frac{1}{2}g^2 \nabla_x \log p_t(x)]dt$, sharing marginals with the SDE, enabling deterministic sampling
- **Tweedie's formula**: $\mathbb{E}[x_0 | x_t] = (x_t + \sigma_t^2\, s(x_t, t))/\alpha_t$ — the score gives the one-step denoised posterior mean

## Applicable Problems

- **Generative modeling**: the mainstream route for image/audio/molecule generation (DDPM, score SDE, flow matching family)
- **Learning unnormalized distributions**: energy-based models avoid the partition function; Langevin sampling needs only the score
- **Inverse problems**: in posterior sampling $p(x|y) \propto p(y|x)p(x)$, the prior score comes from a diffusion model while the likelihood term is handled separately
- **Density-ratio and KL estimation**: score differences give gradients of log density ratios

## AI Design Translation

- **Diffusion model training**: the DSM objective = predicting the injected noise $\epsilon$ (equivalent to predicting the score up to a $-\sigma_t$ factor); the loss $\|\epsilon_\theta(x_t, t) - \epsilon\|^2$ is a plain MSE with a UNet/DiT network
- **Sampler design**: reverse SDE (stochastic, many steps, high quality) vs probability-flow ODE (deterministic, accelerable to 10–20 steps with high-order ODE solvers); DDIM is a first-order discretization of the ODE
- **Flow matching / rectified flow**: directly regress the velocity field of an interpolation path between noise and data; the training objective is isomorphic to DSM but with straighter paths and fewer sampling steps
## Engineering Feasibility

- **Main operations**: training = one forward pass (predicting noise/score), isomorphic to ordinary supervised learning; sampling = multi-step network evaluation (10–1000 steps), the dominant inference cost
- **GPU friendliness**: training is excellent (pure regression); inference depends on step count — each step is a full forward pass, compressible via ODE solvers/distillation/consistency models
- **Complexity**: training $O(\text{forward})$; sampling $O(K \times \text{forward})$ with $K$ steps; no adversarial-training stability issues
- **Low precision**: score regression is insensitive to numerical error and bf16 training is mature; but error accumulates over long sampling trajectories — keep critical steps in fp32

## Risks and Failure Conditions

- **Score explosion at low noise**: as $\sigma \to 0$ the score variance diverges and the DSM objective becomes dominated by small-noise terms; in practice use noise-weighted losses ($\lambda(t)$ weighting) or truncate the minimum noise level
- **Score is defined only on the support**: when data lies on a low-dimensional manifold the score is undefined off-manifold — exactly why noising is necessary; score behavior in extrapolated regions determines sampling trajectories
- **Time-discretization error of the reverse SDE**: with large step sizes the discretized reverse SDE no longer matches the forward marginals; ODE solver order and step count must be tuned jointly
- **Guidance is not free**: large $w$ strengthens conditioning but sharpens the distribution and reduces diversity; strictly speaking the result is no longer sampling from any well-defined distribution
- **Connection to adversarial examples**: small pixel-space changes in the score can cause large changes in generated content; downstream safety analysis cannot test only clean inputs

## Further References

- Distilled book: no dedicated SDE distillation in `../../references/books/` yet
- Song et al. "Score-Based Generative Modeling through Stochastic Differential Equations." *ICLR*, 2021
- Hyvärinen. "Estimation of non-normalized statistical models by score matching." *JMLR*, 2005
- Vincent. "A Connection Between Score Matching and Denoising Autoencoders." *Neural Computation*, 2011 (DSM)
- Karras et al. "Elucidating the Design Space of Diffusion-Based Generative Models." *NeurIPS*, 2022

## Routing Extensions

- For distribution divergences -> `kl-divergence.md` (Fisher divergence vs KL asymmetry)
- For Langevin convergence -> `concentration-inequality.md` (log-Sobolev and mixing times)
- For the geometry of interpolation paths -> `optimal-transport.md` (flow matching and displacement interpolation)
- For energy-based models -> `../information-geometry/fisher-metric.md` (score and the Fisher metric)

## Extensible Directions

- Langevin dynamics (ULA / MALA): score-driven MCMC sampling and its mixing time
- Schrödinger bridges: optimal diffusions with both endpoint distributions prescribed
- Consistency models: distilling multi-step sampling into a single step
- Score identities: Tweedie, second-order scores, and connections to the Hessian
- Discrete diffusion: score analogues on discrete state spaces (likelihood ratios)

- **Guidance**: classifier-free guidance writes the conditional score as $\tilde{s} = s_{\text{uncond}} + w(s_{\text{cond}} - s_{\text{uncond}})$; $w > 1$ strengthens conditioning at the cost of diversity
