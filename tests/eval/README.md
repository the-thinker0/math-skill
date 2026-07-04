# Eval Test Suite

These are **manual evaluation scenarios** for testing the math-skill v3.0.0 routing and output quality. They are not automated tests — they require a human to invoke the skill with each prompt and evaluate the response.

## Test Categories

| File | Purpose | Expected Behavior |
|------|---------|-------------------|
| `should-trigger-design.md` | Mechanism design scenarios (Scenario B) | Full pipeline: Lenses → Knowledge → Design → Critic |
| `should-trigger-knowledge.md` | Knowledge query scenarios (Scenario C) | Direct knowledge card loading |
| `should-not-trigger.md` | Pure engineering tasks (Scenario E) | No math system activation at all |

## How to Run

1. Install math-skill in a Claude Code / Codex environment
2. For each test case, paste the prompt and observe the system's behavior
3. Verify the expected routing path and output format

## Key Assertions

- **Scenario B** should output: [诊断] → [透镜] → [知识] → [设计] → [GPU] → [结论]
- **Scenario C** should output: 最小定义 → 核心公式 → 适用问题 → AI 设计翻译 → 工程可行性 → 风险
- **Scenario E** should NOT load any lenses, knowledge cards, or design patterns
