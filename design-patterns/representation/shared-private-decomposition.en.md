# Shared-Private Decomposition

## Applicable Problems
Use in multi-task/multi-domain learning when representations need to be decomposed into a "cross-task common component" and a "task-specific component."
Typical scenarios: (1) Multi-task MoE -- Shared experts handle linguistic commonalities, Private experts handle task-specific logic;
(2) Multi-domain adaptation -- Shared representations capture general semantics, Private representations capture domain terminology;
(3) Continual learning -- Shared retains stable knowledge, Private accommodates new knowledge without interfering with old knowledge.
Core requirement: **explicitly separate commonality from individuality to prevent negative transfer and catastrophic forgetting**.

## Mathematical Inspiration
- Lenses: lenses/geometry.md (subspace decomposition, direct sum decomposition), lenses/information.md (information decomposition)
- Knowledge: knowledge-base/fundamentals/linear-algebra.md (direct sum decomposition V = U + W, projection operators),
  knowledge-base/fundamentals/information-theory.md (information decomposition: shared/synergy/unique)

## Required Mathematical Background
- **Direct Sum Decomposition**: R^d = S + P, where S intersect P = {0}, and every x = x_S + x_P is unique
  Projection matrices P_S + P_P = I, P_S * P_P = 0
- **Information Decomposition (Williams & Beer PID)**:
  I(X; Y_1, Y_2) = Shared + Unique_1 + Unique_2 + Synergy
  Shared = the redundant information component min(I(X; Y_1), I(X; Y_2))
- **Low-Rank + Sparse Decomposition (RPCA)**: M = L + S, where L is low-rank (common) + S is sparse (specific)
  Solved via nuclear norm + L1 norm convex relaxation
- **CCA (Canonical Correlation Analysis)**: max corr(W_1^T X, W_2^T Y), extracting shared variation between two sets of variables

## AI Module Form
```
Module: SharedPrivateDecomposer
Input: X in R^{N x d}, task identifier t in {1, ..., T}

Method 1 - Additive Decomposition (most common):
  z_shared = E_shared(X)           // shared encoder: MLP or Transformer block
  z_private = E_private[t](X)      // private encoder: independent parameters per task
  z = z_shared + z_private         // additive fusion
  // Training objective: L_task(z, y) + lambda_1 * OrthLoss(z_shared, z_private)
  // Orthogonality ensures shared and private learn different information

Method 2 - Gated Decomposition (dynamic weighting):
  z_shared = E_shared(X)
  z_private = E_private[t](X)
  gate = sigmoid(Linear(z_shared + z_private))  // dynamic fusion gate
  z = gate * z_shared + (1 - gate) * z_private
  // Gating allows per-dimension selection of shared/private contribution ratios

Method 3 - Adversarial Decomposition (information-theoretic guarantee):
  z_shared = E_shared(X)
  z_private = E_private[t](X)
  // Shared should be indistinguishable across tasks (adversarial gradient):
  task_pred = classifier(z_shared.flip_gradient())
  L_adv = -CE(task_pred, t)        // Shared contains no task information
  // Private should be discriminative across tasks:
  L_private = CE(classifier(z_private), t)
  L = L_task + lambda_adv * L_adv + lambda_priv * L_private

Dimension Allocation Principle:
  d_shared = d * T / (T + 1)      // With T tasks, shared occupies the majority
  d_private = d * 1 / (T + 1)     // Each private occupies a smaller portion
  // Or dynamically allocate based on PCA variance explained ratio
```

## Implementable Structures
- **Dual encoder + fusion layer**: shared_encoder (large) + T private_encoders (small) + fusion
- **Parameter efficiency**: Private uses LoRA (Low-Rank Adaptation) instead of full encoders, O(d * r) parameters per task
- **Dynamic routing integration**: Shared experts + private experts selected via MoE routing
- **Progressive expansion**: For new tasks, only add private encoders with frozen shared parameters

## GPU Feasibility
- **Tensorization**: Two encoder forward passes are independent GEMM chains, executable in parallel
- **GEMM-mappable**: Shared/private encoders are each standard Transformer FFNs (2x GEMM)
- **Complexity**: Shared O(N * d^2) + T private encoders O(N * d^2 / T), total approximately 2x a single encoder
- **Memory and KV-Cache**: All T private encoder parameters stored; LoRA compression needed when T is large
- **Low-precision stability**: Additive/gated fusion is safe in fp16; adversarial training gradient reversal requires fp32
- **Parallelism and communication**: Shared and private encoders can be assigned to different GPUs; multi-task batches mixed for training
- **Sparse structure**: Private encoders can be sparsified (only the current task's is activated); only 1 out of T activated
- **Operator fusion**: Additive fusion is trivial; gated fusion sigmoid -> multiply -> add can be fused

## Paper-Worthy Formulation
"We decompose the multi-task representation space R^d into a direct sum S + P. The Shared subspace ensures task-invariance through adversarial training (H(T|Z_s) -> log T), while the Private subspace guarantees information complementarity with Shared via orthogonal regularization. Theoretical analysis shows that negative transfer decays as O(||P_S * P_P||_F) with increasing orthogonality."

## Risks
- Min-max optimization in adversarial training is unstable; the gradient reversal scale and lambda_adv require careful tuning
- Over-compression of Shared leads to insufficient common information, placing excessive burden on Private
- Total Private parameters grow linearly with T, requiring LoRA or adapter modules to control
- When task similarity is low, Shared may learn a vacuous "common component"
