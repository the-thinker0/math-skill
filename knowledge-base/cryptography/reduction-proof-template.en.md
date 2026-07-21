# Reduction Proof Template

## Minimal Definition
A reduction proof is the constructive reasoning paradigm "breaking scheme $Y$ ⇒ solving hard assumption $X$." The core is constructing a PPT algorithm $\mathcal{B}$ (called a reduction/wrapper) that uses adversary $\mathcal{A}$ as a subroutine: if $\mathcal{A}$ breaks $Y$ with advantage $\varepsilon$, then $\mathcal{B}$ solves $X$ with advantage $\varepsilon'=\mathsf{poly}(\varepsilon)$. Therefore, if $X$ is hard, $Y$ is secure.

Reduction proofs are cryptography's standard paradigm for formalizing "relative security": security is not an absolute property but "relative unbreakability under the assumption that $X$ is hard."

## Core Formulas
- **Reduction tightness**: $\varepsilon_{\mathsf{scheme}}\le Q\cdot\varepsilon_{\mathsf{assumption}}$, where $Q$ is the number of queries / hybrid steps / loss factor in the reduction; larger $Q$ means looser reduction
- **Reduction success probability**: $\Pr[\mathcal{B}^{O_X}\text{ wins}]\ge\frac{\varepsilon_{\mathcal{A}}}{\mathsf{poly}(n)}$, where $\varepsilon_{\mathcal{A}}$ is the adversary's advantage
- **Difference Lemma (sequence games)**: if $W_0$ and $W_1$ differ only in some "bad event" branch, then $|\Pr[W_0]-\Pr[W_1]|\le\Pr[\text{bad}]$
- **Hybrid argument**: $H^i$ and $H^{i+1}$ are indistinguishable, a $\mathsf{poly}(n)$-step hybrid chain ⇒ $H^0$ and $H^{\mathsf{poly}(n)}$ are indistinguishable; advantages add up $\varepsilon\le n\cdot\varepsilon_{\text{step}}$
- **Reduction closure**: $\mathsf{poly}\cdot\mathsf{neg}=\mathsf{neg}$, $\mathsf{neg}+\mathsf{neg}=\mathsf{neg}$, $\mathsf{poly}\cdot\mathsf{poly}=\mathsf{poly}$ — closure of polynomial degrees is the foundation of hybrid arguments

## Applicable Problems
- Any AI research scenario requiring "relative security" certificates:
  - Model robustness certificates: breaking robustness ⇒ solving some hard assumption (semantic separability, LWE)
  - Verifiable inference: inference outputs are verifiable but unforgeable ⇒ solving some hard assumption
  - Model watermark unforgeability: watermark verifiable but unforgeable ⇒ OWF
  - Adversarial example reductions: constructing an attack ⇒ solving a hard assumption; or conversely: solving an assumption ⇒ attack exists
  - Privacy guarantees: model outputs ⇒ training data leakage ⇒ solving a differential privacy assumption
- Distribution drift analysis: splitting multi-step training distribution drift into single-step bounds
- Weak-to-strong amplification: weak learners amplified into strong learners (PAC-boosting mirror)

## AI Design Translation
- **Reduction paradigm transfer to ML safety**: apply the "break-scheme ⇒ solve-assumption" framework to ML robustness — if a reduction can be constructed from "attacking robustness" to "solving some hard assumption," a "relative security" certificate results. Note: ML distribution drift breaks reduction assumptions.
- **Hybrid argument transfer to distribution drift**: split multi-step training distribution drift into adjacent hybrids, where adjacent differences are bounded ⇒ total drift is bounded. Hybrid steps must be $\mathsf{poly}(n)$, otherwise the argument fails.
- **Simulation paradigm transfer to privacy certificates**: construct a simulator proving "model output is independently generatable" ⇒ training data not leaked.
- See `../../design-patterns/` for corresponding patterns (e.g., constraint-penalty, information-bottleneck-loss); if no match, label as "temporary design translation."

## Engineering Feasibility
Reduction proofs are pure methodology and do not land on GPU:
- The reduction $\mathcal{B}$ is a logical construct, not a tensor operation
- Hybrid arguments and simulation paradigms are reasoning tools, not GPU kernels
- Tightness analysis is mathematical reasoning, not low-precision numerics
GPU 8-dimension assessment does not apply here; cryptographic outputs do not pass the GPU acceptance gate (see the "Cryptographic GPU Friendliness Warnings" section in `../../references/gpu-friendly-math.en.md`). Corresponding Domain Router rule: the cryptography domain uses "reduction tightness + assumption dependency + implementation pitfall checks," not the GPU 8-dimension gate.

## Risks and Failure Conditions
- **Loose reductions (large $Q$) require parameter compensation**: e.g., RSA-FDH signature reduction tightness $\varepsilon_{\mathsf{sig}}\approx q_H\cdot\varepsilon_{\mathsf{RSA}}$ requires doubling the modulus to compensate; claiming "loose reduction = secure" is an anti-pattern
- **ROM reductions have counterexamples**: proofs in the Random Oracle Model have counterexamples — schemes secure in ROM but insecure under any concrete instantiation. Treating ROM proofs as absolute guarantees is an anti-pattern
- **Black-box separation results limit**: some reductions are impossible in the black-box model — e.g., one-way permutation ⇒ unforgeable signatures is impossible under certain black-box reductions, requiring non-black-box techniques
- **ML distribution drift breaks reduction assumptions**: reductions require adversary inputs to match specific distributions; ML training-deployment distribution drift breaks the distribution-matching premise
- **Assumption achievability needs re-examination**: when transferring cryptographic assumptions to ML, whether the original assumption (e.g., PRF assumption) is achievable in the ML deployment context must be re-examined — e.g., whether randomness in ML training is truly random, whether key management is secure
- **Simulator complexity**: the simulation paradigm requires the simulator to be PPT; if simulator complexity is uncontrolled, the zero-knowledge proof fails

## Further References
- Distilled notes: `../../references/books/foundations-of-cryptography.md` (§IV reduction arguments, hybrid, amplification, simulation paradigm, unpredictability ⇔ pseudorandomness)
- Distilled notes: `../../references/books/applied-cryptography.md` (§3 reduction proof template, §3.4-3.5 sequence games + Difference Lemma, §10.3 reduction tightness)
- Original books: Goldreich, *Foundations of Cryptography Vol. 1*, §4; Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §3, §10.3

## Routing Extensions
- If assumption formalization is needed → `prf-prg-owf.en.md` (OWF/PRG/PRF assumptions)
- If attack games are needed → `attack-game-framework.en.md` (challenger vs adversary)
- If security hierarchy is needed → `cca-cpa-ae-hierarchy.en.md` (CPA/CCA/AE)
- If a game-theoretic view is needed → `../../lenses/game.en.md` (mechanism design, equilibrium)
- If a causal view is needed → `../../lenses/causal.en.md` ("break Y ⇒ break X" is a causal chain)

## Extensible Directions
- Concrete security: non-asymptotic concrete security bounds
- Non-black-box reductions: leveraging adversary code's internal structure
- Reduction lower bounds: proving reduction tightness cannot be improved
- ROM reductions and counterexamples: provability and limitations of the random oracle model
- QROM (quantum random oracle): ROM proofs under quantum adversaries
- Fine-grained reductions: parameterized fine-grained reductions
