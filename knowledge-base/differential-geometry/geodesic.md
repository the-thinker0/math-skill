# 测地线 (Geodesic)

## 最小定义

测地线是流形上局部最短（或极值长度）的路径 $\gamma: [0,1] \to M$，满足自平行条件 $\nabla_{\dot\gamma} \dot\gamma = 0$——即切向量沿自身平行移动不变。指数映射 $\exp_p(v)$ 将切向量 $v \in T_pM$ 映为从 $p$ 出发、初速为 $v$ 的测地线在 $t=1$ 处的终点。

## 核心公式

- 测地方程：$\ddot\gamma^k + \sum_{ij} \Gamma^k_{ij} \dot\gamma^i \dot\gamma^j = 0$
- 指数映射：$\exp_p(v) = \gamma_v(1)$，其中 $\gamma_v$ 是 $\gamma(0)=p, \dot\gamma(0)=v$ 的测地线
- 对数映射：$\log_p(q) = v \in T_pM$ 使得 $\exp_p(v) = q$（指数映射的逆）
- Retraction（工程近似）：$R_p(v) \approx \exp_p(v)$，只需一阶近似即可用于优化
- 单位球面闭式：$\exp_p(v) = \cos(\|v\|)\, p + \sin(\|v\|)\, \frac{v}{\|v\|}$（要求 $\|p\|=1$ 且 $v \perp p$；半径 $r$ 的球面把 $\|v\|$ 换成 $\|v\|/r$）

## 适用问题

- 约束优化：在 SPD/Stiefel/Grassmann/双曲流形上做 SGD，更新步需要沿测地线移动
- 隐空间插值：latent space 中两点间的测地线比欧氏直线更尊重数据流形结构
- 流形上的距离计算：$d(p,q) = \|\log_p(q)\|_g$
- 数据增广：沿测地线采样生成新训练样本

## AI 设计翻译

- **Retraction-based 优化器**：每步做 $x_{k+1} = R_{x_k}(-\eta \cdot \text{grad})$，用闭式 retraction 替代 ODE 积分；球面用旋转、Stiefel 用 QR/Cayley、SO(3) 用 Rodrigues
- **测地线插值层**：在球面/双曲 latent space 中用闭式测地线做 mixup 和插值，$\gamma(t) = \exp_p(t \cdot \log_p(q))$
- **流形上的 momentum**：将动量向量通过 vector transport（平行移动的离散版）从 $T_{x_k}M$ 搬到 $T_{x_{k+1}}M$，再与新梯度合成
- **指数映射输出头**：网络在切空间 $\mathbb{R}^n$ 中自由预测，经 $\exp_p$ 投回合法流形，天然满足约束

## 工程可行性

GPU 友好度取决于是否有闭式 retraction：
- **有闭式的流形**（球面、双曲、SO(3)、Stiefel-QR）：$\exp_p(v)$ 是有限项代数表达式，$O(1)$/样本，可 batched 张量化，GPU 友好
- **无闭式的流形**：需要数值积分测地方程（二阶 ODE），串行递推，GPU 不友好
- 闭式 retraction 替代精确 exp：QR 分解、Cayley 变换等一阶近似，牺牲少量精度换取大幅加速
- 3x3/4x4 小矩阵 exp（SO(3)/SE(3)）可融进单 kernel，但吃不满 Tensor Core
- **低精度致命点**：$\sin\theta/\theta$、$(1-\cos\theta)/\theta^2$ 在 $\theta \to 0$ 时除零，$\theta \to \pi$ 时 log 奇异，fp16 直接 NaN

## 风险与失效条件

- **逐步 ODE 积分做测地线**：串行递推杀死 GPU 并行度，必须用闭式 retraction 替代
- **小角/大角奇异点**：$\theta \to 0$ 和 $\theta \to \pi$ 处的数值不稳定在低精度下被灾难性放大，必须做 Taylor 展开兜底
- **Retraction 误差累积**：一阶近似在多步迭代中误差可能累积，需偶尔做一次精确投影校正
- **Cut locus 问题**：指数映射在 cut locus 以外不再是最短路径，$\log_p(q)$ 可能不存在或不唯一
- **为几何美强行流形化**：欧氏近似已足够的任务硬上测地线，增加复杂度和奇异点风险

## 深入参考

- 蒸馏稿：../../references/books/differential-geometry.md（Ch 13 §13.4 Geodesics, §13.11 Rauch Comparison）
- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 20 The Exponential Map）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §13.4 Geodesics
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 20（指数映射、retraction 原型）


## 路由扩展
- 若需要距离的具体定义 → `metric-tensor.md`（度量张量决定测地线）
- 若用作收缩映射 → `../optimization/riemannian-optimization.md`（指数映射作为收缩映射）
- 若需要偏离平坦空间的程度 → `curvature.md`（曲率控制测地线偏差）

## 可扩展方向
- 共轭点（conjugate points）：测地线上 Jacobi 场的零点
- 割迹（cut locus）：测地线失去最优性的临界点
- Hopf-Rinow 定理：完备性与测地线存在性
- 测地凸性（geodesic convexity）：流形上的凸集与凸函数
- Jacobi 场（Jacobi field）：测地线变分的线性化
- 测地回归（geodesic regression）：流形上的回归分析
