# KL Divergence

## Minimal Definition
Kullback-Leibler divergence measures the **information loss** when a probability distribution $q$ is used to approximate the true distribution $p$ — that is, the average number of extra bits spent when encoding $p$ using $q$. It is not a metric (it is asymmetric and does not satisfy the triangle inequality), but it defines a natural "directional distance" on the probability simplex.

## Core Formulas

**Definition**:
$$D_{KL}(p \| q) = \sum_x p(x) \log \frac{p(x)}{q(x)} = \mathbb{E}_{p}\left[\log \frac{p(X)}{q(X)}\right]$$

**Continuous version**:
$$D_{KL}(p \| q) = \int p(x) \log \frac{p(x)}{q(x)}\, dx$$

**Fundamental properties**:
- $D_{KL}(p \| q) \geq 0$ (Gibbs' inequality), with equality if and only if $p = q$
- **Asymmetric**: $D_{KL}(p \| q) \neq D_{KL}(q \| p)$, hence it is not a metric

**Relationship to cross-entropy and entropy**:
$$D_{KL}(p \| q) = H(p, q) - H(p)$$

**Semantic difference between the two directions**:
- **Forward KL** $D_{KL}(p \| q)$: $q$ tends to cover all modes of $p$ (mean-seeking)
- **Reverse KL** $D_{KL}(q \| p)$: $q$ tends to lock onto a single mode of $p$ (mode-seeking)

## Applicable Problems
- **Variational inference**: Minimize the reverse KL $D_{KL}(q \| p)$ to find an approximate posterior distribution
- **Knowledge distillation**: Minimize the information loss from the teacher distribution $p$ to the student distribution $q$
- **Regularization**: Constrain the model distribution to remain close to a prior (e.g., the KL regularization term in VAEs)

## AI Design Translation
- **Knowledge Distillation Loss**: $\mathcal{L} = (1-\alpha) \cdot CE(y, q_s) + \alpha \cdot T^2 \cdot D_{KL}(p_t \| q_s)$, where $T$ is the temperature parameter
- **VAE Regularization Term**: $D_{KL}(q_\phi(z|x) \| p(z))$, typically with $p(z) = \mathcal{N}(0, I)$, which admits an analytical solution
- **PPO / RLHF**: $D_{KL}(\pi_\theta \| \pi_{\text{ref}})$ serves as a penalty term for the policy deviating from the reference policy

## Engineering Feasibility
- **Dimension 1 Tensorization ✅**: Element-wise $p \log(p/q)$ is fully vectorizable
- **Dimension 2 GEMM-mappability ⚠️**: KL itself is not a GEMM, but its inputs (logits) come from GEMM layers
- **Dimension 3 Complexity ✅**: $O(|\mathcal{X}|)$ linear
- **Dimension 4 Memory ⚠️**: For large vocabularies, both $p$ and $q$ probability vectors must be held simultaneously; chunked computation is possible
- **Dimension 5 Low Precision ✅**: Log-softmax differences are stable in bf16; note that $\log q$ diverges as $q \to 0$, requiring clamping
- **Dimension 8 Operator Fusion ✅**: Can be fused with softmax into FusedKLDivLoss

## Risks and Failure Conditions
- **KL diverges to infinity when $q(x)=0$ but $p(x)>0$**: In practice, label smoothing or temperature scaling must be applied to $q$ to avoid zero probabilities. The mode-seeking behavior of reverse KL can exacerbate this issue — the student model "drops" low-probability regions of the teacher distribution.
- **High gradient variance**: In RL (PPO/RLHF), KL estimation relies on sampling; high variance can lead to training instability. A clipped + linear approximation $\mathbb{E}[\log p - \log q]$ is commonly used in place of the exact KL.

## Further References
- Distillation draft: `references/books/` — no dedicated information theory distillation draft at present
- Cover & Thomas. *Elements of Information Theory*, Ch. 2-3. Wiley, 2006
- Murphy. *Probabilistic Machine Learning: Advanced Topics*, Ch. 6. MIT Press, 2023
- Related knowledge cards: `probability/entropy.md`, `probability/information-bottleneck.md`, `probability/fisher-information.md`
