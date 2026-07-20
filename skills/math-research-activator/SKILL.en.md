---
name: math-research-activator
description: |
  Mathematical research OS — auto-diagnoses user intent, routes to thinking lenses, activation anchors, or design translation layer. Triggers on architecture/operator design, theoretical analysis, math-to-AI transfer, and cryptographic definitions, constructions, reductions, or protocol analysis. Does NOT trigger for pure engineering tasks (debug, refactoring, hyperparameter tuning).
---


> **Language Routing & Mixed-Input Rules**: Judge primary language by sentence structure/verbs/mood particles. AI/math/engineering terms don't count. Code/paths/formulas excluded. When CN/EN ratio is close, follow last turn; default to Chinese if no context. Explicit request overrides. Chinese → `SKILL.md`, English → this file. Full rules: `../../references/skill-index.en.md`.

# Math Research OS

> "The thinking system does not hand out theorems, the knowledge system does not indulge in loose inspiration, and the design layer does not fake profundity."

This system is a mathematical staff office for AI architecture innovation and cryptographic research — not an arsenal, but one that tells you: **what kind of battle this is, which arms to deploy, how to deploy them, and where things could go wrong.**

## Core Principle

> Math Skill does not store mathematics. It activates, routes, and translates mathematics for AI research.

- **knowledge-base/** is not a closed encyclopedia but a set of mathematical activation anchors
- When existing cards cannot cover a problem, the agent must NOT stop or force-fit; instead, generate a "temporary knowledge card" based on lenses, reference layers, and the agent's own mathematical knowledge, then continue with design translation
- **design-patterns/** is a collection of math→AI translation prototypes, not a complete model repository; when no matching pattern exists, generate a temporary design candidate from the mathematical structure and label it as a temporary design pattern

## Three-Layer Orthogonal Architecture

| Layer | Responsibility | Directory | Core Question |
|-------|---------------|-----------|--------------|
| **Thinking Lenses** | Diagnose problem structure, recommend mathematical perspectives | `../../lenses/*.en.md` | Which perspective should we view this problem through? |
| **Activation Anchors** | Activate high-frequency math structures; trigger Knowledge Gap Protocol when insufficient | `../../knowledge-base/*/*.en.md` | What math structures does this perspective require? |
| **Design Translation** | Translate mathematics into AI modules/losses/operators | `../../design-patterns/*/*.en.md` | How does this mathematics become model architecture? |

Auxiliary layers:
- `../../references/books/*.en.md`: Distilled notes from 7 textbooks; full context when deeper understanding is needed
- `../../references/books/applied-cryptography.md`, `../../references/books/foundations-of-cryptography.md`, `../../references/books/introduction-to-modern-cryptography.md`: 3 English-language cryptography distillations; see `../../references/skill-index.en.md`
- `../../references/gpu-friendly-math.en.md`: GPU Eight-Dimension Acceptance Gate (single source of truth)
- `../../agents/math-critic.en.md`: Math-engineering dual critic

## Automatic Trigger Conditions

**All of Gate 1 + Gate 2 + Gate 3 must be satisfied simultaneously for intervention:**

### Gate 0 · Exclusion Gate (Highest Priority)
The following tasks **never** trigger the system regardless of workspace contents: code review, debugging, refactoring, hyperparameter tuning, build/deployment, purely factual queries, general software engineering.

### Gate 1 · Environment Signal
The workspace contains architecture-level core code (attention/transformer/MoE, `*.cu`/kernel) or research notes, **or** cryptography-related code / protocol descriptions / security proof drafts. Routine files like `model.py` or `trainer.py` alone **do not** constitute an environment signal.

### Gate 2 · Task Signal
The user's task involves **designing/improving** a new architecture/operator, **analyzing** theoretical properties, **transferring** mathematical structures into AI design, **analyzing cryptographic constructions/security definitions/reduction proofs/protocols**, or **querying math knowledge relevant to AI research** (e.g., "how is tangent space used in optimization?"). Pure encyclopedic math or cryptography fact queries do not auto-trigger, but can be accessed via `/ask`.

### Gate 3 · Intent Match
The user's intent matches one of scenarios A/B/C/D. Pure engineering tasks matching scenario E → no intervention.

> **`/ask` entry**: Manual invocation skips Gate 1 and Gate 2, executing only Gate 0 (exclusion) + Gate 3 (intent match), allowing direct access to any scenario including knowledge queries.

## Domain Router (new in v3.2.0)

> AI research and cryptography **share** mathematical foundations but each has **exclusive** specialty layers. After intent diagnosis and before lens invocation, Domain Router determines the problem's domain and decides which anchors/books/design patterns to load, avoiding cross-domain pollution and token waste.

### Three-Layer Domain Classification

| Layer | Signal Keyword Examples | Loaded Content | Exclusive/Shared |
|-------|------------------------|----------------|-------------------|
| **AI Research Layer** | attention, loss, routing, representation, compression, MoE, transformer, KV-cache, LoRA, SSM, diffusion, RL | `../../knowledge-base/` (7 domains, 31 anchors) + `../../design-patterns/` (5 types, 22 patterns) + 7 AI books | AI-exclusive |
| **Cryptography Layer** | encryption, signature, MAC, PRF/PRG/PRP, OWF, CCA, CPA, AE, zero-knowledge, reduction proof, attack game, DL/CDH/DDH, RSA, ECC, lattice crypto | 3 crypto books + shared math anchors (on demand) + temporary knowledge cards | Crypto-exclusive |
| **Shared Math Layer** | probability, information theory, entropy, group, ring, field, matrix, spectrum, optimization, convexity, perturbation, complexity | Corresponding anchors in `../../knowledge-base/` + `../../lenses/` lenses | Shared |

### Routing Rules

1. **Judge domain first**: Determine primary domain (AI / Crypto / pure math query) from user keywords.
2. **No redundant loading of shared math**: If the domain is cryptography, load shared math anchors (e.g., `../../knowledge-base/probability/entropy.md`, `../../knowledge-base/matrix-analysis/spectral-decomposition.md`) on demand; do **NOT** load AI-exclusive `../../design-patterns/`.
   - **"On demand" criterion**: Load if and only if the problem's mathematical structure maps to that shared anchor's core definition/formulas — i.e., the problem statement explicitly mentions the anchor's core concept (e.g., "spectrum," "entropy," "convex," "perturbation"), or a lens/critic explicitly routes to it. **The domain tag does not decide whether shared anchors load; the problem structure does.**
3. **Explicit annotation on cross-domain**: If the problem is genuinely AI×crypto intersection (e.g., "use PRF for model watermarking," "reduction proof for adversarial examples"), Domain Router explicitly lists both domains' loaded items and annotates intersection points.
   - **Intersection annotation template** (4-tuple, feeds critic dim 19 checkpoint 6):
     1. **Crypto primitive + security property** (e.g., "PRF + pseudorandomness")
     2. **AI module + functional requirement** (e.g., "watermark + unique traceability")
     3. **Transfer direction** (crypto→AI / AI→crypto)
     4. **Assumption achievability after transfer** (Is the original assumption still achievable in the AI scenario? E.g., "Is the PRF assumption satisfiable in ML deployment?")
4. **No pollution when not cross-domain**: Pure AI problems do not load cryptography books; pure crypto problems do not load AI design patterns. Avoids token waste and conceptual confusion.
5. **Domain-tagged gap protocol**: Temporary knowledge cards generated by Knowledge Gap Protocol are tagged with domain (AI/Crypto/Shared) for subsequent upgrade to corresponding formal cards.

### Domain Router Decision Flow

```
User question
  ↓
[Gate 0-3 triggered?]
  ↓ yes
Domain Router: keyword-based primary domain judgment
  ├─ AI research → load knowledge-base + design-patterns + AI books
  ├─ Cryptography → load crypto books + shared math anchors (on demand)
  ├─ Pure math → only load lenses + corresponding knowledge-base anchors
  └─ AI×Crypto → dual-domain load + intersection annotation
  ↓
[Scenario A/B/C/D routing]
  ↓
[Lenses → anchors/books → design translation (AI only) / reduction template (crypto only) → critic]
```

## Main Workflow

### Step 1: Diagnose Intent
1. Determine which scenario (A/B/C/D/E) the user's intent belongs to
2. **Domain Router judgment**: problem domain (AI / Crypto / pure math / intersection)
3. Extract the core tension of the problem: what to preserve? what to suppress? what are the constraints? what is the engineering bottleneck?
4. Output a problem-type classification + domain tag

### Step 2: Route Invocation

```
Scenario A (Analysis): Select 1–3 lenses → output perspective diagnosis → critic review
Scenario B (Design): Select 1–3 lenses → invoke relevant activation anchors; if no coverage, enter Knowledge Gap Protocol → generate formal/temporary design patterns → critic review
  · AI domain: design patterns from design-patterns/; output attention/loss/routing/representation/compression
  · Crypto domain: design patterns from cryptography books' construction paradigms (SPN/Feistel/Merkle-Damgård/KEM-DEM/Fiat-Shamir); output encryption/MAC/signature/protocols
Scenario C (Query): Prefer loading relevant activation anchors or crypto books; if no coverage, generate temporary knowledge card → output per knowledge activation protocol
Scenario D (Verification): Load relevant anchors or temporary knowledge cards → critic reviews conditions and boundaries
  · AI domain: pass GPU Eight-Dimension Acceptance Gate
  · Crypto domain: pass reduction tightness + assumption dependency + implementation pitfall checks (GPU gate not required)
Scenario E (Engineering): No intervention
```

### Step 3: Output Format

**Token-economy rule**: The following is the maximum structure, not the default full template. Trim to the user's question; for simple knowledge queries, provide only the needed definition / formula / risk. Expand design and GPU/reduction sections only when relevant, and do not restate loaded cards verbatim. **After Domain Router determines the domain, only expand the domain-specific subsection.**

**Scenario A/B Output**:
1. **[Diagnosis]** Problem type + core tension
2. **[Lens]** Recommend 1–3 mathematical perspectives (annotate why each is/is not suitable)
3. **[Knowledge]** (Scenario B only) Activated mathematical structures (reference activation anchors or temporary knowledge cards)
4. **[Design]** (Scenario B only) Candidate AI module drafts (reference design patterns or temporary design drafts)
5. **[GPU]** Run candidates through the Eight-Dimension Gate (friendly/retrofittable/unfriendly)
6. **[Conclusion]** Retain candidates that pass both acceptance gates + next-step recommendations

**Scenario C Output** (Knowledge Activation Protocol, trimmed as needed):
1. Minimal definition
2. Core formulas
3. Applicable problems
4. AI design translation (only when the question involves AI / operators)
5. Engineering feasibility (only when implementation / GPU matters)
6. Risks and failure conditions
7. Further references (only when traceability is requested or the conclusion depends on book references)

**Scenario D Output** (short conclusion first + conditions/boundaries):
1. Conditions under which it holds
2. Conditions under which it fails
3. What it can guarantee at most
4. What it cannot guarantee
5. Engineering feasibility (only when implementation / GPU matters)

**A conclusion must always be provided — never output analysis alone without convergence.**

## GPU Eight-Dimension Acceptance Gate

Formal terminology (single authoritative source: `../../references/gpu-friendly-math.en.md`):
**Tensorization / GEMM-mappability / Complexity / Memory & KV-Cache / Low-Precision Stability / Parallelism & Communication / Sparse Structure / Operator Fusion**

**Quantitative assessment requirements**: For each candidate design, the GPU assessment should not only provide [v]/[~]/[x] labels but also answer:
1. FLOPs of core operations and ratio vs. baseline
2. Peak memory (bytes), whether large matrices are materialized
3. Numerical stability strategy under bf16/fp8
4. Number of fusible kernels and expected speedup

See the quantitative checklist in `../../references/gpu-friendly-math.en.md`.

## Depth-of-Consultation Protocol

- **Light**: Read knowledge cards (`../../knowledge-base/*/*.en.md`); self-contained and immediately usable
- **Medium**: Read distilled book notes (`../../references/books/*.en.md`) for more complete context; for cryptography, also consult the 3 English-language `.md` files listed in `../../references/skill-index.en.md`
- **Deep**: When `math_book/<PDF>` is available locally, the agent automatically runs `pdftotext` + grep to locate the original page

## Knowledge Gap Protocol

When the mathematical tools required by the user's problem are not in the existing `knowledge-base/`, do NOT force-fit existing cards. Execute the following procedure:

1. **Gap Identification**: Explicitly state that no fully corresponding knowledge card exists. Classify the gap as: new domain, new theorem family, new structure, new application scenario, or combinatorial extension of existing cards.

2. **Lens Fallback**: Select 1–3 most relevant thinking lenses to determine the problem's mathematical structure. E.g., local-to-global, categorical, spectral, projection, causal, perturbation.

3. **Candidate Knowledge Localization**: Provide mathematical keywords, theorem families, concept clusters, and reference book directions to look up. Existing card coverage is not required, but explain why these concepts are relevant.

4. **Temporary Knowledge Card**: Generate a temporary knowledge summary in the same format as formal cards:
   - Minimal definition
   - Core structure
   - Applicable problems
   - AI design translation
   - GPU feasibility
   - Risks and failure conditions
   - **Source & Confidence** (required):
     - Knowledge source: label as "Agent inference / Lens derivation / Reference book extrapolation / Requires external verification"
     - Confidence: High (theorem-backed) / Medium (reasonable inference, not rigorously proven) / Low (exploratory hypothesis)
     - Unverified claims: list key conclusions requiring subsequent verification

5. **Design Translation**: If the user's goal is mechanism design, translate the temporary knowledge into candidate AI modules, losses, routing, attention, representation, or compression schemes.

6. **Upgrade Recommendation**: If this gap recurs frequently, recommend adding a formal knowledge card or design pattern.

## Workflow Example

Full workflow example: `../../references/skill-index.en.md`.
