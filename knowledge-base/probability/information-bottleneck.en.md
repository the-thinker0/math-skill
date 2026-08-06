# Information Bottleneck

## Minimal Definition
The Information Bottleneck (IB) is a theoretical framework for representation learning: given input $X$ and target $Y$, find a compressed representation $Z$ that **discards as much information in $X$ that is irrelevant to $Y$ as possible, while retaining information useful for predicting $Y$**. It recasts the learning problem as an information-theoretic constrained optimization.

## Core Formulas

**IB Objective**:
$$\min_{p(z|x)} \; I(X; Z) - \beta \cdot I(Z; Y)$$

where $\beta > 0$ is a Lagrange multiplier controlling the **compression-prediction** trade-off:
- $I(X; Z)$: the amount of information about input $X$ retained in representation $Z$ (smaller = stronger compression)
- $I(Z; Y)$: the amount of information about target $Y$ contained in representation $Z$ (larger = better prediction)

**Variational Lower Bound** (practically computable version):
$$\mathcal{L}_{VIB} = \mathbb{E}_{p(x,y)}[-\log q_\phi(y|z)] + \beta \, D_{KL}(p_\theta(z|x) \| r(z))$$

where $q_\phi(y|z)$ is the classifier/decoder, $r(z)$ is the prior distribution (typically $\mathcal{N}(0,I)$), and $p_\theta(z|x)$ is the encoder.

**IB Curve**: In the $(I(X;Z), I(Z;Y))$ plane, the Pareto-optimal solutions form a concave curve, with inflection points corresponding to optimal compression rates.

## Applicable Problems
- **Understanding the learning dynamics of deep networks**: Information Plane analysis — tracking the trajectory of $(I(X;Z_l), I(Z_l;Y))$ for each layer during training
- **Theoretical guidance for representation learning**: Why regularization (dropout, weight decay) works — they implicitly compress redundant information
- **Feature selection and dimensionality reduction**: Finding Pareto-optimal points between compression rate and predictive performance

## AI Design Translation
- **VIB Layer (Variational Information Bottleneck)**: Encoder $p_\theta(z|x)$ + KL regularization + decoder $q_\phi(y|z)$; structurally identical to a VAE but with different objective semantics (VAE reconstructs $X$, VIB predicts $Y$)
- **Unified perspective on $\beta$-VAE**: The $\beta$-VAE objective is formally identical to the VIB objective, where $\beta$ is the IB Lagrange multiplier
- **Information-theoretic interpretation of attention sparsification / routing**: Sparse Attention and MoE routing can be understood as implicit information bottlenecks — selectively allowing "useful" tokens to pass while discarding noise

## Engineering Feasibility
- **D1[v]**: The VIB encoder/decoder are standard networks; $D_{KL}$ is computed element-wise
- **D2[v]**: The main computation is a standard feedforward network + GEMM
- **D3[v]**: Only adds $O(d)$ computation for the KL term compared to the original network
- **D4[~]**: Requires additional parameters for the prior distribution $r(z)$ and intermediate quantities for KL computation
- **D5[v]**: Reparameterization trick + analytical KL solution are stable in bf16
- **D8[v]**: No conflict with the standard training pipeline; normal fusion applies

## Risks and Failure Conditions
- **Accurate estimation of $I(X;Z)$ is difficult**: Mutual information estimation between high-dimensional continuous variables is itself an open problem (estimators such as MINE and NWJ have high variance). In practice, the VIB variational lower bound is used as a workaround, but the bound may be loose.
- **Sensitive to $\beta$ tuning**: If $\beta$ is too large, excessive compression leads to underfitting; if too small, the objective degenerates to standard ERM (no compression effect). Information plane analysis or adaptive $\beta$ scheduling is required.

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
