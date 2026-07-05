# Eval: Mixed-language Routing

These prompts test the language routing decision system introduced in v3.0.1.

## Should route to Chinese (Scenario B)

1. 帮我 design 一个新的 attention，用 projection 保留主要信息
2. 这个 loss 能不能加一个 information bottleneck 约束？
3. 我想把 manifold optimization 用到 routing module 里，怎么设计？
4. 能不能基于 spectral decomposition 做 KV-cache compression？

## Expected Behavior

- Primary language: **Chinese** (sentence frame, verbs, mood particles are Chinese)
- English technical terms (attention, projection, loss, information bottleneck, manifold, routing, spectral decomposition, KV-cache) are domain terms and do NOT trigger English routing
- Load: `SKILL.md` (Chinese activator)
- Output language: Chinese, retaining necessary English technical terms
- Diagnose intent normally (Scenario B: mechanism design)

## Should route to Chinese (Scenario D)

1. 这个 contrastive loss 真的能保证 domain alignment 吗？
2. 这个 projection operator 是否满足 idempotent？

## Expected Behavior

- Primary language: **Chinese**
- Scenario: D (verification & review)
- Load relevant knowledge cards (Chinese versions) and critic
- Output language: Chinese

## Should route to English (Scenario B)

1. Can you help me design an attention module based on projection?
2. I want to use spectral methods for KV-cache compression. How would you approach this?

## Expected Behavior

- Primary language: **English** (English sentence frame, verbs, articles)
- Load: `SKILL.en.md` (English activator)
- Output language: English

## Edge case: Chinese sentence frame with Chinese math term (Scenario B)

1. I want to use 流形 optimization for routing. How would you design it?

## Expected Behavior

- Primary language: **English** (English sentence frame dominates: "I want to use...for...How would you design it?")
- The Chinese term 流形 is a math term, not a language frame signal
- Output language: English
- 流形 may be translated to "manifold" or preserved with explanation
