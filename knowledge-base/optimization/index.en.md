# Optimization Activation Index

## Domain Signals
Activate this domain direction when the problem involves:
- Constrained optimization: objective function must satisfy equality or inequality constraints
- Duality gap: need to analyze the relationship between primal and dual problems
- Saddle point problems: min-max optimization or game-theoretic structure
- Non-convex landscape: geometric structure analysis of loss functions
- Manifold constraints: parameters need to be optimized on a manifold
- Splitting operators: objective decomposes into multiple components for combined optimization

## Core Anchors
- `lagrangian-duality.md` — Lagrangian duality theory
- `convex-optimization.md` — Convex optimization fundamentals
- `constrained-optimization.md` — Constrained optimization methods
- `riemannian-optimization.md` — Riemannian optimization
- `proximal-method.md` — Proximal methods

## Extended Concepts
When core anchors are insufficient, the following concepts may need temporary activation:
- ADMM: alternating direction method of multipliers, suitable for splitting structures
- mirror descent: mirror descent, suitable for non-Euclidean geometry
- Frank-Wolfe: conditional gradient method, suitable for sparsity constraints
- stochastic optimization (SGD / SAdam convergence): convergence theory for stochastic optimization
- second-order methods (Newton / quasi-Newton): second-order and quasi-Newton methods
- trust region: trust region methods
- line search: line search strategies and convergence guarantees
- gradient clipping theory: theoretical analysis of gradient clipping
- sharpness-aware minimization (SAM): sharpness-aware minimization
- neural tangent kernel optimization landscape: optimization landscape under NTK
- implicit regularization: implicit regularization effects
- bilevel optimization: bilevel optimization and hyperparameter optimization
- minimax optimization: minimax optimization theory
- meta-learning optimization: optimization framework for meta-learning

## Reference Book Directions
- `../../references/books/optimization-ml.md`: comprehensive coverage of ML optimization, including convex optimization, stochastic methods, and second-order methods

## AI Translation Directions
- lagrangian duality → primal-dual training / adversarial loss / constrained generation
- convex optimization → convex regularizers / proximal updates / mirror descent optimizer
- constrained optimization → projected gradient / penalty loss / barrier methods in training
- riemannian optimization → manifold-constrained parameters / natural gradient / geodesic update
- proximal method → sparse regularization / ISTA/FISTA layers / proximal neural networks

## Temporary Activation Rules
When the problem requires mathematics not in the core anchors:
1. First check whether extended concepts contain a match
2. If yes, generate a temporary knowledge card based on the lens
3. If no, enter the Knowledge Gap Protocol
