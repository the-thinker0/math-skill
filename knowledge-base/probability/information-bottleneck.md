# 信息瓶颈 / Information Bottleneck

## 最小定义
信息瓶颈（IB）是一种表示学习理论框架：给定输入 $X$ 和目标 $Y$，寻找压缩表示 $Z$，使其**尽可能丢弃 $X$ 中与 $Y$ 无关的信息，同时保留对预测 $Y$ 有用的信息**。它将学习问题重新表述为信息论约束优化。

## 核心公式

**IB 目标函数**：
$$\min_{p(z|x)} \; I(X; Z) - \beta \cdot I(Z; Y)$$

其中 $\beta > 0$ 为拉格朗日乘子，控制**压缩-预测**的权衡：
- $I(X; Z)$：表示 $Z$ 中保留的关于输入 $X$ 的信息量（越小 = 压缩越强）
- $I(Z; Y)$：表示 $Z$ 中关于目标 $Y$ 的信息量（越大 = 预测越好）

**变分下界**（实际可计算版本）：
$$\mathcal{L}_{VIB} = \mathbb{E}_{p(x,y)}[-\log q_\phi(y|z)] + D_{KL}(p_\theta(z|x) \| r(z))$$

其中 $q_\phi(y|z)$ 为分类器/解码器，$r(z)$ 为先验分布（通常为 $\mathcal{N}(0,I)$），$p_\theta(z|x)$ 为编码器。

**IB 曲线**：在 $(I(X;Z), I(Z;Y))$ 平面上，帕累托最优解构成一条凹曲线，拐点处对应最优压缩率。

## 适用问题
- **理解深度网络的学习动态**：信息平面（Information Plane）分析——每层的 $(I(X;Z_l), I(Z_l;Y))$ 随训练的变化轨迹
- **表示学习的理论指导**：为什么正则化（dropout、weight decay）有效——它们在隐式压缩冗余信息
- **特征选择与降维**：在压缩率和预测性能之间寻找帕累托最优点

## AI 设计翻译
- **VIB 层 Variational Information Bottleneck**：编码器 $p_\theta(z|x)$ + KL 正则 + 解码器 $q_\phi(y|z)$，本质与 VAE 结构相同但目标语义不同（VAE 重构 $X$，VIB 预测 $Y$）
- **$\beta$-VAE 的统一视角**：$\beta$-VAE 的目标函数与 VIB 形式一致，$\beta$ 即为 IB 拉格朗日乘子
- **注意力稀疏化 / 路由的信息论解释**：Sparse Attention 和 MoE 路由可理解为隐式信息瓶颈——选择性地让"有用" token 通过，丢弃噪声

## 工程可行性
- **维度 1 张量化 ✅**：VIB 的编码器/解码器均为标准网络，$D_{KL}$ 为逐元素计算
- **维度 2 GEMM 可映射 ✅**：主体计算为标准前向网络 + GEMM
- **维度 3 复杂度 ✅**：相比原始网络仅增加 KL 项的 $O(d)$ 计算
- **维度 4 显存 ⚠️**：需要额外维护先验分布 $r(z)$ 的参数和 KL 计算中间量
- **维度 5 低精度 ✅**：重参数化技巧 + KL 解析解在 bf16 下稳定
- **维度 8 算子融合 ✅**：与标准训练流程无冲突，可正常融合

## 风险与失效条件
- **$I(X;Z)$ 的精确估计困难**：高维连续变量间的互信息估计本身是开放问题（MINE、NWJ 等估计器方差大），实际用 VIB 变分下界绕过，但下界可能很松。
- **$\beta$ 调参敏感**：$\beta$ 过大会过度压缩（欠拟合），过小则退化为标准 ERM（无压缩效果）。需要信息平面分析或自适应 $\beta$ 调度。

## 深入参考
- 蒸馏稿：`references/books/` 暂无专用 IB 蒸馏稿
- Tishby, Pereira, Bialek. "The Information Bottleneck Method." *arXiv:physics/0004057*, 2000
- Alemi, Poole, Fischer, Dillon, Suresh, Murphy. "Deep Variational Information Bottleneck." *ICLR*, 2017
- Shwartz-Ziv, Tishby. "Opening the Black Box of Deep Neural Networks via Information." *arXiv:1703.00810*, 2017
- 关联知识卡：`probability/entropy.md`、`probability/kl-divergence.md`
