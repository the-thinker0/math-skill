# 浓度不等式 / Concentration Inequality

## 最小定义
浓度不等式界定了**独立随机变量之和（或 Lipschitz 函数）偏离其期望的概率上界**。核心直觉：大量独立随机因素叠加后，结果高度集中在期望附近，尾部概率指数衰减。它是"大数定律的定量加强版"。

## 核心公式

**Markov 不等式**（最弱、最通用）：
$$P(X \geq a) \leq \frac{\mathbb{E}[X]}{a}, \quad X \geq 0$$

**Hoeffding 不等式**（有界独立变量之和）：
$$P\left(\left|\frac{1}{n}\sum_{i=1}^n X_i - \mathbb{E}\left[\frac{1}{n}\sum X_i\right]\right| \geq t\right) \leq 2\exp\left(-\frac{2n^2 t^2}{\sum(b_i - a_i)^2}\right)$$

**Bernstein 不等式**（利用方差信息，尾部更紧）：设 $X_i$ 独立、零均值且 $|X_i| \leq M$，记 $\sigma^2 = \sum_i \mathrm{Var}(X_i)$，则
$$P\left(\sum X_i \geq t\right) \leq \exp\left(-\frac{t^2/2}{\sigma^2 + Mt/3}\right)$$

**McDiarmid 不等式**（有界差分函数）：若 $f$ 对第 $i$ 个变量的变化敏感度为 $c_i$，则
$$P(|f(X_1,\ldots,X_n) - \mathbb{E}[f]| \geq t) \leq 2\exp\left(-\frac{2t^2}{\sum c_i^2}\right)$$

## 适用问题
- **泛化界推导**：给定训练集大小 $n$，模型预测与真实风险之差以多大概率落在 $\epsilon$ 内
- **随机算法可靠性**：Mini-batch 梯度与全量梯度的偏差概率控制
- **采样估算精度**：Monte Carlo 估计的置信区间定量计算

## AI 设计翻译
- **PAC 学习界 / 泛化界**：Hoeffding/McDiarmid → 经验风险与真实风险之差的概率界
- **Dropout / Stochastic Depth 的方差控制**：Bernstein 不等式给出随机正则化后输出集中度的保证
- **梯度压缩 / 通信效率**：量化或稀疏化后梯度偏差的浓度界，确保分布式训练收敛

## 工程可行性
- **D1[v]**：界本身是标量公式，不涉及张量运算，作为分析工具零开销
- **D2[v]**：不直接参与 GEMM，但可作为超参数选择（batch size、压缩率）的理论依据
- **D3[v]**：计算界本身 $O(1)$ 或 $O(n)$，极低
- **D5[v]**：界用 fp32 计算即可，不进入训练主干
- **D8[v]**：不进入计算图，无融合负担

## 风险与失效条件
- **独立性假设不成立**：序列数据、自回归模型中 token 间强相关，Hoeffding 的指数衰减保证失效。需用 Martingale 版本（Azuma-Hoeffding）或混合时间修正。
- **有界性假设违反**：重尾分布（如幂律）下 Hoeffding 不适用，需改用 Bernstein 或截断技巧。在 LLM 训练中梯度偶尔出现极大值时，朴素浓度界给出虚假安全感。

## 深入参考
- 蒸馏稿：`../../references/books/` 暂无专用概率蒸馏稿，本卡基于标准概率论教材
- Boucheron, Lugosi, Massart. *Concentration Inequalities: A Nonasymptotic Theory of Independence*. Oxford, 2013
- Vershynin. *High-Dimensional Probability*. Cambridge, 2018（第 2-3 章）
- 关联知识卡：`entropy.md`、`fisher-information.md`


## 路由扩展
- 若需要信息论界 → `entropy.md`（基于熵的集中不等式）
- 若需要 Donsker-Varadhan 表示 → `kl-divergence.md`（KL 散度的变分表示）
- 若涉及随机矩阵界 → `../matrix-analysis/random-matrix.md`（MP 律、谱范数与最小奇异值的非渐近界）

## 可扩展方向
- 鞅集中（Azuma / Freedman）：鞅差的集中不等式
- 对数 Sobolev 不等式（log-Sobolev inequalities）：蕴含超收缩和集中
- 传输不等式（transportation inequalities）：Wasserstein 距离与相对熵的关系
- Talagrand 不等式：乘积空间上的维度无关集中
- 乘积空间集中（concentration on product spaces）：独立变量函数的集中
- 维度无关界（dimension-free bounds）：不随维度退化的集中界
