---
name: math-research-activator
description: |
  Route AI architecture/operator design, theoretical analysis, math-to-AI transfer, and cryptographic definitions, constructions, reductions, or protocol reviews to the minimum necessary mathematical lenses, anchors, and design checks. Also use for mathematics questions tied to AI research. Do not use for implementation-only debugging, refactoring, tuning, or general code review.
  中文：为 AI 架构/算子设计、理论分析、数学迁移，以及密码学定义、构造、归约和协议审查，选择最少必要的数学透镜、锚点与检查；纯实现工程任务不触发。
---

# Mathematical Research Router

Answer in the user's primary language. Technical terms, code, paths, and formulas do not determine language. `SKILL.md` is the canonical Codex entry. This English file exists only for explicit English command-entry compatibility; do not load both files.

## Objective and hard constraints

Route each problem to the **smallest sufficient** mathematical context and produce a falsifiable, conditional conclusion.

- Distinguish theorems, modeling assumptions, empirical regularities, and exploratory conjectures. Never present the last two as guarantees.
- Keep mathematical anchors, AI design patterns, and cryptographic security semantics domain-separated.
- Never load a directory merely because it exists. Load book distillations only when cards are insufficient, theorem conditions need checking, or the user asks for sources.
- Converge to a conclusion; do not stop at a list of lenses, terms, or loaded files.

## Activation

Classify by the requested **object and guarantee**, not by keyword voting.

1. Classify import/shape/OOM fixes, refactoring, configuration changes, tuning, deployment, and general code-quality reviews as **E engineering** when no mathematical or security claim is at issue.
2. Activate even when code is present if the user asks about mathematical correctness, complexity, convergence, numerical stability, or cryptographic security.
3. A direct request to design, analyze, verify, or explain relevant mathematics is sufficient. Workspace files only disambiguate terse requests; they are not a mandatory gate.
4. `/ask` or an explicit skill mention bypasses automatic-trigger selection, while implementation-only work still remains outside scope.

| Scenario | Goal | Minimal path |
|---|---|---|
| A Analysis | Assess a design, assumption, or argument | 1–2 lenses → conditions/counterexamples |
| B Design | Construct a mechanism, operator, loss, router, or protocol | 1–2 lenses → 1–3 anchors → 0–2 prototypes → review |
| C Knowledge | Understand mathematics tied to the research task | Usually one anchor |
| D Verification | Check a formula, guarantee, reduction, or complexity claim | 1–2 anchors → conditions/boundaries/counterexamples |
| E Engineering | Implementation and maintenance only | Do not load this system's resources |

## Domain Router

Use the target object and required guarantee:

| Domain | Load | Exclude |
|---|---|---|
| Shared mathematics | `lenses/` plus the 8 non-cryptography domains and 33 anchors under `knowledge-base/` | Do not automatically load AI patterns or crypto books |
| AI research | Shared mathematics on demand plus 0–2 relevant prototypes from `design-patterns/` | Do not load crypto anchors/books |
| Cryptography | Relevant `knowledge-base/cryptography/` anchors; then the three crypto books only if needed; shared mathematics by structure | Do not load AI design patterns or apply the GPU gate |
| AI×crypto | Both a cryptographic primitive/formal property and an AI object/functional need are present, and the task asks to transfer or combine them | Load only material needed at the intersection |

Rules:

- Surface terms such as `hashing`, `attack`, or `security` are insufficient for crypto routing. Feature hashing is normally AI; adversarial examples enter crypto/cross-domain routing only when the task asks for a game, certificate, or reduction.
- For pure crypto, review security definitions, reduction tightness, assumptions, and implementation pitfalls. Treat GPU performance as ordinary engineering only when explicitly asked, never as a security acceptance gate.
- For cross-domain tasks, output one four-tuple: (1) primitive + security property; (2) AI object + functional need; (3) transfer direction; (4) whether the assumption remains achievable after transfer. Do not emit it elsewhere.

See `references/skill-index.en.md` for the full index and boundary examples. Do not load it by default merely to route a clear request.

## Progressive loading and token budget

Use these defaults unless the user requests a comprehensive review, multiple candidates, or the available material is genuinely insufficient.

| Scenario | Default context | Default answer |
|---|---|---|
| A | 1–2 lenses; one anchor only if needed | Conclusion + 2–4 key issues + fixes |
| B | 1–2 lenses, 1–3 anchors, 0–2 patterns | One primary design; alternatives only by decisive differences |
| C | One anchor | Definition + formula/intuition + boundary |
| D | 1–2 anchors | Short conclusion + conditions + non-guarantees |

- Do not repeat cards or expose internal load paths unless debugging routing, handling a cross-domain task, or resolving ambiguity.
- Do not force simple questions into a full report template. Every heading must add decision-relevant information.
- Do not expand AI translation, the GPU scorecard, or long bibliographies for a concept-only query.
- If one anchor is sufficient, do not load the matching book. If the card plus reliable existing knowledge is sufficient, do not inspect PDFs.

## Procedure

1. **Classify scenario and domain:** extract the target, constraints, properties to preserve/suppress, and requested guarantee.
2. **Select minimal material:** read only the most relevant files. Use `references/skill-index.en.md` only when filenames do not locate them.
3. **Solve or design:** state objects, assumptions, and testable goals before AI/crypto translation.
4. **Review:** always check assumptions, logic, and boundaries; add complexity/memory/numerics for implementations and security-game/reduction/assumption checks for crypto.
5. **Lead with the conclusion:** answer whether it holds, what to choose, or what to do next before supporting detail.

### AI design

- Treat design patterns as translation examples, not copy-ready models.
- Read `references/gpu-friendly-math.en.md` only for operator, training, or inference implementation questions.
- Report only applicable GPU dimensions that can change the decision. Quantify main FLOPs, peak intermediate/state memory, and low-precision risk. Mark irrelevant dimensions N/A instead of padding to eight items.

### Cryptography

- Define adversarial capability, security game, and advantage before claiming security.
- Separate standard-model theorems, primitive-based reductions, and empirical assumptions about concrete algorithms such as AES.
- Report reduction loss and parameter compensation; check nonce/IV handling, key separation, composition order, and side channels.

### Knowledge Gap Protocol

When no anchor covers the problem, do not force-fit one:

1. identify the gap type; 2. fall back to 1–2 lenses; 3. name concrete concepts/theorem families; 4. write a minimal temporary card; 5. translate into a design only if needed; 6. recommend a permanent card only for recurring gaps.

Every temporary card must state its domain, source (agent inference/lens derivation/reference extrapolation/external verification needed), confidence, and unverified claims. See `references/skill-index.en.md` for detailed fields.

## Output quality check

Before answering, verify:

- Does the conclusion answer the user's decision rather than display knowledge?
- Does every claim of “guaranteed,” “optimal,” “secure,” “stable,” or “equivalent” state sufficient conditions?
- Is there at least one boundary, counterexample, or falsification experiment?
- Did correlation, analogy, or empirical behavior become a theorem or causal claim by accident?
- Did irrelevant domain content leak into context or output?
- Can a section be deleted without losing decision information? If yes, delete it.

Load `agents/math-critic.en.md` only for paper-grade or explicitly comprehensive review. For ordinary A/B/D tasks, use the compact checks above instead of the full 19-dimension template.

## Direct resources

- Lenses: `lenses/`
- Shared anchors: `knowledge-base/` except `knowledge-base/cryptography/`
- Crypto anchors: `knowledge-base/cryptography/`
- AI prototypes: `design-patterns/`
- GPU deep check: `references/gpu-friendly-math.en.md`
- Deep review: `agents/math-critic.en.md`
- Books: `references/books/` on demand only
