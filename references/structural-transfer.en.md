# Discover Cross-Domain Mathematical Ideas from Structural Gaps

Read this when the user asks for inspiration across fields, different mathematical directions, or ideas beyond existing approaches. The aim is to find structural correspondences that change a research judgment, rather than rename an existing module. Start generation from relationships in the problem. Once a mapping is selected, consult existing design patterns as baselines and implementation references. The [design workbench](design-workbench.en.md) helps instantiate a mechanism afterward; it is not a required step for every theoretical insight.

## Let the Task's Relationships Determine Where to Look

Remove model and module names, and retain a relationship missing from the current approach. For example, “combine multiple experts” can be unpacked into: individual observations are insufficient; joint information may help; and transmitting only predictions may already discard information that cannot be recovered. These relationships can lead to statistical sufficiency, function spaces, and projections. The original phrase alone may merely retrieve a routing template.

Select the clues needed to address the user's actual tension: which operations should commute or preserve something; which local results must be compatible; where information is discarded; and which quantities must be additive, composable, or bounded. Propose mathematical formulations even when the user has supplied no mathematical names. When the formulation is already clear, do not reinvent the requirements.

Follow relationships to new formulations, rather than restricting the search to a predetermined list of fields:

| Possible bridge | Specific relationship to verify |
|---|---|
| Different languages for the same structure | For example, observable information corresponds to a space of measurable functions. Do operations, objectives, and quantifiers match on both sides? |
| Duality or certificates | Can a feasibility or optimization problem be reformulated through a certificate, prices, or a separation condition? Are conditions such as strong duality satisfied? |
| Quotients and lifts | After removing symmetry, can a representative be selected stably? If not, should the representation retain orbits, fibers, or a distribution over multiple solutions? |
| Local to global | Is local consistency sufficient? Which global obstructions escape the local checks? |
| Limits or discretization | Can a continuous or discrete formulation yield a new algorithm? Can limits, approximations, and the order of operations be interchanged? |

These are ways to seek relationships, not five mandatory tools. Follow definitions, equivalent formulations, theorem assumptions, and references in primary sources into fields not covered by the skill. The 15 lenses, 41 anchors, 22 patterns, and five construction moves do not bound the search. Prioritize verifying the proposition that determines whether a bridge holds, rather than reviewing an entire book or field.

## Provide a Real Structural Correspondence

Every transfer worth recommending must explain:

- What the task's objects, relationships, or loss correspond to in the source mathematics, and which information and operations are preserved.
- The precise assumptions of the proposition used, and the equation, inequality, impossibility result, or executable operation obtained when translating it back to the task.
- Whether the correspondence is an exact equivalence, a sufficient condition, an approximation with an error bound, or an analogy that remains unproved. These cannot substitute for one another.

Work through at least one key derivation. If all that remains is “like a manifold,” “like a layer,” or “like a game,” with no relationship into which objects can be substituted and checked, continue investigating the gap or retain it as a low-confidence association. Naming a learned tensor does not make it satisfy axioms. Introducing an unavailable oracle into a simulator is not a valid reduction either.

Impossibility, non-identifiability, and insufficient information are valuable findings. They may show that the representation must change, observations must increase, the objective must be relaxed, or multiple solutions must be retained. Do not bypass these conclusions just to deliver a “new module.”

## Select for Research Value, Not Mathematical Names

When the user wants several directions, retain candidates that differ in their information interfaces, mechanisms, guarantees, or research questions. Two differently named weighted averages, or two losses differing only in a regularization coefficient, do not constitute two cross-domain routes.

For each candidate, find a small family of inputs on which it and the current baseline would behave differently, and a control where the transfer offers no benefit or its assumptions fail. Explain which mathematical relationship causes the difference and what it costs. Observable value may include stronger representation, lower computation or sample cost, a more reliable guarantee, or ruling out an impossible research direction. It need not take the form of GPU acceleration.

Do not recommend a candidate as the main direction when its required observations are unavailable, its assumptions have no implementation, or its cost exceeds hard constraints. A known mathematical transfer can have engineering value. A claim of research novelty requires a search for the closest work in the target field, distinguishing what is already known, what has been derived here, and what remains an untested transfer. Do not write “first” without that search.

Lead the delivery with the idea worth trying and what it changes, then give the object mapping, key derivation, sources, and smallest distinguishing experiment. There is no need to reproduce this document's workflow as an output template. When the user wants directions only, do not expand the request into a full implementation project.

## A Complete Bridge: Combining Information Is Not Averaging Predictions

**Task gap:** each expert observes only part of the information. How can complementary information be used? First distinguish “combining existing predictions” from “allowing access to joint information.”

**Probability → functional analysis:** for real-valued $Y\in L^2(\Omega,\mathcal F,P)$ and a sub-$\sigma$-algebra $\mathcal G$, $P_{\mathcal G}Y=\mathbb E[Y\mid\mathcal G]$ is the orthogonal projection onto the closed subspace $L^2(\mathcal G)$. Thus, for $f\in L^2(\mathcal G)$,

$$\mathbb E(Y-f)^2=\mathbb E(Y-P_{\mathcal G}Y)^2+\mathbb E(P_{\mathcal G}Y-f)^2.$$

This correspondence turns “information that may be observed” into “the space of prediction functions that can be expressed.” An ordinary expert obtained through finite training does not automatically equal this Bayes projection. [Pitman, STAT205, Section 10.2.3](https://www.stat.berkeley.edu/~pitman/s205f02/lecture15.pdf)

**The boundary revealed when translating back to AI:** let $X_1,X_2$ be independent Bernoulli$(1/2)$ variables, and let $Y=X_1\operatorname{XOR}X_2$. Both optimal single-view experts output $1/2$. Any normalized weighted average is still $1/2$, with MSE $1/4$. Joint observations allow perfect prediction through $Y=X_1+X_2-2X_1X_2$.

Combining information into $\sigma(X_1)\vee\sigma(X_2)$ therefore differs from averaging predictions based on the two individual information spaces. **The resulting opportunity** is to change the information interface between experts, preserving useful branch information and allowing interactions. Adjusting prediction weights alone cannot solve this counterexample. If the original information is no longer accessible, report the information shortfall. Use XOR and an additive target to compare “transmit predictions only” with “allow joint information.” This does not imply that all expert averaging is ineffective.

For more examples of real structural correspondences and counterexamples, see [transfer bridges](transfer-bridges.en.md): covering spaces to representations of multiple solutions, and local consistency to error-correcting distance. Read them when needed to assess the quality of a transfer; do not treat the examples as fixed recommendations.
