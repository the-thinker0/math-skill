# Algorithmic Thinking -- Original Texts & Historical Context

---

## 1. Turing Machine (1936)

Alan Turing's paper **"On Computable Numbers, with an Application to the Entscheidungsproblem"** (1936) defined a precise mathematical model of "computability" -- the Turing machine.

> "The 'computable' numbers may be described briefly as the real numbers whose expressions as a decimal are calculable by finite means."
> -- Alan Turing, 1936

**Core definition:**
- A Turing machine $M = (Q, \Sigma, \Gamma, \delta, q_0, q_{\text{accept}}, q_{\text{reject}})$, where $\delta: Q \times \Gamma \to Q \times \Gamma \times \{L, R\}$ is the transition function.
- Universal Turing machine: can simulate the execution of any Turing machine $M$ on input $w$, i.e., $U(\langle M \rangle, w) = M(w)$.

**Halting problem:**
- The halting problem $H = \{\langle M, w \rangle : M \text{ halts on } w\}$ is undecidable.
- Proof: Suppose $H$ is decidable. Construct $D(\langle M \rangle) = \text{run } H(\langle M, \langle M \rangle \rangle)$; if $M$ halts on $\langle M \rangle$ then $D$ loops forever, otherwise $D$ halts. Applying $D(\langle D \rangle)$ produces a contradiction.

**Entscheidungsproblem (Decision Problem):**
- Proposed by Hilbert in 1928: Does there exist an algorithm to decide the validity of first-order logic statements?
- Turing and Church independently proved: No such algorithm exists. The validity of first-order logic is undecidable.

---

## 2. Church-Turing Thesis

**Thesis (not a theorem):**
> Every "effectively calculable" function is Turing-computable.

**Equivalent formulations:**
- Church: $\lambda$-definable functions (lambda calculus, 1936)
- Godel-Herbrand-Kleene: general recursive functions
- Post: Post canonical systems
- The sets of functions computable by all these models are identical, supporting the plausibility of the thesis.

**Strong Church-Turing thesis:**
- Any problem solvable on a physical device in time $T$ can be solved on a Turing machine in time $O(T^k)$ ($k$ a constant).
- That is: all reasonable computational models are equivalent up to polynomial time.
- Quantum computing challenges this -- does there exist a polynomial speedup with $k > 1$?

---

## 3. Euclid's Algorithm (~300 BC)

**The oldest algorithm still in use.**

**GCD computation:**
$$\gcd(a, b) = \gcd(b, a \bmod b), \quad a \bmod b \neq 0$$
$$\gcd(a, 0) = a$$

**Termination proof:**
- At each step $b' = a \bmod b < b$, so the sequence $b_0 > b_1 > b_2 > \cdots \geq 0$ is strictly decreasing.
- Within finitely many steps $b_k = 0$ and the algorithm terminates.

**Extended Euclidean algorithm:**
- Computes $\gcd(a, b)$ while simultaneously finding $x, y$ such that $ax + by = \gcd(a, b)$.
- Application: modular inverse $a^{-1} \bmod m$ -- when $\gcd(a, m) = 1$, $ax \equiv 1 \pmod{m}$ and $x = a^{-1}$.

**Time complexity:**
- Lame's theorem (1844): The number of steps in Euclid's algorithm is at most $5 \times$ the number of decimal digits of the smaller number, i.e., $O(\log \min(a, b))$.

---

## 4. Knuth -- The Art of Computer Programming (1968-)

Donald Knuth's multi-volume magnum opus **TAOCP** systematized the field of algorithm analysis.

> "The process of preparing programs for a digital computer is especially attractive, not only because it can be economically and scientifically rewarding, but also because it can be an aesthetic experience much like composing poetry or music."
> -- Donald Knuth, TAOCP Vol. 1, Preface

**Contributions:**
- Introduced and popularized big-O notation from number theory into computer science. $O(f(n))$: there exist constants $c, n_0$ such that $T(n) \leq c \cdot f(n)$ for all $n \geq n_0$.
- A systematic taxonomy of algorithms (sorting, searching, arithmetic, combinatorial, etc.).
- MMIX/MIX mixed pseudo-machines for precise models of algorithm analysis.
- Volumes: Vol. 1 (Fundamental Algorithms, 1968), Vol. 2 (Seminumerical Algorithms, 1969), Vol. 3 (Sorting and Searching, 1973), Vol. 4A (Combinatorial Algorithms, 2011).

---

## 5. Cook-Levin Theorem (1971)

**NP-completeness:**

> "The question 'is P = NP?' is one of the most important open questions in theoretical computer science."
> -- Stephen Cook, 1971

**The Cook-Levin theorem:**
- SAT (the Boolean satisfiability problem) is NP-complete.
- Proof: The accepting computation of a nondeterministic Turing machine $M$ for any NP language $L$ on input $w$ can be encoded as a SAT formula $\varphi_{M,w}$; $w \in L \iff \varphi_{M,w}$ is satisfiable.
- Reduction: $L \leq_p \text{SAT}$ holds for all $L \in \text{NP}$.

**Karp's 21 NP-complete problems (1972):**
- Richard Karp, in "Reducibility among Combinatorial Problems," proved 21 classic problems to be NP-complete, including:
  - 3SAT, CLIQUE, VERTEX-COVER, HAM-CYCLE, TSP, SUBSET-SUM, PARTITION, etc.

**P vs NP:**
- $\text{P} = \text{NP}$? If true, all NP problems would have polynomial-time algorithms. The prevailing conjecture is $\text{P} \neq \text{NP}$. One of the Clay Mathematics Institute Millennium Prize Problems.

---

## 6. Divide-and-Conquer

**Key idea:** Decompose the problem into subproblems, solve recursively, and combine results.

**Canonical examples:**
- **Merge sort:** $T(n) = 2T(n/2) + O(n) \Rightarrow T(n) = O(n \log n)$. A stable sort.
- **Quicksort:** Average $O(n \log n)$, worst case $O(n^2)$. Hoare (1962).
- **Binary search:** $T(n) = T(n/2) + O(1) \Rightarrow T(n) = O(\log n)$. Requires a sorted array.

**Master theorem:**
$$T(n) = a\,T(n/b) + f(n)$$
- Case 1: If $f(n) = O(n^{\log_b a - \varepsilon})$, then $T(n) = \Theta(n^{\log_b a})$.
- Case 2: If $f(n) = \Theta(n^{\log_b a} \log^k n)$, then $T(n) = \Theta(n^{\log_b a} \log^{k+1} n)$.
- Case 3: If $f(n) = \Omega(n^{\log_b a + \varepsilon})$ and $af(n/b) \leq cf(n)$, then $T(n) = \Theta(f(n))$.

---

## 7. Dynamic Programming

> "I decided to use the word 'dynamic' ... it was something not even a Congressman could object to."
> -- Richard Bellman, on naming "dynamic programming" (1957)

**Core principles:**
1. **Optimal substructure:** An optimal solution contains optimal solutions to subproblems.
2. **Overlapping subproblems:** Different subproblems share smaller sub-subproblems, so naive recursion redundantly recomputes them.

**Classic algorithms:**
- **Shortest paths:** Dijkstra (1959) -- single-source shortest paths, $O((V+E)\log V)$.
- **Floyd-Warshall (1962):** All-pairs shortest paths, $O(V^3)$. Recurrence: $d_{ij}^{(k)} = \min(d_{ij}^{(k-1)}, d_{ik}^{(k-1)} + d_{kj}^{(k-1)})$.
- **Knapsack problem:** $O(nW)$ pseudo-polynomial time.

**Bottom-up vs Top-down (memoization):**
- Bottom-up: Fill in a table from the smallest subproblems to the largest.
- Top-down + memoization: Recurse but cache the results of already-solved subproblems.

---

## 8. Greedy Algorithms

**Key idea:** At each step, choose the locally optimal option, hoping to reach a globally optimal solution.

**Classic algorithms:**
- **Kruskal's minimum spanning tree (1956):** Add edges in ascending order of weight, skipping those that form a cycle. $O(E \log E)$. Greedy is optimal for MST problems.
- **Huffman coding (1952):** Repeatedly merge the two nodes with the lowest frequencies. Produces an optimal prefix code.

**When greedy works:**
- **Matroid structure:** If the set of feasible solutions forms a matroid $(E, \mathcal{I})$ -- satisfying the hereditary property and the exchange property -- then the greedy algorithm yields an optimal solution for any weight function.
- Exchange property: If $A, B \in \mathcal{I}$ and $|A| < |B|$, then there exists $e \in B \setminus A$ such that $A \cup \{e\} \in \mathcal{I}$.

---

## 9. Backtracking and Search

**Depth-First Search (DFS) / Breadth-First Search (BFS):**
- DFS: Uses a stack (or recursion), explores as deep as possible first; used for topological sorting and connected components.
- BFS: Uses a queue, expands level by level; used for shortest paths in unweighted graphs.

**Backtracking:**
- Systematically enumerates candidate solutions, retreating as soon as a constraint is violated.
- Examples: N-Queens problem, subset enumeration, permutation enumeration.

**Pruning and branch-and-bound:**
- Pruning: Uses constraints to eliminate impossible branches early, reducing the search space.
- Branch-and-bound: For optimization problems, maintains a bound on the current best solution and prunes branches that cannot improve it. Commonly used for TSP and integer programming.

**Constraint Satisfaction Problems (CSP):**
- A set of variables + domains + constraints. Backtracking search + constraint propagation (AC-3, etc.).

---

## 10. Randomized Algorithms

**Two types:**
- **Las Vegas algorithms:** Always produce correct results; running time is random. Example: randomized quicksort.
- **Monte Carlo algorithms:** Running time is deterministic; result may be incorrect (but error probability can be made arbitrarily small). Example: Miller-Rabin primality test.

**Miller-Rabin primality test (1976/1980):**
- For an odd number $n$, choose a random $a \in \{2, \ldots, n-1\}$ and check whether the sequence $a^{d} \bmod n$ satisfies the strengthened conditions of Fermat's little theorem.
- Error probability per test $\leq 1/4$; after $k$ independent tests, error probability $\leq 4^{-k}$.
- Time complexity $O(k \log^3 n)$.

**Randomized quicksort:**
- Randomly select a pivot; expected number of comparisons $2n \ln n \approx 1.39 n \log_2 n$; expected running time $O(n \log n)$.
- The probability of the worst case $O(n^2)$ can be shown to be extremely low.

---

## 11. Decidability and Undecidability

**The halting problem is undecidable (see Section 1).**

**Rice's theorem (1953):**
> Every non-trivial semantic property of Turing machines is undecidable.

- "Semantic property": depends only on the function computed by $M$, not on the structure of $M$.
- "Non-trivial": holds for some Turing machines but not for others.
- Examples: "Does $M$ compute a constant function?", "Does $M$ halt on some input?", "Does $M$ compute a decidable language?" -- all undecidable.

**Post Correspondence Problem (PCP, 1946):**
- Given a set of dominos $\{(t_1, b_1), \ldots, (t_k, b_k)\}$ (where $t_i, b_i$ are strings), does there exist a sequence $i_1, i_2, \ldots, i_m$ such that $t_{i_1} t_{i_2} \cdots t_{i_m} = b_{i_1} b_{i_2} \cdots b_{i_m}$?
- PCP is undecidable. Commonly used to prove the undecidability of other problems.

---

## 12. Complexity Classes

| Class | Definition | Description |
|-------|-----------|-------------|
| **P** | $\{L : L \text{ is decidable in } O(n^k) \text{ time}\}$ | Decidable in polynomial time |
| **NP** | $\{L : L \text{ has a polynomial-length certificate}\}$ | Decidable in nondeterministic polynomial time |
| **co-NP** | $\{L : \bar{L} \in \text{NP}\}$ | Complement of NP |
| **EXP** | $\{L : L \text{ is decidable in } O(2^{n^k}) \text{ time}\}$ | Decidable in exponential time |
| **R** | $\{L : L \text{ is decidable}\}$ | Recursive / decidable languages |
| **RE** | $\{L : L \text{ is recognizable by a Turing machine}\}$ | Recursively enumerable languages |

**Hierarchies:**
$$\text{P} \subseteq \text{NP} \subseteq \text{PSPACE} \subseteq \text{EXP} \subseteq \text{R} \subseteq \text{RE}$$
$$\text{P} \neq \text{EXP} \quad (\text{time hierarchy theorem, Hartmanis-Stearns 1965})$$
$$\text{R} \neq \text{RE} \quad (\text{halting problem} \in \text{RE} \setminus \text{R})$$

---

## 13. Sorting Lower Bound

**Lower bound for comparison-based sorting:**

$$T(n) \geq \Omega(n \log n)$$

**Information-theoretic argument:**
- The number of permutations of $n$ elements $= n!$; each comparison halves the search space at most.
- The decision tree height $h$ must satisfy $2^h \geq n!$, so $h \geq \log_2(n!) = \Omega(n \log n)$.
- By Stirling's formula: $\log_2(n!) \approx n \log_2 n - n \log_2 e + O(\log n)$.

**Breaking the bound:**
- Non-comparison sorts can surpass $\Omega(n \log n)$: counting sort $O(n+k)$, radix sort $O(d(n+k))$ -- but require special structure in the input.

---

## 14. Algorithm Design Paradigms -- Summary Table

| Paradigm | Key Idea | When to Use | Canonical Example |
|----------|---------|-------------|-------------------|
| Divide-and-Conquer | Decompose -> recurse -> combine | Problem naturally decomposes into independent subproblems | Merge sort, Binary search |
| Dynamic Programming | Overlapping subproblems + optimal substructure; fill a table to avoid recomputation | Severe subproblem overlap with optimal substructure | Floyd-Warshall, Knapsack |
| Greedy | Choose locally optimal at each step | Matroid structure or provable greedy correctness | Kruskal MST, Huffman coding |
| Backtracking | Systematic search + pruning | Search space is finite but large | N-Queens, CSP |
| Branch-and-Bound | Search + maintain upper/lower bounds for pruning | Optimization problems where bounds on solutions can be computed | TSP (exact), Integer programming |
| Randomized | Introduce randomness to reduce expected cost or error probability | Probabilistic guarantees or expected efficiency needed | Miller-Rabin, Randomized quicksort |
| Reduction | Transform a problem into a known problem | An efficient algorithm already exists for the target problem | SAT -> 3SAT (Cook-Levin) |

---

*This file provides mathematical references and historical context for the algorithmic-thinking skill, covering core results from ancient Greece to modern computational theory.*
