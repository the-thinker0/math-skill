# 联络 (Connection)

## 最小定义

联络 $\nabla$ 是流形上"如何把一个向量沿曲线搬到另一点而不额外旋转"的规则。形式化地，$\nabla: \mathfrak{X}(M) \times \mathfrak{X}(M) \to \mathfrak{X}(M)$ 满足 Leibniz 法则。Levi-Civita 联络是唯一与度量相容（$\nabla g = 0$）且无挠（$T = 0$）的联络。

## 核心公式

- 协变导数：$\nabla_X Y = \left(X^i \partial_i Y^k + X^i Y^j \Gamma^k_{ij}\right) \partial_k$
- Christoffel 符号（Levi-Civita）：$\Gamma^k_{ij} = \frac{1}{2} g^{kl}(\partial_i g_{jl} + \partial_j g_{il} - \partial_l g_{ij})$
- 平行移动方程：$\frac{D V^k}{dt} = \dot V^k + \Gamma^k_{ij} \dot\gamma^i V^j = 0$
- 联络形式（主丛）：$\omega \in \Omega^1(P, \mathfrak{g})$，规范场 $A_\mu$ 即局部联络形式
- 曲率 = 联络的不交换性：$R(X,Y) = [\nabla_X, \nabla_Y] - \nabla_{[X,Y]}$

## 适用问题

- 跨点向量比较：不同点的切空间无法直接相加，需要联络规定的"搬运规则"
- 优化中的动量/状态搬运：Riemannian Adam 中历史梯度需要通过 parallel transport 跨步搬运
- 规范等变网络：局部坐标系（gauge）的选择自由由联络对齐
- 物理约束系统：电磁场 = U(1) 联络曲率，Yang-Mills = 非阿贝尔联络曲率

## AI 设计翻译

- **Vector transport 模块**：Riemannian 优化器中，将动量 $m_k \in T_{x_k}M$ 搬到 $T_{x_{k+1}}M$；闭式 transport（如 Stiefel 上的投影）可 GEMM 化
- **Gauge-equivariant CNN**：在流形/网格上，每条边携带一个 $G$-联络元素对齐相邻点的局部 frame，使卷积核对局部坐标选择不变
- **Parallel transport 正则化**：惩罚特征场在联络下的非平行性 $\|\nabla_X f\|^2$，强制特征沿流形平滑变化
- **联络学习的参数化**：将 Christoffel 符号参数化为神经网络输出，学习数据流形上的"最优搬运规则"

## 工程可行性

GPU 友好度：联络的核心挑战是"串行 ODE 积分"。
- **闭式 parallel transport**（特定流形如 SO(3)、Stiefel）：单步矩阵运算，可 batched，GPU 友好
- **一般联络的平行移动**：沿曲线积分 $\dot{V} + \Gamma \dot\gamma V = 0$ 是串行 ODE，并行性差
- **Christoffel 符号计算**：涉及度量 $g$ 的偏导和 $g^{-1}$，若 $g$ 有闭式则 $O(n^3)$，否则更贵
- **规范等变 CNN 中的联络**：每边一个 $G$-元素作用（矩阵乘特征向量），可表达为 sparse matmul 或 batched small GEMM
- 关键改造：用一步 retraction/closed-form transport 替代逐步 ODE 积分

## 风险与失效条件

- **逐步 ODE 积分做平行移动**：串行递推杀死并行度，必须用闭式 transport 或一步近似
- **左右联络约定不统一**：左不变 vs 右不变联络的选择不一致导致梯度错位
- **规范自由度未正确处理**：gauge-equivariant 网络中若联络参数化不完备，等变性会悄悄破缺
- **Christoffel 符号的数值导数**：用有限差分估计 $\partial_i g_{jk}$ 时噪声大，最好有解析式或 autodiff
- **联络 ≠ 度量**：有联络不一定有相容度量（非度量联络），错误假设相容性会导致不一致

## 深入参考

- 蒸馏稿：references/books/differential-geometry.md（Ch 12 Connections and Covariant Derivatives, §12.2 联络形式, §12.4 Ehresmann, §12.12 G-联络）
- 蒸馏稿：references/books/differential-geometry.md（§6.8 Principal Bundles, §9.8 Electromagnetism）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 12（§12.1-§12.12 完整联络理论）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §13.1 Levi-Civita Connection
