# 流形与微分几何 / Manifolds & Differential Geometry

> **Manifolds and Differential Geometry** — Jeffrey M. Lee
> American Mathematical Society, *Graduate Studies in Mathematics*, Volume 107 (2009), ISBN 978-0-8218-4815-9.
> MSC: 58A05, 53C05, 22E15, 53C20, 53B30, 55R10. 本文件是「激活」摘要，非原文转录；全保真回查见末尾「深挖入口」。

## 概要

本书是一部从零构建**光滑流形（smooth manifold）→ 张量 / 微分形式 → 联络与曲率 → 黎曼几何**的研究生教材。它的主线不是"在欧氏空间里算"，而是**在弯曲空间上做微积分**：当没有全局坐标、没有"自然"的向量加法时，如何定义微分、如何比较不同点的向量、如何度量距离与弯曲程度。这恰好是把"参数空间是平坦欧氏的"这一默认假设打破后，深度学习需要的语言。

前言里有一句对 AI 研究极关键的话：**纤维丛上的联络（connection on a fiber bundle）与物理学的规范场（gauge field）是数学家与物理学家各自独立发现的同一个概念**（前言脚注 2）。这正是本技能包反复强调的"跨域激活"原型——结构早就在那里，只差有人把它接到算法设计上（规范等变网络就是这次接驳的产物）。

真实章节地图（按依赖排序，章号与节号经 PDF 目录核对）：

| 章 | 标题 | 对 AI 的钩子 |
|----|------|-------------|
| 1–2 | Differentiable Manifolds / The Tangent Structure | 切空间（tangent space）= 局部线性化、梯度的归属空间 |
| 3 | Immersion and Submersion | 子流形、降维 / 嵌入 |
| 4 | Curves and Hypersurfaces in Euclidean Space | Gauss / mean curvature 的几何直觉来源 |
| 5 | Lie Groups | 连续对称群、指数映射、伴随表示 → 等变架构 |
| 6 | Fiber Bundles（§6.1 一般丛, §6.2 向量丛, §6.8 主丛与配丛）| **规范等变的几何骨架** |
| 7 | Tensors（§7.6 Metric Tensors）| 度量张量 g = 内积场 → Fisher 度量 |
| 8 | Differential Forms（§8.5 丛值形式）| 反对称张量、外微分、规范场强 |
| 9 | Integration and Stokes' Theorem（§9.8 Electromagnetism）| Maxwell = U(1) 联络曲率的实例 |
| 10 | De Rham Cohomology | 整体拓扑不变量（积分守恒量）|
| 11 | Distributions and Frobenius' Theorem | 可积性、约束分布 |
| 12 | Connections and Covariant Derivatives（§12.2 联络形式, §12.4 Ehresmann, §12.5/§12.10 曲率, §12.12 G-联络）| **平行移动 + 曲率** |
| 13 | Riemannian & Semi-Riemannian Geometry（§13.1 Levi-Civita, §13.2 Riemann 曲率, §13.4 测地线, §13.7 Jacobi 场, §13.11 Rauch 比较）| **自然梯度 / 优化地形** |

## 可迁移到 AI/Infra 的核心结构

- **度量与微分**：黎曼度量 g 在每个切空间上给出正定内积。dL 是余向量，grad_g L = g⁻¹dL 是向量。正则、可识别统计族的 Fisher 信息可给出这样的度量；冗余参数化时它可能奇异。Fisher 度量也不必有非零曲率：固定协方差的高斯位置族具有常数度量。
- **联络与搬运**：联络规定协变导数和沿给定曲线的平行移动。Levi-Civita 联络唯一地同时满足度量相容与无挠。优化器动量应一致地搬运；实用 vector transport 需符合方法的要求，但不必等于精确平行移动。
- **黎曼曲率与损失 Hessian**：R(X,Y)Z = ∇_X∇_Y Z − ∇_Y∇_X Z − ∇_[X,Y]Z 描述联络的曲率；Hess_g L = ∇dL 还依赖具体目标函数。两者不是同一张量：欧氏空间 R=0，而 L(x)=‖x‖²/2 的 Hessian 为 I。Sharpness 或 HVP 不等于完整黎曼曲率测量。
- **Jacobi 场与优化**：Jacobi 场和 Rauch 比较研究满足曲率条件的测地线变分。梯度流一般不是测地线，其稳定性要分析自己的线性化动力学与目标 Hessian；几何类比不能写成等价定理。
- **测地线与指数映射**：exp_p(v) 是从 p 以初速度 v 出发的测地线在时间 1 到达的点，前提是该解存在。测地线只在足够短的区间内最短，不保证任意时间或越过 cut locus 后仍最短；半黎曼情形更不能笼统称距离最小化。Retraction 只要求在零向量处满足位置与一阶一致性，不必沿测地线。
- **规范结构**：主丛编码局部 frame 选择，联络用于搬运表示，曲率刻画场强。中间特征通常在规范变化下等变；某个读出是否不变要另行设计。
- **李群**：exp: 𝔤→G 与 Ad 连接无穷小坐标和有限变换。一般 Stiefel/Grassmann 是齐性空间，不具备同样的自身群乘法；先定义实际群作用，再谈网络等变保证。

## 适合激活的问题类型

- 优化在**欧氏假设下病态 / 收敛慢**，但底层参数有自然的概率或几何结构（用度量重新定义"距离"）。
- 数据本身住在**非欧流形**上：协方差 / SPD 矩阵、旋转 SO(3)、方向数据、图与网格、球面信号。
- 需要**严格的对称 / 等变保证**：旋转、平移、局部规范变换下输出可预测地变化。
- 需要把**"坐标选择的任意性"**显式建模成对称性（多视角、多 frame、传感器姿态无关）。
- 想用**几何量（曲率 / 测地距离）做正则或诊断**：sharpness、泛化、轨迹稳定性。

## 可能的算法启发

- **自然梯度 / K-FAC [~]**：求解 Fv=dL 或适当正则化的系统。K-FAC 用 A⊗B 近似层块；近似、阻尼以及有限的坐标加法更新可能破坏精确重参数化不变性。内禀自然梯度流一般也不是 Fisher 测地线。
- **黎曼优化 [~]**：为 SPD/Stiefel/Grassmann/双曲参数选择度量、梯度、retraction 和 vector transport。将环境欧氏梯度投影到切空间适用于诱导度量，不能概括所有度量。
- **规范等变层 [~]**：定义输入输出表示的变换律，并逐层约束交换关系。Frame 对齐本身不能证明所有特征不变。
- **目标尖锐度诊断 [~]**：在明确的范数与参数化下用 HVP 或方向二阶导研究损失 Hessian；不能把它标为黎曼曲率估计，其与泛化的联系另需证据。
- **测地插值 [~]**：选择度量和最短分支，检查 cut locus/非唯一性，再验证任务表现。尊重某个建模几何本身不保证增广质量更好。

## GPU 友好性警告

按 `../gpu-friendly-math.md` 选择影响当前决策的实现维度。以下成本属于具体表示，不是所有几何方法的定律。

- **D2/D3/D4 [v]**：显式 N×N Fisher 占 O(N²) 空间，常规稠密分解约 O(N³)。优先求解线性系统而非物化逆。可选矩阵无关 Fisher-vector product 加迭代求解、对角/分块近似或 Kronecker 因子；结构因子化不是唯一可行路线。
- **K-FAC [~]**：a×a 与 b×b 因子的存储为 O(a²+b²)，稠密因子分解为 O(a³+b³)，另计统计量和预条件作用成本。(A⊗B)⁻¹=A⁻¹⊗B⁻¹ 要求因子可逆；对整体加 λI 不一般等于分别给两个因子加阻尼。
- **D4 [~]**：HVP 避免物化损失 Hessian，通常成本接近少量梯度计算，但取决于模型计算图和保存的激活，不是无条件 O(N)。HVP 不是四阶黎曼曲率张量的作用。
- **D5 [~]**：检查条件数与求解残差，对照较高精度并按需正则化；阻尼会改变算子/度量，单靠 fp32 不能保证逆的精度。
- **D1/D6/D7/D8 [~]**：低维闭式搬运、小群、批处理与融合可能高效。连续群采样仅是一种路线，表示约束可在不枚举群元素时保持精确等变；离散化或表示截断需单独误差分析。

低维精确几何并非天然不可计算。根据实测成本和所需保证，在解析式、迭代求解和近似之间选择。

## 该调用哪个思想透镜

- **symmetry（对称与不变性）—— 首选。** 规范等变、李群对称、纤维丛 = 把"frame / 坐标选择无关"编码成对称性，是本书与 DL 最强的接口。
- **variational（变分）—— 并列首选。** 自然梯度、Riemannian SGD、曲率正则都是"在弯曲约束空间里找最优"。
- **duality（对偶）**：指数 / 对数映射、retraction、坐标变换简化问题。
- **geometric（几何）**：把参数 / 数据空间显式建模为流形，再翻译回算法。
- **topological（拓扑）**：辅助——de Rham 上同调 / 整体不变量用于守恒量与可积性诊断。

组合建议：先 `symmetry` 定对称结构 → `variational` 落到自然梯度 / Riemannian 优化 → `duality` 处理 retraction → 在涉及实现时按 `../gpu-friendly-math.md` 检查适用成本与风险。

## 反模式

- 混同黎曼曲率、目标 Hessian 与依赖参数化的 sharpness；先说明张量、度量与所求性质。
- 将任意自然梯度离散更新称为测地步，或在任意阻尼/离散化后仍声称精确重参数化不变。
- 认为所有测地线全局最短，或跨 cut locus 使用同一个 Log 分支。
- 只需要 Fisher 作用却物化大稠密矩阵；应比较矩阵无关求解和结构近似。
- 把规范等变特征叫作不变特征，或认为连续群等变必然依赖采样。
- 把几何术语当成性能证据；分开验证基线、数学保证、求解精度和实测成本。

## 深挖入口

> **书目信息**：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Graduate Studies in Mathematics Vol. 107, American Mathematical Society, 2009. ISBN 978-0-8218-4815-9.
>
> **启用方式**：将 `Manifolds and Differential Geometry.pdf` 放入项目根目录的 `math_book/` 文件夹，Agent 即可自动搜索原文。PDF 不随 npm/git 分发（版权原因），需自行获取。

> 全保真回查 = 让 Agent **自动搜索本地 PDF** `math_book/Manifolds and Differential Geometry.pdf`（按章号 / 节号定位，勿凭记忆复述）。本摘要只给坐标，不替代原文。

- **§6.8 Principal and Associated Bundles** + **§12.12 G-Connections**：规范等变的几何基础（主丛 + 联络 = 规范场）。
- **§7.6 Metric Tensors** + **§13.1 Levi-Civita Connection**：度量张量与自然梯度 / Fisher 度量的源头。
- **§13.2 Riemann Curvature Tensor** + **§13.7 Jacobi Fields**：曲率与优化地形、轨迹稳定性。
- **§13.4 Geodesics** + **§13.11 Rauch's Comparison Theorem**：测地线 / retraction 与收敛—发散比较。
- **§9.8 Electromagnetism**：规范场作为 U(1) 联络曲率的具体实例（跨域激活的历史样板）。
