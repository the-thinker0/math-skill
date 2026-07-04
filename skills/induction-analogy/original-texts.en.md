# Mathematical Sources and Classic Texts

## Mathematical Induction (Pascal, 1654)

**Principle**:
> If P(1) holds and P(n) -> P(n+1), then P(n) holds for all positive integers n.

**Philosophical implication**: Deriving the "infinite" from the "finite" -- requiring only a base case and an inductive step.

**Classic examples**: 1+2+...+n = n(n+1)/2; Fibonacci properties; proofs in graph theory

## Strong (Complete) Induction

> If P(1)...P(k) all holding implies P(k+1), then P(n) holds for all positive integers n.

**Applicable scenarios**: When P(k+1) depends on many or even all preceding propositions, not just P(k).

**Examples**: Unique factorization theorem; Fibonacci recurrence F(n)=F(n-1)+F(n-2); Fundamental Theorem of Arithmetic

## Structural Induction

> For recursively defined structures (lists, trees, expressions): prove the property holds for base elements and is preserved under construction steps, then it holds for all instances.

**Applications in computer science**: Compiler correctness; type system safety (well-typed programs do not crash); data structure invariants (red-black tree balance); algorithm termination proofs

**Examples**: |L1 ++ L2| = |L1| + |L2|; tree height <= number of nodes

## Transfinite Induction (Cantor Ordinals)

> If P(gamma) for all gamma < beta implies P(beta), then P(alpha) holds for all ordinals alpha.

**Significance**: Induction extends beyond the natural numbers -- it applies to any well-ordered set.

**Key concepts**: Cantor ordinals omega, omega+1, omega*2, omega^2, omega^omega...; equivalence with Zorn's lemma; application: proving that every vector space has a basis

## Well-Ordering Principle

> Every nonempty subset of the natural numbers has a least element; logically equivalent to mathematical induction.

**Equivalence proofs**: Well-ordering implies induction: the set of counterexamples has a least element m, so P(m-1) holds while P(m) does not -- contradiction. Induction implies well-ordering: use induction to prove that every nonempty subset contains a least element.

**Generalization**: The Well-Ordering Theorem (Zermelo 1904) -- every set can be well-ordered; equivalent to the Axiom of Choice.

## Polya's *Mathematics and Plausible Reasoning* (1954)

> "Induction, analogy, specialization, generalization -- principal methods of discovering mathematical truths."

**Inductive pattern**: 1. Observe cases -> 2. Discover patterns -> 3. Formulate conjectures -> 4. Verify (prove or disprove)

## Mathematical Status of Analogy

> "Analogy is a tool for discovery, not for proof."

**Classic analogies**: Sound waves -> wave theory of light; Planetary orbits -> Bohr atomic model; Water flow -> electric current (voltage analogous to water pressure)

## Euler and the Basel Problem (1735)

> Euler discovered Sum(1/n^2) = pi^2/6 by inductive reasoning -- the most celebrated inductive discovery in mathematics.

**Inductive process**: Computed partial sums approximately 1.6449 -> recognized pi^2/6 -> drew an analogy between the infinite product of sin(x) and the root-coefficient relations of polynomials -> rigorous proof. Polya specifically used this to illustrate "plausible reasoning."

## Fermi Estimation

> Solve unknowns via analogy and order-of-magnitude estimation.

**Classic problem**: "How many piano tuners are there in Chicago?" Population ~3 million -> ~1 million households -> 1/20 own pianos -> ~50,000 pianos -> tuned once per year, 2 hours each -> tuner works 2000 hours/year -> approximately 50 tuners.

**Value**: Reasonable analogical estimates yield order-of-magnitude correct results.

## Mill's Five Methods (1843)

> Mill systematized inductive reasoning in *A System of Logic*.

1. **Method of Agreement**: Multiple instances share only one common circumstance -> that circumstance is likely the cause
2. **Method of Difference**: Two instances differ in only one circumstance -> that difference is likely the cause
3. **Joint Method**: Combining agreement and difference to strengthen credibility
4. **Method of Concomitant Variations**: A phenomenon varies as a certain circumstance varies -> causal relationship
5. **Method of Residues**: After subtracting the effects of known causes, remaining effects are explained by remaining causes

## Ramanujan: Intuitive Induction (1887-1920)

> Ramanujan discovered formulas via astonishing pattern recognition, often without formal proof -- a genius of intuitive induction.

**Examples**: Series for 1/pi extrapolated from a few terms to general form; mock theta functions (pattern described, proof delayed by decades). Hardy: "His intuition was almost supernatural, yet logical rigor was often lacking."

**Lesson**: Inductive discovery can far outpace proof -- the tension between intuition and rigor is a driving force of mathematical progress.

## Borwein Integrals: A Cautionary Tale (2000s)

> A pattern holds for many terms then suddenly breaks -- a profound warning about inductive reasoning.

**Phenomenon**: Integral of sin(x)/x dx = pi/2; adding sin(x/3) still gives pi/2; ... continues through sin(x/13); but upon adding sin(x/15) it suddenly deviates! Mathematical root cause: the Patel-Vitali condition.

**Lesson**: The first N cases may hold while case N+1 breaks the pattern. Inductive conclusions require theoretical support and cannot rely solely on empirical evidence.

## Lakatos's *Proofs and Refutations* (1963/1976)

> Mathematical discovery evolves through counterexamples, monster-barring, and lemma-incorporation -- not a linear "conjecture -> proof" process.

**Core concepts**: Monster-barring (modifying definitions to exclude counterexamples); Lemma-incorporation (adding the conditions of counterexamples to the premises); Concept-stretching (counterexamples driving the expansion of concepts)

**Example**: The proof history of Euler's polyhedron formula V-E+F=2 -- from Cauchy's naive proof to successive corrections for holes and tunnels.

## Hume's Problem of Induction (1739)

> "The sun has risen every day in the past; this does not logically guarantee it will rise tomorrow."

**Fundamental flaw**: Deriving the infinite from the finite always carries uncertainty.

**Scientific method's response**: Induction produces hypotheses (not theorems) -> falsifiable (Popper) -> continuously tested -> counterexamples lead to revision or abandonment

## Carnap's Inductive Logic (1950s)

> Carnap attempted to formalize and quantify inductive reasoning -- a logical foundation for inductive probability.

**Core idea**: Confirmation function c(h,e) -- the degree to which evidence e confirms hypothesis h. Inductive logic should have rigorous rules; prior probabilities should be based on logical symmetry rather than subjective belief.

**Limitations**: The system is highly sensitive to the linguistic framework -- different predicate sets yield different degrees of confirmation; Goodman's "grue paradox" further reveals the difficulties.

## Problem of Underdetermination

> Multiple analogies or theories can equally fit the same data -- data underdetermines theory choice.

**Mathematical analogy**: Finitely many data points can be fit by infinitely many functions; multiple inductive hypotheses may be simultaneously consistent with experience; theory choice requires additional criteria: simplicity, explanatory power, predictive power.

**Philosophical roots**: The Quine-Duhem thesis -- any hypothesis can be shielded from falsification by adjusting auxiliary hypotheses.

## Machine Learning as Induction

> Machine learning is the engineering of inductive reasoning -- inferring general rules from data.

**Statistical learning theory**: PAC learning (Valiant 1984) -- outputting a hypothesis with low error with high probability; generalization bounds -- the quantitative relationship between sample complexity and hypothesis class complexity; VC dimension -- a mathematical measure of "inductive capacity."

**Contrast with mathematical induction**: Mathematical induction = deterministic reasoning over an infinite domain; statistical induction = probabilistic reasoning from finite samples; generalization = the inductive leap

## Power and Limits of Analogy

**Power**: Transferring knowledge across domains (one of the most important sources of innovation); converting the unknown into the known; generating new ideas and hypotheses

**Limits**: Analogy is not proof -- conclusions require independent verification; surface similarity does not imply structural similarity; every analogy has a breaking point -- two domains can never be perfectly isomorphic
