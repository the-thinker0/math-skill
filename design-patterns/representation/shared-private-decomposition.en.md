# Shared-Private Decomposition
> **Evidence labels**: [v] supported by stated assumptions or recorded checks; [~] engineering proposal requiring validation; [x] incompatible under the stated conditions; [N/A] outside scope. Pseudocode specifies operators, not a production-ready implementation.

## Applicable Problems
Use in multi-task/multi-domain learning when representations need to be decomposed into a "cross-task common component" and a "task-specific component."
Typical scenarios: (1) Multi-task MoE -- Shared experts handle linguistic commonalities, Private experts handle task-specific logic;
(2) Multi-domain adaptation -- Shared representations capture general semantics, Private representations capture domain terminology;
(3) Continual learning -- Shared retains stable knowledge, Private accommodates new knowledge without interfering with old knowledge.
Core requirement: **explicitly separate commonality from individuality to prevent negative transfer and catastrophic forgetting**.

## Mathematical Inspiration
- Lenses: ../../lenses/projection.en.md (subspace decomposition, direct sum decomposition), ../../lenses/probabilistic.en.md (information decomposition)
- Knowledge: ../../knowledge-base/matrix-analysis/projection.en.md (direct sum decomposition V = U + W, projection operators),
  ../../knowledge-base/probability/kl-divergence.en.md (information decomposition: shared/synergy/unique)

## Required Mathematical Background
- **Direct Sum Decomposition**: R^d = S + P, where S intersect P = {0}, and every x = x_S + x_P is unique
  Projection matrices P_S + P_P = I, P_S * P_P = 0
- **Information Decomposition (Williams & Beer PID)**:
  I(X; Y_1, Y_2) = Shared + Unique_1 + Unique_2 + Synergy
  Shared is the redundant-information term; min(I(X;Y_1), I(X;Y_2)) is only an early/simplified proxy, not the general Williams-Beer redundancy definition
- **Low-Rank + Sparse Decomposition (RPCA)**: M = L + S, where L is low-rank (common) + S is sparse (specific)
  Solved via nuclear norm + L1 norm convex relaxation
- **CCA (Canonical Correlation Analysis)**: max corr(W_1^T X, W_2^T Y), extracting shared variation between two sets of variables

## AI Module Form

```python
z_shared = shared_encoder(X)
z_private = private_encoder[task](X)
z = shared_to_output(z_shared) + private_to_output(z_private)

# Discriminator minimizes CE; gradient reversal makes the shared encoder maximize it.
L_domain = cross_entropy(domain_classifier(gradient_reverse(z_shared)), task)
L_task = task_loss(task_head(z), target)
L = L_task + lambda_adv * L_domain + lambda_decorr * decorrelation(z_shared, z_private)
```
A finite discriminator's failure to predict the task does not prove task independence. Evaluate stronger held-out probes, task-transfer performance and representation collapse. Private-label prediction is optional and can encourage mere task-ID memorization instead of useful task-specific information.

Branch outputs must have compatible shapes for addition; otherwise map each to a common output dimension or concatenate. Choose shared/private latent widths from a parameter/compute budget and task ablations; there is no universal $dT/(T+1)$ allocation law. Learned nonlinear branches with a decorrelation penalty do not automatically define a direct-sum subspace decomposition.

## Implementable Structures
- **Dual encoder + fusion layer**: shared_encoder (large) + T private_encoders (small) + fusion
- **Parameter efficiency**: Private uses LoRA (Low-Rank Adaptation) instead of full encoders, O(d * r) parameters per task
- **Dynamic routing integration**: Shared experts + private experts selected via MoE routing
- **Progressive expansion**: For new tasks, only add private encoders with frozen shared parameters

## GPU Feasibility

- **D1/D2[~]**: Shared/private encoders are ordinary neural modules; their costs follow the actual depth and width.
- **D3/D4[~]**: If token $i$ uses one private branch, cost is $C_{shared}(X)+\sum_t C_{private,t}(X_t)$ with $\sum_t|X_t|=N$, not a universal twice-dense cost. Store all private parameters unless loaded on demand; optimizer state also grows with task count.
- **D5[~]**: Gradient reversal is sign/scale multiplication and does not inherently require fp32; use precision diagnostics for logits, reductions and adversarial stability.
- **D6/D8[~]**: Branches may overlap on hardware, but resource contention and transfer costs determine benefit. Fusion applies mainly to small combination operations.
- **D7[~]**: Conditional private-branch execution saves work only if inactive branches are skipped; it is not sparse weight storage.

## Paper-Worthy Formulation
"We decompose the multi-task representation space R^d into a shared subspace S and task-private subspaces P: the shared branch reduces task identifiability through adversarial training, while the private branches use orthogonality / decorrelation regularization to reduce linear overlap with S. Information complementarity and reduced negative transfer must be validated with task-transfer matrices, mutual-information / PID proxies, and ablations; they are not automatically guaranteed by orthogonality alone."

## Risks
- Min-max variational in adversarial training is unstable; the gradient reversal scale and lambda_adv require careful tuning
- Over-compression of Shared leads to insufficient common information, placing excessive burden on Private
- Total Private parameters grow linearly with T, requiring LoRA or adapter modules to control
- When task similarity is low, Shared may learn a vacuous "common component"
