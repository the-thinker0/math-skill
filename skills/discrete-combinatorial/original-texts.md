# 离散与组合思想 — 原始文献与历史语境 / Discrete & Combinatorial Thinking — Original Texts & Historical Context

---

## 1. Pigeonhole Principle — Dirichlet (1834) / 鸽巢原理 — Dirichlet (1834)

Peter Gustav Lejeune Dirichlet 在 1834 年以"Schubfachprinzip"（抽屉原理）阐述鸽巢原理，用于数论存在性证明。

> "Wenn man n + 1 Objecte in n Facher distribuiert, so ist mindestens ein Fach mit zwei Objecten besetzt."
> — Dirichlet, 1834

**核心陈述 / Core statement:**
- 基本形式：若 n 物品放入 m 个盒子且 n > m，则某盒子含至少 ⌈n/m⌉ 个物品
- 推广形式：kn+1 物品入 n 盒子 → 某盒至少含 k+1 个物品
- 数论应用：对任意实数 α 和整数 N，存在 q ≤ N 使得 |qα − p| < 1/(N+1)（即 qα 逼近整数）

**Diophantine 逼近 / Diophantine approximation:** 将 [0,1) 分为 N+1 个等长区间（"盒子"），考虑 N+2 个数 {0, {α}, {2α}, ..., {(N+1)α}}（"物品"），鸽巢保证必有两个落入同一区间，得 |(q₁−q₂)α − ⌊(q₁−q₂)α⌋| < 1/(N+1)。这是 Dirichlet 逼近定理的标准鸽巢证明。

---

## 2. Euler's Generating Functions (1748) / Euler 的生成函数 (1748)

Leonhard Euler 在 **Introductio in analysin infinitorum** (1748) 中开创生成函数方法——序列变换为幂级数，计数变换为代数运算。

> "If we ask how many ways a given number can be partitioned, we are led to a study of the generating function." — Euler, 1748

**分拆函数生成函数 / Partition GF:**
$$P(x) = \sum_{n=0}^{\infty} p(n) x^n = \prod_{k=1}^{\infty} \frac{1}{1-x^k}$$
- p(n) = 将 n 分为正整数之和的分拆数。p(5) = 7：{5, 4+1, 3+2, 3+1+1, 2+2+1, 2+1+1+1, 1+1+1+1+1}
- 乘积形式：1/(1−x^k) = 1+x^k+x^{2k}+... 表示"取 k 的 0,1,2,... 次"，各 k 独立故乘积编码组合

**五角数定理 / Pentagonal number theorem (Euler 1750):**
$$\prod_{k=1}^{\infty}(1-x^k) = \sum_{m=-\infty}^{\infty} (-1)^m x^{m(3m-1)/2}$$
- 广义五角数 e_m = m(3m−1)/2：0, 1, 2, 5, 7, 12, 15, 22, ...
- 由 P(x)·∏(1−x^k) = Σ(−1)^m x^{e_m}，得递推 p(n) = p(n−1)+p(n−2)−p(n−5)−p(n−7)+...
- 这是有限递推控制无限序列的经典实例——组合思想的精髓

**Hardy-Ramanujan 渐近公式 (1918):**
$$p(n) \sim \frac{1}{4n\sqrt{3}} \exp\left(\pi\sqrt{\frac{2n}{3}}\right)$$

---

## 3. Catalan Numbers / Catalan 数

**历史 / History:** Eugène Catalan (1838) 研究括号嵌套的计数问题，Catalan 数由此得名。但 Euler 早在 1751 年就研究过类似问题（多边形三角剖分）。

**定义与公式 / Definition and formula:**
$$C_n = \frac{1}{n+1}\binom{2n}{n} = \frac{(2n)!}{n!(n+1)!}$$
- 递推：C₀ = 1, C_n = ΣC_i·C_{n−1−i}
- 生成函数：C(x) = ΣC_n x^n = (1−√(1−4x))/(2x)，由 C(x) = 1 + x·C(x)² 解得

**组合解释（60+种） / Combinatorial interpretations (60+):**
- **二叉树**：n 个节点的有序二叉树数 = C_n
- **Dyck 路径**：从 (0,0) 到 (2n,0) 的格点路径，每步 (+1,+1) 或 (+1,−1)，不越 y=0
- **括号序列**：n 对括号的合法嵌套方式数 = C_n
- **投票问题 (Ballot problem)**：A 得 n+1 票、B 得 n 票，A 全程领先 B 的序列数 = C_n（Bertrand 1887）
- **多边形三角剖分**：n+2 边形的不同三角剖分数 = C_n

前几项：C₀=1, C₁=1, C₂=2, C₃=5, C₄=14, C₅=42, C₆=132

---

## 4. Ramsey Theory — Ramsey (1930) / Ramsey 理论 — Ramsey (1930)

Frank P. Ramsey 在 **"On a Problem of Formal Logic"** (1930) 中证明：足够大的系统必存在某种结构——鸽巢原理的深刻推广。

> "In any sufficiently large system, complete disorder is impossible." — Cohen

**Ramsey 数 / Ramsey numbers:**
$$R(s,t) = \min\{n : \text{任意 } n \text{ 阶 2-色完全图中必有红 } K_s \text{ 或蓝 } K_t\}$$

**已知值:** R(3,3)=6（6人聚会必有3人互识或互不识；证明：固定一人，5人中至少3人同色关系（鸽巢），此3人中若2人同色则3人组，否则此3人构成另一色3人组）, R(4,4)=18, R(3,4)=9, R(3,5)=14.

**一般界:** Erdős 1947 概率方法: R(k,k) > 2^{k/2}; 上界 R(k,k) ≤ 4^k. R(5,5)未知(43≤R(5,5)≤48). Erdős："外星人要R(5,5)就动员所有计算机；要R(6,6)就准备战斗。"

---

## 5. Graph Theory — Euler (1736) / 图论 — Euler (1736)

**Königsberg 七桥问题 / Seven Bridges of Königsberg (1736):**

Leonhard Euler 在 **"Solutio problematis ad geometriam situs pertinentis"** (1736) 解决柯尼斯堡七桥问题，开创图论。

> "The problem... is to find whether one can cross each of the seven bridges exactly once and return to the starting point." — Euler, 1736

**Euler 环定理 / Euler circuit theorem:**
- 连通图存在 Euler 环（经过每边恰好一次的闭路径）iff 所有顶点度数为偶数
- 柯尼斯堡图：4 个顶点度数为 3, 3, 3, 5（均为奇数），故 Euler 环不存在——问题无解

**Euler 平面图公式 / Euler's planar formula (1750):**
$$V - E + F = 2$$
- 对任意连通平面图：顶点数 V、边数 E、面数 F 满足此公式
- 推论：简单连通平面图 E ≤ 3V − 6；不含 K₃ 的平面图 E ≤ 2V − 4

**匹配理论 / Matching theory:**
- König (1931)：二分图中最大匹配数 = 最小顶点覆盖数（König 定理）
- Hall 婚姻定理 (1935)：二分图 G(X,Y) 有 X 到 Y 的完美匹配 iff 对任意 S ⊆ X，|N(S)| ≥ |S|

---

## 6. Pólya Enumeration Theorem (1937) / Pólya 计数定理 (1937)

George Pólya 在 1937 年的论文中给出对称性下的计数方法——轨道计数定理，组合计数与群论的交汇点。

> "The number of distinct colorings is obtained by averaging over the group action." — Pólya, 1937

**定理陈述 / Theorem statement:**
设群 G 作用于集合 X，k-着色等价类数（轨道数）:
$$N = \frac{1}{|G|} \sum_{g \in G} k^{c(g)}$$
c(g) = 置换 g 的循环数。应用: 化学异构体、珠串图案。Burnside 引理 (1897): N = (1/|G|)Σ|Fix(g)|，是 Pólya 特例。Pólya 推广为带权版本: GF × 循环指数 = 对称计数。

---

## 7. Inclusion-Exclusion Principle / 容斥原理

**历史:** da Vinci 用容斥思想计算面积；Sylvester (1882) 形式化。容斥处理交集重叠——直接相加重计交集，需逐层修正。

基本形式: |A₁∪...∪A_n| = Σ|A_i| − Σ|A_i∩A_j| + ... ± |A₁∩...∩A_n|. 补集计数: "不具有P" = 全部 − "具有P".

**错排数:** D(n) = n! − C(n,1)(n−1)! + C(n,2)(n−2)! − ... = n!Σ(−1)^k/k! ≈ n!/e (n→∞). 概率形式: P(A₁∪...∪A_n) = ΣP(A_i) − ΣP(A_i∩A_j) + ...

---

## 8. Recurrence Relations / 递推关系

**Fibonacci 数列 / Fibonacci sequence:**
$$F_0 = 0, F_1 = 1, F_n = F_{n-1} + F_{n-2}$$
- 生成函数：F(x) = ΣF_n x^n = x/(1−x−x²)
- Binet 公式：F_n = (φ^n − ψ^n)/√5，φ = (1+√5)/2 ≈ 1.618（黄金比）

**汉诺塔 / Tower of Hanoi:**
$$T_1 = 1, T_n = 2T_{n-1} + 1$$
- 解：T_n = 2^n − 1。64 层需 2^{64} − 1 ≈ 1.8×10^{19} 步

**GF 求解递推 / Solving recurrences via GF:**
1. 递推乘以 x^n，对 n 求和 → A(x) 的方程
2. 利用初始条件，解出 A(x)（代数/微分方程）
3. 提取 a_n：部分分式、Taylor 展开、幂级数对照

**Catalan GF 推导:** C(x) = 1 + x·C(x)² → 解 x·C² − C + 1 = 0 → C(x) = (1−√(1−4x))/(2x) → C_n = (1/(n+1))C(2n,n)

---

## 9. Combinatorial Optimization / 组合优化

**最小生成树 / Minimum spanning tree:**
- Kruskal (1956)：按边权升序贪心选取不成环的边，O(E log E)
- Prim (1957)：从单点扩展，每次选最小权连接边，O(E log V)（优先队列）

**最大流最小割 / Max-flow min-cut:**
- Ford-Fulkerson (1956)：增广路径法，流量逐步增加直至无增广路径
- 最大流最小割定理：最大流值 = 最小割容量（LP 对偶性的组合表现）
- Edmonds-Karp (1972)：BFS 选最短增广路径，保证 O(VE²)

**匹配理论 / Matching theory:**
- Hungarian 算法 (Kuhn 1955)：O(V³) 最大加权二分匹配
- Edmonds 带花树算法 (1965)：一般图最大匹配，O(V³)

---

## 10. The Twelvefold Way / 十二重道

Richard P. Stanley 在 **Enumerative Combinatorics Vol. 1** 中统一分类 n球入k盒的12种基本计数(2×2×3: 球有标号/无标号 × 盒有标号/无标号 × 任意/至多1/至少1):

| 球 / Balls | 盒子 / Boxes | 条件 / Condition | 公式 / Formula |
|---|---|---|---|
| 有标号 distinct | 有标号 distinct | 任意 any | k^n |
| 无标号 identical | 有标号 distinct | 任意 any | C(n+k−1, k−1) |
| 有标号 distinct | 无标号 identical | 任意 any | Σ S₂(n,i), i=1..k |
| 无标号 identical | 无标号 identical | 任意 any | p_k(n)（受限分拆） |
| 有标号 distinct | 有标号 distinct | 至多一个 ≤1 | P(k,n) = k!/(k−n)! |
| 无标号 identical | 有标号 distinct | 至多一个 ≤1 | C(k,n) |
| 有标号 distinct | 无标号 identical | 至多一个 ≤1 | 1 if n≤k, 0 else |
| 无标号 identical | 无标号 identical | 至多一个 ≤1 | 1 if n≤k, 0 else |
| 有标号 distinct | 有标号 distinct | 至少一个 ≥1 | k!·S₂(n,k) |
| 无标号 identical | 有标号 distinct | 至至少一个 ≥1 | C(n−1, k−1) |
| 有标号 distinct | 无标号 identical | 至少一个 ≥1 | S₂(n,k) − S₂(n,k−1) |
| 无标号 identical | 无标号 identical | 至少一个 ≥1 | p_k(n) − p_{k−1}(n) |

**关键洞察:** 2×2×3=12种基本计数覆盖组合数学核心场景。有标号用EGF，无标号用OGF。**Stirling数:** S₁(n,k)=n元素k循环排列数; S₂(n,k)=n元素k非空子集数。

---

*本文件为离散与组合思想技能的数学参考与历史语境，涵盖从 Euler 到现代组合数学的核心成果。*
*This file provides mathematical references and historical context for the discrete-combinatorial skill, covering core results from Euler to modern combinatorics.*