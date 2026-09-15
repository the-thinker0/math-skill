# Foundations of Cryptography

Oded Goldreich, *Foundations of Cryptography, Volume 1: Basic Tools*, Cambridge University Press, 2001, ISBN 978-0-521-79172-4. [Author contents, errata, and draft](https://www.wisdom.weizmann.ac.il/~oded/foc-vol1.html) (checked 2026-09-07).

## When to read

Use for primitive existence, quantifiers, security definitions, and constructive reductions. **Volume 1 has Chapters 1–4**, plus appendices. Old references to Chapters 5/6/7/9 or Roman-numbered “original parts” were incorrect. Systematic encryption, signature, and protocol treatment belongs to Volume 2.

## Verified routes

| Question | Volume 1 location |
|---|---|
| Probability and computation models | §§1.2–1.3 |
| Strong/weak OWFs and amplification | §§2.2–2.3 |
| Hard-core predicates | §2.5 |
| Pseudorandom generation and constructions | Chapter 3, especially §§3.2–3.4 |
| Pseudorandom functions | §3.6 |
| Zero-knowledge definitions and NP constructions | §§4.2–4.4 |

## Definition and reduction checks

- Specify input distribution, security parameter, uniform/nonuniform adversary, auxiliary input, and resources. A difficult learning objective is not automatically an average-case OWF.
- OWF/PRG/PRF existence has equivalence results under standard definitions, but construction efficiency is not equivalent; do not declare every GGM use impractical.
- A PRG can be statistically far from uniform yet computationally indistinguishable. Failure to train one discriminator proves nothing about all efficient distinguishers.
- Multisample hybrids need the relevant independent efficient sampling assumptions. OWF amplification may use independent inputs, but a shared attacker's success events cannot simply be multiplied as independent.
- Next-bit characterizations concern binary ensembles and specified computation models, not raw natural-language next-token accuracy.

## Simulation and transfer boundaries

Check verifier/simulator quantifiers, auxiliary input, runtime type, and statistical/computational distance. HVZK does not automatically cover malicious verifiers; parallel/concurrent composition depends on the protocol and definition. Zero knowledge or the mere existence of a simulator does not imply differential privacy.

Use `axiomatization`, `probabilistic`, or `algorithmic` lenses as needed for definitions/reductions, without loading every lens or the GPU checklist. ML transfer requires a new experiment and functional constraints before reusing a theorem.

## Source lookup

Start with the [PRF/PRG/OWF anchor](../../knowledge-base/cryptography/prf-prg-owf.en.md) and [reduction template](../../knowledge-base/cryptography/reduction-proof-template.en.md). For metatheorems or proofs, locate the original text through the author's contents, record the actual edition/section, and leave inaccessible claims unverified.
