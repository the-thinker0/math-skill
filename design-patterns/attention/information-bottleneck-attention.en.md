# Information Bottleneck Attention
> **Rigor disclaimer**: Claims about complexity, memory, FlashAttention fusion, Tensor Core, and KV-Cache compression are marked as [v] verified / [~] retrofittable (needs validation) / [x] infeasible. Unmarked claims are theoretically possible but require engineering validation.

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

**Core Idea**: Treat attention as an information bottleneck -- attention weights determine "how much information flows from values to output," while KL regularization constrains the information throughput.

**Scheme A: KL-Regularized Attention (Simplest IB Attention)**:
```python
# KL divergence between attention distribution q(z|x) and uniform prior as IB regularizer
scores = (Q @ K.T) / sqrt(d)
attn = softmax(scores)
uniform_prior = ones_like(attn) / n
kl_reg = (attn * (log(attn + eps) - log(uniform_prior))).sum(dim=-1).mean()
loss = task_loss + beta * kl_reg
output = attn @ V
```

**Scheme B: Variational Information Bottleneck Attention (VIB-Attention)**:
```python
# Introduce stochastic bottleneck Z ~ q(Z|attention) to limit information throughput
scores = (Q @ K.T) / sqrt(d)
attn = softmax(scores)
mu_z, log_var_z = attn, linear(attn)  # mean and learnable variance
z = softmax(mu_z + exp(0.5 * log_var_z) * randn_like(mu_z))  # reparameterization + softmax
kl = 0.5 * (mu_z^2 + exp(log_var_z) - log_var_z - 1).sum(-1).mean()  # KL vs prior
output = z @ V
loss = task_loss + beta * kl
```

**Scheme C: Mutual Information Maximization Attention (DIM Style)**:
```python
# Directly maximize I(Z;Y) via InfoNCE, with KL constraining I(X;Z)
Z = softmax((Q @ K.T) / sqrt(d)) @ V
info_nce = infonce_loss(Z, target_embedding, negatives, tau=0.1)
kl_bottleneck = estimate_kl(X, Z)  # MINE/NWJ estimator
loss = -info_nce + beta * kl_bottleneck
```

## Implementable Architectures
- **IB-Sparse Attention**: KL regularization serves as a soft constraint on attention sparsity -- larger KL relative to uniform prior leads to more concentrated attention, yielding implicit Top-K selection
- **IB Interpretation of Dropout**: Dropout is a form of stochastic information bottleneck -- randomly blocking information channels forces the model to learn robust representations. The dropout rate corresponds to the $\beta$ parameter
- **Multi-Head Information Allocation**: Different heads learn different information bottlenecks (different $\beta$); some heads transmit global information, others only local information

## GPU Feasibility
- **D1**: KL regularization involves element-wise operations; VIB reparameterization sampling is element-wise
- **D2**: The main body $QK^T$ and $attn \cdot V$ are standard GEMM; regularization introduces no new GEMM operations
- **D3**: KL regularization is $O(n)$ per token, adding no asymptotic complexity
- **D4**: VIB requires additional $\mu_z$ and $\log\sigma_z$, approximately doubling attention weight memory
- **D5**: log/exp in KL computations are stable under bf16 (standard log-softmax tricks)
- **D6**: Regularization can be computed in parallel with forward propagation, introducing no serial dependencies
- **D7**: KL regularization implicitly induces attention sparsity, amenable to block-sparse acceleration
- **D8**: KL can be fused into the softmax kernel (FusedSoftmaxKL)

## Paper Phrasing
"We propose information bottleneck attention, which models attention as an information bottleneck variational problem. By maximizing the mutual information between output and target while minimizing redundant information transmission from the input, it achieves theoretically optimal information selection and demonstrates enhanced sparsity and interpretability in experiments."

## Risks
- **High Variance of Mutual Information Estimators**: The MINE/NWJ/InfoNCE estimators in Scheme C exhibit high variance in high-dimensional spaces, potentially causing training instability. It is recommended to first validate the basic effect of IB attention with Scheme A (KL regularization) before attempting the full IB objective.
- **Difficulty of $\beta$ Tuning**: $\beta$ controls the compression-prediction trade-off, and the optimal $\beta$ varies significantly across tasks. Too small a $\beta$ degenerates to standard attention; too large a $\beta$ causes underfitting. Adaptive $\beta$ scheduling or information plane monitoring is recommended.
