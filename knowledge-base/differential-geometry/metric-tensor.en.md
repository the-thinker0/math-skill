# Metric Tensor

## Minimal Definition

The metric tensor $g$ is a positive-definite symmetric bilinear form $g_p: T_pM \times T_pM \to \mathbb{R}$ on the tangent space $T_pM$ at each point $p$ of a manifold, defining inner products, lengths, angles, and distances on the manifold. It is the precise quantification of "what is close to what" and "which direction is steepest."

## Core Formulas

- Inner product: $\langle u, v \rangle_g = u^T g_p v = \sum_{ij} g_{ij} u^i v^j$
- Arc length element: $ds^2 = \sum_{ij} g_{ij} dx^i dx^j$
- Geodesic distance: $d(p,q) = \inf_\gamma \int_0^1 \sqrt{g_{\gamma(t)}(\dot\gamma, \dot\gamma)} \, dt$
- Musical isomorphism (index raising/lowering): $v^\flat = gv$ (tangent to cotangent), $\omega^\sharp = g^{-1}\omega$ (cotangent to tangent)
- Fisher-Rao metric: $g_{ij}(\theta) = \mathbb{E}_{p_\theta}\left[\frac{\partial \log p_\theta}{\partial \theta^i} \frac{\partial \log p_\theta}{\partial \theta^j}\right]$

## Applicable Problems

- Parameter space is non-flat and non-Euclidean: the natural metric on families of probability distributions is the Fisher information matrix
- Slow optimization convergence: poor conditioning arises from metric mismatch, remedied by preconditioning with the natural gradient $g^{-1}\nabla L$
- Distance/similarity must adapt to data geometry: metric learning is essentially learning a $g$
- Volume computation and density estimation: $\sqrt{\det g}$ gives the volume form on the manifold

## AI Design Translation

- **Natural gradient / K-FAC optimizer**: $F^{-1}\nabla L$ where $F$ is the Fisher metric; K-FAC uses the Kronecker factorization $F \approx A \otimes B$ to reduce inversion to two small matrix inversions, and the preconditioning reduces to a GEMM chain
- **Learnable metric layer**: Parameterize $g = L^T L$ (Cholesky) to learn a task-specific Riemannian metric for metric learning and contrastive learning
- **Information-geometric regularization**: Replace Euclidean $\|d\theta\|^2$ with the Fisher-Rao distance $\|d\theta\|_F^2 = d\theta^T F d\theta$, making regularization invariant to reparameterization
- **Fisher-aware learning rate scheduling**: Use $\|g^{-1}\nabla L\|_g$ as the "geometrically correct" gradient norm to guide learning rate selection

## Engineering Feasibility

GPU friendliness depends on the structure of the metric:
- **Diagonal metric** $g = \text{diag}(g_1, \ldots, g_n)$: element-wise multiply/divide, $O(n)$, perfectly GPU-friendly
- **Kronecker-factored** $g = A \otimes B$: $(A\otimes B)^{-1} = A^{-1}\otimes B^{-1}$, small matrix inversions + GEMM chain, the core trick of K-FAC, GPU-feasible
- **Block-diagonal metric**: per-block independent inversion, batched small matrix operations, GPU-friendly
- **Full dense metric**: $n \times n$ matrix inversion $O(n^3)$ + memory $O(n^2)$; with parameter count $N \sim 10^9$, this is immediately ruled out
- Low-precision risk: the Fisher matrix is often ill-conditioned; inversion under fp16 catastrophically amplifies errors -- **must add damping $F + \lambda I$ and invert in fp32**

## Risks and Failure Conditions

- **Ill-conditioned metric matrix**: The condition number of the Fisher matrix can exceed $10^6$; low-precision inversion results are entirely noise
- **Materializing the full metric matrix**: An $N \times N$ matrix ($N \sim 10^9$) requires $\sim 4$ PB of memory, making materialization impossible
- **Metric-task mismatch**: The Fisher metric assumes the probabilistic model is correct; under model misspecification, the natural gradient can perform worse than SGD
- **Dynamic metric update overhead**: The Fisher matrix changes with the parameters; statistical noise from re-estimation at each step may offset preconditioning benefits

## Further References

- Distillation notes: ../../references/books/differential-geometry.en.md (Ch 7 Section 7.6 Metric Tensors, Ch 13 Section 13.1 Levi-Civita)
- Distillation notes: ../../references/books/smooth-manifolds.en.md (Ch 13 Riemannian Metrics)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 7.6 Metric Tensors
- Original text: John M. Lee, *Introduction to Smooth Manifolds*, Ch 13 (Riemannian metrics, musical isomorphisms sharp/flat)


## Routing Extensions
- If the metric comes from Fisher information -> `natural-gradient.md` (natural gradient under Fisher metric)
- If Riemannian gradient computation is needed -> `riemannian-optimization.md` (metric determines gradient direction)
- If curvature analysis is needed -> `curvature.en.md` (metric determines curvature tensor)

## Extensible Directions
- Finsler metric: generalized non-quadratic metrics
- Sub-Riemannian metric: metrics under distribution constraints
- Information metric: Fisher-Rao metric on statistical manifolds
- Pullback metric: metric induced by a mapping
- Metric learning: learning optimal metrics from data
- Distance metric learning: supervised distance learning
