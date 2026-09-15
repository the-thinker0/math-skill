---
name: math-research-activator
description: |
  Turn AI research goals into mathematical formulations, implementable mechanisms, and testable conclusions. Use for architecture/operator construction, theoretical analysis, cross-field mathematical discovery, math-to-AI transfer, research-related mathematics, and cryptographic definitions, constructions, reductions, or protocol reviews. Exclude implementation-only debugging, refactoring, tuning, and general code review.
  中文：将 AI 研究目标转成数学对象、可实现机制和可验证结论；用于架构/算子构造、理论分析、跨数学领域思路发现与结构迁移、研究相关数学查询，以及密码学定义、构造、归约与协议审查。纯实现型 debug、重构、调参和一般代码审查不触发。
---

# Mathematical Research: From Problem to Construction and Verification

This is the English compatibility entry, used only by explicit English entry paths. `SKILL.md` is the authoritative entry for Claude Code / Codex / Cursor / DeepSeek Harness and supports answers in either language. Answer in the user's primary natural language; technical terms, code, paths, and formulas do not determine language. Do not load both entries together. All resource paths are relative to this skill's installation directory (`resourceBase` in dsh), not the user's project root.

## What to accomplish

Help the user explain, derive, or construct a mechanism that addresses the current research problem. Mathematical resources serve that task. Selecting lenses, listing terms, producing knowledge cards, or naming a template is not a deliverable.

- Preserve the user's existing goals, proposals, and constraints. Clarify only gaps that would change the conclusion; proceed with explicit assumptions when possible.
- Distinguish established theorems, the current derivation, modeling assumptions, and empirical results. Every claim of optimality, stability, security, or equivalence needs corresponding conditions.
- When the user requests implementation or verification and the environment permits it, run the authorized minimal checks and revise the candidate based on observations. For concept-only or planning requests, deliver within that scope.

## Start with the task

Activate when mathematical correctness, complexity, convergence, stability, or cryptographic security is a goal, even if the task includes code. Import/shape/OOM fixes, refactoring, tuning, deployment, and general code-quality work alone belong to E Engineering; do not load research resources. An explicit skill mention bypasses automatic trigger selection while retaining this engineering boundary.

| Scenario | Deliverable | How to use resources |
|---|---|---|
| A Analysis | Whether the current argument holds, the key reasons, and a repair | Start from the existing objects; use relevant anchors or lenses without a full preliminary diagnosis |
| B Cross-field exploration | Find valuable, structurally different mathematical directions | Start with [structural transfer](references/structural-transfer.en.md); existing prototypes do not bound candidates |
| B Construction | Turn a selected direction into a mechanism, implementation, and validation | Use the [construction workbench](references/design-workbench.en.md) when formulation and implementation need to be developed |
| C Knowledge | Definitions, intuition, formulas, and applicability | Usually one anchor; do not append design, GPU, or experiment reports |
| D Verification | A derivation, conditional bound, or minimal counterexample | Usually 1–2 anchors; run the check when requested |
| E Engineering | Handle the engineering task | Do not load this system's resources |

When the user wants cross-field mathematical ideas or fewer template-based proposals, remove application names and identify the structural relation the current approach cannot satisfy. Search alternative mathematical formulations; show the precise object mapping and the conclusion transferred back. Impossibility and missing-information results also count as useful research insights. Defer design prototypes until the central mapping is established, then use them as comparisons. The five construction moves are examples, not a closed candidate list.

For B Construction, first identify the behavior to change and the information available at decision time, then choose mathematical objects. The workbench provides actions for deriving operators from objects, realizing theorem assumptions, and using small checks to make design decisions. Read the relevant section of [Mathematical Construction Moves](references/construction-moves.en.md) as needed. These moves can produce mechanisms beyond the existing 22 design prototypes; existing prototypes are references.

## Domain Router

Classify by target objects and requested guarantees, not keyword counts.

| Domain | Available resources | Boundary |
|---|---|---|
| Shared mathematics | `lenses/` and the 37 anchors in the 8 non-cryptographic domains | Do not automatically load AI prototypes or cryptography books |
| AI research | Shared mathematics, the design workbench, and relevant AI prototypes | Do not load cryptography anchors or books |
| Cryptography | Relevant anchors in `knowledge-base/cryptography/`; add shared mathematics when the structure requires it | Do not load AI prototypes or construction moves, or judge security using a GPU checklist |
| AI×crypto | Both cryptographic primitives/formal security properties and AI objects are involved, and transfer or composition is requested | Read only resources needed at the intersection |

`hashing`, `attack`, `certificate`, a general proof, or adversarial optimization does not establish a cryptography task. Feature hashing, Lipschitz robustness certificates, and randomized smoothing normally remain AI. A statistical privacy definition alone is not cryptography either.

For cross-domain problems, state once: the primitive and security property, the AI object and function, the transfer direction, and whether the assumptions remain satisfiable after transfer. For pure cryptography, first specify adversarial capabilities, the security game, advantage, and reduction resources. Select implementation considerations for the particular construction. Analyze hardware costs only when the user asks about cryptographic implementation performance.

## Read only what can change the current decision

- When the required mathematical structure is known, read its anchor directly; lenses and the index are optional. Conceptual queries and short verifications generally need only 1–2 resources. Construction can start with the workbench and 1–3 relevant resources, expanding when derivation or verification requires it.
- Lenses help discover formalizations; they are not a mandatory step. Read the [index](references/skill-index.en.md) only when filenames do not locate the needed material. Do not reread sufficient existing context.
- Start with an anchor's definitions, core formulas, and risks or conditions that affect the conclusion. Skip mathematical sections in design prototypes that repeat already-read material. Read an individual file in full when it is short or section-based access is unavailable.
- Read book distillations or original papers when cards are insufficient, exact conditions need checking, or the user requests sources. The workbench, full critic, and GPU checklist are not permanent context for every task.
- Do not expose internal loading paths or workflow labels unless the user is debugging the skill. Do not repeat resources or turn a simple question into a comprehensive review.

## From solving to completion

**Analysis or verification:** Extract objects, quantifiers, and assumptions; complete the required derivation or construct a counterexample. When identifying a failure, provide the smallest repair that preserves the user's goal. Extending a conclusion to outputs or task performance requires a separate argument; properties of intermediate tensors are insufficient by themselves.

**Construction:** Turn desired behaviors and failure cases into a testable relation, then derive an update, objective, solver, or decision rule. Substitute actual tensors for theorem variables and handle the key assumptions: enforce them structurally, control them through solver residuals, or retain them only as empirical assumptions. Training-time teacher information cannot become a free input available before an inference decision. Consult related prototypes after completing the candidate to avoid fitting the problem into an existing template too early.

**Implementation and verification:** Specify the forward computation, training signals, gradient or solver paths, and main costs. When execution is requested and feasible, generate and run an analytically tractable small case, a simple baseline, or a control that violates a key assumption for the current candidate. Revise and recheck after observing failure. Describe unrun experiments only as plans; finite numerical support does not replace a universal proof. Read the [GPU checklist](references/gpu-friendly-math.en.md) for hardware details as needed, and report only dimensions that can change the choice.

**Continuing research:** Preserve existing objects, conditions, failed candidates, and measurements, and address the evidence added in the current turn. Do not restart the entire routing process. For work spanning multiple rounds of candidates or experiments, read the [research loop](references/agentic-workflow.en.md).

## Knowledge Gap Protocol

When existing anchors are insufficient, do not force-fit a card. Locate the specific missing concept or theorem, use lenses to find structure as needed, verify sources, record the minimal definitions and conditions needed for the problem, and return to solving or construction. Temporary cards should identify the domain, source, what is established/derived/assumed, and what remains unverified. Suggest a permanent card only for frequent reuse. See the [index](references/skill-index.en.md) for detailed record fields.

Prefer original papers or author textbooks when checking exact constants, theorem conditions, reductions, and recent methods. Distillations and model memory are not independent verification. Search PDFs on demand only in the current repository or user-provided locations. If unavailable, consult primary sources online or retain unverified status; do not invent page numbers or citations. Proposing a mechanism does not establish publication novelty.

## Before delivery

Lead with the requested conclusion or main proposal, then provide enough evidence to reproduce and assess it. Check whether key conditions are realized, when information is available, which conclusions approximations change, whether degenerate solutions exist, and whether reported experiments actually ran. For short questions, keep only material that affects the answer.

Read [math-critic](agents/math-critic.en.md) when a full review is needed. For a concrete example, choose only one from the current domain: [low rank and queries](references/worked-examples/query-aware-compression.en.md), [equivariance](references/worked-examples/equivariance-check.en.md), or [PRF→MAC](references/worked-examples/security-reduction.en.md).

Resource entry points: `lenses/` (15 perspectives), `knowledge-base/` (41 anchors, including 4 cryptography cards), `design-patterns/` (22 AI prototypes), and `references/books/` (book distillations on demand). These are open starting points, not limits on the mechanisms that can be constructed.
