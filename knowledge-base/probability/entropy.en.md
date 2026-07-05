# Entropy

## Minimal Definition
Shannon entropy measures the **total uncertainty** of a random variable — that is, the minimum average number of bits required to describe it. It is the cornerstone of information theory and the unifying quantity underlying maximum likelihood, variational inference, regularization, and other AI methods.

## Core Formulas

**Shannon Entropy** (discrete):
$$H(X) = -\sum_{x} p(x) \log p(x)$$

**Differential Entropy** (continuous):
$$h(X) = -\int p(x) \log p(x)\, dx$$

**Joint Entropy and Conditional Entropy**:
$$H(X, Y) = H(X) + H(Y|X), \quad H(Y|X) = -\sum_{x,y} p(x,y) \log p(y|x)$$

**Mutual Information** (the amount of information shared by two variables):
$$I(X; Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) = \sum_{x,y} p(x,y) \log \frac{p(x,y)}{p(x)p(y)}$$

**Maximum Entropy Principle**: Among all distributions satisfying the constraints $\mathbb{E}[f_i(X)] = c_i$, the distribution that maximizes $H(X)$ belongs to the exponential family $p(x) \propto \exp\left(\sum \lambda_i f_i(x)\right)$.

## Applicable Problems
- **Feature selection**: Use mutual information $I(X; Y)$ to select the most informative features with respect to the target variable
- **Model compression and quantization**: Entropy provides the theoretical lower bound for lossless compression (Shannon's coding theorem)
- **Regularization design**: Maximum entropy regularization encourages the model to output "uncertain yet fair" distributions, preventing overconfidence

## AI Design Translation
- **Cross-Entropy Loss**: $H(p, q) = -\sum p(x)\log q(x)$, the default loss function for classification tasks; it is essentially the "coding redundancy" between the true distribution $p$ and the model distribution $q$
- **KL Divergence** (see `kl-divergence.md`): $D_{KL}(p\|q) = H(p,q) - H(p)$, i.e., the difference between cross-entropy and entropy
- **Variational Autoencoder (VAE)**: ELBO = reconstruction likelihood $-$ KL regularization term; it fundamentally balances information compression (low $H(Z)$) against reconstruction fidelity

## Engineering Feasibility
- **D1[v]**: $-\sum p \log p$ is an element-wise operation, perfectly vectorizable
- **D2[~]**: Entropy itself is not a GEMM, but the gradient computation of the cross-entropy loss involves a softmax-to-matmul chain
- **D3[v]**: $O(|\mathcal{X}|)$ linear; acceptable for vocabulary-level computation
- **D5[v]**: $\log$ and exp are stable in bf16; softmax benefits from the log-sum-exp trick
- **D8[v]**: softmax + cross-entropy is a classic fused operator (FusedSoftmaxCrossEntropy)

## Risks and Failure Conditions
- **Continuous entropy can be negative**: Differential entropy $h(X)$ is not constrained by $H(X) \geq 0$; directly comparing differential entropies of different dimensions can be misleading. Mutual information or KL divergence (which are non-negative) should be used instead.
- **Sensitive to vocabulary size**: With large vocabularies (e.g., 128K tokenizers for LLMs), the peak memory usage of softmax + cross-entropy can reach tens of GB, requiring chunked/online softmax or label smoothing for mitigation.

## Further References
- Distillation draft: `references/books/` — no dedicated information theory distillation draft at present
- Cover & Thomas. *Elements of Information Theory*, 2nd Edition. Wiley, 2006
- MacKay. *Information Theory, Inference, and Learning Algorithms*. Cambridge, 2003
- Related knowledge cards: `probability/kl-divergence.md`, `probability/information-bottleneck.md`


## Routing Extensions
- If relative entropy is needed -> `kl-divergence.md` (KL divergence is relative entropy)
- If information compression is involved -> `information-bottleneck.md` (information bottleneck uses entropy and mutual information)
- If entropy-power inequality is involved -> `fisher-information.md` (relationship between Fisher information and entropy)

## Extensible Directions
- Renyi entropy: parameterized family of generalized entropies
- Tsallis entropy: entropy for non-extensive statistical mechanics
- Conditional / mutual information: multi-variable information measures
- Entropy rate: asymptotic entropy of stochastic processes
- Maximum entropy principle: distribution selection under minimal assumptions
- Entropy estimation: methods for estimating entropy from samples
- Differential entropy: entropy for continuous distributions
- Entropy power inequality: lower bound on entropy of independent sums
