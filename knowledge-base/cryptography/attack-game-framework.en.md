# Attack Game Framework

## Minimal Definition
An attack game is a formalized interaction between challenger $\mathcal{C}$ and adversary $\mathcal{A}$ used to define "security." Security = no PPT adversary $\mathcal{A}$ wins the game with non-negligible probability. This is cryptography's unified paradigm for turning "intuitively secure" into provable property.

Typical game structure:
1. **Initialization**: challenger generates keys / system parameters
2. **Training phase (queries)**: adversary may query the challenger's oracles (encryption / decryption / signature, etc.), constrained by the threat model (CPA / CCA1 / CCA2)
3. **Challenge**: adversary submits two challenge messages $m_0, m_1$; challenger picks random $b$ and returns $c=\mathsf{Enc}_k(m_b)$
4. **Post-challenge queries** (depending on threat model): adversary may continue querying (except the challenge ciphertext itself)
5. **Output guess**: adversary outputs $b'$; wins iff $b'=b$

## Core Formulas
- **Advantage (two-experiment)**: $\mathsf{Adv}_{\mathcal{A}}=|\Pr[W_0]-\Pr[W_1]|$, where $W_i$ is the event that the adversary outputs 1 in experiment $i$
- **Advantage (bit-guessing)**: $\mathsf{Adv}^{*}_{\mathcal{A}}=2\cdot\Pr[b'=b]-1$, equivalent to the two-experiment form: $\mathsf{Adv}^{*}=2\cdot\mathsf{Adv}$
- **Reduction closure**: $\mathsf{poly}\cdot\mathsf{neg}=\mathsf{neg}$; $\mathsf{neg}+\mathsf{neg}=\mathsf{neg}$; enables hybrid arguments
- **Birthday bound**: collision probability in $q$ random queries $\le q^{2}/2^{n}$, giving the lower bound on query count for birthday attacks
- **Security = negligible advantage**: a scheme is secure iff for all PPT $\mathcal{A}$, $\mathsf{Adv}_{\mathcal{A}}\le\mathsf{negl}(n)$

## Applicable Problems
- Any AI scenario requiring formal threat models:
  - **White-box vs black-box vs adaptive adversaries**: hierarchical ML robustness threat modeling
  - **Adversarial examples**: adversary capability budget (perturbation norm) + win condition (misclassification) + unbreakability proof
  - **Model extraction**: adversary has bounded query count + extraction success rate is negligible
  - **Data poisoning**: adversary can modify a fraction of training data + performance degradation is negligible
  - **Backdoor detection**: adversary implants backdoor but cannot be identified by a detector
  - **Watermark traceability proof**: adversary removes watermark ⇒ fails with non-negligible probability
  - **Verifiable inference**: adversary forges inference output ⇒ solves some hard assumption

## AI Design Translation
- **Applying attack games to ML robustness**: define adversary capability budget (perturbation $\|\delta\|_p\le\epsilon$) → define win condition (misclassification or confidence shift) → prove unbreakability. This turns "intuitively robust" into a provable property. Note: adversary capabilities are hard to formalize strictly in ML, often requiring assumptions about the adversary's attack algorithm class.
- **Hierarchical threat models**: CPA / CCA / AE correspond to ML's "black-box query budget / white-box gradient access / adaptive adversarial training." Hierarchy choice determines threat strength.
- **Advantage bounds as robustness certificates**: provide bounds of the form $\mathsf{Adv}_{\mathcal{A}}\le\mathsf{negl}(n)$ as "relative security" certificates.
- See `../../design-patterns/` for corresponding patterns (e.g., constraint-penalty); if no match, label as "temporary design translation."

## Engineering Feasibility
The attack game framework is pure methodology, not GPU:
- Game definitions are logical constructs, not tensor operations
- Advantage bound computations are mathematical reasoning, not GPU kernels
- Adversary capability modeling is threat modeling, not low-precision numerics
GPU 8-dimension assessment does not apply; cryptographic outputs pass reduction tightness + assumption dependency + implementation pitfall checks (not the GPU gate). See the "Cryptographic GPU Friendliness Warnings" section in `../../references/gpu-friendly-math.en.md`.

## Risks and Failure Conditions
- **Adversary capability modeling too weak**: if the game formalization models adversary capabilities too weakly (e.g., only $L_\infty$ perturbations while ignoring $L_2$, $L_0$), "secure in game but insecure in practice" — the most common failure mode in ML robustness proofs
- **Adversary capabilities hard to formalize in ML**: real attackers may use any algorithm; formalization often restricts the adversary to a class (e.g., PGD attack class), but real attacks may exceed that class
- **Negligible function defined under polynomial security parameter**: $\mathsf{negl}(n)$ requires $n$ to be the security parameter; ML parameter scales may break the bound (e.g., if $n$ is the input dimension and $n\to\infty$, $\mathsf{negl}(n)$ is uncontrolled)
- **Adversary query budget vs deployment mismatch**: the game may bound adversary queries to $q$, but in deployment the query count may be unbounded
- **Reduction closure assumption dependency**: $\mathsf{poly}\cdot\mathsf{neg}=\mathsf{neg}$ requires the adversary to be PPT; non-polynomial adversaries (e.g., exponential time) invalidate the proof
- **Randomness assumptions**: the game requires the challenger to be truly random; whether randomness in ML (e.g., PRNG seeds) is truly random must be verified

## Further References
- Distilled notes: `../../references/books/applied-cryptography.md` (§2 attack game framework, §2.2 advantage definition, §2.3 PPT + negligible functions)
- Distilled notes: `../../references/books/foundations-of-cryptography.md` (§III definitional methodology)
- Distilled notes: `../../references/books/introduction-to-modern-cryptography.md` (formal security definitions)
- Original books: Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §2; Goldreich, *Foundations of Cryptography Vol. 1*, §III

## Routing Extensions
- If reductions are needed → `reduction-proof-template.en.md` (black-box reductions, tightness analysis)
- If threat hierarchy is needed → `cca-cpa-ae-hierarchy.en.md` (CPA/CCA/AE)
- If assumption formalization is needed → `prf-prg-owf.en.md` (OWF/PRG/PRF)
- If a game-theoretic view is needed → `../../lenses/game.en.md` (multi-agent strategic interaction)
- If probability tools are needed → `../probability/concentration-inequality.en.md` (birthday bounds, advantage accumulation)

## Extensible Directions
- UC framework (Universal Composability): universally composable security definitions
- Simulation paradigm: equivalence between adversary view and simulator view
- Zero-knowledge games: three tiers — perfect / statistical / computational zero-knowledge
- Multi-party games: security definitions for multi-party protocols (BEKW framework)
- Fine-grained security games: parameterized concrete security bounds
- Quantum-adversary games: security definitions under quantum computational power
