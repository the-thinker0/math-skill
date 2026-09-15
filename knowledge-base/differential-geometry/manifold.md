# 流形 (Manifold)

## 最小定义

本文的有限维拓扑流形要求 Hausdorff、第二可数，且局部同胚于欧氏空间 $\mathbb{R}^n$ 的拓扑空间。光滑流形进一步要求坐标卡之间的转移映射 $\phi_\beta \circ \phi_\alpha^{-1}$ 是 $C^\infty$ 光滑的，使得微积分可以在弯曲空间上进行。

## 核心公式

- 坐标卡：$\phi_\alpha:U_\alpha\to\phi_\alpha(U_\alpha)\subseteq\mathbb R^n$ 是到欧氏开子集的同胚。
- 光滑转移映射：$\phi_\beta \circ \phi_\alpha^{-1}: \phi_\alpha(U_\alpha \cap U_\beta) \to \phi_\beta(U_\alpha \cap U_\beta) \in C^\infty$
- 强 Whitney 嵌入定理：$n>0$ 的光滑流形可光滑嵌入 $\mathbb R^{2n}$；不是任意拓扑空间的维数压缩保证。

## 适用问题

- 几何数据如 SO(3)、SPD(n)、球面；图和网格需先检查是否构成流形，分叉图或非流形网格不自动满足定义。
- 参数有几何约束（正交、单位范数、低秩），需要把约束集识别为子流形
- 隐空间几何建模：插值、聚类、最近邻需要尊重数据的内在弯曲结构
- 降维与嵌入：高维数据的低维流形假设（manifold hypothesis）

## AI 设计翻译

- **流形优化器**：按选定度量求梯度，再应用 retraction 与一致的状态搬运；环境欧氏梯度的切空间投影仅适用于相应诱导度量。
- **隐空间几何模块**：在 VAE/GAN 的 latent space 中用流形结构做测地插值，替代欧氏线性插值
- **约束重参数化层**：将正交/SPD/单位范数约束编码为流形参数化（如 Cayley 变换、矩阵指数），输出天然满足约束
- **维数指导的架构设计**：用内在维数估计作为隐空间选型的证据，同时报告采样、失真与泛化；低维流形假设本身不保证避免维度诅咒。

## 工程可行性

坐标变换不必逐元素，坐标间耦合及 Jacobian/求解器决定成本。解析变换和迭代求解都可以批处理，存在迭代不等于无法张量化。球面操作可随环境维数为 O(n)，矩形 QR 为 O(np²)，稠密 SPD 特征分解为 O(n³)；说明维度与求解精度，不把所有简单流形统一记为 O(1)。

单位分解能在通常的仿紧光滑流形上构造加权光滑函数，但不自动保留流形值输出或非线性约束。单独检查投影/retraction、内存与低精度残差。

## 风险与失效条件

- **全局图条件**：欧氏空间与 SPD 等可有全局图，球面/旋转不能默认单图全覆盖；按实际参数化检查覆盖与奇点。
- **流形假设滥用**：数据实际分布在平坦欧氏空间时硬套流形结构，纯属过度工程
- **低精度风险**：exp/log/eig 的误差依赖条件数、谱间隙、分支与算法，先用较高精度参考检查约束和梯度残差。
- **维数估计错误**：Whitney 嵌入定理给出上界 $2n$，实际嵌入维数选择缺乏理论指导

## 深入参考

- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 1-2 Smooth Manifolds / Smooth Maps）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 1-2 Differentiable Manifolds / The Tangent Structure）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition, Ch 1-2（拓扑流形、光滑结构、单位分解）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 1-2


## 路由扩展
- 若需要局部结构分析 → `tangent-space.md`（切空间提供局部线性近似）
- 若需要距离定义 → `metric-tensor.md`（度量张量定义流形上的距离）
- 若需要在流形上做优化 → `../optimization/riemannian-optimization.md`（黎曼优化方法）

## 可扩展方向
- 子流形（submanifold）：嵌入子流形与浸没子流形
- 积流形（product manifold）：多个流形的直积构造
- 商流形（quotient manifold）：等价关系下的商空间
- Stiefel / Grassmann 流形：正交矩阵与子空间流形
- 流形学习（Isomap / LLE / diffusion maps）：从高维数据发现低维流形
