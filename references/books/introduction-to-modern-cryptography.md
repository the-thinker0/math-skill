# Introduction to Modern Cryptography — Distilled Knowledge Reference

> Source: Katz & Lindell, *Introduction to Modern Cryptography*, 2nd Edition (2015)
> Purpose: AI research assistant reference for cryptographic reasoning, not a chapter summary

---

## 1. The Modern Cryptographic Paradigm

### 1.1 Three Foundational Principles

Modern cryptography (post-1980s) is distinguished from classical cryptography by three principles that transform the field from an art to a science:

1. **Formal Definitions.** Security must be defined with mathematical precision before design begins. A definition specifies: (a) what constitutes a "break" (the security guarantee), and (b) the adversary's capabilities (the threat model). Without a definition, one cannot know whether a scheme achieves its goals.

2. **Precise Assumptions.** Unconditional security proofs are rare. Most constructions rely on computational hardness assumptions. These must be stated explicitly — not as vague beliefs ("this cipher is hard to break") but as precisely defined mathematical problems (e.g., "factoring random n-bit products of two primes is infeasible for PPT algorithms").

3. **Proofs of Security.** Given a definition and an assumption, one proves that breaking the scheme would violate the assumption. This is a *reduction*: any efficient adversary against the scheme is transformed into an efficient algorithm solving the hard problem.

### 1.2 What a Proof of Security Actually Means

A security proof is always **relative** — it guarantees security *if*:
- The definition correctly captures real-world threats, **and**
- The computational assumption holds.

A proof does **not** guarantee real-world security unconditionally. It shifts the attack surface: to break a provably secure scheme, an attacker must either violate the assumption or exploit a gap between the definition and reality.

### 1.3 Kerckhoffs' Principle

The security of a cryptosystem must rest entirely in the secrecy of the key. The algorithm itself is assumed to be public and known to the adversary. Justification: keys are easier to replace than algorithms; public designs undergo scrutiny; standardization enables interoperability.

---

## 2. Mathematical Foundations

### 2.1 Probability Theory as a Security Language

Security is defined via **probabilistic experiments** (games) between a challenger and an adversary. Key conventions:

- Random variables: $K$ (key), $M$ (message), $C$ (ciphertext)
- $K$ and $M$ are always assumed **independent**
- Encryption algorithms may be **probabilistic**; decryption is deterministic (perfect correctness assumed)
- $x \leftarrow S$ denotes uniform random selection from set $S$
- $\Pr[E]$ denotes probability of event $E$ over all randomness in the experiment

**Bayes' Theorem** is the central tool for analyzing information leakage:
$$\Pr[M=m \mid C=c] = \frac{\Pr[C=c \mid M=m] \cdot \Pr[M=m]}{\Pr[C=c]}$$

### 2.2 Asymptotic Security Framework

Security is parameterized by a **security parameter** $n$ (typically the key length):

| Term | Definition |
|------|-----------|
| **Negligible function** | $f(n)$ is negligible if for every polynomial $p$, $\exists N$ such that $\forall n > N, f(n) < 1/p(n)$. Written $\mathsf{negl}(n)$. |
| **PPT** | Probabilistic Polynomial-Time — algorithms running in time $\mathrm{poly}(n)$ with access to random bits |
| **Efficient adversary** | Always modeled as a PPT algorithm |

**Closure properties of negligible functions:** The sum and product of any polynomial number of negligible functions is negligible. A polynomial times a negligible function is negligible. These properties are essential for hybrid arguments.

### 2.3 Concrete vs. Asymptotic Security

- **Asymptotic approach:** Security defined in terms of $n \to \infty$; attacks requiring super-polynomial time are considered infeasible
- **Concrete approach:** Security defined in terms of specific bit-operations; e.g., a cipher with $n=256$ broken in $2^{128}$ time is considered *insecure* even though $2^{128}$ is infeasible, because it falls far short of the $2^{256}$ brute-force ideal

Block ciphers (AES) are evaluated concretely: the best known attack should have time complexity roughly equivalent to exhaustive key search.

### 2.4 Entropy

**Min-entropy** of distribution $X$: $\mathbf{H}_\infty(X) = -\log(\max_x \Pr[X=x])$. Measures the probability of guessing $X$ in one try. A distribution with min-entropy $m$ gives the attacker success probability at most $2^{-m}$.

**Computational min-entropy:** A distribution is computationally indistinguishable from one with high min-entropy — the attacker cannot efficiently distinguish it from a high-entropy source.

---

## 3. The Hierarchy of Security Definitions

### 3.1 Perfect Secrecy (Information-Theoretic Security)

**Definition (Shannon):** $\Pr[M=m \mid C=c] = \Pr[M=m]$ for all $m, c$ with $\Pr[C=c] > 0$.

**Equivalent formulation:** For all $m_0, m_1, c$:
$$\Pr[\mathsf{Enc}_K(m_0)=c] = \Pr[\mathsf{Enc}_K(m_1)=c]$$

**Adversarial indistinguishability formulation:** An adversary chooses $m_0, m_1$, receives $\mathsf{Enc}_K(m_b)$ for random $b$, and must guess $b$. Perfect secrecy $\iff$ $\Pr[\text{guess correct}] = 1/2$ for *all* (even unbounded) adversaries.

**The One-Time Pad** (Construction 2.8): $\mathcal{M} = \mathcal{K} = \mathcal{C} = \{0,1\}^\ell$. $\mathsf{Gen}$ outputs uniform $k \in \{0,1\}^\ell$. $\mathsf{Enc}_k(m) = k \oplus m$. $\mathsf{Dec}_k(c) = k \oplus c$. This is perfectly secret.

**Shannon's Theorem:** For perfect secrecy, $|\mathcal{K}| \geq |\mathcal{M}|$. The key must be at least as long as the message. This is the fundamental limitation that motivates computational security.

### 3.2 Computational Security (Relaxing Perfect Secrecy)

Two relaxations:
1. Security only against **efficient** (PPT) adversaries
2. Adversaries may succeed with **negligible** probability

**Definition (EAV-security / indistinguishability in presence of eavesdropper):**
$$\Pr[\mathsf{PrivK}_{\mathcal{A},\Pi}^{\mathsf{eav}}(n)=1] \leq \frac{1}{2} + \mathsf{negl}(n)$$

The experiment: $\mathcal{A}$ outputs $(m_0, m_1)$, challenger returns $\mathsf{Enc}_k(m_b)$ for random $b$, $\mathcal{A}$ guesses $b$. This is **equivalent** to semantic security: whatever can be computed about $m$ from $c$ can also be computed without $c$.

**CPA-Security** (Chosen-Plaintext Attack): The adversary additionally has oracle access to $\mathsf{Enc}_k(\cdot)$ — it can obtain encryptions of plaintexts of its choice. Formally captured via the **LR-oracle** paradigm: adversary accesses $\mathsf{LR}_{k,b}(\cdot,\cdot)$ which, on input $(m_0, m_1)$, returns $\mathsf{Enc}_k(m_b)$.

Fundamental fact: **No deterministic encryption scheme can be CPA-secure.** An adversary can simply query $(m, m')$ to the LR-oracle and compare the result to a challenge. This makes randomized encryption essential.

**CCA-Security** (Chosen-Ciphertext Attack): Adversary additionally has access to a **decryption oracle** $\mathsf{Dec}_k(\cdot)$, with the sole restriction that it cannot query the challenge ciphertext. CCA-security implies **non-malleability**: it is infeasible to transform an encryption of $m$ into an encryption of a related message $m'$.

### 3.3 Multiple Encryptions

**Private-key setting:** EAV-security does **not** imply security for multiple encryptions. If the same key encrypts multiple messages, a deterministic scheme or one with state-based weaknesses can be broken. (Proposition 3.20 gives a counterexample.)

**Public-key setting:** CPA-security **automatically** implies multiple-encryption security. (Theorem 11.6.) This is because the adversary already has the public key and can encrypt anything; the LR-oracle provides no additional power beyond what can be simulated. The proof uses a **hybrid argument**.

### 3.4 Security for Message Authentication Codes (MACs)

**Unforgeability under chosen-message attack:** Adversary queries $\mathsf{Mac}_k(\cdot)$ on messages of its choice, then attempts to output $(m, t)$ where $t$ is a valid tag on $m$ and $m$ was never queried. A MAC is **existentially unforgeable** if no PPT adversary succeeds except with negligible probability.

**Strong MACs:** The adversary may not output $(m, t)$ where $t$ was previously returned as a tag on $m$ (even if a *different* tag on the same message was also valid). Necessary for CCA-secure authenticated encryption.

**Replay attacks:** MACs do not prevent replay; this must be handled at a higher protocol layer (sequence numbers, timestamps).

**Timing attacks on verification:** Canonical verification recomputes $\mathsf{Mac}_k(m)$ and compares to $t$ using string equality. If the comparison is not constant-time, timing side channels can enable forgery. The verification must be time-independent.

### 3.5 Authenticated Encryption (AE)

Encryption alone provides secrecy, not integrity. A scheme that is CPA-secure can be completely malleable. **Authenticated encryption** simultaneously provides secrecy and integrity.

**Definition:** A private-key encryption scheme is an authenticated encryption scheme if it is CCA-secure and has **unforgeable ciphertexts** (it is infeasible to produce any ciphertext that decrypts successfully unless it was legitimately generated).

**Generic constructions:**
- **Encrypt-and-MAC:** $c \leftarrow \mathsf{Enc}_{k_E}(m)$, $t \leftarrow \mathsf{Mac}_{k_M}(m)$, output $(c, t)$. *Insecure* in general (MAC may leak info about $m$).
- **MAC-then-Encrypt:** $t \leftarrow \mathsf{Mac}_{k_M}(m)$, $c \leftarrow \mathsf{Enc}_{k_E}(m\|t)$. Used in SSL/TLS. Can be secure if properly instantiated.
- **Encrypt-then-MAC:** $c \leftarrow \mathsf{Enc}_{k_E}(m)$, $t \leftarrow \mathsf{Mac}_{k_M}(c)$, output $(c, t)$. **Provably secure** when $\mathsf{Enc}$ is CPA-secure and $\mathsf{Mac}$ is strongly unforgeable. This is the recommended approach.

### 3.6 Security for Hash Functions

**Collision resistance:** It is infeasible to find $x \neq x'$ such that $H^s(x) = H^s(x')$. The hash key $s$ is public. Implies **second preimage resistance** (given $x$, find $x' \neq x$ with $H(x') = H(x)$), which implies **preimage resistance** (given $y$, find $x$ with $H(x) = y$). The converses do **not** hold.

**Birthday attacks:** Finding collisions in an $n$-bit hash function requires roughly $2^{n/2}$ evaluations (not $2^n$). The small-space birthday attack (Floyd's cycle-finding) finds collisions with $O(2^{n/2})$ time and *constant* memory. This is why hash functions need output lengths of at least 256 bits.

---

## 4. The Indistinguishability Framework

### 4.1 Computational Indistinguishability (Section 7.8)

Two distribution ensembles $X = \{X_n\}$ and $Y = \{Y_n\}$ are **computationally indistinguishable** (written $X \overset{c}{\equiv} Y$) if for every PPT distinguisher $D$:
$$|\Pr[D(X_n)=1] - \Pr[D(Y_n)=1]| \leq \mathsf{negl}(n)$$

This is the fundamental notion that underpins all computational security definitions.

**Key properties:**
- If $X \overset{c}{\equiv} Y$ and $f$ is polynomial-time computable, then $f(X) \overset{c}{\equiv} f(Y)$
- **Transitivity:** If $X \overset{c}{\equiv} Y$ and $Y \overset{c}{\equiv} Z$, then $X \overset{c}{\equiv} Z$ *(requires care: holds for PPT distinguishers due to the hybrid argument)*

### 4.2 The Cryptographic Indistinguishability Experiment Template

Most security definitions follow this pattern:

1. Setup: Generate keys and/or system parameters
2. Adversary interaction: $\mathcal{A}$ may query oracles (depending on threat model)
3. Challenge: $\mathcal{A}$ outputs $(m_0, m_1)$; challenger picks random $b$, returns $\mathsf{Enc}(m_b)$
4. Post-challenge: $\mathcal{A}$ may continue oracle queries (with restrictions)
5. Decision: $\mathcal{A}$ outputs guess $b'$; success if $b' = b$

Security means $\Pr[b' = b] \leq 1/2 + \mathsf{negl}(n)$.

**Why $1/2 + \mathsf{negl}(n)$ and not just $\mathsf{negl}(n)$?** An adversary can always guess randomly and succeed with probability $1/2$. The advantage over random guessing is what matters.

**Equivalent formulation (Definition 3.9-style):**
$$|\Pr[\mathcal{A}(\mathsf{Enc}_k(m_0))=1] - \Pr[\mathcal{A}(\mathsf{Enc}_k(m_1))=1]| \leq \mathsf{negl}(n)$$

Both formulations are equivalent.

---

## 5. The Reductionist Proof Methodology

### 5.1 Proof by Reduction

The central proof technique in modern cryptography. To prove that scheme $\Pi$ is secure under assumption $P$:

1. Assume, for contradiction, a PPT adversary $\mathcal{A}$ that breaks $\Pi$ with non-negligible advantage
2. Construct a PPT algorithm $\mathcal{A}'$ (the **reduction**) that uses $\mathcal{A}$ as a subroutine to violate assumption $P$
3. Show that if $\mathcal{A}$ succeeds, then $\mathcal{A}'$ succeeds with related probability
4. Conclude: if $P$ is hard, $\Pi$ is secure

**The reduction "runs" the adversary internally**, simulating its view of the security experiment. This simulation must be *perfect* (or computationally indistinguishable from the real experiment) for the reduction to work.

### 5.2 The Distinguisher-to-Adversary Pattern

When proving that $X \overset{c}{\equiv} Y$, a typical proof constructs a PPT **distinguisher** $D$ that:
- Receives a sample from either $X$ or $Y$
- Embeds this sample into a simulated experiment for $\mathcal{A}$
- Outputs whatever $\mathcal{A}$ outputs

Analysis: When input comes from $X$, $\mathcal{A}$'s view is exactly its view in one experiment. When input comes from $Y$, it's the other. So $D$'s advantage equals the difference in $\mathcal{A}$'s success probabilities.

### 5.3 The Hybrid Argument

Used when a system transitions through a sequence of intermediate states. To show $H_0 \overset{c}{\equiv} H_t$:

1. Define hybrid distributions $H_0, H_1, \ldots, H_t$ where adjacent hybrids differ in exactly one component
2. Prove $H_{i-1} \overset{c}{\equiv} H_i$ for each $i$ (by reduction to a single assumption)
3. By transitivity (summing $t$ negligible bounds): $H_0 \overset{c}{\equiv} H_t$

**Critical detail:** If each adjacent pair is indistinguishable with advantage $\leq \varepsilon$, then by the triangle inequality the total advantage is $\leq t \cdot \varepsilon$. Since $t$ is polynomial and $\varepsilon$ is negligible, $t \cdot \varepsilon$ remains negligible. This closure property is why asymptotic security works.

**Example applications:**
- Proof that CPA-security implies multiple-encryption security (Theorem 11.6)
- Proof that a pseudorandom generator can be expanded (Section 7.4.2)
- Any construction that iterates a building block polynomially many times

### 5.4 Game-Hopping Proofs

A modern variant of the hybrid argument. Start with the "real" security game $G_0$. Define a sequence of games $G_0, G_1, \ldots, G_k$ where:
- $G_0$ is the original security experiment
- Each transition $G_i \to G_{i+1}$ changes one aspect that is indistinguishable by some assumption
- $G_k$ is an "ideal" game where security is obvious (e.g., the adversary's success probability is exactly $1/2$)

Bounding the adversary's advantage in $G_0$ reduces to bounding the differences between adjacent games.

---

## 6. Cryptographic Primitives and Their Reductions

### 6.1 One-Way Functions (OWF)

**Definition:** $f: \{0,1\}^* \to \{0,1\}^*$ is one-way if:
1. **Easy to compute:** $f(x)$ is computable in polynomial time
2. **Hard to invert:** For every PPT $\mathcal{A}$, $\Pr[\mathcal{A}(f(x), 1^n) \in f^{-1}(f(x))] \leq \mathsf{negl}(n)$, where $x \leftarrow \{0,1\}^n$

**Candidate OWFs:** Integer multiplication ($f(x,y) = x \cdot y$ for random primes), modular exponentiation ($f(g,x) = g^x$), subset sum.

**OWF is the minimal assumption for symmetric-key cryptography:** The existence of OWFs is equivalent to the existence of pseudorandom generators, pseudorandom functions, MACs, CPA-secure encryption, and digital signatures. This is a profound unifying result (Chapter 7).

### 6.2 Hard-Core Predicates

A **hard-core predicate** $\mathsf{hc}(x)$ of a OWF $f$ is a function that is efficiently computable from $x$, but given only $f(x)$, no PPT adversary can predict $\mathsf{hc}(x)$ with probability better than $1/2 + \mathsf{negl}(n)$.

**Goldreich-Levin Theorem:** Every OWF can be transformed into another OWF with an explicit hard-core predicate. If $f$ is a OWF, then $g(x,r) = (f(x), r)$ is also a OWF, and $\mathsf{hc}(x,r) = \bigoplus_i x_i \cdot r_i$ (the inner product mod 2) is a hard-core predicate.

This is the critical bridge from OWF to pseudorandomness: a OWF with a hard-core predicate yields a single pseudorandom bit.

### 6.3 Pseudorandom Generators (PRG)

**Definition:** $G: \{0,1\}^n \to \{0,1\}^{\ell(n)}$ with $\ell(n) > n$ is a PRG if for every PPT distinguisher $D$:
$$|\Pr[D(G(s)) = 1] - \Pr[D(r) = 1]| \leq \mathsf{negl}(n)$$
where $s \leftarrow \{0,1\}^n$ and $r \leftarrow \{0,1\}^{\ell(n)}$.

**Construction from OWF:** In principle, PRGs exist iff OWFs exist. The construction proceeds via:
1. OWF $\to$ OWF with hard-core predicate (Goldreich-Levin)
2. Hard-core predicate $\to$ PRG with 1-bit expansion: $G(s) = (f(s), \mathsf{hc}(s))$
3. 1-bit expansion $\to$ arbitrary polynomial expansion (iterated construction)

**Stream ciphers** are practical (heuristic) instantiations of PRGs.

### 6.4 Pseudorandom Functions (PRF) and Permutations (PRP)

**PRF:** A keyed function $F_k(\cdot)$ that is computationally indistinguishable from a truly random function. Adversary gets oracle access to either $F_k$ (for random $k$) or a random function $f$, and must distinguish.

**PRP / Block Cipher:** A keyed permutation indistinguishable from a random permutation. A **strong PRP** remains indistinguishable even when the adversary gets access to the inverse permutation $F_k^{-1}$.

**PRF $\Rightarrow$ CPA-secure encryption:** $\mathsf{Enc}_k(m) = (r, F_k(r) \oplus m)$ with random $r$.

**PRP $\Rightarrow$ PRF:** A PRP with sufficiently large block length ($\ell \geq n$) is a PRF (the switching lemma: distinguishing advantage $\leq q^2/2^{\ell+1}$ for $q$ queries).

### 6.5 The Hierarchy of Assumptions

```
OWF  ⟹  PRG  ⟹  PRF  ⟹  PRP  ⟹  CPA-Secure Encryption
  ⟹  MAC  ⟹  CCA-Secure Encryption (via Encrypt-then-MAC)
  ⟹  Digital Signatures
  ⟹  Collision-Resistant Hash Functions (via Merkle-Damgård + CRHF from OWF)
```

This hierarchy shows that **all of symmetric-key cryptography can be built from one-way functions**. However, the generic constructions are inefficient; practical systems use heuristic but efficient primitives (AES, SHA-3).

---

## 7. Number-Theoretic Hardness Assumptions

### 7.1 The Algebraic Framework

Most public-key cryptography operates in algebraic structures:

| Structure | Definition | Relevant Problems |
|-----------|-----------|-------------------|
| $\mathbb{Z}_N^*$ | Invertible elements modulo $N$ | Factoring, RSA |
| Cyclic group $\mathbb{G}$ of prime order $q$ | Generated by $g$: $\mathbb{G} = \{g^0, \ldots, g^{q-1}\}$ | DL, CDH, DDH |
| $\mathbb{Z}_p^*$ (prime $p$) | Multiplicative group modulo $p$ | DL in finite fields |
| Elliptic curve groups | Group of points on $E(\mathbb{F}_p)$ | ECDLP (harder per bit than $\mathbb{Z}_p^*$) |

### 7.2 The Factoring and RSA Assumptions

**Factoring assumption:** Given $N = pq$ (product of random $n$-bit primes), no PPT algorithm can find $p, q$ except with negligible probability.

**RSA assumption:** Given $(N, e, y)$ where $N = pq$, $\gcd(e, \phi(N)) = 1$, and $y = x^e \bmod N$ for random $x \in \mathbb{Z}_N^*$, no PPT algorithm can recover $x$ except with negligible probability.

**Relation:** RSA $\leq$ Factoring. If you can factor $N$, you can break RSA. The converse is not known — RSA could be easier than factoring.

**Key algorithmic fact:** $\phi(N) = (p-1)(q-1)$. From $\phi(N)$ one can factor $N$ (solve quadratic $x^2 - (N-\phi(N)+1)x + N = 0$ to recover $p,q$). Thus computing $\phi(N)$ is equivalent to factoring $N$.

### 7.3 The Discrete Logarithm Family

All in a cyclic group $\mathbb{G}$ of prime order $q$ with generator $g$:

| Problem | Given | Find |
|---------|-------|------|
| **DL** (Discrete Log) | $g^x$ | $x \bmod q$ |
| **CDH** (Computational DH) | $g^x, g^y$ | $g^{xy}$ |
| **DDH** (Decisional DH) | $g^x, g^y, g^z$ | Distinguish $g^{xy}$ from $g^z$ (random $z$) |

**Hardness hierarchy:** DDH $\leq$ CDH $\leq$ DL. In English: solving DL solves CDH solves DDH. The reverse reductions are not known in general.

**Gap-CDH:** CDH remains hard even given a DDH oracle. This is needed for proving CCA-security of DHIES/ECIES in the random-oracle model. Believed to hold for standard groups.

**Group selection matters:**
- $\mathbb{Z}_p^*$ (prime-order subgroup): DDH is easy in the full group (Legendre symbol test); must use the subgroup of quadratic residues of prime order
- Elliptic curve groups: Generally believed to have harder DL per bit, enabling shorter keys
- Pairing-friendly curves: DDH is easy, CDH may still be hard

### 7.4 Chinese Remainder Theorem

If $N = pq$ with $\gcd(p,q)=1$:
- $\mathbb{Z}_N \cong \mathbb{Z}_p \times \mathbb{Z}_q$ (as rings)
- $\mathbb{Z}_N^* \cong \mathbb{Z}_p^* \times \mathbb{Z}_q^*$ (as groups)
- Operations mod $N$ can be done mod $p$ and mod $q$ separately, then combined

This is a **structural decomposition** theorem. It underlies:
- RSA decryption speedup (CRT-based exponentiation)
- Attacks when the same message is encrypted to multiple receivers
- The structure of $\mathbb{Z}_{N^2}^*$ for Paillier encryption

---

## 8. Construction Paradigms

### 8.1 Substitution-Permutation Networks (SPN)

The **confusion-diffusion** paradigm (Shannon):

- **Confusion:** The relationship between key and ciphertext should be complex. Achieved via S-boxes (nonlinear substitution tables).
- **Diffusion:** A single plaintext bit change should affect many ciphertext bits. Achieved via mixing permutations.

An SPN round: Key mixing (XOR) $\to$ Substitution (S-boxes) $\to$ Permutation (bit rearrangement). Repeated for $r$ rounds, with a final key-mixing step.

**Design rationale:** If S-boxes are permutations, the entire SPN is a permutation. Individual rounds are weak, but iterated rounds create exponentially growing diffusion and confusion.

**AES** is an SPN with a more structured design: S-box is an algebraic function (inversion in $\mathbb{F}_{2^8}$) rather than a random lookup table.

### 8.2 Feistel Networks

Split the input into left and right halves $(L_0, R_0)$. For each round $i$:
$$L_i = R_{i-1},\quad R_i = L_{i-1} \oplus f_i(R_{i-1})$$

where $f_i$ are round functions derived from the key. **Crucial advantage:** $f_i$ need NOT be invertible; the Feistel structure is always invertible regardless of $f_i$. This enables building block ciphers without requiring invertible S-boxes.

**DES** is a 16-round Feistel network. **Luby-Rackoff construction:** 3 rounds of Feistel with a PRF give a PRP; 4 rounds give a strong PRP.

### 8.3 Merkle-Damgård Transform

Extends a fixed-length compression function $h: \{0,1\}^{n+b} \to \{0,1\}^n$ to a full hash function $H: \{0,1\}^* \to \{0,1\}^n$:

1. Pad the message to a multiple of $b$ bits, appending the message length $L$
2. Set $z_0 = IV$ (fixed initialization vector)
3. For each $b$-bit block $x_i$: $z_i = h(z_{i-1} \| x_i)$
4. Output $z_{B+1} = h(z_B \| L)$

**Theorem:** If $h$ is collision-resistant, then $H$ is collision-resistant.

Note: preimage/second-preimage resistance of $h$ does **not** necessarily lift to $H$ via Merkle-Damgård. Also, Merkle-Damgård hash functions are trivially distinguishable from random oracles (length-extension attacks).

### 8.4 Hybrid Encryption and the KEM/DEM Paradigm

Public-key encryption is orders of magnitude slower than symmetric encryption. **Hybrid encryption** combines them:

- **KEM** (Key Encapsulation Mechanism): Use public-key cryptography to establish a shared symmetric key $k$
- **DEM** (Data Encapsulation Mechanism): Use symmetric encryption with key $k$ for the actual message

**Efficiency analysis:** For an $\ell$-bit message, the per-bit cost approaches the symmetric encryption cost as $\ell \to \infty$. For a 1MB message, hybrid encryption improves computational efficiency by ~700x and halves ciphertext size vs. block-by-block public-key encryption.

**Security theorem (Theorem 11.12):** If the KEM is CPA-secure and the DEM is EAV-secure (a weaker notion than CPA), the hybrid scheme is CPA-secure. The DEM needs only single-encryption security because a fresh key is used each time.

### 8.5 Hash-and-Sign Paradigm

For digital signatures, the "textbook" approach signs the message directly. In practice:

1. Hash the message: $h = H(m)$
2. Sign the hash: $\sigma = \mathsf{Sign}_{sk}(h)$

**RSA-FDH** (Full Domain Hash): $\sigma = H(m)^d \bmod N$ where $H$ maps to $\mathbb{Z}_N^*$. Proven secure in the random-oracle model.

### 8.6 Fiat-Shamir Transform

Converts a 3-round interactive identification protocol (commitment, challenge, response) into a **non-interactive** signature scheme by replacing the verifier's random challenge with $H(\mathsf{commitment} \| m)$. Security holds in the random-oracle model.

**Schnorr signature scheme** is the canonical example: derived from the Schnorr identification protocol via Fiat-Shamir.

---

## 9. The Random-Oracle Model (ROM)

### 9.1 Definition and Methodology

A **random oracle** is an idealized hash function: a truly random function $H: \{0,1\}^* \to \{0,1\}^n$ accessible to all parties (including the adversary) only via oracle queries. No party has a compact description of $H$.

**Proof technique in ROM:**
1. Design and prove scheme secure assuming $H$ is a random oracle
2. Instantiate $H$ with a concrete hash function (e.g., SHA-3) in practice

### 9.2 ROM-Specific Proof Techniques

**Extractability:** The reduction can see every query the adversary makes to the random oracle. This is impossible in the standard model (the adversary can evaluate a hash function locally).

**Programmability:** The reduction can choose $H$'s outputs adaptively — when the adversary queries $x$, the reduction can return any value it wants, as long as it's consistent and appears random. This enables "embedding" challenges into the hash responses.

**Key observations:**
- ROM proofs make **no computational assumptions** about the hash function itself — they hold for computationally unbounded adversaries as long as oracle queries are polynomially bounded
- ROM enables substantially more efficient schemes than the standard model
- Most deployed public-key schemes have proofs only in the ROM

### 9.3 The ROM Controversy

**Objection:** No concrete hash function can be a true random oracle. The description of any real hash function completely determines its outputs. The extractability and programmability techniques have no real-world counterparts.

**Defense:** A ROM proof shows the design is "sound" — the only possible attacks exploit weaknesses in the hash function. Historically, no properly-instantiated ROM scheme has been broken in practice. A ROM proof is significantly better than no proof.

**Canetti et al.'s negative result:** There exist (contrived) schemes secure in the ROM but insecure for *any* concrete instantiation. This establishes a theoretical limitation but its practical relevance is debated.

**Instantiating random oracles:** "Off-the-shelf" hash functions (especially Merkle-Damgård constructions) are NOT suitable as-is. Length-extension attacks, output-format mismatches, and domain separation issues must be addressed.

---

## 10. Attack Models and Adversarial Reasoning

### 10.1 The Taxonomy of Attacks

**On encryption schemes (increasing power):**

| Attack | Adversary Capability |
|--------|---------------------|
| Ciphertext-only | Observes ciphertext(s) |
| Known-plaintext | Knows some $(m, c)$ pairs |
| Chosen-plaintext (CPA) | Can encrypt chosen messages |
| Chosen-ciphertext (CCA) | Can decrypt chosen ciphertexts (except the challenge) |

**Why CPA is realistic:** In the public-key setting, the adversary always knows the public key and can encrypt arbitrarily. In the symmetric setting: encrypted "hello" messages, predictable headers, or the adversary controlling part of the plaintext (e.g., data fields in a protocol).

**Why CCA is realistic:** Padding-oracle attacks (error messages reveal whether padding is valid), encrypted email (receiver quotes decrypted text in replies), malleability in auctions (transform an encrypted bid into a bid for double the amount).

### 10.2 Malleability

A scheme is **malleable** if, given $c = \mathsf{Enc}(m)$, one can efficiently produce $c'$ that decrypts to $m'$ where $m$ and $m'$ have a known relation. CPA-security does **not** prevent malleability:

- El Gamal: $\langle g^y, h^y \cdot m \rangle \to \langle g^y, h^y \cdot (m \cdot \alpha) \rangle$ (multiply second component)
- Plain RSA: $[m^e \bmod N] \to [m^e \cdot r^e \bmod N]$ (multiply by $r^e$)

**CCA-security $\Rightarrow$ non-malleability.** This is why CCA is essential for applications like auctions, voting, and financial protocols.

### 10.3 Side Channels and Implementation Attacks

The book catalogs several attacks that break provably secure schemes through implementation flaws:

- **Padding-oracle attacks on CBC-mode encryption:** If the server reveals whether decrypted padding is valid, an attacker can recover plaintext byte-by-byte by modifying ciphertext blocks
- **Timing attacks on MAC verification:** Non-constant-time string comparison leaks valid prefixes of the tag
- **WEP attacks on RC4:** The known IV is prepended to the key; the first few plaintext bytes are predictable (protocol headers), enabling key recovery

**Lesson:** A security proof for an abstract scheme says nothing about security of its implementation. Side channels, error handling, and protocol-level interactions must be analyzed separately.

### 10.4 Modeling the Adversary

- The adversary is always **PPT** (probabilistic polynomial-time)
- **No restrictions are placed on the adversary's strategy** — only its computational resources are bounded
- The adversary knows the scheme, the algorithms, and the distribution from which messages are drawn
- The adversary controls the communication channel (can observe, modify, inject messages)
- In the public-key setting, the adversary knows the public key

---

## 11. Essential Theorems and Impossibility Results

### 11.1 Fundamental Limitations

1. **Shannon's Theorem:** For perfect secrecy, $|\mathcal{K}| \geq |\mathcal{M}|$. The key space must be at least as large as the message space.

2. **No perfectly secret public-key encryption** is possible. An unbounded adversary with the public key can always decrypt (encrypt all candidate messages and compare).

3. **No deterministic public-key encryption can be CPA-secure.** (Theorem 11.4.) The adversary who knows the public key can encrypt candidate messages and compare.

4. **No deterministic private-key encryption can be CPA-secure** because the same message always encrypts to the same ciphertext, detectable via the LR-oracle.

5. **Unconditional MACs require long keys:** For information-theoretic MACs with forgery probability $\varepsilon$, the key must be at least $(1-\varepsilon)/\varepsilon$ times the number of authenticated messages. Strong authentication without computational assumptions is expensive.

### 11.2 Provable Impossibilities

6. **No algorithm can efficiently factor all integers.** This is an assumption, not a theorem, but one with centuries of failed attack attempts behind it.

7. **OWF existence $\iff$ PRG existence $\iff$ PRF existence $\iff$ symmetric-key crypto.** This is a theorem (Chapter 7 constructs the chain in one direction; the reverse is trivial).

8. **ROM-secure $\not\Rightarrow$ real-world secure.** Canetti et al. showed there exist (contrived) schemes for which this fails.

### 11.3 Key Security Reductions

9. **CPA-secure public-key encryption $\iff$ indistinguishable multiple encryptions** in the public-key setting. (Theorem 11.6.)

10. **DDH $\Rightarrow$ CPA-secure El Gamal.** (Theorem 11.18.)

11. **RSA assumption $\not\Rightarrow$ CPA-secure plain RSA.** Multiple concrete attacks demonstrate this (quadratic improvement, Coppersmith's theorem, related-message attacks, broadcast attacks).

12. **Encrypt-then-MAC with CPA-secure encryption and strongly unforgeable MAC $\Rightarrow$ CCA-secure private-key encryption.** (Theorem 4.19.)

13. **Collision-resistant compression function $\Rightarrow$ collision-resistant hash function** via Merkle-Damgård. (Theorem 5.4.)

---

## 12. Proof Technique Toolkit

### 12.1 Reduction Construction Patterns

**Pattern 1 — Direct simulation:** $\mathcal{A}'$ generates all keys and parameters itself, runs $\mathcal{A}$ as a subroutine, and responds to $\mathcal{A}$'s oracle queries using its knowledge of the scheme internals. Used when proving CPA-security of encryption from PRFs (Construction 3.17 proof).

**Pattern 2 — Embedding a challenge:** $\mathcal{A}'$ receives an external challenge (e.g., "is this a PRF or random function?"), embeds it into the simulation for $\mathcal{A}$ such that $\mathcal{A}$'s success directly translates to distinguishing power. Used in proofs of CPA-security from PRFs.

**Pattern 3 — Random guessing with probability amplification:** $\mathcal{A}'$ guesses which of $\mathcal{A}$'s queries will be the critical one (e.g., which LR-oracle query is the pivotal one), and succeeds with probability inversely proportional to the number of queries. The overall advantage degrades by a polynomial factor but remains non-negligible if $\mathcal{A}$'s advantage is non-negligible.

**Pattern 4 — Oracle query inspection (ROM):** In the random-oracle model, $\mathcal{A}'$ monitors $\mathcal{A}$'s queries to the random oracle. If $\mathcal{A}$ queries the "right" value (the one that would break the assumption), $\mathcal{A}'$ captures it and solves the hard problem. Otherwise, the random oracle's output on unqueried points is uniformly random, making $\mathcal{A}$'s task information-theoretically impossible.

### 12.2 Probability Lemmas

**Union bound:** $\Pr[A \cup B] \leq \Pr[A] + \Pr[B]$. Essential for bounding the probability that any of polynomially many "bad events" occurs.

**Bayes' Theorem:** Used in every information-theoretic security proof. The standard perfect secrecy proof rearranges $\Pr[M=m \mid C=c]$ using Bayes.

**Difference lemma:** For any events $A, B$ with $\Pr[A \mid \neg B] = \Pr[A' \mid \neg B]$, we have $|\Pr[A] - \Pr[A']| \leq \Pr[B]$. Used when two experiments are identical unless a particular "bad" event occurs.

**Switching lemma:** A random permutation on $\{0,1\}^\ell$ is indistinguishable from a random function with advantage $\leq q^2/2^{\ell+1}$ after $q$ queries. This is why PRPs can substitute for PRFs in many constructions.

### 12.3 Common Pitfalls in Cryptographic Reasoning

1. **Confusing necessary and sufficient conditions.** A large key space is necessary but not sufficient for security (mono-alphabetic substitution has $26! \approx 2^{88}$ keys and is trivially broken).

2. **Assuming deterministic encryption is acceptable if messages are "random."** Even for random messages, deterministic encryption reveals equality of encrypted messages and is not CPA-secure. The quadratic-improvement attack on plain RSA shows that even random messages are vulnerable.

3. **Conflating "key recovery is hard" with "the scheme is secure."** $\mathsf{Enc}_k(m) = m$ makes key recovery impossible but provides no security.

4. **Using the same key for encryption and MAC.** Independence of keys is essential in generic compositions. The Encrypt-then-MAC construction requires independent keys $k_E, k_M$.

5. **Assuming ROM proofs imply real-world security.** The random-oracle model is a heuristic. Real hash functions are not random oracles. A ROM proof is better than no proof but weaker than a standard-model proof.

6. **Reusing randomness across encryptions.** A PRG/stem-cipher in synchronized mode requires unique IVs. IV reuse is catastrophic (XOR of two plaintexts is revealed).

7. **Ignoring the message space.** Plain RSA on messages much smaller than $N^{1/e}$ is broken by taking integer $e$-th roots. The encoding of messages into the scheme's mathematical domain must be carefully designed.

8. **Verifying MACs with non-constant-time comparison.** String comparison using `memcmp` (which short-circuits on mismatch) enables timing attacks that forge valid tags.

---

## 13. Information-Theoretic vs. Computational Security — The Philosophical Divide

### 13.1 Perfect Secrecy

- Adversary: **Unbounded** computational power
- Security: **Absolute** — $\Pr[M=m \mid C=c] = \Pr[M=m]$
- Cost: Key length $\geq$ message length (Shannon's theorem)
- Example: One-time pad
- Limitations: Impractical for most applications due to key management

### 13.2 Computational Security

- Adversary: **Polynomial-time** bounded
- Security: **Probabilistic** — success probability $\leq 1/2 + \mathsf{negl}(n)$
- Cost: Short keys (e.g., 128 bits) can encrypt arbitrary-length messages
- Examples: AES-based encryption, RSA, El Gamal
- Limitations: Security rests on unproven assumptions

### 13.3 The Conceptual Bridge

The transition from perfect to computational security is achieved by three relaxations:
1. Security only against **efficient** strategies
2. Adversaries may succeed with **negligible** probability
3. Security relies on **unproven but widely believed** hardness assumptions

This is the fundamental conceptual trade-off of modern cryptography: accept unproven assumptions and bounded adversaries in exchange for practical efficiency.

### 13.4 When to Use Which Framework

- **Information-theoretic:** When key material can be pre-shared in equal quantity to messages, when unconditional guarantees are required regardless of computational advances, or for building blocks within larger constructions (e.g., Shamir secret sharing)
- **Computational:** For virtually all practical systems — key exchange, secure communication, digital signatures, authentication
- **Hybrid:** Use public-key crypto to establish a symmetric key (computationally secure), then use symmetric crypto for bulk encryption (computationally secure, but the overall system inherits the public-key assumptions)

---

## 14. Domain-Specific Design Principles

### 14.1 For Symmetric Encryption

- Randomization is **mandatory** for CPA-security
- Independent randomness per encryption (random IV or nonce)
- The same key should not be used for both encryption and MAC (use derived keys)
- Encrypt-then-MAC is the recommended authenticated encryption composition
- Block ciphers in CTR mode act as stream ciphers; CBC mode requires padding and is vulnerable to padding oracles

### 14.2 For Public-Key Encryption

- Deterministic schemes are **unconditionally insecure** (encrypt-and-compare attack)
- Message encoding into the mathematical domain must be randomized and carefully designed (OAEP for RSA)
- Hybrid encryption (KEM/DEM) is preferred for efficiency
- CCA-security is essential for most applications (email, auctions, financial protocols)
- Key lengths for RSA must be much larger than for elliptic-curve-based schemes for equivalent security

### 14.3 For Hash Functions

- Output length must be at least 256 bits (birthday bound: $2^{128}$ operations for collision)
- Merkle-Damgård constructions are **not** random oracles (length extension)
- Password hashing requires salts (against precomputation) and iteration/slowness (against brute force)
- The random-oracle model is a useful design heuristic but has known theoretical limitations

### 14.4 For Digital Signatures

- Hash-then-sign: never sign raw messages; hash first
- RSA signatures require padding (PSS, FDH) — plain RSA signatures are universally forgeable
- Ephemeral randomness in DSA/ECDSA must be truly random and unique per signature (repeated nonce reveals private key)
- The Fiat-Shamir transform converts interactive identification to signatures (in the ROM)

---

## 15. Mathematical Tools Reference

### 15.1 Number Theory

- **Euler's theorem:** $a^{\phi(N)} \equiv 1 \pmod{N}$ for $\gcd(a,N)=1$
- **Fermat's little theorem:** $a^{p-1} \equiv 1 \pmod{p}$ for prime $p$, $a \not\equiv 0 \pmod{p}$
- **Chinese Remainder Theorem:** System $x \equiv a_i \pmod{n_i}$ with pairwise coprime $n_i$ has unique solution mod $\prod n_i$
- **Miller-Rabin primality test:** Efficient probabilistic primality testing; deterministic variants exist for numbers below certain bounds
- **Extended Euclidean algorithm:** Computes $\gcd(a,b)$ and finds $x,y$ such that $ax + by = \gcd(a,b)$; used for modular inverse $a^{-1} \bmod N$

### 15.2 Group Theory

- A group $(\mathbb{G}, \cdot)$ satisfies closure, associativity, identity, inverses
- **Cyclic group:** $\mathbb{G} = \{g^0, g^1, \ldots, g^{q-1}\}$ where $g$ is a generator and $q = |\mathbb{G}|$
- **Lagrange's theorem:** The order of any subgroup divides the order of the group
- $\mathbb{Z}_N^*$ has order $\phi(N)$
- If $p$ is prime, $\mathbb{Z}_p^*$ is cyclic of order $p-1$
- **Quadratic residues:** Elements with square roots modulo $p$; form a subgroup of index 2 in $\mathbb{Z}_p^*$
- $\mathbb{Z}_{N^2}^*$ has order $N \cdot \phi(N)$; its structure enables Paillier's homomorphic encryption

### 15.3 Probability

- A function $f(n)$ is **overwhelming** if $1 - f(n)$ is negligible
- **Birthday problem:** With $q$ uniform draws from a set of size $N$, collision probability $\approx q^2/2N$ for $q \ll N$. For $q \approx \sqrt{N}$, probability $\approx 1/2$
- **Hoeffding/Chernoff bounds:** Concentration inequalities for sums of independent random variables

### 15.4 Asymptotics

- $f(n) = O(g(n))$: $\exists c, N$ such that $\forall n > N, f(n) \leq c \cdot g(n)$
- $f(n) = \Omega(g(n))$: $\exists c, N$ such that $\forall n > N, f(n) \geq c \cdot g(n)$
- $f(n) = \Theta(g(n))$: both $O$ and $\Omega$
- $f(n)$ is **polynomial** if $f(n) = O(n^c)$ for some constant $c$
- $f(n)$ is **super-polynomial** if $f(n) = \omega(n^c)$ for every $c$
- $f(n)$ is **negligible** if $f(n) = o(n^{-c})$ for every $c$

---

## 16. Applying Cryptographic Thinking to Other Domains

### 16.1 The Security-Modeling Methodology

The modern cryptographic approach provides a general methodology for reasoning about any adversarial setting:

1. **Define the threat model.** What capabilities does the adversary have? What is the system assumed to protect? What constitutes a "break"?

2. **State assumptions precisely.** What do you assume cannot be broken, guessed, or circumvented? Are these assumptions falsifiable?

3. **Prove security by reduction.** Show that any adversary breaking the system could be used to violate an assumption. This transforms the security question into a computational hardness question.

4. **Identify gaps.** What aspects of reality are not captured by the model? Side channels? Implementation flaws? Protocol-level interactions?

### 16.2 Transferable Concepts

**The adversary's advantage over random guessing** as the measure of security. This binariessecurity as a continuous quantity — the advantage — rather than a binary secure/insecure judgment.

**Composition does not preserve security.** A secure component used in an insecure way produces an insecure system. The Encrypt-and-MAC composition is the canonical example: both components are individually secure, but the combination can leak information.

**Necessary vs. sufficient conditions.** A formal definition tells you what must be achieved; a proof tells you that your construction achieves it. Without both, you're in the realm of heuristics.

**Assumption minimization.** Given two schemes with equivalent security but different assumptions, prefer the one with the weaker (i.e., less demanding) or better-studied assumption.

**The limits of provable security.** A proof guarantees security *relative to* a model and assumptions. It does not guarantee security in reality. The attacker's job is to find the gap between model and reality, or to break the assumption. Provable security doesn't end the attacker-defender battle — it reframes it.
