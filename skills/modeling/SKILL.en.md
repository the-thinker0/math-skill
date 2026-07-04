---
name: modeling
description: |
  Trigger when translating real-world problems into mathematics (reality->math->interpretation), building predictive/explanatory models, performing dimensional analysis and model selection, or establishing computable models for algorithms/operators/structures.
---

# Modeling

> "Transforming real-world problems into mathematical problems, solving them mathematically to explain and predict reality. All models are wrong, but some are useful."
>
> -- Applied Mathematics, Mathematical Modeling

## Core Principle

**A model is a simplified representation of reality, not reality itself. A good model is not one that is "true," but one that makes accurate predictions within its domain of applicability.**

The golden cycle of modeling: (1) **Real-world problem -> Mathematical problem** (translation); (2) **Mathematical problem -> Mathematical solution** (solving); (3) **Mathematical solution -> Real-world interpretation** (back-translation); (4) **Real-world interpretation -> Experimental validation** (verification).

> **Mathematical Formalization**
>
> **Dimensional Analysis & Buckingham Pi Theorem**: Before constructing equations, one must verify dimensional consistency. If a system involves $n$ physical quantities spanning $m$ fundamental dimensions, one can construct $k=n-m$ dimensionless Pi terms, thereby reducing the number of variables and simplifying the equations; dimensionally inconsistent equations are physically inadmissible.
>
> **Model Specification**: Let the system output be $y$, with inputs $x_1,\dots,x_p$, and model $y=f(x_1,\dots,x_p;\theta)+\varepsilon$, where $f$ is the model function, $\theta$ is the parameter vector, and $\varepsilon$ is the error term. Model selection amounts to choosing the bias-variance-optimal $f$ from a candidate set $\{f_1,f_2,\dots\}$.

## GPU-Friendliness (Cross-Cutting Check)

When a model is used for **algorithm/operator/training design**, model selection and parameterization directly determine GPU viability -- pass the eight-dimensional gate in `../../references/gpu-friendly-math.md`:

- **Linear / GEMM-compatible parameterization**: $y=f(x;\theta)$ where $f$ can be expressed as dense tensor algebra or a chain of matrix multiplications (linear regression, MLP) -- friendly, fully utilizes Tensor Cores.
- **Low-rank parameterization**: $\theta$ uses low-rank / block structure instead of dense representation -- memory-friendly, compressible (see `../../references/books/matrix-analysis.md`).
- **Operator splitting / block parallelism**: PDE/ODE models decomposed by spatial/temporal blocks, serial recurrence converted to parallel scan -- amenable to adaptation.
- **Anti-patterns**: Model requires $O(n^2)$ dense global operations (naive full attention), data-dependent branching / scalar loops, ill-conditioned numerics requiring fp64, non-differentiable operations requiring discrete search -- "beautiful but incomputable"; switch to a tensorizable, fusible, numerically stable equivalent parameterization.

Eight-dimensional minimum assessment (formal terms): **Tensorization** -- whether model equations can be evaluated in batch; **GEMM-mappability** -- whether the parameterization can be expressed as matrix multiplication / convolution / low-rank factors; **Complexity** -- growth of state dimension, time steps, interaction terms; **Memory & KV-Cache** -- whether hidden states, activations, and caches can be compressed; **Low-precision stability** -- whether equations are ill-conditioned or require fp64; **Parallelism & communication** -- whether the dynamical system can be decomposed into blocks / scans; **Sparse structure** -- whether the coupling graph is structured; **Operator fusion** -- whether model updates and loss computation can be fused.

> Cross-reference `../../references/books/optimization-ml.md` (model parameterization and training), `matrix-analysis.md` (low-rank, condition number, compression).

## When NOT to Use

- **The problem cannot be quantified or structured** -- modeling requires well-defined variables and relationships.
- **Only qualitative understanding is needed** (e.g., "roughly how does this phenomenon work") -- modeling would be overly precise.
- **Fundamental data is lacking** -- a model without data is merely conjecture.

## When to Use

- When a real-world problem needs to be precisely formulated in mathematical language (reality -> math -> interpretation).
- Building predictive / explanatory models to interpret experimental data or predict new phenomena.
- Understanding interactions and sensitivities among factors in complex systems.
- Performing dimensional analysis, model selection (AIC/BIC/CV), and sensitivity analysis.
- **Establishing computable models for algorithms/operators/structures** and evaluating the GPU viability of their parameterizations.

## Method

### Step 1: Define the Real-World Problem
Describe the problem to be solved in the clearest possible language. Key questions: What are the **inputs** of the system? What are the **outputs**? Is the goal prediction, explanation, or optimization? Without clear direction, modeling goes astray.

### Step 2: State Assumptions
This is the most critical and most perilous step in modeling. All models require simplification, but one must **explicitly document every assumption**: Which factors are important and which can be neglected? Is the system deterministic or stochastic? Static or dynamic? Are variable relationships linear or nonlinear? Every assumption must be justified.

### Step 3: Establish Mathematical Structure / Dimensional Analysis
Choose a mathematical framework based on the assumptions:

| Phenomenon Characteristics | Mathematical Framework |
|---|---|
| Causal relationships among variables | ODE/PDE (ordinary/partial differential equations) |
| Spatial distribution and propagation | Partial differential equations (heat conduction, wave, diffusion) |
| Relationships among discrete objects | Graph theory |
| Decision-making under uncertainty | Probabilistic models |
| Resource allocation | Optimization models |
| Population behavior and interactions | Statistical models / Markov chains / Agent-based models |
| Classification and prediction | Function approximation / Regression |

Before constructing equations, one must verify dimensional consistency and construct $k=n-m$ dimensionless Pi terms to reduce variables and simplify equations; dimensionally inconsistent equations are physically inadmissible.

### Step 4: Solve
Solve the model using mathematical methods: **analytical solutions** (exact but possibly nonexistent), **numerical solutions** (approximate but always obtainable), **qualitative analysis** (seeking properties such as stability and monotonicity rather than explicit solutions).

### Step 5: Interpret and Validate
Translate the mathematical solution back into real-world language; compare with existing data or experimental results; perform sanity checks to verify whether predictions are reasonable. Conclusions inconsistent with reality are invalid no matter how "elegant" they may be.

### Step 6: Sensitivity Analysis and Model Selection
**Sensitivity analysis**: If a small perturbation in a parameter causes a large change in output, that parameter is sensitive and its precision must be carefully controlled.
**Bias-variance trade-off**: Simple models have high bias and low variance (underfitting); complex models have low bias and high variance (overfitting); the optimal model strikes a balance between the two.
**Model selection criteria**: AIC $= -2\log L + 2k$ (favors slightly more complex models, suitable for prediction); BIC $= -2\log L + k\log n$ (heavier penalty, favors parsimony, suitable for explanation); Cross-validation (CV) evaluates out-of-sample predictive performance and guards against overfitting.

### Step 7: Iterate and Improve
Models almost always require refinement. If predictions conflict with evidence: Which assumption is at fault? Should new factors be introduced? Should the mathematical framework be changed? When predictions disagree with reality, the response is not to abandon modeling but to revise the model.

### Step 8: Declare Scope of Applicability
Explicitly state the conditions under which the model is valid and those under which it fails. All models have boundaries -- a scope-of-applicability declaration is the model's "expiration label" and is the key safeguard against misuse.

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Overfitting | Model is too complex, fitting noise rather than signal | Apply Occam's razor: do not multiply entities beyond necessity |
| Underfitting | Model is too simple to capture key phenomena | Inspect residual patterns to identify missing factors |
| Ignoring assumption validity | Assumptions are made for mathematical convenience rather than physical plausibility | Every assumption must be grounded in real-world justification |
| Extrapolating beyond the domain of applicability | Model is valid only within a certain range; beyond it, predictions fail | Explicitly declare the model's scope of applicability |
| Confusing correlation with causation | Relationships in a model do not imply causation | Distinguish descriptive models from causal models |
| Forgetting validation | Using a model immediately after construction without checking predictions | Validate with independent data |
| Ignoring dimensional consistency | Dimensions on both sides of an equation do not match; physically inadmissible | Perform dimensional analysis before constructing equations; construct dimensionless Pi terms |
| Selecting models based only on in-sample fit | In-sample error underestimates true prediction error | Use AIC/BIC or cross-validation to assess out-of-sample performance |
| Neglecting sensitivity analysis | Not knowing which parameters drive the results | Perform sensitivity analysis on key parameters and focus on sensitive ones |
| Confusing validation with model selection | Validation tests a given model; selection compares among candidates | First select a model using AIC/BIC/CV, then validate with independent data |
| Excessively complex model leading to incomputability | Parameterization cannot be tensorized / GEMM-mapped; $O(n^2)$ memory explosion | Choose a tensorizable, fusible, numerically stable equivalent parameterization; pass the GPU eight-dimensional gate |

## Operating Procedure

When this skill is triggered, the output must include:

1. **Problem definition**: A one-sentence description of the real-world problem to be solved
2. **Assumption list**: `[Assumption N]: [Content] (Plausibility: High/Medium/Low)`
3. **Dimensional check**: Perform dimensional analysis on key physical quantities and construct dimensionless Pi terms
4. **Model selection**: `[Framework]: [Choice] because [Reason]`
5. **Variable definitions**: Define all variables, parameters, and their physical meanings
6. **Solution approach**: Specify the solving method (analytical / numerical / qualitative)
7. **Sensitivity analysis**: Identify sensitive parameters and assess their impact on the output
8. **Model selection criteria**: If candidate models exist, compare them using AIC/BIC/CV and select the best
9. **Validation plan**: How will the model's validity be tested?
10. **Scope of applicability**: Explicitly state the conditions under which the model is valid and those under which it fails
11. **[GPU viability]** (if used for algorithm/operator/structure): Whether the model parameterization is tensorizable / GEMM-mappable, whether complexity and memory are acceptable; pass the eight-dimensional gate in `../../references/gpu-friendly-math.md`; label as friendly / retrofittable / unfriendly, with adaptation recommendations.

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Axiomatic thinking**: The assumptions of a model are analogous to axioms; their consistency must be verified.
- **Abstraction**: Modeling is an application of abstraction -- abstracting from reality to a mathematical structure.
- **Optimization**: The objective function of many models is itself an optimization problem.
- **Probability and statistics**: Modeling uncertainty requires the tools of probability theory.
- **Transformation**: Solving a model often requires transforming it into a more tractable representation.
- **Algorithmic thinking**: Computational models (agent-based, cellular automata) employ algorithms as the modeling framework.
- **Causal inference**: Causal models (DAGs, structural causal models) explicitly distinguish causation from correlation.
- **Modern mathematics activation**: `../../references/books/smooth-manifolds.md` (manifold constraints / latent-space geometry), `../../references/books/differential-geometry.md` (metrics / curvature), `../../references/books/optimization-ml.md` (parameterization and training).
