---
name: symmetry-invariance
description: |
  触发：当需要寻找变化中的不变性质、揭示隐藏规律、分类研究对象，或在复杂系统中找到简化线索时调用。
  English: Trigger when needing to find invariants amidst change, reveal hidden patterns, classify objects, or find simplification clues in complex systems.
---

# ⚛️ 对称与不变性

> "寻找事物在变换下保持不变的性质，揭示其内在规律。"
> "Finding the properties that remain unchanged under transformations, revealing their underlying laws."
>
> —— 群论、不变量理论、Noether 定理
> —— Group Theory, Invariant Theory, Noether's Theorem
>
> Sophus Lie 想打造一把屠龙刀——解通微分方程。虽然未能屠尽所有的龙，但这把刀的锻造工艺（李群-李代数对应关系）流传了下来。后来的人发现，这把刀用来切菜（线性化非线性问题）、用来雕刻（描述物理对称性）、用来盖房子（机器人状态估计），简直是神兵利器。数学最迷人的地方就在于：为解决特定问题而发明的工具，最终在完全不同的领域展现出远超初衷的价值。
> Sophus Lie wanted to forge a dragon-slaying sword — solving all differential equations. Though it couldn't slay every dragon, the forging technique (Lie group–Lie algebra correspondence) endured. Later generations found this sword perfect for slicing vegetables (linearizing nonlinear problems), sculpting (describing physical symmetries), and building houses (robot state estimation). The most fascinating aspect of mathematics: tools invented for specific problems eventually reveal value far beyond their original purpose in entirely different domains.

## 核心原则 / Core Principle

**在变化中寻找不变——这是理解复杂系统的捷径。对称性不是'好看'，而是系统深层结构的体现。每一个对称性都对应一个守恒量（Noether 定理），每一个不变量都是简化问题的钥匙。**

**Finding invariants amidst change is the shortcut to understanding complex systems. Symmetry is not just 'aesthetic'—it reflects the deep structure of a system. Every symmetry corresponds to a conserved quantity (Noether's Theorem), and every invariant is a key to simplifying problems.**

### 数学形式化 / Mathematical Formalization

群 **G** 作用在集合 **X** 上，通过映射 φ: G×X→X（满足 φ(e,x)=x, φ(g,φ(h,x))=φ(gh,x)）。

**不变量**是函数 f: X→Y 使得 f(g·x)=f(x) 对所有 g∈G 成立。不变量把 X 的丰富结构压缩为对 G "看不见"的信息——它只区分轨道，不区分同一轨道内的元素。形式化：f 是 G-不变量 ⇔ f: X/G → Y 为商空间上的函数。

**轨道** O(x)={g·x : g∈G} 将 X 划分为等价类。同一轨道中的元素在 G 的视角下不可区分。等价关系：x~y ⇔ ∃g∈G 使得 y=g·x。X/~ = X/G。

**商空间** X/G 由所有轨道构成。分类的本质是在 X/G 上工作；寻找不变量的本质是找到在每条轨道上取常值的函数。

**稳定子** Stab(x)={g∈G : g·x=x} 是 G 的子群，衡量 x 的局部对称程度。|O(x)|=|G|/|Stab(x)|——轨道越大，对称越少。

A group **G** acts on a set **X** via φ: G×X→X (satisfying φ(e,x)=x, φ(g,φ(h,x))=φ(gh,x)). An **invariant** is a function f: X→Y with f(g·x)=f(x) for all g∈G—it compresses X's structure into information invisible to G, distinguishing orbits but not elements within an orbit. Formally: f is G-invariant ⇔ f: X/G → Y is a function on the quotient. The **orbit** O(x)={g·x : g∈G} partitions X via x~y ⇔ ∃g∈G with y=g·x. X/~ = X/G. The **quotient** X/G consists of all orbits. Classification amounts to working on X/G; finding invariants amounts to finding functions constant on each orbit. The **stabilizer** Stab(x)={g∈G : g·x=x} is a subgroup of G, measuring local symmetry: |O(x)|=|G|/|Stab(x)|—larger orbit = less symmetry.

核心直觉：**不变量 = 轨径上的常值函数 = 商空间 X/G 上的函数**。一个完备的不变量集能将 X/G 嵌入到某个更简单的空间中，从而实现完全分类。

Core intuition: **Invariant = function constant on orbits = function on the quotient X/G**. A complete set of invariants embeds X/G into a simpler space, achieving full classification.

对称与不变性的层次：
- **几何对称**：反射、旋转、平移对称——群为正交群 O(n)、欧氏群 E(n)。不变量：距离、面积、体积（等距变换下）；角度（共形变换下）
- **代数对称**：方程根的置换对称（Galois 理论）——群为 Gal(f)⊂S_n。不变量：初等对称多项式、判别式
- **物理对称**：时空对称 → 守恒律（Noether 定理）——群为 Lie 群（如 SO(3)、Poincaré 群）。不变量：能量、动量、角动量
- **逻辑不变**：命题逻辑结构在变换下的保持——群为自同构群 Aut(结构)。不变量：真值函数、推理有效性
- **结构不变**：系统在演化中保持的本质特征——同构（代数结构不变）、同伦等价（拓扑结构不变）

> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **系统完全不对称且无规律**——没有对称性可寻找，无群作用可利用 / Systems with no discernible symmetry or pattern—no group action to exploit
- **需要精确数值解**——对称性通常给出结构信息而非具体数值，不变量告诉你"什么相等"但不告诉你"等于多少" / When precise numerical answers are required—symmetry gives structural info, not quantitative values; invariants tell you "what is equal" but not "equal to what"
- **对称破缺是核心机制**（如相变、自发对称破缺）——这时关注的是对称性的破坏而非保持，应转向分析破缺模式而非寻找不变量 / When symmetry breaking itself is the central mechanism—focus shifts to how symmetry is violated, not preserved; analyze breaking pattern G→H instead of invariants
- **问题规模极小**——对称性分析的开销（寻找群、验证公理、计算 Reynolds 算子）可能超过直接求解 / Tiny problems where the overhead of symmetry analysis (finding group, verifying axioms, computing Reynolds operator) exceeds brute-force solving
- **群结构过于复杂**——当 |G| 极大或结构难以确定时，商空间 X/G 不比 X 更简单，不变量本身可能比原问题更复杂 / When |G| is enormous or hard to determine, X/G is no simpler than X; invariants may be more complex than the original problem

## 何时使用 / When to Use

- 面对一个复杂系统，想要找到简化线索 / Facing a complex system, seeking simplification clues
- 需要分类或识别研究对象（利用对称性分类） / Needing to classify objects via symmetry—their orbits in X/G
- 寻找问题中的守恒量或不变量 / Seeking conserved quantities or invariants—functions constant on orbits
- 识别模式、预测变化趋势 / Identifying patterns, predicting trends
- 想要理解一个系统的深层结构而非表面行为 / Wanting deep structure, not surface behavior
- 在科研中发现新的定理或规律（对称性指引） / Discovering new theorems guided by symmetry
- 需要减少变量或降低维度（商空间、基本域） / Needing dimension reduction via quotient spaces or fundamental domains
- 需要判断方程的可解性（Galois 理论） / Judging solvability of equations via Galois theory
- 需要计数对称构型（Burnside 引理、Pólya 计数） / Counting symmetric configurations via Burnside's lemma or Pólya enumeration
- 需要从守恒律反推可能的对称性（逆 Noether 问题） / Inferring possible symmetries from known conservation laws (inverse Noether problem)

## 方法流程 / Method

### 第一步：识别可能的变换 / Identify Possible Transformations

列出系统可能经历的所有变换，组织为候选对称群，验证群性质：
- **空间变换**：平移、旋转、反射、缩放 → 可能构成欧氏群 E(n)、正交群 O(n)、相似群
- **时间变换**：时间平移、时间反演 → 可能构成 R（平移）或 Z₂（反演）或其直积
- **代数变换**：变量替换、参数变换 → 置换群 S_n、线性群 GL(n)、特殊线性群 SL(n)
- **逻辑变换**：命题的否定、等价替换 → Z₂、更一般的自同构群 Aut(结构)
- **规范变换**：物理中的 U(1)、SU(2)、SU(3) → Lie 群，需配合 Lie 代数分析

对每个候选群验证四条公理：封闭性（gh∈G）、结合律（(gh)k=g(hk)）、单位元（e∈G）、逆元（g⁻¹∈G）。若不满足，需识别它究竟是什么结构（半群？广群？），不能盲目当作群使用。

常见陷阱：反射变换集看似是群，但两次反射 = 旋转（封闭性成立）；投影变换集不满足逆元（投影不可逆，不是群）。验证是强制步骤，不可跳过。

Organize candidate transformations as potential symmetry groups; verify group axioms: closure (gh∈G), associativity ((gh)k=g(hk)), identity (e∈G), inverse (g⁻¹∈G). If axioms fail, identify the actual structure (semigroup? magma?)—do not treat it as a group. Common pitfall: reflections compose to rotations (closure holds); projections lack inverses (not a group). Verification is mandatory. Space → E(n), O(n); time → R or Z₂; algebraic → S_n, GL(n), SL(n); logical → Z₂, Aut; gauge → U(1), SU(2), SU(3) as Lie groups.

### 第二步：寻找不变量 / Find Invariants

对于群 G 作用在 X 上，寻找函数 f 使得 f(g·x)=f(x) 对所有 g∈G。这是不变量理论的核心计算问题。数学方法：

**有限群的方法**：
- **Reynolds 算子**：对有限群 G，R(f)=1/|G| Σ_{g∈G} f(g·x)。R(f) 是 G-不变量且是 f 的"平均化"。R 是投影算子：R²=R，R 的像正是所有不变量。若 f 已是不变量，则 R(f)=f。Reynolds 算子是最通用的不变量构造方法——任意函数经平均化后自动成为不变量。
- **Burnside 引理**：|X/G|=1/|G| Σ_{g∈G} |Fix(g)|，计数不同轨道数（即真正不同的构型数）。Fix(g)={x∈X : g·x=x} 是 g 的不动点集。这是"有多少真正不同的对象"这一问题的标准答案。
- **初等不变量构造**：对 S_n 作用于 R^n，初等对称多项式 e_k=Σ_{i₁<…<i_k} x_{i₁}…x_{i_k} 构成完备不变量集——任意 S_n-不变多项式都可表示为 e₁,…,e_n 的多项式（对称多项式基本定理）。

**连续群（Lie 群）的方法**：
- 用 Lie 代数的生成元 T_a 作用：T_a·f=0（f 在 T_a 方向上不变）是微分方程，解之即得不变量。每个生成元给出一个线性约束 T_a·f=0，|dim G| 个约束 → f 的自由度减少。
- Killing 向量场方法：找出保持度量不变的向量场，积分即得不变坐标。例：SO(3) 作用于 R³，Killing 向量场对应旋转，积分得 r=√(x²+y²+z²) 为 SO(3)-不变量。

**不动点分析**：寻找 X 中满足 g·x=x 的点，稳定子 Stab(x)={g∈G : g·x=x} 揭示 x 的局部对称程度。

Common invariants by domain:
- 几何：长度（等距变换下）、角度（共形变换下）、欧拉示性数（拓扑变换下）
- 物理：能量（时间平移对称）、动量（空间平移对称）、角动量（旋转对称）
- 代数：多项式判别式、矩阵的行列式和迹、特征多项式的系数
- 组合：轨道数（Burnside 引理）、等价类大小（轨道-稳定子定理）

For G acting on X, find f with f(g·x)=f(x). Finite groups: Reynolds operator R(f)=1/|G| Σ f(g·x) (projection onto invariants, R²=R); Burnside's lemma |X/G|=1/|G| Σ |Fix(g)| for orbit counting; elementary symmetric polynomials e_k form a complete invariant set for S_n on R^n (fundamental theorem of symmetric polynomials). Continuous groups: solve T_a·f=0 via Lie algebra generators (each generator reduces one degree of freedom); Killing vector fields yield invariant coordinates (e.g., r=√(x²+y²+z²) for SO(3) on R³). Fixed-point analysis: Stab(x)={g∈G : g·x=x} reveals local symmetry degree.

### 第三步：利用不变量简化问题 / Use Invariants to Simplify

不变量是简化问题的利器，三种主要策略：

- **商空间推理**：在 X/G 上工作而非 X。原来需要处理 |X| 个对象，现在只需处理 |X/G| 个轨道。问题维度大幅降低。例如：S_n 作用于 R^n，商空间由初等对称多项式参数化，n 个变量减为 n 个不变量（但独立约束减少）。又如：晶体学中，所有 230 种空间群对应 230 种不同的 X/G 结构。
- **基本域**：找到 X 的子集 D 使得每条轨道恰与 D 交于一点。只需分析 D，结果自动推广到全 X。例如：O(2) 作用于平面，基本域是半平面；SO(3) 作用于球面，基本域是球面三角形；SL(2,Z) 作用于上半平面，基本域由 |z|≥1, |Re(z)|≤1/2 定义。
- **变量缩减**：若 f 不变，用它替代被约束的变量。例如：能量守恒 → 减少一个动力学变量（从 n+1 个变量到 n 个变量 + 1 个常数约束）；角动量守恒 → 在角空间中只关心径向运动；中心力场中 L²=常数 → 约化为一维径向方程。

Invariant-driven simplification: (1) work on quotient X/G instead of X—|X/G| orbits vs |X| elements; 230 space groups give 230 different X/G structures in crystallography. (2) fundamental domain D where each orbit meets D exactly once—O(2) on plane: half-plane; SO(3) on sphere: spherical triangle; SL(2,Z) on upper half-plane: |z|≥1, |Re(z)|≤1/2. (3) replace constrained variables by invariants: energy conservation reduces n+1 variables to n+constant; angular momentum L²=constant reduces central force problem to 1D radial equation.

### 第四步：利用对称性分类 / Use Symmetry for Classification

**轨道-稳定子定理**：|O(x)|=|G|/|Stab(x)|。轨道大小揭示对象的对称程度——稳定子越大，对象越"对称"，轨道越小。完全对称的对象（Stab(x)=G）的轨道是单点 {x}。

根据对称群的不同，对象分为不同的等价类（轨道）。同一轨道中的对象共享所有 G-不变量的值。分类的关键问题：不变量是否完备？即：f(x)=f(y) 能否推出 x 与 y 在同一轨道上？若能，则不变量集实现了完全分类。

**不完备不变量的后果**：若不变量集不完备，则存在"不同轨道上的对象具有相同不变量值"的情况——仅凭不变量无法区分它们。此时需引入更多不变量或使用更精细的群。

**完备不变量的经典例子**：
- S_n 作用于 R^n：初等对称多项式 e₁,…,e_n 构成完备不变量集
- O(n) 作用于 R^n：距离函数 r²=Σ x_i² 是完备不变量（对 n=1）
- SL(2,C) 作用于二次型：判别式 Δ=b²-4ac 是完备不变量

Orbit-stabilizer theorem: |O(x)|=|G|/|Stab(x)|. Larger stabilizer = more symmetric object = smaller orbit. Fully symmetric objects (Stab(x)=G) have singleton orbits {x}. Classification via orbits: objects in the same orbit share all G-invariant values. Key question: is the invariant set complete? i.e., does f(x)=f(y) imply x and y are in the same orbit? If yes, invariants achieve full classification. Consequence of incomplete invariants: different orbits may have the same invariant values—more invariants or finer groups needed. Classical complete invariant examples: S_n on R^n → elementary symmetric polynomials e₁,…,e_n; O(n) on R^n → r²=Σ x_i² (for n=1); SL(2,C) on quadratic forms → discriminant Δ=b²-4ac.

### 第五步：检查对称性破缺 / Check for Symmetry Breaking

理解系统的关键有时不在对称性本身，而在对称性何时、以何种方式被打破：

- **自发对称破缺**：方程有对称性 G，但解只满足 G 的子群 H⊂G。真空（基态）选择了特定方向，打破 G→H。
  - **Goldstone 定理**：连续对称 G→H 破缺产生 dim(G/H) 个无质量 Goldstone 模。这些模对应被破缺方向上的"软"涨落。
  - 例：铁磁体——SO(3)→SO(2)，破缺产生 2 个 Goldstone 模（自旋波）
  - 例：超流体——U(1)→{e}，破缺产生 1 个 Goldstone 模（声子）
- **显式对称破缺**：方程本身不满足 G，对称性被外部力破坏。微扰项破坏对称性。
  - 例：外磁场下的铁磁体——SO(2) 对称被进一步破坏
  - 例：质量项破坏手征对称——夸克质量使 SU(2)_L×SU(2)_R → SU(2)_V
- **分析要点**：识别破缺模式 G→H，确定 H 的结构，计算 Goldstone 模数 dim(G/H)，评估破缺是否改变物理可观测量的定性行为。特别注意：破缺后的有效理论仍需在 H 下不变。

Spontaneous breaking: equations have symmetry G, solutions only H⊂G. Vacuum selects a direction, breaking G→H. Goldstone theorem: continuous G→H breaking yields dim(G/H) massless Goldstone modes (soft fluctuations along broken directions). Examples: ferromagnet—SO(3)→SO(2) yields 2 Goldstone modes (spin waves); superfluid—U(1)→{e} yields 1 Goldstone mode (phonon). Explicit breaking: equations lack symmetry G due to external perturbation. Examples: ferromagnet in external field—SO(2) further broken; quark masses break chiral symmetry SU(2)_L×SU(2)_R → SU(2)_V. Key analysis: identify breaking pattern G→H, compute dim(G/H), assess qualitative impact. Note: the effective theory after breaking must still be H-invariant.

### 第六步：代数对称分析 / Algebraic Symmetry Analysis

**Galois 理论**：多项式方程 f(x)=0 的根集上，Gal(f) 是根的置换群（保持所有代数关系不变的置换构成）。

核心判断：**方程可用根式求解 ⇔ Gal(f) 是可解群**（存在子群链 G=G₀⊃G₁⊃…⊃G_k={e}，每步 G_i/G_{i+1} 为循环群）。

可解群的直觉：每一步商群 G_i/G_{i+1} 对应一次"简单的"根式提取（开方），整个链对应逐步求解的过程。不可解群意味着存在"不可绕过的复杂性"。

- 5 次及以上一般方程：Gal(f)=S_5，S_5 不可解（A_5 是最小非可解单群）→ 不可用根式求解
- 4 次方程：Gal(f)⊂S_4，S_4 可解（链 S₄⊃A₄⊃V₄⊃Z₂⊃{e}）→ 可用根式求解
- 圆可分多项式：Gal(f)⊂(Z/pZ)× 为循环群 → 可用根式求解
- x⁵+x+1=0：Gal(f)=S_5 → 不可用根式求解（具体反例）

Galois 理论展示了代数对称分析的范式：**问题结构 → 置换群 → 群的可解性 → 问题的可解性**。群论从"对称性描述工具"升级为"可解性判断标准"。

Galois theory: Gal(f) permutes roots preserving algebraic relations. Solvability by radicals ⇔ Gal(f) is solvable (subnormal chain with cyclic quotients). Intuition: each quotient G_i/G_{i+1} corresponds to one "simple" radical extraction. Unsolvable groups mean "unavoidable complexity." Degree ≥5 general: Gal(f)=S_5, unsolvable (A_5 is smallest non-solvable simple group). Degree 4: S_4 solvable (chain S₄⊃A₄⊃V₄⊃Z₂⊃{e}). Cyclotomic: cyclic group, solvable. x⁵+x+1=0: Gal(f)=S_5, concrete unsolvable example. Paradigm: problem structure → permutation group → solvability of group → solvability of problem. Group theory upgrades from "symmetry description tool" to "solvability criterion."

### 第七步：物理对称分析 / Physical Symmetry Analysis

**Noether 定理**：连续对称性 → 守恒律。具体地，若作用量 S=∫L dt 在变换 g∈G 下不变，则存在守恒流 Jμ 满足 ∂_μ Jμ=0。这是物理学最深刻的定理之一——它建立了对称性与守恒律的精确对应。

经典对应：
- 时间平移（R 作用）→ 能量守恒：H=常数
- 空间平移（R³ 作用）→ 动量守恒：p=常数向量
- 旋转（SO(3) 作用）→ 角动量守恒：L=常数向量
- 规范变换（U(1) 作用）→ 电荷守恒：Q=常数

量子对应：对称群 G → Hilbert 空间上的酉表示 → 不可约表示分类能级 → Wigner-Eckart 定理简化矩阵元计算。对称性决定了选择规则：哪些跃迁被禁止（矩阵元为零），哪些被允许。

物理对称分析的层次：
- **经典力学**：Lagrangian/Hamiltonian 的对称 → Noether 守恒律 → 简化运动方程
- **量子力学**：对称 → 选择规则 → 能级简并 → Wigner-Eckart
- **场论**：规范对称 → 粒子分类 → 相互作用结构 → 标准模型 SU(3)×SU(2)×U(1)

Noether's theorem: continuous symmetry of action S=∫L dt ⇒ conserved current Jμ with ∂_μ Jμ=0—the most profound theorem in physics, establishing the exact correspondence between symmetry and conservation. Time translation → energy H; space translation → momentum p; rotation → angular momentum L; gauge U(1) → charge Q. Quantum extension: symmetry G → unitary representation on Hilbert space → irreducible representations classify energy levels → Wigner-Eckart theorem → selection rules (which transitions are forbidden, which are allowed). Physical hierarchy: classical mechanics (Lagrangian symmetry → Noether → simplify equations), quantum mechanics (symmetry → selection rules → level degeneracy → Wigner-Eckart), field theory (gauge symmetry → particle classification → interaction structure → Standard Model SU(3)×SU(2)×U(1)).

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|-------------|-------------------------------|---------------------------|
| 忽视隐藏对称性 | 表面不对称，但深层结构有对称性，遗漏可导致不必要的复杂化 | 尝试不同表示（坐标变换、基底变换），寻找深层对称 |
| 混淆近似对称与精确对称 | 近似对称下的"守恒"只是近似成立，误差随时间积累 | 区分精确不变量和近似不变量，标注近似程度 |
| 对称性论证过度 | 不是所有问题都有对称性，强行引入对称性会得出错误结论 | 确认对称性确实存在再使用，验证群公理 |
| 忽视对称性破缺 | 对称破缺可能才是关键机制，遗漏破缺则误解系统行为 | 同时关注对称性和对称破缺，分析 G→H 模式 |
| 把对称性当原因 | 对称性是描述性的约束，不一定是因果机制 | 区分描述（"系统满足对称 G"）和解释（"因为…所以满足 G"） |
| 未验证群性质 | 候选变换集未必满足封闭性或逆元，不验证则后续推理全部建立在错误基础上 | 逐一验证四条群公理后再使用，不满足时识别实际结构 |
| 混淆轨道不变量与一般不变量 | f 在 O(x) 上取常值 ≠ f 在 X 上取常值；全局常值函数平凡且无信息 | 明确不变量是 G-不变的（在每条轨道上取常值），而非全局常值 |
| 忽视稳定子子群 | Stab(x) 含丰富信息，忽视则丢失局部对称和精细分类 | 用轨道-稳定子定理分析局部对称，不同稳定子 → 不同轨道类型 |
| 混淆离散与连续对称 | 离散群无 Reynolds 平均（|G| 可能无穷）；连续群需 Lie 代数而非逐元分析 | 离散群用 Burnside 引理计数；连续群用 Lie 代数生成元与 Noether 定理 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：

1. **变换清单**：列出所有可识别的变换 `[变换N]: [描述] [类型: 空间/时间/代数/逻辑/规范]`，组织为候选群，标注验证了哪些群公理（封闭性✓/✗, 结合律✓/✗, 单位元✓/✗, 逆元✓/✗）
2. **不变量发现**：对每种群作用，标注 `[在群G下]: [不变量Y] 保持不变`；若为有限群，写出 Reynolds 算子形式 R(f)=1/|G| Σ f(g·x)；用 Burnside 引理计数轨道 |X/G|=1/|G| Σ |Fix(g)|
3. **简化策略**：说明如何利用不变量简化问题 `[利用不变量Y]: [如何简化]`；标注是否在商空间 X/G 或基本域 D 上工作，估计维度缩减量
4. **对称分类**：给出轨道-稳定子分析 `[对象x]: |O(x)|=[值], |Stab(x)|=[值]`，基于轨道的分类结果，评估不变量是否完备
5. **对称破缺检查**：`[对称性Z]: [存在/破缺]，破缺方式: [自发/显式]`；若为连续破缺 G→H，标注 Goldstone 模数 dim(G/H)；标注破缺后的有效对称群 H
6. **代数/物理对称**：若涉及方程求解，标注 Galois 群 Gal(f) 及其可解性（可解/不可解）和求解链结构；若涉及物理系统，标注 Noether 对应：`[对称群G]: [守恒律]`
7. **结论**：明确写出利用对称性/不变性得出的结论，包括：发现了哪些不变量，实现了多少维度缩减，分类结果是什么

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **变换思想**：对称性就是变换下的不变性——两个思想是一体两面
- **抽象化思想**：不变量是最高层次的抽象——它独立于具体的表示
- **建模思想**：物理模型的构建常常以对称性原理为指导
- **公理化思想**：群论的公理体系是对称性的数学基础
- **拓扑思想**：拓扑不变量（欧拉示性数、同伦群）是连续变换下的不变量
- **算法思想**：群算法利用对称性加速计算（如 FFT 利用循环群结构）
- **离散/组合思想**：Pólya 计数定理是 Burnside 引理的加权推广，用于枚举对称构型