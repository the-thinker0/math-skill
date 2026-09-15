# 随机矩阵 (Random Matrix Theory)

## 最小定义

随机矩阵理论研究随机矩阵的谱。确定性极限律与谱边缘涨落律依赖矩阵系综、归一化、矩或尾部假设及渐近尺度；它们不是任意训练权重的通用性质。

## 核心公式

- **Marchenko–Pastur 律**：$X\in\mathbb R^{n\times d}$ 的元素 iid、均值0、方差 $\sigma^2$，且 $d/n\to c>0$ 时，取特征协方差 $S=X^TX/n\in\mathbb R^{d\times d}$。极限连续谱端点为 $\sigma^2(1\pm\sqrt c)^2$；$c>1$ 时还含质量 $1-1/c$ 的零原子。另一 Gram 矩阵 $XX^T/n$ 与之共享非零特征值，但零质量不同。
- **半圆律**：中心化实对称 Wigner 系综的上三角元素独立、非对角方差 $\sigma^2$，并满足标准矩条件时，$W/\sqrt n$ 的极限密度为 $[-2\sigma,2\sigma]$ 上的 $\sqrt{4\sigma^2-\lambda^2}/(2\pi\sigma^2)$。
- **Tracy–Widom 涨落**：高斯及满足普适性条件的系综在正规软边缘，适当中心化与缩放后最大特征值有 $O(n^{-2/3})$ 涨落。此尺度**大于**谱内部的 $O(n^{-1})$ 间距；重尾系综与离群尖峰可能遵循其他规律。
- **BBP 相变**：噪声协方差为单位阵、总体尖峰为 $1+\ell$ 的秩一尖峰协方差模型中，$\ell>\sqrt c$ 时样本离群值极限为 $(1+\ell)(1+c/\ell)$；低于阈值时主样本特征向量与信号的重叠渐近消失。这不是任意数据的通用可检测阈值。
- **高斯最小奇异值**：若 $X_{ij}\sim N(0,1)$ 独立、$n\ge d$、$t\ge0$，则 $\Pr[\sigma_{\min}(X/\sqrt n)\le1-\sqrt{d/n}-t]\le e^{-nt^2/2}$。下阈值非正时不能提供有效条件数保证。
- **次高斯奇异值界**：独立、各向同性次高斯行向量的次高斯范数一致有界时，以至少 $1-2e^{-c_0t^2}$ 的概率有 $\sqrt n-C\sqrt d-t\le\sigma_{\min}(X)\le\sigma_{\max}(X)\le\sqrt n+C\sqrt d+t$；常数依赖次高斯范数。

## 适用问题

- **权重谱诊断**：训练后权重谱是否偏离 MP 律（重尾、离群尖峰 = 学到的结构）；weight-watcher 类分析的理论基础
- **随机投影合法性**：Johnson–Lindenstrauss 与随机化数值线代误差界的高维概率依据
- **协方差谱估计**：有限样本下有效秩、条件数的偏差修正（$c = d/n$ 不可忽略时样本特征值系统性外扩）
- **过参数化泛化**：随机特征/NTK 谱 = MP 体 + 信号尖峰，决定岭回归泛化误差
- **初始化设计**：正交初始化 vs 高斯初始化；动力等距（dynamical isometry）的谱条件

## AI 设计翻译

- **谱诊断**：只对明确归一化的零模型拟合谱。把真实权重与打乱/随机化对照及任务指标比较；离群值或拟合的重尾指数不能单独证明学到结构或训练充分。
- **随机投影层**：$d$ 维降到 $k = O(\epsilon^{-2} \log n)$ 维保距，依据是高斯投影的奇异值浓度；实现为固定随机矩阵（不训练）的单次 matmul
- **信号可检测性判断**：估计谱信噪比是否过 BBP 阈值 $\sqrt{c}$，判断 PCA/谱聚类在当前样本量下是否可行，再决定是否加大 batch 或换方法

## 工程可行性

- **主要操作**：谱密度估计 = Lanczos 随机 trace（Hutchinson）$O(k)$ 次 matvec；小矩阵完整 EVD $O(d^3)$ 仅对单层权重可行，LLM 全参数不可行
- **GPU 友好度**：高。谱监控不进训练主干，只读权重快照；Lanczos/matvec 全是 matmul
- **复杂度**：稠密 $d\times d$ EVD 为 $O(d^3)$ 时间、$O(d^2)$ 存储，没有与硬件无关的可行维数阈值。$s$ 个探针、$k$ 步 Lanczos 的无矩阵谱估计需要 $sk$ 次 matvec 及正交化。
- **低精度**：谱监控建议 fp32；不在反向图中，无梯度稳定性问题

## 风险与失效条件

- **模型失配**：相关性、异方差、重尾或归一化选择均可导致偏离 MP，未必是学到信号；解释谱前先排查这些替代原因。
- **BBP 阈值的有限维修正**：$\sqrt{c}$ 是渐近结果，有限 $n, d$ 下过渡带变宽；阈值附近的结论不可靠
- **重尾拟合**：有限范围幂律拟合是经验假设。比较其他分布、拟合区间及留出诊断；HTSR 是可选诊断框架，不是所有训练网络的替代理论。
- **乘积随机矩阵**：深层网络的 Jacobian 是矩阵乘积，谱由乘积律（自由概率）控制，单层 MP 结论不能直接外推

## 假设检查

逐项检查矩阵方向、中心化、方差归一化、宽高比、零特征值质量，以及结论针对谱内部、软边缘还是尖峰。[Vershynin 作者课程与讲义](https://www.math.uci.edu/~rvershyn/teaching/hdp/hdp.html)。

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
