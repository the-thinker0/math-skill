# 自然梯度 / Natural Gradient

## 最小定义
自然梯度是参数空间上关于**Fisher 信息度量**的最速下降方向。与朴素梯度在欧氏度量下定义不同，自然梯度在统计流形的黎曼度量下定义，因此在重参数化下协变（reparameterization covariant：方向作为几何对象不随坐标选择改变），且能自动适应损失面的曲率结构。

## 核心公式

**朴素梯度下降**（欧氏度量）：
$$\theta_{t+1} = \theta_t - \eta \nabla_\theta \mathcal{L}(\theta)$$

**自然梯度下降**（Fisher 度量）：
$$\tilde{\nabla} \mathcal{L}(\theta) = \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$
$$\theta_{t+1} = \theta_t - \eta \, \mathcal{I}(\theta)^{-1} \nabla_\theta \mathcal{L}(\theta)$$

其中 $\mathcal{I}(\theta)$ 为 Fisher 信息矩阵（详见 `../probability/fisher-information.md`）。

**等价推导（约束优化视角）**：自然梯度是以下约束优化问题的解——
$$\min_{\Delta\theta} \mathcal{L}(\theta + \Delta\theta) \quad \text{s.t.} \quad D_{KL}(p_\theta \| p_{\theta+\Delta\theta}) \leq \epsilon$$

用二阶展开 $D_{KL} \approx \frac{1}{2} \Delta\theta^T \mathcal{I} \Delta\theta$，拉格朗日求解即得自然梯度。

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
- **D2[v]**：K-FAC 的 $A_l^{-1} (\nabla W_l) B_l^{-1}$ 是两次矩阵乘，天然 GEMM
- **D3[~]**：K-FAC 每层额外 $O(d_A^2 + d_B^2)$ 协方差估计 + $O(d_A^3 + d_B^3)$ 矩阵逆；对角近似 $O(d)$
- **D4[~]**：需额外存储每层的 $A_l$ 和 $B_l$（$O(d_A^2 + d_B^2)$），对 LLM 可接受但非零
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
