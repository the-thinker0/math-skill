# 曲率 (Curvature)

## 最小定义

采用 $R(X,Y)Z=\nabla_X\nabla_YZ-\nabla_Y\nabla_XZ-\nabla_{[X,Y]}Z$。Riemann 曲率描述联络的局部路径依赖；损失函数 Hessian 描述二阶变化，两者不是同一个对象。欧氏空间的 Riemann 曲率为零，损失 Hessian 仍可非零。

## 核心公式

- 定义分量为 $R(\partial_i,\partial_j)\partial_k=R^l_{ijk}\partial_l$：
  $R^l_{ijk}=\partial_i\Gamma^l_{jk}-\partial_j\Gamma^l_{ik}+\Gamma^l_{im}\Gamma^m_{jk}-\Gamma^l_{jm}\Gamma^m_{ik}$。
- 此约定下 $\operatorname{Ric}_{jk}=\sum_i R^i_{ijk}$，$S=g^{jk}\operatorname{Ric}_{jk}$。
- $K(X,Y)=\langle R(X,Y)Y,X\rangle/(\|X\|^2\|Y\|^2-\langle X,Y\rangle^2)$，要求 $X,Y$ 线性无关。
- 沿测地线的 Jacobi 场：$D_t^2J+R(J,\dot\gamma)\dot\gamma=0$。
- 对固定 $v$ 和二次可微标量损失，$Hv=\nabla(\nabla L\cdot v)$。若 $\mathbb E[vv^T]=I$，则 $\mathbb E[v^THv]=\operatorname{tr}H$；这是 Hessian 迹，不是标量曲率。

## 适用问题

- 流形几何：比较测地线、分析局部曲率与所选度量。
- 优化诊断：用 Hessian 的 Rayleigh 商、谱与 HVP 分析损失局部敏感性；明确坐标和尺度。
- 泛化研究：检验尖锐度是否与独立测试误差相关，不能从平坦性单独推出泛化。

## AI 设计翻译

- **HVP 诊断**：在 $\|v\|=1$ 下估计 $v^THv$；最大 Rayleigh 商为最大特征值，不能省略单位范数约束。
- **SAM 类启发**：参数邻域内的最坏损失与 Hessian 可在局部展开下联系；SAM 不等同于最小化 Riemann 曲率。
- **轨迹稳定性**：梯度流的线性化由损失 Hessian 控制；只有测地线变分才直接使用 Jacobi 方程。
- **图重连**：离散 Ricci 曲率可作瓶颈候选指标，须指定离散定义并比较任务效果，不以负值自动判定增边。

## 工程可行性

- Riemann 张量完整存储为 $O(n^4)$，Hessian 为 $O(N^2)$；低维几何可显式计算，大模型优先收缩量或矩阵作用。
- HVP 可通过混合模式自动微分获得，成本通常与常数次梯度计算同阶；应按计算图成本与激活量估算，不能只按参数数 $N$ 宣称 $O(N)$。
- Hutchinson 估计使用独立 Rademacher/标准高斯方向；报告采样数与方差，使用固定单位向量时需重新检查归一化因子。
- fp32 累加、方向归一化与有限差分步长需要验证；提高精度不是任意病态问题的保证。

## 风险与失效条件

- 曲率张量符号约定不同会改变 Ricci 收缩；同一推导不可混用。
- Hessian 迹、最大特征值与流形标量曲率不可互换。
- 重参数化可改变欧氏尖锐度；比较模型需固定坐标和尺度。
- 数值 HVP、有限样本迹估计只提供计算证据，不是全局收敛或泛化证明。

## 深入参考

- [微分几何书稿](../../references/books/differential-geometry.md)：联络、Riemann 曲率与 Jacobi 场。
- [Pearlmutter, Fast Exact Multiplication by the Hessian](https://www.bcl.hamilton.ie/~barak/papers/nc-hessian.pdf)：自动微分 HVP。

## 路由扩展

- 度量与联络：`metric-tensor.md`、`connection.md`。
- 优化与谱敏感性：`../matrix-analysis/matrix-perturbation.md`。

## 可扩展方向

比较几何、Gauss–Bonnet、曲率流与坐标不变的尖锐度诊断，均需相应条件。
