# 熵 / Entropy

## 最小定义
离散变量用以2为底的对数时，Shannon 熵以 bit 衡量不确定性，并给出平均无损码长下界；单符号前缀码未必精确达到它。自然对数用 nat。微分熵依赖参考测度及坐标，而固定概率测度之间的 KL/MI 具有换元不变性。

## 核心公式

**Shannon 熵**（离散）：
$$H(X) = -\sum_{x} p(x) \log p(x)$$

**微分熵**（连续）：
$$h(X) = -\int p(x) \log p(x)\, dx$$

**联合熵与条件熵**：
$$H(X, Y) = H(X) + H(Y|X), \quad H(Y|X) = -\sum_{x,y} p(x,y) \log p(y|x)$$

**互信息**（两个变量共享的信息量）：
$$I(X; Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) = \sum_{x,y} p(x,y) \log \frac{p(x,y)}{p(x)p(y)}$$

**约束最大熵**：明确支撑/底测度及可行矩约束后，若存在可归一化的内部最优点，Lagrange 驻点条件给出指数族形式。须检查存在性、边界最优及熵无上界情形；任意矩约束不保证可归一化最优分布。

## 适用问题
- **特征选择**：用互信息 $I(X; Y)$ 筛选对目标变量最有信息量的特征
- **模型压缩与量化**：熵给出无损压缩的理论下界（Shannon 编码定理）
- **生成模型的评估与训练**：交叉熵/perplexity 是语言模型的内禀度量；熵正则鼓励探索（RL 中 $\mathcal{L} = \mathcal{L}_{\text{policy}} - \beta H(\pi)$）
- **不确定性量化**：预测熵 $H(p(y|x))$ 作为置信度信号，用于主动学习、OOD 检测与拒识
- **正则化设计**：最大熵正则化鼓励模型输出"不确定但公平"的分布，防止过自信；label smoothing 等价于对输出分布加熵正则

## AI 设计翻译
- **交叉熵**：$H(p,q)=-\sum p\log q$ 是使用模型码的期望码长/交叉熵；超过 $p$ 自身熵的冗余是 **KL**，不是交叉熵本身。
- **KL 散度**（详见 `kl-divergence.md`）：$D_{KL}(p\|q) = H(p,q) - H(p)$，即交叉熵与熵之差
- **VAE**：编码器到先验的期望 KL 包含输入—潜变量 MI 以及聚合后验与先验失配，不等于最小化潜变量熵；需明确随机信道与先验。

## 工程可行性
- **D1[v]**：$-\sum p \log p$ 是逐元素运算，完美向量化
- **D2[~]**：熵本身不是 GEMM，但交叉熵损失的梯度计算涉及 softmax → matmul 链
- **D3[v]**：$O(|\mathcal{X}|)$ 线性，vocab 级计算可接受
- **D5[~]**：使用稳定 log-softmax 与 fp32 累加；mask 零概率按 $0\log0=0$ 处理。低精度 exp/log 可下溢或溢出。
- **D8[v]**：softmax + cross-entropy 是经典融合算子（FusedSoftmaxCrossEntropy）

## 风险与失效条件
- **连续熵可为负**：微分熵 $h(X)$ 不受 $H(X) \geq 0$ 约束，直接比较不同量纲的微分熵可产生误导。应改用互信息或 KL 散度（非负）。
- **词表显存**：物化 $B\times T\times V$ logits 随 batch、序列及词表增长。分块/融合交叉熵可减中间存储；标签平滑改变目标，本身不是降显存方法。

## 深入参考
- 蒸馏稿：`../../references/books/` 暂无专用信息论蒸馏稿
- Cover & Thomas. *Elements of Information Theory*, 2nd Edition. Wiley, 2006
- MacKay. *Information Theory, Inference, and Learning Algorithms*. Cambridge, 2003
- 关联知识卡：`kl-divergence.md`、`information-bottleneck.md`


## 路由扩展
- 若需要相对熵 → `kl-divergence.md`（KL 散度即相对熵）
- 若涉及信息压缩 → `information-bottleneck.md`（信息瓶颈使用熵和互信息）
- 若涉及熵-功率不等式 → `fisher-information.md`（Fisher 信息与熵的关系）

## 可扩展方向
- Renyi 熵（Renyi entropy）：广义熵的参数族
- Tsallis 熵（Tsallis entropy）：非广延统计力学的熵
- 条件/互信息（conditional / mutual information）：多变量信息度量
- 熵率（entropy rate）：随机过程的渐近熵
- 最大熵原理（maximum entropy principle）：最少假设下的分布选择
- 熵估计（entropy estimation）：从样本估计熵的方法
- 微分熵（differential entropy）：连续分布的熵
- 熵功率不等式（entropy power inequality）：独立和的熵下界
