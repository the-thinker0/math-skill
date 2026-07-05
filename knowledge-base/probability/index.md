# 概率与信息 激活索引 / Probability & Information Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 不确定性量化：需要量化随机变量的集中程度或尾部行为
- 泛化界：需要推导模型泛化的理论上界
- 分布距离：需要度量两个分布之间的差异
- 信息压缩：需要在保持信息的前提下压缩表示
- 样本效率：需要分析从有限样本中学习的能力
- 尾部控制：需要控制随机变量的极端偏差概率

## 核心锚点
- `concentration-inequality.md` — 集中不等式
- `entropy.md` — 熵
- `kl-divergence.md` — KL 散度
- `information-bottleneck.md` — 信息瓶颈
- `fisher-information.md` — Fisher 信息

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- optimal transport（Wasserstein distance, Sinkhorn）：最优传输与 Wasserstein 距离
- total variation distance：全变差距离
- f-divergence family：f-散度族（chi-squared, Hellinger, Jensen-Shannon 等）
- mutual information estimation（MINE / NWJ）：互信息的神经估计方法
- variational inference（ELBO / VI）：变分推断与证据下界
- Markov chain Monte Carlo：马尔可夫链蒙特卡罗方法
- stochastic process（martingale, Brownian motion, SDE）：随机过程基础
- PAC-Bayes bounds：PAC-Bayes 泛化界
- Rademacher complexity：Rademacher 复杂度
- VC dimension：VC 维与假设空间容量
- generalization via compression：基于压缩的泛化理论
- differential privacy：差分隐私
- normalizing flow theory：规范化流理论
- score matching：得分匹配
- diffusion process theory：扩散过程理论

## 参考书方向
- `../../references/books/optimization-ml.md`：变分方法和概率推断相关章节

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
