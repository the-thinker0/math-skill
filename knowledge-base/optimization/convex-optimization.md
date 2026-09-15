# 凸优化 (Convex Optimization)

## 最小定义

在凸集上最小化凸函数：每个局部极小都是全局极小，但存在性与唯一性另需假设。无约束可微问题中，$\nabla f(x^*)=0$ 刻画最优点。约束凸问题的精确条件为 $0\in\partial(f+\delta_C)(x^*)$；写成 $\partial f+N_C$ 需次微分求和规则。KKT 必要性要求约束资格条件，充分性来自凸性。多项式时间保证还依赖表示、oracle、精度及条件数。

## 核心公式

- 凸集：$\forall x, y \in C, \theta \in [0,1]: \theta x + (1-\theta)y \in C$
- 凸函数：$f(\theta x + (1-\theta)y) \leq \theta f(x) + (1-\theta)f(y)$
- 一阶条件：$f(y) \geq f(x) + \nabla f(x)^T(y-x)$（切线在下方的上方）
- 二阶条件：$\nabla^2 f(x) \succeq 0$（Hessian 半正定）
- 标准凸问题形式：$\min f(x)$ s.t. $g_i(x) \leq 0$（$g_i$ 凸）, $Ax = b$
- 梯度下降速率：$f$ 为 $\mu$-强凸且 $L$-光滑，完整梯度以步长 $1/L$ 更新时，$f(x_k)-f^*\le(1-\mu/L)^k(f(x_0)-f^*)$。这是特定算法及步长的结论，不是任意优化器性质。
- 半定规划 (SDP)：$\min \langle C, X \rangle$ s.t. $\langle A_i, X \rangle = b_i, X \succeq 0$

## 适用问题

- 凸损失的线性/逻辑回归关于线性模型参数凸；唯一性需适当严格/强凸性，无正则的可分逻辑回归可能没有有限最优解。
- 权重衰减 / 正则化：$\|w\|_2^2$、$\|w\|_1$ 都是凸正则项
- SVM：hinge loss + 二次正则 = 凸问题
- PCA：协方差矩阵的最大特征值问题 = SDP 的特例
- 核方法的 Gram 矩阵优化：SDP 约束 $K \succeq 0$

## AI 设计翻译

- **Loss 函数的凸性诊断**：交叉熵对 logits 是凸的（softmax + NLL），MSE 对线性输出是凸的。但一旦过非线性层（ReLU、attention），整体变为非凸。设计 loss 时保持最后一层到 loss 的凸性是收敛保障。
- **随机与确定性速率**：SGD 速率需无偏梯度、噪声/矩界、步长及平均口径；确定性光滑凸 GD 目标误差为 $O(1/T)$，加速可为 $O(1/T^2)$。BatchNorm/LayerNorm 可改变优化，但不普遍减小 Hessian 条件数。
- **凸松弛 (Convex Relaxation)**：将非凸问题松弛为凸问题求解。例：$\ell_0$ 稀疏 $\to \ell_1$（LASSO）；矩阵秩最小化 $\to$ 核范数最小化；整数规划 $\to$ LP 松弛。实现为替换正则项或约束。
- **投影到凸集 (Convex Projection)**：$\text{proj}_C(x) = \arg\min_{y \in C} \|y - x\|^2$。$\ell_2$-ball 投影 = $x / \max(1, \|x\|_2/R)$（elementwise + norm）；$\ell_1$-ball 投影 = soft-thresholding + sort（$O(n\log n)$）；box 约束 = clamp（elementwise）。全是 GPU 友好操作。
- **镜像下降**：概率单纯形配负熵镜像映射时，指数梯度为 $x_i^+\propto x_i\exp(-\eta\nabla_i f)$。它不是带符号 $\ell_1$ 球的通用更新；需明确域及镜像映射。

## 工程可行性

- **主要操作**：梯度计算 = 反向传播（matmul 链）；投影 = elementwise + norm；凸函数评估 = 前向传播。整体与标准训练循环同构。
- **GPU 友好度**：极高。凸优化的一阶方法（梯度下降、投影梯度、镜像下降）完全映射到 GPU 算子。二阶方法（Newton、内点法）在中等规模（$d < 10000$）可用 cuSOLVER。
- **复杂度**：梯度下降每步 $O(d)$（梯度计算 $O(\text{model FLOPs})$）；投影 $O(d)$ 到 $O(d\log d)$；内点法每步 $O(d^3)$。
- **低精度**：强凸/梯度 Lipschitz 不保证 bf16 精度。有限精度带来依赖尺度、条件数及停止容差的误差下限；以 fp32/fp64 监控目标和最优性残差。

## 风险与失效条件

- **假凸性**：看似凸的 loss 在复合非线性后变成非凸（如 $f(W_2 \sigma(W_1 x))$ 对 $W_1, W_2$ 非凸）。仅最后一层到 loss 是凸的不代表全局凸。
- **弱曲率**：强凸性消失时线性收敛保证失效；替代速率取决于光滑性、随机噪声和算法。给凸目标加 $\ell_2$ 项可保证强凸，任意非凸神经网络目标则不能如此断言。
- **SDP 成本**：内点法成本取决于矩阵大小、约束数、稀疏结构及精度。稠密问题可很昂贵，但没有通用500维不可行阈值；按实际问题比较一阶、低秩及结构化替代。
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
