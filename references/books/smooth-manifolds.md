# 光滑流形 / Smooth Manifolds

> **书目**：John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition. Graduate Texts in Mathematics 218, Springer, 2013. ISBN 978-1-4419-9981-8 / DOI 10.1007/978-1-4419-9982-5. MSC 53-01 / 58-01 / 57-01.
> **定位**：把"局部像欧氏空间、整体可弯曲"的对象（manifold）配上微积分（切空间、向量场、微分形式、流、李导数），是 **流形优化、隐空间几何、可微结构** 的数学母体。

## 概要

光滑流形 = 局部能用坐标卡（chart）线性化、卡与卡之间用光滑转移映射（transition map）粘合的空间。全书主线：**先把欧氏微积分搬到弯曲空间上，再研究其上的几何与拓扑不变量**。对 AI 最值钱的是前半部分那套"可微机器"——切/余切空间、向量场、流、黎曼度量。

真实章节地图（2nd ed.，章号与本书一致）：

- **Ch 1–2 Smooth Manifolds / Smooth Maps**：拓扑流形、光滑结构（atlas）、光滑映射、单位分解（partition of unity）。→ 局部线性化 + 全局拼接的语言。
- **Ch 3 Tangent Vectors**：切空间 T_pM、微分（differential / pushforward）df_p、切丛 TM。→ **局部线性化的核心**，反向传播的几何原型。
- **Ch 4–5 Submersions, Immersions, Embeddings / Submanifolds**：常秩定理、嵌入、正则水平集 → 子流形。→ 约束集 = 子流形。
- **Ch 6 Sard's Theorem**：临界值测度为零、Whitney 嵌入定理（适当嵌入 R^{2n+1}；书中陈述的强版本在 n>0 时给出 R^{2n}）。→ 嵌入维数 / 流形假设。
- **Ch 7 Lie Groups**：既是群又是流形（SO(n), U(n), GL(n)…），李代数 = 单位元处切空间。→ 正交/酉权重约束、等变。
- **Ch 8–9 Vector Fields / Integral Curves and Flows**：向量场、积分曲线、局部流（完备向量场才生成全局单参数微分同胚群）、李导数与李括号 [X,Y]。→ **Neural ODE / 扩散 / 连续归一化流** 的母结构。
- **Ch 10–12 Vector Bundles / Cotangent Bundle / Tensors**：丛、余向量场（1-form）、拉回（pullback）、张量。→ 微分 df 是余向量；梯度还需要度量。
- **Ch 13 Riemannian Metrics**：每点内积、长度/距离/体积、切-余切同构（musical (sharp)/(flat)，升降指标）。→ **自然梯度 / 黎曼优化的度量来源**。
- **Ch 14–16 Differential Forms / Orientations / Integration**：k-形式、楔积、外微分 d（d²=0）、定向、体积形式、流形上积分与变量替换。→ 归一化流的 log-det-Jacobian = 体积形式拉回。
- **Ch 17–18 De Rham Cohomology / de Rham Theorem**：闭形式模去恰当形式 = 从微分数据读出的拓扑不变量。→ 全局障碍 / 上同调正则。
- **Ch 19–22 Distributions & Foliations / Exponential Map / Quotient Manifolds / Symplectic Manifolds**：可积分布（Frobenius）、李群指数映射（不能混同一般黎曼指数）、商流形（Grassmann 等）、辛形式与 Hamilton 流。→ retraction、商空间约束、辛积分器 / HMC。

**范围边界**：本书提供光滑结构、向量丛、度量和李群指数映射的工具。联络、黎曼测地线、平行移动与曲率需转向黎曼几何教材；不能把 Ch 20 当作一般黎曼指数映射的系统讲解。版本勘误可查[作者书目页](https://sites.math.washington.edu/~lee/Books/ISM/)。

## 可迁移到 AI/Infra 的核心结构

- **切空间 = 参数/隐空间的局部线性化（local linearization）**。`df_p: T_pM → T_{f(p)}N` 就是 Jacobian / pushforward（前推，对应 JVP / 前向模式 AD）；反向传播 = 余切丛上的拉回（pullback on cotangent bundle，VJP = 向量-Jacobian 积 = 余向量的拉回），即沿复合映射做 pullback（链式法则的几何版）。一切一阶方法都活在切空间里。
- **微分 df 是余向量，grad_g f 是向量**。反向模式 AD 给出 df 的坐标分量；选定度量后，grad_g f = g⁻¹df，负梯度是最陡下降方向。欧氏与自然梯度的区别来自度量选择；镜像下降与特定 Hessian 度量的关系还需要凸势等条件。
- **约束集 = 子流形（submanifold）**。正则水平集定理：当 g 是 submersion 时 `g(x)=c` 的解集是光滑子流形；约束优化 = 在子流形上做无约束优化。
- **李群与齐性空间要区分**。SO(n)、U(n) 是李群，其李代数可用于 Exp 参数化。一般 Stiefel/Grassmann 是相应群作用下的齐性/商流形，不具备这里假定的群乘法或自身李代数；可使用矩形 QR retraction、商空间方法或群作用构造，而非照搬群 Exp。
- **局部流与存在性条件**。光滑向量场在其解存在的区间内生成局部微分同胚；全局时间需完备性，保体积需对所选体积形式散度为零。Neural ODE/CNF 使用确定性流；随机扩散 SDE 不能直接当作确定性可逆流，probability-flow ODE 的联系另需条件。
- **黎曼度量 = 可设计/可学习的"局部几何"**。它决定距离、夹角、体积、谁与谁正交；改度量就改了优化轨迹与采样测度。
- **微分形式 + 体积形式 = 变量替换的语言**。归一化流里的 `log|det J|` 项就是体积形式在映射下的拉回；选对结构（三角/耦合 Jacobian）能让它廉价。

## 适合激活的问题类型

- 参数本应满足 **几何约束**：正交、单位范数、单位行列式、SPD、低秩流形、双曲/球面隐空间。
- 优化在 **弯曲空间** 上更自然：Stiefel/Grassmann 上的子空间学习、旋转/姿态估计、超球面表征。
- 需要 **保结构动力学**：可逆生成模型、保体积流、Hamilton 系统、能量守恒的长程模拟。
- **隐空间几何**：插值、测地线、度量学习、流形上的聚类/最近邻。
- 需要从相关性升级到 **拓扑不变量**：检测隐空间的"洞"、全局障碍、用上同调做一致性正则。

## 可能的算法启发

- **黎曼/流形优化器（Riemannian optimizers）**：把 Adam/SGD 搬到 Stiefel、Grassmann、SPD、双曲空间——按所选度量计算梯度、应用 retraction 并一致搬运状态；环境欧氏梯度的切空间投影适用于诱导度量。
- **正交/Stiefel 约束权重**：用 Cayley 变换或 QR-retraction 维持 `WᵀW=I`，缓解 RNN/深网的梯度爆炸/消失；或用 so(n) 李代数 + matrix-exp 重参数化旋转。
- **测地线插值（geodesic interpolation）**：在球面/双曲/SPD 隐空间用闭式测地线做插值与混合，替代欧氏线性插值。
- **归一化的对象要明确**：非零特征的 L2 归一化落在球面上；忽略 ε 与仿射变换时，LayerNorm 还施加零均值约束。谱归一化约束的是矩阵算子范数，不能直接等同球面投影或保证约束集处处光滑。
- **Neural ODE / CNF**：学确定性向量场，核对解的存在唯一性和散度计算成本；随机扩散及其 probability-flow ODE 单独定义。
- **辛积分器（symplectic integrator）/ HMC**：用 leapfrog 这种保辛、保体积的显式更新做采样与"带动量的优化"，长程稳定。
- **等变网络（equivariant nets）**：用李群作用 + 商流形把对称性写进结构（geometric deep learning）。

## GPU 友好性警告

按 `../gpu-friendly-math.md` 选择适用维度。光滑流形结构本身不规定 GPU 成本，具体算子和表示才规定成本。

- **D1/D2 [~]**：线性映射的 JVP/VJP 可用 GEMM；一般微分的实现仍由原计算图决定，不能把所有切空间操作都称为 GEMM。QR、矩阵指数和求解器可批处理，但需要实测尺寸、吞吐与峰值内存。
- **D3/D4 [v]**：球面点的内积/距离通常为 O(n)，矩形 n×r QR 约 O(nr²)，稠密 n×n SPD 特征分解通常 O(n³)。不存在“所有测地线/平行移动都 O(n³) 起”的统一下界。
- **D5 [~]**：误差取决于谱间隙、条件数、角度分支与算法。以 fp32/fp64 为参照测试目标精度；升精度和正则化也不能消除数学上的不可微点或病态性。
- **D6/D7/D8 [~]**：ODE 时间步有依赖，但样本、块和部分线性子问题可并行。低维闭式表达、稀疏结构和融合能否获益由实现决定。

硬约束与软正则应按所需保证选择：正交惩罚并不确保严格正交。辛积分器保持辛结构，不一般逐步精确保能；leapfrog 的显式形式还依赖可分离 Hamiltonian，HMC 接受率需要另测。

## 该调用哪个思想透镜

- **variational（变分透镜）**：主透镜——约束下寻最优、黎曼/流形优化、retraction 选型。
- **symmetry（对称与不变性）**：李群、等变、商流形、群作用下的不变量。
- **duality（对偶透镜）**：坐标卡变换、pushforward/pullback、归一化流的变量替换、微分同胚。
- **topological（拓扑透镜）**：de Rham 上同调、全局障碍、隐空间的"洞"与连通性。
- **categorical（范畴化透镜）**：从高维杂乱的环境数据中抽出"局部线性 + 光滑拼接"的流形骨架（流形假设）。

## 反模式

- **把 ML 的 "tensor"（数组）当数学 tensor（多线性、有协变/逆变变换律）**，误以为自动获得坐标无关的不变性。
- **未经验证把矩阵 exp/log 放入低精度热循环**：先检查条件数、分支、梯度残差和实测耗时，再选择精度与近似。
- **该软不软**：用严格流形约束换来微小收益，却付出 QR/eig 的吞吐与稳定性代价；很多任务一个正交正则项就够。
- **混淆微分 df（余向量）与梯度 grad_g f（向量）**：忘了度量、把 raw autodiff 输出直接当自然梯度。
- **单一全局坐标卡的幻觉**：球面/SO(3) 等空间不能用单个无奇异欧氏坐标图覆盖，但 Rⁿ 和 SPD 的矩阵对数坐标是反例；是否需要多图取决于对象拓扑，不是所有流形的必然限制。
- **流形假设滥用**：参数空间本是平坦欧氏时硬套黎曼机器，纯属过度工程（违反 simplicity-first）。

## 深挖入口

> **书目信息**：John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition, Graduate Texts in Mathematics 218, Springer, 2013. ISBN 978-1-4419-9981-8.
>
> **启用方式**：将 `Introduction to Smooth Manifolds.pdf` 放入项目根目录的 `math_book/` 文件夹，Agent 即可自动搜索原文。PDF 不随 npm/git 分发（版权原因），需自行获取。

> **全保真回查**：需要原文定义/定理/证明时，让 Agent **自动搜索本地 PDF** `math_book/Introduction to Smooth Manifolds.pdf`（按章号/关键词定位，勿凭记忆复述）。下列为真实章号（2nd ed.）：

- **Ch 3 Tangent Vectors** — 切空间、微分/pushforward、切丛：局部线性化与反传的几何原型。
- **Ch 11 The Cotangent Bundle** — 余向量场（1-form）、`df` 作为余向量、pullback：df 是余向量，梯度由度量升指标得到。
- **Ch 13 Riemannian Metrics** — 度量、切-余切同构（(sharp)/(flat)）、距离：自然梯度 / 黎曼优化的根。
- **Ch 9 Integral Curves and Flows** — 流、积分曲线、李导数/李括号：Neural ODE / 扩散 / 保结构动力学。
- **Ch 20 The Exponential Map** — 李群指数映射：由左不变向量场的流定义；不要把该章当成一般黎曼测地线教材。

（延伸：Ch 7 Lie Groups → 正交/酉约束与等变；Ch 14 Differential Forms → 体积形式与 log-det-Jacobian；Ch 22 Symplectic Manifolds → 辛积分器 / HMC。）
