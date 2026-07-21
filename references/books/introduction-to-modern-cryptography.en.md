# Introduction to Modern Cryptography

> Jonathan Katz and Yehuda Lindell, *Introduction to Modern Cryptography*, 2nd Edition, CRC Press, 2015. An introduction organized around three principles: **formal definitions, explicit assumptions, and security proofs**.

## Overview

Modern cryptography defines the adversary and failure event before selecting a construction. A proof is normally a reduction: an adversary that breaks the scheme yields an algorithm contradicting a stated assumption. Kerckhoffs's principle treats every system detail except the secret key as public.

**Activation boundary:** This book balances definitions and engineering-oriented construction patterns—EAV/CPA/CCA/AE notions, SPNs, Feistel networks, Merkle–Damgård, KEM/DEM, Fiat–Shamir, attack models, and implementation pitfalls. Use this distillation to choose a definition, construction family, and proof obligation; use current standards and implementation guidance for deployment decisions.

## Core Structures and Cross-Domain Boundaries

| Definition or construction | What transfers—and what does not |
|---|---|
| **Definition/assumption/proof discipline (§1)** | Formalize the threat, state assumptions, then prove a relative claim. |
| **Kerckhoffs's principle (§1.3)** | Design for public algorithms and secret keys. It is a design principle, not an automatic theorem about another system. |
| **Probability as the security language (§2.1)** | Random experiments, conditional probability, and leakage analysis. |
| **Asymptotic vs concrete security (§2.3)** | Asymptotics organize theory; deployment requires explicit resources and advantage. |
| **Entropy and min-entropy (§2.4)** | Min-entropy measures best one-shot guessing probability; the modeled distribution must be stated. |
| **Perfect secrecy (§3.1–3.2)** | Under standard finite-space assumptions, perfect secrecy imposes a key-space lower bound; computational security relaxes the adversary. |
| **CPA/CCA/AE families (§3.2–3.5)** | Different adversarial interfaces and encryption goals. Authenticated encryption combines confidentiality and ciphertext integrity; exact equivalences depend on definitions. |
| **MAC unforgeability (§3.4)** | Strong unforgeability, constant-time verification, and the fact that replay protection belongs to a protocol layer. |
| **Hash security and birthday bounds (§3.6)** | Collision, second-preimage, and preimage resistance are distinct notions. A generic collision attack on an ideal n-bit hash takes about `2^(n/2)` queries. |
| **Reduction template (§5)** | Build B around adversary A and account for simulation error and success loss. |
| **Hybrid arguments and game hopping (§5.3–5.4)** | Bound adjacent games and sum the losses; do not hide a large number of transitions. |
| **OWF/PRG/PRF existence relations (§6)** | Standard constructions and implication results, not production recommendations. |
| **Number-theoretic assumptions (§7)** | Reduction directions among factoring/RSA and DL/CDH/DDH must be stated precisely and depend on the group. |
| **SPN and Feistel constructions (§8.1–8.2)** | Confusion/diffusion and Feistel structure; the round function need not be invertible. |
| **Merkle–Damgård (§8.3)** | Lifts collision resistance from a compression function under stated padding; does not behave as a random oracle and permits length extension in common forms. |
| **KEM/DEM (§8.4)** | A KEM establishes key material and a DEM protects data. End-to-end security depends on matching definitions, KDF/context binding, and composition. |
| **Hash-and-sign and Fiat–Shamir (§8.5–8.6)** | Hash before signing; transform an interactive identification protocol only in a model and construction for which the proof applies. |
| **Random-oracle methodology (§9)** | Programmability and extraction can enable proofs; a ROM proof is not a standard-model proof. |

**Activation families:**

- **Definitions (§3):** EAV, CPA, CCA, AE, MAC unforgeability, and hash properties.
- **Proofs (§5):** reductions, distinguishers, hybrids, and game hopping.
- **Primitives (§6):** OWFs, hardcore predicates, PRGs, PRFs, and PRPs.
- **Assumptions (§7):** factoring/RSA and DL/CDH/DDH families.
- **Constructions (§8):** SPNs, Feistel, Merkle–Damgård, KEM/DEM, hash-and-sign, and Fiat–Shamir.

## Key Facts

- **Definition first:** without a game and adversary interface, “secure” has no testable meaning.
- **Shannon lower bound:** with the standard finite message/key spaces and correctness assumptions, perfect secrecy requires `|K| ≥ |M|`. OTP meets the bound, but this does not make it the only scheme in a literal structural sense.
- **Eavesdropping indistinguishability and semantic security:** standard formulations are equivalent under the appropriate setting and quantifiers.
- **Deterministic encryption is not IND-CPA secure** for ordinary nontrivial message spaces under the standard public-key or private-key games.
- **Multi-message IND-CPA security** is normally derived by a hybrid under the matching encryption definition and randomness/nonce conditions.
- **CCA security and non-malleability are closely related,** but the exact implication or equivalence depends on the selected definitions.
- **Encrypt-then-MAC is a robust generic route** when the encryption and MAC assumptions, independent keys, and verification order match the theorem. MtE/EaM require construction-specific analysis.
- **Birthday bound:** an ideal n-bit hash provides roughly n/2 bits of generic collision resistance.
- **OWFs, PRGs, and PRFs have deep existence relations;** AES is a block cipher and SHA is a hash family, not interchangeable “practical versions” of one primitive.
- **Goldreich–Levin:** the inner-product predicate is hardcore in the stated OWF construction.
- **PRP switching:** the bound scales quadratically with the number of queries and inversely with the permutation domain, up to convention-dependent constants.
- **Reduction directions matter:** solving DL generally gives CDH, and solving CDH gives a DDH decision procedure; factoring an RSA modulus enables RSA inversion, while the converse is not generally known.
- **Luby–Rackoff:** three Feistel rounds with suitable independent PRFs give a PRP under chosen-plaintext-style access; four rounds give a strong PRP under forward/inverse access.
- **KEM/DEM composition depends on the target notion:** CPA and CCA goals require compatible KEM/DEM definitions, derivation, and context binding.
- **ROM is useful but model-relative:** it is stronger than having no proof and weaker than a standard-model guarantee.

## Suitable Questions

- Which of CPA, CCA, ciphertext integrity, or AE matches the threat model?
- Which current standardized construction fits the required interface? Verify current recommendations externally before deployment.
- Is the reduction simulation correct, and what is its concrete loss?
- How do key/output length, birthday effects, quantum resources, and reduction loss affect parameters?
- Are comparisons constant-time, nonces unique, keys separated, and errors uniform?
- Is protocol context—identities, roles, transcript, version—cryptographically bound?
- In AI×crypto work, have the adversary interface, winning event, and assumptions been redefined? CPA/CCA cannot simply be renamed as black-box/white-box ML access.

## Possible Design Inspiration

1. **AES-CTR plus EtM as a composition case study:** illustrates separation of confidentiality and integrity, independent keys, and verify-before-decrypt discipline. AES-NI is a CPU feature, not evidence of GPU/GEMM suitability.
2. **KEM/DEM responsibility separation:** can inspire interface decomposition, but provides no automatic ML security or performance guarantee.
3. **Hash-and-sign and content addressing:** hashing maps arbitrary-length data to a fixed-length digest, useful for fingerprints and version binding subject to the chosen hash property.
4. **Fiat–Shamir and verifiable inference:** a noninteractive proof requires an actual proof-system construction and model; it is not obtained by naming a model output a proof.
5. **Random oracles remain formal cryptographic interfaces:** an ordinary ML black box is not an independent programmable random oracle.

## Implementation and GPU Boundary

Pure cryptographic security is not decided by GPU friendliness. For performance questions, inspect only the applicable dimensions in `../gpu-friendly-math.en.md`.

- AES and SHA-3 use bitwise/permutation operations, SIMD, dedicated instructions, or specialized kernels rather than ordinary GEMM. AES-NI and SHA extensions are CPU ISA features.
- RSA and ElGamal implementations use large-integer or finite-field arithmetic.
- Elliptic-curve scalar multiplication uses finite-field and point operations, not standard GEMM.
- DEM operations can often be batched but normally remain cryptographic kernels.
- Hashing can be parallelized; CPU and GPU use different implementation paths.

Avoid treating AES/SHA as GEMM, repeatedly invoking non-measured cryptographic kernels in a hot training loop, using a cryptographic hash as a differentiable loss, or treating a Merkle–Damgård hash as both a MAC and a random oracle.

## Relevant Thinking Lenses

- **`axiomatization`:** definition before construction and explicit assumptions.
- **`algorithmic`:** reductions as algorithms; complexity and iterative constructions.
- **`probabilistic`:** advantage, negligible functions, birthday bounds, and leakage experiments.
- **`duality`:** information-theoretic vs computational security; adversary vs simulator.
- **`symmetry`:** Feistel/SPN structure and group-based assumptions, without confusing visual symmetry with security.
- **`categorical`:** implication relations among primitives, with reduction direction stated.
- **`game`:** attack games and adversarial interfaces.
- **`perturbation`:** concrete reduction loss and parameter compensation.

## Anti-Patterns

- Claiming security without a definition.
- Replacing separate key-length, collision, second-preimage, and preimage requirements with an unconditional implication chain.
- Equating resistance to key recovery with encryption security.
- Reusing one key for encryption and MAC without a theorem supporting the composition.
- Using deterministic public-key encryption under an IND-CPA claim.
- Reusing CTR/GCM nonces; GCM nonce reuse can also compromise authentication.
- Using early-exit MAC comparison.
- Treating Merkle–Damgård as a random oracle or a raw MAC.
- Using textbook RSA signatures without a secure encoding such as PSS/FDH in the corresponding model.
- Reusing DSA/ECDSA nonces.

## Deep-Dive Entry

> Jonathan Katz and Yehuda Lindell, *Introduction to Modern Cryptography*, 2nd Edition, CRC Press, 2015. ISBN 978-1-4665-7026-1.
>
> Place `Introduction to Modern Cryptography.pdf` under `math_book/` for targeted local full-text lookup.

Useful sections:

- **§1:** modern-cryptography methodology and Kerckhoffs's principle.
- **§2:** probability, asymptotic/concrete security, and entropy.
- **§3:** perfect secrecy, EAV/CPA/CCA, MACs, AE, and hash properties.
- **§4:** computational indistinguishability and experiment syntax.
- **§5:** reductions, hybrids, and game hopping.
- **§6:** OWFs, hardcore predicates, PRGs, PRFs/PRPs, and switching bounds.
- **§7:** factoring/RSA, DL/CDH/DDH, CRT, and group selection.
- **§8:** SPN, Feistel, Luby–Rackoff, Merkle–Damgård, KEM/DEM, hash-and-sign, and Fiat–Shamir.
- **§9:** random-oracle methodology and limitations.
