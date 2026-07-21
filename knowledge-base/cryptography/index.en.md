# Cryptography Activation Index

## Domain Signals
Activate this domain when the problem involves:
- Security definitions: formal threat models like CPA/CCA1/CCA2/AE/EUF-CMA
- Primitives: OWF/PRG/PRF/PRP/CRHF/TDF and their equivalence / construction chains
- Assumptions: DL/CDH/DDH/RSA/LWE/quantum threats (Shor/Grover)
- Reduction proofs: black-box reductions, hybrid argument, simulation paradigm, tightness analysis
- Protocols: encryption/MAC/signature/ZK/AKE/MPC
- Attack games: formal challenger-vs-adversary interaction framework
- Post-quantum: lattice-based, code-based, hash-based signatures
- Advanced constructions: homomorphic encryption, attribute-based encryption, functional encryption, verifiable computation

## Core Anchors
- `prf-prg-owf.en.md` — Pseudorandom function families, pseudorandom generators, and one-way functions (minimal-assumption → basic-primitive equivalence chain)
- `reduction-proof-template.en.md` — Reduction proof template (constructive "break-scheme ⇒ solve-assumption" reasoning paradigm)
- `attack-game-framework.en.md` — Attack game framework (challenger-vs-adversary security definition paradigm)
- `cca-cpa-ae-hierarchy.en.md` — Security hierarchy CPA/CCA/AE (increasing adversary capability layers)

## Extension Concepts
When core anchors are insufficient, these concepts may require temporary activation:
- Zero-knowledge proofs: interactive/non-interactive (Fiat-Shamir), Sigma protocols, zk-SNARK/zk-STARK
- Commitment schemes: hiding + binding, hash commitments, Pedersen commitments
- Secret sharing: Shamir threshold, Baum-Waidner verifiable secret sharing
- Homomorphic encryption: partially homomorphic (FHE/TFHE/CKKS), bootstrapping
- Multi-party computation (MPC): Yao garbled circuits, GMW, BGW, SPDZ
- Verifiable computation (VC): PCP, zk-SNARK, GKR, interactive proofs
- Differential privacy × cryptography intersection: indistinguishability on adjacent datasets, relation to computational indistinguishability
- Post-quantum cryptography (PQC): lattice-based (LWE/RLWE), code-based (McEliece), hash-based (SPHINCS+), multivariate
- Identity-based cryptography (IBE): master key derivation, Boneh-Franklin
- Attribute-based encryption (ABE): key-policy vs ciphertext-policy, access structures
- Functional encryption (FE): function keys for decryption
- Impossibility & separation results: black-box separation, Oracle separation, meta-theorems

## Reference Book Directions
- `../../references/books/applied-cryptography.md`: Boneh & Shoup, attack games + reduction proofs + constructions and protocols
- `../../references/books/foundations-of-cryptography.md`: Goldreich, definitional methodology + constructive reductions + meta-theorems
- `../../references/books/introduction-to-modern-cryptography.md`: Katz & Lindell, formal security definitions + construction paradigms + implementation pitfalls

## AI Translation Directions
Cryptography does not directly produce GPU kernels, but its **design ideas** transfer to AI safety / verifiable computation:
- PRF → verifiable pseudorandom source (routing seed, data partitioning, reproducible experiments)
- OWF → hard-to-invert mapping design pattern (hash attention, verifiable watermarking)
- Reduction paradigm → ML robustness certificates (break robustness ⇒ solve hard problem)
- Attack games → ML adversarial modeling (adversary capability budget + win condition + unbreakability proof)
- Commitment schemes → model watermarking and traceable distribution
- Zero-knowledge → verifiable inference (inference produces SNARK-like proofs, verifier low-cost check)
- Differential privacy → privacy-preserving training (gradient noise injection with formal guarantees)
- Simulation paradigm → privacy certificates (model output independently generatable ⇒ training data not leaked)

## Temporary Activation Rules
When the required mathematics is not in core anchors:
1. First check the extension concepts list for a match
2. If matched, generate a temporary knowledge card using relevant lenses (game/axiomatization/algorithmic/probabilistic/duality/causal/categorical)
3. If unmatched, enter Knowledge Gap Protocol
4. Tag the temporary card's domain as "crypto" or "shared" for subsequent upgrade
