# 等变性 (Equivariance)

## 最小定义

映射 $f: X \to Y$ 关于群 $G$ 的作用等变，若 $f(g \cdot x) = g \cdot f(x)$ 对所有 $g \in G, x \in X$ 成立。等变性是比不变性（$f(g \cdot x) = f(x)$）更精细的结构保持：输出随输入按同一群作用"协动"。

## 核心公式

- 等变性条件：$f(\rho_X(g) x) = \rho_Y(g) f(x), \quad \forall g \in G$
- 不变性 = 等变到平凡表示：$f(g \cdot x) = f(x)$（$\rho_Y = \text{id}$）
- 卷积的平移等变性：$f(T_a x) = T_a f(x)$，其中 $T_a$ 是平移算子
- 规范等变性：$f_{A^g}(\rho_X(g)x)=\rho_Y(g)f_A(x)$，同时变换特征与联络。离散搬运满足 $T_{ij}\mapsto g_iT_{ij}g_j^{-1}$。
- 指数映射的共轭等变：$\exp(\operatorname{Ad}_g\xi)=g\exp(\xi)g^{-1}$；它不是任意 $f$ 的性质。

## 适用问题

- 3D 点云/分子：输入旋转后，输出（分割/力/位姿）应同样旋转
- 球面/流形上的信号处理：局部坐标选择不应影响预测结果
- 多视角/多传感器：相机朝向变化时，特征应协变而非重新学习
- 物理模拟：力、速度等矢量应随坐标系变换正确旋转

## AI 设计翻译

- **E(n)-等变 GNN**：$x_i\mapsto x_i+\sum_j\phi(r_{ij})(x_i-x_j)$ 在系数依赖不变标量（如距离）、邻接和聚合也相容时等变；不能给一般方向相关系数同样保证。
- **Gauge-equivariant CNN**：边搬运和特征均遵循局部 frame 变换律；核满足 intertwiner 条件，中间特征通常等变，不变读出需另行构造。
- **Steerable CNN**：特征场是群表示的直和 $\bigoplus_l \rho_l$，卷积核被 Schur 引理约束为块结构，参数少但严格等变
- **位姿输出头**：先区分左乘等变 $f(gX)=g f(X)$ 与共轭等变。仅用 exp 并不能保证左乘位姿等变；需对输入编码、群作用与输出构造作完整证明。
- **等变性验证损失**：$L_{\text{eq}} = \|f(g \cdot x) - g \cdot f(x)\|^2$ 作为辅助正则，强制近似等变

## 工程可行性

GPU 友好度取决于群的离散化程度：
- **离散群（$C_n$, 八面体群等）**：群卷积可展开为 GEMM，等变约束使权重块对角化（参数减少），GPU 友好
- **平移群（CNN）**：无限或周期网格上、stride 1 且边界处理相容的卷积可精确平移等变；padding、下采样与有限裁剪会改变可保证的平移集合。
- **SO(3)/SE(3)**：可用谐波表示，也可用不变标量系数与相对向量构造等变层；连续群不强制离散枚举。
- **Gauge-equivariant**：每边一个 $G$-元素作用 = 小矩阵乘特征向量，可表达为 sparse matmul
- **近似等变（正则化）**：等变性损失 $L_{\text{eq}}$ 是普通的 MSE，完全 GPU 友好，但等变性不严格
- 关键权衡：严格等变（结构约束）vs 近似等变（正则化）——前者参数少但实现复杂，后者简单但不保证

## 风险与失效条件

- **连续群离散化误差**：采样不当导致等变性悄悄破缺，验证时通过但推理时失败
- **等变性与表达力的权衡**：严格等变约束减少参数空间，可能不足以拟合复杂函数
- **多群作用的组合爆炸**：同时要求旋转 + 平移 + 置换等变时，约束交叉复杂
- **数据噪声破坏等变性**：传感器噪声使 $g \cdot x$ 的精确计算不可靠，等变性前提失效
- **等变层的数值精度**：球谐/CG 系数在大 $l$ 下的浮点误差会破坏等变性，需 fp32 累加
- **过度等变约束**：任务只需近似对称时硬上严格等变，不如用正则化软约束

## 深入参考

- 蒸馏稿：../../references/books/micro-lie-theory.md（§II-F 伴随 Ad_X，等变性的代数实现）
- 蒸馏稿：../../references/books/differential-geometry.md（§6.8 Principal Bundles, §12.12 G-Connections, 规范等变）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 5 Lie Groups, 连续对称作为先验）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §6.8 + §12.12（规范等变的几何基础）


## 路由扩展
- 若需要表示理论基础 → `representation.md`（等变映射是表示间态射）
- 若需要群作用结构 → `group-action.md`（等变性定义依赖群作用）
- 若用于注意力机制设计 → `equivariant-attention`（设计模式层的等变注意力）

## 可扩展方向
- 可操纵特征（steerable features）：SO(3) 下的可操纵特征表示
- 球谐函数（spherical harmonics）：SO(3) 不可约表示的基函数
- Wigner D-矩阵：SO(3) 表示的矩阵元
- 等变映射代数（equivariant map algebra）：等变线性映射的完全刻画
- 通用等变架构（universal equivariant architectures）：等变函数的通用逼近
- 对称破缺（symmetry breaking）：近似等变或可控对称破缺
- 近似等变（approximate equivariance）：噪声或离散化下的近似等变性
