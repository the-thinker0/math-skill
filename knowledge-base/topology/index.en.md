# Topology Activation Index

## Domain Signals
Activate this domain direction when the problem involves:
- Connectivity preservation: need to maintain or detect connectivity structure of a space
- Representation space tearing: latent space or representation space exhibits topological tearing
- Local-to-global consistency: whether local information can be consistently glued into a global structure
- Multimodal alignment obstruction: whether topological obstructions exist for multimodal alignment
- Whether compression destroys structure: whether dimensionality reduction or compression alters the topological features of data

## Core Anchors
- `persistent-homology.md` — Persistent homology
- `euler-characteristic.md` — Euler characteristic
- `fundamental-group.md` — Fundamental group

## Extended Concepts
When core anchors are insufficient, the following concepts may need temporary activation:
- simplicial complex: simplicial complexes (Vietoris-Rips, alpha complex, etc.)
- Cech complex: Cech complex and coverings
- sheaf theory (section, restriction map, gluing, Cech cohomology): sheaf theory basics and Cech cohomology
- covering space: covering spaces and covering maps
- homotopy group: higher homotopy groups
- CW complex: CW complexes and cell structure
- Morse theory: Morse theory and critical point analysis
- Betti numbers: Betti numbers and topological invariants
- topological data analysis (Mapper algorithm): topological data analysis and Mapper algorithm
- obstruction theory: obstruction theory
- classifying space: classifying spaces
- K-theory: K-theory
- cobordism: cobordism theory

## Reference Book Directions
- `../../references/books/smooth-manifolds.md`: Chapters 17-18, covering homology theory basics
- `../../references/books/algebraic-geometry-rising-sea.md`: Cech cohomology sections

## Temporary Activation Rules
When the problem requires mathematics not in the core anchors:
1. First check whether extended concepts contain a match
2. If yes, generate a temporary knowledge card based on the lens
3. If no, enter the Knowledge Gap Protocol
