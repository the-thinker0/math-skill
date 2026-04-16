# 数学出处与经典文献 / Mathematical Sources and Classic Texts

## 贝叶斯定理 / Bayes' Theorem (Bayes, 1763)

> P(H|E) = P(E|H) × P(H) / P(E)
>
> 后验概率 = 似然 × 先验概率 / 证据

**含义**：当我们观察到新证据 E 时，我们关于假设 H 的信念从先验 P(H) 更新为后验 P(H|E)。

**贝叶斯思维的核心**：
1. 先有信念（先验概率）
2. 观察数据（证据）
3. 更新信念（后验概率）
4. 重复这个过程

**数学背景**：Thomas Bayes 的论文 "An Essay towards solving a Problem in the Doctrine of Chances" 于 1763 年由 Richard Price 代为发表。贝叶斯定理本质上是条件概率的定义 P(A∩B) = P(A|B)P(B) = P(B|A)P(A) 的重排，但其哲学意义远超数学本身——它为"从数据学习"提供了严格的数学框架。

## 大数定律 / Law of Large Numbers (Bernoulli, 1713)

> 当试验次数 n 趋于无穷时，样本均值依概率收敛于期望值。
> As the number of trials n approaches infinity, the sample mean converges in probability to the expected value.

**含义**：单次观察不可赖，但大量观察会揭示真实规律。这是统计推断的理论基础。

**数学背景**：Jacob Bernoulli 在《Ars Conjectandi》(1713) 中证明了弱大数定律：对任意 ε>0, P(|X̄ₙ - μ| ≥ ε) → 0。Borel (1909) 与 Kolmogorov 进一步强化为强大数定律——几乎必然收敛：P(lim X̄ₙ = μ) = 1。

## 中心极限定理 / Central Limit Theorem (De Moivre-Laplace, 1733–Lindeberg-Feller, 20世纪)

> 大量独立同分布随机变量的和近似服从正态分布，无论原始分布是什么。
> The sum of a large number of i.i.d. random variables is approximately normally distributed, regardless of the original distribution.

**含义**：正态分布之所以普遍，是因为它是"大量小因素叠加"的自然结果。

**数学背景**：De Moivre (1733) 首先发现二项分布的正态近似；Laplace (1810) 推广到一般情形。Lindeberg-Feller 条件给出最精确的独立但非同分布情形的收敛条件。Lyapunov (1901) 引入特征函数证明方法，成为现代概率论的核心工具。

## Kolmogorov 公理化体系 / Kolmogorov Axioms (1933)

> 概率论的基础公理：
> 1. 非负性：P(A) ≥ 0
> 2. 规范性：P(Ω) = 1
> 3. 可加性：若 A₁, A₂, ... 互不相交，则 P(∪Aₖ) = ΣP(Aₖ)

**含义**：概率被定义为测度——概率论从此成为严格的数学分支，而非经验规则集合。

**数学背景**：Andrey Kolmogorov 在《Grundbegriffe der Wahrscheinlichkeitsrechnung》(1933) 中将概率论嵌入测度论框架 (Ω, F, P)，即样本空间、事件域（σ-代数）与概率测度三元组。这一公理化使大数定律、条件概率、随机变量等概念获得精确定义，是现代概率论的基石。

## Neyman-Pearson 检验理论 / Neyman-Pearson Lemma (1928/1933)

> 在给定显著性水平 α 下，似然比检验是最强大的检验：
> 拒绝 H₀ 当 L(x|H₁)/L(x|H₀) > k，其中 k 由 α 决定。

**含义**：统计检验不是主观判断，而是可以在"控制犯错概率"的前提下达到最优。

**数学背景**：Jerzy Neyman 与 Egon Pearson 在 1928–1933 年间系统化了假设检验理论，引入 Type I 错误（α，假阳性）与 Type II 错误（β，假阴性）、检验功效 (power = 1-β) 等概念。Neyman-Pearson 引理证明了简单假设 vs 简单假设情形下似然比检验的最优性。这一框架成为现代统计检验的标准范式。

## Fisher 统计推断体系 / Fisher's Statistical Inference (1920s–1930s)

- **最大似然估计**：选择使观测数据出现概率最大的参数 θ̂ = argmax L(θ; x)
- **p-value**：在原假设为真的条件下，观察到当前或更极端数据的概率
- **显著性检验**：通过 p-value 判断是否拒绝原假设
- **充分性原则**：统计量 T(X) 是充分的，若 P(X|T) 不依赖于 θ

**数学背景**：R.A. Fisher 的贡献远不止 p-value。他提出一致性、有效性等估计量评价准则； Fisher 信息量 I(θ) = E[(∂log L/∂θ)²] 度量数据对参数的信息含量，与 Cramér-Rao 下界紧密关联：Var(θ̂) ≥ 1/I(θ)。

## Fisher 实验设计 / Fisher's Experimental Design (1935)

> 随机化不是忽视因果，而是使因果推断成为可能。

**含义**：科学实验的可信度不来自"精密控制"，而来自"随机分配"。

**数学背景**：Fisher 在《The Design of Experiments》(1935) 中提出三大原则——随机化 (randomization)、区组化 (blocking)、复因子设计 (factorial designs)。随机化使处理效应的估计免受系统偏差；区组化控制已知干扰变量；2²、2³ 等因子设计可同时估计多个主效应与交互效应，效率远超逐一试验。

## Student t 分布 / Student's t-Distribution (Gosset, 1908)

> 当样本量 n 较小且总体标准差未知时：
> t = (X̄ - μ) / (S/√n)，服从 t(n-1) 分布。

**含义**：小样本不能直接用正态近似——t 分布的尾部更厚，反映了估计标准差本身的不确定性。

**数学背景**：William Sealy Gosset 以 "Student" 为笔名在 1908 年发表此结果。他在 Guinness 啤酒厂工作，因保密要求无法署真名。t 分布是标准正态与 χ²/(n-1) 的比值分布，当 n→∞ 时趋于正态。Fisher (1925) 给出了严格证明并将其推广。

## χ² 检验 / Chi-Squared Test (Karl Pearson, 1900)

> χ² = Σ(Oₖ - Eₖ)² / Eₖ，在原假设下近似服从 χ²(k-1-p) 分布。

**含义**：观测频率与期望频率之间的差异是否超过随机波动所能解释的范围？

**数学背景**：Karl Pearson 在 1900 年提出拟合优度检验，这是第一个正式的统计检验方法。自由度 = k-1-p（k 为类别数，p 为估计参数数）的修正由 Fisher (1922) 完成。χ² 检验在列联表独立性检验、分布拟合等领域广泛应用。

## 回归与最小二乘法 / Regression and Least Squares (Legendre 1805, Gauss 1809)

> min Σ(yₖ - (a + bxₖ))² → 最小二乘估计 β̂ = (X'X)⁻¹X'y

**含义**：在所有拟合直线中，最小二乘使残差平方和最小；在正态误差假设下，它等价于最大似然估计。

**数学背景**：Legendre (1805) 首先发表最小二乘法；Gauss (1809) 声称自己早在 1795 年就已使用该方法，并给出正态误差假设下的概率论证。"回归"一词由 Galton (1886) 提出，研究身高代际回归现象。现代线性回归模型 Y = Xβ + ε 是统计建模的核心框架。

## Markov 链 / Markov Chains (Markov, 1906)

> P(Xₙ₊₁ = j | Xₙ = i, Xₙ₋₁, ...) = P(Xₙ₊₁ = j | Xₙ = i)
>
> 未来只依赖现在，不依赖过去——无记忆性 (memoryless property)。

**含义**：许多真实过程具有"当前状态决定未来走向"的性质，历史细节可以忽略。

**数学背景**：Andrey Markov (1906) 通过研究普希金《叶甫盖尼·奥涅金》中元音/辅音序列，首次定义了 Markov 链。遍历定理保证：对不可约、非周期、正常返链，π(j) = lim P(Xₙ = j) 存在且为唯一平稳分布。Markov 链是 MCMC (Metropolis 1943, Hastings 1970, Gelfand-Smith 1990) 的理论基础，也支撑 Google PageRank (Brin-Page 1998)。

## 随机过程 / Stochastic Processes (Brownian Motion, Wiener Process)

> W(t) 满足：(1) W(0)=0, (2) W(t)-W(s) ~ N(0, t-s), (3) 独立增量, (4) 连续路径

**含义**：布朗运动是微观随机涨落的宏观数学模型——从花粉运动到股价波动。

**数学背景**：Brown (1827) 观察花粉微粒的无规则运动；Bachelier (1900) 首先用其模型化股价；Wiener (1923) 给出严格数学构造。Itô (1944) 发展随机积分 dX = μdt + σdW 与 Itô 公式，成为金融数学 (Black-Scholes 1973) 与随机微分方程的理论基石。

## Shannon 信息论 / Shannon Information Theory (1948)

> H(X) = -Σ p(x) log p(x) —— 熵，随机变量的不确定性度量
> I(X;Y) = H(X) - H(X|Y) —— 互信息，Y 对 X 提供的信息量
> C = max I(X;Y) —— 信道容量，可靠通信的速率上限

**含义**：信息可以被量化；通信的根本限制由数学定律决定，而非工程技术。

**数学背景**：Claude Shannon 在《A Mathematical Theory of Communication》(1948) 中创立信息论。信源编码定理：平均编码长度 ≥ H(X)；信道编码定理：传输速率 R < C 时存在可靠编码。熵与概率的深层联系——H(X) = -E[log p(X)]——使信息论成为概率论的自然延伸。

## Pearl 因果推断 / Pearl's Causal Inference (2000)

> 因果层级：
> 1. 关联 P(y|x) —— 看到
> 2. 干预 P(y|do(x)) —— 做
> 3. 反事实 P(yₓ|x', y') —— 想

**含义**：因果不是关联的强化版——"do(x)" 与 "observe x" 在数学上截然不同。

**数学背景**：Judea Pearl 在《Causality》(2000) 中用有向无环图 (DAG) 与 do-演算系统化了因果推断。do-演算三条规则允许在可观测变量间转换干预概率；前门/后门准则给出从观测数据计算因果效应的条件。因果推断回答"若我做了 x，y 会怎样"，这超出了概率论本身的表达能力。

## Bootstrap 方法 / Bootstrap (Efron, 1979)

> 从样本 X₁,...,Xₙ 中有放回抽样 B 次，得到 B 个 bootstrap 样本，
> 用 bootstrap 分布近似真实分布。

**含义**：当理论推导困难时，用数据自身模拟抽样过程——"用自己验证自己"。

**数学背景**：Bradley Efron (1979) 提出 bootstrap，其理论保证由 Bickel-Freedman (1981) 与 Singh (1981) 建立：在温和条件下，bootstrap 分布一致收敛于真实抽样分布。Bootstrap 可估计标准误、置信区间（百分位法/BCa 法）、p-value 等，是非参数推断的通用工具。

## 贝叶斯学派 vs 频率学派 / Bayesian vs Frequentist Debate

> 贝叶斯：概率是信念度，参数 θ 是随机变量 → P(θ|data)
> 频率学派：概率是长期频率，参数 θ 是固定未知常 → 估计量 θ̂ 的抽样分布

**含义**：这不是技术分歧，而是"概率是什么"的哲学分歧。

**核心对比**：
- 贝叶斯：先验 + 似然 → 后验，天然适合序贯更新与小样本
- 频率学派：无偏性、一致性、功效，天然适合大规模可重复实验
- 实践中：贝叶斯方法在机器学习、因果推断中占优；频率方法在临床试验、质量控制中占优

**数学背景**：争论自 Laplace vs Fisher 延续至今。Jeffreys (1939) 提出无信息先验 p(θ) ∝ |I(θ)|^(1/2)；de Finetti (1937) 证明主观概率的一致性等价于可加性；Bernardo-Smith (1994) 发展参考先验理论。

## Monty Hall 问题 / Monty Hall Problem

> 三扇门，一扇有奖品。你选一扇，主持人打开另一扇空门。
> 问：你是否应该换门？答案是：换门胜率 2/3，不换 1/3。

**含义**：直觉在此失效——主持人的行为传递了信息（他不会打开有奖品的门）。

**数学背景**：此问题是贝叶斯思维的绝佳入门案例。用贝叶斯定理：P(奖品在剩余门|主持人打开空门) = 2/3，因为主持人选择性地避开奖品，这本身是信息。类似的结构出现在医疗诊断、法律推理中——"选择性观察"改变了概率。

## 常见统计谬误与认知偏差

**幸存者偏差（Survivorship Bias）**：
二战期间，军方统计返航飞机的弹孔分布，发现机翼上弹孔最多，建议加固机翼。统计学家 Abraham Wald 指出：应该加固没有弹孔的部位——因为被击中那些部位的飞机根本没飞回来。Wald 的洞察本质上是条件概率：我们观察到的数据是在"飞机返航"条件下的数据，而非全部数据。

**基础率忽视（Base Rate Neglect）**：
某种罕见病发病率 0.1%，检测准确率 99%。如果检测为阳性，真正患病的概率是多少？
- 直觉回答：99%
- 贝叶斯计算：P(患病|阳性) = 0.99 × 0.001 / (0.99 × 0.001 + 0.01 × 0.999) ≈ 9%
- 先验概率（基础率）被直觉严重低估

**回归均值（Regression to the Mean）**：
表现极好的个体在下次测量中倾向于更接近平均水平，不是因为"能力下降"，而是极端表现部分来自运气。Galton (1886) 发现高个子父母的子女往往比父母矮——这不是"退化"，而是统计规律。

## 概率思维的日常生活价值

> "概率思维的核心不是计算精确概率，而是养成'在不确定性中思考'的习惯。"

- 不要被单个案例说服——考虑基础概率
- 新信息来了要更新信念——贝叶斯更新
- 区分信号和噪声——大数定律
- 警惕极端值——回归均值
- 区分"看到"与"做了"——因果层级（Pearl）
- 量化不确定性——熵与信息（Shannon）