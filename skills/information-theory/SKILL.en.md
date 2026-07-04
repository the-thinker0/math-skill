---
name: information-theory
description: |
  Trigger when a problem needs to quantify uncertainty, measure information value as "information = reduction of uncertainty"; or compute entropy / mutual information / KL divergence / channel capacity, or design information criteria for compression / KV-cache compression / quantization / routing.
---

# 📡 Information Theory

> "Information is reduction of uncertainty — knowing more means doubting less."
>
> — Information Theory, Coding Theory, Statistical Inference

## Core Principle

**Information is reduction of uncertainty — uncertainty is precisely quantified by entropy; compression and communication have unbreakable limits set by the entropy bound and channel capacity; information gain guides which observation to prioritize under uncertainty.**

> **Mathematical Formalization**
>
> Shannon entropy $H(X) = -\sum_x p(x)\log p(x)$ quantifies the average "surprise" of a random variable — the lower the probability of an event, the greater the surprise when it occurs; entropy is the expected value of surprise.
>
> Mutual information $I(X;Y) = H(X) - H(X|Y) = \sum_{x,y} p(x,y)\log\frac{p(x,y)}{p(x)p(y)}$ measures the reduction in uncertainty about $X$ after observing $Y$ — this is precisely the mathematical definition of "information."
>
> KL divergence $D_{KL}(P\|Q) = \sum_x p(x)\log\frac{p(x)}{q(x)}$ measures the information loss when $Q$ is used in place of $P$; it is **asymmetric**: $D(P\|Q)\neq D(Q\|P)$.
>
> Source coding theorem: The average code length of the optimal compression satisfies $\ge H(X)$ bits/symbol; compression below the entropy bound inevitably loses information.
>
> Channel coding theorem: The upper bound on the rate of reliable communication is the channel capacity $C = \max_{p(x)} I(X;Y)$; when $R<C$, there exist codes that drive the error rate to zero; when $R>C$, reliable communication is impossible.
>
> Rate-distortion function $R(D) = \min_{p(\hat{x}|x):\,\mathbb{E}[d(x,\hat{x})]\le D} I(X;\hat{X})$ gives the minimum information rate for a given distortion $D$ — the fundamental limit of lossy compression.
>
> See `original-texts.md` for detailed mathematical foundations.

## GPU-Friendliness (Cross-Cutting Check)

When information-theoretic quantities are used for **compression/pruning/quantization/KV-cache compression/routing design**, they must pass the `../../references/gpu-friendly-math.md` eight-dimension gate. Core criterion: **local, fusible entropy/KL estimation = friendly; global exact information estimation = unfriendly**.

- **Quantization calibration (per-block entropy/Hessian)**: Local, batchable via GEMM, feasible at low precision — friendly (dimensions 1/2/5).
- **KV-Cache compression (information bottleneck/block summary)**: Low-rank block summary compresses memory — friendly (dimension 4); Plücker-style block summaries are discussed in `../../references/books/algebraic-geometry-rising-sea.md`.
- **Mutual information pruning / feature selection**: Adaptable if $I(X;Y)$ is estimated using local or low-rank approximations; unfriendly if full-distribution exact estimation is required.
- **Information gain routing**: Global exact $I(X;Y)$ requires $O(n^2)$ memory, high precision, and is unfusable — anti-pattern; replace with continuous differentiable approximations such as softmax/tropical gating (dimensions 3/6/8).
- **Anti-pattern**: Computing exact entropy/mutual information over the full token distribution — memory explosion, requires fp64, serial dependencies — "beautiful but intractable."

Eight-dimension minimum criteria (formal terms): **Tensorization** checks whether entropy/KL/MI can be estimated per token/block/batch; **GEMM-mappability** checks whether compression, projection, and calibration reduce to linear algebra; **complexity** avoids full-distribution exact estimation; **memory and KV-cache** quantifies KV/activation/codebook footprint; **low-precision stability** checks log/softmax/KL dynamic range; **parallelism and communication** checks whether block-wise statistics can be reduced across devices; **sparse structure** checks whether codebooks/routing are block-structured; **operator fusion** checks whether statistics, masking, and quantization can be fused.

> Used together with `../../references/books/matrix-analysis.md` (low-rank compression), `../../references/books/abstract-algebra.md` (coding/finite fields).

## When NOT to Use

- **The problem has no probabilistic structure** (e.g., purely symbolic reasoning, logical deduction) — entropy and information gain require probability distributions; without probability there is no information theory.
- **Purely deterministic scenarios with no uncertainty** (e.g., mathematical problems with known exact answers) — when entropy is zero, information theory degenerates to trivial conclusions.
- **Qualitative judgments that need no quantification** (e.g., aesthetic evaluations, emotional judgments) — information theory quantifies uncertainty in the probabilistic sense, not semantic ambiguity.

## When to Use

- Measuring the magnitude of uncertainty (entropy $H(X)$ quantifies the "disorder" of a random variable).
- Comparing the value of different information sources (mutual information $I(X;Y)$ measures which observation $Y$ best reduces uncertainty about $X$).
- Achieving optimal data compression (the source coding theorem guarantees the optimal compression limit is $H(X)$ bits/symbol).
- Communicating reliably under noise (the channel coding theorem guarantees reliable transmission is feasible when $R<C$).
- Feature selection or model selection (mutual information screens features; AIC/BIC/MDL serve as information criteria for model selection).
- Bayesian model comparison (KL divergence $D(P\|Q)$ measures the information distance between distributions; Bayes factors quantify the evidence ratio between models).
- **Designing information criteria for compression / KV-cache compression / quantization / routing**, and evaluating their GPU feasibility.

## Method

### Step 1: Identify Source and Uncertainty
- What is the **random variable $X$**? — Define the information source and clarify the object of uncertainty.
- The **probability distribution $p(x)$** — use a probability table for discrete distributions, a density function for continuous distributions.
- **Compute $H(X) = -\sum p(x)\log p(x)$** — quantify the current level of uncertainty.
- **Identify the uncertainty to be reduced** — clarify "knowing what would reduce uncertainty?"

### Step 2: Quantify Information Gain
- **Compute conditional entropy $H(X|Y)$** — the residual uncertainty about $X$ after observing $Y$.
- **Compute mutual information $I(X;Y) = H(X) - H(X|Y)$** — the amount of information $Y$ provides about $X$.
- **Identify the optimal observation** — which $Y$ maximizes $I(X;Y)$? That observation is the most worth acquiring.
- **Chain rule** — $H(X_1,\dots,X_n) = H(X_1) + H(X_2|X_1) + \dots + H(X_n|X_1,\dots,X_{n-1})$, decomposing joint uncertainty variable by variable.

### Step 3: Choose Coding Strategy
- **Source coding (compression)**: Huffman coding (greedy optimal prefix code, average length approaching $H(X)$), arithmetic coding (closer to the entropy bound), universal coding (LZ77/LZ78/LZW, no prior distribution needed).
- **Channel coding (error correction)**: Hamming codes (minimum distance 3, corrects 1-bit errors), Reed–Solomon codes (burst error correction), LDPC/Turbo codes (approaching the Shannon limit).
- **Coding selection principle**: Compression needs → source coding → approach $H(X)$; noise protection needs → channel coding → approach the Shannon limit ($R\to C$).

### Step 4: Evaluate Channel Capacity
- **Compute channel capacity $C = \max_{p(x)} I(X;Y)$** — maximize mutual information over all input distributions.
- **Compare transmission rate $R$ with capacity $C$**: $R<C$ → reliable communication is feasible; $R>C$ → errors are inevitable.
- **Noise models**: BSC (binary symmetric channel, flip probability $p$), BEC (binary erasure channel, erasure probability $\varepsilon$), AWGN (additive white Gaussian noise channel).
- **Capacity formula examples**: BSC capacity $C = 1 - H(p)$; AWGN capacity $C = \frac{1}{2}\log(1 + S/N)$.

### Step 5: Apply Information Criteria
- **AIC (Akaike Information Criterion)**: $\text{AIC} = -2\ln L + 2k$ — favors goodness of fit, suited for prediction objectives.
- **BIC (Bayesian Information Criterion)**: $\text{BIC} = -2\ln L + k\ln n$ — favors parsimony, suited for explanation objectives.
- **KL divergence $D_{KL}(P\|Q) = \sum p(x)\log\frac{p(x)}{q(x)}$** — measures the information loss when $Q$ is used in place of $P$; note the asymmetry.
- **MDL principle (Minimum Description Length)**: Choose the model that minimizes "data description length + model description length" — the information-theoretic version of Occam's razor.

### Step 6: Make Information-Optimal Decision
- **Bayesian experimental design**: Choose the experiment that maximizes expected information gain $\max\,\mathbb{E}[I(\theta;Y)]$ — prioritize acquiring the data that most reduces uncertainty.
- **Minimize KL divergence**: The output distribution $Q$ of a decision should be as close as possible to the target distribution $P$, i.e., $\min D(P\|Q)$.
- **Maximum entropy principle**: Under known constraints, choose the distribution that maximizes $H(X)$ — fewest assumptions, most conservative inference.
- **Information bottleneck**: $\min I(X;T) - \beta I(T;Y)$ — when compressing $X$ into $T$, retain the maximum relevant information about $Y$.

## Common Errors

| Error | Critique | Correct Approach |
|-------|----------|-----------------|
| Equating information with bits rather than probabilistic reduction | Entropy $H(X)$ is a function of the probability distribution; bits are merely the unit of measurement | Understand information as reduction of uncertainty: $I(X;Y)=H(X)-H(X\|Y)$ |
| Ignoring channel capacity limits | When $R>C$, no coding scheme achieves reliable communication | Compute capacity $C=\max I(X;Y)$ and ensure $R<C$ |
| Confusing entropy with variance | Entropy measures the "spread" of the probability structure; variance measures the "spread" of numerical values; they are not equivalent | Use entropy for probabilistic uncertainty; use variance for numerical deviation; continuous entropy can be negative |
| Over-compressing below the entropy bound | Optimal compression satisfies $\ge H(X)$ bits/symbol; compression below this bound inevitably loses information | Accept the entropy bound and design codes accordingly |
| Ignoring the asymmetry of KL divergence | $D(P\|Q)\ne D(Q\|P)$; the direction determines the meaning | Be explicit about direction: $D(P\|Q)$ means "the extra cost of encoding $P$ using $Q$" |
| Equating correlation with information | Correlation $\rho$ measures only linear association; $I(X;Y)=0 \Leftrightarrow$ independence, but $\rho=0 \not\Rightarrow$ independence | Use mutual information $I(X;Y)$ to assess dependence |
| Forcing quantification on qualitative judgments | Information theory quantifies probabilistic uncertainty, not semantic ambiguity or subjective experience | Distinguish probabilistic uncertainty from semantic ambiguity; do not apply entropy formulas to qualitative problems |
| Global exact entropy / mutual information is intractable | Exact estimation of $I(X;Y)$ over the full distribution requires $O(n^2)$ memory and high precision; infeasible on GPU | Use local/sampled/low-rank estimation; pass the GPU eight-dimension gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **[Information source]: [description]** $H(X)=$ [value] — define the random variable $X$, compute its entropy, and quantify the current uncertainty.
2. **[Information gain]: [description]** $I(X;Y)=$ [value] — compute mutual information and identify the most valuable observation $Y$.
3. **[Coding strategy]: [choice]** — source coding (compression) or channel coding (error correction), stating which limit is being approached.
4. **[Channel capacity]: [description]** $C=$ [value] — compute channel capacity and compare transmission rate $R$ with $C$.
5. **[Information criterion]: [AIC/BIC/KL/MDL]** — state the chosen information criterion and the rationale.
6. **[Optimal decision]: [explanation]** — decision recommendation based on information gain maximization or KL divergence minimization.
7. **[GPU feasibility]** (if used for compression/KV-cache compression/quantization/routing) — is entropy/KL/mutual information estimation local and fusible, or global and exact? Pass the eight-dimension gate; annotate as friendly / retrofittable / unfriendly + adaptation suggestions.

**The output must not present analysis alone without a conclusion.**

## Relations to Other Skills

- **Probability and statistics**: Entropy and information gain complement probabilistic reasoning — $H(X)$ measures distributional uncertainty, and $I(X;Y)$ is the information-theoretic expression of Bayesian updating.
- **Optimization thinking**: Channel capacity maximization is an optimization problem — $C=\max_{p(x)} I(X;Y)$ is optimization over input distributions.
- **Transformation thinking**: Coding is a transformation of the information space — source coding transforms into efficient representations; channel coding transforms into noise-resistant representations.
- **Modeling thinking**: Information criteria guide model selection — AIC/BIC/MDL quantify the fit-complexity trade-off from an information-theoretic perspective.
- **Algorithmic thinking**: Compression algorithms are computational implementations — Huffman/LZ/LDPC and related algorithms are approximation implementations of information-theoretic limits.
- **Modern mathematics activation**: `../../references/books/matrix-analysis.md` (low-rank compression), `../../references/books/abstract-algebra.md` (coding/finite fields), `../../references/books/algebraic-geometry-rising-sea.md` (Plücker KV compression).
