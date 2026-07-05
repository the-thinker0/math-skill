# 最优化（含 ML 应用）/ Optimization with ML

> **An Introduction to Optimization, With Applications to Machine Learning** (5th Edition, 2024)
> Edwin K. P. Chong, Wu-Sheng Lu, Stanisław H. Żak — John Wiley & Sons（Hardback ISBN 9781119877639）
>
> 本文件是「激活参考」：综合提炼、面向工程，不逐字摘录。
> 目标——把这本经典优化教材里**能落到算法 / GPU / 训练 Infra** 的结构抽出来。

## 概要

经典连续优化教材的第五版。相较旧版，最大增量是新增完整的 **Part V「机器学习中的优化」**，把一阶/二阶最优性、对偶、KKT、收敛性与 SGD/SVM/PCA 等训练实践彻底打通。全书 31 章，分五部分。

真实章节地图：

- **Part I — 数学复习（Ch 1–5）**
  - Ch 1 证明方法与记号；Ch 2 向量空间与矩阵（秩、内积与范数）。
  - Ch 3 变换：特征值/特征向量、正交投影、二次型 §3.4、矩阵范数 §3.5。
  - Ch 4 几何：超平面、**凸集 §4.3**、多胞形与多面体。
  - Ch 5 微积分：导数矩阵 §5.3、**水平集与梯度 §5.5**、Taylor 级数 §5.6。
- **Part II — 无约束优化（Ch 6–14）**
  - Ch 6 局部极小的一阶/二阶必要与充分条件。
  - Ch 7 一维搜索：黄金分割、Fibonacci、二分、Newton、割线、线搜索。
  - **Ch 8 梯度法**（最速下降 §8.2、收敛分析 §8.3）。
  - **Ch 9 Newton 法**（Levenberg–Marquardt §9.3、非线性最小二乘）。
  - Ch 10 共轭方向/共轭梯度；**Ch 11 拟牛顿**（逆 Hessian 近似、DFP §11.4、**BFGS §11.5**）。
  - Ch 12 解线性方程（最小二乘、RLS、Kaczmarz、最小范数解）。
  - **Ch 13 神经网络与反向传播**（单神经元训练 §13.2、Backprop §13.3）。
  - Ch 14 全局搜索：Nelder–Mead、模拟退火、PSO、遗传算法。
- **Part III — 线性规划（Ch 15–19）**
  - Ch 15 LP 基础与几何；Ch 16 单纯形法。
  - **Ch 17 LP 对偶**（对偶 LP、矩阵博弈）。
  - Ch 18 非单纯形/内点法（Khachiyan、仿射尺度、Karmarkar）；Ch 19 整数规划。
- **Part IV — 非线性约束优化（Ch 20–25）**
  - Ch 20 等式约束：切空间/法空间 §20.3、**Lagrange 条件 §20.4**、二阶条件。
  - **Ch 21 不等式约束与 KKT**（KKT §21.1、二阶条件 §21.2）。
  - **Ch 22 凸优化**（凸函数 §22.2、凸问题 §22.3、SDP/LMI §22.4）。
  - **Ch 23 Lagrange 对偶**（弱/强对偶、对偶间隙 §23.4.6、Slater §23.6.3、鞍点）。
  - Ch 24 约束算法（投影 §24.2、**投影梯度 §24.3**、Armijo §24.4.4、增广 Lagrange §24.5、惩罚法 §24.6）。
  - Ch 25 多目标 / 鲁棒 LP（Pareto、不确定性）。
- **Part V — ML 中的优化（Ch 26–31）**
  - Ch 26 特征工程、PCA、SVD、线性自编码器。
  - **Ch 27 SGD 算法**（SGD §27.1、方差缩减 **SVRG §27.2**、**分布式 SVRG 与通信/计算权衡 §27.3**）。
  - Ch 28 线性回归（正则化 §28.3、交叉验证）；Ch 29 逻辑回归 / Softmax。
  - **Ch 30 SVM**（hinge loss、硬/软间隔）；**Ch 31 核技巧与 K-Means**。

## 可迁移到 AI/Infra 的核心结构

- **一阶最优性 + 梯度几何（Ch 6, §5.5）**
  - 梯度 ⊥ 水平集、是最速上升方向——所有训练优化器的公理根。
  - `∇f = 0` 是停机判据；鞍点 / 非凸是现代深度学习的核心痛点。
- **收敛性分析框架（Ch 8 §8.3）**
  - 用条件数 κ = λ_max/λ_min 刻画最速下降的收敛速率。
  - 解释"为什么病态网络难训、为什么要归一化 / 预条件"。
- **二阶曲率与阻尼（Ch 9）**
  - Newton 用 Hessian 给出仿射不变的步长与方向。
  - Levenberg–Marquardt 的 `(H+μI)` 阻尼 = 信赖域思想，是 Adam 的 `ε`、二阶优化器的祖先。
- **拟牛顿低秩更新（Ch 11）**
  - BFGS/DFP 只用梯度差，以 rank-1/rank-2 更新维护逆 Hessian 近似。
  - 是 L-BFGS、K-FAC、Shampoo 的直接思想源。
- **无矩阵二阶（Ch 10）**
  - 共轭梯度只需 Hessian-向量积，不存全 Hessian；对应 autodiff 的 HVP（Hessian-free）。
- **约束几何（Ch 20–21, 24）**
  - 切/法空间 → Lagrange/KKT → 投影梯度 + 惩罚 / 增广 Lagrange。
  - 构成"带约束训练"的完整工具链。
- **对偶与鞍点（Ch 17, 23）**
  - 强对偶 ⇔ minimax = maximin；KKT、互补松弛、Slater 条件。
  - min-max 训练（GAN / 对抗鲁棒）、SVM 对偶都落在这里。
- **随机与分布式（Ch 27）**
  - SGD 的无偏梯度估计、SVRG 方差缩减。
  - **分布式下"通信 vs 计算"的显式权衡**——数据并行训练的理论根。
- **低秩 / 谱（Ch 26, §3.4）**
  - SVD/PCA/线性自编码器、二次型与谱——LoRA、KV 压缩、谱归一化的数学底座。

## 适合激活的问题类型

- 选型 / 设计优化器，或解释训练动力学（为什么发散、震荡、停滞在鞍点）。
- 诊断病态与慢收敛：用条件数 κ 把"难训"量化。
- 带约束训练：权重范数球、谱范数、安全 / 预算约束，需要投影或惩罚。
- min-max / 对抗 / 对偶视角：把难解 primal 换成易解 dual（如核 Gram 矩阵）。
- 分布式训练的通信-计算权衡、梯度压缩、方差缩减。
- 需要二阶信息却不能算全 Hessian 的场景（曲率自适应预条件）。

## 可能的算法启发

- **自适应优化器**
  - Levenberg–Marquardt 的 `(H+μI)` 阻尼 → Adam 的 `ε`、信赖域、自适应学习率。
  - 把"曲率 / 阻尼"显式化，而非停留在纯启发式调参。
- **大模型可行的二阶**
  - L-BFGS：只存最近 m 步梯度对（低秩历史，显存 O(md)）。
  - Hessian-free：autodiff 的 HVP + CG（matrix-free，无需物化 Hessian）。
  - K-FAC / Shampoo：把 Hessian 近似成**块对角 / Kronecker 因子**，每块退化为小 GEMM。
- **对偶视角高效求解**
  - SVM 把高维 primal 转成只依赖核 Gram 矩阵的对偶（Ch 30–31），样本数 ≪ 维度时大赚。
  - 约束问题的对偶分解天然可并行。
- **约束训练**
  - 投影梯度（§24.3）做 norm-ball / spectral-norm 约束（weight clipping、谱归一化）。
  - 增广 Lagrange / 惩罚法（§24.5–24.6）把硬约束软化成可微正则。
- **方差缩减 / 大 batch**
  - SVRG（§27.2）的控制变量思想 → 梯度累积、大 batch 训练的稳定性分析。
- **分布式**
  - §27.3「通信 vs 计算」直接对应 all-reduce 与计算的 overlap、梯度压缩、联邦 / 数据安全。

## GPU 友好性警告

> 以下逐项对照 `../gpu-friendly-math.md` 的**八维记分卡**（先读它）。
> 结论：本书的一阶 / 随机 / 低秩部分天然友好；二阶法与搜索类方法需重度改造或淘汰。

- **二阶法的全 Hessian（Ch 9, 11）**
  - 违反**D4**：稠密 Hessian 是 O(d²)，亿级参数无法物化。
  - 违反**D2**：求逆 / 分解非 batched-GEMM 友好。
  - 违反**D5**：病态求逆在 bf16/fp16 灾难性抵消。
  - 改造：matrix-free HVP + CG、L-BFGS 低秩、K-FAC 块对角 → 重回**D2/D4** 友好。
- **线搜索（Ch 7 黄金分割 / Armijo §24.4.4）**
  - 违反**D1**：本质是标量循环 + 数据相关分支（逐步比较函数值）。
  - 违反**D8**：频繁小 kernel、控制流发散。
  - 改造：大模型几乎都用调度式步长（warmup + cosine）替代逐步线搜索。
- **一阶 / SGD（Ch 8, 27）**
  - **D1/D2 友好**：梯度 = 张量代数、可写成 GEMM。
  - **D6**良好：数据并行 all-reduce 可与反向 overlap——大模型默认路线的根本原因。
- **全局搜索（Ch 14：GA/SA/PSO）**
  - 违反**D1**：不可微、离散随机搜索，阻断端到端梯度训练。
  - **D6** 也差：种群间依赖、难并行映射。仅适合黑盒超参搜索，不进训练内环。
- **LP 单纯形 / 内点法（Ch 16, 18）**
  - 单纯形的行运算尚可；内点法每步要解线性系统，**D2/D6** 受限于分解与通信。
  - 适合中等规模约束子问题，不适合放进每个训练 step。
- **投影（§24.2）**
  - norm-ball / box 投影是廉价 elementwise（**D1/D8** 友好）。
  - 一般多面体投影要解 QP（**D2** 退化）。
- **收敛依赖条件数 κ**
  - κ 大 → **D5** 在低精度下被进一步放大（病态梯度）。
  - 必须配归一化 / 预条件，否则 bf16 训练发散。

## 该调用哪个思想透镜

- **variational**（主）：目标-约束-最优性-收敛的完整框架，本书是其核心出处；把现实任务（分类 / 回归 / 约束）翻译成可解的优化问题。
- **algorithmic**：迭代算法的收敛性、复杂度、步长 / 停机判据。
- **duality**：对偶、核技巧、变量替换、SVD/PCA——"等价转换简化问题"。
- **probabilistic**：SGD 随机梯度、SVRG 方差缩减、交叉验证 / 正则化。

## 反模式

- 把**全 Hessian Newton** 直接上大模型——O(d²) 显存与求逆当场爆炸（必须 matrix-free / 低秩 / 块对角）。
- 在大模型每步用**线搜索**调步长——标量串行、控制流发散，吃光算力；应改调度式学习率。
- 用 **GA/SA/PSO 训练神经网络**——不可微、无法并行、样本效率极低；仅限黑盒超参搜索。
- 谈收敛却**忽略条件数 κ**——不归一化 / 不预条件就期望低精度收敛是幻觉。
- 把 **LP 单纯形思维**硬套连续可微问题。
- 把**对偶 / KKT 当万能**——非凸通常无强对偶、存在对偶间隙（§23.4.6），KKT 只是必要条件。
- 把这份「激活参考」当严格证明来源——细节与定理条件必须回查原书。

## 深挖入口

> **书目信息**：Edwin K. P. Chong, Wu-Sheng Lu, Stanisław H. Żak, *An Introduction to Optimization, With Applications to Machine Learning*, 5th Edition, John Wiley & Sons, 2024. ISBN 978-1-119-87763-9.
>
> **启用方式**：将 `An Introduction to Optimization With Applications to Machine Learning.pdf` 放入项目根目录的 `math_book/` 文件夹，Agent 即可自动搜索原文。PDF 不随 npm/git 分发（版权原因），需自行获取。

全保真回查 = 让 Agent 直接搜索本地 PDF
`math_book/An Introduction to Optimization With Applications to Machine Learning.pdf`，按真实章号定位：

- **Ch 8 Gradient Methods**（§8.3 收敛分析、条件数）+ **Ch 11 Quasi-Newton Methods**（§11.5 BFGS）——优化器与可行二阶。
- **Ch 22 Convex Optimization Problems**（§22.2 凸函数、§22.4 SDP/LMI）——凸性判据与半定规划。
- **Ch 23 Lagrangian Duality**（§23.5 强对偶、§23.6.3 Slater 条件）+ **Ch 21 KKT Condition**——对偶 / KKT / 鞍点。
- **Ch 24 Algorithms for Constrained Optimization**（§24.3 投影梯度、§24.5 增广 Lagrange、§24.6 惩罚法）——约束训练算法。
- **Ch 27 Stochastic Gradient Descent Algorithms**（§27.1 SGD、§27.2 SVRG、§27.3 分布式与通信 / 计算）——大规模训练核心。
