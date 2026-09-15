# 联络 (Connection)

## 最小定义

仿射联络定义协变导数 ∇_X Y：对 X 为 C∞(M)-线性，对 Y 为实线性，并满足 ∇_X(fY)=X(f)Y+f∇_X Y。平行移动方程由它规定沿给定曲线如何比较向量。给定黎曼度量时，Levi-Civita 是唯一度量相容且无挠的联络；一般联络不必保持长度或夹角。

## 核心公式

- 协变导数：$\nabla_X Y = \left(X^i \partial_i Y^k + X^i Y^j \Gamma^k_{ij}\right) \partial_k$
- Christoffel 符号（Levi-Civita）：$\Gamma^k_{ij} = \frac{1}{2} g^{kl}(\partial_i g_{jl} + \partial_j g_{il} - \partial_l g_{ij})$
- 平行移动方程：$\frac{D V^k}{dt} = \dot V^k + \Gamma^k_{ij} \dot\gamma^i V^j = 0$
- 联络形式（主丛）：$\omega \in \Omega^1(P, \mathfrak{g})$，规范场 $A_\mu$ 即局部联络形式
- 曲率 = 联络的不交换性：$R(X,Y) = [\nabla_X, \nabla_Y] - \nabla_{[X,Y]}$

## 适用问题

- 跨点向量比较：不同点的切空间无法直接相加，需要联络规定的"搬运规则"
- 优化动量可用合适的 vector transport；不必每步求精确平行移动。
- 规范等变网络：局部坐标系（gauge）的选择自由由联络对齐
- 物理约束系统：电磁场 = U(1) 联络曲率，Yang-Mills = 非阿贝尔联络曲率

## AI 设计翻译

- **Vector transport 模块**：Riemannian 优化器中，将动量 $m_k \in T_{x_k}M$ 搬到 $T_{x_{k+1}}M$；闭式 transport（如 Stiefel 上的投影）可 GEMM 化
- **Gauge-equivariant CNN**：局部 frame 变化时，特征与边搬运同时变换，核满足等变态射条件；中间特征并不自动不变。
- **Parallel transport 正则化**：惩罚特征场在联络下的非平行性 $\|\nabla_X f\|^2$，强制特征沿流形平滑变化
- **联络学习**：单坐标图内可参数化联络系数；跨图时必须遵循 Christoffel 的非张量变换律。若要求 Levi-Civita，需从度量构造或约束无挠与度量相容。

## 工程可行性

GPU 友好度：联络的核心挑战是"串行 ODE 积分"。
- **闭式/近似向量运输**：依赖流形、度量与路径；Stiefel 切投影运输通常不是精确平行移动。
- **一般联络的平行移动**：沿曲线积分 $\dot{V} + \Gamma \dot\gamma V = 0$ 是串行 ODE，并行性差
- **Christoffel 计算**：全系数有 $O(n^3)$ 存储项；计算量还依赖度量导数与求解。通常只计算 Γ 与给定向量的缩并，避免全张量物化。
- **规范等变 CNN 中的联络**：每边一个 $G$-元素作用（矩阵乘特征向量），可表达为 sparse matmul 或 batched small GEMM
- 优化更新可比较 retraction 与适当 vector transport；retraction 移动点，transport 移动切向量，二者不能互换。

## 风险与失效条件

- **ODE 积分成本**：是否可近似取决于精度要求；闭式或近似 vector transport 是优化中的选择，不是所有精确平行移动任务的替代。
- **左右联络约定不统一**：左不变 vs 右不变联络的选择不一致导致梯度错位
- **规范自由度未正确处理**：gauge-equivariant 网络中若联络参数化不完备，等变性会悄悄破缺
- **Christoffel 符号的数值导数**：用有限差分估计 $\partial_i g_{jk}$ 时噪声大，最好有解析式或 autodiff
- **联络 ≠ 度量**：有联络不一定有相容度量（非度量联络），错误假设相容性会导致不一致

## 深入参考

- 蒸馏稿：../../references/books/differential-geometry.md（Ch 12 Connections and Covariant Derivatives, §12.2 联络形式, §12.4 Ehresmann, §12.12 G-联络）
- 蒸馏稿：../../references/books/differential-geometry.md（§6.8 Principal Bundles, §9.8 Electromagnetism）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 12（§12.1-§12.12 完整联络理论）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §13.1 Levi-Civita Connection


## 路由扩展
- 若需要曲率的定义 → `curvature.md`（曲率张量由联络导出）
- 若需要平行移动与测地线 → `geodesic.md`（测地线是平行移动的自平行曲线）
- 若需要协变导数的具体计算 → `tangent-space.md`（切空间上的协变微分）

## 可扩展方向
- Levi-Civita 联络：黎曼流形的唯一无挠度量联络
- Christoffel 符号：联络在坐标基下的分量
- 和乐（holonomy）：平行移动绕闭曲线的效果
- 挠率（torsion）：联络的非对称部分
- 仿射联络（affine connection）：一般的仿射联络理论
- Ehresmann 联络：纤维丛上的水平分布
- 规范联络（gauge connection）：物理中的规范场作为联络
