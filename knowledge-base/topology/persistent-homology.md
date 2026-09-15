# 持续同调 (Persistent Homology)

## 最小定义

持续同调追踪拓扑空间在不同尺度 $\epsilon$ 下的同调群 $H_k$ 变化：当 $\epsilon$ 从 0 增大时，拓扑特征（连通分量、洞、空腔）在某个尺度"诞生"，在更大尺度"消亡"。长存活可提示跨尺度稳定结构，但不能不经采样/噪声模型验证就把长条当真实、短条当噪声。输出是 barcode/persistence diagram。

## 核心公式

- 滤过（filtration）：$\emptyset = K_0 \subseteq K_1 \subseteq \cdots \subseteq K_n = K$（如 Vietoris-Rips 复形 $VR_\epsilon$）
- Vietoris-Rips 复形：$VR_\epsilon = \{\sigma \subseteq X \mid d(x_i, x_j) \leq \epsilon, \forall x_i, x_j \in \sigma\}$
- 持续同调群：$H_k^{i,j} = \text{im}(H_k(K_i) \to H_k(K_j))$
- 持续图（persistence diagram）：$D_k = \{(b_l, d_l)\}$，$b_l$ 为诞生尺度，$d_l$ 为消亡尺度
- Bottleneck 距离：$d_B(D,D')=\inf_\gamma\sup_x\|x-\gamma(x)\|_\infty$；匹配允许与无限重数的对角线配对，并固定系数域与无穷持久区间约定。
- 固定同调维数 $h$，第 $j\ge1$ 层景观为 $\lambda_j^{(h)}(t)=\sup\{u\ge0:\operatorname{rank}H_h^{t-u,t+u}\ge j\}$，空集取 0；同调维数与层序不能混用。

## 适用问题

- 点云数据的拓扑特征提取：检测聚类数、环、空腔等全局结构
- 隐空间质量评估：VAE/GAN 生成的隐空间是否保留了数据的拓扑结构
- 时间序列分析：Takens 嵌入后的持续同调揭示动力学拓扑
- 图/网络分析：检测社区结构、瓶颈、高阶关联

## AI 设计翻译

- **持续图正则化**：$L_{topo}=d_B(D_{latent},D_{data})$ 鼓励所选同调维数/滤流的图接近，不保证完整拓扑或语义保持。
- **持续图特征化层**：将 persistence diagram 转为固定维向量（persistence image/landscape/silhouette），作为下游分类/回归的输入
- **拓扑感知的聚类**：用 $H_0$ 的持续区间自动确定聚类数，长存活分量是候选簇，需结合采样与尺度验证
- **隐空间拓扑监控**：跟踪所选滤流的 H₁ 特征；环消失不等于 VAE 后验坍塌，后者需检查潜变量使用与后验/先验关系。

## 工程可行性

令 $n$ 为点数、$M$ 为构造出的单纯形数。二维 skeleton 最坏 $M=O(n^3)$，这是构造大小，不是完整 persistence 算法的 $O(n^3)$ 时间保证。经典一般边界矩阵约化的上界可达 $O(M^3)$ 时间、$O(M^2)$ 空间；稀疏结构、clearing 与专门算法可显著降低实际成本。

GPU/并行算法存在，但依赖复形与数据，不能无基准宣称 10–100 倍加速。先报告截断维数、$M$、非零元数和实际运行资源。固定有限复形、规则滤流参数化下可研究几乎处处可微的 persistence；landscape 是分段线性的，不能统一称光滑。bottleneck 匹配、ties 和退化处需定义梯度/代理。

## 风险与失效条件

- 样本、系数域、距离定义与尺度范围都会改变结果；持续图带有尺度/度量信息，并非完全丢失度量。
- 相同持续图不证明同胚、语义一致或无模式坍塌。
- 原始点云噪声需要稳定性条件；长条不自动代表真结构。
- 子采样/landmark 与截断必须记录；不存在通用的 $n>10^4$ 不可计算阈值。
- 若只需廉价监控，可比较 Euler curve/采样代理，但需明确丢失了哪些信息。

## 深入参考

- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 17-18 De Rham Cohomology，拓扑不变量概念来源）
- 蒸馏稿：../../references/books/algebraic-geometry-rising-sea.md（§18 Cech Cohomology, §23 Derived Functors，上同调计算）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 17-18（de Rham 上同调）
- 延伸：Edelsbrunner & Harer, *Computational Topology: An Introduction*（持续同调标准教材）


## 路由扩展
- 若需要拓扑不变量的计算 → `euler-characteristic.md`（Euler 示性数作为 Betti 数的交替和）
- 若需要 1 维拓扑分析 → `fundamental-group.md`（基本群捕捉环路结构）
- 若用于信息保持压缩 → `../probability/information-bottleneck.md`（拓扑保持的信息压缩）

## 可扩展方向
- 单纯复形类型（Cech, Vietoris-Rips, alpha）：不同复形构造的优缺点
- 层论（sheaf theory）：局部到全局的一致数据结构
- Mapper 算法：基于滤波函数、覆盖与局部聚类的拓扑摘要；不是直接由持续同调计算出的图。
- 拓扑数据分析（topological data analysis）：TDA 的完整方法论
- 持续图像/景观（persistence image / landscape）：持续图的向量化表示
- 多参数持续（multiparameter persistence）：多尺度过滤的同调
- zigzag 持续（zigzag persistence）：允许双向过滤的持续同调
