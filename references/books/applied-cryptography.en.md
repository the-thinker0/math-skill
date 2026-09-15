# Applied Cryptography

Dan Boneh and Victor Shoup, *A Graduate Course in Applied Cryptography*. This index uses the author's public **v0.6 (January 2023)** contents; do not reuse page numbers from other versions. [Author site and editions](https://toc.cryptobook.us/) (checked 2026-09-07).

## When to read

Use when the four [crypto anchors](../../knowledge-base/cryptography/index.en.md) do not support a construction, attack model, or reduction. The book provides definitions and proofs, not automatic deployment certification. Attack games are probabilistic experiments, not Nash-equilibrium problems.

## Verified chapter routes

| Question | v0.6 chapters | Check |
|---|---|---|
| Perfect/computational confidentiality | 2 | Success probability versus advantage over a baseline |
| Stream/block primitives and CPA | 3–5 | Interfaces, queries, and randomness |
| MACs and generic composition | 6–9 | Freshness, message domain, and AE game |
| Public-key confidentiality and CCA | 11–12 | Decryption restrictions and challenge embedding |
| Signatures, number theory, lattices | 13–17 | Assumptions, models, and parameter loss |
| Sigma, zero knowledge, key exchange | 19–21 | Verifier type, sessions, identity binding |
| Threshold and multiparty computation | 22–23 | Corruptions, thresholds, composition |

## Preserve concrete quantities

For $\Pr[\mathrm{Break}_S(A)]\le c\operatorname{Adv}_P(B)+\delta+p_0$, explain the reduction factor, simulation bias, ideal baseline, and reduction runtime/queries. These come from the actual proof; arbitrary reductions do not automatically lose the query count.

The forward-oracle PRP/random-function switching bound uses the same finite domain/range, with collision bound $q(q-1)/2^{n+1}$ for $q$ queries on $n$-bit blocks. It does not directly cover two-way permutation access; a concrete AES PRP assumption is additional.

In classical prime-order groups, a DL solver gives CDH and a CDH solver gives DDH. Hardness implications therefore reverse the solver direction: DDH hardness is the stronger assumption.

## Composition and implementation boundaries

- Generic EtM results require the stated encryption/MAC properties, key separation, and authenticated scope. MtE/EaM must be assessed for the actual construction.
- Nonce uniqueness, unpredictable IVs, and key rotation are different requirements.
- Sigma protocols are not automatically SNARKs; Fiat–Shamir, knowledge soundness, succinctness, and quantum oracle access need separate conditions.
- Security reviews have no GPU gate. Performance work measures actual field/hash/cipher kernels; GEMM form says nothing about security.

## Transfer and source lookup

The [PRF-to-MAC example](../worked-examples/security-reduction.en.md) gives a direct reduction without an extra query-count loss. AI watermarking needs new ownership/removal/forgery games and functional constraints; the MAC proof does not transfer automatically.

Locate original text through verified chapters and the author's edition when local PDFs are absent. Read exact theorems/constants before citing them; this index is not a theorem-by-theorem certification.
