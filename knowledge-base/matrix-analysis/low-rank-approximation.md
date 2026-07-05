# 低秩逼近 (Low-Rank Approximation)

## 最小定义

给定矩阵 $A \in \mathbb{R}^{m \times n}$，寻找秩不超过 $k$ 的矩阵 $B$ 使得 $\|A - B\|$ 最小。Eckart-Young-Mirsky 定理保证截断 SVD 给出 Frobenius 范数和谱范数下的唯一最优解：$B_k = \sum_{i=1}^k \sigma_i u_i v_i^H$。

## 核心公式

- SVD：$A = U\Sigma V^H = \sum_{i=1}^r \sigma_i u_i v_i^H$，$\sigma_1 \geq \sigma_2 \geq \cdots \geq \sigma_r > 0$
- 截断 SVD（最优秩-$k$ 逼近）：$A_k = U_k \Sigma_k V_k^H$
- Eckart-Young 误差：$\|A - A_k\|_F = \sqrt{\sum_{i=k+1}^r \sigma_i^2}$，$\|A - A_k\|_2 = \sigma_{k+1}$
- 随机化 SVD：$A \approx Q(Q^HA)$，$Q$ 为 $A\Omega$（$\Omega$ 随机高斯）的 QR 分解之 $Q$ 因子
- 有效秩：$r_{\text{eff}}(A) = \|A\|_F^2 / \|A\|_2^2 = \sum \sigma_i^2 / \sigma_1^2$
- 核范数（秩的凸松弛）：$\|A\|_* = \sum \sigma_i$，是谱范数的对偶

## 适用问题

- LoRA 权重压缩：$W \approx W_0 + BA$，$B \in \mathbb{R}^{d \times r}, A \in \mathbb{R}^{r \times d}$，$r \ll d$
- KV-Cache 压缩：将 Key/Value 缓存投影到低维子空间，显存 $O(n) \to O(k)$
- PCA / 白化：数据协方差的前 $k$ 个主成分即截断 SVD
- 梯度压缩：大模型梯度矩阵的有效秩通常远低于名义秩，可安全截断
- 推荐系统 / 矩阵补全：低秩因子分解 $R \approx UV^H$

## AI 设计翻译

- **LoRA (Low-Rank Adaptation)**：冻结 $W_0$，训练 $\Delta W = BA$（$r \ll d$），推理时合并 $W = W_0 + BA$。前向传播 = 两次 matmul（$x \to Ax \to BAx$），训练参数量从 $O(d^2)$ 降到 $O(dr)$。用 `torch.mm(B, torch.mm(A, x))` 或合并为单次 matmul。
- **随机化 SVD 算子**：对大矩阵 $A \in \mathbb{R}^{m \times n}$，先采样 $Y = A\Omega$（$\Omega \in \mathbb{R}^{n \times (k+p)}$ 随机高斯），QR 分解 $Y = QR$，再算 $B = Q^HA$（小矩阵 $O(k \times n)$），对 $B$ 做 SVD。总复杂度 $O(mnk)$ 而非 $O(mn^2)$，核心操作全是 matmul。
- **KV-Cache 低秩化**：维护 $K$ 的低秩因子形式 $K \approx U_k \Sigma_k V_k^H$（存储 $U_k \in \mathbb{R}^{L \times k}$ 和 $\Sigma_k V_k^H \in \mathbb{R}^{k \times d}$，共 $O(Lk + kd)$ 而非 $O(Ld)$）。每新到 token 做增量 PCA 或 streaming SVD 更新。**注意**：对标准 softmax attention，需先重构 $K_k = U_k (\Sigma_k V_k^H) \in \mathbb{R}^{L \times d}$，序列维度仍为 $L$（省显存不省计算）。仅在线性注意力（核特征映射 $\phi$）下，可利用因子形式计算 $\phi(Q)(\phi(K_k)^T V_k)$ 将序列维度从 $L$ 降至 $k$，同时省显存和计算。
- **核范数正则化**：$\mathcal{L} = \mathcal{L}_{\text{task}} + \lambda \|W\|_*$ 促进低秩解。但核范数计算需完整 SVD（$O(n^3)$），替代方案：(1) 用截断 SVD 近似；(2) 因子化 $\|W\|_* = \min_{W=UV^H} \frac{1}{2}(\|U\|_F^2 + \|V\|_F^2)$ 转为对 $U, V$ 的 Frobenius 正则。
- **梯度低秩压缩 (分布式训练)**：将梯度 $G$ 截断为 $G_k$（top-$k$ SVD）后 all-reduce 通信量从 $O(d)$ 降到 $O(kd)$。用随机化 SVD 在每卡本地算，再合并。

## 工程可行性

- **主要操作**：matmul + 小矩阵 SVD。LoRA 前向 = 两次 matmul；随机化 SVD = 三次 matmul + 一次小 QR；截断 SVD = 完整 SVD 的 $O(k/n)$ 倍（用 Lanczos）。
- **GPU 友好度**：极高。LoRA 前向/反向全是 tensor core matmul；随机化 SVD 的主要开销也是 matmul。小矩阵 SVD 有 cuSOLVER 的 batched 实现。
- **复杂度**：LoRA 前向 $O(dk)$ per sample vs. $O(d^2)$ 全秩；随机化 SVD $O(mnk)$；完整 SVD $O(\min(m^2n, mn^2))$。
- **显存**：LoRA 存储 $O(dr)$ vs. $O(d^2)$；KV-Cache 低秩化 $O(Lk)$ vs. $O(Ld)$。

## 风险与失效条件

- **秩选择错误**：$k$ 过小导致信息丢失（$\sigma_{k+1}$ 不可忽略），$k$ 过大失去压缩意义。解决：监控奇异值衰减曲线，选 $\sum_{i>k}\sigma_i^2 / \sum\sigma_i^2 < \epsilon$ 的拐点。
- **随机化 SVD 精度不足**：oversampling $p$ 太小（通常 $p = 5 \sim 10$）或 power iteration 次数不足时，低阶奇异值估计偏差大。解决：增加 $q = 1 \sim 2$ 步 power iteration $Y = (AA^H)^q A\Omega$，但增加 matmul 次数。
- **LoRA 不适用于所有层**：Attention 的 Q/K/V 通常低秩有效，但 FFN 层和 embedding 的有效秩可能接近满秩，强行 LoRA 会损失精度。需逐层诊断有效秩。
- **核范数 proximal 的 SVD 开销**：soft-thresholding $\text{prox}_{\lambda\|\cdot\|_*}(A) = U(\Sigma - \lambda I)_+ V^H$ 需要 SVD，大矩阵每步算不起。解决：用因子化替代或随机化近似。

## 深入参考

- 蒸馏稿：../../references/books/matrix-analysis.md（§2.6 SVD、§7.4 极分解与 SVD、核范数-谱范数对偶 §5.5）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 2 §2.6 (SVD) + Chapter 7 §7.3-7.4 (Polar Decomposition & SVD)


## 路由扩展
- 若需要子空间投影的具体实现 → `projection.md`（投影算子）
- 若需要分解工具的详细分析 → `spectral-decomposition.md`（SVD/EVD）
- 若目标是信息保持压缩 → `information-bottleneck.md`（信息瓶颈理论）

## 可扩展方向
- 张量分解（CP / Tucker / TT）：高阶张量的低秩分解
- 结构化低秩（Toeplitz / Hankel）：保持结构的低秩近似
- 在线/流式低秩（online / streaming low-rank）：增量更新的低秩估计
- 矩阵补全（matrix completion）：从部分观测恢复低秩矩阵
- 鲁棒 PCA（robust PCA）：低秩+稀疏分解
