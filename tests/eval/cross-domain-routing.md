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
- Uses both domains' relevant items internally:
  - AI domain: relevant shared anchors + at most the needed design patterns; books only if cards are insufficient
  - Cryptography domain: relevant crypto anchors first; crypto books and shared math anchors only on demand
- Annotates the intersection once using the **4-tuple template** for compact cryptographic review:
  1. **密码学原语 + 安全性质** (e.g., "PRF + pseudorandomness" or "commitment + binding")
  2. **AI 模块 + 功能需求** (e.g., "watermark + unforgeability" or "inference + verifiability")
  3. **迁移方向** (crypto→AI / AI→crypto)
  4. **迁移后假设可达性** (Is the original assumption still achievable in the AI scenario? e.g., "Is the PRF assumption satisfiable in ML deployment?")
- The compact cryptographic-security checks are mandatory; load the full critic only for a comprehensive review
- Does NOT pollute: no unnecessary loading of unrelated domains (e.g., no loading of unrelated AI design-patterns for a pure crypto question, and vice versa)

## Example 4-Tuple for Test Case 1 (PRF watermarking)

1. 密码学原语 + 安全性质: PRF + pseudorandomness; watermark unforgeability still needs its own attack game
2. AI 模块 + 功能需求: model watermark + traceability / resistance to forgery under a stated interface
3. 迁移方向: crypto → AI
4. 迁移后假设可达性: Is the PRF key sampled and protected as required, and does the watermark interface expose only the queries covered by the game? Key leakage or an undefined extraction/verification interface breaks the claimed transfer.

## Key Assertions

- Domain Router identifies AI × crypto intersection (not just one domain)
- The 4-tuple makes the intersection explicit; internal file manifests stay hidden unless the user asks to debug routing
- 4-tuple annotation is complete and specific (not generic boilerplate)
- Compact crypto checks review the four-tuple; the full critic is conditional
- No cross-pollution: pure AI or pure crypto questions do not load the other domain's exclusive content
