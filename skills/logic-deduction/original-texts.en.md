# Mathematical Sources and Classic Texts

## Propositional Logic

**Basic inference rules**:

| Rule Name | Form | Validity |
|-----------|------|----------|
| Modus Ponens | P → Q, P ⊢ Q | Valid |
| Modus Tollens | P → Q, ¬Q ⊢ ¬P | Valid |
| Hypothetical Syllogism | P → Q, Q → R ⊢ P → R | Valid |
| Disjunctive Syllogism | P ∨ Q, ¬P ⊢ Q | Valid |
| Affirming the Consequent | P → Q, Q ⊢ P | Invalid |
| Denying the Antecedent | P → Q, ¬P ⊢ ¬Q | Invalid |

## Boolean Algebra (Boole, 1854)

George Boole, in *An Investigation of the Laws of Thought* (1854), established an algebraic system for propositional logic, transforming logical reasoning into algebraic computation:

> "Logic is a species of algebra whose variables take only the values 0 and 1."

The core operations of Boolean algebra — ∧ (multiplication), ∨ (addition), ¬ (complement) — satisfy algebraic properties such as distributivity and De Morgan's laws. This is the algebraic dual of propositional logic: the same inferential structure can be handled either deductively or computationally. Boolean algebra later became the mathematical foundation of digital circuit design (Shannon, 1938) and computer science.

## Frege's *Begriffsschrift* (1879)

Frege invented the first complete formal system of first-order logic, introducing quantifiers (∀, ∃) and function symbols, demonstrating that logical reasoning can be fully mechanized. This is the starting point of modern mathematical logic — henceforth, mathematical proofs had precise syntactic rules rather than relying solely on intuitive narration.

> "Can arithmetical truths be proved purely logically? The Begriffsschrift provides the instrument for this."

## Peano Axioms (1889)

Constructing the natural number system from logic:

> 1. 0 is a natural number.
> 2. Every natural number n has a successor S(n).
> 3. 0 is not the successor of any natural number.
> 4. Different natural numbers have different successors.
> 5. (Induction Axiom) If a property holds for 0, and if it holds for n then it also holds for S(n), then the property holds for all natural numbers.

This demonstrates how to construct a complete mathematical system from a minimal set of logical assumptions. The Peano axioms are a paradigm of first-order theories — a single second-order induction axiom (or a first-order induction schema) suffices to characterize the entire structure of the natural numbers.

## Russell's Paradox (1901)

> "Consider the set R of all sets that do not contain themselves: does R contain R?"

If R ∈ R, then by definition R ∉ R; if R ∉ R, then by definition R ∈ R. The contradiction is irresolvable. This paradox directly demolished Frege's naive set theory (Frege acknowledged the fundamental flaw in his system upon receiving Russell's letter), triggering the "third crisis" of the foundations of mathematics. It gave rise to:

- **ZFC Set Theory** (Zermelo-Fraenkel + Choice): Eliminates the paradox by restricting set construction rules (the Separation schema rather than unrestricted Comprehension)
- **Type Theory** (Russell, 1908): Prohibits self-reference through a hierarchy of types
- **Intuitionism** (Brouwer): Rejects treating infinite sets as completed objects

Russell's paradox profoundly reveals that the consistency of a logical system cannot be taken for granted — it must be proved or constructively guaranteed.

## ZFC as Background Logic for Mathematics

Zermelo-Fraenkel set theory with the Axiom of Choice (ZFC) is the default foundational language of contemporary mathematics — virtually all mathematical objects (numbers, functions, spaces, groups) can be defined as sets within ZFC, and all mathematical theorems can (in principle) be translated into formal proofs in ZFC.

> "Mathematicians do not write ZFC proofs in daily work, but they presuppose that all proofs can in principle be formalized in ZFC."

ZFC's nine axioms (Extensionality, Empty Set, Pairing, Union, Power Set, Infinity, Separation, Replacement, Choice) carefully circumvent Russell's paradox while preserving sufficient constructive power. The Axiom of Choice (AC) has provoked ongoing controversy — it permits non-constructive selections (as in Zorn's Lemma and the Well-Ordering Theorem), revealing its cost in counterintuitive results such as the Banach-Tarski decomposition.

## First-Order vs Higher-Order Logic

**First-Order Logic (FOL)**: Quantifiers range only over individuals (∀x, ∃x), not over predicates or functions. This is the "standard language" of mathematical logic, possessing completeness (Gödel 1929) and compactness.

**Higher-Order Logic (HOL)**: Allows quantification over predicates (∀P) and functions (∀f), offering greater expressive power at a steep cost — higher-order logic is **incomplete** (no recursively enumerable proof system can capture all valid inferences) and non-compact.

> "First-order logic is complete but limited in expressive power; higher-order logic is expressive but incomplete. This is a fundamental trade-off."

Peano Arithmetic (PA) is a first-order theory whose induction axiom is encoded as infinitely many first-order axiom schemas; the genuine Peano axioms (with second-order induction) uniquely characterize ℕ, but first-order PA has non-standard models. This connects directly to the Löwenheim-Skolem theorem.

## Gödel: Completeness (1929) vs Incompleteness (1931)

**Completeness Theorem (1929)**: The deductive system of first-order logic is complete — every logically valid formula can be formally proved.

> "In first-order logic, all logically valid formulas can be proved from the axioms through formal inference."

**Incompleteness Theorem (1931)**: Any consistent formal system that includes basic arithmetic contains undecidable propositions — neither provable nor refutable.

> "In any sufficiently strong consistent formal system T, there exists a sentence G such that T ⊬ G and T ⊬ ¬G."

The crucial distinction: the Completeness Theorem states that the **logical system itself** does not miss any valid inference; the Incompleteness Theorem states that **arithmetic theory** cannot exhaust all truths. The two are not contradictory — completeness guarantees "the inference rules are sufficient," while incompleteness reveals "arithmetical truth transcends any fixed set of axioms."

## Löwenheim-Skolem Theorem (1920, 1922)

> "If a first-order theory T has an infinite model, then T has a model of every infinite cardinality κ ≥ ℵ₀."

Downward Löwenheim-Skolem: T must have a countable model. Upward Löwenheim-Skolem: T must have models of arbitrarily large cardinality.

A startling corollary: a first-order theory **cannot control the cardinality of its models**. Even though ZFC aims to describe an uncountable universe of sets, ZFC itself has countable models (the Skolem paradox). This reveals a fundamental limitation of first-order logic's expressive power — first-order sentences cannot distinguish the "internal" and "external" perspectives on "countable" versus "uncountable."

## Tarski's Semantic Theory of Truth (1933)

> "'Snow is white' is true if and only if snow is white."

Tarski provided a formal definition of truth (the T-schema), illuminating the distinction between "truth" and "provability" in logic — "truth" is a semantic concept (dependent on models), while "provability" is a syntactic concept (dependent on proof systems). The Completeness Theorem bridges the two (in FOL, T ⊢ φ ⇔ T ⊨ φ), but in strong theories such as arithmetic they are permanently separated (Gödel's incompleteness).

Tarski also proved that a sufficiently expressive language **cannot consistently define truth within itself** — a truth definition must employ a stronger metalanguage. This, together with Russell's paradox and Gödel's incompleteness, forms a triad of impossibility results concerning self-reference.

## Gentzen's Natural Deduction and Sequent Calculus (1935)

Gerhard Gentzen, in *Investigations into Logical Deduction*, invented two entirely new proof structures:

**Natural Deduction**: Inference rules are organized around the introduction (I) and elimination (E) of each logical connective — ∧I, ∧E, →I, →E, ∀I, ∀E, etc. This captures the way mathematicians actually reason: assume a premise, derive a conclusion, then discharge the assumption (→I, i.e., conditional proof).

**Sequent Calculus**: The objects of proof are sequents Γ ⊢ Δ (assumptions on the left, conclusions on the right), and rules operate between sequents. The key breakthrough: the **Cut-Elimination Theorem** (Hauptsatz) — any proof using the Cut rule can be transformed into a cut-free proof.

> "The Hauptsatz states that all proofs can be transformed into cut-free proofs, eliminating all 'intermediate formulas'."

Cut-elimination is the central tool of proof theory: it guarantees the subformula property (every step of a cut-free proof involves only subformulas of the final conclusion), making consistency and decidability proofs possible. Gentzen's work shifted logic from an "axiomatic" to a "structural" paradigm, founding the discipline of Proof Theory.

## Turing's Halting Problem (1936)

Alan Turing, in *On Computable Numbers*, defined the Turing machine and proved:

> "There is no general algorithm that can decide whether an arbitrary Turing machine halts on an arbitrary input."

The undecidability of the halting problem is a fundamental limitation on computation and logic. Its logical essence is equivalent to Gödel's incompleteness: if the halting problem were decidable, arithmetic incompleteness could be circumvented; if arithmetic were complete, the halting problem would be decidable. The two are duals — two faces of the same wall.

A direct corollary of the halting problem: the **Entscheidungsproblem** for first-order logic is also undecidable (Church, 1936; Turing, 1936) — there is no general algorithm that can decide whether an arbitrary first-order formula is logically valid. Logical deduction can be executed, but it cannot be mechanically and fully predicted.

## Resolution and Unification (Robinson, 1965)

J. A. Robinson, in *A Machine-Oriented Logic Based on the Resolution Principle*, introduced the resolution rule:

> "Resolve P ∨ Q and ¬P ∨ R to obtain Q ∨ R."

Resolution compresses all inference into a single rule combined with the Unification algorithm — automatically finding an algebraic substitution σ that makes two terms equal, so that σ(P) = σ(P'), thereby enabling resolution on complementary literals.

Resolution-unification is the mathematical core of Automated Theorem Proving and Logic Programming (e.g., Prolog). It demonstrates that proof search in first-order logic can be unified into a single algorithmic process, although efficiency issues (search space explosion) remain a severe practical challenge.

## Curry-Howard Correspondence (1969)

> "Propositions as types, proofs as programs."

Curry (1958) first observed the correspondence between types in combinatory logic and formulas in propositional logic; Howard (1969) extended it to constructive predicate logic:

| Logic Concept | Type Theory / Programming Concept |
|---------------|-----------------------------------|
| Proposition A | Type A |
| A ∧ B | A × B (product type) |
| A ∨ B | A + B (sum type) |
| A → B | A → B (function type) |
| ∀x. P(x) | Πx:A. P(x) (dependent function type) |
| ∃x. P(x) | Σx:A. P(x) (dependent pair type) |
| Constructive proof | Executable program |

The Curry-Howard correspondence reveals a deep isomorphism between logical deduction and computation: a constructive proof is a program, and the execution of the program is proof normalization. This is the computational counterpart of Gentzen's cut-elimination — β-reduction is cut-elimination.

This correspondence became the theoretical foundation of type theory (Martin-Löf, 1972), dependently typed programming (Coq, Agda), and Homotopy Type Theory (HoTT, 2013), unifying "proof correctness" and "program correctness" into a single problem.

## Formalization of Common Logical Fallacies

| Fallacy Name | Form | Counterexample |
|--------------|------|----------------|
| Affirming the Consequent | P → Q, Q ∴ P | "If it rains, the ground is wet; the ground is wet, therefore it rained" (could be a sprinkler) |
| Denying the Antecedent | P → Q, ¬P ∴ ¬Q | "If it rains, the ground is wet; it did not rain, therefore the ground is not wet" (could be a sprinkler) |
| Begging the Question (Circular Reasoning) | P ∴ P | "This book tells the truth because the book says so" |
| Straw Man | Attacking P' ≠ P | A: "We should increase the education budget." B: "You want to give all the money to schools." |
| Slippery Slope | A → B → ... → Z, ∴ ¬A | "Allow this → that → disaster, therefore we must not allow it." |
