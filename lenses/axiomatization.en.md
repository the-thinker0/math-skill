# 📐 Axiomatization Lens

> Build from minimal assumptions using rigorous logic — scrutinizing premises matters more than checking conclusions

## What Perspective It Offers

Axiomatization is not "proving things," but rather a stance of disciplined skepticism: every theoretical system rests on a set of implicit or explicit assumptions, and laying all of these assumptions bare — examining them one by one — is far more likely to reveal fundamental problems than inspecting the conclusions alone. If the premises are wrong, no conclusion, however elegant, can stand. This perspective turns the "taken for granted" into an object requiring verification.

## What Problems It Is Suited to Diagnose

- Whether the assumptions of a paper or theory are self-consistent, and whether undeclared implicit premises exist
- Whether two ostensibly equivalent sets of premises are genuinely independent (i.e., whether redundant axioms are present)
- Whether a formal system is decidable, and whether undecidable propositions exist within it
- After axiomatizing an operator or structure and identifying its invariants, checking consistency and completeness

## What Problems It Is Not Suited For

- Purely factual queries — no theoretical framework requires examination
- The user has already accepted the framework and only needs to apply it — the axioms are already chosen
- Empirical questions — axiomatization cannot substitute for empirical evidence
- Constructive contexts where the law of excluded middle or the axiom of choice should not be assumed by default

## Which Knowledge Domains It Routes To

- **formal-logic**: The choice among first-order, second-order, and constructive logic is the foundational decision in axiomatization
- **set-theory**: ZFC/ZF as the background axiomatic system and the host for relative consistency proofs
- **model-theory**: Model existence proves consistency; categoricity determines structural uniqueness

## What AI Designs It May Inspire

- **Premise Auditing Module**: Automatically extracts explicit and implicit assumptions from papers and annotates their logical hierarchy
- **Axiom Perturbation Engine**: Given a change to one axiom, derives how the resulting theoretical system shifts
- **Consistency Guardian**: Detects in real time whether the axiom set generates contradictions during reasoning

## Reasoning Protocol

1. **Lay Out Premises**: List all explicit axioms, implicit assumptions, and background framework assumptions
2. **Specify the Language**: Declare the formal language (first-order, second-order, or constructive) and state the rationale for the choice
3. **Consistency Check**: Construct a model or carry out a relative consistency proof to confirm the axiom set is non-contradictory
4. **Independence Check**: For each axiom, attempt to construct a model in which it fails while all others hold
5. **Completeness Assessment**: Determine whether the axiom set suffices to derive all significant results in the target domain, and annotate decidability

## Acceptance Criteria

- Every axiom has an explicit verdict on consistency, independence, and completeness (none left unresolved)
- Implicit assumptions have been made explicit
- The consequences of axiom modifications have been analyzed
- An overall evaluative conclusion about the theoretical system has been provided
