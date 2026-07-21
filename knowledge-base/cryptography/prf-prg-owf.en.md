# One-Way Functions, Pseudorandom Generators, and Pseudorandom Functions

## Minimal Definition

- **One-way function (OWF):** Efficiently computable, while every probabilistic polynomial-time (PPT) algorithm finds any preimage of the image of a random input with only negligible probability.
- **Pseudorandom generator (PRG):** A deterministic polynomial-time map $G:\{0,1\}^n\to\{0,1\}^{\ell(n)}$, $\ell(n)>n$, such that $G(U_n)$ and $U_{\ell(n)}$ are computationally indistinguishable to every PPT distinguisher.
- **Pseudorandom function family (PRF):** An efficient keyed family $F_k:\mathcal X\to\mathcal Y$ whose oracle is computationally indistinguishable from a uniformly sampled random function $\mathcal X\to\mathcal Y$ for every PPT oracle distinguisher.

These are asymptotic definitions for families indexed by a growing security parameter, not unconditional claims about one fixed-parameter implementation.

## Core Formulas

- OWF: for every PPT $A$,
  $$\Pr_{x\leftarrow U_n}\left[f(A(1^n,f(x)))=f(x)\right]\le \operatorname{negl}(n).$$
- PRG advantage:
  $$\operatorname{Adv}^{\rm prg}_{G}(D)=\left|\Pr[D(G(U_n))=1]-\Pr[D(U_{\ell(n)}))=1]\right|.$$
- PRF advantage:
  $$\operatorname{Adv}^{\rm prf}_{F}(A)=\left|\Pr_{k}[A^{F_k}=1]-\Pr_{R}[A^{R}=1]\right|.$$
- Existence relations: OWFs exist iff PRGs exist; GGM constructs a PRF from a PRG. A PRF yields a PRP through Feistel: the classical Luby--Rackoff results give a PRP against forward queries with three rounds and a strong PRP against forward and inverse queries with four rounds, with concrete bounds depending on query count and block length.
- PRP/random-function switching bounds have birthday order $O(q^2/2^n)$. Exact constants depend on the game and inverse-query access, so there is no context-free unique formula.

## Applicable Problems

- Decide whether a keyed construction satisfies the PRF definition and write its real/random oracle game.
- Analyze GGM-like constructions or PRF-based encryption/MAC constructions through hybrids.
- Separate standard-model existence theorems, primitive-based reductions, and concrete assumptions that treat AES/HMAC as PRFs.
- Account for birthday loss, key/domain separation, and multi-user security.

## Cryptographic Construction and Cross-Domain Boundary

- Practical systems normally use analyzed candidates or standardized constructions such as HMAC, CMAC/KMAC, or block-cipher-based modes, rather than directly implementing generic HILL/GGM existence constructions.
- In AI×crypto tasks, a PRF can provide keyed reproducible pseudorandomness, but only relative to a stated oracle and leakage model. Parameters, gradients, logs, or distributed training may reveal key-related information outside the original game.
- An OWF does not automatically make hashed features private; input distributions, auxiliary information, collisions, and membership inference need separate models.
- Yao's next-bit characterization concerns binary distribution ensembles and efficient predictors. Without defining encoding, conditional distributions, and a security parameter, it does not imply “hard next-token prediction makes an entire language-model output pseudorandom.”

## Implementation Considerations

- PRFs are normally implemented with bit operations, permutations, hash/compression functions, or dedicated cryptographic instructions, not “small GEMMs.” AES-NI and SHA-NI are CPU ISA features and are not evidence of GPU feasibility.
- Nonces, counters, domain tags, and derived subkeys must satisfy the protocol's uniqueness and separation requirements. Reusing one PRF without domain separation can invalidate independence assumptions.
- If GPU throughput is explicitly requested, analyze the concrete implementation's batching, memory access, and side channels. Performance analysis does not replace a security proof.
- State the quantum query model. Grover gives a square-root improvement in ideal black-box query complexity, but concrete strength also depends on circuit depth, parallel resources, and the attack model; “halve the key bits” is not a complete assessment.

## Risks and Failure Conditions

- **Treating a concrete primitive as a theorem:** AES/HMAC PRF behavior is an adopted concrete-security assumption supported by analysis, not an unconditional theorem derived from the specification.
- **Ignoring query and multi-user loss:** Query count, user count, and message length may amplify advantage through birthdays or hybrid steps.
- **Confusing unpredictability and indistinguishability:** Their equivalence needs precise definitions and reductions; empirical prediction accuracy is not a cryptographic advantage.
- **Treating generic constructions as engineering recipes:** HILL/GGM establish existence and reductions, not acceptable constants, parallelism, or throughput.
- **Cross-domain model mismatch:** Side information, distribution shift, and adaptive ML queries may exceed the original security game.

## Further References

- `../../references/books/foundations-of-cryptography.md`: OWF/PRG theory and GGM.
- `../../references/books/applied-cryptography.md`: PRF/PRP games and switching arguments.
- `../../references/books/introduction-to-modern-cryptography.md`: formal definitions and Feistel.

## Routing Extensions

- Reductions: `reduction-proof-template.en.md`
- Games: `attack-game-framework.en.md`
- CPA/CCA/AE: `cca-cpa-ae-hierarchy.en.md`
- Probability bounds: `../probability/concentration-inequality.en.md`
