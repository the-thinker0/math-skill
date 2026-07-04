# 🧮 Projection Lens

> Counting is the oldest mathematical activity — finite objects encode infinite patterns. Project complex wholes onto discrete structures, and use systematic counting and algebraic transformations to reveal hidden order.

## What Perspective It Offers

This is a "disassembler's" perspective — projecting continuous or chaotic wholes into discrete, countable structures, then using combinatorial principles and algebraic tools (generating functions, recurrences) to discover the deep laws governing enumeration. It rests on the conviction that finite, simple rules can govern infinitely complex phenomena. Behind every "how many ways" question lies a structure that can be unlocked algebraically.

## What Problems It Is Suited to Diagnose

- Counting configurations (permutations / combinations / partitions / distributions)
- Discovering recurrence relations or closed-form formulas for enumerative sequences
- Graph and network analysis (connectivity / paths / matchings / colorings / coverings)
- Transforming counting problems into algebraic ones (recurrence → generating function → coefficient extraction)

## What Problems It Is Not Suited For

- Continuous or analytical problems with no discrete structure — limits, derivatives, and integrals belong to analysis, not combinatorics
- Problems where an exact closed-form formula directly yields the answer — combinatorial enumeration is unnecessary overhead
- Purely probabilistic problems with no combinatorial structure — continuous distribution parameter estimation does not involve finite-set counting

## Which Knowledge Domains It Routes To

- Combinatorics (counting principles / inclusion-exclusion / pigeonhole): foundational tools for the systematic counting of finite structures
- Generating functions (OGF / EGF): the core method for transforming counting problems into algebraic ones
- Graph theory (paths / matchings / colorings / connectivity): discrete modeling and analysis of relational structures
- Abstract algebra (group actions / Burnside / Pólya): counting equivalence classes under symmetry

## What AI Designs It May Produce

- Counting-type classifier: permutation / combination / partition, ordered / unordered, labeled / unlabeled → automatic formula selection
- Generating function solver: recurrence → construct GF → algebraic solution → extract coefficients → closed-form formula
- Small-case automatic verification: manual enumeration for n = 0, 1, 2, 3 compared against the formula to ensure counting correctness

## Reasoning Protocol

1. **Identify the discrete structure**: Clarify the objects being counted, the constraints, and the classification scheme (ordered / unordered, labeled / unlabeled)
2. **Select a counting principle**: Multiplication / addition / pigeonhole / inclusion-exclusion — chosen according to the independence and interaction of constraints
3. **Construct a generating function** (if recurrences are involved): Recurrence → OGF / EGF → algebraic equation → solve
4. **Extract formulas or asymptotics**: Extract coefficients from the generating function to obtain a closed-form formula, or analyze asymptotic behavior
5. **Verify and generalize**: Compare manual enumeration of small cases against the formula; check boundary conditions (empty structure = 1); generalize to broader settings

## Acceptance Criteria

- The classification of counting objects is explicit (permutation / combination / partition, ordered / unordered)
- Constraint interactions have been handled (inclusion-exclusion corrects overcounting, complement corrects undercounting)
- A recurrence relation has been provided (if applicable), and a generating function constructed
- A closed-form formula or asymptotic expression has been extracted
- Manual enumeration for at least n = 0, 1, 2, 3 has been compared against the formula — unverified counts are not to be trusted
