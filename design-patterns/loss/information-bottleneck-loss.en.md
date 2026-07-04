# Information Bottleneck Loss

## Applicable Problems
When a representation $Z$ must achieve an optimal balance between "retaining task-relevant information" and "compressing input redundancy." Typical scenarios: (1) Shared representations should retain only cross-task common information, discarding task-specific noise; (2) Private representations should retain only single-task unique information; (3) Routing features should maximize expert-task matching information. Core objective: **optimal information compression -- nothing more, nothing less, retaining only what is useful**.

## Mathematical Inspiration
- Lenses: lenses/probabilistic.md (information bottleneck principle, mutual information optimization), lenses/variational.md (Lagrangian duality)
- Knowledge: knowledge-base/probability/kl-divergence.md (IB theory, rate-distortion function), knowledge-base/probability/entropy.md (mutual information and conditional entropy)

## Required Mathematical Knowledge
- **Information Bottleneck Objective**: $\min I(X;Z) - \beta \cdot I(Z;Y)$, compressing $X \to Z$ while preserving the predictive power of $Z$ for $Y$
- **Variational Bounds on Mutual Information**:
  $I(X;Z) \leq \mathbb{E}_{p(x,z)}[\log q(z|x)] - \mathbb{E}_{p(z)}[\log q(z)]$ (upper bound for compression term)
  $I(Z;Y) \geq \mathbb{E}_{p(z,y)}[\log q(y|z)] + H(Y)$ (lower bound for prediction term)
- **CPC (Contrastive Predictive Coding)**: InfoNCE lower bound on $I(Z_t; Z_{t+k})$
- **MINE (Mutual Information Neural Estimation)**:
  $I(X;Z) = \sup_\theta \{ \mathbb{E}[\log T_\theta(x,z)] - \log \mathbb{E}[T_\theta(x,z')] \}$

## AI Module Form
```
Module: InformationBottleneckLoss
Input: representation Z in R^{B x d}, input X (or its encoding), label Y

Method 1 - VIB (Variational Information Bottleneck):
  // Compression upper bound: variational approximation q(z) = N(0, I)
  I_upper = KL(q(z|x) || p(z))  // standard VAE KL term
  // Prediction lower bound: classifier/regressor q(y|z)
  I_lower = CE(q(y|z), y)  // cross-entropy = estimate of -H(Y|Z)
  L_IB = I_upper + beta * I_lower
  // beta controls compression-prediction trade-off: larger beta = more aggressive compression

Method 2 - Contrastive Mutual Information Estimation (no distributional assumptions):
  // NWJ estimator instead of KL
  I_nwj(x;z) = E[f(x,z)] - exp(E[f(x,z')] - 1)  // f is a discriminator network
  L_IB_contrast = I_nwj(x;z) - beta * InfoNCE(z, y)  // both terms differentiable

Method 3 - Shared/Private IB Decomposition:
  Z_s = enc_shared(x), Z_p = enc_private(x)
  L = I(Z_s; X) + I(Z_p; X)           // total compression
    - beta_1 * I(Z_s; Y_common)        // Shared retains common information
    - beta_2 * I(Z_p; Y_specific)      // Private retains specific information
    + gamma * OrthLoss(Z_s, Z_p)       // orthogonality ensures decomposition
```

## Implementable Architectures
- **Dual-Encoder Architecture**: enc_shared and enc_private share a base trunk, branching into separate heads
- **Mutual Information Estimator**: Small MLP discriminator $T(x,z) \to$ scalar, alternating optimization with the main network
- **Beta Scheduling**: Set $\beta = 0$ at training start (no compression), gradually increase to target value during training
- **Gradient Reversal**: Gradient of $I(X;Z)$ is reversed via z.flip_gradient(), implementing adversarial compression

## GPU Feasibility
- **Tensorization**: Mutual information estimator is a standard MLP -> GEMM chain; KL is element-wise
- **GEMM-mappability**: VIB method requires only encoder GEMM + KL computation; contrastive method adds 1 GEMM for shuffled negatives
- **Complexity**: One additional KL term $O(B \cdot d)$ or one discriminator forward pass $O(B \cdot d^2)$ beyond the standard network; acceptable
- **Memory & KV-Cache**: Requires additional storage for discriminator parameters (small MLP) and intermediate activations, <10MB
- **Low Precision Stability**: The exp operation in the MINE estimator requires clipping under fp16; VIB KL is recommended in fp32
- **Parallelism & Communication**: Discriminator and main network forward passes can run in parallel; gradients are synchronized through the shared representation layer
- **Sparse Structure**: Compressed $Z$ dimensions can be dynamically pruned (Automatic Relevance Determination, ARD)
- **Operator Fusion**: Encoder forward + KL computation + discriminator forward can be partially fused

## Paper Phrasing
"Based on information bottleneck theory, we formalize Shared/Private decomposition as $\min I(X;Z_s) + I(X;Z_p) - \beta_1 I(Z_s;Y_c) - \beta_2 I(Z_p;Y_s)$, replacing mutual information terms with variational upper and lower bounds for end-to-end optimization, theoretically guaranteeing beta-optimality on the compression-prediction Pareto frontier."

## Risks
- Mutual information estimators (MINE/NWJ) have high variance, causing training instability; large batches or moving averages are needed
- Improper beta selection leads to over-compression (underfitting) or insufficient compression (overfitting)
- VIB assumes Gaussian posteriors, which may be inadequate for complex posterior distributions
- When optimizing multiple IB objectives jointly, the relative ratio of $\beta_1$ and $\beta_2$ is sensitive
