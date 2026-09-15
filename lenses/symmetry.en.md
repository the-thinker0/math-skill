# Symmetry Lens

> Seek the invariant amid change — conservation laws require dynamical and action-based assumptions, and every invariant is a key to simplifying the problem

## What Perspective It Offers

Symmetry is a way of "finding what remains unchanged under transformations": when confronting a complex system, first ask, "Under what transformations do which properties of the system remain invariant?" Invariants are the core tool for simplification — they distinguish only between orbits (equivalence classes), not between elements within the same orbit. Complete invariants can distinguish orbits, but the quotient map is generally not an embedding and the quotient need not be a smooth manifold. Noether's theorem links differentiable continuous symmetries of an action to conserved quantities along Euler–Lagrange solutions; neural-network equivariance alone does not imply conservation laws.

## What Problems It Is Suited to Diagnose

- Facing a complex system and seeking simplification clues — use invariants to reduce dimensionality
- Needing to classify or identify objects — use orbits (the quotient space X/G)
- Searching for conserved quantities or invariants — functions that are constant on orbits
- Determining the solvability of equations (Galois theory) or designing equivariant structures

## What Problems It Is Not Suited For

- The system is completely asymmetric with no discernible pattern — no group action is available to exploit
- Precise numerical solutions are required — symmetry provides structural information, not specific values
- Symmetry breaking is the central mechanism — one should turn to analyzing the breaking pattern rather than searching for invariants
- The group structure is too complex — when the quotient space is no simpler than the original space

## Which Knowledge Domains It Routes To

- `lie-theory/group-action`: Group actions, the orbit-stabilizer theorem, and Burnside's lemma — the algebraic foundations of symmetry
- **lie-theory**: Lie groups, Lie algebras, and Noether's theorem — continuous symmetries and conservation laws
- `../references/books/abstract-algebra.en.md`: Galois and solvable groups; finite Galois theory is not Lie group theory

## What AI Designs It May Inspire

- **Symmetry Detector**: Identifies candidate transformation groups from a problem description and verifies the group axioms
- **Invariant Extractor**: Computes invariants using the Reynolds operator or Lie algebra generators
- **Quotient-Space Classifier**: Works on X/G and uses a complete set of invariants to classify equivalence classes

## Reasoning Protocol

1. **Identify the Transformation Group**: List the candidate transformations of the system, organize them into a candidate group, and verify closure, associativity, identity, and inverses
2. **Find Invariants**: Average over finite groups when the group order is invertible in the field; use normalized Haar averaging for compact groups. Lie algebra generators only test the identity component; check disconnected components separately
3. **Simplify Using Invariants**: Work on the quotient space X/G, replacing constrained variables with invariants
4. **Orbit Classification**: Use the orbit-stabilizer theorem and assess the completeness of the invariant set
5. **Check for Symmetry Breaking**: Identify G → H breaking patterns and discuss Goldstone modes only when the relevant field-theoretic assumptions hold

## Acceptance Criteria

- The candidate group has been verified through the axioms (not merely assumed to have group structure)
- Invariants have been explicitly given, distinguishing orbital invariants from global invariants
- The simplification strategy has stated the degree of dimensionality reduction
- Symmetry breaking has been checked (presence or absence; spontaneous or explicit)
- Classification results and the completeness of the invariant set have been assessed
