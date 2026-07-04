# 🌀 Topological Lens

> Stretching and bending are allowed, but tearing is not — the truly important properties are those invariant under continuous deformation

## What Perspective It Offers

Topology is a way of "ignoring precise measurements and focusing only on qualitative structure": when exact distances do not matter, topology captures the essential structure — connectedness, the number of holes, and dimension. A donut and a coffee cup are topologically equivalent because each has exactly one hole. The core insight is that shape matters more than size; invariants that survive continuous deformation are the truly robust properties. Cohomology (especially Čech cohomology) can also detect whether "local fragments can be assembled into a globally consistent object."

## What Problems It Is Suited to Diagnose

- Qualitative classification — not "how large" or "how far," but "is it connected?" and "how many holes does it have?"
- Robustness analysis — topological invariants guarantee that properties do not vanish under continuous perturbation
- Data whose shape standard statistics cannot capture — clusters, voids, and ring-like structures
- Detecting global consistency obstructions — whether local fragments can be assembled into a globally consistent object

## What Problems It Is Not Suited For

- Precise measurements are required — topology concerns only qualitative structure and does not provide distances or angles
- Metric properties are central — topologically equivalent spaces can have entirely different metric behavior
- Precise numerical decisions are needed — the topological perspective is too coarse to answer "how much" questions

## Which Knowledge Domains It Routes To

- `topology/persistent-homology`: Fundamental group, homology groups, Betti numbers, and cohomology — computational tools for topological invariants
- **tda**: Persistent homology, filtrations, and simplicial complexes — extracting topological features from data
- `topology/fundamental-group`: Sheaf cohomology and Čech cohomology — algebraic criteria for local-to-global consistency

## What AI Designs It May Inspire

- **Topological Feature Extractor**: Builds filtrations from point-cloud data and computes persistent homology barcodes
- **Consistency Detector**: Uses Čech cohomology H¹ to detect obstructions to global consistency among local fragments
- **Shape Classifier**: Uses combinations of invariants (χ, π₁, βₙ) to perform topological classification of spaces

## Reasoning Protocol

1. **Specify the Equivalence Standard**: Determine whether the relevant notion is homeomorphism, homotopy equivalence, or diffeomorphism; distinguish what may vary (distance) from what must remain invariant (number of holes)
2. **Compute Topological Invariants**: Euler characteristic, connected components, fundamental group, homology groups, and Betti numbers
3. **Classify Using Invariants**: Same χ implies same surface type; same π₁ implies same homotopy type
4. **Construct a Topological Model**: Build a filtration from a point cloud, a graph from a network, or a phase space from a dynamical system
5. **Verify Equivalence**: Attempt to construct an explicit homeomorphism or homotopy; check whether all invariants match

## Acceptance Criteria

- The equivalence standard has been explicitly stated (homeomorphism, homotopy equivalence, or diffeomorphism)
- Invariants have been computed: at minimum, χ, π₁, and βₙ (where obtainable) have been provided
- A classification conclusion has been given, with a note on whether the invariants are complete
- Equivalence verification has been completed (match, mismatch, or inconclusive)
- The reasoning chain is complete: "because [topological property] → [conclusion]"
