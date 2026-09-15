# 谱分解 (Spectral Decomposition)

## 最小定义

将矩阵分解为特征值-特征向量对的线性组合。对 Hermitian 矩阵 $A$，存在酉矩阵 $U$ 使得 $A = U \Lambda U^H$，其中 $\Lambda = \text{diag}(\lambda_1, \ldots, \lambda_n)$ 为实特征值。对一般矩阵，用 Schur 分解 $A = QTQ^H$（$T$ 为上三角）作为数值可靠的替代。

## 核心公式

- Hermitian 谱分解：$A = \sum_{i=1}^{n} \lambda_i u_i u_i^H = U\Lambda U^H$
- 谱映射：$f(A) = U f(\Lambda) U^H$（矩阵指数、对数、幂次等）
- 谱半径：$\rho(A) = \max_i |\lambda_i|$
- 正规矩阵判据：$A^HA = AA^H \iff A$ 可酉对角化
- Schur 分解（一般矩阵）：$A = QTQ^H$，$T$ 上三角，对角元 = 特征值
- 迹-特征值关系：$\text{tr}(A) = \sum \lambda_i$，$\det(A) = \prod \lambda_i$

## 适用问题

- Hessian 分析：二阶可微损失的驻点处，正定 Hessian 蕴含严格局部极小，不定 Hessian 蕴含鞍点；只有负特征值也可能是局部极大。
- 梯度协方差谱诊断各向异性；稳定性需从实际更新算子、步长及噪声模型分析。
- 谱归一化：约束 $\sigma_{\max}(W) \leq 1$ 稳定 GAN/扩散模型训练
- 状态空间模型 (SSM) 稳定性：离散化矩阵谱半径 $< 1$ 保证不发散
- 图神经网络：Laplacian 谱分解 = 图上的 Fourier 基

## AI 设计翻译

- **幂迭代**：$u\leftarrow Au/\|Au\|$ 只在主特征值模严格占优且初始化有非零重叠等条件下估计主特征向量。估计 $\sigma_{\max}(W)$ 应交替 $u\leftarrow Wv/\|Wv\|$、$v\leftarrow W^Tu/\|W^Tu\|$，再取 $u^TWv$；不要与非正规矩阵的谱半径混淆。
- **Hessian 向量积**：用嵌套自动微分计算 HVP，不物化 Hessian。标准 CG 要求对称正定算子；使用带阻尼的适当 PSD 曲率近似，或显式处理负曲率的求解器/信赖域方法。
- **K-FAC**：用 $A\otimes B$ 近似逐层 Fisher（或明确指定的广义 Gauss–Newton）块。稠密 $d\times d$ 因子求逆为 $O(d^3)$、存储 $O(d^2)$，常跨多步摊销；它不是任意 Hessian 的分解。[K-FAC 原论文](https://arxiv.org/abs/1503.05671)。
- **谱正则化 Loss**：$\mathcal{L}_{\text{spec}} = \max(0, \rho(A) - 1)^2$ 或 $\mathcal{L}_{\text{spec}} = \|\sigma_{\max}(W) - 1\|^2$，通过 power iteration 估计后加入总 loss。实现为附加标量 loss，不影响主计算图结构。
- **Graph Fourier Transform**：图 Laplacian $L = D - A$ 的特征分解 $L = U\Lambda U^H$ 给出图频域基。GCN 的谱卷积 = $U g(\Lambda) U^H x$，三次 matmul。大规模图用 Chebyshev 多项式近似避免显式分解。

## 工程可行性

- **主要操作**：完整 EVD 为 $O(n^3)$ 时间、$O(n^2)$ 存储；稠密幂迭代每步 $O(n^2)$。K-FAC 因子构造、立方级因子求解及刷新频率分别计入成本。
- **GPU 可行性**：matvec 与分解均有 GPU 实现，但吞吐取决于矩阵尺寸、批处理、精度及设备；按所需谱范围测量，不设完整 EVD 的通用不可行维数阈值。
- **低精度**：Weyl 界控制 Hermitian 输入扰动引起的特征值绝对误差，不保证近零特征值相对误差、特征向量稳定或求解器支持低精度。Gram/Hessian 累加与敏感分解使用 fp32/fp64，检查残差及谱间隙。

## 风险与失效条件

- **非正规矩阵陷阱**：$A^HA \neq AA^H$ 时特征值不预测瞬态行为（pseudospectra 可能远大于谱半径），用特征值判断稳定性会严重误判。解决：改用 SVD 看奇异值。
- **重特征值的数值敏感性**：代数重数 > 几何重数时（亏损矩阵），特征向量对扰动极度敏感，Jordan 块在浮点下不可算。解决：用 Schur 分解代替。
- **Power iteration 收敛慢**：当 $\lambda_1 / \lambda_2 \approx 1$ 时收敛极慢（需 $O(1/(1-\lambda_2/\lambda_1))$ 步）。解决：block iteration 或 Lanczos 加速。
- **HVP 的数值精度**：$Hv$ 的浮点误差在 CG 迭代中累积，可能导致 CG 不收敛。需定期重正交化或加重启动。

## 深入参考

- 蒸馏稿：../../references/books/matrix-analysis.md（Ch 1 特征值与相似、§2.4-2.5 Schur 三角化与正规矩阵、§4.2 Courant-Fischer）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 1 (Eigenvalues, Eigenvectors, Similarity) + Chapter 2 (Unitary Similarity §2.4-2.5)


## 路由扩展
- 若需要截断近似 → `low-rank-approximation.md`（基于 SVD 的低秩近似）
- 若用于注意力机制设计 → `spectral-attention`（设计模式层）
- 若需要谱的集中界 → `../probability/concentration-inequality.md`（随机矩阵谱的集中不等式）

## 可扩展方向
- SVD 变体（truncated / randomized SVD）：大规模矩阵的快速分解
- CUR 分解：基于列/行采样的可解释矩阵近似
- Nystrom 方法：核矩阵的低秩近似
- 谱图理论（Laplacian eigenvalues）：图拉普拉斯特征值与图结构分析
- 随机矩阵理论：大维随机矩阵的谱分布
