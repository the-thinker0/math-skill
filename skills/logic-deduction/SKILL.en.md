---
name: logic-deduction
description: |
  Trigger when checking proof rigor, formal logic analysis, premise auditing, predicate logic verification, quantifier structure analysis, discovering logical loopholes; or doing formal derivation and proof verification for algorithm correctness or invariants.
---

# 🧠 Logic Deduction

> "Logic is the house rule of mathematics — all reasoning must proceed under the supervision of formal rules."
>
> — Gödel's Completeness Theorem (1929), First-Order Logic

## Core Principle

Deriving new true propositions rigorously from true premises — every step in the chain of inference must be legitimate. Types of inference: deduction (true premises + valid rules → necessarily true conclusion, most reliable), induction (instances → general, probabilistic), abduction (observation + theory → best explanation, hypothetical).

> **Mathematical Formalization**
>
> Logical deduction has a two-layer structure: propositional logic handles truth-functional connectives (¬, ∧, ∨, →, ↔), and predicate logic adds quantifiers (∀, ∃) and individual variables on top of this foundation. Mathematical proofs live within predicate logic — propositional logic alone cannot express statements such as "for all x, if P(x) then Q(x)," and therefore cannot proof-check actual mathematical arguments.
>
> Gödel's Completeness Theorem (1929): In first-order predicate logic, all valid arguments are provable — if φ is a valid formula of first-order logic, there exists a formal proof sequence deriving φ from the empty premise set. This guarantees that the deductive power of first-order logic coincides exactly with semantic validity (soundness + completeness), but this holds only for first-order logic; second-order logic does not enjoy this property.
>
> See `original-texts.md` for detailed mathematical foundations.

## GPU-Friendliness (Cross-Cutting Check)

When logical/formal verification structures are mapped to GPU, caution is required: **symbolic reasoning is often "beautiful but not computable"** — proof search and resolution backtracking are inherently serial and difficult to tensorize. When logic is used for algorithm/invariant design, pass the eight-dimension gate of `../../references/gpu-friendly-math.md`:

- **Batch SAT/SMT solving**: Independent clauses can be batch-parallelized (friendly), but CDCL backtracking is serial.
- **Theorem proving (Coq/Lean)**: Tactic solvers are highly serial with complex dependency graphs — not trainable; **verify offline** and deploy only the conclusions.
- **Model Checking**: State-space explosion → symbolic BDDs can compress; on GPU, switch to parallel SAT / local reachability (retrofittable).
- **Type/invariant checking**: Used as compile-time/offline static checks with zero runtime overhead (friendly).
- **Anti-pattern**: Embedding resolution/natural-deduction proof search inside the training loop — non-differentiable and non-parallelizable; should be relaxed to differentiable approximations (probabilistic/neuro-symbolic logic) or proved offline with only conclusions deployed.

Eight-dimension minimum assessment (formal terminology): **Tensorization** — typically unfriendly unless clauses/states can be batch-encoded; **GEMM-Mappability** — suitable only for differentiable logic, SAT scoring, or Boolean semiring approximations; **Complexity** — must flag the exponential or undecidable boundary of proof search/model checking; **Memory & KV-Cache** — whether state spaces, proof trees, or BDDs explode; **Low-Precision Stability** — whether relaxed logic preserves semantic boundaries under fp16/bf16; **Parallelism & Communication** — whether branching search can be batched or offloaded; **Sparsity Structure** — whether the constraint graph is regular; **Operator Fusion** — whether logic loss/mask can be fused; proof search itself should never enter a kernel.

> In conjunction with `../../references/books/abstract-algebra.md` (formal systems), `../../references/books/algebraic-geometry-rising-sea.md` (category-theoretic reasoning).

## When NOT to Use

- **The premises themselves are uncertain** — first establish the truth of premises, then deduce.
- **A creative breakthrough is needed rather than logical verification** — deduction can only discover conclusions already implicit in existing information; it cannot generate new information.
- **Second-order logic problems** — Gödel's completeness covers only first-order logic; second-order validity cannot be fully axiomatized.

## When to Use

- When reading a paper or code, checking the rigor of its proofs/derivations/invariants.
- When suspecting logical leaps or gaps in an argument and needing to locate them formally.
- When verifying whether a conclusion truly follows from the premises (whether Γ ⊢ φ holds).
- When analyzing mathematical statements containing ∀ / ∃, verifying the correctness of quantifier reasoning.
- When checking the validity boundary of a second-order logic argument.
- When performing formal derivation and proof verification for algorithm correctness, loop invariants, or program properties.

## Method

### Step 1: Identify the Premises
List all premises (assumptions, known conditions, cited theorems) in the argument, annotating their status: **proven theorem** (e.g., "there are infinitely many primes"), **axiom** (e.g., ZF set theory axioms), **hypothesis** (e.g., "the Riemann Hypothesis"), **empirical fact**. Also annotate the logical level: purely propositional premises (no quantifiers) or predicate premises (containing ∀ / ∃). Premise quality determines inference quality — if the premises do not hold, the conclusion is inevitably unreliable.

### Step 2: Check the Rules of Inference
Verify that each step uses a valid rule of inference.

**Propositional logic rules**: Modus Ponens P→Q, P ⊢ Q; Modus Tollens P→Q, ¬Q ⊢ ¬P; Hypothetical Syllogism P→Q, Q→R ⊢ P→R; Disjunctive Syllogism P∨Q, ¬P ⊢ Q; Conjunction Introduction P, Q ⊢ P∧Q; Double Negation Elimination ¬¬P ⊢ P.

**Predicate logic rules**: Universal Instantiation (UI) ∀x P(x) ⊢ P(a); Universal Generalization (UG) P(a) holds for arbitrary a ⊢ ∀x P(x) (a must be arbitrary, not a specific constant); Existential Instantiation (EI) ∃x P(x) ⊢ P(c) (c must be a fresh name, not conflicting with existing constants); Existential Generalization (EG) P(a) ⊢ ∃x P(x).

**Other frameworks**: Resolution Principle — from (P∨Q) and (¬P∨R), resolve to (Q∨R), suitable for automated proving; Natural Deduction systems — organized symmetrically by introduction/elimination rules, more closely mirroring human reasoning habits.

### Step 3: Check for Common Fallacies
**Propositional logic fallacies**: Affirming the consequent P→Q, Q ⊢ P (invalid); Denying the antecedent P→Q, ¬P ⊢ ¬Q (invalid); confusing sufficient and necessary conditions; circular reasoning (the conclusion is implicitly used as a premise); straw man fallacy.

**Predicate logic fallacies**: Quantifier shift fallacy ∀x∃y R(x,y) ≠ ∃y∀x R(x,y) (the former means "each person has their own beloved," the latter means "there is someone beloved by everyone"); illegal universal generalization (inferring ∀x P(x) from P(a) for a specific a, violating UG's arbitrariness requirement); confusing free and bound variables; confusing the strength of ∀ and ∃; equivocation; false dilemma (presenting P∨Q as the only options, implicitly excluding ¬P∧¬Q).

### Step 4: Analyze Quantifier Structure
The nesting order of ∀ and ∃ determines logical strength:
- **∀∃ structure** (weaker): ∀x∃y R(x,y) — for each x, a respective y can be constructed; constructively satisfiable.
- **∃∀ structure** (stronger): ∃y∀x R(x,y) — there exists a uniform y that holds for all x, often requiring the Axiom of Choice.

Key points: the more nesting layers, the more carefully one must reason; adjacent quantifiers of the same type commute (∀x∀y = ∀y∀x, ∃x∃y = ∃y∃x), but quantifiers of different types do not; quantifier negation equivalences: ¬∀x P(x) ≡ ∃x ¬P(x), ¬∃x P(x) ≡ ∀x ¬P(x).

### Step 5: Verify Completeness of the Inference Chain
Check whether the premise set Γ can formally derive the conclusion φ: does there exist a finite sequence φ₁, φ₂, ..., φₙ = φ, where each φᵢ either belongs to Γ or follows from earlier formulas by a valid rule? If the chain is incomplete, flag the missing intermediate steps and the rules they would require. A single missing step breaks the entire chain.

### Step 6: Assess the Strength of the Conclusion
Logical strength classification: **necessary** (deductively valid; if premises are true, the conclusion is necessarily true), **probable** (inductively supported, probabilistic evidence), **hypothetical** (abductive, best explanation but unverified). Also assess scope: universal (∀) or existential (∃)? Conditional (→) or unconditional? Do not inflate "possible" into "necessary."

### Step 7: Select Proof Strategy
- **Direct proof**: Proceed step by step from premises to conclusion; the most natural approach.
- **Proof by contradiction**: Assume ¬φ and derive a contradiction, thereby proving φ; suited for negative conclusions or arguments difficult to construct directly.
- **Contrapositive proof**: Prove ¬Q → ¬P to establish P → Q; used when the contrapositive direction is easier to reason about.
- **Proof by exhaustion**: Verify all cases one by one; suited for finitely enumerable situations.
- **Constructive proof**: Directly construct an object satisfying the conditions; more informative than a pure existence proof (which merely shows ∃x P(x) without specifying x).

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Confusing sufficient and necessary conditions | P → Q holding does not mean Q → P holds | Clearly distinguish sufficient, necessary, and necessary-and-sufficient conditions |
| Affirming the consequent fallacy | P → Q, Q ⊬ P; only Modus Ponens/Tollens are valid | Reject invalid inferences such as P→Q, Q ⊢ P |
| Hidden premises | Using unstated premises in the reasoning | Expose all premises and examine each one |
| Infinite regress | Every premise requires another premise to prove it | Find a starting point that needs no proof (axioms / empirical facts) |
| Quantifier shift fallacy | ∀x∃y R(x,y) ≠ ∃y∀x R(x,y); the former is weaker, the latter stronger | Strictly respect quantifier order; do not swap quantifiers of different types |
| Illegal universal generalization | Inferring ∀x P(x) from P(a) for a specific a, violating UG's arbitrariness requirement | UG applies only to arbitrary individuals a, not to specific constants |
| Confusing free and bound variables | x is bound in ∀x P(x) but free in P(x); the meanings differ | Clearly annotate the bound/free status of variables; avoid conflating them |
| Confusing ∀ and ∃ | "All elements satisfy P" is far stronger than "some element satisfies P" | Strictly distinguish the logical strength of universal and existential assertions |
| Embedding symbolic reasoning in the training loop | Proof search/resolution is inherently serial and non-differentiable — "beautiful but not computable" | Relax to differentiable approximations (probabilistic/neuro-symbolic) or prove offline and deploy only conclusions |

## Operating Procedure

When this skill is triggered, the output must contain:

1. **[Premise Inventory]** — List all premises, annotated `[proven]` / `[axiom]` / `[hypothesis]` / `[empirical]`, and annotated with logical level `[propositional]` / `[predicate]`
2. **[Inference Chain Reconstruction]** — Restate the reasoning process in formal logic language, annotating the inference rule used at each step (including predicate rules such as UI/UG/EI/EG)
3. **[Fallacy Check]** — Check for propositional and predicate logic fallacies one by one, annotating `✅ No such fallacy` or `❌ Found [specific fallacy]`
4. **[Quantifier Structure Analysis]** — If ∀ / ∃ nesting is present, annotate quantifier order and logical strength `∀∃ (weak)` / `∃∀ (strong)`
5. **[Completeness Assessment]** — Is the inference chain complete? Annotate `✅ Complete` or `⚠️ Gap: [explanation]`
6. **[Conclusion Strength]** — Annotate `[necessary]` / `[probable]` / `[hypothetical]`, and annotate scope `[universal]` / `[existential]` / `[conditional]`
7. **[Proof Strategy Assessment]** — What proof strategy does the current argument use? Is there a better strategy? Annotate `✅ Strategy appropriate` or `💡 Suggestion: [better strategy]`
8. **[GPU Feasibility]** (if used for algorithm/invariant verification) — Whether formal verification is conducted offline and conclusions can be deployed; whether proof search needs to be relaxed to a differentiable approximation; pass the eight-dimension gate.

**Output must never provide analysis alone without a conclusion.**

## Relations to Other Skills

- **Axiomatization**: Logical deduction is the inference engine of axiom systems; axioms provide the premises, deduction provides the derivation mechanism, and together they constitute a formal system.
- **Abstraction**: Formal logic is itself a highly abstract structure — stripping away specific content to retain only the form of inference.
- **Induction and Analogy**: Deduction and induction are complementary — deduction guarantees correctness, induction provides new premises.
- **Probability and Statistics**: Under uncertainty, classical logic must be extended to probabilistic logic.
- **Algorithmic Thinking**: Logical deduction provides the formal framework for proving algorithm correctness — verifying program properties is essentially first-order predicate reasoning.
- **Counterexample Thinking**: Counterexamples are the direct means of falsifying ∀ assertions, forming a dual verification system with deductive proof of truth.
- **Modern Math Activation**: `../../references/books/abstract-algebra.md` (formal systems), `../../references/books/algebraic-geometry-rising-sea.md` (category-theoretic reasoning).
