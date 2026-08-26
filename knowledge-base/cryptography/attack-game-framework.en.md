# Attack-Game Framework

## Minimal Definition

An attack game is a probabilistic interaction between a challenger and an adversary that specifies a security goal, adversarial capabilities, and a winning event. Security usually means that every adversary within the stated resource class has negligible asymptotic advantage or an explicitly small concrete advantage.

**Do not confuse with the game lens (`../../lenses/game.en.md`)**: an attack game is not game theory — there is no payoff matrix, Nash equilibrium, or mechanism design; "game" is merely the naming tradition for "interactive experiment." Do not load this card for equilibrium/mechanism-design questions.

An encryption indistinguishability game is only one instance. Signatures, MACs, commitments, and zero knowledge use different oracles, restrictions, and winning conditions; they cannot all be forced into one “submit two messages and guess a bit” script.

## Core Formulas

- Two-experiment advantage:
  $$\operatorname{Adv}_A=\left|\Pr[A\text{ outputs }1\text{ in experiment }0]-\Pr[A\text{ outputs }1\text{ in experiment }1]\right|.$$
- Bit-guess games commonly use $|\Pr[b'=b]-1/2|$ or twice this quantity. Align conventions before comparing bounds.
- Difference lemma: if two games can diverge only after event `bad`,
  $$|\Pr[W_0]-\Pr[W_1]|\le \Pr[\mathsf{bad}].$$
- For $q$ uniform $n$-bit samples, the collision union bound is $q(q-1)/2^{n+1}$; $q^2/2^n$ is only an order-level shorthand.

## Applicable Problems

- Formalize IND-CPA/CCA, EUF-CMA, PRF, binding/hiding, and related properties.
- Specify encryption, decryption, signing, verification, random-oracle, or leakage interfaces.
- Check post-challenge restrictions, freshness, multi-user effects, and adaptive corruption.
- Rewrite a proof as a game sequence and track advantage loss at each transition.

## Cryptographic Construction and Cross-Domain Boundary

- AI security can borrow the discipline of explicitly defining the adversary, interface, budget, and winning event. It must not simply rename CPA/CCA as black-box/white-box attacks.
- Perturbation sets, data distributions, and error rates in ML are generally not negligible functions. Use task-appropriate risks or certified radii rather than mechanically requiring $\operatorname{negl}(n)$.
- Load cryptographic oracle details only when the AI construction actually uses a primitive or claims a cryptographic property.

## Implementation Considerations

- A game is a definition. Finite tests can find implementation deviations but cannot prove negligible advantage against every PPT adversary.
- Concrete-security reports should state the security parameter, queries, time/memory, user count, and all failure events.
- Randomness, state reset, challenge freshness, and forbidden-query logic must match between implementation and proof.

## Risks and Failure Conditions

- **Weak adversary model:** Missing interfaces, leakage, or adaptivity proves security in the wrong game.
- **Mixed advantage conventions:** $|p-1/2|$ and $2|p-1/2|$ differ by a factor of two.
- **Asymptotic/concrete confusion:** Negligibility does not itself establish sufficient strength at fixed parameters.
- **Incorrect challenge restrictions:** Too little restriction trivializes the game; too much inflates security.
- **Testing as proof:** Failure to find an attack is evidence only against the tested adversaries.

## Further References

- `../../references/books/applied-cryptography.md`
- `../../references/books/foundations-of-cryptography.md`
- `../../references/books/introduction-to-modern-cryptography.md`

## Routing Extensions

- Reductions: `reduction-proof-template.en.md`
- CPA/CCA/AE: `cca-cpa-ae-hierarchy.en.md`
- PRF: `prf-prg-owf.en.md`
- Probability bounds: `../probability/concentration-inequality.en.md`
