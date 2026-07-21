# Reduction-Proof Template

## Minimal Definition

A security reduction constructs an algorithm $B$ that uses a scheme-breaking adversary $A$ as a subroutine to solve a defined hard problem. The conclusion is conditional: if the assumption remains hard for the resulting resources, and the simulation and parameter bounds hold, then no adversary in the corresponding resource range can break the scheme.

## Core Formulas

A typical concrete-security bound is
$$
\operatorname{Adv}^{\mathsf{scheme}}(A)
\le L(q,n)\operatorname{Adv}^{\mathsf{assump}}(B)+\delta(q,n),
$$
where $L$ is reduction loss and $\delta$ collects collisions, simulation failures, and similar events. Report $B$'s running time and oracle queries as well as advantage.

- Difference lemma: if games diverge only after `bad`, their advantage difference is at most $\Pr[\mathsf{bad}]$.
- Hybrid: $|p_0-p_t|\le\sum_{i=0}^{t-1}|p_i-p_{i+1}|$; every step bound and the number of steps enter the final loss.
- Asymptotic closure $\operatorname{poly}\cdot\operatorname{negl}=\operatorname{negl}$ does not imply an acceptable fixed-parameter value.

## Applicable Problems

- Prove encryption, MAC, signature, or protocol security from PRF/PRP, OWF, DDH/LWE, or related assumptions.
- Check whether a reduction's simulation is perfect, statistically close, or computationally indistinguishable.
- Track loss from guessing, rewinding, hybrids, and forking.
- Compare standard-model, ROM/QROM, and black-box/non-black-box proof boundaries.

## Cryptographic Construction and Cross-Domain Boundary

- A reduction is not causal inference or an analogy between problems. It requires executable $B$, interface simulation, and a success-probability relation.
- AI robustness or watermarking warrants a cryptographic-reduction claim only after defining a security game, parameter, adversarial resources, and hard problem. Ordinary Lipschitz certificates, generalization bounds, and differential-privacy guarantees are not “cryptographic hardness assumptions.”
- Hybrid summation can analyze general distribution changes, but using that inequality alone does not create cryptographic security.
- A simulator that reproduces some output distribution does not by itself prove training-data privacy; it needs a formal indistinguishability/simulation definition or a formal DP bound.

## Implementation Considerations

- Specify how $B$ generates parameters, answers every query, embeds the challenge, handles aborts, and extracts a solution from $A$.
- Label every game hop as identical, statistically bounded, assumption-based, or bad-event-based.
- Substitute advantage, time, queries, users, and failure terms into concrete parameters; “polynomial loss” is not a numerical analysis.
- GPU performance is orthogonal to reduction validity. Analyze it separately only for a concrete primitive implementation.

## Risks and Failure Conditions

- **Wrong direction:** “Solving the assumption enables an attack” usually does not prove “an attack solves the assumption.”
- **Unproved simulation:** If $A$ distinguishes the simulated view from the real game, its claimed advantage cannot be reused.
- **Missing tightness/resources:** Small advantage loss can coexist with impractical time or query overhead.
- **Model mismatch:** ROM/QROM, selective/adaptive, and single-/multi-user models cannot be switched silently.
- **Uncounted abort/guessing:** Guessing an index or conditional abort can dominate the loss.
- **Existence versus parameters:** An asymptotic reduction does not establish that the current key size is sufficient.

## Further References

- `../../references/books/foundations-of-cryptography.md`
- `../../references/books/applied-cryptography.md`
- `../../references/books/introduction-to-modern-cryptography.md`

## Routing Extensions

- Games: `attack-game-framework.en.md`
- PRF/OWF: `prf-prg-owf.en.md`
- CPA/CCA/AE: `cca-cpa-ae-hierarchy.en.md`
