# Entropy

## Minimal Definition
For a discrete variable and base-2 logs, Shannon entropy measures uncertainty in bits and lower-bounds expected lossless code length; a one-symbol prefix code need not achieve it exactly. Natural logs use nats. Differential entropy depends on the reference measure and coordinates, unlike the invariant KL/MI between fixed probability measures.

## Core Formulas

**Shannon Entropy** (discrete):
$$H(X) = -\sum_{x} p(x) \log p(x)$$

**Differential Entropy** (continuous):
$$h(X) = -\int p(x) \log p(x)\, dx$$

**Joint Entropy and Conditional Entropy**:
$$H(X, Y) = H(X) + H(Y|X), \quad H(Y|X) = -\sum_{x,y} p(x,y) \log p(y|x)$$

**Mutual Information** (the amount of information shared by two variables):
$$I(X; Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) = \sum_{x,y} p(x,y) \log \frac{p(x,y)}{p(x)p(y)}$$

**Maximum entropy under constraints**: If a normalizable interior optimum exists for specified support/base measure and feasible moment constraints, Lagrange stationarity yields an exponential-family form. Existence, boundary optima and unbounded-entropy cases must be checked; arbitrary moment constraints do not guarantee a normalizable maximizer.

## Applicable Problems
- **Feature selection**: Use mutual information $I(X; Y)$ to select the most informative features with respect to the target variable
- **Model compression and quantization**: Entropy provides the theoretical lower bound for lossless compression (Shannon's coding theorem)
- **Generative model evaluation and training**: Cross-entropy/perplexity is the intrinsic metric of language models; entropy regularization encourages exploration (in RL, $\mathcal{L} = \mathcal{L}_{\text{policy}} - \beta H(\pi)$)
- **Uncertainty quantification**: Predictive entropy $H(p(y|x))$ as a confidence signal for active learning, OOD detection, and selective prediction
- **Regularization design**: Maximum entropy regularization encourages the model to output "uncertain yet fair" distributions, preventing overconfidence; label smoothing is equivalent to entropy regularization on the output distribution

## AI Design Translation
- **Cross-entropy**: $H(p,q)=-\sum p\log q$ is expected code length/cross-entropy under the model code; the excess over the entropy of $p$ is **KL**, not cross-entropy itself.
- **KL Divergence** (see `kl-divergence.en.md`): $D_{KL}(p\|q) = H(p,q) - H(p)$, i.e., the difference between cross-entropy and entropy
- **VAE**: The expected encoder-to-prior KL combines input–latent MI with mismatch of the aggregated posterior to the prior. It is not equivalent to minimizing latent entropy; state the stochastic channel and prior.

## Engineering Feasibility
- **D1[v]**: $-\sum p \log p$ is an element-wise operation, perfectly vectorizable
- **D2[~]**: Entropy itself is not a GEMM, but the gradient computation of the cross-entropy loss involves a softmax-to-matmul chain
- **D3[v]**: $O(|\mathcal{X}|)$ linear; acceptable for vocabulary-level computation
- **D5[~]**: Use stable log-softmax and fp32 accumulation; handle masked zeros with the $0\log0=0$ convention. Low-precision exp/log can underflow or overflow.
- **D8[v]**: softmax + cross-entropy is a classic fused operator (FusedSoftmaxCrossEntropy)

## Risks and Failure Conditions
- **Continuous entropy can be negative**: Differential entropy $h(X)$ is not constrained by $H(X) \geq 0$; directly comparing differential entropies of different dimensions can be misleading. Mutual information or KL divergence (which are non-negative) should be used instead.
- **Vocabulary memory**: Materializing $B\times T\times V$ logits scales with batch, sequence and vocabulary size. Tiled/fused cross-entropy can reduce stored intermediates; label smoothing changes the objective and is not by itself a memory-reduction method.

## Further References
- Distillation draft: `../../references/books/` — no dedicated information theory distillation draft at present
- Cover & Thomas. *Elements of Information Theory*, 2nd Edition. Wiley, 2006
- MacKay. *Information Theory, Inference, and Learning Algorithms*. Cambridge, 2003
- Related knowledge cards: `kl-divergence.en.md`, `information-bottleneck.en.md`


## Routing Extensions
- If relative entropy is needed -> `kl-divergence.en.md` (KL divergence is relative entropy)
- If information compression is involved -> `information-bottleneck.en.md` (information bottleneck uses entropy and mutual information)
- If entropy-power inequality is involved -> `fisher-information.en.md` (relationship between Fisher information and entropy)

## Extensible Directions
- Renyi entropy: parameterized family of generalized entropies
- Tsallis entropy: entropy for non-extensive statistical mechanics
- Conditional / mutual information: multi-variable information measures
- Entropy rate: asymptotic entropy of stochastic processes
- Maximum entropy principle: distribution selection under minimal assumptions
- Entropy estimation: methods for estimating entropy from samples
- Differential entropy: entropy for continuous distributions
- Entropy power inequality: lower bound on entropy of independent sums
