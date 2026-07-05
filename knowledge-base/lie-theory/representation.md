# 表示 (Representation)

## 最小定义

群 $G$ 在向量空间 $V$ 上的表示是群同态 $\rho: G \to GL(V)$，将抽象群元素实现为可计算的线性变换（矩阵）。表示论的核心问题是：把复杂的群作用分解为不可约表示（irrep）的直和，如同整数分解为素数。

## 核心公式

- 表示：$\rho(g_1 g_2) = \rho(g_1)\rho(g_2)$，$\rho(e) = I$
- 特征标：$\chi_\rho(g) = \text{tr}(\rho(g))$，是类函数，编码表示的核心信息
- Peter-Weyl 定理（紧群）：$L^2(G) \cong \bigoplus_{\pi \in \hat{G}} \dim(\pi) \cdot \pi$
- Schur 引理：$\rho_1, \rho_2$ 不可约且不等价 $\Rightarrow$ $\text{Hom}_G(\rho_1, \rho_2) = 0$
- SO(3) 的不可约表示：维数 $2l+1$，$l = 0,1,2,\ldots$，基函数为球谐函数 $Y_l^m$
- Clebsch-Gordan 分解：$\rho_1 \otimes \rho_2 \cong \bigoplus_k m_k \rho_k$

## 适用问题

- 信号定义在群/球面上：需要用球谐展开做频域分析
- 构建等变特征空间：每个特征通道对应一个不可约表示
- 群卷积的加速：利用 Fourier 变换（不可约表示）将卷积变为频域逐点乘法
- 分子/晶体对称性：点群/空间群的表示决定轨道对称性和选择定则

## AI 设计翻译

- **球谐特征层**：将 3D 点云/分子特征展开为球谐基 $Y_l^m$，每个 $(l,m)$ 通道按 SO(3) 不可约表示变换，实现严格旋转等变
- **群 Fourier 变换层**：有限群信号 $f: G \to \mathbb{R}$ 经 $\hat{f}(\pi) = \sum_g f(g)\pi(g)$ 变换到频域，卷积变为逐 irrep 矩阵乘
- **Schur 约束的权重矩阵**：等变层间映射 $W: V_1 \to V_2$ 必须与群作用交换 $W\rho_1(g) = \rho_2(g)W$，Schur 引理强制 $W$ 为块对角/标量，大幅减少参数
- **特征标池化**：用 $\chi_\rho(g) = \text{tr}(\rho(g))$ 提取不变量作为分类/回归的输入特征

## 工程可行性

GPU 友好度取决于群的规模和表示维数：
- **有限群表示**：每个 irrep 是小矩阵（$d \times d$），群 Fourier 变换 = 一批小 GEMM，$O(|G| \cdot d^2)$，可 batched
- **SO(3) 球谐变换**：有快速算法（$O(L^2 \log L)$），但实现复杂；实空间→频域的变换可表达为稀疏 matmul
- **Clebsch-Gordan 系数**：预计算后是固定的稀疏张量，与特征的缩并可 GEMM 化
- **Schur 约束的稀疏性**：等变层的权重矩阵被约束为块对角/标量，参数大幅减少，但需要稀疏/分块 GEMM
- 关键瓶颈：高维 irrep（大 $l$ 的球谐）的 Clebsch-Gordan 张量规模增长快

## 风险与失效条件

- **高频球谐数值不稳定**：大 $l$ 的 $Y_l^m$ 在极点附近振荡剧烈，fp16 下精度损失严重
- **irrep 完备性截断**：只取到 $l_{\max}$ 阶球谐丢失高频信息，截断误差需要实验标定
- **非紧群的表示无穷维**：Lorentz 群等的不可约表示是无穷维的，工程上必须截断
- **表示选择的自由度**：哪些 irrep 参与、阶数多少是超参数，缺乏自动选择方法
- **Clebsch-Gordan 张量的存储**：$l$ 增大时 CG 系数数量 $O(l^3)$ 增长，预计算和存储开销上升

## 深入参考

- 蒸馏稿：../../references/books/micro-lie-theory.md（§II-F 伴随 Ad_X 与伴随矩阵）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 5 Lie Groups, 伴随表示部分）
- 原书：Joan Sola et al., *A micro Lie theory*, §II-F（伴随表示，式 30-35）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 5（李群的表示）


## 路由扩展
- 若需要等变网络设计 → `equivariance.md`（表示理论驱动等变网络构造）
- 若需要群作用的具体形式 → `group-action.md`（表示是线性群作用）
- 若需要不可约分解 → `../matrix-analysis/spectral-decomposition.md`（类比为矩阵的谱分解）

## 可扩展方向
- 不可约表示（irreducible representation）：表示的基本构建块
- 特征标（character）：表示的迹函数与分类
- Schur 引理：不可约表示间的态射
- Peter-Weyl 定理：紧群的正则表示分解
- 诱导表示（induced representation）：从子群构造大群表示
- 表示的张量积（tensor product of representations）：多粒子系统的组合
- Clebsch-Gordan 系数：张量积分解为不可约的变换系数
