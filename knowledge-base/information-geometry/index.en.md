# Information Geometry Activation Index

## Domain Signals
Activate this domain direction when the problem involves:
- Distribution family geometry: probability distribution families have intrinsic geometric structure
- Parameterization-independent optimization: optimization methods should not depend on specific parameterization
- Statistical model complexity: need to measure the intrinsic complexity of statistical models
- Distance between distributions: need to define geometric distance in distribution space
- Natural gradient: gradient direction must account for the geometric structure of parameter space

## Core Anchors
- `natural-gradient.md` — Natural gradient
- `fisher-metric.md` — Fisher metric

## Extended Concepts
When core anchors are insufficient, the following concepts may need temporary activation:
- alpha-divergence: alpha-divergence family
- Amari-Chentsov tensor: Amari-Chentsov tensor and cubic differential structure
- dually flat manifold: dually flat manifolds
- e-connection / m-connection: exponential connection and mixture connection
- Pythagorean theorem for KL: generalized Pythagorean theorem for KL divergence
- Bregman divergence: Bregman divergence and convex duality
- mirror descent as natural gradient: equivalence between mirror descent and natural gradient
- EM algorithm geometry: geometric interpretation of the EM algorithm
- variational Bayes geometry: geometric structure of variational Bayes
- information geometry of neural networks (loss landscape curvature): information geometry of neural networks and loss landscape curvature
- neural tangent kernel as metric: neural tangent kernel as a metric
- Fisher-Rao gradient flow: Fisher-Rao gradient flow
- Wasserstein gradient flow: Wasserstein gradient flow

## Reference Book Directions
- `../../references/books/smooth-manifolds.md`: Chapter 13 on Riemannian metrics, providing differential geometry foundations for information geometry

## Temporary Activation Rules
When the problem requires mathematics not in the core anchors:
1. First check whether extended concepts contain a match
2. If yes, generate a temporary knowledge card based on the lens
3. If no, enter the Knowledge Gap Protocol
