# 数学出处与经典文献 / Mathematical Sources and Classic Texts

## 傅里叶变换 / Fourier Transform (1822)

> "任何周期函数都可以表示为正弦函数和余弦函数的无穷级数。"
> "Any periodic function can be expressed as an infinite series of sine and cosine functions."

傅里叶级数：f(x) = a₀/2 + Σ[aₙcos(nx) + bₙsin(nx)]

傅里叶变换：F(ω) = ∫f(t)e^(-iωt)dt

**核心思想**：时域中的复杂信号在频域中可能很简单。变换的力量在于改变了问题的表示方式。

**变换的魔术效果**：
- 时域中的卷积 = 频域中的乘法
- 时域中的微分 = 频域中的乘法（乘以 iω）
- 这使得微分方程可以转化为代数方程

**出处**：Joseph Fourier, *Théorie analytique de la chaleur* (1822) — 最初为热传导问题而发展，其影响远远超出了热力学。

## 快速傅里叶变换 / FFT — Cooley-Tukey Algorithm (1965)

> O(n log n) vs O(n²)：从此，傅里叶变换从理论工具变为工程现实。
> O(n log n) vs O(n²): Fourier transform went from theoretical tool to engineering reality.

**核心思想**：利用分治策略将离散傅里叶变换(DFT)的复杂度从 O(n²) 降低到 O(n log n)。对于 n = 10⁶ 的数据，加速约 10⁶/log(10⁶) ≈ 50000 倍。

**历史背景**：Cooley & Tukey (1965) 的论文使 FFT 广为人知，但相同思想可追溯至 Gauss (1805)。被广泛认为是 **20世纪最重要的数值算法** / the most important numerical algorithm of the 20th century。

**应用**：信号处理、图像压缩(JPEG)、频谱分析、大整数乘法、偏微分方程数值解。

## 拉普拉斯变换 / Laplace Transform (1780s)

> L{f(t)} = ∫₀^∞ f(t)e^(-st)dt

**核心思想**：将微分方程转化为代数方程，求解后再逆变换回来。与傅里叶变换相比，拉普拉斯变换能处理不收敛的函数（通过引入收敛因子 e^(-st)）。

**出处**：Laplace 在 1780s 发展此变换用于概率论，后由 Heaviside 系统应用于电路分析。

## 小波变换 / Wavelet Transform — Morlet (1980s), Daubechies (1988)

> 傅里叶变换告诉你"有什么频率"，小波变换还告诉你"什么时候有"。
> Fourier tells you "what frequencies exist"; wavelets also tell you "when they exist."

**核心思想**：傅里叶变换只有频率分辨率没有时间分辨率；小波变换通过可缩放、可平移的基函数实现 **时频局部化** / time-frequency localization。

**历史**：Morlet (1982) 在地震信号分析中提出连续小波变换；Daubechies (1988) 构造了紧支撑正交小波基，使离散小波变换成为现实。

**数学意义**：小波基不是单一的三角函数族，而是由一个母小波 ψ 通过缩放和平移生成：ψ_{a,b}(t) = |a|^(-1/2) ψ((t-b)/a)。多分辨率分析(MRA)提供了统一的数学框架。

## 勒让德变换 / Legendre Transform

> 凸分析中的对偶变换：将一个凸函数的描述从"值"转为"斜率"。
> The duality transform in convex analysis: describes a convex function by its slopes instead of its values.

f*(p) = sup_x [px - f(x)]

**核心思想**：对于凸函数，"函数值"和"导数（斜率）"携带相同信息——它们是对偶描述。这是数学中 **对偶性** / duality 的核心实例。

**物理中的双重角色**：
- **热力学**：熵 S ↔ 自由能 F（通过温度 T 对偶）；内能 ↔ 吉布斯能
- **力学**：拉格朗日量 L(v,q) ↔ 哈密顿量 H(p,q)（通过 v ↔ p 对偶）
- **优化**：原问题 ↔ 对偶问题（拉格朗日对偶）

**出处**：Legendre (1787) 在最小曲面问题中引入；此后成为凸分析和变分学的基石。

## 生成函数 / Generating Functions — Euler (1748), Laplace

> 将序列编码为幂级数的系数，卷积运算变成乘法运算。
> Encode a sequence as coefficients of a power series; convolution becomes multiplication.

G(x) = Σ aₙxⁿ

**核心思想**：一个无穷序列 {a₀, a₁, a₂, ...} 被压缩为一个函数 G(x)。序列的递推关系变成函数的微分方程；两个序列的卷积变成两个函数的乘积。

**经典应用**：
- **组合计数**：Euler 用生成函数解决分割数问题； partitions of integers
- **概率论**：矩生成函数 M(t) = E[e^(tX)]，特征函数 φ(t) = E[e^(itX)]
- **数论**：Riemann ζ 函数本质上是素数分布的生成函数
- **递推求解**：斐波那契递推 → 生成函数 → 闭式解

**出处**：Euler, *Introductio in analysin infinitorum* (1748)；Laplace 在概率论中系统使用。

## 保角映射 / Conformal Mapping — Riemann Mapping Theorem (1851)

> 任何单连通区域都可以保角映射到单位圆盘。
> Any simply connected domain can be conformally mapped onto the unit disk.

**核心思想**：保角映射保持角度和局部形状，但可以扭曲大小和全局形状。在复解析函数 f(z) 下，无穷小圆仍为圆，只是缩放和旋转。

**数学基础**：Riemann 映射定理 (1851) — 复分析中最深刻的结果之一，保证了映射的存在性。

**应用**：
- **2D 边值问题**：将复杂边界区域映射为简单区域（圆/半平面），在那里求解后映射回来
- **流体力学**：势流问题的经典解法
- **空气动力学**：翼型设计（Joukowski 变换 z → z + 1/z）
- **静电学**：复杂几何下的电势计算

## Z变换 / Z-Transform — Discrete Counterpart of Laplace

> X(z) = Σ x[n]z^(-n) — 采样世界中的拉普拉斯变换。
> X(z) = Σ x[n]z^(-n) — the Laplace transform for the sampled world.

**核心思想**：拉普拉斯变换处理连续时间信号 s = σ + iω；Z变换处理离散时间信号 z = re^(iω)。令 z = e^(sT) 即可联系两者。

**数字信号处理中的核心地位**：
- 系统稳定性判断：单位圆 |z| = 1 对应频率轴，极点在圆内 = 稳定
- 数字滤波器设计：FIR / IIR 滤波器的传递函数直接用 Z 变换表示
- 差分方程 → 代数方程（与拉普拉斯变换将微分方程 → 代数方程完全类比）

**历史**：1947年由 Hurewicz 等人在采样数据控制系统中引入；名称 "Z-transform" 由 Ragazzini & Zadeh (1952) 给出。

## Plancherel 定理 / Parseval 定理 — Transforms Preserve Information

> ∫|f(t)|²dt = ∫|F(ω)|²dω — 能量在时域和频域中守恒。
> Energy is conserved between time domain and frequency domain.

**核心思想**：好的变换不丢失信息——变换前后，总能量（L² 范数的平方）完全相等。这意味着变换是 **等距映射** / isometry。

**Parseval 定理** (1799)：傅里叶级数形式 — Σ|aₙ|² + Σ|bₙ|² = (1/π)∫|f(x)|²dx

**Plancherel 定理** (1910)：傅里叶变换形式 — ∫|f|² = ∫|F|²，给出变换在 L² 空间上的酉性 / unitarity。

**哲学含义**：可逆变换保证信息守恒——我们可以自由切换视角而不丢失任何东西。这是变换思想中 "可逆性" 的数学基础。

## Mellin 变换 / Mellin Transform — Scaling Analysis

> M{f}(s) = ∫₀^∞ f(t)t^(s-1)dt — 尺度变换下的傅里叶变换。
> The Fourier transform under scaling changes.

**核心思想**：令 t = e^(-x)，Mellin 变换就变成傅里叶变换。它天然地与 **缩放** / scaling 运算对偶——函数 f(at) 在 Mellin 空间中仅乘以 a^(-s)。

**核心应用**：
- **解析数论**：Riemann ζ 函数的 Mellin 变换表示是素数计数函数的桥梁
- **渐近分析**：Mellin 变换方法可提取函数的渐近展开（主项+修正项）
- **分形与自相似性**：自相似函数在 Mellin 空间中有特别简单的表示

**出处**：Hjalmar Mellin (1904) 系统发展；更早可追溯至 Euler 对 ζ 函数的研究。

## Radon 变换 / Radon Transform (1917) — Mathematical Basis of CT Scanning

> 将函数沿直线积分，得到其"投影"；逆变换从投影重建原函数。
> Integrate a function along lines to get "projections"; inverse transform reconstructs the original from projections.

R{f}(θ, s) = ∫ f(x·nθ + tnθ⊥)dt （沿方向 θ 的线积分）

**核心思想**：一个物体的所有方向的投影包含了足够的信息来完全重建该物体。这是 **层析成像** / tomography 的数学基础。

**历史与应用**：
- **Radon** (1917)：纯数学论文，证明了逆变换的存在性和唯一性
- **Cormack** (1963-64)：独立重新发现，应用于医学成像
- **Hounsfield** (1971)：发明 CT 扫描仪，两人共获 1979 年诺贝尔医学奖
- **地震学**：反射地震数据的速度重建

## 坐标变换 / Coordinate Transformation

**极坐标**：(x, y) → (r, θ)，适用于旋转对称问题
**球坐标**：(x, y, z) → (r, θ, φ)，适用于球对称问题
**傅里叶空间**：时间信号 → 频率表示

**核心思想**：选择合适的坐标系，可以让复杂的问题变得简单。

## 对角化 / Diagonalization (线性代数)

> 对于一个可对角化的矩阵 A，存在可逆矩阵 P 使得 P⁻¹AP = D（对角矩阵）。

**核心思想**：在特征向量基下，线性变换变得最简单——每个坐标方向独立缩放。

## Jordan 标准形 / Jordan Normal Form — Non-Diagonalizable Matrices

> 不可对角化的矩阵怎么办？Jordan 标准形是最接近对角化的形式。
> What if a matrix cannot be diagonalized? Jordan form is the closest thing to diagonal.

A = PJP⁻¹, J = diag(J₁, J₂, ...), Jₖ = λₖI + Nₖ（λₖ 为特征值，Nₖ 为幂零矩阵）

**核心思想**：当矩阵没有足够的独立特征向量（几何重数 < 代数重数）时，Jordan 块引入了"近似特征向量"——广义特征向量链。幂零部分 Nₖ 使得迭代 Aⁿ 的行为可以被精确计算。

**出处**：Camille Jordan (1870), *Traité des substitutions et des équations algéraiques*。

**应用**：线性 ODE 系统的解（特别是有重根的情况）、矩阵指数 e^(At) 的计算、线性递推的显式解。

## 特征值理论与谱理论 / Eigenvalue Theory & Spectral Theory — Mathematical Heart of Transformation

> 特征值是变换的"DNA"——它们决定了变换的本质行为。
> Eigenvalues are the "DNA" of a transformation — they determine its essential behavior.

Av = λv

**谱定理** (Hilbert, 1909-1912)：自伴算子有实谱，且可以被谱分解——连续维度的"对角化"。

**核心思想**：
- **有限维**：矩阵的特征值决定稳定性（|λ|<1 收敛）、振荡性（λ 虚部）、增长率（λ 实部）
- **无限维**：谱理论将特征值推广到 Hilbert 空间上的自伴算子，量子力学中可观测量 = 自伴算子，其谱 = 可能的测量值
- **稳定性分析**：所有动力系统的稳定性归结为谱的位置

**关键定理**：
- **Gershgorin 圆定理** (1931)：特征值的几何定位
- **Courant-Fischer 极小-极大定理**：特征值的变分刻画
- **Weyl 不等式**：矩阵扰动下谱的连续性

## 变换的哲学含义

> "换一个角度看问题，问题可能就解决了。"

变换思想的深层含义：
- **表示的相对性**：同一个对象在不同表示下有不同面貌
- **变换的不变性**：有些东西在变换下保持不变（这就是对称性）
- **表示的选择**：好的表示让问题简单，坏的表示让问题复杂
- **可逆性**：理想情况下，变换不丢失信息——我们可以自由切换视角（Plancherel 定理的保证）

## 日常生活中的"变换"

- **时间视角变换**：当前的困难，放在 10 年的尺度上看可能微不足道
- **角色视角变换**：站在对方的角度看问题（本质是坐标变换）
- **尺度变换**：宏观和微观视角可能揭示不同的规律（Mellin 变换的直觉）
- **领域变换**：一个问题在一个领域无解，换到另一个领域可能有现成方案（傅里叶：微分→代数；Legendre：力学→力学对偶）