# Fisher 度量 / Fisher-Rao Metric

## 最小定义
Fisher-Rao 度量是概率分布族（统计模型）参数空间上的**黎曼度量**，其度量张量恰好是 Fisher 信息矩阵。它赋予参数空间一个内蕴几何结构，使得概率分布之间的"距离"可以用几何语言（测地线、曲率、联络）来描述，是信息几何的核心结构。

## 核心公式

**度量张量（即 Fisher 信息矩阵）**：
$$g_{ij}(\theta) = \mathcal{I}_{ij}(\theta) = \mathbb{E}_\theta\left[\frac{\partial \log p}{\partial \theta_i} \frac{\partial \log p}{\partial \theta_j}\right]$$

**线元（分布间的无穷小距离）**：
$$ds^2 = \sum_{i,j} g_{ij}(\theta) \, d\theta_i \, d\theta_j = 2 \, D_{KL}(p_\theta \| p_{\theta+d\theta})$$

**测地线距离（有限分布间距离）**：
$$d(p_{\theta_1}, p_{\theta_2}) = \inf_{\gamma} \int_0^1 \sqrt{\dot{\gamma}^T \mathcal{I}(\gamma(t)) \dot{\gamma}} \, dt$$

**$\alpha$-联络族**（定义"直线"的不同方式）：
$$\Gamma_{ijk}^{(\alpha)} = \mathbb{E}\left[\left(\partial_i \partial_j \ell + \frac{1-\alpha}{2} \partial_i \ell \, \partial_j \ell\right) \partial_k \ell\right]$$
- $\alpha = 0$：Levi-Civita 联络（度量兼容），对应"中点"对称
- $\alpha = 1$：$e$-联络（指数联络），对应指数族的自然参数直线
- $\alpha = -1$：$m$-联络（混合联络），对应混合族的期望参数直线

**对偶平坦性**：$(\mathcal{M}, g, \nabla^{(e)}, \nabla^{(m)})$ 构成对偶平坦流形——$e$-联络和 $m$-联络关于 $g$ 互为对偶，广义勾股定理成立。

## 适用问题
- **分布间的几何距离**：比较两个概率模型（如两个语言模型的输出分布）的"本质差异"
- **统计模型复杂度度量**：Fisher 度量诱导的体积元 $\sqrt{\det \mathcal{I}(\theta)} \, d\theta$ 用于 MDL/BIC 中的模型复杂度惩罚
- **参数化无关优化**：确保优化算法的行为不依赖于参数的具体选取方式（reparameterization invariance）

## AI 设计翻译
- **Wasserstein vs. Fisher-Rao 在生成模型中**：GAN 用 Wasserstein 距离度量分布差异；Fisher-Rao 度量提供替代方案——在分布族的参数空间上做几何感知优化
- **预训练模型空间的几何**：将不同 checkpoint 视为统计流形上的点，Fisher 测地线距离可用于模型选择、合并（model merging）和插值路径规划
- **MoE 专家分布的几何分析**：不同专家的输出分布在 Fisher 度量下的分离度可量化专家多样性

## 工程可行性
- **D1[x]**：完整度量张量 $g_{ij}$ 是 $d \times d$，$d \sim 10^{10}$ 时不可物化
- **D2[~]**：Kronecker/对角近似可，精确度量不可
- **D3[x]**：测地线计算需解二阶 ODE，精确计算不可行
- **D4[x]**：完整度量张量存储 $O(d^2)$，LLM 级完全不可能
- **D5[~]**：度量张量的条件数可能很大，低精度下不稳定
- **D6[~]**：近似版本（K-FAC、对角）可并行，精确版本不可
- **D7[~]**：Fisher 信息矩阵通常稠密；块对角近似（层间独立）引入结构化稀疏
- **D8[v]**：近似版本可融入优化器更新

**结论**：精确 Fisher 度量在 LLM 规模下不可行，但**近似版本**（K-FAC、对角 Fisher、低秩）在工程上可落地。信息几何的理论价值主要在**指导设计**而非直接计算。

## 风险与失效条件
- **计算复杂度致命**：$d$ 维参数空间的度量张量有 $O(d^2)$ 个独立分量，LLM 级无法承受。所有实用方案必须做近似（对角、Kronecker、低秩），近似质量决定实际效果。
- **统计流形的奇点**：在参数空间的某些区域（如混合分布的退化点），Fisher 度量可能退化（$\det \mathcal{I} = 0$），导致测地线距离不定义。在 MoE 中某专家权重为零时即出现此类退化。

## 深入参考
- 蒸馏稿：`references/books/` 暂无专用信息几何蒸馏稿
- Amari & Nagaoka. *Methods of Information Geometry*. AMS/Oxford, 2000
- Amari. *Information Geometry and Its Applications*. Springer, 2016
- Ay, Jost, Le, Schwachhofer. *Information Geometry*. Springer, 2017
- 关联知识卡：`probability/fisher-information.md`、`information-geometry/natural-gradient.md`
