# 测地线 (Geodesic)

## 最小定义

测地线是流形上局部最短（或极值长度）的路径 $\gamma: [0,1] \to M$，满足自平行条件 $\nabla_{\dot\gamma} \dot\gamma = 0$——即切向量沿自身平行移动不变。指数映射 $\exp_p(v)$ 将切向量 $v \in T_pM$ 映为从 $p$ 出发、初速为 $v$ 的测地线在 $t=1$ 处的终点。

## 核心公式

- 测地方程：$\ddot\gamma^k + \sum_{ij} \Gamma^k_{ij} \dot\gamma^i \dot\gamma^j = 0$
- 指数映射：$\exp_p(v) = \gamma_v(1)$，其中 $\gamma_v$ 是 $\gamma(0)=p, \dot\gamma(0)=v$ 的测地线
- 对数映射：$\log_p(q)$ 在正常邻域中是 exp_p 的局部逆；越过分支或 cut locus 不能预设唯一的全局逆。
- Retraction：$R_p(0)=p$、$DR_p(0)=\mathrm{id}_{T_pM}$，且输出位于流形；这是局部一阶一致性，不是 Banach 意义的收缩映射。
- 半径 $r>0$ 球面：$\exp_p(v)=\cos(\|v\|/r)p+r\sin(\|v\|/r)v/\|v\|$，$\|p\|=r$、$p^Tv=0$；$v=0$ 用连续极限 $p$。

## 适用问题

- 约束优化：可采用满足条件的 retraction，不一定每步求精确测地线；所选更新需配合度量与收敛假设。
- 隐空间插值：latent space 中两点间的测地线比欧氏直线更尊重数据流形结构
- 流形距离：仅当 $\log_p(q)$ 选取到达 q 的最短测地分支时，$d(p,q)=\|\log_p(q)\|_g$。
- 数据增广：沿测地线采样生成新训练样本

## AI 设计翻译

- **Retraction-based 优化器**：每步做 $x_{k+1} = R_{x_k}(-\eta \cdot \text{grad})$，用闭式 retraction 替代 ODE 积分；球面用旋转、Stiefel 用 QR/Cayley、SO(3) 用 Rodrigues
- **测地线插值层**：在球面/双曲 latent space 中用闭式测地线做 mixup 和插值，$\gamma(t) = \exp_p(t \cdot \log_p(q))$
- **流形上的 momentum**：将动量向量通过 vector transport（平行移动的离散版）从 $T_{x_k}M$ 搬到 $T_{x_{k+1}}M$，再与新梯度合成
- **指数映射输出头**：网络在切空间 $\mathbb{R}^n$ 中自由预测，经 $\exp_p$ 投回合法流形，天然满足约束

## 工程可行性

GPU 友好度取决于是否有闭式 retraction：
- **闭式/有限代数步骤**：球面 exp 为 $O(n)$；Stiefel-QR 是 retraction，通常 $O(np^2)$，不是球面 exp 或常数成本。SO(3) 群 exp 只有在相应度量下才等于黎曼 exp。
- **无闭式的流形**：需要数值积分测地方程（二阶 ODE），串行递推，GPU 不友好
- 闭式 retraction 替代精确 exp：QR 分解、Cayley 变换等一阶近似，牺牲少量精度换取大幅加速
- 3x3/4x4 小矩阵 exp（SO(3)/SE(3)）可融进单 kernel，但吃不满 Tensor Core
- **数值分支**：零角的 sinθ/θ 是可去奇点；SO(3) Log 在 π 附近的分支/轴问题需另行处理，零角 Taylor 不能解决。

## 风险与失效条件

- **ODE 成本**：精确测地线距离任务不能任意换成 retraction；优化任务可比较 retraction 与 ODE 的成本及收敛条件。
- **数值分支**：小角可用 Taylor/sinc；割迹附近需处理 log 分支与非唯一性，不能靠小角 Taylor 消除拓扑问题。
- **Retraction 误差**：合法 retraction 每步仍在流形上；与 exp 的局部差异不等于约束漂移，有限精度约束残差另测。
- **Cut locus 问题**：超过沿某方向的 cut time，测地线失去最短性；割迹处最短 log 可能非唯一。$d(p,q)=\|\log_pq\|$ 只对最短分支成立。
- **为几何美强行流形化**：欧氏近似已足够的任务硬上测地线，增加复杂度和奇异点风险

## 深入参考

- 蒸馏稿：../../references/books/differential-geometry.md（Ch 13 §13.4 Geodesics, §13.11 Rauch Comparison）
- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 20 The Exponential Map）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §13.4 Geodesics
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 20（指数映射、retraction 原型）


## 路由扩展
- 若需要距离的具体定义 → `metric-tensor.md`（度量张量决定测地线）
- 若用于优化更新 → `../optimization/riemannian-optimization.md`（retraction 与收敛条件）。
- 若需要偏离平坦空间的程度 → `curvature.md`（曲率控制测地线偏差）

## 可扩展方向
- 共轭点（conjugate points）：测地线上 Jacobi 场的零点
- 割迹（cut locus）：测地线失去最优性的临界点
- Hopf-Rinow 定理：完备性与测地线存在性
- 测地凸性（geodesic convexity）：流形上的凸集与凸函数
- Jacobi 场（Jacobi field）：测地线变分的线性化
- 测地回归（geodesic regression）：流形上的回归分析
