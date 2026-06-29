---
name: discrete-combinatorial
description: |
  触发：当需要计数、枚举、发现有限结构中的规律，或处理图论、组合结构、生成函数、递推关系；或为稀疏/路由/拓扑结构设计组合方案时调用。
  English: Trigger when you need to count, enumerate, find patterns in finite structures, or handle graph theory, combinatorial structures, generating functions, recurrences; or design combinatorial schemes for sparse/routing/topological structures.
---

# 🧮 离散与组合思想 / Discrete & Combinatorial

> "计数是最古老的数学活动——有限对象蕴含无限规律。"
> "Counting is the oldest mathematical activity — finite objects harbor infinite patterns."
>
> —— 组合数学、图论、生成函数
> —— Combinatorics, Graph Theory, Generating Functions

## 核心原则 / Core Principle

**组合思想对有限结构进行系统计数、发现支配枚举的规律，并用生成函数等代数方法将计数问题变换为代数问题——有限的简单掌控无限的复杂。**

**Combinatorial thinking systematically counts finite structures, discovers patterns governing enumeration, and uses algebraic methods (generating functions) to recast counting as algebra — finite simplicity governing infinite complexity.**

> **数学形式化 / Mathematical Formalization**
>
> **鸽巢原理 (Pigeonhole Principle)**：n 个物品放入 m < n 个盒子，则某盒至少含 2 个；推广 kn+1 入 n 盒则某盒至少含 k+1。存在性证明利器——只证必然存在，不构造具体实例。
>
> **容斥原理 (Inclusion-Exclusion)**：|A₁∪...∪A_n| = Σ|A_i| − Σ|A_i∩A_j| + ... ± |A₁∩...∩A_n|；补集计数："不具有 P" = 全部 − "具有 P"。
>
> **生成函数 (Generating Functions)**：常生成函数 OGF A(x)=Σa_n x^n（无序/组合，A·C 系数 = Σa_i·c_{n−i}）；指数生成函数 EGF B(x)=Σb_n x^n/n!（有序/有标号，B·D 系数/n! = Σ(b_i/i!)·(d_{n−i}/(n−i)!)）。
>
> **Pólya 计数定理 (Pólya Enumeration)**：群 G 作用下的轨道计数 = (1/|G|)Σ_{g∈G}|Fix(g)|（Burnside 引理），用循环指标多项式刻画"旋转/翻转视为相同"的等价类着色计数。
>
> Euler 的洞察：将 1+2+3+... 的"发散级数"重新诠释为分拆计数的生成函数。

## GPU 友好性 / GPU-Friendliness（横切检查）

离散/组合结构常「美但不可算」——精确计数多为 #P 完备（着色计数、匹配计数），精确枚举 NP-hard（Hamilton 路、子集和），直接落 GPU 不可行。落 GPU 须过 `../../references/gpu-friendly-math.md` 八维门，改用可张量化的聚合与采样近似：

- **友好**：邻接矩阵幂迭代 A^k 计路径数（GEMM）、动态规划表批量并行、bitset packed 计数（popcount）、结构化稀疏图遍历。
- **可改造**：容斥/递推 → 半环聚合（(min,+) / (max,+) / Boolean / 热带半环）张量化；精确计数 → 蒙特卡洛/重要性采样估计；枚举 → 分支定界剪枝 + 批量并行；离散选择 → Gumbel-softmax 松弛。
- **反模式**：精确全枚举（n! 爆炸）、串行回溯搜索、强串行 DP（长程依赖不可并行）、非结构化图随机访存——"美但不可算"，须近似或松弛。

八维最低判定（正式术语）：**张量化**看有限对象能否编码成矩阵/bitset/批量表；**GEMM 可映射**看递推能否半环矩阵化；**复杂度**明确 NP-hard/#P-hard 与近似界；**显存与 KV-Cache**检查枚举表、DP 表、邻接结构是否爆炸；**低精度稳定**看松弛采样和半环运算是否数值稳健；**并行与通信**看子问题是否独立或可斜扫描；**稀疏结构**只采用块/带状/规则图稀疏；**算子融合**看计数、mask、采样能否合并为少量 kernel。

> 配合 `../../references/books/abstract-algebra.md`（半环/有限域聚合）、`../../references/books/matrix-analysis.md`（邻接矩阵/谱图）。

## 不适用场景 / When NOT to Use

- **连续/分析性问题，无离散结构**——极限、微分、积分而非有限对象计数，属分析而非组合。
- **精确闭式公式可直接给出答案**——组合枚举是多余开销（如 n·(n−1) 直接代数运算）。
- **纯粹概率问题，无组合结构**——连续分布参数估计、贝叶斯更新不涉及有限集合计数，概率密度积分不是组合问题。

## 何时使用 / When to Use

- 需要计数配置数量（排列/选择/分配），答案是具体有限数而非 1 或无穷。
- 需通过鸽巢原理证存在性（"必存在某对象具某性质"）而不构造实例。
- 需发现枚举数列 {a_n} 的递推或封闭公式（如 Catalan C_n = (2n)!/(n!(n+1)!)）。
- 需枚举满足约束的配置——按结构分类、按规则生成，非随机罗列。
- 需图/网络分析（连接、路径、匹配、着色、覆盖）——社交网络、调度、规划可化为图问题。
- 需求解递推关系求封闭公式或渐近行为——递推 → 生成函数 → 代数求解 → 提取系数。
- **为稀疏/路由/拓扑结构设计组合方案**——稀疏 attention 模式、路由表/拓扑排序、块结构化稀疏布局。

## 方法流程 / Method

### 第一步：识别离散结构与计数问题
明确**计数对象**（排列/组合/分拆/安排）、**目标**（总数/带约束子集/概率）、**约束**（互不相交、有序/无序、有标号/无标号）。分类：排列 P(n,k)=n!/(n−k)!；组合 C(n,k)=n!/(k!(n−k)!)；分拆 p(n) 整数分拆、B(n) 集合分拆；安排（物品入位置）。

### 第二步：应用基本计数原理
- **乘法原理**：k 个独立选择 → k₁×k₂×...×k_n。
- **加法原理**：互斥选项 → |A∪B|=|A|+|B|（A∩B=∅）。
- **鸽巢原理**：n>m 碰撞不可避免，某盒至少 ⌈n/m⌉；推广 kn+1 入 n 盒则某盒至少含 k+1。

### 第三步：使用容斥原理
|A₁∪...∪A_n| = Σ|A_i| − Σ|A_i∩A_j| + Σ|A_i∩A_j∩A_k| − ... ± |A₁∩...∩A_n|。**补集计数**："不具有 P" = 全部 − "具有 P"；经典错排 D(n) = n! − C(n,1)(n−1)! + C(n,2)(n−2)! − ... ± C(n,n)·0!。**符号规则**：第 k 层贡献 = (−1)^{k+1} Σ|A_{i₁}∩...∩A_{i_k}|（奇层正、偶层负）。

### 第四步：构造生成函数
- **OGF**：A(x)=Σa_n x^n，无序/组合；A(x)·C(x) 系数 = Σa_i·c_{n−i}（组合两个独立计数）。
- **EGF**：B(x)=Σb_n x^n/n!，有序/排列/有标号；B(x)·D(x) 系数/n! = Σ(b_i/i!)·(d_{n−i}/(n−i)!)。
- 经典：分拆 P(x)=Σp(n)x^n = 1/((1−x)(1−x²)(1−x³)...)；Catalan C(x)=ΣC_n x^n = (1−√(1−4x))/(2x)，由 C_n=ΣC_i·C_{n−1−i} 得 C(x)=1+x·C(x)²。

### 第五步：分析图结构
图 G=(V,E)，|V| 顶点、|E| 边。核心：度数 deg(v)、邻接/关联矩阵；路径/连通分量、最短路（Dijkstra、Floyd-Warshall）；树恰 n−1 边、生成树（Kruskal/Prim）、二叉树计数 C_n；平面图 Euler 公式 V−E+F=2、E≤3V−6；色数 χ(G)、四色定理 χ(平面图)≤4；匹配（Hall 婚姻定理、König：二分图最大匹配=最小顶点覆盖）；Euler 环（连通且全度数偶）、Hamilton 环（NP-complete）。

### 第六步：发现递推与封闭公式
- **递推**：Catalan C_n=ΣC_i·C_{n−1−i}，Fibonacci F_n=F_{n−1}+F_{n−2}，错排 D_n=(n−1)(D_{n−1}+D_{n−2})。
- **生成函数求解**：递推乘 x^n 求和 → 解 A(x) → 提取 a_n；Fibonacci F(x)=x/(1−x−x²)，部分分式得 F_n=(φ^n−ψ^n)/√5（φ=(1+√5)/2）。
- **直接公式**：C(n,k)=n!/(k!(n−k)!)（n 选 k 无序）；Catalan C_n=C(2n,n)/(n+1)（合法括号序列组合论证）。

### 第七步：验证与推广
检查小案例 n=0,1,2,3 手动枚举与公式对比；验证公式计数正确、递推自洽、边界条件无误（空结构计数为 1：C₀=1, F₀=0, F₁=1）；推广至更一般参数或更深组合解释。

> **验证不是可选的——未经验证的计数公式不可信。** n=3 的手动枚举与公式对比是最低验证要求。

## 常见错误 / Common Errors

| 错误 / Error | 批评 / Critique | 正确做法 / Correct Approach |
|---|---|---|
| 漏计与重计 | 漏计：遗漏约束交互少计；重计：同配置多次计算 | 明确约束交互，容斥修正重计，补集修正漏计 |
| 忽略约束条件交互 | 约束非独立，交集须容斥处理 | 用容斥：并集 = 各集之和 − 交集 |
| 混淆排列与组合 | 排列计序 P(n,k)=n!/(n−k)!，组合不计序 C(n,k)=n!/(k!(n−k)!) | 先判有序/无序再选公式 |
| 错误使用容斥符号 | 奇层正、偶层负，符号错则结果偏差 | 严格按 (−1)^{k+1} 定符号 |
| 忽略生成函数收敛域 | 形式幂级数可忽略收敛，但提封闭公式须在收敛域内 | 区分形式操作与解析操作 |
| 混淆有标号/无标号 | 有标号用 EGF，无标号用 OGF | 排列/分布→EGF；组合/分拆→OGF |
| 鸽巢原理使用不当 | 仅证存在性不构造实例，需 n>m | 确认 n>m，结论为"至少一个"非"恰好一个" |
| 递推边界条件错误 | C₀=1 非 0；F₀=0, F₁=1 | 空结构=1，检查 n=0,1 边界 |
| GPU 不可算性 | 精确枚举/计数 #P 或 NP-hard 爆炸 | 改半环聚合/采样近似，过 GPU 八维门 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，输出必须包含：

1. **结构识别**：`[结构]: [离散对象]` — 计数对象、约束、分类
2. **计数类型**：`[计数类型]: [排列/组合/分拆/安排]` — 有序/无序、有标号/无标号
3. **原理选择**：`[原理]: [乘法/加法/鸽巢/容斥]` — 选择理由
4. **生成函数**：`[生成函数]: [公式]` — GF 及代数性质（如涉及）
5. **图结构**：`[图结构]: [属性]` — 顶点/边/连通/着色（如涉及）
6. **递推/公式**：`[递推/公式]: [内容]` — 递推及封闭公式
7. **验证**：`[验证]: [小案例]` — 至少 n=0,1,2,3 手动枚举与公式对比
8. **[GPU 可行性]**（若用于算法/算子设计）— 精确计数/枚举是否 NP-hard/#P，能否半环聚合/张量化/采样近似，过八维门

**输出不得只给分析而无结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **归纳与类比**：组合规律由归纳发现——从 {a_n} 前几项归纳递推，再类比到更一般结构。
- **算法思想**：组合计数支撑复杂度分析——n!、C(n,k) 是算法代价估计基础。
- **概率与统计**：组合是概率的计算基础——古典概率 P(A)=|A|/|Ω|，分子分母皆组合计数。
- **变换思想**：生成函数将计数变换为代数——序列→幂级数，递推→方程，计数→系数提取。
- **公理化思想**：组合恒等式需严格证明——C(n,k)=C(n,n−k) 须代数或组合论证，不可仅凭直觉。
- **现代数学激活**：`../../references/books/abstract-algebra.md`（有限域/半环聚合、Burnside 计数）、`../../references/books/matrix-analysis.md`（邻接矩阵/谱图/传递矩阵）。
