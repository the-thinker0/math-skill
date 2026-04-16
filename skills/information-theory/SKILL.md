---
name: information-theory
description: |
  科研模式触发：熵计算、信道容量、编码理论、模型选择等信息论数学形式化问题。
  生活模式触发：评估信息价值、减少冗余、判断该获取哪些信息等日常信息决策问题。
  English (Research mode): Trigger for entropy computation, channel capacity, coding theory, model selection.
  English (Life mode): Trigger for assessing information value, reducing redundancy, evaluating what information to seek.
---

# 📡 信息论思想

> "信息是不确定性的减少——知道更多意味着怀疑更少。"
> "Information is reduction of uncertainty — knowing more means doubting less."
>
> —— 信息论、编码理论、统计推断
> —— Information Theory, Coding Theory, Statistical Inference

## 核心原则 / Core Principle

三个核心洞见：
1. **不确定性是可量化的**——熵 H(X) 给出不确定性的精确度量，而非主观感受
   **Uncertainty is quantifiable** — entropy H(X) gives a precise measure of uncertainty, not a subjective feeling
2. **压缩与通信存在基本极限**——信源编码定理与信道编码定理揭示了信息处理的数学边界，不可逾越
   **Compression and communication have fundamental limits** — source coding and channel coding theorems reveal mathematical boundaries of information processing, unbreakable
3. **信息增益连接不确定性与决策**——观察 Y 对 X 的信息增益 I(X;Y) = H(X) − H(X|Y) 指导在不确定性下应优先获取何种信息
   **Information gain connects uncertainty and decision-making** — I(X;Y) = H(X) − H(X|Y) guides which information to prioritize under uncertainty

> **数学形式化 / Mathematical Formalization**（科研模式参考）
>
> Shannon 熵 H(X) = −Σ p(x) log p(x) 量化随机变量的平均"惊奇度"——概率越低的事件发生时带来的惊奇越大，熵是所有事件惊奇度的期望。
>
> 信息增益 I(X;Y) = H(X) − H(X|Y) 量化观察 Y 之后对 X 不确定性的减少——这正是"信息"的数学定义。
>
> 信源编码定理：最优压缩的平均编码长度 ≥ H(X) bits/symbol，低于熵限则必然丢失信息。
>
> 信道编码定理：可靠通信的速率上限为信道容量 C = max I(X;Y)，当传输速率 R < C 时存在编码方案使误码率趋零，R > C 时可靠通信不可能。
>
> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **问题无概率结构**（如纯粹符号推理、逻辑演绎）——熵与信息增益需要概率分布，无概率则无信息论 `[科研]`
  **No probabilistic structure** (e.g., pure symbolic reasoning, logical deduction) — entropy and information gain require probability distributions `[科研]`
- **纯确定性场景无不确定性**（如已知精确答案的数学问题）——熵为零时信息论退化为平凡结论 `[科研]`
  **Purely deterministic scenarios with no uncertainty** (e.g., math problems with exact known answers) — when entropy is zero, information theory degenerates to trivial conclusions `[科研]`
- **定性判断无需量化**（如美学评价、情感判断）——信息论量化的是概率意义上的不确定性，非语义歧义 `[通用]`
  **Qualitative judgments need no quantification** (e.g., aesthetic evaluation, emotional judgment) — information theory quantifies uncertainty in the probabilistic sense, not semantic ambiguity `[通用]`
- **被噪音信息淹没而忽略关键信息**——在信息过载的环境中迷失于无关细节 `[生活]`
  **Overwhelmed by noise information while ignoring key information** — lost in irrelevant details in an information-overloaded environment `[生活]`
- **追求更多信息而不评估其价值**——数量不等于质量，未经筛选的信息可能是噪音 `[生活]`
  **Seeking more information without evaluating its value** — quantity ≠ quality; unfiltered information may be noise `[生活]`
- **信息过载导致决策瘫痪**——信息量超过处理能力时反而降低决策质量 `[生活]`
  **Decision paralysis from information overload** — when information volume exceeds processing capacity, decision quality actually declines `[生活]`

## 何时使用 / When to Use

### 科研触发条件 / Research Trigger Conditions

- 需要度量不确定性的大小（熵 H(X) 量化随机变量的"混乱程度"）
  Need to measure the magnitude of uncertainty (entropy H(X) quantifies the "disorder" of a random variable)
- 需要比较不同信息源的价值（互信息 I(X;Y) 衡量哪个观察 Y 最能减少关于 X 的不确定性）
  Need to compare the value of different information sources (mutual information I(X;Y) measures which observation Y best reduces uncertainty about X)
- 需要最优数据压缩（信源编码定理保证最优压缩极限为 H(X) bits/symbol）
  Need optimal data compression (source coding theorem guarantees the optimal compression limit is H(X) bits/symbol)
- 需要在噪声环境下可靠通信（信道编码定理保证速率低于容量 C 时可靠传输可行）
  Need reliable communication under noise (channel coding theorem guarantees reliable transmission when rate is below capacity C)
- 需要特征选择或模型选择（互信息筛选特征，AIC/BIC/MDL 作为信息准则选择模型）
  Need feature selection or model selection (mutual information filters features, AIC/BIC/MDL as information criteria for model selection)
- 需要贝叶斯模型比较（KL 散度 D(P||Q) 衡量分布间信息距离，贝叶斯因子量化模型间证据比）
  Need Bayesian model comparison (KL divergence D(P||Q) measures information distance between distributions, Bayes factor quantifies evidence ratio between models)

### 生活触发条件 / Life Trigger Conditions

- 需要评估某条信息是否值得获取——不是所有信息都有同等价值
  Need to assess whether a piece of information is worth acquiring — not all information has equal value
- 需要在信息过载中筛选关键信息——去除冗余、聚焦核心
  Need to filter key information from overload — remove redundancy, focus on the core
- 需要判断哪个解释更合理——最简洁且最有解释力的解释优于复杂但增量解释力很小的解释
  Need to judge which explanation is more reasonable — the simplest yet most explanatory beats complex ones with marginal explanatory gain
- 需要决定是先收集更多信息还是果断行动——信息不足时先收集关键信息，信息足够时果断行动
  Need to decide whether to gather more information or act decisively — collect key info when insufficient, act decisively when sufficient
- 需要提高沟通效率——识别信息传递的瓶颈，用最精炼的方式传达关键内容
  Need to improve communication efficiency — identify bottlenecks, convey key content in the most concise way

## 方法流程 / Method

### 第一步：识别信息源与不确定度 / Step 1: Identify Source and Uncertainty

**科研模式 / Research Mode:**
- **随机变量 X** 是什么？——定义信息源，明确要研究的不确定性对象
- **概率分布 p(x)**——离散分布用概率表，连续分布用密度函数
- **计算 H(X) = −Σ p(x) log p(x)**——量化当前不确定性水平
- **识别要减少的不确定性**——明确"知道什么之后不确定性会降低？"

**生活模式 / Life Mode:**
- 你面对的不确定性是什么？你最想搞清楚哪件事？——明确"知道什么之后不确定性会降低"是关键
  What uncertainty are you facing? What do you most want to figure out? — clarifying "what knowledge would reduce uncertainty" is the key

**共通要点 / Common Point:**
- 核心都是明确不确定性对象——科研用数学定义 X 和 p(x)，生活用问题描述
  The core is clarifying the object of uncertainty — research uses mathematical definitions of X and p(x), life uses problem description

### 第二步：量化信息增益 / Step 2: Quantify Information Gain

**科研模式 / Research Mode:**
- **计算条件熵 H(X|Y)**——观察 Y 之后 X 的剩余不确定性
- **计算互信息 I(X;Y) = H(X) − H(X|Y)**——Y 对 X 提供的信息量
- **识别最优观察**——哪个 Y 使 I(X;Y) 最大？该观察最值得获取
- **链式规则**——H(X₁,...,Xₙ) = H(X₁) + H(X₂|X₁) + ... + H(Xₙ|X₁,...,Xₙ₋₁)，逐个变量拆解联合不确定性

**生活模式 / Life Mode:**
- 这条信息能减少多少不确定性？——不是所有信息都有同等价值，有的信息一针见血，有的信息只是噪音
  How much uncertainty can this information reduce? — not all information has equal value; some is incisive, some is just noise

**共通要点 / Common Point:**
- 核心都是评估信息的价值——科研用 I(X;Y) 精确量化，生活用直觉判断哪条信息最能减少不确定性
  The core is evaluating information value — research uses I(X;Y) for precise quantification, life uses intuitive judgment of which info best reduces uncertainty

### 第三步：选择编码策略 / Step 3: Choose Coding Strategy

**科研模式 / Research Mode:**
- **信源编码（压缩）**：Huffman 编码（贪心最优前缀码，平均长度接近 H(X)）、算术编码（更接近熵限）、通用编码（LZ77/LZ78/LZW，无需已知分布）
- **信道编码（纠错）**：Hamming 码（最小距离 3，纠正 1 位错）、Reed-Solomon 码（突发纠错）、LDPC/Turbo 码（逼近 Shannon 极限）
- **编码选择原则**：压缩需求用信源编码→逼近 H(X)；噪声防护用信道编码→逼近 Shannon 极限 (R→C)

**生活模式 / Life Mode:**
- 如何用最精炼的方式传递关键信息？——去除冗余、聚焦核心、避免信息过载
  How to convey key information in the most concise way? — remove redundancy, focus on the core, avoid information overload

**共通要点 / Common Point:**
- 核心都是压缩与传递的效率——科研用编码定理逼近数学极限，生活用精炼表达逼近沟通极限
  The core is efficiency of compression and transmission — research uses coding theorems to approach mathematical limits, life uses concise expression to approach communication limits

### 第四步：评估信道容量 / Step 4: Evaluate Channel Capacity

**科研模式 / Research Mode:**
- **计算信道容量 C = max_{p(x)} I(X;Y)**——在所有输入分布 p(x) 上最大化互信息
- **比较传输速率 R 与容量 C**：R < C → 可靠通信可行；R > C → 必定出错
- **噪声模型**：BSC（二元对称信道，翻转概率 p）、BEC（二元擦除信道，擦除概率 ε）、AWGN（加性白高斯噪声信道）
- **容量公式示例**：BSC 容量 C = 1 − H(p)；AWGN 容量 C = ½ log(1 + S/N)

**生活模式 / Life Mode:**
- 信息传递的瓶颈在哪？——不是所有信息都能有效传达，识别沟通的限制条件
  Where is the bottleneck in information transmission? — not all information can be effectively conveyed; identify communication constraints

**共通要点 / Common Point:**
- 核心都是识别信息传递的限制——科研用信道容量 C 量化数学极限，生活用沟通瓶颈识别实际限制
  The core is identifying limits of information transmission — research uses channel capacity C to quantify mathematical limits, life uses communication bottlenecks to identify practical limits

### 第五步：应用信息准则 / Step 5: Apply Information Criteria

**科研模式 / Research Mode:**
- **AIC（赤池信息准则）**：AIC = −2lnL + 2k——偏重拟合，适合预测目标
- **BIC（贝叶斯信息准则）**：BIC = −2lnL + k·ln(n)——偏重简约，适合解释目标
- **KL 散度 D(P||Q) = Σ p(x) log(p(x)/q(x))**——衡量用 Q 替代 P 的信息损失，注意不对称性 D(P||Q) ≠ D(Q||P)
- **MDL 原则（最小描述长度）**：选择使"数据描述长度 + 模型描述长度"最小的模型——信息论版本的奥卡姆剃刀

**生活模式 / Life Mode:**
- 如何判断哪个解释更好？——最简洁且最解释力的解释优于复杂但增量解释力很小的解释（奥卡姆剃刀的信息论版本）
  How to judge which explanation is better? — the simplest yet most explanatory explanation beats complex ones with marginal explanatory gain (the information-theoretic version of Occam's razor)

**共通要点 / Common Point:**
- 核心都是简洁性与解释力的权衡——科研用 AIC/BIC/KL/MDL 精确量化，生活用"简洁且有解释力"直觉判断
  The core is balancing simplicity and explanatory power — research uses AIC/BIC/KL/MDL for precise quantification, life uses "simple yet explanatory" intuitive judgment

### 第六步：做出信息最优决策 / Step 6: Make Information-Optimal Decision

**科研模式 / Research Mode:**
- **贝叶斯实验设计**：选择使期望信息增益 max E[I(θ;Y)] 最大的实验——优先获取最能减少不确定性的数据
- **最小化 KL 散度**：决策输出分布 Q 应尽量接近目标分布 P，即 min D(P||Q)
- **最大熵原则**：在已知约束下选择使 H(X) 最大的分布——最少假设，最保守推断
- **信息瓶颈**：min I(X;T) − βI(T;Y)——在压缩 X 为 T 时保留关于 Y 的最大相关信息

**生活模式 / Life Mode:**
- 在当前信息水平下做最优决策——信息不足时先收集关键信息，信息足够时果断行动
  Make the optimal decision at the current information level — collect key info when insufficient, act decisively when sufficient

**共通要点 / Common Point:**
- 核心都是信息与行动的平衡——科研用信息增益最大化设计实验，生活用"信息不足先收集、信息足够果断行动"策略
  The core is balancing information and action — research uses information gain maximization to design experiments, life uses "collect when insufficient, act when sufficient" strategy

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach | 标签 / Tag |
|---|---|---|---|
| 把信息等同于比特而非概率减少 | 熵 H(X) 是概率分布的函数，不是比特的物理量；信息增益 I(X;Y) 是不确定性的减少量 | 理解信息为不确定性的减少：I(X;Y) = H(X) − H(X|Y)，比特只是量化单位 | `[科研]` |
| 忽视信道容量极限 | R > C 时无论何种编码都不能实现可靠通信；信道容量是数学极限而非工程限制 | 计算信道容量 C = max I(X;Y)，确保 R < C | `[科研]` |
| 混淆熵与方差 | 熵 H(X) 度量分布的"扩散度"（概率意义上），方差 Var(X) 度量分布的"展开度"（距离意义上）；两者不等价 | 熵量化概率结构的不确定性，方差量化数值偏差；连续分布熵可为负 | `[科研]` |
| 过度压缩低于熵限 | 信源编码定理保证最优压缩 ≥ H(X) bits/symbol；低于此限必然丢失信息 | 最优压缩极限为 H(X)，接受此极限并据此设计编码 | `[科研]` |
| 忽视 KL 散度不对称性 | D(P||Q) ≠ D(Q||P)；D(P||Q) 衡量"用 Q 近似 P 的信息损失"，D(Q||P) 衡量"用 P 近似 Q 的信息损失" | 明确 KL 散度的方向性：D(P||Q) 用于编码（用 Q 编码 P 的额外代价） | `[科研]` |
| 把相关性等同于信息 | 相关 ρ(X,Y) 仅衡量线性关联；互信息 I(X;Y) 衡量所有依赖关系（含非线性）；I(X;Y)=0 ⇔ X,Y 独立，但 ρ=0 ≠ X,Y 独立 | 用互信息 I(X;Y) 代替相关系数 ρ 评估变量间依赖关系 | `[科研]` |
| 把定性判断强行量化 | 信息论量化的是概率意义上的不确定性，非语义歧义或主观感受 | 区分概率不确定性与语义歧义，不要对定性问题强行套用熵公式 | `[通用]` |
| 被噪音信息淹没而忽略关键信息 | 信息过载时，大量低价值信息掩盖了少量高价值信息 | 先评估每条信息的不确定性减少能力，优先关注高信息增益的信息 | `[生活]` |
| 追求更多信息而不评估其价值 | 数量 ≠ 质量；未经筛选的信息可能是噪音而非信息 | 每获取一条信息前先问"这条信息能减少多少不确定性？" | `[生活]` |
| 信息过载导致决策瘫痪 | 信息量超过处理能力时，决策质量反而下降 | 设定信息收集的止损点——信息足够时果断行动，不再追求完美信息 | `[生活]` |

## 操作规程 / Operating Procedure

当本 skill 被触发时，首先判断模式：

- **科研模式**：问题涉及熵计算、信道容量、编码理论、模型选择等数学形式化
- **生活模式**：问题涉及评估信息价值、减少冗余、判断该获取哪些信息等日常决策

---

### 科研模式输出格式 / Research Mode Output Format

1. **[信息源]:[描述]** H(X) = [值]——定义随机变量 X，计算其熵，量化当前不确定性
2. **[信息增益]:[描述]** I(X;Y) = [值]——计算互信息，识别最有价值的观察 Y
3. **[编码策略]:[选择]**——信源编码（压缩）或信道编码（纠错），说明逼近哪种极限
4. **[信道容量]:[描述]** C = [值]——计算信道容量，比较传输速率 R 与 C
5. **[信息准则]:[AIC/BIC/KL/MDL]**——说明选择的信息准则及理由
6. **[最优决策]:[说明]**——基于信息增益最大化或 KL 散度最小化的决策建议

**科研模式输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**

---

### 生活模式输出格式 / Life Mode Output Format

1. **[核心不确定性]:[描述]** — 你最想搞清楚什么
   **[Core Uncertainty]:[description]** — What you most want to figure out
2. **[信息价值排序]:[列表]** — 哪些信息最能减少不确定性，价值高低排序
   **[Information Value Ranking]:[list]** — Which information best reduces uncertainty, ranked by value
3. **[信息瓶颈]:[识别]** — 信息传递或获取的限制在哪
   **[Information Bottleneck]:[identification]** — Where are the limits on information transmission or acquisition
4. **[精炼传递]:[建议]** — 如何用最精炼的方式聚焦关键信息
   **[Concise Transmission]:[suggestion]** — How to focus key information in the most concise way
5. **[最优解释]:[判断]** — 哪个解释最简洁且最有力
   **[Optimal Explanation]:[judgment]** — Which explanation is simplest yet most powerful
6. **[行动建议]:[步骤]** — 在当前信息水平下最务实的行动方案
   **[Action Advice]:[steps]** — The most pragmatic action plan at the current information level

**生活模式输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **概率与统计**(熵与信息增益补充概率推理)——熵 H(X) 度量概率分布的不确定性，信息增益 I(X;Y) 是贝叶斯更新的信息论表达
- **优化思想**(信道容量最大化是优化问题)——C = max_{p(x)} I(X;Y) 是在输入分布上的最优化问题
- **变换思想**(编码是信息空间的变换)——编码将信息从原始空间映射到压缩/纠错空间，是信息空间的变换
- **建模思想**(信息准则指导模型选择)——AIC/BIC/MDL 从信息论角度量化模型的拟合与复杂度权衡
- **算法思想**(压缩算法是计算实现)——Huffman/LZ/LDPC 等算法是信息论极限的逼近实现