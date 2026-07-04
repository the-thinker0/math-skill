# 🖥️ Algorithmic Lens

> Algorithms are the automation of thought — converting insights into precise, repeatable steps.

## What Perspective It Offers

This is an "engineer's" perspective — decomposing problems into finitely executable steps, evaluating costs, and judging feasibility. Its first principle is not "how to solve it," but rather "whether it is solvable and at what cost." Some problems are inherently difficult (NP-complete), and some are inherently unsolvable (undecidable); understanding these limits is as important as finding solutions. Every problem should first be asked: to which complexity class does it belong?

## What Problems It Is Suited to Diagnose

- Automating processes — applying the same operation repeatedly to large volumes of data
- Estimating computational cost — evaluating time / space consumption before large-scale execution
- Judging feasibility — determining whether a problem is in P / NP-hard / undecidable to decide on a solution strategy
- Confronting combinatorial explosion — search spaces that grow exponentially with input size, requiring pruning or approximation

## What Problems It Is Not Suited For

- Problems with closed-form solutions that yield answers directly — algorithmization only adds complexity
- Problems that are inherently qualitative rather than procedural — they cannot be reduced to finite steps
- Unstructured inputs that cannot be discretized — when preprocessing is more complex than the core problem itself

## Which Knowledge Domains It Routes To

- Complexity theory (P / NP / undecidability): the fundamental framework for judging problem feasibility
- Algorithmic paradigms (divide-and-conquer / dynamic programming / greedy / backtracking / randomized): core design decisions that determine the subsequent path
- Data structures: storage and query efficiency directly affects algorithmic performance
- Computation theory (Turing machines / the halting problem): understanding the absolute boundaries of computability

## What AI Designs It May Inspire

- Complexity classifier: input → automatic determination of P / NP-hard / undecidable, with recommended response strategies
- Algorithmic paradigm selector: automatic paradigm selection based on subproblem independence / overlap / greedy properties
- Correctness verification pipeline: automated checking of loop invariants + structural induction + termination proofs

## Reasoning Protocol

1. **Formalize the specification**: Define the input domain, output domain, and constraints; write pre-condition and post-condition predicates
2. **Judge feasibility**: To which complexity class does the problem belong? P → exact algorithm; NP-hard → approximation / heuristics; undecidable → restricted version
3. **Select a paradigm**: Independent → divide-and-conquer; overlapping → dynamic programming; greedy property → greedy; structured search → backtracking; high deterministic cost → randomized
4. **Analyze complexity**: Provide time O(f(n)) and space O(g(n)); distinguish worst-case from average-case; attend to constant factors
5. **Prove correctness**: Use loop invariants / structural induction / termination proofs to ensure algorithmic reliability

## Acceptance Criteria

- Input / output specifications have been formalized; pre- and post-conditions can be expressed as predicates
- Complexity is given in terms of time order and space order, annotated with worst-case / average-case scenarios
- Feasibility class has been determined (P / NP-hard / undecidable), with a corresponding response strategy stated
- A correctness proof has been provided (loop invariant or inductive strategy), annotated as proved / unproved
- Optimization recommendations are based on bottleneck analysis rather than blind parameter tuning
