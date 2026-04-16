# 数学出处与经典文献 / Mathematical Sources and Classic Texts

## Wright 路径分析与 DAG / Wright's Path Analysis and DAGs (1921)

> 路径系数 p_{ij}：变量 i 对变量 j 的直接因果效应的标准化度量。
> 每条从 i 到 j 的路径的总效应 = 路径上各系数的乘积。

**含义**：因果结构可以用有向图表示，因果效应可以在图上沿路径计算——这是因果 DAG 的起源。

**数学背景**：Sewall Wright (1921) 在研究遗传学时发明路径图（path diagrams），用于分解性状的遗传与环境成分。路径分析的本质是结构方程模型（SEM）的图表示：每个变量的值由其直接原因和外生误差项决定，Y = Σ β_{ij}·X_j + ε_j。Wright 的路径追踪规则允许沿 DAG 路径计算变量间的总关联：r_{XY} = Σ(路径上系数乘积)。这一方法为 Pearl 的 DAG 框架奠定了基础。

**Significance**: Causal structure can be represented with directed graphs, and causal effects can be computed along paths on the graph — this is the origin of causal DAGs. Wright invented path diagrams in genetics to decompose hereditary and environmental components of traits. Path analysis is essentially the graphical representation of structural equation models (SEM).

**关键公式**：路径追踪规则（Wright's tracing rule）：变量 i 与 j 间的总关联 r_{ij} = Σ(沿 i→j 的每条开放路径上路径系数乘积)。开放路径是指不经过同一变量两次（无回路）且不含"对撞"（collider）的路径——对撞是两条箭头同时指向的节点。对撞节点默认阻断路径，但若对撞被条件化，则路径重新开放——这就是"对撞偏差"（collider bias）的来源。

**Key formula**: Wright's tracing rule: total association r_{ij} = Σ(product of path coefficients along each open path from i to j). An open path has no loops and no colliders (nodes receiving two arrows). Colliders block paths by default, but conditioning on a collider opens the path — the origin of "collider bias."

## Fisher 随机化实验 / Fisher's Randomized Experiments (1935)

> 随机化不是忽视因果，而是使因果推断成为可能。
> 随机分配切断所有指向处理变量的因果箭头。

**含义**：科学实验的可信度不来自"精密控制"，而来自"随机分配"——随机化是因果推断的黄金标准。

**数学背景**：R.A. Fisher 在《The Design of Experiments》(1935) 中提出随机化原则。核心论证：若处理 T 随机分配给个体，则 T 与任何混淆变量 Z 独立（P(Z|do(T)) = P(Z)），因此 P(Y|do(T)) = P(Y|T)。随机化消除了所有后门路径，无需识别具体混淆变量。Fisher 还提出零假设下的精确检验（permutation test）：在 T 无效应假设下，所有可能分配的 Y 值分布相同，p-value = "观察到当前或更极端分配的概率"。

**Significance**: The credibility of scientific experiments comes not from "precise control" but from "random assignment" — randomization is the gold standard for causal inference. Fisher showed that if treatment T is randomly assigned, T is independent of any confounder Z, so P(Y|do(T)) = P(Y|T). Randomization eliminates all back-door paths without needing to identify specific confounders.

**Fisher 精确检验与置换推断**：Fisher 的 lady tasting tea 实验是随机化推断的经典案例。一位女士声称能分辨茶是先加奶还是后加奶。Fisher 设计了 8 杯茶（4 杯先加奶、4 杯后加奶），随机顺序呈现。在"女士无辨别能力"（零假设）下，正确猜中 4 杯先加奶的概率 = 1/C(8,4) = 1/70 ≈ 0.014。这一 p-value 不依赖任何分布假设——它完全基于随机化分配，是置换检验（permutation test）的起源。

## Wright 工具变量 / Wright's Instrumental Variables (1928)

> 工具变量 V 满足：(1) V → X（影响处理），(2) V 与 Y 无直接路径，(3) V 与 Y 无共同原因。
> IV 估计量：β_{IV} = Cov(Y,V)/Cov(X,V)。

**含义**：当混淆变量不可观测时，工具变量可以利用"外生变异"来估计因果效应——IV 创造的 X 的变异不受混淆影响。

**数学背景**：Philip Sewall Wright (1928) 在估计亚麻籽需求弹性时首次提出工具变量方法。他需要估计价格对需求量的因果效应，但价格与需求量之间存在双向因果关系（混淆）。Wright 引入一个只影响供给（从而影响价格）但不直接影响需求量的变量作为工具。IV 估计的逻辑：Cov(Y,V) = β_{因果}·Cov(X,V) + Cov(混淆,U·V)，但 V 与混淆独立所以 Cov(混淆,U·V)=0，于是 β_{因果} = Cov(Y,V)/Cov(X,V)。当 IV 弱（Cov(X,V) 小），IV 估计的方差膨胀，需警惕弱工具变量问题。

**Significance**: When confounders are unobserved, instrumental variables exploit "exogenous variation" to estimate causal effects — the variation in X created by IV is unaffected by confounding. Wright first proposed IV estimation for flaxseed demand elasticity. The logic: since V is independent of confounders, β_{causal} = Cov(Y,V)/Cov(X,V). Weak IV (small Cov(X,V)) inflates variance — beware of weak instrument problems.

**经典 IV 案例**：

- **Angrist & Krueger (1991)**：用出生季度作为教育年数的工具变量——出生在年初的人因入学年龄规定而被迫多上一年学。IV 估计的教育回报率约 7%，高于 OLS 的 5%（OLS 受能力混淆向下偏）。
- **两阶段最小二乘 (2SLS)**：第一阶段 X̂ = π₀ + π₁·V（用 IV 预测 X）；第二阶段 Y = β₀ + β₁·X̂（用预测值估计因果效应）。当 IV 强时（F-statistic > 10），2SLS 可靠；当 IV 弱时，2SLS 偏向 OLS 且置信区间膨胀。

**Classic IV cases**: Angrist & Krueger (1991) used birth quarter as IV for education years — those born early in the year were forced to attend more school. IV-estimated education return ~7% vs OLS ~5% (OLS biased down by ability confounding). 2SLS: first stage X̂ = π₀ + π₁·V, second stage Y = β₀ + β₁·X̂. Reliable when F > 10 (strong IV); biased toward OLS when IV is weak.

## Lewis 反事实语义 / Lewis's Counterfactual Semantics (1973)

> "如果 A 发生了（实际上没有），C 会怎样？" ——在 A 成立的可能世界中，C 是否成立？
> Counterfactual: "If A had occurred (which it didn't), would C have happened?" — In the possible world where A holds, does C hold?

**含义**：因果陈述本质上涉及反事实——"A 导致 C"意味着"如果 A 没发生，C 就不会发生"。反事实推理需要比较不同的可能世界。

**数学背景**：David Lewis (1973) 在《Counterfactuals》中提出可能世界语义来分析反事实条件句。核心概念：相似性 ordering — 在 A 成立的可能世界中，最接近现实世界的那个决定了反事实的真值。Lewis 的 VC (Variably Strict Conditional) 系统：A □→ C 为真，若在所有最接近的 A-世界中 C 成立。这一哲学框架为 Pearl 的结构因果模型中的反事实计算提供了语义基础——SCM 的反事实 Y_x(u) 就是在"设定 X=x"的可能世界中个体 u 的 Y 值。

**Significance**: Causal claims inherently involve counterfactuals — "A caused C" means "if A hadn't occurred, C wouldn't have." Counterfactual reasoning requires comparing different possible worlds. Lewis proposed possible-world semantics: the closest A-world to reality determines the truth of the counterfactual. This philosophical framework provided the semantic basis for Pearl's SCM counterfactuals — Y_x(u) is the value of Y for individual u in the world where X is set to x.

## Rubin 潜在结果框架 / Rubin's Potential Outcomes Framework (1974)

> 对于个体 i：Y_i(1) 为处理下的潜在结果，Y_i(0) 为对照下的潜在结果。
> 个体因果效应：τ_i = Y_i(1) - Y_i(0)（永远不可同时观测）。
> 平均处理效应：ATE = E[Y(1) - Y(0)]。

**含义**：因果效应是两个潜在结果之差——但每个个体只能观测到一个潜在结果，这是因果推断的根本难题（"因果推断的根本问题" / fundamental problem of causal inference）。

**数学背景**：Donald Rubin (1974) 将 Neyman (1923) 在农业实验中的随机化推断框架推广为一般性的潜在结果模型（Neyman-Rubin causal model）。关键假设 SUTVA（Stable Unit Treatment Value Assumption）：(1) 个体 i 的潜在结果不受他人处理分配影响，(2) 处理形式唯一（无不同版本）。在随机化下，ATE 的无偏估计为 τ̂ = Ȳ_1 - Ȳ_0。Rubin 的框架与 Pearl 的 DAG 框架是等价的：潜在结果模型是 SCM 中结构方程的隐式表示，DAG 是潜在结果模型中因果假设的显式表示。

**Significance**: The causal effect is the difference between two potential outcomes — but only one can be observed per individual, the "fundamental problem of causal inference." Rubin extended Neyman's framework into the general potential outcomes model (Neyman-Rubin causal model). SUTVA ensures no interference between units. Under randomization, ATE is unbiasedly estimated by τ̂ = Ȳ_1 - Ȳ_0. Rubin's framework is equivalent to Pearl's: potential outcomes are implicit structural equations, DAGs are explicit causal assumptions.

## Pearl 因果层级与 do-演算 / Pearl's Causal Hierarchy and Do-Calculus (2000)

> 因果层级：
> Level 1：P(y|x) — 关联 / Seeing
> Level 2：P(y|do(x)) — 干预 / Doing
> Level 3：P(y_x|x',y') — 反事实 / Imagining
>
> do-演算三条规则允许将干预表达式转化为可观测量。

**含义**：因果不是关联的强化版——"do(x)" 与 "observe x" 在数学上截然不同。do-演算提供了从观测数据计算因果效应的完整逻辑系统。

**数学背景**：Judea Pearl 在《Causality》(2000) 中建立了因果推断的数学框架。核心贡献：(1) 因果层级将推理能力从关联到干预到反事实分为三层，每层需要更强的建模假设；(2) do-演算三条规则给出了将 do-表达式转化为无 do 的可观测量表达式的完整规则集；(3) Pearl 证明了 do-演算的完备性——若一个 do-表达式可以转化为可观测量表达式，do-演算的三条规则必能找到这一转化。后门准则和前门准则是 do-演算的最重要特例。

**Significance**: Causation is not a strengthened version of correlation — "do(x)" and "observe x" are mathematically distinct. Do-calculus provides a complete logical system for computing causal effects from observational data. Pearl proved completeness: if a do-expression can be converted to an observational expression, the three rules of do-calculus will find it. The back-door and front-door criteria are the most important special cases.

## Card & Krueger 双重差分 / Card & Krueger Difference-in-Differences (1994)

> DD = (Y₁^{post} - Y₁^{pre}) - (Y₀^{post} - Y₀^{pre})
> 处理组的前后变化减去对照组的前后变化 = 纯因果效应。

**含义**：当 RCT 不可能时，可以利用干预前后处理组与对照组的差异变化来估计因果效应——前提是平行趋势假设成立。

**数学背景**：David Card 与 Alan Krueger (1994) 在研究最低工资对就业的影响时，比较了新泽西（提高最低工资）与宾夕法尼亚（未提高）的快餐业就业变化。DD 的关键假设：若无干预，处理组与对照组的趋势相同（平行趋势假设）。数学上，DD 估计量 τ̂_{DD} = (Ȳ_{NJ,post} - Ȳ_{NJ,pre}) - (Ȳ_{PA,post} - Ȳ_{PA,pre})。当平行趋势成立时，τ̂_{DD} = ATE。平行趋势可部分检验：比较干预前两个组的时间趋势是否一致。

**Significance**: When RCT is impossible, difference-in-differences estimates causal effects by comparing pre-post changes between treatment and control groups — provided the parallel trends assumption holds. Card & Krueger studied minimum wage effects on employment by comparing New Jersey (raised minimum wage) with Pennsylvania (did not). The parallel trends assumption can be partially tested by comparing pre-intervention trends.

## 中介分析：直接与间接效应 / Mediation Analysis: Direct and Indirect Effects

> X → M → Y：间接效应 = X 通过 M 对 Y 的影响
> X → Y：直接效应 = X 不通过 M 对 Y 的直接影响
> 总效应 = 直接效应 + 间接效应

**含义**：因果效应可以沿不同路径传播——拆分直接与间接效应有助于理解因果机制。

**数学背景**：Baron & Kenny (1986) 提出中介分析的经典方法（逐步回归法），但该方法有严重缺陷：依赖线性假设、忽略交互效应、无法处理混淆。Pearl (2001) 提出因果中介分析的定义：自然直接效应 NDE = E[Y_{x,M_{x'}}] - E[Y_{x',M_{x'}}]（将 M 设为 x' 下自然值时，X 从 x' 变为 x 的效应）；自然间接效应 NIE = E[Y_{x',M_x}] - E[Y_{x',M_{x'}}]（X 保持 x' 时，M 从 x' 下自然值变为 x 下自然值的效应）。总效应 = NDE + NIE。这一定义不依赖线性假设。

**Significance**: Causal effects propagate along different paths — decomposing direct and indirect effects helps understand causal mechanisms. Baron & Kenny's (1986) classic method has serious flaws. Pearl (2001) defined causal mediation: natural direct effect NDE and natural indirect effect NIE, without requiring linearity. Total effect = NDE + NIE.

## Rosenbaum 敏感性分析 / Rosenbaum's Sensitivity Analysis (2002)

> 给定混淆强度 Γ：最大 odds ratio P(U=1|T=1)/P(U=1|T=0) ≤ Γ。
> 计算：在 Γ 下因果结论可能翻转的最大 p-value。

**含义**：因果结论必须评估其脆弱性——如果未观测混淆只需强度 Γ 就能推翻结论，则结论不稳健。

**数学背景**：Paul Rosenbaum 在《Observational Studies》(2002) 中系统化敏感性分析方法。核心思想：在随机化下 Γ=1（处理与混淆完全独立），Γ>1 表示存在未观测混淆的可能。对每个 Γ，计算：在最强可能混淆下，处理效应的最小 p-value。若 Γ=2 时 p-value 已超过显著性阈值，则结论对较弱混淆就脆弱；若 Γ=5 时 p-value 仍显著，则结论非常稳健。E-value (VanderWeele & Ding, 2017) 是相关概念：使效应估计归零所需的最小混淆强度，E-value = ATE + √(ATE² + ATE)。

**Significance**: Causal conclusions must be assessed for robustness — if an unobserved confounder of strength Γ can overturn the conclusion, it's fragile. Rosenbaum's method: for each Γ, compute the maximum p-value under the strongest possible confounding. If the conclusion remains significant at Γ=5, it's robust. The E-value quantifies the minimum confounding strength needed to nullify the effect estimate.

## Pearl 结构因果模型 / Pearl's Structural Causal Models (SCM)

> SCM = ⟨U, V, F, P(U)⟩
> U = 外生变量（不可观测的个体特征），V = 内生变量（可观测），F = 结构方程 {f_V}, P(U) = 外生分布
>
> 结构方程：V_i = f_i(PA_i, U_i)，PA_i = V_i 的直接原因（父母节点）

**含义**：结构因果模型是因果推断的完整数学框架——它同时编码因果假设（DAG）、干预（do-演算）和反事实（结构方程）。

**数学背景**：Pearl 的 SCM 框架统一了因果推断的三个层级。核心数学对象：(1) DAG 编码因果假设——箭头 PA_i → V_i 表示 PA_i 是 V_i 的直接原因；(2) 结构方程 V_i = f_i(PA_i, U_i) 编码因果机制——f_i 是因果函数而非统计回归；(3) 干预 do(X=x) 的数学操作：将 X 的结构方程替换为 X=x，保持其他方程不变；(4) 反事实 Y_x(u) 的计算：在修改后的模型（X=x）中，给定外生变量 U=u，计算 Y 的值。SCM 的关键性质：从 SCM 可以推导出所有 Level 1-3 的量；反之，仅从 Level 1 数据无法唯一确定 SCM。

**Significance**: Structural Causal Models provide the complete mathematical framework for causal inference — they simultaneously encode causal assumptions (DAG), interventions (do-calculus), and counterfactuals (structural equations). The key property: from an SCM, all Level 1-3 quantities can be derived; conversely, Level 1 data alone cannot uniquely determine the SCM.

## 因果推断的根本问题 / The Fundamental Problem of Causal Inference

> 对于个体 i：τ_i = Y_i(1) - Y_i(0)
> 我们永远无法同时观测 Y_i(1) 和 Y_i(0)——只能看到其中一个。

**含义**：个体因果效应永远不可直接观测——这是因果推断的根本难题。一切因果推断方法本质上都是在试图用部分信息推断完整效应。

**数学背景**：Holland (1986) 明确阐述了这一根本问题。每个个体 i 有两个潜在结果 Y_i(treated) 和 Y_i(control)，但现实世界只呈现其中一个。一切因果推断策略本质上都是绕过这一限制：(1) 随机化——用群体均值替代个体效应；(2) 前后比较——用个体之前状态近似对照状态（假设无时间趋势）；(3) 回归调整——用可观测特征匹配近似个体；(4) 反事实建模——用结构方程预测未观测的潜在结果。每种策略都有其假设，违反假设则结论无效。

**Significance**: Individual causal effects can never be directly observed — this is the fundamental problem of causal inference. All causal inference strategies circumvent this limitation: (1) randomization — replace individual effects with group means; (2) before-after comparison — approximate control state; (3) regression adjustment — match on observables; (4) counterfactual modeling — predict unobserved potential outcomes. Each strategy has assumptions; violating them invalidates conclusions.

## Simpson 悖论与因果结构 / Simpson's Paradox and Causal Structure

> 同一数据在不同分组下给出相反结论：
> 整体：处理组恢复率更高；分组（按病情严重度）：处理组恢复率更低。

**含义**：统计关联的方向取决于分析维度——Simpson 悖论揭示纯统计推理无法确定"哪个分组是正确的"，必须依赖因果假设。

**数学背景**：Simpson 悖论的本质是混淆变量的干扰。经典案例：药物试验中，轻度患者多数被分配到处理组（恢复率高），重度患者多数被分配到对照组（恢复率低）。整体看处理组恢复率更高（因为处理组多为轻度患者），但按病情分组后处理组恢复率更低（药物实际有害）。Pearl 的因果解释：若病情 Z 是混淆变量（Z→T 且 Z→Y），则 P(Y|T=1) > P(Y|T=0) 是虚假关联，正确的因果效应 P(Y|do(T=1)) < P(Y|do(T=0)) 需要后门调整 P(Y|do(T)) = Σ_z P(Y|T,z)·P(z)。因果 DAG 决定了"应该按 Z 分组还是按整体计算"——没有因果模型，统计方法本身无法给出答案。

**Significance**: The direction of statistical association depends on the level of analysis — Simpson's paradox reveals that pure statistical reasoning cannot determine "which grouping is correct"; causal assumptions are required. Pearl's explanation: if Z is a confounder (Z→T and Z→Y), P(Y|T=1) > P(Y|T=0) is spurious. The correct causal effect P(Y|do(T=1)) < P(Y|do(T=0)) requires back-door adjustment. The causal DAG determines whether to condition on Z or not — without a causal model, statistics alone cannot answer.

## d-分离与条件独立性 / d-Separation and Conditional Independence

> 在 DAG G 中，路径 p 被 Z d-阻断，若 p 包含：
> (1) 一个链 A→B→C 且 B∈Z，或
> (2) 一个叉 A←B→C 且 B∈Z，或
> (3) 一个对撞 A→B←C 且 B∉Z（且 B 的后代∉Z）。

**含义**：d-分离是 DAG 编码的条件独立性——若 X 与 Y 被 Z d-分离，则 X ⊥ Y | Z 在所有由 G 产生的分布中成立。

**数学背景**：d-分离（directed separation）是 Pearl (1988) 提出的概念，连接因果图结构与概率分布的独立性。三条阻断规则对应三种路径类型：链（因果传导路径）、叉（混淆路径）、对撞（选择偏差路径）。d-分离的关键性质：(1) 若 X 与 Y 被 Z d-分离，则数据中应观察到 X ⊥ Y | Z——若观察到 X 与 Y 在给定 Z 时仍相关，则 DAG 可能错误；(2) d-分离是 DAG 的蕴涵——不需要知道具体参数值，仅从图结构即可推断独立性；(3) d-分离是因果推理的基础——后门路径就是不被空集 d-阻断的非因果路径。

**Significance**: d-separation is the conditional independence encoded by the DAG — if X and Y are d-separated by Z, then X ⊥ Y | Z holds in all distributions generated by G. The three blocking rules correspond to: chains (causal transmission), forks (confounding), colliders (selection bias). d-separation is foundational for causal reasoning — back-door paths are exactly non-causal paths not d-separated by the empty set.