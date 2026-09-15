# Score Matching & SDE

## Minimal Definition

The score is the gradient of the log-density $\nabla_x \log p(x)$ — definable without knowing the normalizing constant. Score matching learns unnormalized distributions by regressing the score; diffusion models upgrade this to a **noise-scale-dependent score family** $s_\theta(x, t) \approx \nabla_x \log p_t(x)$: a forward SDE adds noise, and a reverse SDE (or probability-flow ODE) follows the score to denoise and generate samples.

**Scope and signs**: Integration by parts requires differentiable densities/scores and vanishing boundary terms. The displayed reverse SDE uses time running from $T$ to $0$ ($dt<0$) and state-independent scalar diffusion $g(t)$; state-dependent diffusion needs additional divergence terms. Tweedie uses $x_t=\alpha_t x_0+\sigma_t\varepsilon$, $\varepsilon\sim N(0,I)$, $\alpha_t\ne0$. Matching SDE/ODE marginals assumes the exact score and regularity; learned scores and numerical solvers introduce error. [Original score-SDE paper](https://arxiv.org/abs/2011.13456).

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
- **Sampler design**: Compare reverse-SDE and probability-flow ODE discretizations under matched network-evaluation budgets and tolerances. A deterministic sampler need not be low-step or higher quality by definition; relate DDIM to an ODE only under the specific parameterization and schedule.
- **Flow matching / rectified flow**: Regress a conditional velocity for a specified interpolation path. Relations to score matching depend on the path and parameterization; straight paths and fewer evaluations are not automatic guarantees.
## Engineering Feasibility

- **Main operations**: training = one forward pass (predicting noise/score), isomorphic to ordinary supervised learning; sampling = multi-step network evaluation (10–1000 steps), the dominant inference cost
- **GPU friendliness**: training is excellent (pure regression); inference depends on step count — each step is a full forward pass, compressible via ODE solvers/distillation/consistency models
- **Complexity**: training $O(\text{forward})$; sampling $O(K \times \text{forward})$ with $K$ steps; no adversarial-training stability issues
- **Low precision**: Score error depends on noise scale, loss weighting and conditioning. Compare precision across the entire trajectory; use fp32 for sensitive solver states/reductions rather than assuming score regression is insensitive.

## Risks and Failure Conditions

- **Score explosion at low noise**: as $\sigma \to 0$ the score variance diverges and the DSM objective becomes dominated by small-noise terms; in practice use noise-weighted losses ($\lambda(t)$ weighting) or truncate the minimum noise level
- **Score is defined only on the support**: when data lies on a low-dimensional manifold the score is undefined off-manifold — exactly why noising is necessary; score behavior in extrapolated regions determines sampling trajectories
- **Time-discretization error of the reverse SDE**: with large step sizes the discretized reverse SDE no longer matches the forward marginals; ODE solver order and step count must be tuned jointly
- **Guidance**: A well-posed guided SDE/ODE still defines an output distribution. Arbitrary guidance need not sample the desired conditional or a single time-consistent tempered density; compare quality, diversity and guidance-induced numerical error.
- **Connection to adversarial examples**: small pixel-space changes in the score can cause large changes in generated content; downstream safety analysis cannot test only clean inputs

## Further References

- Distilled book: no dedicated SDE distillation in `../../references/books/` yet
- Song et al. "Score-Based Generative Modeling through Stochastic Differential Equations." *ICLR*, 2021
- Hyvärinen. "Estimation of non-normalized statistical models by score matching." *JMLR*, 2005
- Vincent. "A Connection Between Score Matching and Denoising Autoencoders." *Neural Computation*, 2011 (DSM)
- Karras et al. "Elucidating the Design Space of Diffusion-Based Generative Models." *NeurIPS*, 2022

## Routing Extensions

- For distribution divergences -> `kl-divergence.en.md` (Fisher divergence vs KL asymmetry)
- For Langevin convergence -> `concentration-inequality.en.md` (log-Sobolev and mixing times)
- For the geometry of interpolation paths -> `optimal-transport.en.md` (flow matching and displacement interpolation)
- For energy-based models -> `../information-geometry/fisher-metric.en.md` (score and the Fisher metric)

## Extensible Directions

- Langevin dynamics (ULA / MALA): score-driven MCMC sampling and its mixing time
- Schrödinger bridges: optimal diffusions with both endpoint distributions prescribed
- Consistency models: distilling multi-step sampling into a single step
- Score identities: Tweedie, second-order scores, and connections to the Hessian
- Discrete diffusion: score analogues on discrete state spaces (likelihood ratios)

- **Guidance**: classifier-free guidance writes the conditional score as $\tilde{s} = s_{\text{uncond}} + w(s_{\text{cond}} - s_{\text{uncond}})$; $w > 1$ strengthens conditioning at the cost of diversity
