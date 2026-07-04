# 🧠 Perturbation Lens

> Logic is the house rule of mathematics — every step in a chain of reasoning must be carried out under the supervision of formal rules

## What Perspective It Offers

The perturbation perspective (formerly "Logical Deduction") is a way of "scrutinizing the rigor of a chain of reasoning": for any argument, ask, "What are the premises? Is each inference rule applied legitimately? Have quantifier orders been quietly swapped? Has the logical strength of the conclusion been overstated?" Deduction necessarily carries true premises to true conclusions, but a single unjustified leap anywhere in the chain breaks the entire argument. The nesting order of quantifiers (∀∃ vs. ∃∀) determines a fundamental difference in logical strength.

## What Problems It Is Suited to Diagnose

- Rigor checks on proofs and derivations in papers or code
- Arguments that may contain logical leaps or hidden premises
- Quantifier structure analysis of mathematical statements involving ∀ and ∃
- Whether a conclusion genuinely follows from its premises (whether Γ ⊢ φ holds)

## What Problems It Is Not Suited For

- The premises themselves are uncertain — establish the truth or falsity of premises before deducing
- Problems requiring creative breakthroughs — deduction only discovers what is already entailed; it generates no new information
- Second-order logic problems — Gödel's completeness theorem covers only first-order logic

## Which Knowledge Domains It Routes To

- **formal-logic**: Inference rules of propositional and predicate logic (modus ponens, quantifier instantiation and generalization)
- **proof-theory**: Proof strategy selection (direct proof, proof by contradiction, contrapositive, constructive proof)
- **set-theory**: The axiom of choice and the ZF framework — foundations for quantifier strength and existence assertions

## What AI Designs It May Inspire

- **Reasoning Chain Auditor**: Reconstructs the reasoning process step by step, annotating the inference rule used at each step
- **Fallacy Detector**: Automatically checks for common fallacies such as affirming the consequent, quantifier shifting, and illicit universal generalization
- **Conclusion Strength Annotator**: Distinguishes necessary, probable, and hypothetical conclusions, preventing "possibly" from being inflated to "necessarily"

## Reasoning Protocol

1. **Identify Premises**: List all premises, annotating their source (proven, axiom, assumption, or empirical) and logical level (propositional or predicate)
2. **Reconstruct the Reasoning Chain**: Restate the argument step by step in a formal logical language, annotating each step with its inference rule
3. **Check for Fallacies**: Systematically check for common fallacies in propositional and predicate logic
4. **Analyze Quantifier Structure**: Annotate the nesting order and logical strength of ∀/∃ (∀∃ is weak vs. ∃∀ is strong)
5. **Assess Conclusion Strength**: Annotate whether the conclusion is necessary, probable, or hypothetical; distinguish universal, existential, and conditional scopes

## Acceptance Criteria

- All premises have been made explicit; no hidden premises remain
- Every step in the reasoning chain is supported by a legitimate inference rule
- Common fallacies have been individually checked and results annotated
- Quantifier structure has been analyzed and logical strength has been annotated
- The strength and scope of the conclusion have been clearly determined
