# Lagrange 对偶 (Lagrangian Duality)

## 最小定义

将约束优化问题（primal）转化为对偶变量的最大化问题（dual）。对偶函数 $g(\lambda, \nu) = \inf_x L(x, \lambda, \nu)$ 是原问题最优值的下界（弱对偶），当对偶间隙为零时（强对偶）对偶问题的最优值等于原问题最优值。

## 核心公式

- 原始问题：$\min_x f(x) \quad \text{s.t.} \quad g_i(x) \leq 0, \ h_j(x) = 0$
- Lagrangian：$L(x, \lambda, \nu) = f(x) + \sum_i \lambda_i g_i(x) + \sum_j \nu_j h_j(x)$
- 对偶函数：$g(\lambda, \nu) = \inf_x L(x, \lambda, \nu)$（对 $x$ 的逐点下确界，天然凹）
- 弱对偶：$d^* \leq p^*$（对偶最优 $\leq$ 原问题最优，恒成立）
- 强对偶条件（Slater）：凸问题 + 存在严格可行点 $g_i(x_0) < 0 \implies d^* = p^*$
- 互补松弛：$\lambda_i^* g_i(x^*) = 0$（最优时，要么约束紧、要么乘子为零）
- Minimax 等价：强对偶 $\iff \min_x \max_{\lambda \geq 0} L = \max_{\lambda \geq 0} \min_x L$

## 适用问题

- GAN / 对抗训练：$\min_G \max_D V(D,G)$ 即 minimax 博弈，强对偶时鞍点 = Nash 均衡
- SVM 对偶：原始 $O(d)$ 维转对偶 $O(n)$ 维 + 核 Gram 矩阵，样本数 $\ll$ 维度时大赚
- 约束分解：大规模问题按约束拆成子问题，对偶分解后各子问题可并行求解
- 正则化参数的对偶解释：$\lambda$-正则化 $\iff$ 带约束的原问题（如 $\|w\|_2^2 \leq C$）
- 资源分配 / 联邦学习：全局约束分解为本地子问题的 Lagrange 松弛

## AI 设计翻译

- **对抗训练的 minimax 框架**：$L(\theta, \phi) = \mathbb{E}[\log D_\phi(x)] + \mathbb{E}[\log(1 - D_\phi(G_\theta(z)))]$。$G$ 和 $D$ 交替梯度上升/下降，核心操作是前向 + 反向传播（matmul 链）。梯度惩罚 / spectral norm 约束 $D$ 的 Lipschitz 保证 minimax 有鞍点。
- **SVM 对偶 + 核技巧**：原始 $\min_w \frac{1}{2}\|w\|^2 + C\sum\xi_i$ 转对偶 $\max_\alpha \sum\alpha_i - \frac{1}{2}\alpha^T(K \circ yy^T)\alpha$。核 Gram $K_{ij} = k(x_i, x_j)$ 是 matmul（线性核）或 elementwise（RBF 核）。对偶变量 $\alpha \in \mathbb{R}^n$，用 SMO 或梯度投影求解。
- **增广 Lagrangian 约束训练**：$\mathcal{L}_{\text{AL}} = f(x) + \sum \lambda_i g_i(x) + \frac{\rho}{2}\sum g_i(x)^2$。内层对 $x$ 用 SGD 优化，外层对 $\lambda$ 梯度上升更新：$\lambda \leftarrow [\lambda + \rho g(x)]_+$。$\rho$ 项改善对偶函数的凹性（使对偶问题更容易求解），但对非凸原问题不保证全局收敛。收敛性依赖于：(a) 约束规格（如 LICQ/MFCQ），(b) 二阶充分条件，(c) $\rho$ 足够大以满足局部凸性条件。
- **对偶分解 (Dual Decomposition)**：$\min \sum_k f_k(x_k)$ s.t. $\sum x_k \leq b$ 分解为各子问题 $\min_{x_k} f_k(x_k) + \lambda^T x_k$ 独立求解，主问题 $\max_\lambda g(\lambda)$ 用次梯度上升。天然可并行，适合分布式训练。
- **信息瓶颈的对偶视角**：$\min I(Z;X) - \beta I(Z;Y)$ 可写为带约束优化，$\beta$ 是对偶变量。Variational IB 用 ELBO 松弛后变成标准 VAE 训练（reparameterization trick + SGD）。

## 工程可行性

- **主要操作**：Lagrangian 评估 = 原目标 + 约束项的加权求和（elementwise + reduce）；对偶梯度上升 = 标准梯度更新；SMO（SVM）= 坐标下降式的 $2 \times 2$ 子问题。
- **GPU 友好度**：高（对偶函数评估）到中等（SMO 等串行求解器）。增广 Lagrangian 的内层优化完全是标准 SGD（matmul 链），对偶变量更新是 elementwise。SMO 是坐标式更新，GPU 不友好，但 $n$ 不大时 CPU 即可。
- **复杂度**：对偶函数评估 = 一次前向传播 $O(\text{model FLOPs})$；对偶梯度上升每步 $O(n)$（约束数）；SMO $O(n^2 d)$。
- **低精度**：对偶变量 $\lambda$ 应保持在 fp32（乘子范围大，低精度溢出风险）；模型参数可用 bf16。

## 风险与失效条件

- **非凸问题的对偶间隙**：强对偶仅对凸问题 + Slater 条件保证。非凸神经网络训练中 $d^* < p^*$ 常见，对偶解不给出原始可行解。解决：对凸问题，增广 Lagrangian（$\rho$ 足够大时具有 exact penalty 性质，可消除对偶间隙）；对非凸问题，对偶间隙可能持续存在，增广 Lagrangian 只能保证局部收敛到 KKT 点，或改用 SQP。
- **对偶变量振荡**：$\lambda$ 的梯度上升步长不当会导致对偶变量振荡、原始不可行。解决：使用自适应步长（Adam 更新 $\lambda$）或增广 Lagrangian 的 $\rho$ 递增策略。
- **互补松弛的数值判定**：$\lambda_i g_i(x) = 0$ 在浮点下只能达到 $\sim 10^{-6}$，严格互补松弛不可得。影响 SVM 支持向量识别等，需设阈值。
- **Minimax 训练的 mode collapse**：GAN 中 $\min\max$ 的非凸-非凹博弈导致模式坍缩或训练不稳定。需梯度惩罚（WGAN-GP）、谱归一化等额外正则化。

## 深入参考

- 蒸馏稿：../../references/books/optimization-ml.md（Ch 23 Lagrangian Duality、§23.5 强对偶、§23.6.3 Slater 条件）
- 原书：Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 23 (Lagrangian Duality §23.1-23.6) + Chapter 17 (LP Duality)


## 路由扩展
- 若需要从原始问题出发 → `constrained-optimization.md`（原始约束优化）
- 若需要强对偶条件 → `convex-optimization.md`（凸问题的强对偶定理）
- 若涉及 IB 目标函数的对偶形式 → `information-bottleneck.md`（信息瓶颈的变分对偶）

## 可扩展方向
- 增广 Lagrangian（augmented Lagrangian）：罚项增强的 Lagrangian 方法
- 鞍点理论（saddle point theory）：Lagrangian 鞍点的存在性与求解
- KKT 条件正则性（KKT regularity）：约束规范与 KKT 必要条件
- 锥对偶（conic duality）：锥规划的对偶理论
- Fenchel 对偶（Fenchel duality）：凸共轭与 Fenchel-Rockafellar 对偶
- 极小极大对偶（minimax duality）：min-max 定理与对偶间隙
