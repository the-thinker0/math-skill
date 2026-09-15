# Introduction to Modern Cryptography

Jonathan Katz and Yehuda Lindell, *Introduction to Modern Cryptography*, 2nd edition, CRC Press, 2015, ISBN 978-1-4665-7026-9. This index retains the second edition; the [author page](https://www.cs.umd.edu/~jkatz/imc2.html) links to the third edition separately. Do not mix chapter numbering. The [second-edition contents](https://www.cs.umd.edu/~jkatz/imc/toc-preface.pdf) were checked on 2026-09-07.

## When to read

Use to formalize security goals and examine primitive composition, assumptions, and reductions. Start with [attack games](../../knowledge-base/cryptography/attack-game-framework.en.md) and [encryption notions](../../knowledge-base/cryptography/cca-cpa-ae-hierarchy.en.md); consult the book for constructions or original details.

## Verified routes

| Question | Second-edition location |
|---|---|
| Definitions, assumptions, proof methodology | §1.4 |
| Perfect confidentiality and OTP | Chapter 2 |
| Computational security and reductions | §§3.1–3.3 |
| Multiple encryptions, CPA, PRF constructions | §§3.4–3.5 |
| Modes, CCA, padding oracles | §§3.6–3.7 |
| MAC definitions, domain extension, CBC-MAC | §§4.2–4.4 |
| AE and generic composition | §4.5 |
| Hashing, HMAC, ROM | §§5.1–5.5 |
| Theoretical symmetric primitives | Chapter 7 |

## Common boundaries

- Perfect secrecy is information theoretic; computational security includes adversary resources and a security parameter. A large key space alone is insufficient.
- CPA, CCA, and ciphertext integrity are different experiments. Anyone can create public-key ciphertexts, so shared-key AE integrity cannot transfer unchanged.
- Basic CBC-MAC has message-length conditions. Variable-length messages need a proved domain extension, not arbitrary concatenation.
- Collision resistance, preimage resistance, PRFs, and random oracles are distinct. ROM theorems hold in an ideal model; concrete hash instantiation does not automatically preserve them.
- Deterministic public-key encryption leaks message comparability/equality. Restricted deterministic settings need explicit message distributions and goals.

## From review to correction

Write oracles, challenge restrictions, freshness, winning events, and advantage convention. Construct each simulation step and label its justification: identical distributions, computational indistinguishability, or a bad-event probability bound. Evaluate runtime, queries, and tag/block lengths in the final bound; do not invent birthday or query-factor losses.

The [PRF-to-MAC example](../worked-examples/security-reduction.en.md) supplies a complete minimal reduction. AI robustness certificates normally remain AI mathematics; cross-domain transfer requires actual cryptographic primitives or security experiments.

## Implementation and lookup

Historical algorithms discussed in a textbook are not current deployment recommendations. For implementations, verify official specifications and actual versions separately; pure proofs have no GPU gate. Retrieve exact constants, theorem numbers, and newer-edition material rather than guessing from this index.
