# PRF, PRG, and OWF

## Minimal Definition
- **One-Way Function (OWF)**: a polynomial-time computable function $f$ that no PPT adversary can invert with non-negligible probability: $\Pr[f(\mathcal{A}(f(x)))=f(x)]\le\mathsf{negl}(n)$.
- **Pseudorandom Generator (PRG)**: a deterministic polynomial-time algorithm $\mathcal{G}:\{0,1\}^{n}\to\{0,1\}^{m(n)}$, $m(n)>n$, whose output is computationally indistinguishable from uniform.
- **Pseudorandom Function Family (PRF)**: a keyed function family $\{F_k\}_{k\in\mathcal{K}}$ computationally indistinguishable from a truly random function family.
- **Equivalence chain** (core structural theorem of cryptography): OWF ⇔ PRG (HILL theorem, 1989); PRG ⇒ PRF (GGM tree construction, Goldreich-Goldwasser-Micali); PRF ⇒ PRP (Luby-Rackoff, 4-round Feistel).

## Core Formulas
- **OWF definition**: $f$ polynomial-time computable, $\forall\mathsf{PPT}\,\mathcal{A}$: $\Pr_{x\leftarrow\{0,1\}^{n}}\big[f(\mathcal{A}(f(x),1^{n}))=f(x)\big]\le\mathsf{negl}(n)$.
- **PRG computational indistinguishability**: $\{\mathcal{G}(U_n)\}_{n}\stackrel{c}{\approx}\{U_{m(n)}\}_{n}$, $m(n)>n$, advantage $\mathsf{Adv}^{\mathsf{prg}}(\mathcal{D})=|\Pr[\mathcal{D}(\mathcal{G}(U_n))=1]-\Pr[\mathcal{D}(U_{m(n)})=1]|$.
- **PRF security game**: adversary may query $F_k$ or truly random $\mathcal{R}$; challenger picks random $b$; $\mathsf{Adv}^{\mathsf{prf}}_{\mathcal{A}}=|\Pr[\mathcal{A}^{F_k}=1]-\Pr[\mathcal{A}^{\mathcal{R}}=1]|$, secure iff negligible for all PPT $\mathcal{A}$.
- **PRP Switching Lemma** (PRP used as PRF): distinguishing $n$-bit PRP from a random function in $q$ queries has advantage $\le q^{2}/2^{n+1}$.
- **GGM construction**: from length-doubling PRG $\mathcal{G}:\{0,1\}^{n}\to\{0,1\}^{2n}$, build PRF $F_k(x_1\cdots x_n)=\mathcal{G}_{x_n}\circ\cdots\circ\mathcal{G}_{x_1}(k)$, a binary tree of depth $n$.
- **Luby-Rackoff**: 4-round Feistel turns PRF into PRP (strong pseudorandom permutation requires 3 rounds of PRF + 3 rounds of invertibility).

## Applicable Problems
- AI scenarios requiring "verifiable pseudorandomness": unpredictable routing seeds, reproducible data partitioning, randomized algorithm seed management
- Scenarios requiring "hard-to-invert mappings": hash attention, verifiable watermarking via hash chains
- Formalizing "pseudorandomness" in robustness proofs: adversarial examples are not formally random noise
- Formal "identifiable vs truly random" distribution evaluation: generative vs real distributions
- Key derivation in cryptographic pipelines: master key → sub-keys

## AI Design Translation
- **PRF as verifiable pseudorandom source**: use PRF to generate routing seeds / data partitioning / projection sampling, ensuring reproducibility and adversary unpredictability. Lands at: D1/D2, small overhead, GEMM-friendly.
- **OWF as hard-to-invert mapping design pattern**: hash attention (OWF transform of query prevents inversion), verifiable watermarking (OWF embedded in weights).
- **Unpredictability ⇔ pseudorandomness (Yao's theorem) transfer**: next-token unpredictability ⇒ overall pseudorandomness; usable as theoretical language for generative model evaluation.
- See `../../design-patterns/` for corresponding patterns (e.g., constraint-penalty, shared-private-decomposition); if no match, label as "temporary design translation."

## Engineering Feasibility
Cryptographic primitives have mixed GPU friendliness:
- **AES-NI / SHA-NI**: run on dedicated instructions, not GEMM (violates D1/D2), low SM occupancy
- **GGM tree construction**: cascaded PRG is a sequentially unrolled binary tree, poor parallelism (violates D6); theoretical existence proof, not practical
- **PRF evaluation**: $F_k(x)$ is usually a small GEMM or lookup (D2-friendly)
- **Hadamard inner product (Goldreich-Levin)**: tensorizable but used in cryptography, not ML
- **Mathematical methodology layer does not land on GPU**: equivalence chains, definitions, reduction proofs are pure logical reasoning
GPU 8-dimension assessment: see the "Cryptographic GPU Friendliness Warnings" section in `../../references/gpu-friendly-math.en.md`.

## Risks and Failure Conditions
- **HILL construction constants are enormous**: the OWF ⇒ PRG reduction is polynomial but practically unusable; theoretical existence proof, not practical construction
- **GGM tree depth is bounded**: practical construction depth $n$ is limited; long PRF key sequences are costly
- **Empirical PRF assumption dependency**: using AES as a PRF is an **assumption, not a theorem** — AES is not proven to be a PRF, only empirically strong. Any proof taking "AES is a PRF" as a premise is substituting the AES assumption for the PRF assumption
- **Quantum threats**: Grover halves the effective security bits of symmetric primitives (AES-128 → 64-bit security under quantum); Shor breaks RSA/DL but not symmetric primitives
- **Unpredictability assumption transfer risk**: moving "next-bit unpredictability ⇒ overall pseudorandomness" to ML sequences requires hybrid length $n$ to be polynomial; non-polynomial $n$ breaks the argument
- **Distribution drift breaks reductions**: reductions require adversary inputs to match specific distributions; ML distribution drift breaks assumptions

## Further References
- Distilled notes: `../../references/books/foundations-of-cryptography.md` (§III OWF/PRG equivalence, §V GGM construction, §5.1 Goldreich-Levin hardcore bit)
- Distilled notes: `../../references/books/applied-cryptography.md` (§5 PRP/PRF, §14 assumption families)
- Original books: Goldreich, *Foundations of Cryptography Vol. 1*, §2-§3, §7; Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §5, §14

## Routing Extensions
- If reduction proofs are needed → `reduction-proof-template.en.md` (black-box reductions, tightness analysis)
- If attack-game formalization is needed → `attack-game-framework.en.md` (challenger-vs-adversary framework)
- If security hierarchy is needed → `cca-cpa-ae-hierarchy.en.md` (CPA/CCA/AE threat models)
- If probability tools are needed → `../probability/concentration-inequality.en.md` (birthday attacks, advantage bounds)
- If a game-theoretic view is needed → `../../lenses/game.en.md` (multi-agent strategic interaction)

## Extensible Directions
- PRP/SPRP (strong pseudorandom permutations): stronger variants
- Correlation-robust PRG: resists correlated-input attacks
- PRF under non-uniform assumptions: circuit adversaries vs Turing machine adversaries
- Quantum-secure PRF: resists quantum adversaries
- Extractable OWF: foundation for knowledge-sound arguments
- Input-indistinguishable PRF: for functional encryption
