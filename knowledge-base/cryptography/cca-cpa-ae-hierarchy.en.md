# Security Hierarchy: CPA/CCA/AE

## Minimal Definition
Increasing-capability threat models, ordered by the oracle strength the adversary can query:
- **CPA (Chosen-Plaintext Attack)**: the adversary can obtain encryptions of arbitrary plaintexts. For private-key encryption, this is the minimum; for public-key encryption, the adversary can encrypt arbitrarily (the key is public).
- **CCA1 (non-adaptive Chosen-Ciphertext Attack)**: the adversary can decrypt arbitrary ciphertexts before the challenge (except the challenge ciphertext). Also called "lunchtime attack."
- **CCA2 (adaptive Chosen-Ciphertext Attack)**: the adversary can decrypt arbitrary ciphertexts both before and after the challenge (except the challenge ciphertext itself). This is the strongest standard threat model for encryption.
- **AE (Authenticated Encryption)**: AE = IND-CCA2 + INT-CTXT (ciphertext integrity). Both confidential and integral.

## Core Formulas
- **IND-CPA game**: adversary submits $m_0, m_1$ (equal length), challenger returns $\mathsf{Enc}_k(m_b)$; secure iff $\mathsf{Adv}^{\mathsf{ind\text{-}cpa}}_{\mathcal{A}}=|\Pr[b'=b]-1/2|\le\mathsf{negl}(n)$
- **IND-CCA1**: adversary may query decryption oracle during training, but not after challenge
- **IND-CCA2**: adversary may query decryption oracle before and after challenge (except the challenge ciphertext itself); strongest encryption security
- **INT-CTXT (ciphertext integrity)**: adversary cannot produce a new valid ciphertext (even given other valid ciphertexts)
- **EtM vs MtE vs EaM composition paradigms**:
  - **EtM (Encrypt-then-MAC)**: $\mathsf{CT}=\mathsf{Enc}_k(m)\|\mathsf{MAC}_{k'}(\mathsf{Enc}_k(m))$, **secure**
  - **MtE (MAC-then-Encrypt)**: $\mathsf{CT}=\mathsf{Enc}_k(m\|\mathsf{MAC}_{k'}(m))$, **vulnerable to padding oracle, insecure**
  - **EaM (Encrypt-and-MAC)**: $\mathsf{CT}=\mathsf{Enc}_k(m)\|\mathsf{MAC}_{k'}(m)$, **leaks information, insecure**
- **Shannon perfect secrecy**: the cost of information-theoretic security is $|K|\ge|M|$ (key must be at least as long as the message, the origin of OTP); computational security breaks this limit
- **CPA security ⇏ multi-encryption security (symmetric); public-key CPA ⇒ multi-encryption security** (public-key adversaries can encrypt arbitrarily)

## Applicable Problems
- Hierarchical threat modeling in AI scenarios:
  - **White-box vs black-box vs adaptive adversaries**: corresponding to CPA / CCA1 / CCA2 hierarchy
  - **Adversarial example strength**: hierarchical perturbation budgets + adaptive query capabilities
  - **Model extraction**: adversary query budget and training-data access hierarchy
  - **AE analogy for verifiable inference**: both correct output (integrity) and unforgeability (confidentiality)
  - **CCA analogy for adversarial training**: adversary can query during training (pre-challenge) and deployment (post-challenge)
  - **Composition pipeline security review**: EtM/MtE/EaM correspond to ML pipeline "encryption + tamper-proofing" composition modes

## AI Design Translation
- **Applying CPA/CCA hierarchy to ML adversarial strength**:
  - CPA analogy: black-box query adversary (query access only, no gradient access)
  - CCA1 analogy: white-box adversary can access gradients during training but not deployment
  - CCA2 analogy: adaptive adversarial training adversary (gradient access during both training and deployment)
  - AE analogy: both correct output (tamper-proof) and unforgeable (leak-proof)
- **EtM/MtE/EaM composition paradigm transfer**: ML pipeline "model inference + integrity check" composition modes correspond to EtM-secure / MtE-insecure. Warning: composition pitfalls may transfer.
- See `../../design-patterns/` for corresponding patterns (e.g., constraint-penalty); if no match, label as "temporary design translation."

## Engineering Feasibility
Threat hierarchy definitions are pure methodology, not GPU:
- Security games are logical constructs, not tensor operations
- Composition paradigm review is design reasoning, not GPU kernels
- IND/CCA proofs are mathematical reasoning, not low-precision numerics
GPU 8-dimension assessment does not apply; cryptographic outputs pass reduction tightness + assumption dependency + implementation pitfall checks (see the "Cryptographic GPU Friendliness Warnings" section in `../../references/gpu-friendly-math.en.md`).

## Risks and Failure Conditions
- **Hierarchy too strong limits practical schemes**: requiring CCA2 security excludes many efficient constructions; requiring "adaptive adversarial robustness" in ML can make training cost explode
- **Adversary capabilities hard to formalize strictly in ML**: the boundary between white-box and black-box is blurred (e.g., distilled models can leak teacher model information)
- **EtM/MtE composition pitfalls may transfer to ML pipelines**: e.g., "verify-then-infer" corresponds to EtM (secure), "infer-then-verify" corresponds to MtE (potentially insecure); padding-oracle-style attacks may transfer
- **Shannon perfect secrecy cost transfer**: if information-theoretic ML robustness is required, "key length ≥ message length" corresponds to "training data ≥ model parameters" — practically unreachable
- **Multi-encryption security assumption transfer**: CPA-secure symmetric encryption is insecure under multiple encryptions, corresponding to possible degradation of ML robustness under multiple queries
- **Quantum threats**: Shor breaks public-key encryption; Grover halves symmetric security bits; AE with symmetric + public-key hybrids must consider quantum hierarchy

## Further References
- Distilled notes: `../../references/books/applied-cryptography.md` (§4 CPA/CCA/AE, §7.9 EtM/MtE/EaM, §9.2 composition security)
- Distilled notes: `../../references/books/introduction-to-modern-cryptography.md` (formal security definitions, IND/CCA, MACs)
- Original books: Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §4, §7.9, §9.2; Katz & Lindell, *Introduction to Modern Cryptography*, 2nd ed.

## Routing Extensions
- If attack-game formalization is needed → `attack-game-framework.en.md` (challenger vs adversary)
- If reductions are needed → `reduction-proof-template.en.md` (tightness analysis)
- If assumption formalization is needed → `prf-prg-owf.en.md` (OWF/PRG/PRF)
- If a game-theoretic view is needed → `../../lenses/game.en.md` (mechanism design, equilibrium)
- If an axiomatic view is needed → `../../lenses/axiomatization.en.md` (security definitions as axioms)

## Extensible Directions
- Forward Security (PFS): session key compromise does not break history
- Backward Security: future keys do not compromise current
- Key Compromise Resilience: partial key compromise does not break the whole
- Stateless vs stateful schemes: security impact of state management
- Asymmetric hierarchy: KEM-DEM paradigm
- Post-quantum AE: authenticated encryption against quantum adversaries
