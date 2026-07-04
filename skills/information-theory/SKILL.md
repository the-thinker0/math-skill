---
name: information-theory
description: |
  触发：问题需量化不确定性、以"信息=不确定性的减少"度量信息价值；或需计算熵/互信息/KL 散度/信道容量，为压缩/KV 压缩/量化/路由设计信息准则时调用。
  English: Trigger when a problem needs to quantify uncertainty, measure information value as "information = reduction of uncertainty"; or compute entropy / mutual information / KL divergence / channel capacity, or design information criteria for compression / KV-cache compression / quantization / routing.
---

> **语言路由**：若用户消息为英文，请读取并遵循同目录下的 `SKILL.en.md`，按其操作规程以英文输出；中文消息则继续使用本文件。

# 📡 信息论思想 / Information Theory

> "信息是不确定性的减少——知道更多意味着怀疑更少。"
> "Information is reduction of uncertainty — knowing more means doubting less."
>
> —— 信息论、编码理论、统计推断 / Information Theory, Coding Theory, Statistical Inference

## 核心原则 / Core Principle

**信息是不确定性的减少——不确定性可由熵精确量化，压缩与通信存在由熵限与信道容量刻画的不可逾越极限，信息增益则指导在不确定性下应优先获取何种观察。**

**Information is reduction of uncertainty — uncertainty is precisely quantified by entropy; compression and communication have unbreakable limits set by the entropy bound and channel capacity; information gain guides which observation to prioritize under uncertainty.**

> **数学形式化 / Mathematical Formalization**
>
> Shannon 熵 $H(X) = -\sum_x p(x)\log p(x)$ 量化随机变量的平均"惊奇度"——概率越低的事件发生时惊奇越大，熵是惊奇度的期望。
>
> 互信息 $I(X;Y) = H(X) - H(X|Y) = \sum_{x,y} p(x,y)\log\frac{p(x,y)}{p(x)p(y)}$，即观察 $Y$ 后对 $X$ 不确定性的减少——这正是"信息"的数学定义。
>
> KL 散度 $D_{KL}(P\|Q) = \sum_x p(x)\log\frac{p(x)}{q(x)}$ 衡量用 $Q$ 替代 $P$ 的信息损失，**不对称** $D(P\|Q)\neq D(Q\|P)$。
>
> 信源编码定理：最优压缩的平均编码长度 $\ge H(X)$ bits/symbol，低于熵限则必然丢失信息。
>
> 信道编码定理：可靠通信的速率上限为信道容量 $C = \max_{p(x)} I(X;Y)$；$R<C$ 时存在编码使误码率趋零，$R>C$ 时可靠通信不可能。
>
> 率失真函数 $R(D) = \min_{p(\hat{x}|x):\,\mathbb{E}[d(x,\hat{x})]\le D} I(X;\hat{X})$ 给定失真 $D$ 下的最小信息率——有损压缩的极限。
>
> 详细数学依据见 `original-texts.md`。

## GPU 友好性 / GPU-Friendliness（横切检查）

信息论量用于**压缩/剪枝/量化/KV 压缩/路由设计**时，须过 `../../references/gpu-friendly-math.md` 八维门。核心判据：**局部、可融合的熵/KL 估计 = 友好；全局精确信息估计 = 不友好**。

- **量化校准（per-block 熵/Hessian）**：局部、可批量 GEMM 化、低精度可行——友好（维度 1/2/5）。
- **KV-Cache 压缩（信息瓶颈/块摘要）**：低秩块摘要压缩显存——友好（维度 4）；Plücker 式块摘要见 `../../references/books/algebraic-geometry-rising-sea.md`。
- **互信息剪枝/特征选择**：用局部或低秩近似估计 $I(X;Y)$ 则可改造；若需全分布精确估计则不友好。
- **信息增益路由**：全局精确 $I(X;Y)$ 需 $O(n^2)$ 显存、高精度、不可融合——反模式；改用 softmax/热带门控等连续可微近似（维度 3/6/8）。
- **反模式**：在完整 token 分布上精确计算熵/互信息——显存爆炸、需 fp64、串行依赖，"美但不可算"。

八维最低判定（正式术语）：**张量化**看熵/KL/MI 是否可按 token/block/batch 估计；**GEMM 可映射**看压缩、投影、校准是否落线性代数；**复杂度**避免全分布精确估计；**显存与 KV-Cache**量化 KV/激活/码本占用；**低精度稳定**检查 log/softmax/KL 动态范围；**并行与通信**看分块统计是否可跨设备归约；**稀疏结构**看码本/路由是否块结构化；**算子融合**看统计、mask、量化能否融合。

> 配合 `../../references/books/matrix-analysis.md`（低秩压缩）、`../../references/books/abstract-algebra.md`（编码/有限域）。

## 不适用场景 / When NOT to Use

- **问题无概率结构**（如纯粹符号推理、逻辑演绎）——熵与信息增益需要概率分布，无概率则无信息论。
- **纯确定性场景无不确定性**（如已知精确答案的数学问题）——熵为零时信息论退化为平凡结论。
- **定性判断无需量化**（如美学评价、情感判断）——信息论量化的是概率意义上的不确定性，非语义歧义。

## 何时使用 / When to Use

- 需要度量不确定性的大小（熵 $H(X)$ 量化随机变量的"混乱程度"）。
- 需要比较不同信息源的价值（互信息 $I(X;Y)$ 衡量哪个观察 $Y$ 最能减少关于 $X$ 的不确定性）。
- 需要最优数据压缩（信源编码定理保证最优压缩极限为 $H(X)$ bits/symbol）。
- 需要在噪声环境下可靠通信（信道编码定理保证 $R<C$ 时可靠传输可行）。
- 需要特征选择或模型选择（互信息筛选特征，AIC/BIC/MDL 作为信息准则选择模型）。
- 需要贝叶斯模型比较（KL 散度 $D(P\|Q)$ 衡量分布间信息距离，贝叶斯因子量化模型间证据比）。
- **为压缩 / KV-Cache 压缩 / 量化 / 路由设计信息准则**，并评估其 GPU 可行性。

## 方法流程 / Method

### 第一步：识别信息源与不确定度 / Identify Source and Uncertainty
- **随机变量 $X$** 是什么？——定义信息源，明确要研究的不确定性对象。
- **概率分布 $p(x)$**——离散分布用概率表，连续分布用密度函数。
- **计算 $H(X) = -\sum p(x)\log p(x)$**——量化当前不确定性水平。
- **识别要减少的不确定性**——明确"知道什么之后不确定性会降低？"

### 第二步：量化信息增益 / Quantify Information Gain
- **计算条件熵 $H(X|Y)$**——观察 $Y$ 之后 $X$ 的剩余不确定性。
- **计算互信息 $I(X;Y) = H(X) - H(X|Y)$**——$Y$ 对 $X$ 提供的信息量。
- **识别最优观察**——哪个 $Y$ 使 $I(X;Y)$ 最大？该观察最值得获取。
- **链式规则**——$H(X_1,\dots,X_n) = H(X_1) + H(X_2|X_1) + \dots + H(X_n|X_1,\dots,X_{n-1})$，逐变量拆解联合不确定性。

### 第三步：选择编码策略 / Choose Coding Strategy
- **信源编码（压缩）**：Huffman 编码（贪心最优前缀码，平均长度接近 $H(X)$）、算术编码（更接近熵限）、通用编码（LZ77/LZ78/LZW，无需已知分布）。
- **信道编码（纠错）**：Hamming 码（最小距离 3，纠正 1 位错）、Reed-Solomon 码（突发纠错）、LDPC/Turbo 码（逼近 Shannon 极限）。
- **编码选择原则**：压缩需求用信源编码→逼近 $H(X)$；噪声防护用信道编码→逼近 Shannon 极限 ($R\to C$)。

### 第四步：评估信道容量 / Evaluate Channel Capacity
- **计算信道容量 $C = \max_{p(x)} I(X;Y)$**——在所有输入分布上最大化互信息。
- **比较传输速率 $R$ 与容量 $C$**：$R<C$ → 可靠通信可行；$R>C$ → 必定出错。
- **噪声模型**：BSC（二元对称信道，翻转概率 $p$）、BEC（二元擦除信道，擦除概率 $\varepsilon$）、AWGN（加性白高斯噪声信道）。
- **容量公式示例**：BSC 容量 $C = 1 - H(p)$；AWGN 容量 $C = \frac{1}{2}\log(1 + S/N)$。

### 第五步：应用信息准则 / Apply Information Criteria
- **AIC（赤池信息准则）**：$\text{AIC} = -2\ln L + 2k$——偏重拟合，适合预测目标。
- **BIC（贝叶斯信息准则）**：$\text{BIC} = -2\ln L + k\ln n$——偏重简约，适合解释目标。
- **KL 散度 $D_{KL}(P\|Q) = \sum p(x)\log\frac{p(x)}{q(x)}$**——衡量用 $Q$ 替代 $P$ 的信息损失，注意不对称性。
- **MDL 原则（最小描述长度）**：选择使"数据描述长度 + 模型描述长度"最小的模型——信息论版本的奥卡姆剃刀。

### 第六步：做出信息最优决策 / Make Information-Optimal Decision
- **贝叶斯实验设计**：选择使期望信息增益 $\max\,\mathbb{E}[I(\theta;Y)]$ 最大的实验——优先获取最能减少不确定性的数据。
- **最小化 KL 散度**：决策输出分布 $Q$ 应尽量接近目标分布 $P$，即 $\min D(P\|Q)$。
- **最大熵原则**：在已知约束下选择使 $H(X)$ 最大的分布——最少假设，最保守推断。
- **信息瓶颈**：$\min I(X;T) - \beta I(T;Y)$——在压缩 $X$ 为 $T$ 时保留关于 $Y$ 的最大相关信息。

## 常见错误 / Common Errors

| 错误 / Error | 批评 / Critique | 正确做法 / Correct Approach |
|---|---|---|
| 把信息等同于比特而非概率减少 | 熵 $H(X)$ 是概率分布的函数，比特只是量化单位 | 理解信息为不确定性的减少 $I(X;Y)=H(X)-H(X\|Y)$ |
| 忽视信道容量极限 | $R>C$ 时无论何种编码都不能可靠通信 | 计算容量 $C=\max I(X;Y)$，确保 $R<C$ |
| 混淆熵与方差 | 熵度量概率结构的"扩散度"，方差度量数值"展开度"，两者不等价 | 概率不确定性用熵，数值偏差用方差；连续熵可为负 |
| 过度压缩低于熵限 | 最优压缩 $\ge H(X)$ bits/symbol，低于此限必然丢信息 | 接受熵限并据此设计编码 |
| 忽视 KL 散度不对称性 | $D(P\|Q)\ne D(Q\|P)$，方向不同含义不同 | 明确方向：$D(P\|Q)$ 用于"用 $Q$ 编码 $P$ 的额外代价" |
| 把相关性等同于信息 | 相关 $\rho$ 仅衡量线性关联；$I(X;Y)=0 \Leftrightarrow$ 独立，但 $\rho=0 \not\Rightarrow$ 独立 | 用互信息 $I(X;Y)$ 评估依赖关系 |
| 把定性判断强行量化 | 信息论量化概率不确定性，非语义歧义或主观感受 | 区分概率不确定性与语义歧义，不对定性问题套熵公式 |
| 全局精确熵/互信息不可算 | 在完整分布上精确估计 $I(X;Y)$ 需 $O(n^2)$ 显存与高精度，GPU 不可行 | 用局部/采样/低秩估计，过 GPU 八维门 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，输出必须包含：

1. **[信息源]:[描述]** $H(X)=$ [值]——定义随机变量 $X$，计算其熵，量化当前不确定性。
2. **[信息增益]:[描述]** $I(X;Y)=$ [值]——计算互信息，识别最有价值的观察 $Y$。
3. **[编码策略]:[选择]**——信源编码（压缩）或信道编码（纠错），说明逼近哪种极限。
4. **[信道容量]:[描述]** $C=$ [值]——计算信道容量，比较传输速率 $R$ 与 $C$。
5. **[信息准则]:[AIC/BIC/KL/MDL]**——说明选择的信息准则及理由。
6. **[最优决策]:[说明]**——基于信息增益最大化或 KL 散度最小化的决策建议。
7. **[GPU 可行性]**（若用于压缩/KV 压缩/量化/路由）——熵/KL/互信息估计是局部可融合还是全局精确？过八维门，标注友好/可改造/不友好 + 改造建议。

**输出不得只给分析而无结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **概率与统计**：熵与信息增益补充概率推理——$H(X)$ 度量分布不确定性，$I(X;Y)$ 是贝叶斯更新的信息论表达。
- **优化思想**：信道容量最大化是优化问题——$C=\max_{p(x)} I(X;Y)$ 是输入分布上的最优化。
- **变换思想**：编码是信息空间的变换——信源编码变换为高效表示，信道编码变换为抗干扰表示。
- **建模思想**：信息准则指导模型选择——AIC/BIC/MDL 从信息论角度量化拟合与复杂度权衡。
- **算法思想**：压缩算法是计算实现——Huffman/LZ/LDPC 等算法是信息论极限的逼近实现。
- **现代数学激活**：`../../references/books/matrix-analysis.md`（低秩压缩）、`../../references/books/abstract-algebra.md`（编码/有限域）、`../../references/books/algebraic-geometry-rising-sea.md`（Plücker KV 压缩）。
