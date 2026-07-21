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

每条都按 **几何概念 → 数学内核 → AI 迁移** 三段给出，方便直接接到算法设计上。

- **黎曼度量 g（Riemannian metric, §7.6 / §13.1）→ 自然梯度与信息几何。**
  - 内核：度量张量在每点给切空间一个内积 ⟨u,v⟩_g = uᵀg v，决定"谁离谁近"、什么方向算"最陡"。
  - 迁移：概率分布族上的天然度量就是 **Fisher 信息矩阵（Fisher–Rao metric）**；参数空间因此不是平坦欧氏的，而是弯曲流形。最陡下降方向不是 ∇L 而是 **g⁻¹∇L（natural gradient）**，对重参数化不变。
- **联络 / 协变导数（connection, §12.1–§12.4）→ 平行移动（parallel transport）。**
  - 内核：不同点的切空间无法直接相加；联络 ∇ 规定"如何把一个向量沿曲线搬到另一点而不额外旋转"。**Levi-Civita 联络**是唯一与度量相容且无挠的那一个。
  - 迁移：把**动量（momentum）/ 历史梯度 / 二阶状态**在参数流形上正确搬运，是 Riemannian SGD/Adam 中 vector transport 的来源。
- **曲率（curvature, §12.5 / §13.2 / §13.7）→ 优化地形（loss landscape）。**
  - 内核：曲率 = 向量绕一个小环平行移动一圈后偏转多少，是"空间弯不弯、路径依不依赖"的度量，本质是 Hessian 的几何化身。
  - 迁移：损失曲面的曲率决定条件数与尖锐度；**Jacobi 场 / Rauch 比较定理（§13.7 / §13.11）** 描述测地线发散—汇聚，等价于优化轨迹的稳定 vs 发散。
- **测地线与指数映射（geodesics, §13.4）→ 流形上的"直线步"。**
  - 内核：测地线是局部最短路径；指数映射 exp_p(v) 把切空间向量 v 映回流形上对应的最短路径终点。
  - 迁移：在 SPD 矩阵、Stiefel / Grassmann 流形上做**约束优化**时，exp_p 是 retraction 的精确版；latent 空间的测地插值比欧氏直线更尊重数据流形。
- **纤维丛 / 主丛 + G-联络（§6.8 / §12.12 / §9.8）→ 规范等变（gauge equivariance）。**
  - 内核：主 G-丛把"局部坐标系 / frame 的任意选择"打包成纤维上的群作用；丛上的联络 = 规范场（gauge field），曲率 = 场强。
  - 迁移：物理量不应依赖局部 frame 选择，这个"规范自由度（gauge freedom）"正是 **gauge-equivariant CNN（球面 / mesh / 一般流形卷积）** 的归纳偏置；§9.8 用 Maxwell 给出 U(1) 联络曲率的真实样板。
- **李群与李代数（§5）→ 连续对称作为先验。**
  - 内核：指数映射 exp: 𝔤→G、伴随表示 Ad 给出"无穷小生成元 → 有限变换"的通道。
  - 迁移：把对称群作为网络的硬归纳偏置（等变层、李代数参数化的旋转 / 刚体变换）。

## 适合激活的问题类型

- 优化在**欧氏假设下病态 / 收敛慢**，但底层参数有自然的概率或几何结构（用度量重新定义"距离"）。
- 数据本身住在**非欧流形**上：协方差 / SPD 矩阵、旋转 SO(3)、方向数据、图与网格、球面信号。
- 需要**严格的对称 / 等变保证**：旋转、平移、局部规范变换下输出可预测地变化。
- 需要把**"坐标选择的任意性"**显式建模成对称性（多视角、多 frame、传感器姿态无关）。
- 想用**几何量（曲率 / 测地距离）做正则或诊断**：sharpness、泛化、轨迹稳定性。

## 可能的算法启发

- **自然梯度 / K-FAC（natural gradient / K-FAC）**：用 Fisher 度量做预条件，更新方向 = F⁻¹∇L 而非 ∇L。
  - 关键工程：K-FAC 把每层 Fisher 近似成 Kronecker 积 **F ≈ A ⊗ B**（A 来自输入激活、B 来自输出梯度），求逆变两小矩阵求逆、作用变小 GEMM（见下节记分卡）。
- **信息几何优化（information-geometric optimization）**：把训练看成在分布流形上沿 Fisher–Rao 测地线移动。
  - 镜像下降（mirror descent）、Bregman 散度、指数族的对偶坐标都是这套 Hessian 度量的特例；可用来设计对参数化不敏感的优化器。
- **Riemannian optimization**：在 SPD / Stiefel / Grassmann / 双曲流形上做 SGD/Adam。
  - 三件套：retraction（exp 的廉价近似）、vector transport（平行移动的离散版）、流形上的动量；常用于度量学习、正交约束、层次结构嵌入。
- **Gauge-equivariant CNN**：在流形 / 网格上卷积时引入局部规范（local gauge）。
  - 用 G-联络对齐相邻点的 frame，使特征对局部坐标选择不变；适用于球面信号、mesh、晶格等没有全局坐标的域。
- **曲率正则 / SAM 的几何视角（curvature regularization）**：用 Hessian-vector product 估计曲率。
  - 惩罚尖锐极小（flat minima 偏好），或用 Jacobi 场刻画轨迹发散，给 sharpness-aware 训练一个几何解释。
- **测地插值与流形增广（geodesic interpolation）**：latent / 嵌入空间沿测地线插值与采样，比欧氏直线更尊重数据流形，可用于数据增广与可控生成。

## GPU 友好性警告

> 用 `../gpu-friendly-math.md` 评判相关实现维度，无关项标 `N/A`。微分几何实现常见风险是度量/曲率矩阵的求逆、物化与条件数。

- **D2/D3**：求逆是生死线。 朴素自然梯度要算 N×N Fisher 的逆，N 是参数量（~10⁹），O(N³) 求逆 + O(N²) 显存，**直接出局**。
  - **可改造 [v]**：**K-FAC** 把 F 分块为 Kronecker 积 A⊗B，利用 (A⊗B)⁻¹ = A⁻¹⊗B⁻¹，只需对两个小因子求逆，且预条件作用到梯度上**就是 GEMM**。这就是"能否 Kronecker 因子化为 GEMM"的肯定答案——能，且这是它唯一可上集群的形态。
- **D4**：不要物化全 Hessian / 全曲率张量。 Riemann 曲率张量是 4 阶，全物化爆显存。用 **Hessian-vector product（HVP）** 经一次反向以 O(N) 拿到曲率信息，避免 N×N。
- **D5**：Fisher / 度量矩阵常病态。 bf16/fp16 下求逆灾难性放大误差，**必须加阻尼（damping / Tikhonov，F+λI）** 并把求逆留在 fp32；否则违反"低精度稳定"。
- **D6**：平行移动 / 测地线是串行 ODE。 沿曲线积分联络方程是长串行递推，并行性差；工程上用**一步 retraction / 闭式平行移动**（特定流形有解析公式）替代逐步积分。
- **D1/D2**：群卷积可友好，但连续群要当心。 离散群（如 C_n、八面体群）的群卷积可展开成 GEMM [v]；连续李群需采样离散化，采样不当会导致等变性破缺 + 不规则 gather/scatter（D7 稀疏不友好）。

**自然梯度 / K-FAC 八维记分卡（worked example）：**

| D | 朴素自然梯度（全 Fisher 求逆）| K-FAC（Kronecker 因子化）|
|------|------------------------------|--------------------------|
| D1 | [x] 大矩阵显式逆 | [v] 批量小矩阵代数 |
| D2 | [x] N×N 求逆无法 GEMM | [v] A⁻¹⊗B⁻¹ 作用 = GEMM 链 |
| D3 | [x] O(N³) | [v] 两个小因子，亚立方 |
| D4 | [x] 物化 N×N | [v] 只存两个小因子 |
| D5 | [x] 病态、需 fp64 | [~] 加阻尼 + fp32 求逆可改造 |
| D6 | [~] 单次大求逆难并行 | [v] 各层因子独立、可并行 |
| D7 | — | [v] 块对角结构化 |
| D8 | [x] | [v] 预条件可融进优化器 kernel |

**结论**：黎曼 / 信息几何方法**只有在度量被结构化因子化（Kronecker / 块对角 / 低秩）后才 GPU 可行**；精确求逆与精确平行移动都属于"美但不可算"，须改造或淘汰。

## 该调用哪个思想透镜

- **symmetry（对称与不变性）—— 首选。** 规范等变、李群对称、纤维丛 = 把"frame / 坐标选择无关"编码成对称性，是本书与 DL 最强的接口。
- **variational（变分）—— 并列首选。** 自然梯度、Riemannian SGD、曲率正则都是"在弯曲约束空间里找最优"。
- **duality（对偶）**：指数 / 对数映射、retraction、坐标变换简化问题。
- **geometric（几何）**：把参数 / 数据空间显式建模为流形，再翻译回算法。
- **topological（拓扑）**：辅助——de Rham 上同调 / 整体不变量用于守恒量与可积性诊断。

组合建议：先 `symmetry` 定对称结构 → `variational` 落到自然梯度 / Riemannian 优化 → `duality` 处理 retraction → 过 `../gpu-friendly-math.md` 验收门。

## 反模式

每条给出 **反模式 → 正解**：

- **物化并精确求逆全 Fisher / 全 Hessian**：O(N³) / O(N²)，集群上不可行。
  - 正解：先做 Kronecker / 块对角 / 低秩因子化，再求逆；不做因子化就别上自然梯度。
- **在 fp16 直接求逆病态度量矩阵**：灾难性抵消，结果是噪声。
  - 正解：加阻尼 F+λI，求逆留在 fp32，必要时用 CG / Woodbury 隐式求解。
- **逐步 ODE 积分做平行移动 / 测地线**：串行递推杀死并行度。
  - 正解：用闭式 retraction / vector transport（特定流形有解析式），把递推换成单步。
- **连续群无脑离散化**：等变性悄悄破缺，还引入不规则 gather/scatter。
  - 正解：选可精确表示的离散子群，或用可证明误差界的求积 / 频域（球谐）方案。
- **为"几何美"强行流形化**：绝大多数任务欧氏近似已足够。
  - 正解：上黎曼机制前先用实验证明欧氏确实病态（条件数 / 收敛曲线），再引入。
- **把曲率正则当万能药**：曲率估计本身昂贵且噪声大。
  - 正解：先用 HVP 在小规模验证收益，确认信噪比再放大。

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
