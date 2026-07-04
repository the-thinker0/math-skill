# 熵 / Entropy

## 最小定义
Shannon 熵度量一个随机变量的**不确定性总量**——即描述该变量所需的最少平均比特数。它是信息论的基石，也是最大似然、变分推断、正则化等 AI 方法的底层统一量。

## 核心公式

**Shannon 熵**（离散）：
$$H(X) = -\sum_{x} p(x) \log p(x)$$

**微分熵**（连续）：
$$h(X) = -\int p(x) \log p(x)\, dx$$

**联合熵与条件熵**：
$$H(X, Y) = H(X) + H(Y|X), \quad H(Y|X) = -\sum_{x,y} p(x,y) \log p(y|x)$$

**互信息**（两个变量共享的信息量）：
$$I(X; Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) = \sum_{x,y} p(x,y) \log \frac{p(x,y)}{p(x)p(y)}$$

**最大熵原理**：在满足约束条件 $\mathbb{E}[f_i(X)] = c_i$ 的所有分布中，使 $H(X)$ 最大的分布为指数族 $p(x) \propto \exp\left(\sum \lambda_i f_i(x)\right)$。

## 适用问题
- **特征选择**：用互信息 $I(X; Y)$ 筛选对目标变量最有信息量的特征
- **模型压缩与量化**：熵给出无损压缩的理论下界（Shannon 编码定理）
- **正则化设计**：最大熵正则化鼓励模型输出"不确定但公平"的分布，防止过自信

## AI 设计翻译
- **交叉熵损失 Cross-Entropy Loss**：$H(p, q) = -\sum p(x)\log q(x)$，分类任务的默认损失函数，本质是真实分布 $p$ 与模型分布 $q$ 之间的"编码冗余"
- **KL 散度**（详见 `kl-divergence.md`）：$D_{KL}(p\|q) = H(p,q) - H(p)$，即交叉熵与熵之差
- **变分自编码器 VAE**：ELBO = 重构似然 $-$ KL 正则项，本质是在信息压缩（低 $H(Z)$）与重构保真之间取平衡

## 工程可行性
- **维度 1 张量化 ✅**：$-\sum p \log p$ 是逐元素运算，完美向量化
- **维度 2 GEMM 可映射 ⚠️**：熵本身不是 GEMM，但交叉熵损失的梯度计算涉及 softmax → matmul 链
- **维度 3 复杂度 ✅**：$O(|\mathcal{X}|)$ 线性，vocab 级计算可接受
- **维度 5 低精度 ✅**：$\log$ 和 exp 在 bf16 下稳定，softmax 有 log-sum-exp 技巧
- **维度 8 算子融合 ✅**：softmax + cross-entropy 是经典融合算子（FusedSoftmaxCrossEntropy）

## 风险与失效条件
- **连续熵可为负**：微分熵 $h(X)$ 不受 $H(X) \geq 0$ 约束，直接比较不同量纲的微分熵可产生误导。应改用互信息或 KL 散度（非负）。
- **对 vocab 大小敏感**：大 vocab（如 LLM 的 128K tokenizer）下 softmax + 交叉熵的显存峰值可达数十 GB，需 chunked/online softmax 或 label smoothing 缓解。

## 深入参考
- 蒸馏稿：`references/books/` 暂无专用信息论蒸馏稿
- Cover & Thomas. *Elements of Information Theory*, 2nd Edition. Wiley, 2006
- MacKay. *Information Theory, Inference, and Learning Algorithms*. Cambridge, 2003
- 关联知识卡：`probability/kl-divergence.md`、`probability/information-bottleneck.md`
