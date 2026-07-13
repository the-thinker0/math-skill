# Applied Cryptography — Mathematical Reference

> Derived from: Dan Boneh & Victor Shoup, *A Graduate Course in Applied Cryptography* (v0.4, Sep 2017)

---

## 1. The Cryptographic Mindset

### 1.1 What Cryptography Is Fundamentally About

Cryptography is the mathematical study of **adversarial systems**. Unlike most engineering disciplines where components fail randomly, cryptographic components face an intelligent adversary who actively tries to break them. This shifts the mode of reasoning from reliability analysis to **game-theoretic security proofs**.

**Core organizing principle:** Define what "security" means via a formal **attack game** between a challenger (following a fixed protocol) and an adversary (following an arbitrary but bounded strategy). A scheme is *secure* if no efficient adversary can win the game with non-negligible probability.

### 1.2 Brittleness

The most secure cryptosystem can be rendered completely insecure by a single specification or programming error. Unit testing cannot uncover security vulnerabilities — only mathematical proof can. This is the fundamental tension: cryptography must be simultaneously practical and provably secure.

### 1.3 The Central Epistemological Move

Cryptography does not prove unconditional security (which is impossible for most tasks by Shannon's theorem). Instead it proves:

> **If** assumption X holds, **then** scheme Y satisfies security definition Z.

This is a **reduction**: break scheme Y → break assumption X. Since X is assumed hard, Y must be secure. Every security theorem in cryptography is a reduction theorem.

---

## 2. The Attack Game Framework

### 2.1 Universal Structure

All security definitions in cryptography share a common structure:

```
Attack Game: For a given scheme S and adversary A, define Experiment 0 and Experiment 1.
  - In Experiment b (b = 0, 1): Challenger behaves according to protocol P_b, A behaves arbitrarily.
  - Let W_b be the event that A outputs 1 in Experiment b.
  - Define Adv[A, S] := |Pr[W_0] - Pr[W_1]|
  - S is secure iff Adv[A, S] is negligible for all efficient A.
```

### 2.2 Bit-Guessing Equivalence

Every two-experiment advantage definition has an equivalent single-experiment "bit-guessing" form:

- Challenger chooses b ∈ {0,1} randomly, runs Experiment b.
- A outputs guess ˆb; wins if ˆb = b.
- Adv*[A, S] := |Pr[ˆb = b] − 1/2|
- **Fundamental relation:** Adv[A, S] = 2 · Adv*[A, S]

This equivalence holds universally because:

$$Pr[\hat{b} = b] = \frac{1}{2}(1 - p_0 + p_1) \implies |Pr[\hat{b} = b] - \frac{1}{2}| = \frac{1}{2}|p_1 - p_0|$$

### 2.3 The Asymptotic Formalism

- **Security parameter λ:** A "dial" trading off security vs. efficiency. Larger λ → higher security, larger keys, slower operations.
- **Negligible function:** f(λ) decays faster than 1/λ^c for any c > 0. Examples: 2^(−λ), 2^(−√λ), n^(−log n).
- **Poly-bounded function:** |f(λ)| ≤ λ^c + d for some c, d.
- **Efficient algorithm:** Running time bounded by poly(λ), with negligible probability of exceeding the bound.
- **Key closure properties:** neg + neg = neg, poly · poly = poly, poly · neg = neg.

**Critical implication:** A PRG can only be secure if its seed space is super-poly (|S| must grow faster than any polynomial). Otherwise an adversary can simply enumerate all seeds.

### 2.4 System Parameterization

Real cryptographic schemes are indexed by:
- A **security parameter** λ (integer, fixed at deployment)
- A **system parameter** Λ (generated probabilistically, public)

Families of spaces: {K_{λ,Λ}}, {M_{λ,Λ}}, {C_{λ,Λ}}.

The formal definition distinguishes between efficient sampling, efficient recognition, and effective length functions for these spaces.

---

## 3. The Reduction Proof Pattern

### 3.1 The Black-Box Wrapper

The universal proof technique: To show that security notion X implies security notion Y, construct adversary B (attacking X) that uses adversary A (attacking Y) as a black-box subroutine:

```
B's challenger ←→ [Interface Layer B] ←→ [Adversary A]
```

B is an **elementary wrapper** around A iff:
1. B runs A as a subroutine with an interface layer
2. The interface layer's running time depends only on the number of A's queries, not A's internal complexity
3. If A is efficient, B is efficient (compositional closure)

### 3.2 The Proof Template

1. **Assume** scheme S satisfies security definition X.
2. **Let** A be an arbitrary efficient adversary attacking S under definition Y.
3. **Construct** B (elementary wrapper around A) attacking S under definition X.
4. **Prove** that Adv_Y[A, S] ≤ f(Adv_X[B, S]) for some simple f.
5. **Conclude:** Since Adv_X[B, S] is negligible (by assumption X), Adv_Y[A, S] is also negligible.

### 3.3 Contrapositive Form

Equivalently: If there exists A breaking Y, then there exists B breaking X. This is the form used in practice: "If you can break my scheme, you can solve this hard problem."

### 3.4 The Sequence-of-Games Technique

For complex proofs, transform the attack game through a sequence of intermediate games:

- **Game 0:** The original attack game
- **Game 1, 2, ..., k:** Modified games where each transition is justified by:
  - An assumption (e.g., "PRF card": replace PRF with random function)
  - A "faithful gnome" implementation (restate the same game with different code)
  - A "forgetful gnome" step (remove a consistency check)
  - The Difference Lemma to bound |Pr[W_i] − Pr[W_{i−1}]|
- **Game k:** A game where the adversary's advantage is obviously zero

Then: Adv[original] ≤ Σ |Pr[W_i] − Pr[W_{i−1}]| ≤ negligible.

### 3.5 The Difference Lemma

**Theorem (Difference Lemma):** If events Z occur with probability ε, and Games 2 and 3 proceed identically unless Z occurs, then |Pr[W_2] − Pr[W_3]| ≤ Pr[Z].

This lemma is the workhorse of game-hopping proofs. It lets you argue that two games are indistinguishable by showing the "bad event" that differentiates them has negligible probability.

---

## 4. The Spectrum of Security Definitions

### 4.1 Perfect Security (Information-Theoretic)

**Definition:** A Shannon cipher E = (E, D) over (K, M, C) is perfectly secure iff for all m₀, m₁ ∈ M and all c ∈ C:

$$Pr[E(k, m_0) = c] = Pr[E(k, m_1) = c]$$

where k is uniformly distributed over K.

**Equivalent characterizations:**
- For each ciphertext c, the number of keys mapping m to c is the same for all messages m.
- Ciphertext c and message m are independent random variables.
- For every predicate φ on ciphertexts, Pr[φ(E(k, m₀))] = Pr[φ(E(k, m₁))].

**Shannon's Theorem:** If E is perfectly secure, then |K| ≥ |M|. Keys cannot be shorter than messages.

**The one-time pad** achieves perfect security: E(k, m) = k ⊕ m, with K = M = C = {0,1}^L. It is the unique optimal scheme (up to isomorphism in the group structure).

### 4.2 Semantic Security (Computational)

**Definition (Attack Game 2.1):** A chooses m₀, m₁ of equal length. Challenger encrypts m_b with random k and returns c. A outputs ˆb.

$$SSadv[A, E] := |Pr[A outputs 1 | b=0] - Pr[A outputs 1 | b=1]|$$

E is semantically secure iff SSadv[A, E] is negligible for all efficient A.

**Key relaxations from perfect security:**
1. Only efficient adversaries matter (computationally bounded)
2. Advantage need not be zero — only negligible
3. Messages must be equal length (ciphertext may leak length)
4. Encryption may be probabilistic

**Implications of semantic security:**
- Security against message recovery (Theorem 2.7)
- Security against parity prediction (Theorem 2.8)
- Security against computing any partial information about the message

### 4.3 CPA Security (Chosen Plaintext Attack)

The adversary can obtain encryptions of messages of its choice before submitting the challenge pair. This models real adversaries who can influence what gets encrypted.

**Attack Game 5.2:** A makes encryption queries, then submits challenge (m₀, m₁), receives encryption of m_b, may make more queries, outputs guess.

**Implication:** CPA security ⇒ semantic security. The converse is false (a deterministic semantically secure scheme is not CPA-secure since the adversary can encrypt m₀ and m₁ and compare).

### 4.4 CCA Security (Chosen Ciphertext Attack)

The adversary additionally gets a **decryption oracle** (cannot query the challenge ciphertext). This models adversaries who can observe decryption behavior.

**CCA1 (lunchtime attack):** Decryption queries only before challenge.
**CCA2 (adaptive):** Decryption queries both before and after challenge (but not the challenge ciphertext).

CCA security is strictly stronger than CPA security. It defeats attacks that exploit **malleability**: the ability to modify a ciphertext to produce a related plaintext.

### 4.5 Authenticated Encryption (AE)

Combines CPA security + **ciphertext integrity** (CI): no efficient adversary can produce a valid ciphertext that decrypts to a message not previously encrypted by the sender.

**AE ⇒ CCA security** (Theorem 9.1): If a cipher provides authenticated encryption, then it is CCA-secure. This is the standard path to CCA security in symmetric-key cryptography.

### 4.6 Hierarchy Summary

```
Perfect Security (|K| ≥ |M|)
  ⊂ Statistical Security (Adv ≤ ε, |K| ≥ (1-ε)|M|)
    ⊂ Semantic Security (computational)
      ⊂ CPA Security (encryption oracle)
        ⊂ CCA1 Security (decryption oracle before challenge)
          ⊂ CCA2 Security (decryption oracle before and after)
            ⊂ Authenticated Encryption (CCA2 + ciphertext integrity)
```

---

## 5. Core Cryptographic Primitives

### 5.1 Pseudo-Random Generator (PRG)

**Definition:** G: S → R is a secure PRG iff for all efficient A:

$$PRGadv[A, G] := |Pr[A(G(s)) = 1] - Pr[A(r) = 1]| = negl(λ)$$

where s ←^R S, r ←^R R.

**Stream cipher reduction:** If G is a secure PRG, then E(s, m) := G(s) ⊕ m is semantically secure. Specifically, SSadv[A, E] = 2 · PRGadv[B, G].

**Necessary condition:** |S| must be super-poly (otherwise brute-force seed enumeration succeeds).

### 5.2 Pseudo-Random Function (PRF)

**Definition:** F: K × X → Y is a secure PRF iff for all efficient A (with oracle access):

$$PRFadv[A, F] := |Pr[A^{F(k,·)} = 1] - Pr[A^{f} = 1]| = negl(λ)$$

where k ←^R K, f ←^R Funs[X, Y].

**Intuition:** No efficient algorithm can distinguish between oracle access to F(k, ·) and oracle access to a truly random function.

**Weak PRF variant:** Security holds when the adversary only sees F evaluated at random points (not of its choosing).

### 5.3 Pseudo-Random Permutation (PRP) / Block Cipher

**Definition:** E: K × X → X is a secure block cipher iff E(k, ·) is a permutation on X for each k, and for all efficient A:

$$BCadv[A, E] := |Pr[A^{E(k,·)} = 1] - Pr[A^{π} = 1]| = negl(λ)$$

where k ←^R K, π ←^R Perms[X].

**Strong PRP:** Adversary gets both encryption and decryption oracles (E(k, ·) and D(k, ·)).

### 5.4 PRF ↔ PRP Relations

**PRP Switching Lemma:** A secure PRP with large domain is a secure PRF. The advantage of distinguishing an n-bit PRP from an n-bit random function using Q queries is at most Q²/2^{n+1}. When N = 2^n is super-poly, this difference is negligible.

**Consequence:** AES (a block cipher / PRP) can be used wherever a PRF is needed, as long as the number of queries is bounded.

### 5.5 Collision-Resistant Hash Function (CRHF)

**Definition:** H: K × M → T (with |M| ≫ |T|) is collision-resistant iff for all efficient A:

$$CRHFadv[A, H] := Pr[H(k, x_0) = H(k, x_1) \land x_0 \neq x_1 | k \leftarrow^R K, (x_0, x_1) \leftarrow A(k)] = negl(λ)$$

**Birthday attack:** Generic collision-finding requires O(√|T|) hash evaluations. A hash function with n-bit output provides at most n/2 bits of collision resistance.

### 5.6 One-Way Trapdoor Function (TDF)

**Definition:** A TDF scheme T = (G, F, I) consists of:
- G(): generates (pk, sk) — public key and secret key (trapdoor)
- F(pk, x): easy to compute, a permutation on X
- I(sk, y): easy to compute with trapdoor, inverts F

**Security (one-wayness):** Given pk and y = F(pk, x) for random x, no efficient adversary can recover x with non-negligible probability.

### 5.7 Universal Hash Function (UHF)

**Definition:** H: K × M → T is ε-UHF iff for all distinct m₀, m₁ ∈ M:

$$Pr[H(k, m_0) = H(k, m_1)] \leq ε$$

where k ←^R K.

**Difference from CRHF:** UHF is an information-theoretic (unconditional) property, not computational. ε = 1/|T| is optimal.

---

## 6. Number-Theoretic Assumptions

### 6.1 The Assumption Hierarchy

```
DDH (Decisional Diffie-Hellman)
  ⇒ CDH (Computational Diffie-Hellman)
    ⇒ DL (Discrete Logarithm)
```

Each is strictly stronger (DDH is the strongest, DL the weakest). All three are conjectured hard in suitable prime-order cyclic groups.

### 6.2 Discrete Logarithm (DL) Assumption

**Attack Game 10.4:** Given g^α for random α ← Z_q, find α.

**Formal:** For all efficient A, DLadv[A, G] := Pr[A(g^α) = α] = negl(λ).

### 6.3 Computational Diffie-Hellman (CDH) Assumption

**Attack Game 10.5:** Given g^α, g^β for random α, β ← Z_q, compute g^{αβ}.

**Formal:** For all efficient A, CDHadv[A, G] := Pr[A(g^α, g^β) = g^{αβ}] = negl(λ).

**Key nuance:** CDH solutions cannot be efficiently recognized (unlike RSA, where y = x^e can be verified). This leads to the stronger DDH assumption.

### 6.4 Decisional Diffie-Hellman (DDH) Assumption

**Attack Game 10.6 (two-experiment):** Distinguish (g^α, g^β, g^{αβ}) from (g^α, g^β, g^γ) for random α, β, γ.

**Formal:** For all efficient A, DDHadv[A, G] := |Pr[A(g^α, g^β, g^{αβ}) = 1] − Pr[A(g^α, g^β, g^γ) = 1]| = negl(λ).

**Critical restriction:** DDH only holds in prime-order groups. In groups of even order, DDH is trivially false (Exercise 10.21).

### 6.5 RSA Assumption

**Attack Game 10.3:** Given (n, e, y = x^e mod n) for random x ← Z_n, find x.

**Formal:** For all efficient A, RSAadv[A, ℓ, e] = negl(λ).

**RSA as TDF:** pk = (n, e), sk = (n, d) where ed ≡ 1 mod φ(n). F(pk, x) = x^e, I(sk, y) = y^d.

### 6.6 Random Self-Reducibility of DL

**Theorem 10.2:** If an algorithm A solves DL on random instances with probability ε, there exists an algorithm B that solves DL on *any* instance with probability ε (over B's random coins only).

**Construction:** B(u) picks random ρ ← Z_q, runs A(u · g^ρ), subtracts ρ from the result. Since u · g^ρ = g^{α+ρ} is uniformly distributed, A succeeds with probability ε.

**Implication:** DL is "hard everywhere or easy everywhere" — there is no middle ground where DL is hard on some instances and easy on others.

### 6.7 Other Computational Assumptions

**Factoring assumption:** Given n = pq (product of random primes), finding p and q is hard.

**Quadratic residuosity assumption:** Distinguishing quadratic residues from non-residues in Z_n^* (where n = pq) is hard without the factorization.

**ICDH (Interactive CDH):** Used for Cramer-Shoup CCA security proof. Extends CDH with an "image oracle."

---

## 7. Symmetric-Key Constructions

### 7.1 Stream Cipher = PRG + One-Time Pad

**Construction:** E(s, m) = G(s)[0..|m|-1] ⊕ m

**Security Theorem 3.1:** If G is a secure PRG, the resulting stream cipher is semantically secure.

$$SSadv[A, E] = 2 · PRGadv[B, G]$$

### 7.2 Hybrid Encryption (PRF-based CPA Security)

**Construction (Theorem 5.2):** E'(k, m) = (x, F(k, x) ⊕ m) where x ←^R X.

**Security:** If F is a secure PRF and |X| is super-poly, then E' is CPA-secure.

$$CPAadv[A, E'] \leq \frac{2Q^2}{|X|} + 2 · PRFadv[B, F]$$

where Q is the number of encryption queries.

### 7.3 Randomized Counter Mode

**Construction:** IV ←^R X, c[j] = F(k, IV + j mod N) ⊕ m[j]

**Security Theorem 5.3:** Secure if F is a PRF and N = |X| is super-poly.

$$CPAadv^*[A, E] \leq \frac{2Q^2ℓ}{N} + PRFadv[B, F]$$

**Proof technique:** (1) Replace PRF with random function f. (2) Use gnome to check for IV collisions. (3) Apply Difference Lemma: collision probability ≤ 2Q²ℓ/N. (4) In no-collision game, all pad bits are independent random → advantage = 0.

### 7.4 CBC Mode

**Construction:** c[0] ←^R X, c[j+1] = E(k, c[j] ⊕ m[j])

**Security Theorem 5.4:** The collision probability bound becomes Q²ℓ²/N (worse than counter mode because collisions in the chaining values matter).

### 7.5 MAC from PRF

**Construction:** For a PRF F: K × M → T where |T| is super-poly, tag = F(k, m). Verification: re-compute and compare.

**Security:** If F is a secure PRF, then this is a secure MAC.

**Extension to long messages:**
- **ECBC/NMAC:** Prefix-free PRF + final encryption step
- **CMAC:** XOR-based final key derivation to handle non-prefix-free inputs
- **PMAC:** Parallel MAC using PRF(UHF) composition

### 7.6 Carter-Wegman MAC

**Construction:** tag = H(k_h, m) ⊕ F(k_f, n) where H is an ε-XOR-UHF, F is a PRF, and n is a nonce.

**Theorem 7.6:** If H is an ε-XOR-UHF and F is a secure PRF, this is a secure nonce-based MAC.

**Advantage:** The UHF handles the long message (fast, information-theoretic), the PRF only processes a short nonce.

### 7.7 Merkle-Damgård Construction

Iterates a compression function h: {0,1}^n × {0,1}^κ → {0,1}^n to build a hash for arbitrary-length inputs.

**Theorem 8.1:** If h is collision-resistant, the iterated hash H is collision-resistant.

**Joux's attack (Section 8.4.1):** Multicollisions in Merkle-Damgård are much cheaper than the birthday bound suggests.

**Davies-Meyer compression:** h(x, y) = E(y, x) ⊕ x where E is a block cipher. Proved to be collision-resistant in the ideal cipher model.

### 7.8 Sponge Construction (SHA-3)

Absorbing phase (XOR input blocks into state, apply permutation f) followed by squeezing phase (extract output, apply f between extractions). Security analysis in the random permutation model.

### 7.9 Authenticated Encryption Composition

**Encrypt-then-MAC (EtM):** c ← E(ke, m), t ← MAC(km, c), output (c, t). **This is secure.**

**MAC-then-encrypt (MtE):** t ← MAC(km, m), c ← E(ke, m‖t). **Not generally secure.** Padding oracle attacks break it (see SSL/TLS, SSH attacks).

**Encrypt-and-MAC (EaM):** c ← E(ke, m), t ← MAC(km, m). **Not generally secure** — MAC may leak information about m.

**Theoretical requirement:** EtM requires independent keys for encryption and MAC.

---

## 8. The Random Oracle Model (ROM)

### 8.1 Definition

A random oracle is an idealized hash function: H: X → Y where H(x) returns a uniformly random element of Y, consistent across queries (same x → same y).

### 8.2 ROM Methodology

1. Design scheme using a real hash function h
2. Prove security in ROM (where h is replaced by a random oracle)
3. Instantiate h with a concrete hash function (e.g., SHA-256) in practice

### 8.3 ROM Proof Pattern

In the security proof, the challenger simulates the random oracle. The adversary queries the oracle adaptively. The challenger can "program" the oracle (choose outputs for specific inputs) as long as the distribution remains uniformly random and consistent.

### 8.4 When ROM Proofs Are Useful

- **Full Domain Hash (FDH) signatures:** H(m)^d mod n secure in ROM under RSA assumption
- **ElGamal encryption in ROM:** Secure under CDH (without ROM, need DDH)
- **OAEP padding:** CCA-secure RSA encryption in ROM
- **Key derivation (HKDF):** Extract-then-expand paradigm justified in ROM

### 8.5 Limitations and Caveats

- ROM proofs are **heuristic** — a scheme secure in ROM may be insecure when instantiated with any concrete hash function
- There exist contrived schemes secure in ROM but insecure under any instantiation
- The ROM provides a useful sanity check: if a scheme cannot be proven secure in ROM, it is likely fundamentally broken

### 8.6 ROM vs. Standard Model

| Property | ROM | Standard Model |
|----------|-----|----------------|
| Assumption | Hash is truly random | Concrete computational assumption (CRHF, PRF) |
| Proof strength | Heuristic | Rigorous |
| Efficiency | Usually better | Usually worse |
| Practical acceptance | Widely used (TLS 1.3, PSS signatures) | Preferred when achievable |

---

## 9. Public-Key Encryption

### 9.1 Semantic Security for PKE

**Attack Game 11.1:** Same as symmetric SS (Attack Game 2.1) but the adversary also receives the public key pk.

$$SSadv[A, E] := |Pr[W_0] - Pr[W_1]|$$

**Necessary randomization:** A deterministic PKE cannot be semantically secure (the adversary can encrypt both candidate messages and compare).

### 9.2 TDF-based PKE (with ROM)

**Construction E_TDF:** c = (F(pk, r), H(r) ⊕ m) where r is random and H is a random oracle.

**Security:** One-way TDF + ROM ⇒ Semantic security. The proof uses H to extract a hardcore bit/pad from r.

### 9.3 ElGamal Encryption

**Key generation:** sk = α ← Z_q, pk = g^α.

**Encryption:** β ← Z_q, c = (g^β, pk^β · m).

**Decryption:** m = c₂ / c₁^α (since pk^β = g^{αβ} and c₁^α = g^{αβ}).

**Security (ROM):** CDH assumption is sufficient when m = H(g^{αβ}) ⊕ m'.
**Security (standard model):** DDH assumption required for semantic security.

### 9.4 CCA Security via Cramer-Shoup

**Theorem 12.9:** Under DDH and a universal projective hash function (or target collision resistant hash), the Cramer-Shoup scheme achieves CCA security in the standard model (no ROM).

**Key insight:** The ciphertext includes an "authentication tag" that is verified before decryption, making the scheme non-malleable. An adversary who modifies the ciphertext will produce an invalid tag with overwhelming probability.

### 9.5 CCA via Fujisaki-Okamoto Transform

**Generic transform:** Takes a one-way CPA-secure PKE and produces a CCA-secure PKE in the ROM.

**Construction:** Encrypt by re-encrypting: c = E(pk, m; H(m)) where the encryption randomness is derived deterministically from the message via a random oracle.

### 9.6 Threshold Decryption

**Shamir Secret Sharing:** Split a secret s ∈ Z_q into n shares such that any t shares reconstruct s, but t-1 shares reveal nothing.

**Construction:** Pick random polynomial f of degree t-1 with f(0) = s. Share i = f(i). Lagrange interpolation reconstructs f(0).

**ElGamal threshold decryption:** Share the secret key α among n parties. Each party partially decrypts (computes c₁^{α_i}); combine using Lagrange coefficients.

---

## 10. Digital Signatures

### 10.1 EUF-CMA Security

**Attack Game 13.1:** A gets pk and a signing oracle. A outputs (m*, σ*). A wins if Verify(pk, m*, σ*) = accept and m* was never queried to the signing oracle.

**Existential Unforgeability under Chosen Message Attack (EUF-CMA):** For all efficient A, probability of winning is negligible.

**Strong EUF-CMA:** A also wins if it produces a new valid signature on a previously signed message.

### 10.2 Full Domain Hash (FDH)

**Construction:** σ = H(m)^d mod n (RSA-based FDH).

**Security Theorem 13.3 (ROM):** RSA assumption ⇒ EUF-CMA security for FDH.

**Proof technique:** The simulator programs the random oracle H so that for queried messages, H(m) = r^e mod n (so σ = r is known). For the forgery, H(m*) = y (the RSA challenge), so the forged signature solves the RSA problem.

### 10.3 Tightness of Security Reductions

**Theorem 13.3 reduction tightness:** ε_RSA ≈ ε_sig / q_H where q_H is the number of hash queries. This is a "loose" reduction.

**Theorem 13.4:** An alternative RSA-based scheme achieves ε_RSA ≈ ε_sig (tight reduction). The trade-off is computational efficiency.

### 10.4 Hash-Based Signatures (Lamport, Winternitz, Merkle)

**Lamport one-time signature:** Public key = 2ℓ hash images (for ℓ-bit messages). Sign bit i by revealing the preimage for the corresponding bit value. **Information-theoretic security** assuming one-wayness of the underlying function.

**Winternitz optimization:** Sign log₂(w) bits per chain of length w-1 using iterated hashes. Trade-off: larger w → shorter signatures but slower signing.

**Merkle tree:** Combine many one-time public keys into a single "root" public key. Authentication path of length log₂(N) proves a one-time key belongs to the tree. Full stateless many-time signature from one-time components.

### 10.5 The Hash-then-Sign Paradigm

CRHF H extends signature scheme from short messages to arbitrary-length messages: Sign(sk, H(m)). If H is collision-resistant, forgery on the extended scheme implies either forgery on the original scheme or a collision in H.

---

## 11. Sigma Protocols and Zero-Knowledge

### 11.1 Sigma Protocol Structure

A sigma protocol for relation R = {(x, w)} has three moves:

1. **Prover → Verifier:** Commitment a (computed from random nonce)
2. **Verifier → Prover:** Challenge c (random from challenge space C)
3. **Prover → Verifier:** Response z

**Formal definition (Definition 19.4):** A sigma protocol must be:
- **Complete:** Honest prover with valid witness always convinces
- **Knowledge sound:** There exists an extractor that, given two accepting transcripts (a, c₁, z₁) and (a, c₂, z₂) with c₁ ≠ c₂, extracts a witness w
- **Special Honest Verifier Zero Knowledge (HVZK):** Given a challenge c, there exists a simulator that produces accepting transcripts indistinguishable from real ones

### 11.2 The Fiat-Shamir Heuristic

Converts any sigma protocol into a non-interactive proof (or signature) by replacing the verifier's random challenge with a hash of the commitment and message:

$$c \leftarrow H(a, m)$$

**For signatures (Schnorr):** σ = (a, z) where c = H(a, m) and z is the response. Verify by checking the sigma protocol verification equation.

**Security in ROM:** If the sigma protocol is knowledge-sound and HVZK, the resulting signature scheme is EUF-CMA secure in the ROM.

### 11.3 Schnorr Identification and Signatures

**Relation:** R = {(u, α) : u = g^α} (knowledge of discrete logarithm).

**Protocol:** a = g^ρ, c ← Z_q, z = ρ + cα mod q. Verify: g^z = a · u^c.

**Schnorr signature:** c = H(a, m), σ = (c, z). Verify by checking c = H(g^z · u^{-c}, m).

### 11.4 OR-proofs and AND-proofs

**OR-proof (Theorem 19.9):** Prove knowledge of w₁ OR w₂ without revealing which. The prover simulates the branch without the witness (using HVZK simulator) and runs the real protocol for the branch with the witness.

**AND-proof:** Prove knowledge of w₁ AND w₂ simultaneously. Run both protocols with the same challenge.

### 11.5 Witness Independence

**Definition 19.7:** A protocol is witness-independent if for any two witnesses w₀, w₁ for the same statement x, transcripts produced using w₀ are indistinguishable from transcripts produced using w₁.

**Theorem 19.8:** Special HVZK ⇒ Witness independence.

This is critical for **actively secure identification**: even if the verifier is malicious (deviates from the protocol), the prover's witness remains hidden.

### 11.6 Zero-Knowledge Proofs

**Existential soundness (Section 20.1):** For statements x in a language L, no efficient prover can convince the verifier to accept x ∉ L (except with negligible probability). Defined with respect to an instance generator, not universally.

**Computational ZK (Section 20.4):** The simulation is computationally indistinguishable from real proofs. Weaker than statistical/perfect ZK but sufficient for most applications.

**NIZK (Non-Interactive Zero Knowledge):** The Fiat-Shamir transform applied to a sigma protocol yields a NIZK proof in the ROM. The proof is a single message π that the verifier checks.

**SNARKs (Section 20.6):** Succinct Non-interactive ARguments of Knowledge — proofs that are very short and fast to verify, enabling verifiable computation.

---

## 12. Key Exchange Protocols

### 12.1 The AKE Security Model

**Attack Game 21.1 (Boneh-Shoup AKE model):** Multiple honest parties with long-term keys. Adversary controls all communication (deliver, modify, drop, inject messages). A **partner function** determines which sessions are "matching." Security has two components:

1. **Indistinguishability:** For a test session (fresh, accepted), the adversary cannot distinguish the real session key from random.
2. **Explicit key confirmation:** (Optional) The adversary cannot make a party accept a key that doesn't match its partner's.

**Freshness conditions** encode which compromises the adversary is allowed:
- **PFS (Perfect Forward Secrecy):** Long-term key compromise does not reveal past session keys. Modeled by allowing the adversary to corrupt a party *after* the test session completes.
- **HSM security:** Ephemeral key leakage does not reveal the session key. The long-term key still protects the session.
- **One-sided authentication:** Only one party is authenticated (e.g., TLS: server authenticated, client anonymous until application layer).

### 12.2 Diffie-Hellman Key Exchange (Anonymous)

**Protocol:** Alice sends g^α, Bob sends g^β. Shared key = g^{αβ}.

**Security:** CDH assumption ⇒ passive security (against eavesdropping). No authentication — completely insecure against active attacks (man-in-the-middle can establish separate keys with each party).

### 12.3 Signed Diffie-Hellman

Alice signs her ephemeral public key g^α. Bob verifies the signature. Security requires both parties to sign the complete transcript (including both ephemeral keys and identities) to prevent identity misbinding attacks.

### 12.4 SIGMA and TLS 1.3

TLS 1.3 uses a SIGMA-style protocol: (EC)DHE key exchange with digital signatures for authentication. The key derivation uses HKDF in an extract-then-expand pattern, with the transcript hash bound into the key derivation to prevent downgrade and replay attacks.

### 12.5 PAKE (Password-Authenticated Key Exchange)

**Core problem:** Two parties share only a low-entropy secret (password). Must resist offline dictionary attacks — the only way to test a password guess should be through an online interaction.

**Protocol PAKE₂ (Section 21.11.5):** Uses a PRF-based construction. Security: the adversary can test at most one password per online interaction. The session key is indistinguishable from random if the password is not guessed.

**Phishing resistance:** Even if the user is tricked into interacting with a fake server, the fake server learns nothing about the password (it only gets to test one guess).

---

## 13. Common Attack Patterns and Pitfalls

### 13.1 The Two-Time Pad

Reusing a stream cipher key (or PRG seed, or one-time pad key) is catastrophic: c₁ ⊕ c₂ = m₁ ⊕ m₂, which reveals the XOR of the two plaintexts. With redundancy in plaintexts (e.g., ASCII), both messages can be recovered.

### 13.2 Malleability Attacks

A cipher is **malleable** if an adversary can transform a ciphertext c (encrypting m) into a ciphertext c' (encrypting a related message m'). 

- **Stream ciphers:** Flipping a bit of c flips the corresponding bit of m.
- **CBC mode:** Modifying IV allows controlled modification of the first plaintext block.
- **Counter mode:** Same bit-flipping vulnerability as stream ciphers.

**Mitigation:** Use authenticated encryption (MAC on ciphertext).

### 13.3 Padding Oracle Attacks

When the receiver reveals whether padding is valid (e.g., through error messages or timing), adaptive chosen-ciphertext attacks can decrypt any ciphertext bit by bit.

**Bleichenbacher's attack (Section 12.8.3):** Exploits PKCS1 v1.5 padding format oracle to recover RSA-encrypted plaintexts. Each oracle query eliminates a fraction of the message space.

**Vaudenay's attack (Section 9.4.2):** Exploits CBC padding oracle in TLS/SSL. One byte of plaintext recovered per ~128 oracle queries on average.

### 13.4 Extension Attacks

**CBC-MAC extension:** Given tag t = CBC-MAC(k, m), one can compute CBC-MAC(k, m‖pad(m)‖Δ) for any Δ without knowing k.

**Non-prefix-free MACs:** If the MAC doesn't distinguish message boundaries, an adversary can forge a tag for m₀‖m₁ from tags on m₀ and m₁.

### 13.5 Related-Key Attacks

**WEP disaster:** Per-frame keys derived as IV‖k (concatenation, not PRF) created related RC4 keys. After ~1M frames, the long-term key k is completely recovered.

**Correct approach:** Per-frame key = F(k, IV) where F is a secure PRF.

### 13.6 Key-Control Attacks

Using the same key for encryption and MAC in Encrypt-then-MAC creates cross-scheme interactions that break security. **Independent keys are essential** for composition.

### 13.7 Nonce Misuse

In nonce-based encryption (counter mode, GCM), reusing the same (key, nonce) pair:
- **Counter mode:** Two-time pad vulnerability
- **GCM:** Authentication key recovery (the GHASH key can be extracted)

### 13.8 Protocol-Level Failures

- **Missing identity in signatures:** Signing only the ephemeral key (not the peer's identity) enables identity misbinding — Alice thinks she's talking to Bob, but the signature only proves knowledge of the secret key, not the signer's identity.
- **Reflection attacks:** An attacker reflects Alice's messages back to Alice, making her think she's talking to Bob when she's actually talking to herself.
- **Downgrade attacks:** Stripping authentication from a protocol by modifying negotiation messages. Mitigation: include the full transcript in the final MAC or signature.

---

## 14. The Assumption Landscape

### 14.1 Symmetric-Key Assumptions

| Assumption | Definition | Used For |
|-----------|-----------|---------|
| PRG exists | Stretch random seed to longer pseudorandom string | Stream ciphers |
| PRF exists | Keyed function indistinguishable from random function | MAC, encryption, KDF |
| PRP/Block cipher exists | Keyed permutation indistinguishable from random permutation | AES, DES |
| CRHF exists | Hard to find collisions | Digital signatures, commitments |

**One-way functions (OWF) are minimal:** OWF ⇒ PRG ⇒ PRF ⇒ PRP ⇒ everything in symmetric crypto. But OWF existence implies P ≠ NP — the entire edifice rests on this unproven conjecture.

### 14.2 Public-Key Assumptions

| Assumption | Problem | Hardness |
|-----------|---------|----------|
| Factoring | Given n = pq, find p, q | Subexponential (GNFS, L_n[1/3, 1.923]) |
| RSA | Given (n,e,y), find x: x^e = y mod n | ≤ Factoring |
| DL in Z_p^* | Given g, g^α, find α | Subexponential (same complexity as factoring) |
| DL in EC | Given P, αP, find α | **Exponential** (√q via Pollard rho) |
| CDH | Given g^α, g^β, compute g^{αβ} | ≥ DL |
| DDH | Distinguish (g^α, g^β, g^{αβ}) from random | > CDH (strictly) |
| LWE | Distinguish (A, As+e) from random | **Post-quantum**, reduction from worst-case lattice problems |

### 14.3 Quantum Threats

**Shor's algorithm:** Factoring and discrete log in polynomial time on a quantum computer. Breaks RSA, DH, ElGamal, DSA, ECDSA.

**Grover's algorithm:** Quadratic speedup for brute-force search. A 128-bit symmetric key provides only 64 bits of quantum security. Mitigation: use 256-bit keys.

**Post-quantum assumptions:** LWE (Learning With Errors), SIS (Short Integer Solution), code-based, multivariate — all believed resistant to quantum attacks.

### 14.4 Concrete Security Parameters

| Primitive | Classical Security | Quantum Security |
|-----------|-------------------|------------------|
| AES-128 | 128 bits | 64 bits (Grover) |
| AES-256 | 256 bits | 128 bits |
| RSA-2048 | ~112 bits | Broken (Shor) |
| ECC P-256 | ~128 bits | Broken (Shor) |
| SHA-256 (collision) | 128 bits (birthday) | 85 bits (BHT) |

---

## 15. Mathematical Toolbox

### 15.1 Probability Theory

**Total probability:** Pr[X = x] = Σ_i Pr[X = x | E_i] · Pr[E_i]

**Independence:** X, Y independent iff Pr[X = x ∧ Y = y] = Pr[X = x] · Pr[Y = y]

**Birthday paradox:** For n independent uniform samples from a set of size N, collision probability ≈ 1 − e^{−n²/2N}. Expected number of samples before first collision ≈ √(πN/2).

**Union bound:** Pr[E₁ ∨ E₂ ∨ ... ∨ E_k] ≤ Σ Pr[E_i]. Tight when events are rare and nearly disjoint.

**Difference Lemma (Theorem 4.7):** If two games proceed identically unless event Z occurs, then |Pr[W in Game 2] − Pr[W in Game 3]| ≤ Pr[Z].

### 15.2 Group Theory

**Cyclic group G of prime order q:** G = {g⁰, g¹, ..., g^{q-1}} where g is a generator. Every non-identity element is a generator.

**Subgroup:** H ⊆ G is a subgroup if closed under the group operation and inverses. Lagrange: |H| divides |G|.

**Z_p*:** Multiplicative group modulo prime p. Order = p-1. Always cyclic.

**Elliptic curve group:** Points (x, y) satisfying y² = x³ + ax + b over F_p, plus point at infinity. Group operation is chord-and-tangent law. Order ≈ p (Hasse's theorem: |#E(F_p) − (p+1)| ≤ 2√p).

### 15.3 Number Theory

**Chinese Remainder Theorem (CRT):** For n = n₁·n₂ with gcd(n₁, n₂) = 1:
Z_n ≅ Z_{n₁} × Z_{n₂}. Computations mod n can be done mod n₁ and mod n₂ separately.

**Euler's totient:** φ(n) = number of integers 1 ≤ k ≤ n with gcd(k, n) = 1. For n = pq: φ(n) = (p−1)(q−1).

**Euler's theorem:** a^{φ(n)} ≡ 1 (mod n) for gcd(a, n) = 1.

**Fermat's theorem:** a^{p−1} ≡ 1 (mod p) for prime p and a ≠ 0 mod p.

**Quadratic residues:** x ∈ Z_p* is a QR iff x^{(p−1)/2} = 1. Exactly half the elements are QRs. Square roots: easy when p ≡ 3 mod 4 via a = x^{(p+1)/4}.

### 15.4 Complexity Theory

**P (polynomial time):** Problems solvable by deterministic polynomial-time algorithms.

**BPP (bounded-error probabilistic polynomial time):** Solvable by probabilistic polynomial-time with error ≤ 1/3.

**Negligible probability:** f: N → R is negligible iff ∀c > 0, ∃n₀: ∀n ≥ n₀, |f(n)| < n^{−c}.

**One-way function:** f is one-way if (1) f(x) is easy to compute, (2) for all efficient A, Pr[A(f(x)) ∈ f^{−1}(f(x))] is negligible for random x.

---

## 16. Reasoning Patterns and Design Principles

### 16.1 The Reduction Mindset

Always think: "If an adversary can break my scheme, what hard problem does that let me solve?" The proof constructs an explicit adversary against the hard problem using the scheme adversary as a subroutine.

### 16.2 The Simulation Paradigm

In reduction proofs, the challenger (reduction) must simulate the environment for the adversary without knowing the secrets. Techniques:
- **Random oracle programming:** Choose H outputs to embed problem instances
- **Decryption oracle simulation:** Use the "faithful gnome" pattern to maintain consistency
- **Key delegation:** Give the adversary only what it is entitled to know

### 16.3 The Idealized Component Replacement

Replace a real component (PRF, block cipher) with its idealized counterpart (random function, random permutation). The adversary's advantage changes by at most the distinguishing advantage against the component. This decomposes the proof: cryptographic assumption → idealized game → information-theoretic analysis.

### 16.4 The Game-Hopping Methodology

1. Start with the real attack game
2. Replace each cryptographic component with its ideal version (one hop per assumption)
3. Apply the Difference Lemma at each hop
4. In the final idealized game, compute the advantage directly (often zero by information-theoretic argument)

### 16.5 The Hybrid Argument

When proving security for multi-query or multi-instance settings, define intermediate "hybrid" games where the first i components are real and the rest are ideal. The difference between adjacent hybrids is bounded by the single-component security. Summing over Q hybrids gives the final bound.

### 16.6 Necessary Conditions as Sanity Checks

Before attempting to prove security, check necessary conditions:
- **Key space must be super-poly** (otherwise brute-force succeeds)
- **PRG seed space must be super-poly** (otherwise enumeration succeeds)
- **MAC tag space must be super-poly** (otherwise random guessing succeeds)
- **DDH requires prime-order groups** (even-order groups have trivial DDH distinguishers)

### 16.7 Composition Principles

- **Encrypt-then-MAC is always safe** (Theorem 9.2)
- **Use independent keys** for different primitives in composition
- **Include complete context** (identities, transcript, purpose) in MAC/signature computation
- **Nonce-based schemes break catastrophically on nonce reuse** — design for nonce-misuse resistance when possible

### 16.8 The "Nothing Up My Sleeve" Principle

Cryptographic constants should have a clear, verifiable provenance (e.g., digits of π, smallest prime satisfying constraints) to avoid suspicion of embedded backdoors. Contrast: P-256 (verifiable seed) vs. potentially suspicious parameters.

---

## 17. Transferable Thinking Modes

### 17.1 Adversarial Modeling

The core innovation of cryptography is not any particular algorithm, but the **methodology of adversarial modeling**:
1. Define exactly what the adversary can do (oracle access, computational bounds)
2. Define exactly what constitutes "winning"
3. Prove that no efficient adversary can win with non-negligible probability

This methodology transfers to any domain with strategic adversaries: mechanism design, network security, ML robustness, game theory.

### 17.2 Reduction as Universal Proof Technique

The reduction pattern (A breaks Y ⇒ B breaks X) is a general scientific reasoning tool:
- Frame a hypothesis ("scheme is secure")
- Show that refuting it would refute a more fundamental hypothesis ("DL is hard")
- The strength of the conclusion depends on the plausibility of the fundamental hypothesis

### 17.3 Asymptotic vs. Concrete Security

Cryptography makes a deliberate choice to use asymptotic analysis (security parameter → ∞). This gives a clean mathematical theory but must be complemented by **concrete security analysis** (exact advantage bounds as functions of query counts and running time) for practical deployment.

### 17.4 Information-Theoretic vs. Computational

Many problems have two regimes:
- **Information-theoretically impossible** but computationally feasible (public-key crypto: secret key is uniquely determined by public key, but computing it is hard)
- **Information-theoretically possible** but requires impractically large parameters (perfect security: |K| ≥ |M|)

The art is finding the sweet spot: schemes that are information-theoretically broken but computationally secure with practical parameters.

### 17.5 The Abstraction Hierarchy

Cryptography builds abstractions in layers:
```
One-way functions → PRG → PRF → PRP → Stream/Block ciphers
                                           → MAC → Authenticated Encryption
                                           → CPA Encryption → CCA Encryption
Trapdoor functions → Public-key encryption → CCA-secure PKE
DL/CDH/DDH → Key exchange → Authenticated key exchange
Sigma protocols → Signatures (Fiat-Shamir) → Certificates/PKI
                → Zero-knowledge proofs → NIZK → SNARKs
```

Each layer provides a clean API to the layer above. Breaking any layer requires solving a hard mathematical problem at the base. This is the **layered assurance** model of cryptographic engineering.

### 17.6 When to Trust and When to Doubt

- **ROM proofs** are useful design validation but not ironclad guarantees
- **Reductions with security loss** (ε_scheme ≈ Q · ε_assumption) require compensating with larger parameters
- **Composition is delicate:** two secure schemes composed naively can be insecure
- **Provable security ≠ implementation security:** Side channels, timing, and fault attacks live outside the mathematical model
