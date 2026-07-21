# Foundations of Cryptography

> Oded Goldreich, *Foundations of Cryptography, Volume 1: Basic Tools*, Cambridge University Press, 2001. A theoretical foundation unified by **definition methodology and constructive reductions**.

## Overview

The book's central contribution is methodological: it replaces informal security intuition with explicit definitions, computational assumptions, and reductions. Classical efficient adversaries are commonly modeled as probabilistic polynomial-time algorithms, but PPT is a modeling convention—not the set of every practical attack. Quantum computation, nonuniform circuits, side channels, and concrete resources require additional models.

Good cryptographic definitions formalize the intended intuition, exclude trivial constructions, permit constructions, and support reductions. The book develops implication and construction relations among primitives such as OWFs, PRGs, and PRFs.

**Activation boundary:** This is a theory-and-meta-theorem reference, not a deployment manual. Many generic constructions establish existence but are too inefficient for practice. Use it for definitions, assumption dependencies, reductions, and impossibility boundaries; use implementation references for concrete systems.

## Core Structures and Cross-Domain Boundaries

| Theoretical structure | What transfers—and what does not |
|---|---|
| **Computational indistinguishability (§2.2)** | Defines “cannot be distinguished” relative to efficient distinguishers. It is not statistical closeness; an ML transfer must redefine the security parameter, distinguisher class, and sampling interface. |
| **PPT and negligible functions (§2.1, §2.3)** | An asymptotic quantifier framework; deployment also needs explicit time, query, and success bounds. |
| **OWF/PRG/PRF construction chain (Parts III, V)** | Deep existence and construction relations under standard definitions; not a proof of an ML boosting result. |
| **Cryptographic reductions (§4.1)** | The reduction must preserve the adversary's input and success distribution; arbitrary distribution substitution invalidates the proof. |
| **Hybrid arguments (§4.2)** | Bound a long transition by analyzable adjacent steps. The number of hybrids and each transition bound matter. |
| **Weak-to-strong amplification (§4.3)** | Strengthens cryptographic properties while tracking loss; only a high-level analogy to boosting. |
| **Simulation paradigm (§4.4, Part VI)** | Defines zero knowledge in a stated real/ideal experiment. The mere existence of an informal simulator does not imply training-data privacy or differential privacy. |
| **Unpredictability and pseudorandomness (§4.5)** | Yao's next-bit characterization concerns binary distribution ensembles, efficient predictors, and a security parameter—not ordinary next-token uncertainty. |
| **Goldreich–Levin hardcore bit (§5.1)** | Constructs a computationally unpredictable predicate from an OWF; it is not information-theoretically perfectly hidden. |
| **Black-box vs non-black-box (§7.3)** | Classifies constructions and separation results; a black-box impossibility need not rule out non-black-box techniques. |

**Activation families:**

- **Definitions:** OWF, PRG, PRF, zero knowledge, and commitments.
- **Proof techniques:** reductions, hybrids, amplification, simulation, and unpredictability.
- **Constructions:** OWF → hardcore predicate → PRG → PRF → commitments and zero knowledge.
- **Meta-theory:** definition-driven research, primitive implication relations, black-box separations, and assumption minimization.

## Key Facts

- **Computational indistinguishability does not imply statistical closeness:** pseudorandom ensembles may have much smaller support than the uniform distribution while remaining computationally indistinguishable.
- **Multi-sample lifting needs sampling assumptions:** for efficiently and independently sampled ensembles, a hybrid can lift one-sample indistinguishability to polynomially many samples.
- **OWF existence and PRG existence are equivalent under standard formulations:** the HILL theorem supplies the difficult direction.
- **Weak OWFs can be amplified:** a parallel construction is simple to state, but the inversion proof cannot assume independent adversarial success events.
- **Yao's next-bit characterization:** a distinguisher for an output ensemble can be converted into a predictor for some next bit with a loss related to the output length.
- **Goldreich–Levin:** for `g(x,r)=(f(x),r)`, the inner-product predicate `<x,r> mod 2` is hardcore under the stated OWF setting.
- **GGM tree:** input bits select a path through repeated PRG expansion; evaluation computes one leaf on demand rather than storing an exponential function table.
- **Zero knowledge is simulation with precise quantifiers:** the verifier class, auxiliary input, running time, and perfect/statistical/computational relation must be stated.
- **Zero-knowledge class containments depend on definitions and assumptions:** do not compress conditional results about interactive proofs into an unconditional equality chain.

## Suitable Questions

- How should security, privacy, or unlearnability be formalized?
- Does primitive A imply primitive B, and is the reduction black-box?
- Which assumption is minimal, and can it be weakened to an OWF assumption?
- How is a weak property amplified without an unjustified independence step?
- What simulator and quantifier order are required by the claimed real/ideal guarantee?
- Does a next-bit analogy define an encoding, ensemble, security parameter, and efficient predictor? Natural-language next-token metrics normally do not satisfy the theorem's premises.
- Where is the boundary between computational privacy, information-theoretic leakage, and differential privacy?

## Possible Design Inspiration

1. **Goldreich–Levin as a construction lesson:** an ordinary hard-to-optimize ML mapping is not automatically an OWF.
2. **GGM-style keyed expansion:** can inspire compact keyed generation or routing, but any pseudorandomness claim still needs the cryptographic interface and assumption.
3. **Hybrid reasoning for drift analysis:** decompose a multi-step distribution change, while proving rather than assuming each transition bound.
4. **Simulation for real/ideal definitions:** useful for structuring privacy claims, but it implies only the stated simulation notion and not DP automatically.
5. **Weak-to-strong only as structural analogy:** cryptographic amplification and PAC boosting have different premises and conclusions.

## Implementation and GPU Boundary

The book primarily supplies definitions, theorems, and reductions—not GPU kernels.

- Generic HILL/GGM constructions are chiefly existence results and are not default practical implementations.
- Generic zero-knowledge constructions for NP may have large constants and round/prover costs; practical systems use specialized constructions with their own assumptions.
- The Leftover Hash Lemma is an information-theoretic extraction tool; efficiency depends on the entropy parameters and hash family.
- Reduction, hybrid, and simulation reasoning has no GPU acceptance requirement.
- Goldreich–Levin is related to Hadamard/list-decoding structure, but that does not make an ML deployment automatically useful.

Avoid implementing a generic existence construction as a production primitive, treating computational indistinguishability as a differentiable loss, or treating a classical PPT adversary as a quantum/side-channel model. Quantum security usually requires a QPT adversary and an explicit oracle-access model.

## Relevant Thinking Lenses

- **`axiomatization`:** definitions, consistency, independence, and explicit assumptions.
- **`categorical`:** implication relations among primitives, without overclaiming universal properties.
- **`algorithmic`:** reductions as algorithms; black-box vs non-black-box access.
- **`probabilistic`:** negligible functions, indistinguishability, hybrids, and birthday bounds.
- **`duality`:** information-theoretic vs computational security; adversary vs simulator.
- **`perturbation`:** tracking losses in amplification.
- **`local-to-global`:** adjacent hybrids to a whole chain; one sample to many under sampling assumptions.

## Anti-Patterns

- Treating a definition as a construction.
- Assuming independent inversion events inside an amplification proof.
- Applying a black-box separation result to every non-black-box construction.
- Treating asymptotic security as a concrete fixed-parameter bound.
- Equating honest-verifier zero knowledge with zero knowledge against arbitrary malicious verifiers.
- Reusing the classical PPT model for quantum, side-channel, or nonuniform attackers without revision.
- Citing meta-theorems before identifying the exact assumption and quantifier order.

## Deep-Dive Entry

> Oded Goldreich, *Foundations of Cryptography, Volume 1: Basic Tools*, Cambridge University Press, 2001. ISBN 978-0-521-79235-9.
>
> Place `Foundations of Cryptography.pdf` under `math_book/` for targeted local full-text lookup.

Useful sections:

- **§2.1–2.4:** probability and computational indistinguishability.
- **§2.5–2.6:** strong and weak one-way functions.
- **§3:** pseudorandom generators and hardcore predicates.
- **§4:** reductions, hybrids, amplification, simulation, and unpredictability.
- **§5:** pseudorandom functions and the GGM tree.
- **§6:** simulation and zero knowledge for NP.
- **§7:** definition methodology and black-box/non-black-box results.
- **§9:** assumptions and limitations.
