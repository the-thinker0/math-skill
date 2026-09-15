# 格拉斯曼流形与 Plücker 嵌入 / Grassmannian and Plücker Embedding

## 最小定义
格拉斯曼流形 $\mathsf{Gr}(k,n)$ 是 $n$ 维向量空间中所有 $k$ 维线性子空间的参数空间，是基域上维数为 $k(n-k)$ 的光滑射影簇；本文用复数域，其实维数为 $2k(n-k)$（实 Grassmannian 的实维数为 $k(n-k)$）。它把"子空间"作为几何点参数化，使子空间运算（投影、求交、距离）可表示为几何运算。

Plücker 嵌入 $\mathsf{Gr}(k,n)\hookrightarrow\mathbb{P}(\Lambda^k\mathbb{C}^n)$ 把每个子空间 $V=\mathsf{span}(v_1,\ldots,v_k)$ 映射为其基底的外积 $[v_1\wedge\cdots\wedge v_k]$，将子空间表示为射影齐次坐标。这是把几何对象（子空间）转化为代数对象（外代数元素）的标准方式。

## 核心公式
- **格拉斯曼流形定义**：$\mathsf{Gr}(k,n)=\{k\text{-dim subspaces of }\mathbb{C}^n\}$
- **维数**：$\dim_{\mathbb C}\mathsf{Gr}_{\mathbb C}(k,n)=k(n-k)$；相应实维数为 $2k(n-k)$。
- **Plücker 嵌入**：$V=\mathsf{span}(v_1,\ldots,v_k)\mapsto[v_1\wedge\cdots\wedge v_k]\in\mathbb{P}(\Lambda^k\mathbb{C}^n)$
- **Plücker 坐标**：$p_{i_1\cdots i_k}=\det(v_{i_j}^{(i)})$（基底向量在 $i_1,\ldots,i_k$ 行上的子行列式），共 $\binom{n}{k}$ 个
- **Plücker 关系**（Plücker 坐标满足的二次关系）：$\sum_{j=1}^{k+1}(-1)^j p_{i_1\cdots\hat{i_j}\cdots i_{k+1}}\cdot p_{j_1\cdots j_{k-1}i_j}=0$
- **Schubert 胞腔分解**：$\mathsf{Gr}(k,n)=\bigsqcup_\lambda\Omega_\lambda$（按子空间与固定 flag 的相对位置分层）
- **存储比较**：Plücker 有 $\binom nk$ 个齐次坐标，基底有 $nk$ 个数；中间 k 时前者可极大，但 k=1 或接近 n 的情况不能一概称膨胀。
- **弦距离（非测地距离）**：正交/酉基的主角为 $\Theta$，$d_{chord}(V,W)=\|\sin\Theta\|_F$；标准 Grassmann 测地距离为 $\|\Theta\|_F$。

## 适用问题
- **子空间表示压缩**：区分只依赖子空间的任务与需要重构矩阵的任务；后者必须保留系数，不能用一个 Grassmann 点替代完整 KV-Cache。
- **子空间聚类**：多个低秩子空间的并集表示
- **表示学习的几何结构分析**：特征空间作为子空间族，度量子空间间距离
- **特征空间中的距离/度量定义**：用投影度量而非欧氏距离
- **多模态对齐**：各模态表示子空间的对齐
- **主角度与主向量**：子空间间的"夹角"作为相似度度量

## AI 设计翻译
- **格拉斯曼参数化**：存储 KV-Cache/LoRA 的子空间基底时，还须保留重构所需的 token/矩阵系数；子空间本身丢失幅值与行身份。
- **按尺寸选择表示**：实际比较 $dk$ 与 $\binom dk$，只在后者明显更大时称基底更经济；外积的因子并不保存原矩阵的系数。
- **主角度作为子空间相似度**：$d(V,W)=\|\sin\Theta\|_F$ 作为子空间距离，用于多视图对齐
- 对应设计模式见 `../../design-patterns/compression/low-rank-kv-cache.md`、`../../design-patterns/representation/shared-private-decomposition.md`、`../../design-patterns/representation/subspace-alignment.md`；无对应模式时标为"临时设计翻译"。

## 工程可行性

用实正交基 $U\in\mathbb R^{n\times k}$（复情形用酉基与共轭转置）。QR 通常 $O(nk^2)$；主角计算涉及 $U^TV$ 和 $k\times k$ SVD。精度、条件数与融合可行性需测，不能默认 bf16 QR 准确。

对 $A\in\mathbb R^{L\times d}$，rank-$k$ 重构需系数与基底，共 $O(Lk+dk)$ 存储，单个 Grassmann 点不足。Plücker 坐标数为 $\binom dk$；按实际维度比较，不能说任意低秩都膨胀（$k=1$ 是例外）。$\|\sin\Theta\|_F=\|UU^T-VV^T\|_F/\sqrt2$ 是弦距离，标准测地距离为 $\|\Theta\|_F$。

## 风险与失效条件

- 区分实/复 Grassmannian 与相应维数。
- 只保留子空间会丢掉系数；先证明任务只依赖子空间，再这样压缩。
- QR 不给出子空间唯一基；比较需对换基不变。
- Plücker 坐标数在 $k=d/2$ 附近最大，是否膨胀需按实际 $d,k$ 判断。
- 近重合子空间用 acos 求小角可能损失精度；采用稳定 SVD/CS 或残差方法。
- 保留子空间能量不自动保留 attention/任务行为。

## 深入参考
- 蒸馏稿：`../../references/books/algebraic-geometry-rising-sea.md`
- 蒸馏稿：`../../references/books/matrix-analysis.md`（§2.6 SVD、主角度）
- 原书：Ravi Vakil, *The Rising Sea*, Ch on Grassmannians
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., §2.5 (angles between subspaces)

## 路由扩展
- 若需要低秩近似 → `../matrix-analysis/low-rank-approximation.md`（Eckart-Young、随机化 SVD）
- 若需要子空间投影 → `../matrix-analysis/projection.md`（正交投影）
- 若需要矩阵扰动 → `../matrix-analysis/matrix-perturbation.md`（Davis-Kahan 主角度扰动界）
- 若需要几何视角 → `../../lenses/geometric.md`（度量/曲率）
- 若需要对称性视角 → `../../lenses/symmetry.md`（GL(n) 作用）

## 可扩展方向

黎曼优化、子空间跟踪、带谱隙条件的扰动界与换基不变的对齐。
