# Fisher 信息 / Fisher Information

## 最小定义
Fisher 信息度量**概率分布族对参数的敏感度**——即观测数据对参数 $\theta$ 提供了多少信息。它在统计流形上定义了一个自然的黎曼度量（Fisher 信息矩阵 = 度量张量），是信息几何的基石。

## 核心公式

**Fisher 信息（标量参数）**：
$$\mathcal{I}(\theta) = \mathbb{E}_\theta\left[\left(\frac{\partial}{\partial \theta} \log p(X|\theta)\right)^2\right] = -\mathbb{E}_\theta\left[\frac{\partial^2}{\partial \theta^2} \log p(X|\theta)\right]$$

**Fisher 信息矩阵（向量参数）**：
$$[\mathcal{I}(\theta)]_{ij} = \mathbb{E}_\theta\left[\frac{\partial \log p(X|\theta)}{\partial \theta_i} \frac{\partial \log p(X|\theta)}{\partial \theta_j}\right] = -\mathbb{E}_\theta\left[\frac{\partial^2 \log p(X|\theta)}{\partial \theta_i \partial \theta_j}\right]$$

**Cramér-Rao 下界**（无偏估计的方差下界）：
$$\text{Var}(\hat{\theta}) \geq \frac{1}{\mathcal{I}(\theta)}$$

**与 KL 散度的关系**（Fisher 信息 = KL 散度的二阶展开系数）：
$$D_{KL}(p_\theta \| p_{\theta + d\theta}) \approx \frac{1}{2} d\theta^T \mathcal{I}(\theta) d\theta$$

## 适用问题
- **参数估计效率评估**：Cramér-Rao 界给出任何无偏估计器精度的理论极限
- **自然梯度下降**：用 $\mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}$ 替代朴素梯度，沿统计流形的测地线方向更新（详见 `../information-geometry/natural-gradient.md`）
- **实验设计 / 主动学习**：选择使 Fisher 信息最大的数据点采集，最大化参数学习的信息增益

## AI 设计翻译
- **自然梯度 / K-FAC 优化器**：用 Fisher 信息矩阵的 Kronecker 近似 $\mathcal{I} \approx A \otimes B$ 替代 Hessian，实现近似二阶优化
- **弹性权重巩固 EWC**：$\mathcal{L}_{\text{EWC}} = \mathcal{L}_{\text{new}} + \frac{\lambda}{2} \sum_i \mathcal{I}_i (\theta_i - \theta_i^*)^2$，用 Fisher 信息衡量每个参数对旧任务的重要性，防止灾难性遗忘
- **预训练-微调的敏感度分析**：Fisher 信息大的参数方向 = 对数据敏感的参数，微调时应更谨慎

## 工程可行性
- **D1[~]**：完整 FIM 是 $d \times d$ 矩阵（$d$ = 参数量），直接物化不可行（LLM 参数量 $10^{10}+$）。必须用近似。
- **D2[v]**：K-FAC 用 Kronecker 因子 $A \otimes B$，$A$ 和 $B$ 各自可用 GEMM 计算和求逆
- **D3[~]**：精确 FIM 计算 $O(nd^2)$，K-FAC 降至 $O(d)$ 量级但需逐层维护
- **D4[~]**：K-FAC 的 Kronecker 因子需额外显存，但相比完整 FIM 已大幅压缩
- **D5[v]**：FIM 估计用 fp32 即可，不需 fp64
- **D6[v]**：K-FAC 的 Kronecker 因子天然按层分解，可并行计算
- **D8[v]**：EWC 惩罚项为逐元素运算，可融入参数更新 kernel

## 风险与失效条件
- **完整 FIM 不可计算**：对于 LLM 级别的参数规模（$d > 10^9$），即使 K-FAC 的 Kronecker 近似也可能代价过高。实践中常用对角 Fisher（$O(d)$）或低秩近似。
- **经验 Fisher ≠ 真实 Fisher**：用训练集均值替代期望，在样本量不足时估计偏差大，自然梯度方向可能指向错误方向。需与 learning rate warmup 配合。

## 深入参考
- 蒸馏稿：`../../references/books/` 暂无专用信息几何蒸馏稿
- Amari. *Information Geometry and Its Applications*. Springer, 2016
- Amari & Nagaoka. *Methods of Information Geometry*. AMS, 2000
- Martens. "Optimizing Neural Networks with Kronecker-Factored Approximate Curvature." *ICML*, 2015
- 关联知识卡：`../information-geometry/natural-gradient.md`、`../information-geometry/fisher-metric.md`


## 路由扩展
- 若需要几何视角 → `../information-geometry/fisher-metric.md`（Fisher 信息作为黎曼度量）
- 若需要基于 Fisher 的优化 → `../information-geometry/natural-gradient.md`（Fisher 信息驱动的自然梯度）
- 若需要 Cramer-Rao 界 → `concentration-inequality.md`（Fisher 信息与估计精度界）

## 可扩展方向
- 观测 vs 期望 Fisher（observed vs expected Fisher）：两种 Fisher 信息矩阵
- Fisher 信息矩阵性质：正定性、链式法则、充分统计量
- Jeffreys 先验（Jeffreys prior）：Fisher 信息定义的无信息先验
- Fisher 信息距离（Fisher information distance）：分布间的 Fisher 度量距离
- 互信息与 Fisher（mutual information and Fisher）：Fisher 信息与互信息的关系
- 深度学习中的 Fisher（Fisher in deep learning）：K-FAC, Shampoo 等近似方法
