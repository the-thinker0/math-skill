# Eval Test Suite

These are **manual evaluation scenarios** for testing the math-skill v3.2.1 routing and output quality. They are not automated tests — they require a human to invoke the skill with each prompt and evaluate the response.

## Test Categories

| File | Purpose | Expected Behavior |
|------|---------|-------------------|
| `should-trigger-design.md` | Mechanism design scenarios (Scenario B) | Full pipeline: Lenses → Knowledge → Design → Critic |
| `should-trigger-knowledge.md` | Knowledge query scenarios (Scenario C) | Direct knowledge card loading |
| `should-trigger-analysis.md` | Analysis scenarios (Scenario A) | Lenses → Critic (no design output, no GPU gate unless GPU-related) |
| `should-trigger-verification.md` | Verification scenarios (Scenario D) | Knowledge anchors → Critic; short conclusion + conditions/boundaries |
| `should-not-trigger.md` | Pure engineering tasks (Scenario E) | No math system activation at all |
| `cross-domain-routing.md` | AI × cryptography intersection | Dual-domain load + 4-tuple intersection annotation |
| `domain-router-isolation.md` | No cross-pollution guarantee | Pure AI does not load crypto; pure crypto does not load AI design-patterns |
| `knowledge-gap-protocol.md` | Gaps not covered by existing anchors | 6-step Knowledge Gap Protocol with temporary card + source/confidence |
| `mixed-language-routing.md` | Code-switched input (CN/EN mixed) | Correct language routing per 5-rule decision system |

## How to Run

1. Install math-skill in a Claude Code / Codex environment
2. For each test case, paste the prompt and observe the system's behavior
3. Verify the expected routing path and output format

## Key Assertions

- **Scenario B** should output: [诊断] → [透镜] → [知识] → [设计] → [GPU] → [结论]
- **Scenario C** should output: 最小定义 → 核心公式 → 适用问题 → AI 设计翻译 → 工程可行性 → 风险
- **Scenario E** should NOT load any lenses, knowledge cards, or design patterns
