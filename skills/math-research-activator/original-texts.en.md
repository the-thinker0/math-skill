# Intellectual Sources for the Math Research OS

> **Note**: This file is design-rationale background (Pólya/Newell-Simon/Schoenfeld intellectual sources), not a runtime resource — the Domain Router does not auto-load it. Consult it only to understand the skill's design motivation.

## The Tradition of Problem Classification and Tool Selection

### Pólya's Problem-Solving Heuristics

George Pólya (1887-1985) proposed the four-step problem-solving method in *How to Solve It* (1945), which laid the foundation for modern problem-solving methodology:

1. **Understanding the problem** — You must understand the problem
2. **Devising a plan** — Find the connection between the known and the unknown
3. **Carrying out the plan** — Check each step
4. **Looking back** — Examine the solution obtained

Pólya's central insight: **different types of problems require different problem-solving strategies**. He catalogued dozens of heuristic strategies, including:
- If you cannot solve the proposed problem, try to solve some related problem first
- Go back to definitions
- From the particular to the general, and from the general to the particular
- Consider extreme cases
- Reason backwards
- Draw a figure
- Introduce auxiliary elements

> "Problem solving is a practical skill, like swimming — you can learn it by imitation and practice." — Pólya

Pólya's taxonomy of heuristics provides the intellectual foundation for our activator: **the core characteristics of a problem (such as "does it involve uncertain quantities," "does it exhibit symmetry," "can it be decomposed into subproblems") determine the most appropriate problem-solving method**.

### Newell & Simon's Problem Space Theory

Allen Newell and Herbert A. Simon proposed the problem space theory in *Human Problem Solving* (1972):

- **Problem Space**: The set of all possible states, including the initial state, the goal state, and the permissible operations
- **Search Strategy**: A method for navigating from the initial state to the goal state within the problem space
- **Heuristic Search**: Rather than exhaustively enumerating all states, use heuristic rules to select the directions most likely to lead toward the goal

Core insight: **the nature of the problem space determines the choice of search strategy**. If the problem space is small, exhaustive search is feasible; if it is large, heuristics are essential; if the problem space has special structure (such as monotonicity or symmetry), that structure can be exploited to accelerate the search.

> "Choosing a search strategy is the most critical decision in problem solving — the strategy determines which region of the problem space you will search." — Newell & Simon

### Schoenfeld's Strategic Decision Theory

Alan H. Schoenfeld, in *Mathematical Problem Solving* (1985), analyzed why students fail to solve problems even when they possess the necessary tools — the critical deficiency is not a lack of tools but a lack of **strategic decision-making ability**:

- **Resources**: Knowledge, skills, tools — corresponding to our 15 thinking lenses
- **Heuristics**: How to use resources — corresponding to the methodological workflow for each thinking lens
- **Control**: When to use which resource — corresponding to the function of the activator
- **Belief Systems**: Beliefs about mathematics and about oneself — affecting whether the appropriate tool is selected

Core insight: **mastery of tools ≠ ability to solve problems. The critical difference lies at the 'control' level — knowing when to deploy which tool**. This is precisely the problem the activator is designed to address.

> "The students' problem is not a lack of knowledge or skill, but a lack of strategic decision-making ability — they do not know when to use which method." — Schoenfeld

### Wicked Problems Theory (Rittel & Webber)

Horst Rittel and Melvin Webber, in "Dilemmas in a General Theory of Planning" (1973), distinguished between "tame problems" and "wicked problems":

Characteristics of tame problems:
- Clearly defined
- Have clear stopping conditions
- Solutions can be objectively evaluated as right or wrong
- Domain-specific

Characteristics of wicked problems:
- No definitive formulation — understanding the problem is itself part of solving it
- No clear stopping conditions
- Solutions are not right or wrong, only better or worse
- Span multiple domains

Core insight: **wicked problems require combinations of cross-domain thinking lenses, whereas tame problems can be solved with a single tool**. The activator recommends multi-tool combinations when facing wicked problems and single-tool focus when facing tame problems.

> "Wicked problems have no right or wrong answers, only better or worse ways of dealing with them." — Rittel & Webber

### Kahneman's Dual-System Theory

Daniel Kahneman, in *Thinking, Fast and Slow* (2011), proposed the dual-system theory:

- **System 1**: Fast, intuitive, automatic — responsible for the majority of everyday decisions
- **System 2**: Slow, rational, deliberate — required for decisions demanding careful thought

Core insight: **not all problems require System 2-level rational analysis**. Many everyday decisions require only intuition (System 1), and forcibly deploying thinking lenses constitutes over-analysis. The activator's "inapplicable scenarios" list is grounded in this insight — simple problems do not need tools; wicked problems do.

> "Overthinking is the enemy of decision-making — some decisions are best left to intuition." — Kahneman

### Lakatos's Methodology

Imre Lakatos, in *Proofs and Refutations* (1976), demonstrated that mathematical knowledge does not grow linearly but evolves through a dialectical process of "conjecture → refutation → revision":

- **Progressive Problemshift**: Each revision gives rise to new, deeper questions
- **Degenerative Problemshift**: Revisions merely accommodate counterexamples without generating new insights

Core insight: **tool selection itself should be a progressive problemshift** — the initial choice may not be ideal, but through post-use reflection, the ability to choose improves progressively. The activator's "combination sequencing" and "auxiliary perspectives" recommendations embody this dialectical thinking.

> "Knowledge is not truth descending from above, but conjecture continually refined through criticism and refutation." — Lakatos

## Mapping Ideas to Practice

Our activator integrates all of the above intellectual traditions:

| Intellectual Source | Manifestation in the Math Research OS |
|---------|-------------------|
| Pólya's Heuristics | 11 characteristic branches in the decision tree — each branch corresponds to a class of heuristic strategies |
| Newell & Simon's Problem Space | Problem characteristic dimensions — interactivity, uncertainty, constraint, structure, dynamism |
| Schoenfeld's Strategic Selection | The core principle that "choosing the right tool matters more than brute-force analysis" |
| Wicked Problems Theory | Multi-tool combination recommendations — wicked problems require cross-domain tool combinations |
| Kahneman's Dual System | "Inapplicable scenarios" — simple problems do not need tools; avoid over-analysis |
| Lakatos's Methodology | Combination sequencing advice — use the primary tool first, then supplement with auxiliary tools for additional perspectives |
