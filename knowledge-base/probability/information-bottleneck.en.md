# Information Bottleneck

## Minimal Definition
The Information Bottleneck (IB) is a theoretical framework for representation learning: given input $X$ and target $Y$, find a compressed representation $Z$ that **discards as much information in $X$ that is irrelevant to $Y$ as possible, while retaining information useful for predicting $Y$**. It recasts the learning problem as an information-theoretic constrained optimization.

## Core Formulas

**IB Objective**:
$$\min_{q(z|x)} I(X;Z)-\beta_{pred}I(Z;Y)$$

where $\beta_{pred}>0$ controls the **compression–prediction** trade-off:
- $I(X; Z)$: the amount of information about input $X$ retained in representation $Z$ (smaller = stronger compression)
- $I(Z; Y)$: the amount of information about target $Y$ contained in representation $Z$ (larger = better prediction)

**Variational objective bound** (encoder defines $q(z|x)$; use $\beta_{pred}$ above and $\beta_{comp}=1/\beta_{pred}$ below):
$$\mathcal L_{VIB}=\mathbb E_{p(x,y)q_\theta(z|x)}[-\log q_\phi(y|z)]+\beta_{comp}\,\mathbb E_{p(x)}D_{KL}(q_\theta(z|x)\|r(z)).$$

Here $q_\phi(y|z)$ is the predictive distribution and $r(z)$ a reference prior. The compression identity is $\mathbb E_x KL(q(z|x)\|r)=I(X;Z)+KL(q(z)\|r)\ge I(X;Z)$; prediction uses a lower bound on $I(Z;Y)$. Minimize the resulting **upper bound on the negative utility**, with expectations over the stochastic encoder. [Deep VIB](https://arxiv.org/abs/1612.00410).

**IB curve**: For an unrestricted stochastic encoder with time sharing, the optimal relevance as a function of the allowed information rate is nondecreasing and concave. Restricted neural encoder families can depart from this frontier; there is no universal inflection-point rule for choosing compression.

## Applicable Problems
- **Understanding the learning dynamics of deep networks**: Information Plane analysis — tracking the trajectory of $(I(X;Z_l), I(Z_l;Y))$ for each layer during training
- **Theoretical guidance for representation learning**: Why regularization (dropout, weight decay) works — they implicitly compress redundant information
- **Feature selection and dimensionality reduction**: Finding Pareto-optimal points between compression rate and predictive performance

## AI Design Translation
- **VIB Layer (Variational Information Bottleneck)**: Encoder $p_\theta(z|x)$ + KL regularization + decoder $q_\phi(y|z)$; structurally identical to a VAE but with different objective semantics (VAE reconstructs $X$, VIB predicts $Y$)
- **Beta-VAE comparison**: Both use an encoder-to-prior KL plus a prediction/reconstruction term. Their targets and information semantics differ; always identify whether beta weights compression or relevance.
- **Information-theoretic interpretation of attention sparsification / routing**: Sparse Attention and MoE routing can be understood as implicit information bottlenecks — selectively allowing "useful" tokens to pass while discarding noise

## Engineering Feasibility
- **D1[v]**: The VIB encoder/decoder are standard networks; $D_{KL}$ is computed element-wise
- **D2[v]**: The main computation is a standard feedforward network + GEMM
- **D3[v]**: Only adds $O(d)$ computation for the KL term compared to the original network
- **D4[~]**: A fixed prior has no learned parameters; a Gaussian stochastic encoder usually adds mean/log-variance outputs and sampled latent activations. Count these explicitly.
- **D5[~]**: Use fp32 KL reductions and range-aware log-variance; Gaussian exp terms can overflow even when the network matmuls use bf16.
- **D8[v]**: No conflict with the standard training pipeline; normal fusion applies

## Risks and Failure Conditions
- **Bound gap**: VIB uses an upper bound for compression and a lower bound for relevance. The reference-prior mismatch can make compression bounds loose; MINE/NWJ lower bounds do not certify compression when minimized.
- **Beta convention**: Larger `beta_comp` in prediction loss + `beta_comp * KL` encourages compression; larger `beta_pred` in classic IB encourages relevance. State the reciprocal conversion before scheduling or comparing papers.

## Further References
- Distillation draft: `../../references/books/` — no dedicated IB distillation draft at present
- Tishby, Pereira, Bialek. "The Information Bottleneck Method." *arXiv:physics/0004057*, 2000
- Alemi, Poole, Fischer, Dillon, Suresh, Murphy. "Deep Variational Information Bottleneck." *ICLR*, 2017
- Shwartz-Ziv, Tishby. "Opening the Black Box of Deep Neural Networks via Information." *arXiv:1703.00810*, 2017
- Related knowledge cards: `entropy.en.md`, `kl-divergence.en.md`


## Routing Extensions
- If the KL component in IB objective is needed -> `kl-divergence.en.md` (KL component of IB objective)
- If rate-distortion theory is involved -> `entropy.en.md` (relationship between IB and rate-distortion theory)
- If used for VIB loss design -> `variational-loss` (design pattern layer for variational information bottleneck loss)

## Extensible Directions
- Rate-distortion theory: optimal compression bounds from information theory
- Deterministic IB: IB variant with deterministic encoding
- Geometric IB: information bottleneck under geometric structure
- IB for representation learning: feature learning under IB framework
- IB for clustering: IB-driven clustering algorithms
- Deep IB: information bottleneck in deep networks
- IB with multiple bottlenecks: multi-layer information constraints
- IB generalization bounds: theoretical connection between IB and generalization
