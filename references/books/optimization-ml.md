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

- **驻点与几何（Ch 6, §5.5）**：正则等值面上的非零欧氏梯度垂直于等值面，并在欧氏度量下给出最陡上升方向。小梯度只是驻点诊断，不证明局部极小；约束问题还需可行性/KKT 残差。
- **条件数（Ch 8）**：κ=λ_max/λ_min 直接适用于正定二次型 Hessian；光滑强凸问题对应 L/μ。不能未经限制就把该模型用于不定的神经网络 Hessian。
- **Newton 与阻尼（Ch 9）**：Newton 解 Hp=−g；要获得可靠下降步，需正定性或全局化策略。非线性最小二乘的 Levenberg–Marquardt 解 (JᵀJ+μI)p=−Jᵀr。Adam 分母的 ε 有数值稳定作用，但不是这个曲率矩阵，也不等价于信赖域。
- **拟 Newton（Ch 11）**：BFGS/DFP 用割线信息更新 Hessian 或逆 Hessian 近似，正定保持需曲率条件或阻尼；L-BFGS 限制历史存储。K-FAC 的 Fisher 近似、Shampoo 的梯度矩因子有不同推导。
- **Matrix-free（Ch 10）**：HVP 避免存储稠密 Hessian；标准线性 CG 要求对称正定系统。非凸 Hessian-free 方法需阻尼、PSD 替代或 truncated CG 的负曲率处理。
- **约束（Ch 20–21, 24）**：投影、惩罚法、增广 Lagrange 是不同算法；有限惩罚系数不自动保证可行，不等式还要检查乘子符号与互补松弛。
- **对偶（Ch 17, 23）**：弱对偶给界，强对偶需适当条件；Slater 是适当凸问题的充分条件。光滑非凸问题的 KKT 必要性通常要约束资格条件；可微凸问题中 KKT 可充分保证全局最优，但一般 GAN 不是此类问题。
- **随机方法（Ch 27）**：梯度无偏性依赖采样/估计方案。SVRG 是带参考梯度的控制变量构造，普通大 batch 或梯度累积不是 SVRG。
- **谱方法（Ch 26）**：SVD/PCA 支持低秩近似，但从重构误差到 LoRA 或 KV 压缩任务质量仍需独立的衔接论证。

## 适合激活的问题类型

- 选型 / 设计优化器，或解释训练动力学（为什么发散、震荡、停滞在鞍点）。
- 诊断病态与慢收敛：用条件数 κ 把"难训"量化。
- 带约束训练：权重范数球、谱范数、安全 / 预算约束，需要投影或惩罚。
- min-max / 对抗 / 对偶视角：把难解 primal 换成易解 dual（如核 Gram 矩阵）。
- 分布式训练的通信-计算权衡、梯度压缩、方差缩减。
- 需要二阶信息却不能算全 Hessian 的场景（曲率自适应预条件）。

## 可能的算法启发

- **先匹配优化器与目标**：借用 Newton、自然梯度或自适应矩方法前，明确目标、度量/预条件、随机 oracle 和停机标准。
- **可扩展曲率**：L-BFGS 对 d 个参数与 m 对历史需 O(md) 存储；HVP 以多次自动微分换取显存。K-FAC 近似 Fisher 块，Shampoo 构造各轴梯度矩与逆矩阵根，需计入更新频率和分解成本。
- **按规模选 primal/dual**：SVM 在样本 n 相对维度 d 很小时可能受益于对偶，但稠密核矩阵存储为 O(n²)；可分性和耦合决定对偶分解的并行收益。
- **约束训练**：box 投影逐坐标截断；l2 球投影需要范数归约与径向缩放；l1 球和谱范数球有不同算法。把所有奇异值一起除以最大值，一般不等于到谱范数球的欧氏投影；后者逐个截断超阈值的奇异值。
- **明确的 SVRG 控制变量**：f=(1/n)Σᵢfᵢ 且 i 均匀采样时，使用 v=∇fᵢ(x)−∇fᵢ(x_ref)+∇f(x_ref)，该估计无偏；成本必须包括额外的参考全梯度遍历。线性收敛主张需给出光滑/凸性与步长等假设。
- **分布式执行**：只在依赖允许时重叠通信，报告字节数、同步和梯度估计偏差；分布式优化本身不提供隐私或安全聚合保证。

## GPU 友好性警告

> 只评估 `../gpu-friendly-math.md` 的适用维度。无导数方法、串行依赖或非 GEMM 运算是需要测量的实现选择，不是自动淘汰条件。

| 方法 | 成本与数值检查 |
|---|---|
| 稠密 Newton | Hessian 存储 O(d²)，常规稠密分解 O(d³)；解方程而非显式求逆，大 d 时利用结构或 matrix-free。 |
| HVP / L-BFGS / 结构化因子 | 降低存储不消除多轮迭代、内积归约、历史显存或矩阵根成本；比较同等质量下的总时间。 |
| 线搜索 | 额外目标/梯度评估与同步可能昂贵，可批量试探步长；按工作负载与固定/调度步长比较。 |
| SGD 与自适应一阶更新 | 反向成本取决于模型，优化器步骤常是带宽受限的逐元素 kernel 而非 GEMM；通信重叠依计算图与实现。 |
| GA / PSO / evolution strategies | 候选评估可并行，也可优化神经网络权重；无需路径导数，需评价种群成本、样本效率、同步与所选估计器。 |
| LP / QP / 内点子问题 | 分解形状与复用决定成本；小型批量或隐式微分优化层可进入训练，需检查正则性与求解精度。 |
| 投影 | box 逐元素、l2 需归约、l1 可能需排序/选择，谱约束可能需要奇异值计算。 |
| 低精度 | 条件数、缩放、随机噪声与残差阈值共同影响结果；有无预条件都不能单独决定 bf16 是否收敛。 |

## 该调用哪个思想透镜

- **variational**（主）：目标-约束-最优性-收敛的完整框架，本书是其核心出处；把现实任务（分类 / 回归 / 约束）翻译成可解的优化问题。
- **algorithmic**：迭代算法的收敛性、复杂度、步长 / 停机判据。
- **duality**：对偶、核技巧、变量替换、SVD/PCA——"等价转换简化问题"。
- **probabilistic**：SGD 随机梯度、SVRG 方差缩减、交叉验证 / 正则化。

## 反模式

- 不给前提就把小梯度或 KKT 点当全局最优。
- 不处理负曲率就把标准 CG 用于不定 Hessian。
- 把 K-FAC/Shampoo 都称为 Hessian 近似，或把 Adam ε 等同 Levenberg–Marquardt 阻尼。
- 没有控制变量和参考梯度计算，却把梯度累积称为 SVRG。
- 把各类范数球投影、谱归一化和通用 weight clipping 混为一谈。
- 仅因损失包含约束违背项，就宣称满足硬约束。
- 用“不能并行”的错误前提一概排除线搜索或种群方法；应比较实际任务成本与质量。
- 从通信/计算优化直接宣称训练安全或隐私。

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

## 已核验的扩展来源

[Boyd 与 Vandenberghe：Convex Optimization](https://web.stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf)提供凸性、KKT、对偶与数值方法的可访问核验来源。现代扩展应分别回到原论文：[Adam](https://arxiv.org/abs/1412.6980)、[K-FAC](https://proceedings.mlr.press/v37/martens15.html)、[Shampoo](https://proceedings.mlr.press/v80/gupta18a.html)、[SVRG](https://proceedings.neurips.cc/paper/2013/hash/ac1dd209cbcc5e5d1c6e28598e8cbbe8-Abstract.html)。不能把这些算法写成同一教材构造的等价推论。
