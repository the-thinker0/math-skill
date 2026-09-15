# 半正定矩阵 (Positive Semidefinite Matrices)

## 最小定义

Hermitian 矩阵 $A$ 若对所有非零向量 $x$ 满足 $x^HAx \geq 0$，则称半正定（PSD），记 $A \succeq 0$。等价条件：所有特征值 $\geq 0$；存在 $B$ 使 $A = B^HB$（Gram 表示）；**所有主子式** $\geq 0$（注意：是全部主子式，不仅是顺序主子式）。正定（PD）要求严格 $> 0$，记 $A \succ 0$。

## 核心公式

- PSD 等价条件：$A \succeq 0 \iff \lambda_i(A) \geq 0 \ \forall i \iff A = B^HB \iff$ 所有主子式 $\geq 0$（注意：是 **所有** 主子式，不仅是顺序主子式）
- 正定等价（Sylvester 准则）：$A \succ 0 \iff \lambda_i(A) > 0 \ \forall i \iff$ 所有顺序主子式 $> 0$（仅需检验顺序主子式，这是 PD 的充分必要条件）
- Cholesky 分解：$A \succ 0 \implies A = LL^H$，$L$ 下三角
- Loewner 偏序：$A \succeq B \iff A - B \succeq 0$
- Schur 积定理：$A \succeq 0, B \succeq 0 \implies A \circ B \succeq 0$（Hadamard 积保 PSD）
- 同时对角化：$A, B \succ 0 \implies \exists C$ 使 $C^HAC = I, C^HBC = \Lambda$
- 极分解：$A = UP$，$P = (A^HA)^{1/2} \succeq 0$

## 适用问题

- 核方法：Gram 矩阵 $K_{ij} = k(x_i, x_j)$ 必须 PSD 才能保证 RKHS 存在
- 协方差矩阵：$\Sigma = \mathbb{E}[xx^H] \succeq 0$，PCA/白化依赖其正定性
- 二阶优化预条件：Hessian/Fisher 信息矩阵的 PSD 结构保证下降方向
- 半定规划 (SDP)：约束 $X \succeq 0$ 下的线性目标优化
- Attention 矩阵分析：softmax 输出的行随机矩阵一般不是 Gram/PSD；只有显式构造对称 PSD kernel（如 $K_{ij}=k(x_i,x_j)$）或对称化并投影到 PSD cone 后，才能使用 PSD 工具。

## AI 设计翻译

- **PSD 核工程 (可学习核)**：用 Schur 积定理组合多个 PSD 核：$K = K_1 \circ K_2 \circ \cdots$（Hadamard 积），保证结果始终 PSD。实现为 elementwise 张量乘 `K = K1 * K2`，$O(n^2)$ elementwise，极 GPU 友好。可参数化 $K_\theta(x,y) = \exp(-\|f_\theta(x)-f_\theta(y)\|^2)$ 保证 PSD。
- **协方差白化 (Whitening)**：$\hat{x} = \Sigma^{-1/2}x$，其中 $\Sigma^{-1/2}$ 可通过缩放后的 Newton-Schulz 迭代近似（纯 matmul）。常用 coupled 形式：$Y_0=A/\alpha, Z_0=I$，$T_k=\frac{1}{2}(3I-Z_kY_k)$，$Y_{k+1}=Y_kT_k, Z_{k+1}=T_kZ_k$，最后 $A^{-1/2}\approx Z_k/\sqrt{\alpha}$；或单变量形式 $X_{k+1}=\frac{1}{2}X_k(3I-AX_k^2)$。收敛需要谱缩放和正定条件，低精度下需残差监控；5-6 步只是常见工程预算。BatchNorm 可视为对角白化的近似。
- **Cholesky 求解**：**正定** $H=LL^H$ 时，先解 $Lz=g$ 再解 $L^Hx=z$，即 $H^{-1}g=L^{-H}L^{-1}g$。逆因子顺序不能颠倒；仅 PSD 的奇异 Hessian 需要阻尼或伪逆。
- **最近 PSD 近似 (Higham)**：给定对称矩阵 $A$，求最近 PSD 矩阵 $A_+ = \arg\min_{X \succeq 0} \|A - X\|_F$。解法：EVD $A = U\Lambda U^H$，将 $\Lambda$ 中负值截零，$A_+ = U\Lambda_+ U^H$。用于修正浮点误差导致的协方差矩阵失去正定性。
- **对角加载**：Hermitian $A$ 的 $A+\epsilon I$ 正定当且仅当 $\epsilon> -\lambda_{\min}(A)$。按尺度与精度留裕量，固定 $10^{-6}$ 未必足够。原位对角更新为 $O(n)$，构造完整单位阵分配 $O(n^2)$。

## 工程可行性

- **主要操作**：Cholesky 分解 $O(n^3/3)$（有 cuSOLVER batched）；Gram 矩阵构造 $O(n^2d)$（matmul）；Newton-Schulz 迭代 $O(n^3)$/step（纯 matmul）；Hadamard 积 $O(n^2)$（elementwise）。
- **GPU 友好度**：高。Gram 矩阵 = matmul；Hadamard 积 = elementwise；Newton-Schulz = 纯 matmul 链；Cholesky 有 cuSOLVER batched 版本，可并行多组。
- **复杂度**：构造 Gram $O(n^2d)$；Cholesky $O(n^3/3)$；Newton-Schulz 5 步 $O(5n^3)$；Jitter $O(n)$。
- **低精度**：Cholesky 与 Newton–Schulz 都要求良好缩放、足够精度和残差检查。纯 matmul 不保证 bf16 收敛；近奇异输入可能需 fp32/fp64 及正则化。

## 风险与失效条件

- **浮点下丢失 PSD**：Cholesky 前对称化并检查最小特征值，使用与尺度匹配的 jitter 及 fp32/fp64。Newton–Schulz 同样要求适当缩放的正定输入及收敛检查，不能修复任意不定矩阵。
- **近奇异性**：$\lambda_{\min} \to 0$ 时条件数 $\kappa \to \infty$，$A^{-1}$ 的元素量级爆炸。解决：截断小特征值（spectral cutoff）或用岭正则 $A + \lambda I$。
- **Schur 积定理的滥用**：$A \circ B \succeq 0$ 要求 $A, B$ **都** PSD；若其中一个非 PSD，结果不保证。可学习核设计中需逐因子验证 PSD 性。
- **SDP 解的微分**：满足正则性且局部解映射良好时，可以通过锥规划层隐式微分。退化、活跃集变化及求解误差可能使梯度不存在或不稳定；PSD 投影求解的是另一个问题，不能通用替代 SDP。[可微凸优化层原论文](https://papers.neurips.cc/paper/9152-differentiable-convex-optimization-layers.pdf)。

## 深入参考

- 蒸馏稿：../../references/books/matrix-analysis.md（Ch 7 Positive Definite and Semidefinite Matrices、§7.5 Schur 积定理、§7.7 Loewner 偏序）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 7 (Positive Definite and Semidefinite Matrices §7.1-7.8)


## 路由扩展
- 若需要求解 SDP 问题 → `../optimization/convex-optimization.md`（半正定规划作为凸优化）
- 若涉及 PSD 矩阵的条件与扰动 → `matrix-perturbation.md`（特征值扰动界）
- 若用于 Fisher 信息矩阵 → `../probability/fisher-information.md`（Fisher 信息的 PSD 性质）

## 可扩展方向
- 半正定规划（semidefinite programming）：SDP 的求解方法与应用
- PSD 补全（PSD completion）：部分已知 PSD 矩阵的补全
- 矩阵平方根（matrix square root）：PSD 矩阵的唯一平方根
- Lowner 序（Lowner order）：PSD 锥上的偏序关系
- 算子单调函数（operator monotone functions）：Loewner-Heinz 定理
- 完全正矩阵（completely positive matrices）：CP 分解与锥结构
