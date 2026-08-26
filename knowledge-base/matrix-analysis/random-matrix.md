# 随机矩阵 (Random Matrix Theory)

## 最小定义

随机矩阵理论研究矩阵元素为随机变量时，其谱（特征值/奇异值）的统计规律。核心现象：高维极限下，经验谱分布收敛到**确定性的极限律**（Marchenko–Pastur 律、半圆律），而边缘特征值的个体涨落由 Tracy–Widom 律控制。它把"随机"变成了可计算的"确定"，是高维统计与深度学习谱分析的基础。

## 核心公式

- **Marchenko–Pastur 律**：$X \in \mathbb{R}^{n \times d}$ 元素 iid（均值 0、方差 $\sigma^2$），样本协方差 $S = \frac{1}{n}XX^T$，当 $n, d \to \infty$ 且 $d/n \to c \in (0, 1]$ 时，谱分布收敛到 MP 律，支撑于 $[\sigma^2(1-\sqrt{c})^2,\ \sigma^2(1+\sqrt{c})^2]$
- **半圆律**：对称 Wigner 矩阵 $W$（上三角 iid），$W/\sqrt{n}$ 的谱分布收敛到 $[-2\sigma, 2\sigma]$ 上的半圆密度 $\frac{1}{2\pi\sigma^2}\sqrt{4\sigma^2 - \lambda^2}$
- **Tracy–Widom 涨落**：最大特征值偏离谱边缘 $O(n^{-2/3})$，服从 TW 分布——边缘涨落远小于体内间距
- **BBP 相变（spiked covariance）**：信号尖峰强度 $\ell > \sqrt{c}$ 时，样本特征值才跳出 MP 体内，位于 $(1+\ell)(1+c/\ell)$；$\ell \leq \sqrt{c}$ 时信号被噪声淹没（PCA 失效阈值）
- **最小奇异值**：高斯 $X \in \mathbb{R}^{n \times d}$（$n \geq d$）：$\sigma_{\min}(X) \approx \sqrt{n} - \sqrt{d}$；浓度界 $P(\sigma_{\min}(X/\sqrt{n}) \leq 1 - \sqrt{d/n} - t) \leq e^{-nt^2/2}$
- **非渐近谱范数界**（次高斯）：$\sqrt{n} - C\sqrt{d} - t \leq \sigma_{\min}(X) \leq \sigma_{\max}(X) \leq \sqrt{n} + C\sqrt{d} + t$，概率 $\geq 1 - 2e^{-ct^2}$

## 适用问题

- **权重谱诊断**：训练后权重谱是否偏离 MP 律（重尾、离群尖峰 = 学到的结构）；weight-watcher 类分析的理论基础
- **随机投影合法性**：Johnson–Lindenstrauss 与随机化数值线代误差界的高维概率依据
- **协方差谱估计**：有限样本下有效秩、条件数的偏差修正（$c = d/n$ 不可忽略时样本特征值系统性外扩）
- **过参数化泛化**：随机特征/NTK 谱 = MP 体 + 信号尖峰，决定岭回归泛化误差
- **初始化设计**：正交初始化 vs 高斯初始化；动力等距（dynamical isometry）的谱条件

## AI 设计翻译

- **谱健康监控器**：对每层权重做 ESD–MP 拟合。拟合优度差 + 重尾指数 $\alpha \in (2, 4)$ 通常对应训练充分；出现离群尖峰说明该层学到低秩结构。实现为定期（每 N 步）对采样子矩阵跑 Lanczos 谱密度估计
- **随机投影层**：$d$ 维降到 $k = O(\epsilon^{-2} \log n)$ 维保距，依据是高斯投影的奇异值浓度；实现为固定随机矩阵（不训练）的单次 matmul
- **信号可检测性判断**：估计谱信噪比是否过 BBP 阈值 $\sqrt{c}$，判断 PCA/谱聚类在当前样本量下是否可行，再决定是否加大 batch 或换方法

## 工程可行性

- **主要操作**：谱密度估计 = Lanczos 随机 trace（Hutchinson）$O(k)$ 次 matvec；小矩阵完整 EVD $O(d^3)$ 仅对单层权重可行，LLM 全参数不可行
- **GPU 友好度**：高。谱监控不进训练主干，只读权重快照；Lanczos/matvec 全是 matmul
- **复杂度**：单层权重的完整谱 $O(d^3)$（$d \leq 10^4$ 可接受）；随机 trace 估计 $O(k d^2)$，$k \sim 10^2$ 远小于完整 EVD
- **低精度**：谱监控建议 fp32；不在反向图中，无梯度稳定性问题

## 风险与失效条件

- **MP 律的 iid 假设**：训练后的权重不是 iid 随机矩阵，MP 拟合是**诊断工具不是定理**——偏离 MP 恰是信号所在，不能把 MP 当作"正确"的基准去强制拟合
- **BBP 阈值的有限维修正**：$\sqrt{c}$ 是渐近结果，有限 $n, d$ 下过渡带变宽；阈值附近的结论不可靠
- **重尾谱不是 MP**：训练充分网络的谱常呈幂律尾 $\rho(\lambda) \sim \lambda^{-\alpha}$，与 MP 的紧支撑矛盾，需要 HTSR（heavy-tailed self-regularization）分类框架
- **乘积随机矩阵**：深层网络的 Jacobian 是矩阵乘积，谱由乘积律（自由概率）控制，单层 MP 结论不能直接外推

## 深入参考

- 蒸馏稿：`../../references/books/matrix-analysis.md`（谱与扰动理论的经典结果；RMT 本身超出该书范围）
- Vershynin. *High-Dimensional Probability*. Cambridge, 2018（非渐近界，第 4、7 章）
- Tao. *Topics in Random Matrix Theory*. AMS, 2012（渐近谱律）
- Potters & Bouchaud. *A First Course in Random Matrix Theory*. Cambridge, 2020（含 ML 应用）

## 路由扩展

- 若需要确定性扰动界 → `matrix-perturbation.md`（Weyl/Davis-Kahan；随机矩阵是其随机化版本）
- 若需要谱分解工具 → `spectral-decomposition.md`（EVD/SVD 本身）
- 若需要偏差概率界 → `../probability/concentration-inequality.md`（标量集中不等式）

## 可扩展方向

- 自由概率（free probability）：独立随机矩阵之和/积的谱，深层 Jacobian 分析
- 乘积随机矩阵（products of random matrices）：深度与谱爆炸/消失的关系
- Dyson Brownian motion：特征值的随机动力学，与扩散过程的联系
- 随机矩阵与核方法（RMT for kernels）：核矩阵谱与泛化
- 稀疏随机矩阵（sparse random matrices）：图邻接矩阵谱（Bordenave–Chafaï）
