# 近端方法 (Proximal Methods)

## 最小定义

对不可微或非光滑目标函数 $f(x) = g(x) + h(x)$（$g$ 光滑、$h$ 可能不可微但"简单"），用近端算子 $\text{prox}_{\eta h}(v) = \arg\min_x \{h(x) + \frac{1}{2\eta}\|x - v\|^2\}$ 代替对 $h$ 的梯度。近端方法将不可微部分封装为一个闭式子问题。

## 核心公式

- 近端算子：$\text{prox}_{\eta h}(v) = \arg\min_x \left\{h(x) + \frac{1}{2\eta}\|x - v\|^2\right\}$
- 近端梯度下降 (ISTA)：$x_{k+1} = \text{prox}_{\eta h}(x_k - \eta \nabla g(x_k))$
- 加速近端梯度 (FISTA)：$y_k = x_k + \frac{k-1}{k+2}(x_k - x_{k-1})$，$x_{k+1} = \text{prox}_{\eta h}(y_k - \eta \nabla g(y_k))$，收敛率 $O(1/k^2)$ vs. ISTA 的 $O(1/k)$
- Soft-thresholding（$\ell_1$ 近端）：$\text{prox}_{\eta\|\cdot\|_1}(v)_i = \text{sign}(v_i)\max(|v_i| - \eta, 0)$
- 投影（指示函数近端）：$\text{prox}_{\eta \delta_\mathcal{C}}(v) = \text{proj}_\mathcal{C}(v)$
- 核范数近端（奇异值软阈值）：$\text{prox}_{\eta\|\cdot\|_*}(A) = U(\Sigma - \eta I)_+ V^H$
- Moreau envelope：$h_\eta(v) = \min_x \{h(x) + \frac{1}{2\eta}\|x-v\|^2\}$（$h$ 的光滑近似）
- ADMM 分裂：$\min f(x) + g(z)$ s.t. $Ax + Bz = c$，交替更新 $x, z, u$（对偶变量）

## 适用问题

- 稀疏训练 / $\ell_1$ 正则化：权重稀疏化、特征选择
- 低秩矩阵恢复：核范数正则化（矩阵补全、鲁棒 PCA）
- 分组稀疏 / Group Lasso：$\sum_g \|w_g\|_2$ 正则化（结构化剪枝）
- 约束优化的算子分裂：ADMM 将复杂约束分解为简单子问题
- 量化感知训练：将权重量化建模为近端算子（round + straight-through gradient）

## AI 设计翻译

- **Soft-thresholding 做稀疏训练**：$\text{prox}_{\eta\lambda\|\cdot\|_1}(w) = \text{sign}(w) \odot \max(|w| - \eta\lambda, 0)$，实现为 `w.sign() * (w.abs() - eta * lam).clamp(min=0)`，纯 elementwise，$O(d)$，零额外显存。每次 SGD 更新后做一次 soft-thresholding 即可得到稀疏权重。
- **奇异值软阈值做低秩正则**：$\text{prox}_{\eta\|\cdot\|_*}(W) = U(\Sigma - \eta)_+ V^H$。需 SVD，大矩阵用随机化 SVD 近似：先做 randomized SVD 到 rank $r$，再对 $\Sigma$ 做 elementwise soft-threshold，重构。核心是 matmul 链 + elementwise。
- **Group Lasso 结构化剪枝**：$\text{prox}_{\eta\sum_g\|w_g\|_2}(w)_g = w_g \cdot \max(1 - \eta/\|w_g\|_2, 0)$。按通道/头分组后，每组独立做 soft-thresholding（norm + elementwise scale），$O(d)$。实现为 reshape + norm(dim) + clamp + mul。
- **ADMM 做分布式训练**：$\min \sum_i f_i(x_i) + g(z)$ s.t. $x_i = z$。各节点独立更新 $x_i$（本地 SGD），server 更新 $z = \text{prox}_{g/\rho}(\bar{x} + u)$（聚合 + 近端），$u$ 对偶变量更新。通信效率高于 all-reduce（只需传 $x_i$ 和 $z$）。
- **量化近端算子**：将权重量化建模为 $\text{prox}(w) = \Delta \cdot \text{round}(w/\Delta)$，反向传播用 straight-through estimator（STE）：$\partial \text{prox}/\partial w \approx 1$。实现为 `w_q = (w / delta).round() * delta`，forward 是 elementwise round + mul，backward 是 identity。

## 工程可行性

- **主要操作**：近端算子多为 elementwise（soft-thresholding、clamp、group norm）或 matmul + 小 SVD（核范数）。梯度步 = 标准反向传播。
- **GPU 友好度**：极高。$\ell_1$ 近端 = elementwise；group lasso 近端 = reshape + norm + scale = elementwise；核范数近端 = matmul + 小 SVD。FISTA 的动量项也是 elementwise。ADMM 的通信模式适配数据并行。
- **复杂度**：ISTA/FISTA 每步 = 一次梯度计算 + 一次近端算子（$O(d)$ elementwise）；核范数近端 = $O(nd^2)$（随机化 SVD 降到 $O(ndk)$）；ADMM 每节点 = 本地 SGD + $O(d)$ 通信。
- **低精度**：elementwise 近端算子在 bf16 下稳定（不涉及精细数值运算）。SVD 类近端需在 fp32 下计算。FISTA 的动量累积在 bf16 下可能丢精度，建议用 fp32 存储 $y_k$。

## 风险与失效条件

- **核范数近端的 SVD 开销**：大矩阵每步完整 SVD 是 $O(n^3)$，不可行。解决：(1) 随机化 SVD 近似；(2) 因子化 $\|W\|_* = \min_{W=UV^T} \frac{1}{2}(\|U\|_F^2 + \|V\|_F^2)$ 转为对 $U, V$ 的光滑优化，无需 SVD。
- **FISTA 的重启问题**：FISTA 的 $y_k$ 序列可能振荡（非单调），导致实际收敛慢于理论。解决：adaptive restart（当 $f(x_{k+1}) > f(x_k)$ 时重置动量 $t_k = 1$），实现为简单的 if 判断。
- **ADMM 的 $\rho$ 参数敏感**：$\rho$ 过大导致子问题病态，$\rho$ 过小导致对偶收敛慢。解决：adaptive $\rho$（根据 primal/dual residual 比值自动调整），每若干步 $\rho \leftarrow \rho \cdot \tau$（$\tau > 1$ 若 primal residual $>$ dual residual）。
- **近端算子无闭式解**：并非所有 $h(x)$ 都有闭式 prox。复杂正则项（如 TV 正则、重叠 group lasso）需内层迭代求解。解决：用 Dykstra 算法分裂为多个简单 prox 的组合，或改用 ADMM 分裂。
- **Straight-Through Estimator 的偏差**：量化 prox 的 STE 梯度有偏（$\partial \text{round}/\partial w = 0$ 几乎处处），长期训练可能发散。解决：用 learnable scale factor 补偿，或加噪声的量化（stochastic rounding）。

## 深入参考

- 蒸馏稿：../../references/books/optimization-ml.md（Ch 8 梯度法 §8.3 收敛分析、Ch 11 拟牛顿 §11.5 BFGS、Ch 24 约束算法 §24.5 增广 Lagrange）
- 原书：Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 24 (Constrained Algorithms §24.5 Augmented Lagrangian) + Parikh & Boyd, *Proximal Algorithms*, Foundations and Trends in Optimization, 2014


## 路由扩展
- 若可微部分主导 → `convex-optimization.md`（光滑部分的凸优化方法）
- 若近端算子对应约束 → `constrained-optimization.md`（指示函数与约束的等价）
- 若用于变分损失的正则化 → `variational-loss`（设计模式层的近端正则化）

## 可扩展方向
- 近端梯度（ISTA / FISTA）：L1 正则化的快速近端方法
- Douglas-Rachford 分裂：两个非光滑函数之和的优化
- 原始-对偶混合梯度（PDHG）：鞍点问题的一阶方法
- 交替最小化（alternating minimization）：块可分目标的分块优化
- 块坐标下降（block coordinate descent）：高维问题的分块更新策略
- 近端神经网络（proximal neural networks）：将近端算子嵌入网络结构
