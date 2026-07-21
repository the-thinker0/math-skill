# Encryption Security Hierarchy: CPA, CCA, and AE

## Minimal Definition

- **IND-CPA:** Even with encryption-oracle access, an adversary cannot distinguish the challenge encryptions of two equal-length messages.
- **IND-CCA1:** A decryption oracle is available before, but not after, the challenge.
- **IND-CCA2:** A decryption oracle is available before and after the challenge, except on the challenge ciphertext itself and any variants excluded by the definition.
- **INT-CTXT:** The adversary cannot produce a fresh valid ciphertext not previously returned by the encryption oracle.
- **Authenticated encryption (AE):** Provides confidentiality and ciphertext integrity. A common formulation uses IND-CPA + INT-CTXT and implies the corresponding CCA confidentiality; exact AE/AEAD games vary by source.

This is a common hierarchy, not a claim that IND-CCA2 is the strongest possible notion for every protocol.

## Core Formulas

- IND advantage is written as $|\Pr[b'=b]-1/2|$ or twice this quantity, depending on convention.
- Typical implications: IND-CCA2 $\Rightarrow$ IND-CCA1 $\Rightarrow$ IND-CPA; converses fail in general.
- With independent keys and suitable primitive assumptions, Encrypt-then-MAC (EtM) is a generic route to AE.
- MAC-then-Encrypt and Encrypt-and-MAC are **not unconditionally insecure**. They lack EtM's broad generic composition theorem; security depends on the encryption/MAC, encoding, error handling, and leakage model.
- For perfect secrecy over finite message spaces, the key space/entropy must cover the message uncertainty; in the common uniform finite case $|\mathcal K|\ge|\mathcal M|$. This is not a general key-length formula for computational security.

## Applicable Problems

- Select confidentiality and integrity goals for encryption, KEM-DEM, record, or storage protocols.
- Determine whether decryption oracles, errors, and replay interfaces strengthen the adversary.
- Review EtM/AEAD key separation, nonce handling, and associated-data binding.
- Check whether a paper's CPA/CCA/AE claim matches its actual API.

## Cryptographic Construction and Cross-Domain Boundary

- CPA/CCA describe encryption-oracle capabilities; they are not synonyms for black-box/white-box/gradient access in ML.
- Correctness, unforgeability, and privacy are distinct. Verifiable inference should define soundness, zero knowledge/privacy, and authentication separately rather than calling all of them AE.
- EtM cannot be transferred to an arbitrary ML pipeline merely as “verify before/after inference.” First define the authenticated bytes, parsing behavior, and failure side channels.

## Implementation Considerations

- Prefer standardized AEAD APIs. Meet each scheme's random/unique nonce requirement and bind protocol context as associated data.
- Derive separate encryption and authentication keys; verify the tag before releasing plaintext and unify error behavior.
- CCA security does not itself prevent replay, traffic analysis, endpoint compromise, or side channels.

## Risks and Failure Conditions

- **Treating implication as equivalence:** IND-CPA does not imply IND-CCA; confidentiality does not imply integrity.
- **Judging composition from initials alone:** MtE/EaM security depends on the concrete construction.
- **Nonce/key reuse:** Many AEAD schemes lose confidentiality and integrity under nonce reuse.
- **Decryption error side channels:** Distinct padding/tag/parsing failures can become an oracle.
- **Invalid perfect-secrecy analogy:** $|\mathcal K|\ge|\mathcal M|$ does not mean training-data size must exceed model-parameter count.

## Further References

- `../../references/books/applied-cryptography.md`
- `../../references/books/introduction-to-modern-cryptography.md`

## Routing Extensions

- Games: `attack-game-framework.en.md`
- Reductions: `reduction-proof-template.en.md`
- PRF: `prf-prg-owf.en.md`
