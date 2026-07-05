# 流形 (Manifold)

## 最小定义

流形是局部同胚于欧氏空间 $\mathbb{R}^n$ 的拓扑空间。光滑流形进一步要求坐标卡之间的转移映射 $\phi_\beta \circ \phi_\alpha^{-1}$ 是 $C^\infty$ 光滑的，使得微积分可以在弯曲空间上进行。

## 核心公式

- 坐标卡：$(U_\alpha, \phi_\alpha)$，其中 $\phi_\alpha: U_\alpha \to \mathbb{R}^n$ 是同胚
- 光滑转移映射：$\phi_\beta \circ \phi_\alpha^{-1}: \phi_\alpha(U_\alpha \cap U_\beta) \to \phi_\beta(U_\alpha \cap U_\beta) \in C^\infty$
- Whitney 嵌入定理：$n$ 维流形可嵌入 $\mathbb{R}^{2n}$

## 适用问题

- 数据本身住在非欧空间：旋转 SO(3)、协方差矩阵 SPD(n)、方向数据 $S^2$、图与网格
- 参数有几何约束（正交、单位范数、低秩），需要把约束集识别为子流形
- 隐空间几何建模：插值、聚类、最近邻需要尊重数据的内在弯曲结构
- 降维与嵌入：高维数据的低维流形假设（manifold hypothesis）

## AI 设计翻译

- **流形优化器（Riemannian SGD/Adam）**：梯度投影到切空间 + retraction 回流形，替代投影梯度下降的 ad-hoc 修补
- **隐空间几何模块**：在 VAE/GAN 的 latent space 中用流形结构做测地插值，替代欧氏线性插值
- **约束重参数化层**：将正交/SPD/单位范数约束编码为流形参数化（如 Cayley 变换、矩阵指数），输出天然满足约束
- **流形假设驱动的架构设计**：用流形维数估计指导隐空间维度选择，避免维度诅咒

## 工程可行性

GPU 友好度中等。坐标卡变换本身是逐元素的映射（可并行），但核心瓶颈在于：
- 转移映射若为闭式（球面、双曲空间）：可直接张量化，batched 逐样本计算，GPU 友好
- 转移映射若需迭代求解（一般流形）：串行依赖、不可张量化，GPU 不友好
- 单位分解（partition of unity）涉及局部加权求和，可表达为稀疏 matmul
- 关键操作复杂度取决于具体流形：简单流形 $O(1)$/样本，复杂流形可能 $O(n^3)$

## 风险与失效条件

- **全局坐标卡幻觉**：试图用单一参数化覆盖整个流形必有奇点（如欧拉角的 gimbal lock），需要 atlas / 冗余参数化
- **流形假设滥用**：数据实际分布在平坦欧氏空间时硬套流形结构，纯属过度工程
- **低精度不稳定**：坐标变换中的矩阵 exp/log/eig 在 fp16/bf16 下灾难性不稳定，常静默发散
- **维数估计错误**：Whitney 嵌入定理给出上界 $2n$，实际嵌入维数选择缺乏理论指导

## 深入参考

- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 1-2 Smooth Manifolds / Smooth Maps）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 1-2 Differentiable Manifolds / The Tangent Structure）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition, Ch 1-2（拓扑流形、光滑结构、单位分解）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 1-2


## 路由扩展
- 若需要局部结构分析 → `tangent-space.md`（切空间提供局部线性近似）
- 若需要距离定义 → `metric-tensor.md`（度量张量定义流形上的距离）
- 若需要在流形上做优化 → `riemannian-optimization.md`（黎曼优化方法）

## 可扩展方向
- 子流形（submanifold）：嵌入子流形与浸没子流形
- 积流形（product manifold）：多个流形的直积构造
- 商流形（quotient manifold）：等价关系下的商空间
- Stiefel / Grassmann 流形：正交矩阵与子空间流形
- 流形学习（Isomap / LLE / diffusion maps）：从高维数据发现低维流形
