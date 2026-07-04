# 黎曼优化 (Riemannian Optimization)

## 最小定义

在光滑流形 $\mathcal{M}$（如正交群 $O(n)$、Stiefel 流形、Grassmann 流形、双曲空间）上做优化。核心思想：将欧氏空间的梯度投影到流形的切空间，沿测地线（或收缩映射）更新，保证迭代始终在流形上。

## 核心公式

- 黎曼梯度：$\text{grad} f(x) = \text{proj}_{T_x\mathcal{M}}(\nabla f(x))$（欧氏梯度投影到切空间）
- 黎曼梯度下降：$x_{k+1} = R_{x_k}(-\alpha_k \cdot \text{grad} f(x_k))$，$R$ 为收缩映射（retraction）
- 正交群 $O(n)$ 的切空间：$T_Q O(n) = \{Q\Omega : \Omega^T = -\Omega\}$（反对称矩阵左乘）
- 正交群收缩映射（Cayley）：$R_Q(\xi) = Q(I + \frac{1}{2}\Omega)^{-1}(I - \frac{1}{2}\Omega)$，$\xi = Q\Omega$
- 极分解收缩：$R_Q(\xi) = (Q + \xi)(I + \xi^T\xi)^{-1/2}$（投影到最近正交矩阵）
- Newton-Schulz 正交化：$X_{k+1} = \frac{1}{2}X_k(3I - X_k^T X_k)$，收敛到最近正交矩阵
- 双曲空间（Poincaré ball）：$\text{grad}_{\mathcal{H}} f = \frac{(1-\|x\|^2)^2}{4} \nabla f(x)$

## 适用问题

- 正交权重约束：$W^TW = I$ 保持特征值模长为 1，稳定 RNN/SSM 训练
- Muon 优化器：将梯度投影到最近正交矩阵作为更新方向（"二阶味"的廉价替代）
- 低秩子空间追踪：Grassmann 流形上的在线 PCA
- 双曲嵌入：层次结构（树、taxonomy）的 Poincaré 嵌入
- 度量学习：SPD 矩阵流形（协方差矩阵空间）上的距离度量

## AI 设计翻译

- **Muon 优化器 (正交化梯度更新)**：将动量矩阵 $M$ 通过 Newton-Schulz 迭代投影到最近正交矩阵：$X_{k+1} = \frac{1}{2}X_k(3I - X_k^TX_k)$，5 步收敛。更新 $W \leftarrow W - \alpha \cdot U$（$U$ 为正交化结果）。核心是纯 matmul 链，每步 2 次 matmul，完全 tensor core 友好，bf16 稳定。
- **谱归一化的流形视角**：约束 $\sigma_{\max}(W) = 1$ 等价于在 Stiefel 流形的某个切方向上做投影。Power iteration 估计方向 + 归一化 = 一种近似的黎曼梯度投影。实现同标准 spectral norm。
- **正交 RNN (orthogonal RNN)**：隐藏状态递推 $h_t = \sigma(W h_{t-1} + U x_t)$，约束 $W \in O(n)$ 避免梯度消失/爆炸。训练时用 Cayley 参数化 $W = (I-A)(I+A)^{-1}$（$A$ 反对称），反向传播走 $A$ 的无约束梯度。核心是矩阵求逆 $O(n^3)$（层维度小，可接受）。
- **Poincaré 嵌入 (双曲空间)**：将层次数据嵌入 Poincaré ball $\mathcal{B}^n = \{x : \|x\| < 1\}$。距离 $d(x,y) = \text{arcosh}(1 + 2\|x-y\|^2 / ((1-\|x\|^2)(1-\|y\|^2)))$。梯度乘以度量因子 $(1-\|x\|^2)^2/4$ 即可。实现为 elementwise 缩放，$O(d)$。
- **Grassmann 流形上的子空间学习**：将低秩子空间视为 Grassmann 流形上的点，用黎曼 SGD 在线更新。比 SVD 更适合 streaming 数据。投影 $P = QQ^T$ 的更新通过 QR 分解实现，核心是 matmul + thin QR。

## 工程可行性

- **主要操作**：黎曼梯度投影 = matmul（$Q^T \nabla$ 得切空间分量）；收缩映射 = matmul + 小矩阵求逆 / Newton-Schulz（纯 matmul）；双曲度量 = elementwise。
- **GPU 友好度**：高（Newton-Schulz 正交化 = 纯 matmul 链）到中等（Cayley 映射需 $n \times n$ 矩阵求逆，$n$ 为层维度，$n \leq 1024$ 时 cuSOLVER 可行）。双曲嵌入的度量缩放是纯 elementwise。
- **复杂度**：Newton-Schulz 每步 $O(n^3)$（但 $n$ 为层维度，非模型总参数量）；Cayley $O(n^3)$；双曲梯度 $O(d)$；Grassmann QR $O(nd^2)$。
- **低精度**：Newton-Schulz 在 bf16 下稳定（纯 matmul 迭代，不涉及除法/开方）；Cayley 映射的求逆在 bf16 下可能失败（需 fp32）；双曲度量在 $\|x\| \to 1$ 时分母趋零，需 clamp 防溢出。

## 风险与失效条件

- **Cayley / 矩阵指数映射的求逆开销**：每步 $O(n^3)$ 矩阵求逆，层维度 $> 4096$ 时成为瓶颈。解决：改用 Newton-Schulz 正交化（纯 matmul）或 polar decomposition 的近似收缩。
- **双曲空间的数值溢出**：$\|x\| \to 1$ 时 $d(x,y) \to \infty$，度量因子 $(1-\|x\|^2)^{-2} \to \infty$，梯度爆炸。解决：clamp $\|x\| \leq 1 - \epsilon$（$\epsilon \sim 10^{-5}$），或用 Lorentz 模型（数值更稳定的双曲参数化）。
- **收缩映射 vs. 指数映射**：收缩映射（retraction）是指数映射的一阶近似，大步长时精度下降。对学习率敏感的优化问题，可能需要真正的指数映射（更贵）。
- **非紧凑流形的无界性**：SPD 流形 / 双曲空间非紧，优化路径可能跑到无穷远。需加正则化或信赖域约束。
- **正交约束与 BatchNorm 冲突**：BatchNorm 的仿射变换破坏正交性。需在正交约束层后禁用 BN 的 scale/shift，或改用 GroupNorm。

## 深入参考

- 蒸馏稿：references/books/matrix-analysis.md（§7.3 极分解、Newton-Schulz 迭代、§2.6 SVD 与正交因子）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 7 §7.3 (Polar Decomposition) + Absil, Mahony, Sepulchre, *Optimization Algorithms on Matrix Manifolds*, Princeton University Press, 2008
