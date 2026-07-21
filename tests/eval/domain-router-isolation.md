# Eval: Domain Router Isolation (No Cross-Pollution)

These prompts should NOT load content from unrelated domains. Pure AI should not load crypto books; pure crypto should not load AI design-patterns.

## Should load ONLY AI (not crypto)

1. "设计一个新的 attention 机制，用谱分解保留主要信息"
2. "How to design a low-rank KV-Cache compression method?"
3. "我想用 manifold optimization 做表示学习"
4. "Design a contrastive loss for domain alignment"

## Expected Behavior

- Domain Router judges the problem as pure AI research
- Loads: knowledge-base/ relevant anchors (matrix-analysis, differential-geometry, optimization, etc.) + design-patterns/ relevant patterns + AI books (if needed)
- Does NOT load the 3 crypto books (references/books/applied-cryptography.md, foundations-of-cryptography.md, introduction-to-modern-cryptography.md)
- Does NOT load knowledge-base/cryptography/ anchors
- Does NOT trigger critic dimension 19 (cryptographic security review)
- Uses only the GPU dimensions relevant to an implementation decision; does not print eight boilerplate rows
- Domain Router rule 4 enforced: pure AI does not load crypto content

## Should load ONLY crypto (not AI)

1. "这个 IND-CCA2 游戏的归约紧度够吗？"
2. "Is this PRF construction secure under the DDH assumption?"
3. "证明这个签名方案在 ROM 下是 EUF-CMA 安全的"
4. "Does this commitment scheme satisfy binding and hiding?"

## Expected Behavior

- Domain Router judges the problem as pure cryptography
- Loads the smallest relevant `../../knowledge-base/cryptography/` anchor set; shared math by structure and one crypto book only if the anchors are insufficient or the user requests literature depth
- Does NOT load design-patterns/ (attention, loss, routing, representation, compression)
- Does NOT use the GPU checklist as a security gate (crypto uses security definitions, reduction tightness, assumptions, and implementation pitfalls)
- Domain Router rule 4 enforced: pure crypto does not load AI design-patterns

## Edge Cases

### Edge case 1: Crypto concept with shared math (should load shared, not AI design-patterns)

- "分析 RSA 的归约紧度，需要算大数模乘的复杂度" → loads a crypto reduction anchor plus algorithmic/complexity material as needed; a crypto book is conditional, and AI design patterns remain excluded.

### Edge case 2: AI concept that sounds crypto but isn't

- "用 hashing 做特征哈希" → "hashing" sounds crypto but is actually ML feature hashing; Domain Router judges as AI, loads AI design-patterns, does NOT load crypto books.

## Key Assertions

- Domain Router rule 4 ("no pollution when not cross-domain") is enforced
- Pure AI does not load the 3 crypto books or knowledge-base/cryptography/ anchors
- Pure crypto does not load design-patterns/ (attention, loss, routing, representation, compression)
- Shared math anchors load based on problem structure, NOT domain tag (rule 2: "domain tag does not decide shared anchors; problem structure does")
- Edge cases are correctly classified (not over-triggered by superficial keyword matching)
