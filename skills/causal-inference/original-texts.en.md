# Mathematical Sources and Classic Texts

## Wright's Path Analysis and DAGs (1921)

> Path coefficient p_{ij}: a standardized measure of the direct causal effect of variable i on variable j.
> The total effect along each path from i to j = the product of the coefficients along that path.

**Significance**: Causal structure can be represented with directed graphs, and causal effects can be computed along paths on the graph — this is the origin of causal DAGs.

**Mathematical background**: Sewall Wright (1921) invented path diagrams while studying genetics, to decompose the hereditary and environmental components of traits. Path analysis is essentially the graphical representation of structural equation models (SEM): each variable's value is determined by its direct causes and an exogenous error term, Y = Σ β_{ij}·X_j + ε_j. Wright's path tracing rule allows one to compute the total association between variables along DAG paths: r_{XY} = Σ(product of path coefficients). This approach laid the foundation for Pearl's DAG framework.

**Key formula**: Wright's tracing rule: total association r_{ij} = Σ(product of path coefficients along each open path from i to j). An open path has no loops and no colliders (nodes receiving two arrows). Colliders block paths by default, but conditioning on a collider opens the path — the origin of "collider bias."

## Fisher's Randomized Experiments (1935)

> Randomization does not ignore causation; it makes causal inference possible.
> Random assignment severs all causal arrows pointing into the treatment variable.

**Significance**: The credibility of scientific experiments comes not from "precise control" but from "random assignment" — randomization is the gold standard for causal inference.

**Mathematical background**: R.A. Fisher, in *The Design of Experiments* (1935), introduced the principle of randomization. The core argument: if treatment T is randomly assigned to individuals, then T is independent of any confounder Z (P(Z|do(T)) = P(Z)), so P(Y|do(T)) = P(Y|T). Randomization eliminates all back-door paths without needing to identify specific confounders. Fisher also proposed exact tests under the null hypothesis (permutation test): under the assumption that T has no effect, the distribution of Y values is the same across all possible assignments, and the p-value = "the probability of observing the current or a more extreme assignment."

**Fisher's exact test and permutation inference**: Fisher's lady tasting tea experiment is the classic case of randomized inference. A lady claimed she could distinguish whether milk was poured before or after the tea. Fisher designed an experiment with 8 cups (4 with milk first, 4 with tea first), presented in random order. Under the null hypothesis (the lady has no discriminatory ability), the probability of correctly identifying all 4 milk-first cups = 1/C(8,4) = 1/70 ≈ 0.014. This p-value does not rely on any distributional assumption — it is based entirely on the randomization assignment, and is the origin of the permutation test.

## Wright's Instrumental Variables (1928)

> An instrumental variable V satisfies: (1) V → X (affects treatment), (2) V has no direct path to Y, (3) V shares no common cause with Y.
> IV estimator: β_{IV} = Cov(Y,V)/Cov(X,V).

**Significance**: When confounders are unobserved, instrumental variables exploit "exogenous variation" to estimate causal effects — the variation in X created by the IV is unaffected by confounding.

**Mathematical background**: Philip Sewall Wright (1928) first proposed the instrumental variable method when estimating the demand elasticity of flaxseed. He needed to estimate the causal effect of price on quantity demanded, but price and quantity demanded exhibit bidirectional causality (confounding). Wright introduced a variable that only affects supply (and thus price) but does not directly affect demand as an instrument. The logic of IV estimation: Cov(Y,V) = β_{causal}·Cov(X,V) + Cov(confounder, U·V), but since V is independent of the confounder, Cov(confounder, U·V) = 0, so β_{causal} = Cov(Y,V)/Cov(X,V). When the IV is weak (small Cov(X,V)), the variance of the IV estimator inflates, and one must beware of weak instrument problems.

**Classic IV cases**:

- **Angrist & Krueger (1991)**: used birth quarter as an instrumental variable for years of education — those born early in the year were compelled to attend more school due to school-entry age regulations. The IV-estimated return to education was approximately 7%, higher than the OLS estimate of 5% (OLS biased downward by ability confounding).
- **Two-Stage Least Squares (2SLS)**: first stage X̂ = π₀ + π₁·V (predict X using the IV); second stage Y = β₀ + β₁·X̂ (estimate the causal effect using predicted values). When the IV is strong (F-statistic > 10), 2SLS is reliable; when the IV is weak, 2SLS is biased toward OLS and confidence intervals inflate.

## Lewis's Counterfactual Semantics (1973)

> "If A had occurred (which it didn't), would C have happened?" — In the possible world where A holds, does C hold?

**Significance**: Causal claims inherently involve counterfactuals — "A caused C" means "if A hadn't occurred, C wouldn't have." Counterfactual reasoning requires comparing different possible worlds.

**Mathematical background**: David Lewis (1973), in *Counterfactuals*, proposed possible-world semantics to analyze counterfactual conditionals. Core concept: similarity ordering — among the possible worlds where A holds, the one closest to the actual world determines the truth value of the counterfactual. Lewis's VC (Variably Strict Conditional) system: A □→ C is true if C holds in all closest A-worlds. This philosophical framework provided the semantic foundation for Pearl's counterfactual computation in structural causal models — the SCM counterfactual Y_x(u) is the value of Y for individual u in the possible world where X is set to x.

## Rubin's Potential Outcomes Framework (1974)

> For individual i: Y_i(1) is the potential outcome under treatment, Y_i(0) is the potential outcome under control.
> Individual causal effect: τ_i = Y_i(1) - Y_i(0) (never simultaneously observable).
> Average Treatment Effect: ATE = E[Y(1) - Y(0)].

**Significance**: The causal effect is the difference between two potential outcomes — but only one can be observed per individual, which is the "fundamental problem of causal inference."

**Mathematical background**: Donald Rubin (1974) extended Neyman's (1923) randomization inference framework from agricultural experiments into a general potential outcomes model (the Neyman-Rubin causal model). Key assumption SUTVA (Stable Unit Treatment Value Assumption): (1) individual i's potential outcomes are unaffected by others' treatment assignments, (2) the treatment has a single version (no variations). Under randomization, an unbiased estimator of the ATE is τ̂ = Ȳ_1 - Ȳ_0. Rubin's framework is equivalent to Pearl's: the potential outcomes model provides implicit structural equations in the SCM, and the DAG provides explicit causal assumptions of the potential outcomes model.

## Pearl's Causal Hierarchy and Do-Calculus (2000)

> Causal hierarchy:
> Level 1: P(y|x) — Association / Seeing
> Level 2: P(y|do(x)) — Intervention / Doing
> Level 3: P(y_x|x',y') — Counterfactual / Imagining
>
> The three rules of do-calculus allow interventional expressions to be converted into observable quantities.

**Significance**: Causation is not a strengthened version of correlation — "do(x)" and "observe x" are mathematically distinct. Do-calculus provides a complete logical system for computing causal effects from observational data.

**Mathematical background**: Judea Pearl, in *Causality* (2000), established the mathematical framework for causal inference. Core contributions: (1) the causal hierarchy classifies reasoning capabilities from association to intervention to counterfactual in three levels, each requiring stronger modeling assumptions; (2) the three rules of do-calculus provide a complete set of rules for converting do-expressions into do-free observational expressions; (3) Pearl proved the completeness of do-calculus — if a do-expression can be converted into an observational expression, the three rules of do-calculus will find that conversion. The back-door criterion and front-door criterion are the most important special cases of do-calculus.

## Card & Krueger Difference-in-Differences (1994)

> DD = (Y₁^{post} - Y₁^{pre}) - (Y₀^{post} - Y₀^{pre})
> The pre-post change in the treatment group minus the pre-post change in the control group = the pure causal effect.

**Significance**: When RCTs are impossible, difference-in-differences estimates causal effects by comparing pre-post changes between treatment and control groups — provided the parallel trends assumption holds.

**Mathematical background**: David Card and Alan Krueger (1994), in studying the effect of minimum wage on employment, compared changes in fast-food employment between New Jersey (which raised the minimum wage) and Pennsylvania (which did not). The key assumption of DD: in the absence of intervention, the trends of the treatment and control groups are the same (parallel trends assumption). Mathematically, the DD estimator is τ̂_{DD} = (Ȳ_{NJ,post} - Ȳ_{NJ,pre}) - (Ȳ_{PA,post} - Ȳ_{PA,pre}). When parallel trends hold, τ̂_{DD} = ATE. Parallel trends can be partially tested by comparing the pre-intervention time trends of the two groups.

## Mediation Analysis: Direct and Indirect Effects

> X → M → Y: indirect effect = the effect of X on Y through M
> X → Y: direct effect = the direct effect of X on Y not through M
> Total effect = direct effect + indirect effect

**Significance**: Causal effects propagate along different paths — decomposing direct and indirect effects helps understand causal mechanisms.

**Mathematical background**: Baron & Kenny (1986) proposed the classical method of mediation analysis (stepwise regression), but this method has serious flaws: it relies on linearity assumptions, ignores interaction effects, and cannot handle confounding. Pearl (2001) proposed the definitions for causal mediation analysis: natural direct effect NDE = E[Y_{x,M_{x'}}] - E[Y_{x',M_{x'}}] (the effect of changing X from x' to x while holding M at its natural value under x'); natural indirect effect NIE = E[Y_{x',M_x}] - E[Y_{x',M_{x'}}] (the effect of changing M from its natural value under x' to its natural value under x, while holding X at x'). Total effect = NDE + NIE. This definition does not rely on linearity assumptions.

## Rosenbaum's Sensitivity Analysis (2002)

> Given confounding strength Γ: maximum odds ratio P(U=1|T=1)/P(U=1|T=0) ≤ Γ.
> Compute: the maximum p-value at which the causal conclusion could be overturned under Γ.

**Significance**: Causal conclusions must be assessed for robustness — if an unobserved confounder of strength Γ can overturn the conclusion, it is fragile.

**Mathematical background**: Paul Rosenbaum, in *Observational Studies* (2002), systematized sensitivity analysis methods. Core idea: under randomization Γ=1 (treatment completely independent of confounders), Γ>1 indicates the possibility of unobserved confounding. For each Γ, compute: the minimum p-value for the treatment effect under the strongest possible confounding. If the p-value already exceeds the significance threshold at Γ=2, the conclusion is fragile to even weak confounding; if the p-value remains significant at Γ=5, the conclusion is highly robust. The E-value (VanderWeele & Ding, 2017) is a related concept: the minimum confounding strength required to nullify the effect estimate, E-value = ATE + √(ATE² + ATE).

## Pearl's Structural Causal Models (SCM)

> SCM = ⟨U, V, F, P(U)⟩
> U = exogenous variables (unobserved individual characteristics), V = endogenous variables (observed), F = structural equations {f_V}, P(U) = exogenous distribution
>
> Structural equation: V_i = f_i(PA_i, U_i), PA_i = direct causes (parent nodes) of V_i

**Significance**: Structural Causal Models provide the complete mathematical framework for causal inference — they simultaneously encode causal assumptions (DAG), interventions (do-calculus), and counterfactuals (structural equations).

**Mathematical background**: Pearl's SCM framework unifies the three levels of causal inference. Core mathematical objects: (1) the DAG encodes causal assumptions — the arrow PA_i → V_i indicates that PA_i is a direct cause of V_i; (2) structural equations V_i = f_i(PA_i, U_i) encode causal mechanisms — f_i is a causal function, not a statistical regression; (3) the mathematical operation of intervention do(X=x): replace the structural equation for X with X=x, keeping all other equations unchanged; (4) counterfactual computation Y_x(u): in the modified model (X=x), given exogenous variables U=u, compute the value of Y. Key property of SCM: from an SCM, all Level 1-3 quantities can be derived; conversely, Level 1 data alone cannot uniquely determine the SCM.

## The Fundamental Problem of Causal Inference

> For individual i: τ_i = Y_i(1) - Y_i(0)
> We can never simultaneously observe Y_i(1) and Y_i(0) — we can only see one of them.

**Significance**: Individual causal effects can never be directly observed — this is the fundamental problem of causal inference. All causal inference methods are essentially attempting to infer complete effects from partial information.

**Mathematical background**: Holland (1986) explicitly articulated this fundamental problem. Each individual i has two potential outcomes Y_i(treated) and Y_i(control), but the real world reveals only one. All causal inference strategies are essentially ways of circumventing this limitation: (1) randomization — replace individual effects with group means; (2) before-after comparison — approximate the control state using the individual's prior state (assuming no time trends); (3) regression adjustment — approximate individuals by matching on observable characteristics; (4) counterfactual modeling — predict unobserved potential outcomes using structural equations. Each strategy has its assumptions; violating them invalidates the conclusions.

## Simpson's Paradox and Causal Structure

> The same data yields opposite conclusions under different groupings:
> Overall: the treatment group has a higher recovery rate; stratified (by disease severity): the treatment group has a lower recovery rate.

**Significance**: The direction of statistical association depends on the level of analysis — Simpson's paradox reveals that pure statistical reasoning cannot determine "which grouping is correct"; causal assumptions are required.

**Mathematical background**: The essence of Simpson's paradox is confounding. Classic case: in a drug trial, mild patients are mostly assigned to the treatment group (high recovery rate), while severe patients are mostly assigned to the control group (low recovery rate). Overall, the treatment group shows a higher recovery rate (because it contains mostly mild patients), but after stratification by severity, the treatment group shows a lower recovery rate (the drug is actually harmful). Pearl's causal explanation: if disease severity Z is a confounder (Z→T and Z→Y), then P(Y|T=1) > P(Y|T=0) is a spurious association; the correct causal effect P(Y|do(T=1)) < P(Y|do(T=0)) requires back-door adjustment P(Y|do(T)) = Σ_z P(Y|T,z)·P(z). The causal DAG determines "whether to stratify by Z or compute overall" — without a causal model, statistical methods alone cannot provide an answer.

## d-Separation and Conditional Independence

> In DAG G, path p is d-separated by Z if p contains:
> (1) a chain A→B→C with B∈Z, or
> (2) a fork A←B→C with B∈Z, or
> (3) a collider A→B←C with B∉Z (and descendants of B ∉Z).

**Significance**: d-separation is the conditional independence encoded by the DAG — if X and Y are d-separated by Z, then X ⊥ Y | Z holds in all distributions generated by G.

**Mathematical background**: d-separation (directed separation) was proposed by Pearl (1988) to connect the causal graph structure with the independence properties of probability distributions. The three blocking rules correspond to three types of paths: chains (causal transmission paths), forks (confounding paths), and colliders (selection bias paths). Key properties of d-separation: (1) if X and Y are d-separated by Z, then X ⊥ Y | Z should be observed in the data — if X and Y remain correlated given Z, the DAG may be incorrect; (2) d-separation is an implication of the DAG — one need not know specific parameter values, as independence can be inferred from graph structure alone; (3) d-separation is foundational for causal reasoning — back-door paths are precisely non-causal paths not d-separated by the empty set.
