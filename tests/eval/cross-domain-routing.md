# Eval: Cross-Domain Routing (AI × Cryptography)

These prompts SHOULD trigger dual-domain loading + intersection annotation using the 4-tuple template.

## Test Cases

1. "用 PRF 给模型做水印，能不能保证不可伪造？"
2. "对抗样本的鲁棒性能不能做归约证明？把'破鲁棒性'归约到某个困难假设？"
3. "Can we use zero-knowledge proofs to verify ML inference without revealing the model?"
4. "用差分隐私训练模型，密码学假设和 ML 假设怎么协同？"
5. "Could commitment schemes enable verifiable model distillation?"
6. "用 PRG 的不可预测性来评估序列模型生成质量，这个迁移合理吗？"

## Expected Behavior

- Domain Router judges AI × Cryptography intersection (both domains' signal keywords present)
- Explicitly lists both domains' loaded items:
  - AI domain: knowledge-base/ relevant anchors + design-patterns/ relevant patterns + AI books (if needed)
  - Cryptography domain: 3 crypto books + knowledge-base/cryptography/ anchors + shared math anchors (on demand)
- Annotates intersection using the **4-tuple template** (feeds critic dimension 19 checkpoint 6):
  1. **密码学原语 + 安全性质** (e.g., "PRF + pseudorandomness" or "commitment + binding")
  2. **AI 模块 + 功能需求** (e.g., "watermark + unforgeability" or "inference + verifiability")
  3. **迁移方向** (crypto→AI / AI→crypto)
  4. **迁移后假设可达性** (Is the original assumption still achievable in the AI scenario? e.g., "Is the PRF assumption satisfiable in ML deployment?")
- Critic dimension 19 (cryptographic security review) is mandatory and reviews the intersection annotation
- Does NOT pollute: no unnecessary loading of unrelated domains (e.g., no loading of unrelated AI design-patterns for a pure crypto question, and vice versa)

## Example 4-Tuple for Test Case 1 (PRF watermarking)

1. 密码学原语 + 安全性质: PRF + pseudorandomness (and EUF-CMA for unforgeability)
2. AI 模块 + 功能需求: model watermark + unique traceability (unforgeability)
3. 迁移方向: crypto → AI
4. 迁移后假设可达性: Is the PRF assumption satisfiable in ML deployment? Key management in distributed training is the typical failure point; the "PRF" assumption holds only if keys are truly random and independent across parties.

## Key Assertions

- Domain Router identifies AI × crypto intersection (not just one domain)
- Both domains' loaded items are explicitly listed (no silent loading)
- 4-tuple annotation is complete and specific (not generic boilerplate)
- Critic dimension 19 checkpoint 6 reviews the 4-tuple
- No cross-pollution: pure AI or pure crypto questions do not load the other domain's exclusive content
