# Discrete & Combinatorial Thinking — Original Texts & Historical Context

---

## 1. Pigeonhole Principle — Dirichlet (1834)

Peter Gustav Lejeune Dirichlet stated the pigeonhole principle in 1834 as the "Schubfachprinzip" (drawer principle), using it for existential proofs in number theory.

> "Wenn man n + 1 Objecte in n Facher distribuiert, so ist mindestens ein Fach mit zwei Objecten besetzt."
> — Dirichlet, 1834

**Core statement:**
- Basic form: if n items are placed into m boxes and n > m, then some box contains at least ⌈n/m⌉ items
- Generalized form: kn+1 items into n boxes → some box contains at least k+1 items
- Number theory application: for any real number α and integer N, there exists q ≤ N such that |qα − p| < 1/(N+1) (i.e., qα approximates an integer)

**Diophantine approximation:** Partition [0,1) into N+1 equal-length intervals ("boxes"), and consider the N+2 numbers {0, {α}, {2α}, ..., {(N+1)α}} ("items"). The pigeonhole principle guarantees that two must fall into the same interval, yielding |(q₁−q₂)α − ⌊(q₁−q₂)α⌋| < 1/(N+1). This is the standard pigeonhole proof of Dirichlet's approximation theorem.

---

## 2. Euler's Generating Functions (1748)

Leonhard Euler pioneered the generating function method in **Introductio in analysin infinitorum** (1748) — transforming sequences into power series, and counting into algebraic operations.

> "If we ask how many ways a given number can be partitioned, we are led to a study of the generating function." — Euler, 1748

**Partition generating function:**
$$P(x) = \sum_{n=0}^{\infty} p(n) x^n = \prod_{k=1}^{\infty} \frac{1}{1-x^k}$$
- p(n) = the number of partitions of n into positive integers. p(5) = 7: {5, 4+1, 3+2, 3+1+1, 2+2+1, 2+1+1+1, 1+1+1+1+1}
- Product form: 1/(1−x^k) = 1+x^k+x^{2k}+... represents "taking 0, 1, 2, ... copies of k"; since each k is independent, the product encodes all combinations

**Pentagonal number theorem (Euler 1750):**
$$\prod_{k=1}^{\infty}(1-x^k) = \sum_{m=-\infty}^{\infty} (-1)^m x^{m(3m-1)/2}$$
- Generalized pentagonal numbers e_m = m(3m−1)/2: 0, 1, 2, 5, 7, 12, 15, 22, ...
- From P(x)·∏(1−x^k) = Σ(−1)^m x^{e_m}, one obtains the recurrence p(n) = p(n−1)+p(n−2)−p(n−5)−p(n−7)+...
- This is a classic example of a finite recurrence controlling an infinite sequence — the essence of combinatorial thinking

**Hardy-Ramanujan asymptotic formula (1918):**
$$p(n) \sim \frac{1}{4n\sqrt{3}} \exp\left(\pi\sqrt{\frac{2n}{3}}\right)$$

---

## 3. Catalan Numbers

**History:** Eugène Catalan (1838) studied the counting problem of nested parentheses, from which the Catalan numbers derive their name. However, Euler had already studied a related problem (polygon triangulation) in 1751.

**Definition and formula:**
$$C_n = \frac{1}{n+1}\binom{2n}{n} = \frac{(2n)!}{n!(n+1)!}$$
- Recurrence: C₀ = 1, C_n = ΣC_i·C_{n−1−i}
- Generating function: C(x) = ΣC_n x^n = (1−√(1−4x))/(2x), obtained by solving C(x) = 1 + x·C(x)²

**Combinatorial interpretations (60+):**
- **Binary trees**: the number of ordered binary trees with n nodes = C_n
- **Dyck paths**: lattice paths from (0,0) to (2n,0), with steps (+1,+1) or (+1,−1), never crossing above y=0
- **Parenthesizations**: the number of valid nestings of n pairs of parentheses = C_n
- **Ballot problem**: A receives n+1 votes, B receives n votes; the number of sequences in which A is always ahead of B = C_n (Bertrand 1887)
- **Polygon triangulation**: the number of distinct triangulations of an (n+2)-gon = C_n

First few terms: C₀=1, C₁=1, C₂=2, C₃=5, C₄=14, C₅=42, C₆=132

---

## 4. Ramsey Theory — Ramsey (1930)

Frank P. Ramsey proved in **"On a Problem of Formal Logic"** (1930) that sufficiently large systems necessarily contain some structure — a profound generalization of the pigeonhole principle.

> "In any sufficiently large system, complete disorder is impossible." — Cohen

**Ramsey numbers:**
$$R(s,t) = \min\{n : \text{every 2-coloring of the complete graph on } n \text{ vertices contains a red } K_s \text{ or a blue } K_t\}$$

**Known values:** R(3,3)=6 (at a party of 6 people, there must be 3 mutual acquaintances or 3 mutual strangers; proof: fix one person, among the remaining 5 at least 3 share the same relationship color by the pigeonhole principle; if any 2 of those 3 share that color they form a monochromatic triangle, otherwise those 3 form a triangle of the other color), R(4,4)=18, R(3,4)=9, R(3,5)=14.

**General bounds:** Erdős 1947 probabilistic method: R(k,k) > 2^{k/2}; upper bound R(k,k) ≤ 4^k. R(5,5) is unknown (43 ≤ R(5,5) ≤ 48). Erdős: "If aliens demanded R(5,5), we should marshal all our computers; if they demanded R(6,6), we should prepare for battle."

---

## 5. Graph Theory — Euler (1736)

**Seven Bridges of Königsberg (1736):**

Leonhard Euler, in **"Solutio problematis ad geometriam situs pertinentis"** (1736), solved the Königsberg bridge problem, founding graph theory.

> "The problem... is to find whether one can cross each of the seven bridges exactly once and return to the starting point." — Euler, 1736

**Euler circuit theorem:**
- A connected graph has an Euler circuit (a closed walk traversing every edge exactly once) if and only if all vertices have even degree
- The Königsberg graph: the 4 vertices have degrees 3, 3, 3, 5 (all odd), so no Euler circuit exists — the problem has no solution

**Euler's planar formula (1750):**
$$V - E + F = 2$$
- For any connected planar graph: the number of vertices V, edges E, and faces F satisfy this formula
- Corollaries: for a simple connected planar graph E ≤ 3V − 6; for a planar graph containing no K₃, E ≤ 2V − 4

**Matching theory:**
- König (1931): in a bipartite graph, the maximum matching size = the minimum vertex cover size (König's theorem)
- Hall's marriage theorem (1935): a bipartite graph G(X,Y) has a perfect matching from X to Y if and only if for every S ⊆ X, |N(S)| ≥ |S|

---

## 6. Pólya Enumeration Theorem (1937)

George Pólya, in his 1937 paper, provided a counting method under symmetry — the orbit counting theorem, the meeting point of combinatorial enumeration and group theory.

> "The number of distinct colorings is obtained by averaging over the group action." — Pólya, 1937

**Theorem statement:**
Let group G act on set X. The number of equivalence classes of k-colorings (number of orbits):
$$N = \frac{1}{|G|} \sum_{g \in G} k^{c(g)}$$
where c(g) = the number of cycles of the permutation g. Applications: chemical isomers, bead necklace patterns. Burnside's lemma (1897): N = (1/|G|)Σ|Fix(g)| is a special case of Pólya's theorem. Pólya generalized this to a weighted version: GF × cycle index = symmetric counting.

---

## 7. Inclusion-Exclusion Principle

**History:** da Vinci used inclusion-exclusion ideas to compute areas; Sylvester (1882) formalized the principle. Inclusion-exclusion handles overlapping intersections — direct addition double-counts intersections, requiring successive corrections.

Basic form: |A₁∪...∪A_n| = Σ|A_i| − Σ|A_i∩A_j| + ... ± |A₁∩...∩A_n|. Complement counting: "not having property P" = total − "having property P."

**Derangements:** D(n) = n! − C(n,1)(n−1)! + C(n,2)(n−2)! − ... = n!Σ(−1)^k/k! ≈ n!/e as n→∞. Probability form: P(A₁∪...∪A_n) = ΣP(A_i) − ΣP(A_i∩A_j) + ...

---

## 8. Recurrence Relations

**Fibonacci sequence:**
$$F_0 = 0, F_1 = 1, F_n = F_{n-1} + F_{n-2}$$
- Generating function: F(x) = ΣF_n x^n = x/(1−x−x²)
- Binet's formula: F_n = (φ^n − ψ^n)/√5, where φ = (1+√5)/2 ≈ 1.618 (the golden ratio)

**Tower of Hanoi:**
$$T_1 = 1, T_n = 2T_{n-1} + 1$$
- Solution: T_n = 2^n − 1. A tower of 64 disks requires 2^{64} − 1 ≈ 1.8×10^{19} moves

**Solving recurrences via generating functions:**
1. Multiply the recurrence by x^n, sum over n → obtain an equation for A(x)
2. Use initial conditions to solve for A(x) (algebraic or differential equation)
3. Extract a_n: partial fractions, Taylor expansion, or matching against known power series

**Catalan GF derivation:** C(x) = 1 + x·C(x)² → solve x·C² − C + 1 = 0 → C(x) = (1−√(1−4x))/(2x) → C_n = (1/(n+1))C(2n,n)

---

## 9. Combinatorial Optimization

**Minimum spanning tree:**
- Kruskal (1956): greedily select edges in ascending order of weight, skipping those that form cycles, O(E log E)
- Prim (1957): expand from a single vertex, each time selecting the minimum-weight connecting edge, O(E log V) (with a priority queue)

**Max-flow min-cut:**
- Ford-Fulkerson (1956): augmenting path method, incrementally increasing flow until no augmenting path exists
- Max-flow min-cut theorem: the maximum flow value = the minimum cut capacity (the combinatorial manifestation of LP duality)
- Edmonds-Karp (1972): BFS selects the shortest augmenting path, guaranteeing O(VE²)

**Matching theory:**
- Hungarian algorithm (Kuhn 1955): O(V³) maximum weighted bipartite matching
- Edmonds' blossom algorithm (1965): maximum matching in general graphs, O(V³)

---

## 10. The Twelvefold Way

Richard P. Stanley, in **Enumerative Combinatorics Vol. 1**, unified and classified the 12 fundamental counting problems of placing n balls into k boxes (2×2×3: balls labeled/unlabeled × boxes labeled/unlabeled × any/at most one/at least one):

| Balls | Boxes | Condition | Formula |
|---|---|---|---|
| distinct | distinct | any | k^n |
| identical | distinct | any | C(n+k−1, k−1) |
| distinct | identical | any | Σ S₂(n,i), i=1..k |
| identical | identical | any | p_k(n) (restricted partitions) |
| distinct | distinct | at most one ≤1 | P(k,n) = k!/(k−n)! |
| identical | distinct | at most one ≤1 | C(k,n) |
| distinct | identical | at most one ≤1 | 1 if n≤k, 0 otherwise |
| identical | identical | at most one ≤1 | 1 if n≤k, 0 otherwise |
| distinct | distinct | at least one ≥1 | k!·S₂(n,k) |
| identical | distinct | at least one ≥1 | C(n−1, k−1) |
| distinct | identical | at least one ≥1 | S₂(n,k) − S₂(n,k−1) |
| identical | identical | at least one ≥1 | p_k(n) − p_{k−1}(n) |

**Key insight:** The 2×2×3=12 fundamental counting problems cover the core scenarios in combinatorics. Use EGF for labeled objects, OGF for unlabeled objects. **Stirling numbers:** S₁(n,k) = the number of permutations of n elements with k cycles; S₂(n,k) = the number of ways to partition n elements into k non-empty subsets.

---

*This file provides mathematical references and historical context for the discrete-combinatorial skill, covering core results from Euler to modern combinatorics.*
