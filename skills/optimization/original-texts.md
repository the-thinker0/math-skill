# 数学出处与经典文献 / Mathematical Sources and Classic Texts

## Euler-Lagrange 变分方程与最速降线 / Euler-Lagrange Variational Equation & Brachistochrone (1696)

> Johann Bernoulli 于 1696 年提出最速降线问题：在重力作用下，质点从 A 到 B 沿哪条曲线下降最快？答案是旋轮线（cycloid）。

**核心方程**：对泛函 J[y] = ∫_{a}^{b} F(x, y, y') dx，极值函数满足

> ∂F/∂y - d/dx(∂F/∂y') = 0 （Euler-Lagrange 方程）

最速降线问题的 F = √(1 + y'²) / √(2g(y₀ - y))，代入 Euler-Lagrange 方程后解出旋轮线参数方程：x = a(θ - sin θ), y = a(1 - cos θ)。

**思想**：变分法将"在整个函数类中寻优"化为微分方程求解——这是无穷维优化的起源。Euler（1744）系统化了变分法，Lagrange（1788）引入了 δ 符号与乘数法，两者一脉相承。变分法后来发展为最优控制理论（Pontryagin 最大值原理，1961），在航天轨道设计、机器人路径规划等领域广泛应用。

## Fermat 与 Weierstrass 极值条件 / Fermat & Weierstrass Conditions for Unconstrained Optimization

> Fermat（1636）：可微函数 f 在 x* 处取得局部极值的必要条件是 ∇f(x*) = 0。
> Weierstrass（19th c.）：若 f 二阶可微且 ∇f(x*) = 0，则 Hessian H(x*) 正定 ⇔ x* 是严格局部极小；H(x*) 负定 ⇔ x* 是严格局部极大。

对凸函数，∇f(x*) = 0 不仅是必要条件，也是充分条件——且 x* 是全局极小。

**思想**：一阶条件找驻点，二阶条件判极值性质——无约束优化的最基本定理。∇f = 0 是几乎所有迭代优化算法（梯度下降、牛顿法）的收敛目标。

## Lagrange 乘数法 / Lagrange Multipliers (1788)

> 在约束 g(x) = 0 下求 f(x) 的极值，等价于求 L(x,λ) = f(x) - λg(x) 的无条件极值。

**思想**：将约束优化问题转化为无约束问题。在最优解处，目标函数的梯度与约束函数的梯度平行：∇f(x*) = λ∇g(x*)。

## Pareto 最优性 / Pareto Optimality (Vilfredo Pareto, ~1906)

> 在多目标优化中，解 x 是 Pareto 最优的，若不存在 y 使得 f_i(y) ≤ f_i(x) ∀i 且至少一个 f_j(y) < f_j(x)（严格改善）。

Pareto 在《Manuale di economia politica》(1906) 中将此概念引入经济学：资源配置的效率前沿。Pareto 前沿 Pareto frontier {f(x) : x is Pareto optimal} 刻画了所有不可同时改善的权衡解。数学上，对目标 f₁,...,fₘ 的 Pareto 前沿是 {y ∈ ℝᵐ : y = (f₁(x),...,fₘ(x)), x Pareto optimal}——它是目标空间中的一个（通常非凸的）曲面。

> 加权标量化：将多目标 min f₁,...,fₘ 转化为单目标 min Σw_i f_i（w_i > 0），每个权重组合对应 Pareto 前沿上的一个点。这是求解 Pareto 前沿的常用方法，但对非凸前沿不能遍历所有 Pareto 最优解。

**思想**：多目标优化没有唯一的"最优解"，而有一组 Pareto 最优解，需要在它们之间做权衡。这在经济学（效率与公平）、工程（性能与成本）、机器学习（精度与复杂度）中无处不在。

## 博弈论与优化 / Game Theory & Optimization (von Neumann, 1928; Nash, 1950)

> Nash 均衡：策略组 (s₁*, ..., sₙ*) 使得每个玩家 i 在其他玩家策略固定时，s_i* 是其最优响应——即无人有单方面偏离的动机。

von Neumann（1928）证明了零和博弈的 minimax 定理：max_{x} min_{y} f(x,y) = min_{y} max_{x} f(x,y)，这本质上是线性规划对偶性的先声。Nash（1950）将均衡推广到非零和博弈，Nash 均衡是"互为最优"的优化——每个玩家的优化问题以他人策略为约束。

> Nash 均衡的存在性：Nash（1950）用 Brouwer 不动点定理证明了每个有限博弈至少存在一个混合策略 Nash 均衡。这揭示了博弈论与拓扑学的深层联系。

**思想**：博弈论将优化从"单人决策"推广到"多人交互决策"——最优不再是对自然的最优，而是对其他理性主体的最优响应。

## KKT 条件 / Karush-Kuhn-Tucker Conditions (1939/1951)

不等式约束优化的必要条件：

> 对于 min f(x) s.t. g_i(x) ≤ 0, h_j(x) = 0，最优解 x* 满足：
> - 平稳性：∇f(x*) + Σμ_i∇g_i(x*) + Σλ_j∇h_j(x*) = 0
> - 可行性：g_i(x*) ≤ 0, h_j(x*) = 0
> - 互补松弛性：μ_i · g_i(x*) = 0, μ_i ≥ 0

Karush（1939，硕士论文）最早给出此条件；Kuhn & Tucker（1951）独立重新发现并广泛传播。

**思想**：最优解处，要么约束不起作用（μ_i = 0），要么约束是紧的（g_i(x*) = 0）。互补松弛性是对偶理论的基石——它将 KKT 条件与对偶间隙为零紧密联系。当约束限定条件 constraint qualification 成立时（如 LICQ：活跃约束梯度线性无关），KKT 条件是最优性的必要条件。

## 线性规划对偶 / Linear Programming Duality (Farkas, 1902; Dantzig-von Neumann, 1947)

> Farkas 引理（1902）：Ax = b, x ≥ 0 有解 ⟺ Aᵀy ≥ 0, bᵀy < 0 无解——这是 LP 对偶的几何根基。

> 强对偶定理：若原 LP min cᵀx s.t. Ax = b, x ≥ 0 有可行解，则 max bᵀy s.t. Aᵀy ≤ c 的最优值相等。对偶变量 y 的分量称为影子价格 shadow price——它衡量每个约束的"边际价值"。

**思想**：每个 LP 都有一个"镜像"问题——原问题看成本，对偶问题看价值。对偶间隙为零是深刻的事实：资源的最小成本等于影子价格的最大收益。

## Dantzig 单纯形法 / Simplex Method (1947)

线性规划的基本算法。在可行域的顶点上搜索最优解。

> Klee-Minty 立方体（1973）：存在 LP 实例使得单纯形法遍历所有 2ⁿ 个顶点——最坏情况指数复杂度。

> 内点法 / Interior-Point Methods：Karmarkar（1984）提出多项式时间 LP 算法，在可行域内部沿中心路径收敛，避免顶点遍历。现代内点法（如 Mehrotra predictor-corrector）在实践和理论上均表现优异。

**思想**：线性规划的最优解一定在可行域的顶点上。单纯形法利用此结构沿边移动；内点法从内部逼近，两者互补。

## 对偶理论 / Duality Theory

> 弱对偶：对任何优化问题，对偶问题的最优值 d* ≤ 原问题最优值 p*（对偶间隙 gap = p* - d* ≥ 0）。

> 强对偶（Slater 条件）：若凸优化问题存在严格可行点（Slater point：g_i(x) < 0 严格成立），则 d* = p*，对偶间隙为零。

> 对偶提供了下界（原问题的最优值 ≥ 对偶值），这在分支定界、 Cutting-plane 等算法中是关键工具。

**思想**：对偶将"最小化成本"与"最大化价值"联系起来——两个视角看同一问题。Slater 条件保证了凸优化的"无信息损失"。

## 梯度下降 / Gradient Descent (Cauchy, 1847; Robbins-Monro, 1951)

> Cauchy（1847）提出最速下降法：x_{k+1} = x_k - α_k ∇f(x_k)，沿负梯度方向迭代，α_k 为步长。对 L-平滑凸函数（Lipschitz 连续梯度），步长 α = 1/L 时 f(x_k) - f(x*) ≤ L‖x₀ - x*‖² / (2k)——线性收敛率 O(1/k)。

> 牛顿法 Newton's Method：x_{k+1} = x_k - H(x_k)⁻¹ ∇f(x_k)，利用二阶信息，在最优解附近达到二次收敛 O(‖x_k - x*‖²)。

> 随机梯度下降 SGD：Robbins & Monro（1951）提出随机逼近，用噪声梯度 g_k ≈ ∇f(x_k) 替代真梯度。条件 Σα_k = ∞, Σα_k² < ∞ 保证收敛。SGD 在期望意义上收敛，代价是方差——minibatch 是方差与效率的折中。

**思想**：梯度下降是最朴素的优化——"哪里最陡就往哪里走"。SGD 将此思想扩展到大数据场景：不需要看全部数据，只需随机采样一小部分即可逼近方向。深度学习的训练几乎全部依赖 SGD 及其变体（Adam, AdaGrad 等）。

## 整数规划与 NP-困难 / Integer Programming & NP-Hardness (Cook, 1971; Karp, 1972)

> 整数线性规划 ILP：min cᵀx s.t. Ax ≤ b, x ∈ ℤⁿ——变量取整数值。即使 0-1 ILP（x ∈ {0,1}ⁿ）也是 NP困难的。

> Cook（1971）证明 SAT 是 NP 完全的（Cook-Levin 定理）；Karp（1972）列出 21 个 NP 完全问题，包含整数规划、背包问题、旅行商问题等。ILP 是 NP困难的——不存在（在 P ≠ NP 假设下）多项式时间精确算法。

> 凸松弛：将 x ∈ ℤⁿ 松弛为 x ∈ ℝⁿ 得到 LP，其最优值给出 ILP 的下界——这正是分支定界法 branch-and-bound 的核心机制。

**思想**：离散优化比连续优化本质上更难。"整数"这一看似微小的约束，将问题从多项式可解推向 NP 困难。分支定界 branch-and-bound、割平面 cutting-plane 是主要精确方法；启发法在实践中更常用。

## 凸优化 / Convex Optimization (Boyd & Vandenberghe, 2004)

> 凸优化：min f(x) s.t. g_i(x) ≤ 0 (凸), h_j(x) = 0 (线性), x ∈ C (凸集)。f 为凸函数时局部极小即全局极小。

> 关键性质：(1) 局部极小 = 全局极小；(2) 可行域是凸集；(3) Slater 条件下强对偶成立；(4) 内点法在多项式时间内可解。

凸优化涵盖的重要子类：
- LP（线性规划）：f 线性，约束线性
- QP（二次规划）：f 二次，约束线性
- SOCP（二阶锥规划）：约束含二阶锥 ‖Ax + b‖ ≤ cᵀx + d
- SDP（半定规划）：约束含矩阵半正定条件 X ≥ 0
- GP（几何规划）：对数空间下化为凸优化

Boyd & Vandenberghe《Convex Optimization》(2004) 统一了上述各类问题，成为现代优化的标准教材与工程参考。凸优化是"可高效求解的优化"的边界——凸性保证了算法的收敛性与解的全局性。

**思想**：凸优化是优化理论的"甜蜜区"——足够丰富以涵盖大量实际问题，又足够结构化以保证可解性。非凸问题往往通过凸松弛 convex relaxation 来近似。

## Bellman 最优性原理 / Bellman's Principle of Optimality (1957)

> "一个最优策略具有这样的性质：无论初始状态和初始决策如何，剩余决策必须构成关于由初始决策产生的状态的最优策略。"
> "An optimal policy has the property that whatever the initial state and initial decision are, the remaining decisions must constitute an optimal policy with regard to the state resulting from the first decision."

> 递推方程：V(s) = max_a { R(s,a) + γ · V(s') }，其中 s' 为状态转移结果。

**思想**：动态规划的核心——最优解的子结构也是最优的。Bellman 方程将多阶段决策分解为单阶段子问题，是强化学习的理论根基。

## 优化的哲学意义

优化思想的核心是**在约束下做最好的选择**——这不仅是数学问题，也是人生问题。生活中大多数决策都可以表述为优化问题：

- **目标函数**：你想最大化什么？（幸福？成就？自由？）
- **约束条件**：你面临什么限制？（时间？金钱？能力？）
- **可行域**：在约束下你有什么选择？
- **最优解**：在所有选择中，哪个使目标最大化？
- **对偶视角**：从"成本"看和从"价值"看，答案是一致的——这正是强对偶的哲学。
- **凸与非凸**：凸优化有唯一全局最优；非凸优化有多个局部最优——人生的困境恰在于世界是非凸的。

## 优化理论历史年表 / Timeline of Optimization

| 年份 | 事件 |
|------|------|
| 1636 | Fermat 提出无约束极值的必要条件 ∇f = 0 |
| 1696 | Johann Bernoulli 提出最速降线问题，变分法萌芽 |
| 1744 | Euler 系统化变分法 |
| 1788 | Lagrange 发表乘数法，融入《分析力学》 |
| 1902 | Farkas 引理——LP 对偶的几何基础 |
| ~1906 | Pareto 将效率前沿概念引入经济学 |
| 1928 | von Neumann 证明 minimax 定理（零和博弈） |
| 1939 | Karush 给出 KKT 条件（硕士论文） |
| 1947 | Dantzig 发明单纯形法；von Neumann 建立 LP 对偶 |
| 1950 | Nash 证明非零和博弈均衡存在性 |
| 1951 | Kuhn & Tucker 发表 KKT 条件；Robbins-Monro 提出随机逼近 |
| 1957 | Bellman 发表动态规划与最优性原理 |
| 1971 | Cook 证明 NP 完全性（Cook-Levin 定理） |
| 1972 | Karp 列出 21 个 NP 完全问题 |
| 1973 | Klee-Minty 证明单纯形法最坏情况指数复杂度 |
| 1984 | Karmarkar 提出多项式时间内点法 |
| 2004 | Boyd & Vandenberghe 出版《Convex Optimization》