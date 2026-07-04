---
name: transformation
description: |
  Trigger when a problem is intractable in its current representation and needs a mathematical transform into an equivalent simpler problem; or finding an equivalent but more GPU-friendly representation (e.g. convolution->GEMM, spectral transform) for algorithm/operator design.
---

# Transformation

> "Complex problem -> equivalent simple problem; the key is finding the right transformation and its inverse."
>
> -- Fourier, Laplace, Coordinate Transform

## Core Principle

**The same problem can have different representations. Choosing a good representation (or transformation) can make a difficult problem simple.** The essence of a transformation is not to change the problem itself, but to change the perspective from which it is viewed.

> **Mathematical Formalization**
>
> Let a transformation $T: D_1 \to D_2$. $T$ is useful if and only if three conditions hold simultaneously: (1) **Computability**: $T(x)$ can be explicitly computed; (2) **Simplification**: the problem is more tractable in $D_2$ (e.g., differentiation -> multiplication, convolution -> multiplication); (3) **$T^{-1}$ exists**: the solution in $D_2$ can be mapped back to the original solution in $D_1$.
>
> Core question: **Under what conditions does $T^{-1}$ exist?** Existence determines equivalence, and the domain of convergence determines validity. Properties: equivalence (no information loss, requiring $T^{-1}$ to exist), simplification, invertibility (when $T^{-1}$ exists and is computable, the transformation is exact rather than approximate).

## GPU-Friendliness (Cross-Cutting Check)

In algorithm design, the value of a transformation often manifests as "converting an unfriendly operation into a GPU-friendly one" -- pass the eight-dimensional gate in `../../references/gpu-friendly-math.md`:

- **Convolution -> GEMM** (im2col / Winograd): Converts irregular convolution into matrix multiplication, fully utilizing Tensor Cores (friendly, but watch for memory expansion).
- **Spectral transforms (FFT / DCT)**: $O(N^2)\to O(N\log N)$, batch-parallelizable; but butterfly communication patterns require attention to memory access.
- **Duality transforms (Legendre / Fenchel)**: Converts constrained optimization into a dual problem -- friendly if the dual is more GEMM-amenable.
- **Transforms as compression**: Frequency-domain sparsity means only significant coefficients need to be stored (KV / activation compression, friendly).
- **Anti-patterns**: The transform itself requires $O(n^2)$ global rearrangement and cannot be fused -- "beautiful but incomputable"; the inverse transform is not numerically stable (ill-conditioned).

Eight-dimensional minimum assessment (formal terms): **Tensorization** -- whether the transform / inverse transform can be batched; **GEMM-mappability** -- whether it can be rewritten as GEMM / convolution / FFT / batched solve; **Complexity** -- the transform must reduce, not increase, the computational order; **Memory & KV-Cache** -- whether im2col, frequency-domain caches, and block summaries save memory rather than explode it; **Low-precision stability** -- inverse transform, orthogonalization, normalization; **Parallelism & communication** -- butterfly / scan / block communication patterns; **Sparse structure** -- whether frequency-domain / block sparsity is structured; **Operator fusion** -- whether the transform-core operation-inverse transform chain can be fused or recomputed.

> Cross-reference `../../references/books/matrix-analysis.md` (spectral / low-rank), `optimization-ml.md` (duality).

## When NOT to Use

- **The problem is already simple enough** -- no transformation is needed.
- **The transformation loses critical information** (irreversible, and the lost information is precisely what matters) -- choose an information-preserving transformation.
- **Only qualitative understanding is needed** -- transformations are typically quantitative tools.
- **Convergence conditions are not satisfied** -- forcing a transformation produces meaningless results.

## When to Use

- The problem is difficult to analyze or solve in its current form; revealing hidden structure in data (periodic signals -> frequency spectrum).
- Simplifying complex operations into simpler ones (convolution -> multiplication); linearizing nonlinear problems; decoupling coupled variables.
- **Finding an equivalent but more GPU-friendly representation for an operator** (convolution -> GEMM, sparse -> structured, frequency-domain compression).

## Method

### Step 1: Analyze the Difficulty of the Current Representation
Why is the current form hard to work with? Is the computation complex (e.g., ODEs are hard to solve directly)? Is the structure opaque (periodicity is invisible in the time domain)? Are variables coupled? Identifying "where the difficulty lies" is a prerequisite for choosing a transformation; selecting a transform without diagnosis is blind operation.

### Step 2: Select the Transformation
Choose based on the type of difficulty; for each candidate, verify the formula, domain mapping, convergence conditions, and simplification effect:

| Transform | Formula | Domain Mapping | Convergence / Validity | Simplification Effect |
|---|---|---|---|---|
| Fourier | $F(\omega)=\int f(t)e^{-i\omega t}\,dt$ | $t\in\mathbb{R}\to\omega\in\mathbb{R}$ | Dirichlet: absolutely integrable, finitely many extrema/discontinuities | Differentiation -> multiplication, convolution -> multiplication |
| Laplace | $F(s)=\int_0^\infty f(t)e^{-st}\,dt$ | $t\in[0,\infty)\to s\in\mathbb{C},\;\text{Re}(s)>\alpha$ | $\exists\alpha: \int|f(t)|e^{-\alpha t}\,dt<\infty$ | Constant-coefficient ODE -> algebraic equation, incorporates initial conditions |
| Z-transform | $F(z)=\sum f[n]z^{-n}$ | $n\in\mathbb{N}\to z\in\mathbb{C},\;|z|>R$ | $\exists R: \sum|f[n]|R^{-n}<\infty$ | Difference equation -> algebraic equation |
| Generating function | $G(x)=\sum a_n x^n$ | $n\in\mathbb{N}\to x,\;|x|<\rho$ | $\exists\rho: \sum|a_n|\rho^n$ converges | Recurrence -> differential equation |
| Legendre | $f^*(p)=\sup_x(px-f(x))$ | $x\to p=f'(x)$ | When $f$ is convex and differentiable, $p\leftrightarrow x$ is a bijection | Convex optimization -> dual, Lagrangian -> Hamiltonian |
| Wavelet | $W(a,b)=\int f(t)\psi_{a,b}(t)\,dt$ | $t\in\mathbb{R}\to(a,b)$ | $f\in L^2$, $\psi$ admissible | Time-frequency localization, multi-scale analysis |

### Step 3: Execute the Transformation
Transform the problem into the new representation space, strictly following the formula. A transformation is not an escape from the problem; it is a re-expression of the same problem in a more effective language.

### Step 4: Verify Convergence and Domain Conditions
**Before applying transformation results, one must verify convergence conditions**: For Fourier, check Dirichlet conditions ($\int|f|\,dt<\infty$); for Laplace, determine the region of convergence $\text{Re}(s)>\alpha$ (outside this region $F(s)$ is undefined); for the Z-transform, determine $|z|>R$ (the inverse transform depends on the choice of region of convergence); for generating functions, determine the radius of convergence $\rho$; for wavelets, verify the admissibility condition of the mother wavelet. Skipping this step is the largest source of errors.

### Step 5: Solve in the Transformed Space
In the new representation the problem is often simpler; all operations must be carried out within the valid domain of the transform. The value of the transformed space lies in making originally hidden structure visible.

### Step 6: Apply the Inverse Transform to Return to the Original Space
Map the solution back to the language of the original problem. The existence of the inverse transform requires conditions: Fourier inverse $f(t)=(1/2\pi)\int F(\omega)e^{i\omega t}\,d\omega$ (requires $F$ to be absolutely integrable); Laplace inverse via the Bromwich integral $f(t)=(1/2\pi i)\int F(s)e^{st}\,ds$ ($\gamma>\alpha$, to the right of the region of convergence); Z-inverse $f[n]=(1/2\pi i)\oint F(z)z^{n-1}\,dz$ (contour within the region of convergence); generating function $a_n=G^{(n)}(0)/n!$ or $[x^n]G(x)$. The transformation is merely a means; the final answer must be in the original space.

### Step 7: Verify Equivalence
Confirm that the transformation has not lost critical information and that the inverse-transformed result is indeed a solution of the original problem: Was the inverse transform executed within the correct region of convergence? Does the original function satisfy the prerequisite conditions? Were boundary / initial conditions correctly encoded? Equivalence is the bottom line of transformation theory -- a transformation must be a verifiably equivalent operation, not an approximation or an evasion.

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Choosing an inappropriate transformation | Fails to simplify and instead increases complexity | Select the transformation based on problem characteristics |
| Using an irreversible transformation that loses information | Cannot return to the original problem after transformation | Verify invertibility or confirm that the lost information is not critical |
| Forgetting the inverse transform | After obtaining a solution in the new space, forgetting to transform back | The final answer must be in the original space |
| Ignoring domain changes after transformation | The transformation may alter the domain or introduce singularities | Check the post-transformation domain and boundary conditions |
| Treating the transformation as magic | A transformation only changes the representation, not the essence of the problem | A transformation is a tool; understanding is the core competency |
| Applying Fourier to non-integrable functions | When $\int|f|\,dt=\infty$, $F(\omega)$ may be meaningless | First check Dirichlet conditions; if not satisfied, use generalized functions or Laplace |
| Ignoring the Laplace region of convergence | $F(s)$ is defined only for $\text{Re}(s)>\alpha$ | Restrict all operations to the region of convergence |
| Assuming all transformations are invertible | Some transformations are not invertible under certain conditions (e.g., non-convex Legendre) | Verify invertibility conditions before applying the inverse transform |
| Overlooking discrete transforms (DFT/FFT) | Continuous transforms are not applicable to discrete data | Use the DFT for discrete data: $X[k]=\sum x[n]e^{-i2\pi kn/N}$ |
| Post-transformation incomputability / non-fusibility | The transform requires $O(n^2)$ global rearrangement or an ill-conditioned inverse | Evaluate the GPU eight-dimensional gate; if necessary, choose a fusible, numerically stable equivalent transformation |

## Operating Procedure

The output must include:

1. **Difficulty of the current representation**: `[Difficulty]: [Description]`
2. **Transformation selection**: `[Transform]: [Choice] because [Reason], formula [Formula], convergence conditions [Conditions], expected simplification [Effect]`
3. **Transformation execution**: The problem form after transformation
4. **Convergence and domain verification**: `[Verification]: [Whether conditions are satisfied, region of convergence]`
5. **Solution in transformed space**: The solution method under the new representation
6. **Inverse transform**: The solution translated back to the original space, noting inverse-transform conditions
7. **Equivalence verification**: Is it invertible? Is information lost? Is the region of convergence correct?
8. **[GPU viability]** (if used for operator design) -- whether the transformation converts the operation into GEMM / fusible / numerically stable form; pass the eight-dimensional gate

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Abstraction**: A transformation is also an act of abstraction -- representing the same object in a new structure.
- **Symmetry and invariance**: Properties that remain unchanged under a transformation are precisely the symmetries of that transformation.
- **Optimization**: Transforming to the dual space sometimes makes optimization easier.
- **Modeling**: A transformation is often a key step in solving a model.
- **Algorithmic thinking**: The FFT reduces the DFT from $O(N^2)$ to $O(N\log N)$, exemplifying how transformation ideas serve computational efficiency.
- **Information theory**: Coding is transformation -- source coding transforms data into an efficient representation; channel coding transforms it into a noise-resistant representation.
- **Modern mathematics activation**: `../../references/books/matrix-analysis.md` (spectral / low-rank transforms), `algebraic-geometry-rising-sea.md` (Plücker coordinates for KV compression, tropical gating), `optimization-ml.md` (duality transforms).
