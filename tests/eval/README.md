# Eval Test Suite

These are **manual evaluation scenarios** for testing the math-skill v3.2.1 routing and output quality. They are not automated tests — they require a human to invoke the skill with each prompt and evaluate the response.

## Test Categories

| File | Purpose | Expected Behavior |
|------|---------|-------------------|
| `should-trigger-design.md` | Mechanism design scenarios (Scenario B) | Minimal route: lenses → anchors → optional prototypes → compact review |
| `should-trigger-knowledge.md` | Knowledge query scenarios (Scenario C) | Direct knowledge card loading |
| `should-trigger-analysis.md` | Analysis scenarios (Scenario A) | 1–2 lenses → compact assumption/boundary review; full critic only on explicit comprehensive review |
| `should-trigger-verification.md` | Verification scenarios (Scenario D) | 1–2 anchors → short conclusion + conditions/boundaries; full critic only on demand |
| `should-not-trigger.md` | Pure engineering tasks (Scenario E) | No math system activation at all |
| `cross-domain-routing.md` | AI × cryptography intersection | Dual-domain load + 4-tuple intersection annotation |
| `domain-router-isolation.md` | No cross-pollution guarantee | Pure AI does not load crypto; pure crypto does not load AI design-patterns |
| `knowledge-gap-protocol.md` | Gaps not covered by existing anchors | 6-step Knowledge Gap Protocol with temporary card + source/confidence |
| `mixed-language-routing.md` | Code-switched input (CN/EN mixed) | Correct output language without loading both entry bodies |

## How to Run

1. Install math-skill in a Claude Code / Codex environment
2. For each test case, paste the prompt and observe the system's behavior
3. Verify the expected routing path and output format

## Key Assertions

- **Scenario B** should reason through diagnosis → lenses → anchors → design → relevant implementation checks → conclusion, while showing only decision-relevant sections
- **Scenario C** should normally output only: conclusion/definition → one core formula or intuition → applicability/boundary. AI translation, GPU, and references are conditional.
- **Scenario E** should NOT load any lenses, knowledge cards, or design patterns

The Scenario B sequence describes required reasoning, not mandatory visible headings. Do not expose load paths or pad a simple answer to match a template.
