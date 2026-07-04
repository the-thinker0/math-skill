---
name: causal-inference
description: |
  Trigger when a problem concerns correlation vs. causation, intervention/counterfactual reasoning, do-calculus, causal DAG modeling, confounder identification, policy/treatment effect estimation; or needs explicit causal assumptions for model interpretability, out-of-distribution generalization, or data-generating process modeling.
---

# 🔗 Causal Inference

> "Correlation is not causation — but causation can be sorted out. Key distinction: 'how is Y when we see X' is not the same as 'what if we did X.'"
>
> — Causal Inference, Structural Causal Models, Counterfactual Reasoning

## Core Principle

**Causal inference answers questions beyond probability's expressive power: probability answers "how is Y when we see X," not "what if we did X." Pearl's causal hierarchy has three levels, each requiring stronger modeling assumptions.**

> **Mathematical Formalization**
>
> Pearl's Causal Hierarchy:
> - **Level 1 — Association**: $P(y|x)$ — Seeing
> - **Level 2 — Intervention**: $P(y|do(x))$ — Doing
> - **Level 3 — Counterfactual**: $P(y_x|x',y')$ — Imagining
>
> **$do(x) \neq$ conditioning on $x$**: $do(x)$ severs all arrows pointing into $X$ (graph surgery), while conditioning on $x$ severs no arrows. Back-door adjustment: $P(y|do(x)) = \sum_z P(y|x,z)P(z)$
>
> **Potential Outcomes (Neyman-Rubin)**: $Y(x)$ denotes "the value $Y$ would take under intervention $X=x$"; individual treatment effect $\tau_i = Y_i(1)-Y_i(0)$; average treatment effect ATE $= E[Y(1)]-E[Y(0)] = E[Y|do(X=1)] - E[Y|do(X=0)]$.
>
> **Structural Causal Model (SCM)**: $Y := f(X, Z, U)$, where $U$ is exogenous; the DAG together with structural equations determines the counterfactual $Y_x = f(x, Z, U)$.
>
> **d-Separation**: A path is blocked by $Z$ $\iff$ a chain/fork middle node $\in Z$, or a collider $X\to C\leftarrow Y$ has $C$ and its descendants $\notin Z$. d-separation $X\perp_G Y|Z$ implies conditional independence; it is the tool for reading off causal assumptions from the graph.
>
> **Do-Calculus — Three Rules** (applied on modified graphs using d-separation):
> - Rule 1 (Insertion/deletion of observations): If $Y \perp Z \mid X$ in the graph with all arrows into $X$ removed, then $P(y|do(x),z) = P(y|do(x))$
> - Rule 2 (Exchange of intervention and observation): If $Y \perp Z \mid X$ in the graph with all arrows into $X$ removed and all arrows out of $Z$ removed, then $P(y|do(x),do(z)) = P(y|do(x),z)$
> - Rule 3 (Insertion/deletion of interventions): If $Y \perp Z \mid X$ in the graph with all arrows into $X$ removed and all arrows from $Z$ to $X$ along paths from $Z$ to $X$ removed, then $P(y|do(x),do(z)) = P(y|do(x))$
>
> **Causal reasoning requires an explicit causal model; it cannot be derived from data alone. The DAG encodes causal assumptions, and do-calculus transforms interventional expressions into observable quantities.**
>
> See `original-texts.md` for detailed mathematical foundations.

## GPU-Friendliness (Cross-Cutting Check)

When causal inference is used for **model interpretability / out-of-distribution generalization / data-generating process modeling** at scale, the methods themselves must pass through the eight-dimensional gate in `../../references/gpu-friendly-math.md`:

- **Effect estimation / adjustment regression**: Back-door adjustment, IPW, doubly-robust ML — conditional expectations and regression are all batch GEMM, tensorizable, fusible, low-precision viable — **friendly** (see `../../references/books/optimization-ml.md`).
- **Conditional independence testing**: High-dimensional conditional independence tests involve precision matrix (covariance inverse) inversion $O(p^3)$; can be reformed via **low-rank / diagonal approximation** or iterative solvers — **retrofittable** (see `../../references/books/matrix-analysis.md`).
- **Exact causal discovery (DAG search)**: DAG space grows super-exponentially with node count; exact score-based search is NP-hard, non-differentiable, serial — a classic "beautiful but intractable" anti-pattern.
- **Reform approach**: NOTEARS-style **continuous relaxation** (acyclicity constraint $h(W)=\text{tr}(e^{W\circ W})-p=0$) transforms discrete graph search into differentiable optimization; alternatively, MCMC / greedy + scoring as heuristic approximation.
- **Counterfactual / SCM simulation**: Forward simulation of structural equations is batch-parallelizable; however, individual counterfactuals depend on identifying exogenous $U$ — watch for serial dependencies.

Eight-dimensional minimum assessment (formal terms): **Tensorization** — whether samples / interventions / candidate graphs admit batched processing; **GEMM-mappability** — whether adjustment regression and representation learning fall into matrix multiplication; **Complexity** — whether causal discovery avoids super-exponential DAG search; **Memory and KV-Cache** — whether precision matrices, candidate graphs, and intermediate counterfactuals are compressible; **Low-precision stability** — whether IPW weights, covariance inverses, and logits are numerically robust; **Parallelism and communication** — whether multi-environment / multi-intervention estimation is parallelizable; **Sparse structure** — whether the DAG / SCM is structurally sparse; **Operator fusion** — whether scoring, masking, and loss can be fused.

> Use in conjunction with `../../references/books/optimization-ml.md` (intervention estimation / regression) and `../../references/books/matrix-analysis.md` (conditional independence / low-rank precision matrices).

## When NOT to Use

- **Pure prediction tasks with no causal question** (only $P(y|x)$ is needed, no interest in "why") — association is sufficient; causation is superfluous.
- **No encodable causal assumptions** (cannot draw a reasonable DAG; causal directions are uncertain) — without explicit assumptions, no causal conclusions can be drawn.
- **Deterministic systems with no variation** (inputs map strictly uniquely to outputs) — causation is fully described by the mechanism; the probabilistic causal framework is unnecessary.

## When to Use

- Need to know the effect of an intervention ("If we do X, what happens to Y?") — requires $P(y|do(x))$, not $P(y|x)$.
- Need to distinguish causes from confounders (Does X cause Y, or does Z cause both X and Y?) — DAGs identify confounding paths.
- Need counterfactual reasoning ("What would have happened if we had not done A?") — Level 3 requires structural equations.
- Need policy / treatment effect evaluation (back-door adjustment, IV, difference-in-differences when RCTs are infeasible).
- Need mediation analysis (decomposing direct and indirect effects along $X\to M\to Y$).
- Need to model the data-generating process (DGP) for **model interpretability / out-of-distribution generalization**, transforming predictor associations into actionable causal mechanisms.

## Method

### Step 1: Construct the Causal DAG
Identify all variables explicitly; draw causal arrows encoding direct-cause assumptions; verify acyclicity. Identify the cause variable $X$ (intervention target), outcome $Y$ (effect), confounders $Z$ (common causes of $X$ and $Y$), and mediators $M$ ($X\to M\to Y$). An arrow $X\to Y$ means "$X$ is a direct cause of $Y$"; the direction encodes a causal assumption. The DAG must be directed and acyclic — cycles indicate uncertain causal direction and require re-modeling. **Key question**: Is there sufficient domain knowledge to encode causal directions? Conclusions depend entirely on DAG correctness.

### Step 2: Identify Confounders
Confounders simultaneously affect $X$ and $Y$, creating spurious association — without adjustment, effect estimates are biased. **Definition**: $Z$ is a confounder $\iff$ $Z$ is a common cause of $X$ and $Y$ ($Z\to X$ and $Z\to Y$). **DAG identification**: find all common ancestors of $X$ and $Y$. **Back-door paths** $X\leftarrow Z\to Y$ create non-causal associations that must be blocked. **Key question**: Are all confounders observable? If unobserved confounders exist, back-door adjustment is unavailable and front-door criterion or instrumental variables are needed.

### Step 3: Choose Identification Strategy
Based on confounder observability, select a strategy for computing $P(y|do(x))$ from observational data:
- **Back-door criterion**: If $\exists S$ blocking all back-door paths from $X$ to $Y$ and $S$ contains no descendants of $X$, then $P(y|do(x)) = \sum_s P(y|x,S=s)\cdot P(S=s)$.
- **Front-door criterion**: Confounders are unobservable but mediator $M$ is observable, $X\to M$ has no back-door paths, and $M$ blocks all back-door paths from $X$ to $Y$; then $P(y|do(x)) = \sum_m P(m|x)\cdot\sum_z P(y|m,z)P(z)$.
- **Do-calculus**: Three rules transform do-expressions among observable quantities (see the Mathematical Formalization block in Core Principle).

### Step 4: Compute Intervention Effects
Use the adjustment formula to compute $P(y|do(x))$ and compare with the observational $P(y|x)$ to quantify confounding bias:
- Back-door adjustment: $P(y|do(x)) = \sum_z P(y|x,z)\cdot P(z)$ — weighted average over all values of $Z$.
- Confounding bias: $|P(y|do(x)) - P(y|x)|$ — larger bias indicates more severe confounding.
- Average treatment effect: ATE $= E[Y|do(X=1)] - E[Y|do(X=0)] = E[Y(1)] - E[Y(0)]$.

**Key question**: Are $P(y|do(x))$ and $P(y|x)$ significantly different? If so, observational analysis suffers from confounding bias.

### Step 5: Counterfactual Analysis
Individual-level retrospective reasoning: If $X$ had been $x_1$ instead of $x_0$, what would $Y$ have been?
- **SCM**: $Y = f(X, Z, U)$, where $U$ is exogenous.
- **Counterfactual computation**: Given observation $(x_0,y_0,z_0)$, the counterfactual $Y_{x_1} = f(x_1, z_0, u_0)$.
- **Individual causal effect**: $Y_{x_1} - Y_{x_0}$ — requires structural equations.

**Key point**: Counterfactuals depend on the specific form of the structural equations and are highly sensitive to model assumptions.

### Step 6: Experimental Design
- **RCT (gold standard)**: Randomization severs all arrows into $X$; treatment and control groups are equal in expectation on all variables; ATE $= E[Y|do(X=1)] - E[Y|do(X=0)]$.
- **Natural experiments**: Exploit naturally occurring quasi-random events (earthquakes, policy changes).
- **Instrumental variables (IV)**: $V\to X$ with no direct path from $V$ to $Y$ and no common cause of $V$ and $Y$ — use the variation in $X$ created by $V$ to estimate the causal effect.
- **Difference-in-differences (DD)**: $(Y_1^{\text{post}}-Y_1^{\text{pre}}) - (Y_0^{\text{post}}-Y_0^{\text{pre}})$.

### Step 7: Sensitivity Analysis
Quantify the vulnerability of conclusions to unobserved confounding:
- **Rosenbaum $\Gamma$**: For confounding strength $\Gamma$, compute the maximum $p$-value at which the conclusion could be overturned — larger $\Gamma$ means more vulnerable.
- **E-value**: The minimum confounding strength required to nullify the effect estimate — larger values indicate greater robustness.

**Key question**: How strong must an unobserved confounder $U$ be to overturn the conclusion?

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Inferring causation directly from correlation | $P(y\|x)\neq P(y\|do(x))$; correlation may be created by confounding | Draw a DAG to identify confounders; use back-door adjustment to compute $P(y\|do(x))$ |
| Ignoring confounders | Without adjustment, $\|P(y\|do(x))-P(y\|x)\|$ equals confounding bias | Find all common ancestors of $X$ and $Y$; adjust for observable confounders |
| Confusing $do(x)$ with conditioning $P(y\|x)$ | $do(x)$ severs arrows into $X$; conditioning does not | Clearly distinguish intervention (forced setting) from observation (passive seeing) |
| Ignoring mediation effects | $X\to M\to Y$: total effect = direct + indirect | Perform mediation analysis to decompose direct / indirect effects; front-door criterion may apply |
| Over-reliance on a single DAG | If the DAG is wrong, all conclusions are wrong; different DAGs can yield opposite conclusions | Validate DAG plausibility; compare multiple candidate DAGs |
| Skipping sensitivity analysis | Unobserved confounders may overturn conclusions | Quantify vulnerability using Rosenbaum $\Gamma$ or E-value |
| Intractable exact causal graph search | DAG space is super-exponential, NP-hard, non-differentiable | Use continuous relaxation (NOTEARS) / heuristic approximation; pass through the GPU eight-dimensional gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **[DAG]**: Directed acyclic graph of all variables, with justification for each arrow's causal assumption.
2. **[Confounders]**: List all common ancestors of $X$ and $Y$; label each as observable / unobservable.
3. **[Identification Strategy]**: Back-door / front-door / do-calculus, with justification for the choice.
4. **[Intervention Effect]**: $P(y|do(x))$ = [value], computed via the adjustment formula and compared with $P(y|x)$.
5. **[Counterfactuals]**: Counterfactual reasoning for key individuals / subgroups, specifying the required structural equations.
6. **[Validation Method]**: RCT / natural experiment / IV / DD — how to validate causal conclusions.
7. **[Sensitivity]**: Rosenbaum $\Gamma$ or E-value, quantifying vulnerability to unobserved confounding.
8. **[GPU Feasibility]** (if used for large-scale estimation in interpretability / OOD / DGP modeling): Causal discovery / estimation method passes through the eight-dimensional gate; label friendly / retrofittable / unfriendly with reform suggestions.

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Probability and Statistics**: Statistics is the foundation of causation but is insufficient — $P(y|x)$ is association, $P(y|do(x))$ is causal effect; causation requires additional assumptions.
- **Modeling Thinking**: Causal DAGs are structural models — they encode hypotheses about causal mechanisms among variables; causal modeling is the causal version of modeling.
- **Logical Deduction**: Starting from DAG assumptions, causal conclusions are deduced through the three rules of do-calculus.
- **Information Theory Thinking**: Confounders create spurious signals; causal inference extracts true causal signals from noise.
- **Game Theory Thinking**: Players' choices in strategic interaction constitute causal interventions; equilibrium analysis requires causal reasoning.
- **Modern Mathematics Activation**: `../../references/books/optimization-ml.md` (intervention estimation / regression, double ML), `../../references/books/matrix-analysis.md` (conditional independence testing, low-rank precision matrix approximation).
