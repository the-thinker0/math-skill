# Categorification Lens

> Strip away incidental details to reveal essential structure — problems across different domains often share the same abstract skeleton

## What Perspective It Offers

Categorification (formerly "Abstraction") is a way of "recognizing isomorphisms across domains": when confronted with a complex problem, first strip away surface details and ask, "What does its skeleton look like? Have I seen this skeleton in another domain before?" Essential features — those whose alteration would fundamentally change the nature of the problem — must be preserved; inessential features may be discarded. The category-theoretic viewpoint pays particular attention to the behavior of morphisms between objects rather than to the internal structure of the objects themselves.

## What Problems It Is Suited to Diagnose

- Facing a complex problem with no clear entry point — extract the core structure first
- Two seemingly different problems share similarities — find a common abstract framework
- A need to generalize concrete observations into general principles
- Identifying transferable structural patterns for algorithm or operator design (group actions, functors, natural transformations)

## What Problems It Is Not Suited For

- Every detail is critical (e.g., debugging a specific bug) — abstraction discards crucial information
- A concrete numerical answer is required — categorification does not provide specific computations
- The problem is already in its simplest form — no further abstraction is needed

## Which Knowledge Domains It Routes To

- `lie-theory/equivariance`: Objects, morphisms, functors, natural transformations, and the Yoneda lemma — the core language for cross-domain transfer
- `lie-theory/representation`: Groups, rings, fields, modules, and lattices — axiom-matching to identify algebraic structure
- **topology**: Open sets, continuity, and connectedness — when the problem involves spatial structure and continuous deformation

## What AI Designs It May Inspire

- **Structure Recognizer**: Extracts objects and morphisms from a problem description and matches them to known categories
- **Cross-Domain Analogy Engine**: Uses functors to transfer solution strategies from one domain to another
- **Abstraction-Level Manager**: Determines whether the current stage involves extraction, generalization, or structuring, and decides whether to ascend to a higher level

## Reasoning Protocol

1. **Precisely Describe the Concrete**: Use mathematical language to describe all elements of the problem — objects, relations, constraints, and objectives
2. **Distinguish Essential from Inessential**: Examine each feature one by one; determine whether altering it changes the core structure
3. **Select a Matching Perspective**: Choose the best-matching framework from category theory, algebra, topology, or analysis, and execute its operations
4. **Solve at the Abstract Level**: Use universal constructions (products, coproducts, limits) or the Yoneda perspective to solve the problem abstractly
5. **Concretize Back to the Original Problem**: Translate the abstract solution precisely back into the mathematical language of the original problem, verifying that no information is lost

## Acceptance Criteria

- Essential and inessential features have been clearly distinguished and annotated
- A matching abstract perspective has been selected with stated rationale
- The abstract solution has been concretized back to the original problem
- The round-trip process has been verified to preserve all critical information intact
- The current level — extraction, generalization, or structuring — has been annotated
