# 凸优化 (Convex Optimization)

## 最小定义

在凸集上最小化凸函数的优化问题。凸性保证局部最优即全局最优。对于**无约束可微**凸优化，一阶条件（$\nabla f(x^*) = 0$）是充分必要的；对于**约束**凸优化（$\min f(x)$ s.t. $x \in C$），KKT 条件在 Slater 条件满足时是充分必要的；对于**非光滑**凸优化，最优性条件为 $0 \in \partial f(x^*) + N_C(x^*)$，其中 $N_C$ 为约束集的法锥。凸问题是优化理论中唯一能保证全局最优且可高效求解的类别。

## 核心公式

- 凸集：$\forall x, y \in C, \theta \in [0,1]: \theta x + (1-\theta)y \in C$
- 凸函数：$f(\theta x + (1-\theta)y) \leq \theta f(x) + (1-\theta)f(y)$
- 一阶条件：$f(y) \geq f(x) + \nabla f(x)^T(y-x)$（切线在下方的上方）
- 二阶条件：$\nabla^2 f(x) \succeq 0$（Hessian 半正定）
- 标准凸问题形式：$\min f(x)$ s.t. $g_i(x) \leq 0$（$g_i$ 凸）, $Ax = b$
- 收敛速率（强凸 + 光滑）：$\|x_k - x^*\|^2 \leq (1 - \mu/L)^k \|x_0 - x^*\|^2$，条件数 $\kappa = L/\mu$
- 半定规划 (SDP)：$\min \langle C, X \rangle$ s.t. $\langle A_i, X \rangle = b_i, X \succeq 0$

## 适用问题

- 线性/逻辑回归：交叉熵 + 线性模型是凸问题，有唯一全局最优
- 权重衰减 / 正则化：$\|w\|_2^2$、$\|w\|_1$ 都是凸正则项
- SVM：hinge loss + 二次正则 = 凸问题
- PCA：协方差矩阵的最大特征值问题 = SDP 的特例
- 核方法的 Gram 矩阵优化：SDP 约束 $K \succeq 0$

## AI 设计翻译

- **Loss 函数的凸性诊断**：交叉熵对 logits 是凸的（softmax + NLL），MSE 对线性输出是凸的。但一旦过非线性层（ReLU、attention），整体变为非凸。设计 loss 时保持最后一层到 loss 的凸性是收敛保障。
- **学习率调度与凸优化收敛率**：强凸 + 光滑下 SGD 收敛率 $O(1/T)$，非强凸 $O(1/\sqrt{T})$。条件数 $\kappa = L/\mu$ 决定收敛速度：BatchNorm / LayerNorm 的作用是减小 $\kappa$（使 Hessian 更圆），等价于预条件。实现为标准归一化层。
- **凸松弛 (Convex Relaxation)**：将非凸问题松弛为凸问题求解。例：$\ell_0$ 稀疏 $\to \ell_1$（LASSO）；矩阵秩最小化 $\to$ 核范数最小化；整数规划 $\to$ LP 松弛。实现为替换正则项或约束。
- **投影到凸集 (Convex Projection)**：$\text{proj}_C(x) = \arg\min_{y \in C} \|y - x\|^2$。$\ell_2$-ball 投影 = $x / \max(1, \|x\|_2/R)$（elementwise + norm）；$\ell_1$-ball 投影 = soft-thresholding + sort（$O(n\log n)$）；box 约束 = clamp（elementwise）。全是 GPU 友好操作。
- **镜像下降 (Mirror Descent)**：在非欧几何下用 Bregman 散度代替欧氏距离做梯度更新。对 $\ell_1$ 约束（稀疏权重），用指数梯度 $x_{k+1} \propto x_k \exp(-\eta \nabla f)$，实现为 elementwise exp + normalize。

## 工程可行性

- **主要操作**：梯度计算 = 反向传播（matmul 链）；投影 = elementwise + norm；凸函数评估 = 前向传播。整体与标准训练循环同构。
- **GPU 友好度**：极高。凸优化的一阶方法（梯度下降、投影梯度、镜像下降）完全映射到 GPU 算子。二阶方法（Newton、内点法）在中等规模（$d < 10000$）可用 cuSOLVER。
- **复杂度**：梯度下降每步 $O(d)$（梯度计算 $O(\text{model FLOPs})$）；投影 $O(d)$ 到 $O(d\log d)$；内点法每步 $O(d^3)$。
- **低精度**：强凸问题在 bf16 下稳定（梯度是 Lipschitz 的）；条件数大时需归一化/预条件，否则低精度放大病态。

## 风险与失效条件

- **假凸性**：看似凸的 loss 在复合非线性后变成非凸（如 $f(W_2 \sigma(W_1 x))$ 对 $W_1, W_2$ 非凸）。仅最后一层到 loss 是凸的不代表全局凸。
- **条件数退化**：$\kappa = L/\mu \to \infty$ 时（$\mu \to 0$，弱凸或平坦方向），收敛率退化为 $O(1/\sqrt{T})$。解决：加 $\ell_2$ 正则使问题强凸（$\mu \geq \lambda$），或用归一化层改善 $\kappa$。
- **SDP 求解器扩展性差**：内点法 SDP 求解器复杂度 $O(n^6)$（$n$ 为矩阵维度），超过 $n = 500$ 基本不可行。大规模场景需一阶方法（ADMM）或凸松弛后近似。
- **凸松弛的间隙**：$\ell_1$ 松弛不一定恢复 $\ell_0$ 稀疏解（需 RIP 条件）；核范数松弛不一定给出最低秩解。松弛质量依赖问题结构。

## 深入参考

- 蒸馏稿：../../references/books/optimization-ml.md（Ch 22 Convex Optimization、§22.2 凸函数、§22.3 凸问题、§22.4 SDP/LMI）
- 原书：Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 22 (Convex Optimization Problems §22.1-22.4)


## 路由扩展
- 若问题有约束 → `constrained-optimization.md`（约束凸优化方法）
- 若目标不可微 → `proximal-method.md`（近端方法处理非光滑部分）

## 可扩展方向
- 自协调函数（self-concordant functions）：Newton 法的收敛保证
- 内点法（interior point methods）：大规模凸优化的多项式时间方法
- 一阶方法收敛率（first-order convergence rates）：梯度下降的最优收敛速率
- 加速方法（Nesterov acceleration）：Nesterov 动量加速与最优一阶方法
- 在线凸优化（online convex optimization）：序列决策的 regret 分析
- Bandit 凸优化（bandit convex optimization）：零阶信息下的凸优化
