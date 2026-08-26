# Probability & Information Activation Index

## Domain Signals
Activate this domain direction when the problem involves:
- Uncertainty quantification: need to quantify the concentration or tail behavior of random variables
- Generalization bounds: need to derive theoretical upper bounds on model generalization
- Distribution distance: need to measure the difference between two distributions
- Information compression: need to compress representations while preserving information
- Sample efficiency: need to analyze the ability to learn from finite samples
- Tail control: need to control the probability of extreme deviations of random variables

## Core Anchors
- `concentration-inequality.en.md` — Concentration inequalities
- `entropy.en.md` — Entropy
- `kl-divergence.en.md` — KL divergence
- `information-bottleneck.en.md` — Information bottleneck
- `fisher-information.en.md` — Fisher information
- `optimal-transport.en.md` — Optimal transport and Wasserstein distance (Sinkhorn)
- `score-matching-sde.en.md` — Score matching and SDEs (diffusion models)

## Extended Concepts
When core anchors are insufficient, the following concepts may need temporary activation:
- total variation distance: total variation distance
- f-divergence family: f-divergence family (chi-squared, Hellinger, Jensen-Shannon, etc.)
- mutual information estimation (MINE / NWJ): neural estimation methods for mutual information
- variational inference (ELBO / VI): variational inference and evidence lower bound
- Markov chain Monte Carlo: Markov chain Monte Carlo methods
- stochastic process (martingale, Brownian motion): stochastic process fundamentals
- PAC-Bayes bounds: PAC-Bayes generalization bounds
- Rademacher complexity: Rademacher complexity
- VC dimension: VC dimension and hypothesis space capacity
- generalization via compression: compression-based generalization theory
- differential privacy: differential privacy
- normalizing flow theory: normalizing flow theory
- unbalanced / Gromov–Wasserstein OT: unbalanced and cross-space optimal transport
- Langevin dynamics / Schrödinger bridge: Langevin sampling and diffusion bridges

## Reference Book Directions
- `../../references/books/optimization-ml.en.md`: variational methods and probabilistic inference chapters

## AI Translation Directions
- concentration inequality → generalization bounds / confidence-aware predictions / tail-risk loss
- entropy → entropy regularization / uncertainty estimation / exploration bonus
- kl-divergence → distribution matching loss / knowledge distillation / policy regularization
- information bottleneck → representation compression / VIB loss / uncertainty routing
- fisher information → natural gradient / parameter sensitivity monitor / active learning
- optimal transport → Sinkhorn routing / distribution matching loss / Wasserstein barycenter
- score matching & SDE → diffusion training / ODE samplers / inverse-problem posterior sampling

## Temporary Activation Rules
When the problem requires mathematics not in the core anchors:
1. First check whether extended concepts contain a match
2. If yes, generate a temporary knowledge card based on the lens
3. If no, enter the Knowledge Gap Protocol
