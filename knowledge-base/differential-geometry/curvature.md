# 曲率 (Curvature)

## 最小定义

曲率度量流形"弯不弯"以及"路径依不依赖"。Riemann 曲率张量 $R(X,Y)Z = \nabla_X\nabla_Y Z - \nabla_Y\nabla_X Z - \nabla_{[X,Y]}Z$ 描述向量绕无穷小平行四边形平行移动一圈后的偏转。截面曲率 $K(\sigma)$ 是其最简标量提取。

## 核心公式

- Riemann 曲率张量：$R^l_{ijk} = \partial_i \Gamma^l_{jk} - \partial_j \Gamma^l_{ik} + \Gamma^l_{im}\Gamma^m_{jk} - \Gamma^l_{jm}\Gamma^m_{ik}$
- Ricci 曲率（缩并）：$R_{ij} = \sum_k R^k_{ikj}$
- 标量曲率：$S = \sum_{ij} g^{ij} R_{ij}$
- 截面曲率：$K(X,Y) = \frac{\langle R(X,Y)Y, X\rangle}{\|X\|^2\|Y\|^2 - \langle X,Y\rangle^2}$
- Jacobi 方程：$\frac{D^2 J}{dt^2} + R(J, \dot\gamma)\dot\gamma = 0$（描述测地线的发散/汇聚）
- Hessian-vector product：$Hv = \nabla(\nabla L \cdot v)$，$O(N)$ 估计曲率信息

## 适用问题

- 损失地形分析：曲率决定条件数与尖锐度，尖锐极小 vs 平坦极小的区分
- 优化轨迹稳定性：Jacobi 场描述相邻优化轨迹的发散/汇聚
- 泛化性诊断：平坦极小（低曲率）往往泛化更好
- 流形学习：数据流形的曲率指导隐空间维数和度量选择

## AI 设计翻译

- **曲率正则化（SAM 的几何视角）**：用 Hessian-vector product 估计 $\max_v v^T H v$，惩罚尖锐极小，偏好 flat minima
- **HVP-based 诊断器**：$\|Hv\|/\|v\|$ 作为 loss landscape 曲率的廉价代理，用于学习率自适应和早停
- **Jacobi 场轨迹监控**：跟踪两条相邻优化轨迹的距离变化，$J''(t) + R(J,\dot\gamma)\dot\gamma = 0$ 的离散版，检测发散/收敛
- **Ricci-flow 启发式图重连**：用离散 Ricci 曲率指导图/注意力结构的动态调整（负曲率边=瓶颈，需增连）

## 工程可行性

GPU 友好度：曲率的核心难点是"不能物化全张量"。
- **Riemann 张量**：4 阶，$n^4$ 个分量，物化即爆显存，**禁止显式计算**
- **Hessian-vector product (HVP)**：通过 Pearlmutter 算法，一次前向 + 一次反向即可得到 $Hv$，$O(N)$ 时间 $O(N)$ 显存，GPU 友好
- **Ricci/标量曲率的 Monte Carlo 估计**：随机采样方向 $v$，$\mathbb{E}[v^T H v] = \text{tr}(H)$，用 Hutchinson 估计，GPU 友好
- **Jacobi 场**：需要沿轨迹积分二阶 ODE，串行递推，GPU 不友好；工程上用离散差分近似
- 低精度：HVP 中的二阶导在 fp16 下噪声大，需 fp32 累加

## 风险与失效条件

- **物化全 Riemann/Hessian 张量**：$O(N^2)$~$O(N^4)$ 显存，$N \sim 10^9$ 时不可能
- **曲率估计信噪比低**：HVP 的 Monte Carlo 估计方差大，小 batch 下信号可能被噪声淹没
- **把曲率正则当万能药**：曲率估计本身昂贵（每次需额外前向+反向），收益不确定时需先小规模验证
- **离散近似误差**：用有限差分近似 Jacobi 场/HVP 时，步长选择敏感——太大截断误差大，太小浮点抵消

## 深入参考

- 蒸馏稿：references/books/differential-geometry.md（Ch 12 §12.5/§12.10 Curvature, Ch 13 §13.2 Riemann Curvature, §13.7 Jacobi Fields, §13.11 Rauch Comparison）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §13.2 Riemann Curvature Tensor, §13.7 Jacobi Fields
