# 持续同调 (Persistent Homology)

## 最小定义

持续同调追踪拓扑空间在不同尺度 $\epsilon$ 下的同调群 $H_k$ 变化：当 $\epsilon$ 从 0 增大时，拓扑特征（连通分量、洞、空腔）在某个尺度"诞生"，在更大尺度"消亡"。存活时间长的特征是数据的本质拓扑结构，短命的视为噪声。输出是 barcode/persistence diagram。

## 核心公式

- 滤过（filtration）：$\emptyset = K_0 \subseteq K_1 \subseteq \cdots \subseteq K_n = K$（如 Vietoris-Rips 复形 $VR_\epsilon$）
- Vietoris-Rips 复形：$VR_\epsilon = \{\sigma \subseteq X \mid d(x_i, x_j) \leq \epsilon, \forall x_i, x_j \in \sigma\}$
- 持续同调群：$H_k^{i,j} = \text{im}(H_k(K_i) \to H_k(K_j))$
- 持续图（persistence diagram）：$D_k = \{(b_l, d_l)\}$，$b_l$ 为诞生尺度，$d_l$ 为消亡尺度
- Bottleneck 距离：$d_B(D, D') = \inf_\gamma \sup_x \|x - \gamma(x)\|_\infty$
- 持续性景观（persistence landscape）：$\lambda_k(t) = \sup\{m \mid \text{rank } H_k^{t-m, t+m} \geq k\}$

## 适用问题

- 点云数据的拓扑特征提取：检测聚类数、环、空腔等全局结构
- 隐空间质量评估：VAE/GAN 生成的隐空间是否保留了数据的拓扑结构
- 时间序列分析：Takens 嵌入后的持续同调揭示动力学拓扑
- 图/网络分析：检测社区结构、瓶颈、高阶关联

## AI 设计翻译

- **拓扑正则化损失**：$L_{\text{topo}} = d_B(D_{\text{latent}}, D_{\text{data}})$，强制隐空间的持续图匹配数据的持续图，保持拓扑
- **持续图特征化层**：将 persistence diagram 转为固定维向量（persistence image/landscape/silhouette），作为下游分类/回归的输入
- **拓扑感知的聚类**：用 $H_0$ 的持续区间自动确定聚类数，长存活连通分量 = 真实簇
- **隐空间拓扑监控**：训练中实时计算 latent space 的 $H_1$（洞），检测拓扑坍塌（所有洞消失 = 后验坍塌）

## 工程可行性

GPU 友好度有限，是持续同调落地的主要瓶颈：
- **距离矩阵计算**：$O(n^2)$，batched 成对距离，GPU 友好
- **Vietoris-Rips 构建**：组合爆炸，$n$ 个点的 VR 复形最多 $2^n$ 个单纯形；实践中截断到 2-维，$O(n^3)$ 最坏
- **边界矩阵约化（核心算法）**：类似高斯消元的列约化，**高度串行**，标准算法不可并行化
- **GPU 加速的约化算法**：如 Ripser 的 clearing 优化 + GPU 版约化（Emerald 等），可加速 10-100x，但仍不及 GEMM 的并行度
- **可微替代**：persistence image 是可微的（对点位置的梯度可算），但 barcode 本身在诞生/消亡点不可微
- 复杂度：精确计算最坏 $O(n^3)$（2 维 VR），大规模点云（$n > 10^4$）需要子采样

## 风险与失效条件

- **边界矩阵约化的串行性**：核心算法本质串行，GPU 并行度远低于 GEMM，大规模数据不可行
- **组合爆炸**：VR 复形的单纯形数随维数指数增长，必须截断到 2-3 维
- **不可微性**：barcode 的离散组合结构对输入点位置不可微（在诞生/消亡事件处），需要 landscape/image 等可微代理
- **尺度选择的主观性**：滤过的尺度范围和截断阈值需要手动选择
- **拓扑 ≠ 几何**：持续同调只捕捉拓扑不变量，丢失度量信息（距离、角度），可能不够区分不同数据集
- **子采样偏差**：大规模数据必须子采样，不同子采样的持续图可能有显著差异

## 深入参考

- 蒸馏稿：references/books/smooth-manifolds.md（Ch 17-18 De Rham Cohomology，拓扑不变量概念来源）
- 蒸馏稿：references/books/algebraic-geometry-rising-sea.md（§18 Cech Cohomology, §23 Derived Functors，上同调计算）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 17-18（de Rham 上同调）
- 延伸：Edelsbrunner & Harer, *Computational Topology: An Introduction*（持续同调标准教材）


## 路由扩展
- 若需要拓扑不变量的计算 → `euler-characteristic.md`（Euler 示性数作为 Betti 数的交替和）
- 若需要 1 维拓扑分析 → `fundamental-group.md`（基本群捕捉环路结构）
- 若用于信息保持压缩 → `information-bottleneck.md`（拓扑保持的信息压缩）

## 可扩展方向
- 单纯复形类型（Cech, Vietoris-Rips, alpha）：不同复形构造的优缺点
- 层论（sheaf theory）：局部到全局的一致数据结构
- Mapper 算法：基于持续同调的可视化与聚类
- 拓扑数据分析（topological data analysis）：TDA 的完整方法论
- 持续图像/景观（persistence image / landscape）：持续图的向量化表示
- 多参数持续（multiparameter persistence）：多尺度过滤的同调
- zigzag 持续（zigzag persistence）：允许双向过滤的持续同调
