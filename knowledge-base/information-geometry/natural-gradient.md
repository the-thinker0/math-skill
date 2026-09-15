# 自然梯度 / Natural Gradient

## 最小定义
自然梯度是 Fisher 信息度量下的梯度，其**负方向**才是最速下降。可辨识坐标间光滑可逆换元下，该向量场按坐标一致变换。有限 Euler 更新、阻尼及 Fisher 近似通常不再精确重参数化不变；Fisher 描述分布敏感性，不是任意损失 Hessian。

## 核心公式

**朴素梯度下降**（欧氏度量）：
$$\theta_{t+1} = \theta_t - \eta \nabla_\theta \mathcal{L}(\theta)$$

**自然梯度下降**（Fisher 度量）：
$$\tilde{\nabla} \mathcal{L}(\theta) = \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$
$$\theta_{t+1} = \theta_t - \eta \, \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$

其中 $\mathcal{I}(\theta)$ 为 Fisher 信息矩阵（详见 `../probability/fisher-information.md`）。

**等价推导（约束优化视角）**：自然梯度是以下约束优化问题的解——
$$\min_{\Delta\theta} \mathcal{L}(\theta + \Delta\theta) \quad \text{s.t.} \quad D_{KL}(p_\theta \| p_{\theta+\Delta\theta}) \leq \epsilon$$

需**同时**把目标线性化为 $\mathcal L(\theta)+\nabla\mathcal L^T\Delta\theta$，把 KL 二次近似。Fisher 非奇异且梯度非零时，局部信赖域解为 $\Delta\theta=-\sqrt{2\epsilon/(\nabla\mathcal L^T\mathcal I^{-1}\nabla\mathcal L)}\,\mathcal I^{-1}\nabla\mathcal L$。这是局部近似，不是原非线性约束问题的精确解。

**K-FAC 近似**（Kronecker-Factored Approximate Curvature）：
$$\mathcal{I}_l \approx A_l \otimes B_l$$
其中 $A_l = \mathbb{E}[a_l a_l^T]$（激活协方差），$B_l = \mathbb{E}[g_l g_l^T]$（梯度协方差），逐层独立计算和求逆。

## 适用问题
- **病态损失面优化**：当 Hessian 条件数很大（狭长峡谷）时，自然梯度沿峡谷底部方向更新，避免震荡
- **分布参数学习**：变分推断中后验参数的更新，自然梯度自动处理 Fisher-Rao 流形的曲率
- **策略梯度（RL）**：TRPO/PPO 的信任域约束等价于自然梯度的步长限制版本

## AI 设计翻译
- **K-FAC 优化器**：用 Kronecker 分解近似 FIM，实现近似二阶优化。每层维护 $(A_l, B_l)$，逆为 $A_l^{-1} \otimes B_l^{-1}$，矩阵逆复杂度从 $O(d^3)$ 降至 $O(d_A^3 + d_B^3)$
- **TRPO 信任域策略梯度**：$D_{KL}(\pi_{\theta_{\text{old}}} \| \pi_\theta) \leq \delta$ 约束下的策略更新，本质是自然梯度 + 线搜索
- **变分推断中的自然梯度（SVI）**：对指数族全局变分分布的自然参数 $\lambda$，SVI 自然梯度是坐标最优自然参数与当前值之差 $\hat\lambda - \lambda$，其中 $\hat\lambda = \eta_0 + N\,\mathbb{E}_q[T(X)]$（$\eta_0$ 为先验超参数、$N$ 为样本数；勿与前文学习率 $\eta$ 混淆），更新为 $\lambda \leftarrow (1-\rho)\lambda + \rho\,\hat\lambda$（Hoffman et al. 2013），避免显式 Fisher 求逆。差值相对**当前自然参数**取，不是“$\mathbb{E}_q[T]$ 减去先验的期望充分统计量”

## 工程可行性
- **D1[~]**：FIM 的 Kronecker 因子为稠密矩阵，可张量化；完整 FIM 不可
- **D2[~]**：$W\in\mathbb R^{b\times a}$、激活因子 $A\in\mathbb R^{a\times a}$、输出score因子 $B\in\mathbb R^{b\times b}$，采用列向量化时，$(A\otimes B)^{-1}\operatorname{vec}(G)=\operatorname{vec}(B^{-1}GA^{-1})$。因子顺序须匹配权重维度。
- **D3[~]**：$B$ 个激活/score 样本下，因子估计为 $O(B(d_A^2+d_B^2))$、稠密求逆 $O(d_A^3+d_B^3)$，梯度预条件另有 GEMM 成本。记录刷新频率与摊销。
- **D4[~]**：逐层存 $O(d_A^2+d_B^2)$ 因子，另加逆、阻尼状态及工作区。LLM 可行性依赖架构/设备；部分层可能需对角或低秩近似。
- **D5[~]**：矩阵求逆在 fp16 下可能不稳定，需 fp32 或 Tikhonov 正则化 $(A + \epsilon I)^{-1}$
- **D6[v]**：各层 Kronecker 因子独立计算，层间完全并行
- **D8[v]**：自然梯度更新可融入参数更新 kernel

## 风险与失效条件
- **K-FAC 的层间独立性假设过强**：假设各层 Fisher 信息块对角，忽略层间相关性。在深网络中可能低估有效曲率，导致步长过大。需搭配线搜索或 trust-region 安全机制。
- **协方差估计的 burn-in 问题**：训练初期 $A_l, B_l$ 估计不准确，自然梯度方向可能错误。标准做法是前几百步用 Adam/SGD warmup，再切换到 K-FAC。

## 深入参考
- 蒸馏稿：`../../references/books/` 暂无专用信息几何蒸馏稿
- Amari. *Natural Gradient Works Efficiently in Learning.* Neural Computation, 1998
- Martens & Grosse. "Optimizing Neural Networks with Kronecker-Factored Approximate Curvature." *ICML*, 2015
- Schulman et al. "Trust Region Policy Optimization." *ICML*, 2015
- 关联知识卡：`../probability/fisher-information.md`、`fisher-metric.md`


## 路由扩展
- 若需要度量的定义 → `fisher-metric.md`（Fisher 度量是自然梯度的基础）
- 若需要一般黎曼优化框架 → `../optimization/riemannian-optimization.md`（自然梯度是黎曼梯度的特例）
- 若需要信息论视角 → `../probability/fisher-information.md`（Fisher 信息的统计解释）

## 可扩展方向
- 镜像下降即自然梯度（mirror descent as natural gradient）：对偶空间上的等价性
- Amari 的 alpha-几何（Amari's alpha-geometry）：alpha-联络族
- 自然策略梯度（natural policy gradient / RL）：强化学习中的自然梯度
- 自然进化策略（natural evolution strategies）：NES 优化器
- 实用自然梯度（practical natural gradient）：K-FAC, 对角近似等高效实现
- 自适应自然梯度（adaptive natural gradient）：动态估计 Fisher 信息的方法
