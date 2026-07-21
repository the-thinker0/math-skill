# Sheaf Cohomology

## Minimal Definition
A sheaf $\mathcal{F}$ assigns an algebraic structure (group/ring/vector space) $\mathcal{F}(U)$ to each open set $U$ of a topological space, subject to local-to-global gluing rules. Concretely:
- **Local sections**: $\mathcal{F}(U)$ is the set of "local solutions" on $U$
- **Sheaf axiom (gluing)**: if $\{U_i\}$ is an open cover of $U$ and $s_i\in\mathcal{F}(U_i)$ agree on overlaps $U_i\cap U_j$, then there exists a unique $s\in\mathcal{F}(U)$ restricting to each $s_i$

Sheaf cohomology $H^i(X,\mathcal{F})$ measures local-to-global obstructions finer than the section-gluing axiom itself — for example extension classes, principal-bundle classification, or higher gluing problems. The first cohomology $H^1$ is the most commonly used obstruction diagnostic; Čech cohomology, computed via the intersection complex of an open cover, is the most commonly used approximate form in engineering.

## Core Formulas
- **Sheaf condition (gluing axiom)**: $\mathcal{F}(U)\to\prod_i\mathcal{F}(U_i)\rightrightarrows\prod_{i,j}\mathcal{F}(U_i\cap U_j)$ is an equalizer
- **Čech complex**: $C^p(\mathcal{U},\mathcal{F})=\prod_{i_0<\cdots<i_p}\mathcal{F}(U_{i_0\cdots i_p})$, differential $d^p:C^p\to C^{p+1}$ formed from restriction maps
- **Cohomology groups**: $H^i(X,\mathcal{F})=\ker d^i/\mathsf{im}\,d^{i-1}$
- **Meaning of $H^1=0$**: For many extension, principal-bundle, or gluing-obstruction problems, $H^1$ measures whether local data can be lifted to a global object. Note: a true sheaf already guarantees by the gluing axiom that “sections agreeing on overlaps ⇒ a unique global section,” so $H^1=0$ must not be stated as a blanket necessary-and-sufficient condition for arbitrary “local consistency ⇒ global consistency.” Engineering diagnoses should first specify which cohomology problem is being measured.
- **Spectral sequence (Leray)**: $E_2^{p,q}=H^p(\mathcal{U},\mathcal{H}^q)$ converges to $H^{p+q}(X,\mathcal{F})$, computing higher cohomology
- **Relation to de Rham cohomology**: $H^i_{\mathsf{dR}}(X)\cong H^i(X,\Omega_X^{\bullet})$, de Rham cohomology is a special case of sheaf cohomology
- **Vanishing theorems** (Cartan Theorem A/B, Serre): on affine varieties, coherent sheaf cohomology $H^i=0$ for $i>0$; on projective space, line bundle $\mathcal{O}(d)$ has $H^i$ vanishing for certain $d$ ranges

## Applicable Problems
- Diagnosing "locally consistent but globally obstructed" structures:
  - **Multi-view feature alignment**: each view locally aligns, but global alignment fails — $H^1$ measures the alignment obstruction
  - **Multi-modal fusion inconsistency**: each modality's local information is consistent, but global fusion has contradictions
  - **Distributed training global consistency**: each node's local gradients agree, but global aggregation has obstructions
  - **Topological obstructions in representation space**: "holes" or "loops" in feature space affect downstream tasks
- Model diagnosis: detecting structural obstructions in representation spaces (nontrivial $H^1$)
- Knowledge graph reasoning: local consistency of entity relations vs global contradictions

## AI Design Translation
- **Sheaf cohomology as a "local-to-global obstruction diagnostician"**: model multi-view / multi-modal / multi-node local consistency as sheaf sections, with $H^1$ as a formal measure of fusion failure
- **H¹ as a multi-view fusion consistency measure**: define a sheaf on multi-view features, compute Čech cohomology, $H^1=0$ means fusable, $H^1\ne 0$ means obstructed
- **Persistent sheaf cohomology**: combine persistent homology with sheaf cohomology as a topological diagnostic for representation spaces
- See `../../design-patterns/compression/topology-preserving-compression.en.md`, `../../design-patterns/representation/shared-private-decomposition.en.md` for corresponding patterns; if no match, label as "temporary design translation."

## Engineering Feasibility
Sheaf cohomology has severe GPU-friendliness challenges:
- **D1[x]**: exact Čech cohomology requires constructing open covers + computing high-order intersection complexes, non-tensorizable
- **D2[x]**: boundary matrix reduction is highly serial, not GEMM-mappable
- **D3[x]**: exact Čech cohomology starts at $O(N^3)$, $N$ being the open-cover size; higher cohomology $O(N^{p+3})$
- **D4[~]**: can be reduced to landmark sampling $O(m^3)$, $m\ll N$; but still not GPU-friendly
- **D5[v]**: integer arithmetic (boundary matrices) has no precision issues; floating-point approximations can use bf16
- **D6[x]**: reduction algorithms are highly serial; landmark selection can be parallelized
- **D7[~]**: sparse boundary matrices can be stored in CSR; SpMM is effective but reduction remains serial
- **D8[x]**: boundary matrix reduction is not fusable
**Key retrofit**: use landmark sampling $O(m^3)$ instead of full $O(N^3)$; use approximate persistent homology versions; use Euler curves as proxies; **exact cohomology should not be inserted into training loops**, only as diagnostics or regularization.

## Risks and Failure Conditions
- **Exact cohomology is uncomputable**: $O(N^3)$ serial algorithms are infeasible for $N>10^4$; approximations are mandatory
- **Čech approximation depends on cover choice**: open-cover selection affects results; different covers give different $H^i$; landmark selection may introduce bias
- **Wrong sheaf parameterization distorts cohomology**: if the sheaf $\mathcal{F}$'s sections are defined incorrectly, $H^i$ loses diagnostic meaning
- **$H^1=0$ does not guarantee higher-order obstruction-free**: $H^1=0$ only guarantees local solutions can be glued globally, but $H^2$ and above may still be obstructed
- **Euler curve information loss**: $\chi=\sum(-1)^k\beta_k$ compresses multiple orders into a single value; different topologies can share the same $\chi$
- **Topology ≠ semantics**: topological preservation is not semantic preservation; two semantically different spaces may be topologically isomorphic
- **Cohomology base-field sensitivity**: $\mathbb{Z}$ coefficients vs $\mathbb{R}$ vs $\mathbb{F}_p$ give different torsion information

## Further References
- Distilled notes: `../../references/books/algebraic-geometry-rising-sea.en.md`
- Original book: Ravi Vakil, *The Rising Sea: Foundations of Algebraic Geometry*, Ch 18-22 (sheaves and cohomology)
- Original book: Robin Hartshorne, *Algebraic Geometry*, Ch III (Cohomology)

## Routing Extensions
- If local-to-global is needed → `../../lenses/local-to-global.en.md` (assembling local properties into global)
- If topological diagnosis is needed → `../topology/persistent-homology.en.md` (persistent homology, Betti numbers)
- If categorical language is needed → `../../lenses/categorical.en.md` (sheaves are a core categorical construct)
- If Euler characteristic is needed → `../topology/euler-characteristic.en.md` (fast topological diagnostic proxy)

## Extensible Directions
- Derived functors: $\mathsf{Ext}^i$, $\mathsf{Tor}_i$ as derived functors
- Spectral sequences: Leray, Grothendieck, Atiyah-Hirzebruch
- Hodge decomposition: cohomology of algebraic varieties over $\mathbb{C}$
- D-modules: differential operator theory on sheaves
- Picard group: isomorphism classes of line bundles, $H^1(X,\mathcal{O}^{\times})$
- Persistent sheaf cohomology: combining persistent homology with sheaf cohomology
