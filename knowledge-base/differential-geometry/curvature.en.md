# Curvature

## Minimal Definition

Curvature measures whether a manifold "bends" and whether "paths are path-dependent." The Riemann curvature tensor $R(X,Y)Z = \nabla_X\nabla_Y Z - \nabla_Y\nabla_X Z - \nabla_{[X,Y]}Z$ describes the deflection of a vector after parallel transport around an infinitesimal parallelogram. The sectional curvature $K(\sigma)$ is its simplest scalar extraction.

## Core Formulas

- Riemann curvature tensor: $R^l_{ijk} = \partial_i \Gamma^l_{jk} - \partial_j \Gamma^l_{ik} + \Gamma^l_{im}\Gamma^m_{jk} - \Gamma^l_{jm}\Gamma^m_{ik}$
- Ricci curvature (contraction): $R_{ij} = \sum_k R^k_{ikj}$
- Scalar curvature: $S = \sum_{ij} g^{ij} R_{ij}$
- Sectional curvature: $K(X,Y) = \frac{\langle R(X,Y)Y, X\rangle}{\|X\|^2\|Y\|^2 - \langle X,Y\rangle^2}$
- Jacobi equation: $\frac{D^2 J}{dt^2} + R(J, \dot\gamma)\dot\gamma = 0$ (describes divergence/convergence of geodesics)
- Hessian-vector product: $Hv = \nabla(\nabla L \cdot v)$, $O(N)$ estimation of curvature information

## Applicable Problems

- Loss landscape analysis: curvature determines conditioning and sharpness, distinguishing sharp minima from flat minima
- Optimization trajectory stability: Jacobi fields describe the divergence/convergence of neighboring optimization trajectories
- Generalization diagnostics: flat minima (low curvature) tend to generalize better
- Manifold learning: the curvature of the data manifold guides latent space dimension and metric selection

## AI Design Translation

- **Curvature regularization (geometric perspective on SAM)**: Use Hessian-vector products to estimate $\max_v v^T H v$, penalizing sharp minima and preferring flat minima
- **HVP-based diagnostic**: $\|Hv\|/\|v\|$ as a cheap proxy for loss landscape curvature, used for learning rate adaptation and early stopping
- **Jacobi field trajectory monitoring**: Track the distance evolution between two neighboring optimization trajectories, the discrete analog of $J''(t) + R(J,\dot\gamma)\dot\gamma = 0$, to detect divergence/convergence
- **Ricci-flow-inspired graph rewiring**: Use discrete Ricci curvature to guide dynamic adjustment of graph/attention structure (negative-curvature edges indicate bottlenecks that need additional connections)

## Engineering Feasibility

GPU friendliness: the core difficulty of curvature is that "the full tensor cannot be materialized."
- **Riemann tensor**: 4th order, $n^4$ components, materializing it exhausts memory -- **explicit computation is prohibited**
- **Hessian-vector product (HVP)**: Via Pearlmutter's algorithm, one forward pass + one backward pass yields $Hv$, $O(N)$ time and $O(N)$ memory, GPU-friendly
- **Monte Carlo estimation of Ricci/scalar curvature**: Randomly sample directions $v$, $\mathbb{E}[v^T H v] = \text{tr}(H)$, using Hutchinson's estimator, GPU-friendly
- **Jacobi fields**: Require integrating a second-order ODE along a trajectory, serial recurrence, GPU-unfriendly; in practice, discrete finite-difference approximations are used
- Low precision: second-order derivatives in HVP are noisy under fp16, requiring fp32 accumulation

## Risks and Failure Conditions

- **Materializing the full Riemann/Hessian tensor**: $O(N^2)$ to $O(N^4)$ memory, impossible when $N \sim 10^9$
- **Low signal-to-noise ratio in curvature estimation**: Monte Carlo estimation of HVP has high variance; with small batches, the signal may be drowned in noise
- **Treating curvature regularization as a panacea**: Curvature estimation itself is expensive (requiring additional forward and backward passes); benefits should be validated at small scale first when uncertain
- **Discrete approximation errors**: When using finite differences to approximate Jacobi fields/HVP, the step size is sensitive -- too large causes truncation error, too small causes floating-point cancellation

## Further References

- Distillation notes: references/books/differential-geometry.md (Ch 12 Section 12.5/Section 12.10 Curvature, Ch 13 Section 13.2 Riemann Curvature, Section 13.7 Jacobi Fields, Section 13.11 Rauch Comparison)
- Original text: Jeffrey M. Lee, *Manifolds and Differential Geometry*, Section 13.2 Riemann Curvature Tensor, Section 13.7 Jacobi Fields


## Routing Extensions
- If local geometric analysis is needed -> `metric-tensor.md` (metric determines local curvature)
- If global topological analysis is needed -> `persistent-homology.md` (persistent homology captures global topology)
- If curvature's effect on stability is involved -> `matrix-perturbation.md` (curvature-induced perturbation amplification)

## Extensible Directions
- Sectional / Ricci / scalar curvature: curvature concepts at different dimensions
- Gauss-Bonnet theorem: relationship between curvature and topological invariants
- Comparison theorems (Toponogov, Bishop-Gromov): geometric comparison under curvature constraints
- Curvature flow: mean curvature flow and Ricci flow
- Cartan-Hadamard theorem: global structure of non-positively curved manifolds
