# Curvature

## Minimal Definition

Use $R(X,Y)Z=\nabla_X\nabla_YZ-\nabla_Y\nabla_XZ-\nabla_{[X,Y]}Z$. Riemann curvature describes local path dependence of a connection; a loss Hessian describes second derivatives of a function. They are different objects: Euclidean space has zero Riemann curvature even when a loss Hessian is nonzero.

## Core Formulas

- Define components by $R(\partial_i,\partial_j)\partial_k=R^l_{ijk}\partial_l$:
  $R^l_{ijk}=\partial_i\Gamma^l_{jk}-\partial_j\Gamma^l_{ik}+\Gamma^l_{im}\Gamma^m_{jk}-\Gamma^l_{jm}\Gamma^m_{ik}$.
- With this convention, $\operatorname{Ric}_{jk}=\sum_i R^i_{ijk}$ and $S=g^{jk}\operatorname{Ric}_{jk}$.
- $K(X,Y)=\langle R(X,Y)Y,X\rangle/(\|X\|^2\|Y\|^2-\langle X,Y\rangle^2)$ for linearly independent $X,Y$.
- Jacobi fields along geodesics satisfy $D_t^2J+R(J,\dot\gamma)\dot\gamma=0$.
- For fixed $v$ and a twice-differentiable scalar loss, $Hv=\nabla(\nabla L\cdot v)$. If $\mathbb E[vv^T]=I$, then $\mathbb E[v^THv]=\operatorname{tr}H$. This is the Hessian trace, not scalar curvature.

## Applicable Problems

- Manifold geometry: compare geodesics and analyze local curvature for a specified metric.
- Optimization diagnostics: use Hessian Rayleigh quotients, spectra, and HVPs for local loss sensitivity; specify coordinates and scale.
- Generalization research: test associations between sharpness and independent test error; flatness alone proves no generalization guarantee.

## AI Design Translation

- **HVP diagnostics:** estimate $v^THv$ with $\|v\|=1$; the maximum Rayleigh quotient is the largest eigenvalue. The norm constraint is essential.
- **SAM-inspired analysis:** neighborhood worst-case loss can relate to Hessians via local expansion; SAM does not minimize Riemann curvature.
- **Trajectory stability:** gradient-flow linearization involves the loss Hessian; the Jacobi equation directly applies to geodesic variations.
- **Graph rewiring:** discrete Ricci curvature may suggest bottleneck candidates; specify its discrete definition and measure task outcomes rather than automatically adding edges with negative curvature.

## Engineering Feasibility

- Dense Riemann tensors require $O(n^4)$ storage and Hessians $O(N^2)$. Explicit low-dimensional geometry is viable; large models favor contractions or matrix actions.
- Mixed-mode autodiff computes HVPs at costs typically comparable to a constant number of gradient evaluations. Use computation-graph cost and activation memory, not parameter count alone, to estimate complexity.
- Hutchinson estimation uses independent Rademacher/standard Gaussian directions; report sample count and variance. Unit-vector sampling requires a different normalization factor.
- Validate fp32 accumulation, direction normalization, and finite-difference steps. Higher precision does not solve arbitrary ill-conditioning.

## Risks and Failure Conditions

- Curvature sign conventions change Ricci contractions; do not mix conventions.
- Hessian trace, largest eigenvalue, and manifold scalar curvature are not interchangeable.
- Reparameterization can change Euclidean sharpness; fix coordinates and scales in comparisons.
- Numerical HVPs and finite-sample trace estimates are computational evidence, not global convergence or generalization proofs.

## Further References

- [Differential geometry notes](../../references/books/differential-geometry.en.md): connections, Riemann curvature, and Jacobi fields.
- [Pearlmutter, Fast Exact Multiplication by the Hessian](https://www.bcl.hamilton.ie/~barak/papers/nc-hessian.pdf): autodiff HVPs.

## Routing Extensions

- Metrics and connections: `metric-tensor.en.md`, `connection.en.md`.
- Optimization and spectral sensitivity: `../matrix-analysis/matrix-perturbation.en.md`.

## Extensible Directions

Comparison geometry, Gauss–Bonnet, curvature flows, and coordinate-invariant sharpness diagnostics require their own hypotheses.
