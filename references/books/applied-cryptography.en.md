# Applied Cryptography

> Dan Boneh and Victor Shoup, *A Graduate Course in Applied Cryptography* (v0.4, 2017). A graduate-level reference organized around **attack games and reduction proofs**—a practical guide to constructions, reductions, and protocol analysis.

## Overview

The book treats cryptography as the mathematical study of adversarial systems. Security is defined by a formal **attack game** between a challenger and an adversary: a scheme is secure when no efficient adversary wins with non-negligible advantage. Its proofs are reductions: an attack on scheme Y is transformed into an algorithm for solving hard problem X.

**Activation boundary:** This is a construction-and-proof reference, not an implementation manual. Side channels, constant-time code, and protocol state machines require implementation-focused material as well. Use this distillation to locate security definitions, reduction patterns, and common proof failures.

## Core Structures and Cross-Domain Boundaries

| Cryptographic structure | What transfers—and what does not |
|---|---|
| **Attack games (§2)** | Formalize the adversary, interface, and winning event. This discipline can inform ML threat modeling, but cryptographic game names and negligible advantage do not transfer automatically. |
| **Reduction template (§3)** | “Break my scheme ⇒ solve a hard problem”; makes security relative to explicit assumptions. |
| **Sequences of games and Difference Lemma (§3.4–3.5)** | Decompose a proof into bounded transitions; the probabilistic form of hybrid reasoning. |
| **CPA/CCA/AE hierarchy (§4)** | Hierarchy of encryption-oracle capabilities; not equivalent to black-box, white-box, or gradient access in ML. |
| **PRG/PRF/PRP constructions (§5, §14)** | Constructions and reductions among cryptographic primitives. Similarity to boosting is only structural and does not transfer a proof. |
| **DDH/CDH/DL assumptions (§6)** | A concrete example of carefully ordering and minimizing assumptions. |
| **Encrypt-then-MAC composition (§7.9, §9.2)** | Composition does not preserve security automatically; independent keys and context binding matter. |
| **Sigma protocols and Fiat–Shamir (§11)** | Commitment–challenge–response, underlying Schnorr-style signatures and many noninteractive proof constructions. |
| **AKE and forward secrecy (§12)** | Formal treatment of session-key security and compromise models. |
| **Reduction tightness (§10.3)** | If the loss scales with a query factor Q, parameters must compensate for it. |

**Activation families:**

- **Definitions (§2, §4):** attack games, semantic/CPA/CCA security, and authenticated encryption.
- **Reductions (§3, §16):** black-box wrappers, game sequences, hybrids, and simulation.
- **Primitives (§5, §14):** OWF, PRG, PRF, PRP, collision-resistant hashing, and trapdoor functions.
- **Protocols (§9, §11, §12):** public-key encryption, signatures, Sigma protocols, and authenticated key exchange.

## Key Facts

- **Align the advantage convention first (§2.2):** two-experiment differences, `|Pr[b'=b]-1/2|`, and twice that quantity all occur in the literature.
- **PPT and negligible functions (§2.3):** this is asymptotic language. `poly · negl = negl`, but that does not make an event practically impossible at a fixed parameter.
- **PRP switching:** for Q queries to an n-bit permutation/function interface, a common bound is on the order of `Q²/2^(n+1)`, subject to the exact advantage convention.
- **Perfect secrecy:** under the standard finite-space assumptions, Shannon's bound requires `|K| ≥ |M|`.
- **IND-CPA already permits repeated encryption-oracle queries:** single- and multi-challenge formulations are commonly related by hybrids under matching randomness and message restrictions.
- **Encrypt-then-MAC has broad composition theorems:** security of MAC-then-encrypt or encrypt-and-MAC depends on the concrete encoding, primitives, and error leakage; neither should be rejected by slogan alone.
- **Authenticated encryption combines confidentiality and ciphertext integrity:** exact implications depend on the selected games.
- **Random self-reducibility of discrete logarithm:** an algorithm for random instances can be converted to one for arbitrary instances in the same group setting.
- **ROM reductions may lose a hash-query factor:** concrete parameters must account for the actual loss.
- **Quantum threat model:** Shor affects factoring and discrete-log systems; Grover gives a generic square-root query improvement in an ideal black-box model, but concrete quantum resources require separate analysis.

## Suitable Questions

- Write a security game: what can the adversary query, and what counts as winning?
- Construct a reduction and check whether the simulation is faithful and tight.
- Review EtM/MtE/EaM composition, key separation, and transcript/identity binding.
- Convert reduction loss and query limits into concrete parameter requirements.
- Diagnose protocol failures involving identity binding, downgrade, reflection, nonce reuse, or key reuse.
- For AI×crypto work, transfer the discipline of explicit adversaries and interfaces; claim a cryptographic reduction only when a security parameter, hard problem, and executable reduction are actually defined.

## Possible Design Inspiration

1. **Adversarial modeling:** use an attack-game structure to specify an ML robustness goal, without inheriting cryptographic guarantees by analogy.
2. **PRF as a keyed pseudorandom source:** useful for reproducible keyed seeds only under an explicit key-exposure and query model; implementations are normally not GEMMs.
3. **Sigma protocols to verifiable computation:** proof systems may make a computation independently checkable, but prover and verifier costs depend heavily on the system.
4. **Reduction discipline for cross-domain security:** ordinary robustness bounds are not cryptographic reductions.
5. **Commitments for artifact binding:** a commitment can bind a model digest, but does not by itself provide watermark robustness, ownership, or traceability.

## Implementation and GPU Boundary

Pure cryptography does not use the GPU checklist as a security gate. When implementation performance is requested, inspect only the relevant dimensions in `../gpu-friendly-math.en.md`.

- AES and SHA implementations commonly use bit operations, SIMD, CPU ISA extensions, or dedicated GPU kernels. AES-NI and SHA extensions are CPU features; non-GEMM does not mean unaccelerated.
- RSA and other large-integer arithmetic use bigint kernels rather than ordinary tensor algebra.
- Elliptic-curve scalar multiplication uses finite-field and point operations, not standard GEMM.
- SNARK prover/verifier costs vary by system; common kernels include finite-field arithmetic, multiscalar multiplication, pairings, and hashes—not a generic GEMM.

Avoid treating AES/SHA as matrix multiplication, putting cryptographic primitives into a hot training loop without measurement, or using a nondifferentiable cryptographic hash as an ML loss.

## Relevant Thinking Lenses

- **`game`:** attack games, multi-party interaction, and adversarial strategy.
- **`axiomatization`:** security definitions and explicit assumptions.
- **`algorithmic`:** a reduction as an algorithm transformation; resource accounting.
- **`probabilistic`:** advantage, negligible functions, birthday bounds, and hybrids.
- **`duality`:** information-theoretic vs computational security; adversary vs simulator.
- **`categorical`:** implication relations among primitives, used carefully as a partial order of constructions.

## Anti-Patterns

- Treating a random-oracle-model proof as an absolute standard-model guarantee.
- Confusing necessary with sufficient conditions, such as equating key-space size with security.
- Equating resistance to key recovery with message security.
- Reusing one key across encryption and MAC without a composition theorem.
- Claiming deterministic public-key encryption is IND-CPA secure.
- Reusing IVs or nonces in stream ciphers, CTR, or GCM.
- Comparing MACs with early-exit code that leaks timing.
- Ignoring a large reduction loss in a concrete-security claim.
- Signing an ephemeral key without binding identities and transcript context.

## Deep-Dive Entry

> Dan Boneh and Victor Shoup, *A Graduate Course in Applied Cryptography*, v0.4, September 2017. Online: https://toc.cryptobook.us/
>
> Place `Applied Cryptography.pdf` under `math_book/` for targeted local full-text lookup.

Useful chapters:

- **§2:** attack-game framework.
- **§3:** reductions and sequences of games.
- **§4:** perfect, semantic, CPA, CCA, and authenticated-encryption notions.
- **§5:** PRG/PRF/PRP and switching bounds.
- **§6:** DL/CDH/DDH and random self-reducibility.
- **§7:** symmetric constructions and composition.
- **§11:** Sigma protocols and Fiat–Shamir.
- **§12:** authenticated key exchange, forward secrecy, and PAKE.
- **§13:** attack patterns and protocol failures.
- **§16:** reusable reasoning patterns for reductions and games.
