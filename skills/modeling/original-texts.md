# 数学出处与经典文献 / Mathematical Sources and Classic Texts

## Newton《自然哲学的数学原理》/ *Principia Mathematica* (1687)

> "自然界中的同一效应必须尽可能归因于同一原因。"
> "The same effects of nature must always be assigned to the same causes."

**数学建模史上最重要的成就**：Newton 将天体运动与地面运动统一在同一数学框架之下——万有引力定律 F = GMm/r² 与三大运动定律。这是人类首次用系统的数学模型精确描述物理世界，标志着科学建模的诞生。《原理》确立了"数学模型→物理预测→实验验证"的方法论范式，至今仍是所有建模工作的根基。

---

## Fourier 热传导方程 / Fourier's Heat Equation (1822)

> ∂u/∂t = κ ∇²u

Fourier 在《热的解析理论》中提出了热扩散的数学模型，并为此发明了 Fourier 分析——将任意函数分解为三角级数的方法。这一建模成就具有双重意义：既给出了热传导的精确数学描述，又催生了整个调和分析领域。Fourier 变换至今是信号处理、量子力学、图像压缩等领域的核心工具。

**建模启示**：解决一个建模问题所发明的新数学，往往比原模型本身更具深远影响。

---

## Maxwell 方程组 / Maxwell's Equations (1865)

> ∇·E = ρ/ε₀, ∇×E = -∂B/∂t
> ∇·B = 0, ∇×B = μ₀J + μ₀ε₀∂E/∂t

Maxwell 将电学与磁学统一为四个偏微分方程，从数学模型中预言了电磁波的存在——此预言后被 Hertz 实验证实。这是建模史上最辉煌的范例之一：仅凭数学推演便发现了全新的物理现象。方程还隐含光速 c = 1/√(μ₀ε₀)，将光学纳入电磁理论，堪称统一建模的巅峰。

---

## Lotka-Volterra 捕食者-猎物模型 (1925-1926)

经典的种群动力学模型：

> dx/dt = αx - βxy （猎物增长 - 被捕食）
> dy/dt = δxy - γy （捕食者增长 - 自然死亡）

**建模启示**：通过两个简单的微分方程，成功解释了自然界中捕食者和猎物种群的周期性振荡现象。这是"好模型"的典范——简单但有用。

---

## Kermack-McKendrick SIR 传染病模型 (1927)

> dS/dt = -βSI （易感者减少）
> dI/dt = βSI - γI （感染者变化）
> dR/dt = γI （康复者增加)

**建模启示**：基本再生数 R₀ = β/γ 决定了疫情是否会爆发。Kermack 与 McKendrick 于 1927 年在论文 "A Contribution to the Mathematical Theory of Epidemics" 中首次提出此模型，奠定了传染病数学建模的理论基础。这个简单的模型在新冠疫情期间被广泛使用，证明了经典模型的持久价值。

---

## Buckingham Pi 定理 / Buckingham Pi Theorem (1914)

> 若物理关系涉及 n 个变量、含 k 个独立量纲，则该关系可简化为 (n-k) 个无量纲 Π 组之间的关系。

**建模启示**：Buckingham Pi 定理将量纲分析形式化，是建模中极其重要的简化工具。它告诉我们：任何物理模型都可化为无量纲形式，从而减少参数个数、揭示本质结构。例如，流体力学中雷诺数 Re = ρvL/μ 就是一个 Π 量，它统一了无数看似不同的流动情形。

---

## Turing 反应-扩散模型 / Turing's Reaction-Diffusion Model (1952)

> ∂u/∂t = D_u ∇²u + f(u,v)
> ∂v/∂t = D_v ∇²v + g(u,v)

Turing 在论文 "The Chemical Basis of Morphogenesis" 中证明：两种扩散速率不同的化学物质相互作用，可在均匀状态下产生稳定的空间图案——斑纹、条纹、螺旋等。这是形态发生的数学模型，解释了从豹斑到海贝壳花纹的广泛现象。

**建模启示**：数学模型可以解释"有序如何从无序中涌现"——无需预设图案，纯由方程动力学自发产生。Turing 由此开创了模式形成理论。

---

## Lorenz 系统 / Lorenz System (1963)

> dx/dt = σ(y - x)
> dy/dt = x(ρ - y) - xz
> dz/dt = xy - βz

Lorenz 在数值模拟大气对流模型时发现：初始条件的微小差异会导致完全不同的长期行为——即"蝴蝶效应"。三个看似简单的方程揭示了混沌的本质特征：确定性系统的长期不可预测性。

**建模启示**：混沌理论深刻改变了建模哲学——即便模型完全正确，长期预测也可能本质不可能。建模者必须区分"可预测的时间尺度"与"不可预测的混沌区域"。

---

## Kalman 滤波 / Kalman Filtering (1960)

> x̂_{k|k} = x̂_{k|k-1} + K_k(z_k - H x̂_{k|k-1})

Kalman 滤波是基于状态空间模型的递推估计方法：利用系统动力学模型预测状态，再用观测数据修正预测。它将"模型预测"与"数据更新"统一在一个数学框架中，是现代控制论与信号处理的基石。

**建模启示**：好的建模不仅是"建立模型"，还包括"基于模型做最优估计"。Kalman 滤波展示了模型与数据如何协同工作——模型提供先验，数据提供校正，二者缺一不可。

---

## Pólya《怎样解题》/ *How to Solve It* (1945)

> "数学建模的第一步是理解问题，第二步是制定计划，第三步是执行计划，第四步是回顾。"
> "The first step in mathematical modeling is understanding the problem, the second is devising a plan, the third is carrying out the plan, and the fourth is looking back."

Pólya 的解题框架是建模思想的前身：将未知问题转化为已知的数学问题。

---

## Akaike 信息准则 / Akaike Information Criterion (1974)

> AIC = -2 ln(L_max) + 2k

Akaike 在 1974 年提出 AIC，首次将模型选择问题形式化：在拟合优度 (-2 ln L) 与模型复杂度 (2k) 之间寻求最优平衡。k 为参数个数，L_max 为最大似然。

**建模启示**：AIC 确立了"简约性原则"的数学标准——不是越复杂越好，也不是越简单越好，而是在信息损失最小化与参数简约化之间取最优折中。这是 Box 名言"有些是有用的"的量化版本。

---

## Black-Scholes 模型 / Black-Scholes Model (1973)

> C = S N(d₁) - K e^{-rT} N(d₂)
> d₁ = [ln(S/K) + (r + σ²/2)T] / (σ√T)
> d₂ = d₁ - σ√T

Black、Scholes 与 Merton 建立了期权定价的数学模型，基于几何布朗运动 dS = μS dt + σS dW 与无套利原理推导出偏微分方程 ∂C/∂t + ½σ²S²∂²C/∂S² + rS∂C/∂S - rC = 0。此模型是金融数学最著名的成果，Scholes 与 Merton 因此获 1997 年诺贝尔经济学奖。

**建模启示**：Black-Scholes 是 Box 名言的最佳注脚——模型假设（常数波动率、连续交易、无摩擦市场）在现实中都是"错的"，但它提供了定价框架与风险管理的核心工具，因而是"有用的"。

---

## George Box 的名言 / George Box's Famous Quote

> "All models are wrong, but some are useful."
> "所有模型都是错的，但有些是有用的。"

**建模哲学**：
- 模型不是现实——它必然是对现实的简化
- 模型的价值不在于"真实性"，而在于其预测和解释能力
- 好模型的标准：简洁（parsimonious）、可检验（testable）、有预测力（predictive）

---

## 建模的一般原则

1. **从简单开始**：先用最简单的模型，然后逐步增加复杂度（Lorenz 用三方程揭示混沌，Lotka-Volterra 用两方程解释振荡）
2. **明确假设**：每个假设都要记录和检验（Black-Scholes 的假设虽错但明确，因此仍可使用）
3. **验证与证伪**：用独立数据检验模型，而不仅是拟合数据（AIC 量化了过拟合的风险）
4. **适用范围**：每个模型都有其适用范围，超出范围即失效（Newton 力学在高速下失效，需 Einstein 修正）
5. **迭代改进**：建模是一个循环过程，不是一次性的（Pólya 的"回顾"步骤）
6. **量纲统一**：用 Buckingham Pi 定理将模型化为无量纲形式，减少参数、揭示结构
7. **模型与数据协同**：Kalman 滤波展示了模型预测与数据校正如何循环工作

---

## 建模史的时间线 / Timeline of Mathematical Modeling

| 年份 | 成就 | 领域 |
|------|------|------|
| 1687 | Newton *Principia* | 力学 / Mechanics |
| 1822 | Fourier 热方程 | 热传导 / Heat diffusion |
| 1865 | Maxwell 方程组 | 电磁学 / Electromagnetism |
| 1914 | Buckingham Pi 定理 | 量纲分析 / Dimensional analysis |
| 1925-26 | Lotka-Volterra | 种群动力学 / Population dynamics |
| 1927 | Kermack-McKendrick SIR | 传染病 / Epidemiology |
| 1945 | Pólya *How to Solve It* | 方法论 / Methodology |
| 1952 | Turing 反应-扩散 | 形态发生 / Morphogenesis |
| 1960 | Kalman 滤波 | 估计与控制 / Estimation & control |
| 1963 | Lorenz 系统 | 混沌 / Chaos theory |
| 1973 | Black-Scholes | 金融 / Finance |
| 1974 | Akaike AIC | 模型选择 / Model selection |

这条时间线揭示了一个核心规律：伟大的建模成就往往跨越学科边界。Newton 统一了天与地，Maxwell 统一了电与磁，Turing 统一了化学与生物学——数学模型的力量恰恰在于它的跨领域普适性。