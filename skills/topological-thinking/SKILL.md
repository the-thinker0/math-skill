---
name: topological-thinking
description: |
  科研模式触发：拓扑数据分析（TDA）、持续同调、同调计算、基本群与同调群分析、单纯复形与滤流构造。
  生活模式触发：理解连通性、鲁棒性分析、识别"什么在变化中持续存在"、判断表面不同的事物是否本质同类。
  English Research trigger: topological data analysis (TDA), persistent homology, homology computation, fundamental group & homology group analysis, simplicial complex & filtration construction.
  English Life trigger: understanding connectivity, robustness analysis, recognizing what persists through change, judging whether superficially different things are essentially the same kind.
---

# 🌀 拓扑思想

> "可以拉伸弯曲但不能撕裂——真正重要的性质在连续变形中不变。"
> "You can stretch and bend but never tear — truly important properties survive continuous deformation."
>
> —— 拓扑学、同调理论、拓扑数据分析
> —— Topology, Homology Theory, Topological Data Analysis

## 核心原则 / Core Principle

拓扑学研究连续变形下保持不变的性质。甜甜圈与咖啡杯拓扑等价——它们都有一个洞。核心洞察：当精确距离不重要时，拓扑捕获本质结构——连通性、洞、维数。应用：数据分析（TDA）、网络连通性、鲁棒性分析。

Topology studies properties preserved under continuous deformation. A donut and coffee cup are topologically equivalent — both have one hole. Key insight: when exact distances don't matter, topology captures essential structure — connectedness, holes, dimension. Applications: data analysis (TDA), network connectivity, robustness analysis.

> **数学形式化**（科研模式参考 / Research Mode Reference）
>
> **同胚（homeomorphism）**：连续双射且逆也连续的映射 h: X → Y，是拓扑等价的标准。同伦（homotopy）：连续变形过程本身连续，比同胚更粗的等价。微分同胚（diffeomorphism）：光滑的双射且逆光滑，微分拓扑的等价标准。
>
> Homeomorphism: continuous bijection with continuous inverse h: X → Y, the standard of topological equivalence. Homotopy: the deformation process itself is continuous, a coarser equivalence. Diffeomorphism: smooth bijection with smooth inverse, the standard of differential topology.
>
> **欧拉示性数** χ = V - E + F：凸多面体 χ = 2，环面 χ = 0，配合可定向性是曲面的完全拓扑不变量。
>
> Euler characteristic χ = V - E + F: convex polyhedra χ = 2, torus χ = 0; a complete topological invariant for surfaces (paired with orientability).
>
> **基本群** π₁(X)：基于基点的环路模去同伦变形；π₁(S¹) = Z（绕圈次数），π₁(S²) = 0（球面上所有环路可收缩），π₁(环面) = Z × Z（两个方向的绕圈）。
>
> Fundamental group π₁(X): loops based at a point modulo homotopic deformation; π₁(S¹) = Z (winding number), π₁(S²) = 0 (all loops contractible), π₁(torus) = Z × Z (winding in two directions).
>
> **同调群** H_n(X)：n 维"洞"的计数：H₀ = 连通分量，H₁ = 1 维洞（环路），H₂ = 2 维空洞（围成的空腔）。
>
> Homology groups H_n(X): counting n-dimensional "holes": H₀ = connected components, H₁ = 1-holes (loops), H₂ = 2-dimensional voids.
>
> **Betti 数** β_n = rank H_n(X)：n 维洞的数量：β₀ = 连通分量数，β₁ = 1 维洞数，β₂ = 2 维空洞数。
>
> Betti numbers β_n = rank H_n(X): number of n-dimensional holes: β₀ = components, β₁ = 1-holes, β₂ = 2-voids.
>
> **单纯复形（simplicial complex）**：由点、线段、三角形等单纯形组合而成的拓扑空间模型。
>
> Simplicial complex: a topological space model composed of simplices (points, edges, triangles, etc.).
>
> **滤流（filtration）**：从小到大改变邻域半径，在每个半径下构建单纯复形。
>
> Filtration: vary neighborhood radius from small to large, constructing simplicial complex at each scale.
>
> **持续同调（persistent homology）**：沿滤流计算同调群，长条对应真实拓扑特征，短条对应噪声。
>
> Persistent homology: compute homology groups along filtration; long bars = true topological features, short bars = noise.

> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **需要精确测量** `[科研/通用]`——拓扑只关心定性结构（连通、有洞），不提供距离、角度等精确度量 / When precise measurements matter—topology only addresses qualitative structure (connected, holes), not distances or angles
- **度量性质是核心** `[科研]`——拓扑等价的空间可以有完全不同的度量行为；度量空间的分析工具与拓扑不同 / When metric properties are essential—topologically equivalent spaces can have wildly different metric behavior; analysis requires more than topology
- **纯离散结构无连续性** `[科研]`——拓扑以连续性为基础，对无连续结构的纯离散问题不适用 / Purely discrete with no continuity—topology rests on continuity; inapplicable to purely discrete problems
- **需要精确数值决策** `[生活]`——当决策取决于"多少""多大"而非"是否连通""有没有洞"时，拓扑视角过于粗化 / When decisions depend on "how much" or "how big" rather than "is it connected" or "does it have holes"—topological perspective over-simplifies

## 何时使用 / When to Use

### 科研触发条件 / Research Triggers

- **需要定性分类**——不在乎"多大""多远"，只在乎"是否连通""有多少洞" / Need qualitative classification—only care about connectedness and number of holes
- **形状比大小更重要**——研究对象的整体形态而非精确尺寸 / Shape matters more than size
- **需要鲁棒性分析**——拓扑不变量保证性质在连续扰动下不消失 / Need robustness analysis—invariants guarantee properties persist under continuous perturbation
- **数据具有标准统计无法捕获的形状**——聚类、空洞、环状结构 / Data has shape that standard statistics misses
- **需要变形下存活的不变量**——拓扑绝缘体、拓扑纠错 / Need invariant that survives deformation—topological insulators, topological error correction

### 生活触发条件 / Life Triggers

- **需要理解连通性**——谁和谁连通、信息能否流通、关系网络是否完整 / Need to understand connectivity—who connects to whom, can information flow, is the network complete
- **需要识别"变化中的不变"**——不管表面怎么变，什么核心特征始终存在 / Need to identify "what stays the same through change"—what core features persist regardless of surface variation
- **需要判断本质同类**——看起来不同的东西，核心结构是否相同 / Need to judge essential sameness—do superficially different things share the same core structure
- **需要鲁棒性判断**——系统在扰动下是否稳定、哪些性质不会被消除 / Need robustness judgment—is the system stable under perturbation, which properties won't disappear
- **需要发现盲区**——哪里有信息无法到达的区域、哪里有断裂 / Need to discover blind spots—where information cannot reach, where there are gaps

## 方法流程 / Method

### 第一步：识别连续性要求 / Identify Continuity Requirements

**科研模式 / Research Mode**

明确具体的等价标准：同胚（homeomorphism）、同伦（homotopy）、微分同胚（diffeomorphism）。确定什么可以改变（距离、角度、大小）什么必须固定（洞的数目、连通性、维数）。

Specify the exact equivalence standard: homeomorphism, homotopy, or diffeomorphism. Identify what can change (distances, angles, sizes) and what must stay fixed (number of holes, connectedness, dimension).

**生活模式 / Life Mode**

什么可以改变，什么必须固定？——精确的数值不重要时，关注整体结构和连通性。问：哪些变化只是表面的（大小、外观、配置），哪些变化会破坏核心功能（连通断裂、关键环节消失）？

What can change, what must stay fixed? — When exact values don't matter, focus on overall structure and connectivity. Ask: which changes are merely surface-level (size, appearance, configuration), and which would break core function (connectivity severed, key links lost)?

**共通要点 / Shared Key Point**

核心区分：可变（表面/度量）vs 不变（结构/拓扑）。/ Core distinction: variable (surface/metric) vs invariant (structure/topology).

### 第二步：寻找拓扑不变量 / Find Topological Invariants

**科研模式 / Research Mode**

核心不变量清单：
- **欧拉示性数** χ = V - E + F——凸多面体 χ = 2，环面 χ = 0，配合可定向性是曲面完全拓扑不变量
- **连通性**（path-connectedness）——从任意点能否沿连续路径到达任意其他点；连通分量数 = rank H₀
- **紧致性**（compactness）——每个开覆盖有有限子覆盖；Rⁿ 中紧致 ⇔ 有界 + 闭
- **基本群** π₁(X)——环路模去同伦变形；π₁(S¹) = Z, π₁(S²) = 0, π₁(环面) = Z × Z
- **同调群** H_n(X)——H₀ = 连通分量, H₁ = 1 维洞, H₂ = 2 维空洞
- **Betti 数** β_n = rank H_n——β₀ = 连通分量数, β₁ = 1 维洞数, β₂ = 2 维空洞数

Core invariant list:
- **Euler characteristic** χ = V - E + F — complete surface invariant with orientability
- **Connectedness** — number of components = rank H₀
- **Compactness** — Heine-Borel: compact in Rⁿ ⇔ bounded + closed
- **Fundamental group** π₁(X) — loops modulo homotopy; π₁(S¹) = Z, π₁(S²) = 0, π₁(torus) = Z × Z
- **Homology groups** H_n(X) — H₀ = components, H₁ = 1-holes, H₂ = 2-voids
- **Betti numbers** β_n = rank H_n — β₀ = components, β₁ = 1-holes, β₂ = 2-voids

**生活模式 / Life Mode**

不管怎么变化，什么特征始终存在？——找到"不管表面怎么变，内核不变"的东西。比如：不管组织怎么改组，沟通渠道的连通性不变；不管市场怎么波动，供需的循环结构不变。

What features always exist regardless of change? — Find what stays the same at the core even as the surface changes. E.g.: no matter how an organization restructures, communication channel connectivity persists; no matter how markets fluctuate, the supply-demand loop structure persists.

**共通要点 / Shared Key Point**

不变量 = 变化中的恒定。/ Invariants = constancy through change.

### 第三步：用不变量分类 / Classify Using Invariants

**科研模式 / Research Mode**

同欧拉示性数 → 同类型曲面；同基本群 → 同同伦类型空间；分类定理：紧致曲面由可定向性 + 欧拉示性数完全分类。

Same Euler characteristic → same surface type; same fundamental group → same homotopy type; classification theorem: compact surfaces classified by orientability + Euler characteristic.

**生活模式 / Life Mode**

表面不同的东西核心结构是否相同？——甜甜圈和咖啡杯看起来不同，但核心结构一样（都有一个洞）。生活中看似不同的问题可能本质同类：两个部门的冲突模式可能是同一种循环依赖结构。

Do superficially different things share the same core structure? — A donut and coffee cup look different but share the same core structure (one hole). Seemingly different life problems may be essentially the same kind: conflict patterns in two departments may share the same circular dependency structure.

**共通要点 / Shared Key Point**

分类靠不变量，不看表面看结构。/ Classification by invariants: look at structure, not surface.

### 第四步：构造拓扑模型 / Construct Topological Model

**科研模式 / Research Mode**

**数据**：对点云数据构建滤流（filtration）——从小到大改变邻域半径，计算每个半径下的单纯复形及其同调；提取持续同调（persistent homology），输出条形码图（barcode diagram）或持续图（persistence diagram），长条 = 真实拓扑特征，短条 = 噪声。

**网络**：分析连通分量（可达性）、环路（冗余路径）、聚类系数；网络拓扑决定信息传播与鲁棒性。

**系统**：相空间中吸引子的拓扑——稳定不动点（拓扑上为点）、极限环（拓扑上为 S¹）、混沌吸引子（Strange attractor，分形结构）。

For data: persistent homology via filtrations—barcode/persistence diagram where long bars = true features, short bars = noise. For networks: connected components, cycles, clustering coefficient. For systems: attractor topology — fixed point, limit cycle (S¹), chaotic attractor (fractal).

**生活模式 / Life Mode**

画出事物之间的连接关系——谁和谁连通，有没有断裂，有没有循环依赖，有没有空洞（信息无法到达的区域）。

Map the connections between things—who connects to whom, are there gaps, circular dependencies, voids (areas where information cannot reach).

**共通要点 / Shared Key Point**

建模 = 把复杂现实映射到结构图。/ Modeling = mapping complex reality to a structural diagram.

### 第五步：验证拓扑等价 / Verify Topological Equivalence

**科研模式 / Research Mode**

尝试构造显式同胚或同伦等价；检查不变量是否匹配；若不变量不同 → 空间拓扑不同（可靠否定判断）；若全部匹配 → 可能拓扑等价（但不能确定——不变量可能不完备）。

Attempt explicit homeomorphism or homotopy equivalence; check invariant matching; different invariants → topologically different (reliable negative); all match → possibly equivalent (invariants may be incomplete).

**生活模式 / Life Mode**

验证你识别的核心结构是否真的可靠——变换是否真的不影响关键特征？问：如果表面变化了，我识别的"不变特征"还在吗？如果去掉一层包装，核心结构是否仍然成立？

Verify whether the core structure you identified is truly reliable — does transformation really not affect key features? Ask: if the surface changes, does the "invariant feature" remain? If you strip away packaging, does the core structure still hold?

**共通要点 / Shared Key Point**

验证 = 确认不变量确实不变。/ Verification = confirming invariants are indeed invariant.

### 第六步：拓扑推理与应用 / Topological Reasoning and Applications

**科研模式 / Research Mode**

利用拓扑结论推理：
- "因为 π₁(X) ≠ 0，存在不可收缩环路 → 系统有不可达状态"
- "因为 X 连通，存在路径 → 转移总是可能的"
- "因为 β₁ = 3，数据中有 3 个显著的环状结构"
- "因为 χ = 0，这是环面类型的曲面"

Use topological conclusions for reasoning:
- "Since π₁(X) ≠ 0, non-contractible loops exist → system has inaccessible states"
- "Since X is connected, paths exist → transition is always possible"
- "Since β₁ = 3, data has 3 significant circular structures"
- "Since χ = 0, this is a torus-type surface"

**生活模式 / Life Mode**

用结构洞察指导行动——连通性告诉你信息能否流通，空洞告诉你哪里有盲区，循环依赖告诉你哪里可能卡住。

Use structural insight to guide action—connectivity tells you whether information can flow, voids tell you where there are blind spots, circular dependencies tell you where things may get stuck.

**共通要点 / Shared Key Point**

从结构到结论：不变量 → 性质 → 推理。/ From structure to conclusion: invariants → properties → reasoning.

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach | 标签 / Tag |
|-------------|-------------------------------|---------------------------|-----------|
| 混淆拓扑等价与几何相似 / Confusing topological equivalence with geometric similarity | 拓扑等价只要求同胚，不要求度量相近；圆和椭圆拓扑等价但几何不同 | 区分"拓扑相同"和"几何相似"；先问"连续变形能否到达？"再问"度量是否接近？" | `[科研/通用]` |
| 忽略维数差异 / Ignoring dimension differences | R¹ 与 R² 不同胚（维数是拓扑不变量——Brouwer 区域不变性定理） | 维数 invariance 是强制检查项；不同维数的空间拓扑必然不同 | `[科研]` |
| 混淆连通与道路连通 / Confusing connected with path-connected | 连通 ≠ 道路连通（如拓扑学家的正弦曲线）；道路连通 ⇒ 连通，反之不成立 | 明确标注用的是哪种连通性；多数实际场景中道路连通更自然 | `[科研]` |
| 过度依赖单一不变量 / Over-relying on a single invariant | 仅用欧拉示性数无法区分所有空间（χ=0 的空间多种多样）；单一不变量不完备 | 使用不变量组合（χ + 可定向性 + π₁ + H_n）；不完备时标注不确定性 | `[科研/通用]` |
| 忽略局部与全局拓扑差异 / Ignoring local vs. global topological differences | 局部连通不保证全局连通；局部紧致 ≠ 紧致；局部同胚 ≠ 全局同胚 | 区分局部与全局性质；分别检查局部不变量与全局不变量 | `[科研]` |
| 混淆同调与同伦 / Confusing homology with homotopy | H₁(X) 是 π₁(X) 的 Abel 化（H₁ = π₁/commutators）；同调是同伦的"粗化"版本 | 明确标注用的是 π₁（同伦）还是 H₁（同调）；需要精细分类时用 π₁ | `[科研]` |
| 关注精确数值而忽略整体结构 / Focusing on exact values while ignoring overall structure | 拓扑的价值在于不看数值看结构；纠结精确数字会错失本质 | 先看连通性和循环结构，再看数值细节 / Look at connectivity and loop structure first, then numerical details | `[生活]` |
| 忽视断裂和空洞 / Ignoring gaps and voids | 断裂 = 连通性丧失，空洞 = 信息无法到达的区域；这些是最重要的拓扑特征 | 主动检查：有没有断裂？有没有信息盲区？ / Proactively check: are there gaps? information blind spots? | `[生活]` |
| 把表面差异当本质差异 / Treating surface differences as essential differences | 甜甜圈和咖啡杯表面不同但本质相同；表面差异 ≠ 结构差异 | 问"去掉表面包装，核心结构是否同类？" / Ask: "stripping surface packaging, is the core structure the same kind?" | `[生活]` |

## 操作规程 / Operating Procedure

当本 skill 被触发时，首先选择模式：

**模式选择 / Mode Selection**
- **科研模式**：当涉及拓扑数据分析、持续同调、同调计算、单纯复形与滤流等数学/计算任务时
- **生活模式**：当涉及连通性理解、鲁棒性判断、识别变化中的不变、本质分类等日常推理任务时

**Research Mode**: for mathematical/computational tasks involving TDA, persistent homology, homology computation, simplicial complexes & filtrations
**Life Mode**: for everyday reasoning involving connectivity understanding, robustness judgment, identifying what persists through change, essential classification

---

### 科研模式输出格式 / Research Mode Output Format

1. **连续性要求**：`[连续性要求]: [同胚/同伦/微分同胚]，可变: [距离/角度/大小]，不变: [洞数/连通性/维数]`
2. **不变量**：`[不变量]: χ=[值] π₁=[群] β_n=[数], H₀=[连通分量数] H₁=[1维洞数] H₂=[2维空洞数]，紧致性=[是/否]`
3. **分类**：`[分类]: [可定向/不可定向], χ=[值] → [曲面类型]；π₁=[群] → [同伦类型]`
4. **拓扑模型**：`[拓扑模型]: [单纯复形/滤流/网络图/相空间]，构造方法: [具体描述]`
5. **等价验证**：`[等价验证]: [不变量是否全部匹配/是否有不变量不同]，结论: [拓扑等价/拓扑不同/不确定]`
6. **推理**：`[推理]: 因为[拓扑性质] → [结论]`

### 生活模式输出格式 / Life Mode Output Format

1. **[什么可变/什么不变]:[区分]** — 精确数值不重要，什么核心特征必须保持 / What can change vs. what must stay fixed — exact values don't matter, what core features must persist
2. **[不变特征]:[发现]** — 不管怎么变化，什么始终存在 / Invariant features discovered — what always exists regardless of change
3. **[本质分类]:[判断]** — 看似不同的东西核心是否同类 / Essential classification — are superficially different things the same kind at core
4. **[连接结构]:[分析]** — 事物之间的连通、断裂、循环、空洞 / Connection structure analysis — connectivity, gaps, loops, voids between things
5. **[结构可靠性]:[验证]** — 识别的结构是否真的可靠 / Structural reliability verification — is the identified structure truly reliable
6. **[行动建议]:[步骤]** — 基于结构洞察的结论 / Action recommendation — conclusions based on structural insight

**输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**
**Output must include all 6 items above. Do not output only analytical text without conclusions.**

## 与其他 skill 的关系 / Relations to Other Skills

- **对称与不变性**：拓扑不变量是连续变换下的不变量——拓扑思想与对称思想共享"寻找不变量"的核心逻辑，但拓扑关注连续变形而非群作用
- **抽象化思想**：拓扑是空间结构的抽象——去掉度量只保留开集与连续性，是从几何到拓扑的抽象跃升
- **变换思想**：连续变形是特殊的变换——同胚、同伦都是变换，拓扑研究这些变换下的不变量
- **建模思想**：拓扑数据分析是数据建模——用持续同调为点云数据建立拓扑模型，发现统计方法遗漏的形状特征
- **概率与统计**：TDA 补充统计的形状分析——统计关注均值与方差（量的分析），TDA 关注连通与空洞（质的分析），两者互补