# Spectral Clustering Routing（谱聚类路由）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当需要基于 token/样本的内在相似性结构进行分组路由时使用。典型场景：
(1) 无监督专家分配——没有路由标签时，用谱聚类自动发现 token 的自然分簇；
(2) 自适应专家初始化——训练初期用谱聚类结果初始化专家参数；
(3) 输入感知的动态聚类——不同 batch 的 token 分布不同，路由应自适应；
(4) 多粒度聚类——不同层使用不同粒度的谱聚类（粗→细）。
核心诉求：**发现数据内在的簇结构，用于路由或专家初始化**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（谱图论、拉普拉斯特征映射）、../../lenses/variational.md（松弛与近似）
- 知识：../../knowledge-base/matrix-analysis/projection.md（特征值分解、Rayleigh 商）、
  ../../knowledge-base/differential-geometry/manifold.md（流形学习、图割）

## 需要的数学知识

- 对称非负相似度 $W$ 构造 $S=D^{-1/2}WD^{-1/2}$、$L=I-S$。$L$ 的最小代数特征值对应 $S$ 的最大**代数**特征值，一般不对应原始 $W$。
- Ng–Jordan–Weiss 在 k-means 前对选出的特征向量矩阵逐行归一化。零度节点需明确约定。
- 普通幂迭代找最大模特征值。若 $S$ 可能不定，可移位为 $(I+S)/2$ 或指定最大代数特征值求解器；不能不加条件地用 SVD 替代特征值排序。
- 特征向量有符号及重特征子空间旋转自由度。对原始特征向量接可学习线性映射不会自动对该选择不变；使用投影子、对齐、不变特征或稳定存储基。
- 归一化核的 Nyström 须使用归一化跨集合相似度及 $S$ 的特征值，即 $1-\lambda_j(L)$；近零分母需截断。

## AI 模块形式

```python
# 固定 landmark X_ref；参考图及归一化冻结
W_ref = rbf_affinity(X_ref, X_ref)
d_ref = W_ref.sum(-1)
S_ref = W_ref / sqrt(d_ref[:, None] * d_ref[None, :])
lam, U = largest_algebraic_eigenpairs(S_ref, K)
keep = abs(lam) > eigenvalue_tolerance
lam, U = lam[keep], U[:, keep]
centers = kmeans(row_normalize(U), K)

W_cross = rbf_affinity(X_new, X_ref)
d_new = W_cross.sum(-1)          # 扩展度约定，参考度保持不变
S_cross = W_cross / sqrt(d_new[:, None] * d_ref[None, :])
embedding = (S_cross @ U) / lam[None, :]
assignment = nearest_center(row_normalize(embedding), centers)
```
这是**冻结参考**归一化核的扩展；将所有新点插入并重算全图度会得到另一个算子。用留出点将扩展与小图重算结果比较。

**锚点图替代**：对非负 $Z\in\mathbb R^{N\times m}$，行列和非零时设 $B=D_{row}^{-1/2}ZD_{col}^{-1/2}$。计算 $B^TB$ 的主特征系统 $(V,\Lambda)$；保留正特征值上，点算子 $BB^T$ 的特征向量为 $U=BV\Lambda^{-1/2}$。聚类前逐行归一化 $U$。这里明确的是归一化二部图算子，而不是把未归一化 $ZV$ 叫作精确 Nyström 扩展。

## 可实现结构
- **周期性离线聚类**：每 N_step 步收集 token 表示 → 离线谱聚类 → 更新路由表
- **Nyström 采样**：随机采样 m=1024 个代表点，将 N×N 问题降为 m×m
- **幂迭代实现**：5~10 步幂迭代 + Gram-Schmidt 正交化，GPU 友好
- **渐进式训练**：初期用 k-means 粗路由 → 中期谱聚类精化 → 后期可微调路由网络

## GPU 可行性

- **D1/D2[~]**：相似度构造与归一化是张量操作；特征求解器含全局归约及正交化。
- **D3[~]**：稠密相似度 $O(N^2d)$；块迭代 $O(TN^2K)$ 加正交化。锚点 Gram 构造 $O(Nm^2)$、完整 EVD $O(m^3)$、扩展 $O(NmK)$，另计 $O(Nmd)$ 相似度。
- **D4[~]**：fp32 稠密 $N^2$ 阵需 $4N^2$ 字节（$N=4096$ 时64 MiB）。不流式处理时锚点存储为 $O(Nm+m^2)$。
- **D5[~]**：用 fp32/fp64 求特征子空间，报告谱间隙及残差，避免跨重根对任意基微分。
- **D6/D7[~]**：k-NN 稀疏可有帮助，但图构造及近邻召回率另计；固定迭代数不证明收敛。
- **D8[~]**：逐元素相似度缩放可融合；特征求解及全局 k-means 阶段仍有依赖。

## 论文表述方式
"利用谱聚类的连续松弛实现路由：构造 token 相似度图的归一化拉普拉斯，
通过 Nyström / 锚点近似和幂迭代避免完整 O(N³) 特征分解，并将主要计算转化为 GEMM、matvec 与 k-means。Normalized Cut 可作为聚类质量指标，但近似比依赖图模型、采样策略和求解器假设，不能无条件宣称。"

## 风险

- 核带宽、断连分量及零度节点可能改变推断簇数。
- 特征向量导数在重根附近不稳定；若子空间边界间隙仍存在，不变子空间量可保持良好定义。
- 重新聚类可置换专家标签；更新已训练路由前先对齐标签/基。
- 报告小图精确解与近似路由分歧、扩展误差、延迟及下游质量。
