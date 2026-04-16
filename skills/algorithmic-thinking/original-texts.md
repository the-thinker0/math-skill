# 算法思维 — 原始文献与历史语境 / Algorithmic Thinking — Original Texts & Historical Context

---

## 1. Turing Machine (1936) / 图灵机 (1936)

Alan Turing 的论文 **"On Computable Numbers, with an Application to the Entscheidungsproblem"** (1936) 定义了"可计算性"的精确数学模型——图灵机 (Turing machine)。

> "The 'computable' numbers may be described briefly as the real numbers whose expressions as a decimal are calculable by finite means."
> — Alan Turing, 1936

**核心定义 / Core definition:**
- 图灵机 $M = (Q, \Sigma, \Gamma, \delta, q_0, q_{\text{accept}}, q_{\text{reject}})$，其中 $\delta: Q \times \Gamma \to Q \times \Gamma \times \{L, R\}$ 为转移函数。
- 通用图灵机 (universal Turing machine): 可模拟任意图灵机 $M$ 在输入 $w$ 上的执行，即 $U(\langle M \rangle, w) = M(w)$。

**停机问题 / Halting problem:**
- 停机问题 $H = \{\langle M, w \rangle : M \text{ halts on } w\}$ 是不可判定的 (undecidable)。
- 证明：假设 $H$ 可判定，则构造 $D(\langle M \rangle) = \text{run } H(\langle M, \langle M \rangle \rangle)$；若 $M$ 在 $\langle M \rangle$ 上停机则 $D$ 永不停机，反之 $D$ 停机。令 $D(\langle D \rangle)$ 产生矛盾。

**Entscheidungsproblem (判定问题):**
- Hilbert 1928 年提出：是否存在算法判定一阶逻辑语句的有效性？
- Turing 与 Church 分别独立证明：不存在。一阶逻辑的有效性是不可判定的。

---

## 2. Church-Turing Thesis / Church-Turing 论题

**论题 (thesis, not theorem):**
> 任何"可有效计算"的函数都是图灵可计算的。
> Every "effectively calculable" function is Turing-computable.

**等价表述 / Equivalent formulations:**
- Church: $\lambda$-可定义函数 (lambda calculus, 1936)
- Gödel–Herbrand–Kleene: 一般递归函数 (general recursive functions)
- Post: Post 系统 (Post canonical systems)
- 以上模型计算的函数集完全相同，佐证论题的合理性。

**强 Church-Turing 论题 / Strong Church-Turing thesis:**
- 任何可在物理设备上于时间 $T$ 内求解的问题，均可在图灵机上于时间 $O(T^k)$（$k$ 为常数）内求解。
- 即：所有合理的计算模型在多项式时间内等价。
- 量子计算对此提出挑战——是否存在 $k > 1$ 的多项式加速？

---

## 3. Euclid's Algorithm (~300 BC) / 欧几里得算法 (约公元前300年)

**最古老且仍在使用的算法 / The oldest algorithm still in use.**

**GCD 计算 / GCD computation:**
$$\gcd(a, b) = \gcd(b, a \bmod b), \quad a \bmod b \neq 0$$
$$\gcd(a, 0) = a$$

**终止性证明 / Termination proof:**
- 每一步 $b' = a \bmod b < b$，故序列 $b_0 > b_1 > b_2 > \cdots \geq 0$ 严格递减。
- 有限步内必有 $b_k = 0$，算法终止。

**扩展欧几里得算法 / Extended Euclidean algorithm:**
- 计算 $\gcd(a, b)$ 同时求出 $x, y$ 使得 $ax + by = \gcd(a, b)$。
- 应用：模逆元 $a^{-1} \bmod m$——当 $\gcd(a, m) = 1$ 时，$ax \equiv 1 \pmod{m}$，$x = a^{-1}$。

**时间复杂度:**
- Lamé 定理 (1844): 欧几里得算法的步数 $\leq 5 \times$ 较小数的十进制位数，即 $O(\log \min(a, b))$。

---

## 4. Knuth — The Art of Computer Programming (1968–) / Knuth — 计算机程序设计艺术 (1968–)

Donald Knuth 的多卷巨著 **TAOCP** 系统化了算法分析学科。

> "The process of preparing programs for a digital computer is especially attractive, not only because it can be economically and scientifically rewarding, but also because it can be an aesthetic experience much like composing poetry or music."
> — Donald Knuth, TAOCP Vol. 1, Preface

**贡献 / Contributions:**
- 将 big-O 记号从数论引入计算机科学并普及。$O(f(n))$: 存在常数 $c, n_0$ 使得 $T(n) \leq c \cdot f(n)$ 对所有 $n \geq n_0$。
- 系统化的算法分类体系 (sorting, searching, arithmetic, combinatorial 等)。
- MMIX / MIX 混合伪机器用于算法分析的精确模型。
- 卷目: Vol. 1 (Fundamental Algorithms, 1968), Vol. 2 (Seminumerical Algorithms, 1969), Vol. 3 (Sorting and Searching, 1973), Vol. 4A (Combinatorial Algorithms, 2011).

---

## 5. Cook-Levin Theorem (1971) / Cook-Levin 定理 (1971)

**NP-完全性 / NP-completeness:**

> "The question 'is P = NP?' is one of the most important open questions in theoretical computer science."
> — Stephen Cook, 1971

**Cook-Levin 定理:**
- SAT (布尔可满足性问题) 是 NP-完全的 (NP-complete)。
- 证明：任意 NP 语言 $L$ 的非确定图灵机 $M$ 在 $w$ 上的接受计算可编码为 SAT 公式 $\varphi_{M,w}$；$w \in L \iff \varphi_{M,w}$ 可满足。
- 规约: $L \leq_p \text{SAT}$ 对所有 $L \in \text{NP}$ 成立。

**Karp 的 21 个 NP-完全问题 (1972):**
- Richard Karp 在 "Reducibility among Combinatorial Problems" 中证明 21 个经典问题均为 NP-完全，包括：
  - 3SAT, CLIQUE, VERTEX-COVER, HAM-CYCLE, TSP, SUBSET-SUM, PARTITION 等。

**P vs NP:**
- $\text{P} = \text{NP}$？若成立，则所有 NP 问题均有多项式时间算法。普遍猜测 $\text{P} \neq \text{NP}$。Clay 数学研究所千禧年大奖问题之一。

---

## 6. Divide-and-Conquer / 分治法

**思想 / Key idea:** 将问题分解为若干子问题，递归求解，合并结果。

**经典算法 / Canonical examples:**
- **合并排序 (Merge sort):** $T(n) = 2T(n/2) + O(n) \Rightarrow T(n) = O(n \log n)$。稳定排序。
- **快速排序 (Quicksort):** 平均 $O(n \log n)$，最坏 $O(n^2)$。Hoare (1962)。
- **二分查找 (Binary search):** $T(n) = T(n/2) + O(1) \Rightarrow T(n) = O(\log n)$。有序数组前提。

**主定理 / Master theorem:**
$$T(n) = a\,T(n/b) + f(n)$$
- 情形1: 若 $f(n) = O(n^{\log_b a - \varepsilon})$，则 $T(n) = \Theta(n^{\log_b a})$。
- 情形2: 若 $f(n) = \Theta(n^{\log_b a} \log^k n)$，则 $T(n) = \Theta(n^{\log_b a} \log^{k+1} n)$。
- 情形3: 若 $f(n) = \Omega(n^{\log_b a + \varepsilon})$ 且 $af(n/b) \leq cf(n)$，则 $T(n) = \Theta(f(n))$。

---

## 7. Dynamic Programming / 动态规划

> "I decided to use the word 'dynamic' … it was something not even a Congressman could object to."
> — Richard Bellman, on naming "dynamic programming" (1957)

**核心要素 / Core principles:**
1. **最优子结构 (optimal substructure):** 最优解包含子问题的最优解。
2. **重叠子问题 (overlapping subproblems):** 不同子问题共享更小的子问题，递归会重复计算。

**经典算法:**
- **最短路径:** Dijkstra (1959)——单源最短路径，$O((V+E)\log V)$。
- **Floyd-Warshall (1962):** 所有顶点对最短路径，$O(V^3)$。递推 $d_{ij}^{(k)} = \min(d_{ij}^{(k-1)}, d_{ik}^{(k-1)} + d_{kj}^{(k-1)})$。
- **背包问题 (knapsack):** $O(nW)$ 伪多项式时间。

**自底向上 vs 自顶向下 / Bottom-up vs Top-down (memoization):**
- 自底向上：按子问题规模从小到大填表。
- 自顶向下 + 记忆化 (memoization)：递归但缓存已解子问题的结果。

---

## 8. Greedy Algorithms / 贪心算法

**思想 / Key idea:** 每一步选择局部最优，期望达到全局最优。

**经典算法:**
- **Kruskal 最小生成树 (1956):** 按边权升序加入不形成环的边。$O(E \log E)$。贪心在 MST 问题中有效。
- **Huffman 编码 (1952):** 每次合并频率最低的两个节点。最优前缀编码。

**贪心何时有效 / When greedy works:**
- **拟阵 (matroid) 结构:** 若问题的可行解集构成拟阵 $(E, \mathcal{I})$——即满足遗传性 (hereditary) 与交换性 (exchange property)——则贪心算法对任何权函数均给出最优解。
- 交换性: 若 $A, B \in \mathcal{I}$，$|A| < |B|$，则存在 $e \in B \setminus A$ 使得 $A \cup \{e\} \in \mathcal{I}$。

---

## 9. Backtracking and Search / 回溯与搜索

**深度优先搜索 (DFS) / 广度优先搜索 (BFS):**
- DFS: 用栈（或递归），优先深入；用于拓扑排序、连通分量。
- BFS: 用队列，优先扩展；用于最短路径（无权图）。

**回溯 (backtracking):**
- 系统地枚举候选解，发现不满足约束即回退。
- 例: N-皇后问题、子集枚举、排列枚举。

**剪枝与分支限界 / Pruning and branch-and-bound:**
- 剪枝 (pruning): 利用约束提前排除不可能的分支，减少搜索空间。
- 分支限界 (branch-and-bound): 对优化问题，维护当前最优解的界，剪去不可能更优的分支。常用于 TSP、整数规划。

**约束满足问题 (CSP) / Constraint satisfaction:**
- 变量集 + 值域 + 约束集。回溯搜索 + 约束传播 (AC-3 等)。

---

## 10. Randomized Algorithms / 随机化算法

**两类 / Two types:**
- **Las Vegas 算法:** 结果始终正确，运行时间随机。例：随机化 quicksort。
- **Monte Carlo 算法:** 运行时间确定，结果可能错误（但错误概率可控制在任意小）。例：Miller-Rabin 素性测试。

**Miller-Rabin 素性测试 (1976/1980):**
- 对奇数 $n$，选取随机 $a \in \{2, \ldots, n-1\}$，检验 $a^{d} \bmod n$ 的序列是否满足 Fermat 小定理的强化条件。
- 单次测试的错误概率 $\leq 1/4$；$k$ 次独立测试后错误概率 $\leq 4^{-k}$。
- 时间 $O(k \log^3 n)$。

**随机化快速排序 / Randomized quicksort:**
- 随机选取 pivot，期望比较次数 $2n \ln n \approx 1.39 n \log_2 n$，期望运行时间 $O(n \log n)$。
- 最坏 $O(n^2)$ 的概率可证明极低。

---

## 11. Decidability and Undecidability / 可判定性与不可判定性

**停机问题不可判定 / Halting problem is undecidable (see §1).**

**Rice 定理 (1953):**
> 关于图灵机的任何非平凡语义性质都是不可判定的。
> Every non-trivial semantic property of Turing machines is undecidable.

- "语义性质": 仅取决于 $M$ 计算的函数，不取决于 $M$ 的结构。
- "非平凡": 对某些图灵机成立，对某些不成立。
- 例："M 是否计算常数函数""M 是否在某输入上停机""M 是否计算可判定语言"——均不可判定。

**Post 对应问题 / Post correspondence problem (PCP, 1946):**
- 给定 domino 集合 $\{(t_1, b_1), \ldots, (t_k, b_k)\}$（$t_i, b_i$ 为字符串），是否存在序列 $i_1, i_2, \ldots, i_m$ 使得 $t_{i_1} t_{i_2} \cdots t_{i_m} = b_{i_1} b_{i_2} \cdots b_{i_m}$？
- PCP 是不可判定的。常用于证明其他问题的不可判定性。

---

## 12. Complexity Classes / 复杂度类

| 类 / Class | 定义 / Definition | 中文说明 |
|---|---|---|
| **P** | $\{L : L \text{ 可在 } O(n^k) \text{ 时间内判定}\}$ | 多项式时间可判定 |
| **NP** | $\{L : L \text{ 有多项式长度的验证证书}\}$ | 非确定多项式时间可判定 |
| **co-NP** | $\{L : \bar{L} \in \text{NP}\}$ | NP 的补类 |
| **EXP** | $\{L : L \text{ 可在 } O(2^{n^k}) \text{ 时间内判定}\}$ | 指数时间可判定 |
| **R** | $\{L : L \text{ 是可判定的}\}$ | 递归语言 / 可判定语言 |
| **RE** | $\{L : L \text{ 可被图灵机识别}\}$ | 递归可枚举语言 |

**层次关系 / Hierarchies:**
$$\text{P} \subseteq \text{NP} \subseteq \text{PSPACE} \subseteq \text{EXP} \subseteq \text{R} \subseteq \text{RE}$$
$$\text{P} \neq \text{EXP} \quad (\text{time hierarchy theorem, Hartmanis–Stearns 1965})$$
$$\text{R} \neq \text{RE} \quad (\text{halting problem} \in \text{RE} \setminus \text{R})$$

---

## 13. Sorting Lower Bound / 排序下界

**比较排序的下界 / Lower bound for comparison-based sorting:**

$$T(n) \geq \Omega(n \log n)$$

**信息论论证 / Information-theoretic argument:**
- $n$ 个元素的排列数 $= n!$，每次比较至多将搜索空间减半。
- 决策树高度 $h$ 须满足 $2^h \geq n!$，故 $h \geq \log_2(n!) = \Omega(n \log n)$。
- 由 Stirling 公式: $\log_2(n!) \approx n \log_2 n - n \log_2 e + O(\log n)$。

**突破下界的方法 / Breaking the bound:**
- 非比较排序可超越 $\Omega(n \log n)$：计数排序 $O(n+k)$，基数排序 $O(d(n+k))$——但要求输入有特殊结构。

---

## 14. Algorithm Design Paradigms — Summary Table / 算法设计范式总结表

| 范式 / Paradigm | 核心思想 / Key Idea | 适用条件 / When to Use | 典型例子 / Canonical Example |
|---|---|---|---|
| 分治 / Divide-and-Conquer | 分解→递归→合并 | 问题可自然分为独立子问题 | Merge sort, Binary search |
| 动态规划 / Dynamic Programming | 子问题重叠+最优子结构，填表避免重复 | 子问题重叠严重，有最优子结构 | Floyd-Warshall, Knapsack |
| 贪心 / Greedy | 每步取局部最优 | 拟阵结构或可证贪心正确性 | Kruskal MST, Huffman coding |
| 回溯 / Backtracking | 系统搜索+剪枝 | 搜索空间有限但巨大 | N-Queens, CSP |
| 分支限界 / Branch-and-Bound | 搜索+维护上下界剪枝 | 优化问题，可计算解的界 | TSP (exact), Integer programming |
| 随机化 / Randomized | 引入随机性降低期望代价或错误概率 | 需要概率保证或期望高效 | Miller-Rabin, Randomized quicksort |
| 归约/规约 / Reduction | 将问题变换为已知问题 | 已有高效算法求解目标问题 | SAT → 3SAT (Cook-Levin) |

---

*本文件为算法思维技能的数学参考与历史语境，涵盖从古希腊到现代计算理论的核心成果。*
*This file provides mathematical references and historical context for the algorithmic-thinking skill, covering core results from ancient Greece to modern computational theory.*