# 约束优化 (Constrained Optimization)

## 最小定义

在约束集 $\mathcal{C} = \{x : g_i(x) \leq 0, h_j(x) = 0\}$ 上最小化目标 $f(x)$。最优解满足 KKT 条件（一阶必要条件）：梯度为零（在 Lagrangian 意义下）、原始可行、对偶可行、互补松弛。约束优化将"硬限制"系统性地纳入优化框架。

## 核心公式

- KKT 条件（不等式约束）：
  - $\nabla_x L = \nabla f + \sum \lambda_i \nabla g_i + \sum \nu_j \nabla h_j = 0$（驻点）
  - $g_i(x) \leq 0, \ h_j(x) = 0$（原始可行）
  - $\lambda_i \geq 0$（对偶可行）
  - $\lambda_i g_i(x) = 0$（互补松弛）
- 投影梯度法：$x_{k+1} = \text{proj}_{\mathcal{C}}(x_k - \alpha \nabla f(x_k))$
- 惩罚函数法：$\min_x f(x) + \frac{\rho}{2}\sum [\max(0, g_i(x))]^2 + \frac{\rho}{2}\sum h_j(x)^2$
- 增广 Lagrangian：$\mathcal{L}_\rho(x,\lambda) = f(x) + \sum \lambda_i g_i(x) + \frac{\rho}{2}\sum g_i(x)^2$
- Armijo 线搜索（约束版）：$\alpha$ 满足 $f(\text{proj}_\mathcal{C}(x - \alpha \nabla f)) \leq f(x) - \sigma \alpha \|\nabla f\|^2$

## 适用问题

- 权重范数约束：$\|w\|_2 \leq R$（weight clipping / norm ball）
- 谱范数约束：$\sigma_{\max}(W) \leq 1$（谱归一化，稳定 GAN/扩散模型）
- 安全约束 / RLHF：$\mathbb{E}[r_{\text{safety}}] \geq \tau$（KL 约束策略优化）
- 公平性约束：$|P(\hat{y}|A=0) - P(\hat{y}|A=1)| \leq \epsilon$
- 资源约束：模型大小 / FLOPs / 推理延迟预算下的性能优化

## AI 设计翻译

- **Weight Clipping (WGAN)**：$W \leftarrow \text{clamp}(W, -c, c)$ 即投影到 $\ell_\infty$-box 约束。实现为 `torch.clamp(W, -c, c)`，elementwise 操作，零额外计算。简单但粗糙，不如谱归一化精细。
- **谱归一化 (Spectral Normalization)**：约束 $\sigma_{\max}(W) \leq 1$，即投影到算子范数球。用 power iteration 估 $u \leftarrow W^T W u / \|W^T W u\|$，归一化 $W \leftarrow W / \sigma_{\max}$。每步 2 次 matvec + norm，PyTorch 内置 `torch.nn.utils.spectral_norm`。
- **投影梯度做 $\ell_2$-ball 约束**：$\text{proj}(w) = w \cdot \min(1, R/\|w\|_2)$，实现为 `w * min(1, R / w.norm())`，一次 norm + elementwise，$O(d)$。用于 trust region、对抗鲁棒的 $\epsilon$-ball 约束。
- **增广 Lagrangian 做 RLHF/PPO**：$\mathcal{L} = -\mathbb{E}[r] + \lambda(\text{KL}(\pi\|\pi_{\text{ref}}) - \epsilon) + \frac{\rho}{2}(\text{KL} - \epsilon)^2$。内层对 $\pi$ 用 PPO 优化，外层 $\lambda \leftarrow \lambda + \rho(\text{KL} - \epsilon)$。KL 计算是 softmax + elementwise log-ratio，GPU 友好。
- **惩罚法做稀疏/低秩约束**：$\mathcal{L}_{\text{penalty}} = \mathcal{L}_{\text{task}} + \rho \sum_i \max(0, \|w_i\|_1 - \tau)^2$ 约束每层稀疏度不超 $\tau$。惩罚项是 elementwise + reduce，可微且 GPU 友好。$\rho$ 递增策略：$\rho \leftarrow \beta \rho$（$\beta > 1$），每若干步加倍。

## 工程可行性

- **主要操作**：投影 = elementwise + norm（$O(d)$）；惩罚项 = elementwise + reduce（$O(d)$）；KKT 梯度 = 标准反向传播；power iteration = matvec（$O(d^2)$ 或 $O(nd)$）。
- **GPU 友好度**：高。投影梯度法的投影步骤多为廉价 elementwise（norm-ball、box、$\ell_1$-ball）；惩罚项 / 增广 Lagrangian 仅增加 elementwise 计算；谱归一化的 power iteration 是 matvec。
- **复杂度**：投影 $O(d)$（norm-ball / box）到 $O(d \log d)$（$\ell_1$-ball）；惩罚评估 $O(d)$；谱归一化 $O(nd)$ per iteration；内点法每步 $O(d^3)$（避免在训练内环使用）。
- **低精度**：投影操作在 bf16 下稳定（norm 和 clamp 不涉及精细数值）；惩罚项的 $\rho$ 需控制范围避免溢出（$\rho > 10^6$ 时用 fp32）。

## 风险与失效条件

- **投影的不可微性**：$\text{proj}_\mathcal{C}(x)$ 在约束边界处不可微（如 $\|x\|_2 = R$ 时梯度不连续），影响反向传播。解决：用 Moreau envelope 平滑化，或惩罚法 / 增广 Lagrangian 替代硬投影。
- **惩罚法的病态**：$\rho \to \infty$ 时 Hessian 条件数 $\kappa \sim \rho$，梯度下降收敛变慢。解决：增广 Lagrangian（$\rho$ 不需趋于无穷即可精确满足约束），或对偶上升法。
- **一般多面体投影昂贵**：$\mathcal{C} = \{x : Ax \leq b\}$ 的投影需解 QP，复杂度 $O(d^3)$，不能每步做。解决：改用惩罚法或增广 Lagrangian，避免显式投影。
- **KKT 只是必要条件**：非凸问题下 KKT 点不一定是局部最优（可能是鞍点）。需配合二阶充分条件（Lagrangian Hessian 在约束切空间上正定）判断。
- **互补松弛的数值精度**：$\lambda_i g_i(x) = 0$ 在浮点下只能达到 $\sim \epsilon$，active set 识别困难。增广 Lagrangian 天然避免此问题（不依赖精确互补松弛）。

## 深入参考

- 蒸馏稿：../../references/books/optimization-ml.md（Ch 20-21 等式/不等式约束与 KKT、Ch 24 约束算法 §24.3 投影梯度 §24.5 增广 Lagrange §24.6 惩罚法）
- 原书：Chong, Lu, Zak, *An Introduction to Optimization* 5th Ed., Chapter 20-21 (Equality & Inequality Constraints) + Chapter 24 (Algorithms for Constrained Optimization §24.2-24.6)


## 路由扩展
- 若需要从对偶视角分析 → `lagrangian-duality.md`（Lagrange 对偶理论）
- 若约束在流形上 → `riemannian-optimization.md`（流形约束的黎曼优化）
- 若需要惩罚项设计 → `constraint-penalty`（设计模式层的约束惩罚）

## 可扩展方向
- 罚函数/障碍函数（penalty / barrier methods）：将约束转化为惩罚项
- 序列二次规划（SQP）：约束优化的二阶方法
- 有效集方法（active set methods）：识别活跃约束集
- 约束规范（constraint qualification）：LICQ, MFCQ 等正则条件
- 精确罚函数（exact penalty）：有限罚参数下的精确解
- 增广 Lagrangian 方法（augmented Lagrangian methods）：结合对偶与罚函数
