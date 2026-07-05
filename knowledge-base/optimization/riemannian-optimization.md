# 黎曼优化 (Riemannian Optimization)

## 最小定义

在光滑流形 $\mathcal{M}$（如正交群 $O(n)$、Stiefel 流形、Grassmann 流形、双曲空间）上做优化。核心思想：将欧氏空间的梯度投影到流形的切空间，沿测地线（或收缩映射）更新，保证迭代始终在流形上。

## 核心公式

- 黎曼梯度：$\text{grad} f(x) = \text{proj}_{T_x\mathcal{M}}(\nabla f(x))$（欧氏梯度投影到切空间）
- 黎曼梯度下降：$x_{k+1} = R_{x_k}(-\alpha_k \cdot \text{grad} f(x_k))$，$R$ 为收缩映射（retraction）
- 正交群 $O(n)$ 的切空间：$T_Q O(n) = \{Q\Omega : \Omega^T = -\Omega\}$（反对称矩阵左乘）
- 正交群收缩映射（Cayley）：$R_Q(\xi) = Q(I + \frac{1}{2}\Omega)^{-1}(I - \frac{1}{2}\Omega)$，$\xi = Q\Omega$；等价地用 $A$-形式：设 $G = \nabla f(Q)$ 为欧氏梯度，$A = GQ^T - QG^T$（反对称），则 $R_Q(t) = (I + \frac{t}{2}A)^{-1}(I - \frac{t}{2}A)Q$，步长 $t > 0$ 沿负梯度方向移动（下降方向）
- 极分解收缩：$R_Q(\xi) = (Q + \xi)(I + \xi^T\xi)^{-1/2}$（投影到最近正交矩阵）
- Newton-Schulz 正交化：$X_{k+1} = \frac{1}{2}X_k(3I - X_k^T X_k)$，收敛到最近正交矩阵
- 双曲空间（Poincaré ball）：$\text{grad}_{\mathcal{H}} f = \frac{(1-\|x\|^2)^2}{4} \nabla f(x)$
- Stiefel 流形 $St(n,p) = \{W : W^TW = I_p\}$ 的黎曼梯度：$\text{grad} f(W) = G - W \cdot \text{sym}(W^TG)$，其中 $G = \nabla f(W)$ 为欧氏梯度，$\text{sym}(A) = \frac{A + A^T}{2}$ 为对称修正项。注意：不能简单用 $G - WW^TG$（正交投影），必须包含对称修正才能保证梯度在切空间中。

## 适用问题

- 正交权重约束：$W^TW = I$ 保持特征值模长为 1，稳定 RNN/SSM 训练
- Muon 优化器：将梯度投影到最近正交矩阵作为更新方向（"二阶味"的廉价替代）
- 低秩子空间追踪：Grassmann 流形上的在线 PCA
- 双曲嵌入：层次结构（树、taxonomy）的 Poincaré 嵌入
- 度量学习：SPD 矩阵流形（协方差矩阵空间）上的距离度量

## AI 设计翻译

- **Muon 优化器 (正交化梯度更新)**：将缩放后的动量矩阵 $M$ 通过 Newton-Schulz / polar 迭代近似其正交极因子，例如 $X_{k+1} = \frac{1}{2}X_k(3I - X_k^TX_k)$（需先归一化并满足谱条件）。固定 5 步是工程近似而非无条件收敛保证。更新 $W \leftarrow W - \alpha \cdot U$（$U$ 为正交化结果）。核心是 matmul 链，tensor core 友好，低精度下需缩放和残差监控。
- **谱归一化的流形视角**：约束 $\sigma_{\max}(W) \leq 1$ 的常用做法是按最大奇异值缩放权重，属于重参数化/归一化；它不是 Stiefel 流形切空间投影，也不是到谱范数球的精确最近投影。Power iteration 只用于估计最大奇异方向。
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

- 蒸馏稿：../../references/books/matrix-analysis.md（§7.3 极分解、Newton-Schulz 迭代、§2.6 SVD 与正交因子）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 7 §7.3 (Polar Decomposition) + Absil, Mahony, Sepulchre, *Optimization Algorithms on Matrix Manifolds*, Princeton University Press, 2008


## 路由扩展
- 若需要局部线性化 → `../differential-geometry/tangent-space.md`（切空间上的梯度计算）
- 若需要收缩映射的具体选择 → `../differential-geometry/metric-tensor.md`（度量决定收缩映射）
- 若度量来自 Fisher 信息 → `../information-geometry/natural-gradient.md`（Fisher 度量下的自然梯度）

## 可扩展方向
- 收缩映射类型（retraction types）：指数映射、投影收缩、Cayley 变换
- 向量传输（vector transport）：流形上向量在不同切空间间的传输
- 黎曼共轭梯度（Riemannian conjugate gradient）：流形上的共轭梯度法
- 黎曼信赖域（Riemannian trust region）：流形上的信赖域方法
- 随机黎曼优化（stochastic Riemannian optimization）：流形上的 SGD 变体
