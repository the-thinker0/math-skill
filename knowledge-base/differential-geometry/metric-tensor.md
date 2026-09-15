# 度量张量 (Metric Tensor)

## 最小定义

度量张量 $g$ 是流形上每点 $p$ 处切空间 $T_pM$ 上的一个正定对称双线性形式 $g_p: T_pM \times T_pM \to \mathbb{R}$，定义了流形上的内积、长度、角度和距离。它是"谁离谁近、什么方向最陡"的精确量化。

## 核心公式

- 内积：$\langle u, v \rangle_g = u^T g_p v = \sum_{ij} g_{ij} u^i v^j$
- 弧长：$ds^2 = \sum_{ij} g_{ij} dx^i dx^j$
- 测地距离：$d(p,q) = \inf_\gamma \int_0^1 \sqrt{g_{\gamma(t)}(\dot\gamma, \dot\gamma)} \, dt$
- 升降指标（musical isomorphism）：$v^\flat = gv$（切→余切），$\omega^\sharp = g^{-1}\omega$（余切→切）
- Fisher-Rao 度量：$g_{ij}(\theta) = \mathbb{E}_{p_\theta}\left[\frac{\partial \log p_\theta}{\partial \theta^i} \frac{\partial \log p_\theta}{\partial \theta^j}\right]$

## 适用问题

- Fisher 信息为正则可识别统计族提供度量，但可能奇异，也不必有非零黎曼曲率；固定协方差高斯位置族是平坦例子。
- 优化收敛缓慢：条件数差源于度量不匹配，用自然梯度 $g^{-1}\nabla L$ 预条件
- 距离/相似度需要适应数据几何：度量学习本质是学习一个 $g$
- 体积计算与密度估计：$\sqrt{\det g}$ 给出流形上的体积形式

## AI 设计翻译

- **自然梯度/K-FAC 优化器**：$F^{-1}\nabla L$ 其中 $F$ 是 Fisher 度量；K-FAC 用 Kronecker 因子化 $F \approx A \otimes B$ 使求逆变为两个小矩阵求逆，预条件作用退化为 GEMM 链
- **可学习度量层**：$g=L^TL+\epsilon I$，$\epsilon>0$ 保证正定；仅 $L^TL$ 在 $L$ 秩亏时只半正定。
- **信息几何正则化**：$d\theta^TFd\theta$ 是切向量的局部二次型，不是任意两点间精确 Fisher-Rao 距离。张量变换保持该局部量；有限坐标差/近似Fisher不自动保持精确不变性。
- **Fisher 感知的学习率调度**：$\|g^{-1}\nabla L\|_g$ 作为"几何正确"的梯度范数，指导学习率选择

## 工程可行性

GPU 友好度取决于度量的结构化程度：
- **对角度量** $g = \text{diag}(g_1, \ldots, g_n)$：逐元素乘除，$O(n)$，完美 GPU 友好
- **Kronecker 因子化** $g = A \otimes B$：$(A\otimes B)^{-1} = A^{-1}\otimes B^{-1}$，小矩阵求逆 + GEMM 链，K-FAC 的核心 trick，GPU 可行
- **块对角度量**：逐块独立求逆，batched 小矩阵运算，GPU 友好
- **全稠密度量**：$n \times n$ 矩阵求逆 $O(n^3)$ + 显存 $O(n^2)$，参数量 $N \sim 10^9$ 时直接出局
- 低精度风险：检查条件数、求解残差并比较目标精度；按需阻尼/升精度。阻尼改变算子，fp32 本身不保证求解可靠。

## 风险与失效条件

- **度量矩阵病态**：精度与条件数共同控制求解误差；冗余参数化的 Fisher 可能秩亏，应显式处理正定性与可识别性。
- **物化全度量矩阵**：$N \times N$ 矩阵（$N \sim 10^9$）需 $\sim 4$ EB 显存，不可能物化
- **度量与任务不匹配**：Fisher 可以按模型分布定义，不要求模型等于真实分布；但模型误设定或目标差异会影响其优化价值。
- **动态度量更新开销**：Fisher 矩阵随参数变化，每步重新估计的统计噪声可能抵消预条件收益

## 深入参考

- 蒸馏稿：../../references/books/differential-geometry.md（Ch 7 §7.6 Metric Tensors, Ch 13 §13.1 Levi-Civita）
- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 13 Riemannian Metrics）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §7.6 Metric Tensors
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 13（黎曼度量、升降指标 (sharp)/(flat)）


## 路由扩展
- 若度量来自 Fisher 信息 → `../information-geometry/natural-gradient.md`（Fisher 度量下的自然梯度）
- 若需要黎曼梯度计算 → `../optimization/riemannian-optimization.md`（度量决定的梯度方向）
- 若需要曲率分析 → `curvature.md`（度量决定的曲率张量）

## 可扩展方向
- Finsler 度量（Finsler metric）：非二次型的广义度量
- 亚黎曼度量（sub-Riemannian metric）：分布约束下的度量
- 信息度量（information metric）：统计流形上的 Fisher-Rao 度量
- 拉回度量（pullback metric）：映射诱导的度量
- 度量学习（metric learning）：从数据学习最优度量
- 距离度量学习（distance metric learning）：监督距离学习
