# Manifold Representation（流形表示）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当输入数据虽然在高维空间中，但实际分布在低维流形上时使用。典型场景：
(1) 自然语言 token 的语义空间——虽维度 d=4096，但有效自由度远小于 d；
(2) 多模态对齐——文本和图像分布在不同的流形上，需要对齐；
(3) 专家特征空间——每个专家处理流形的不同局部区域；
(4) 降维/压缩——利用流形低维本质减少参数量。
核心诉求：**利用数据的低维流形结构，提高表示效率和泛化能力**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（黎曼几何、测地线、曲率）、../../lenses/probabilistic.md（内在维度）
- 知识：../../knowledge-base/differential-geometry/manifold.md（流形、切空间、指数映射）、
  ../../knowledge-base/matrix-analysis/projection.md（SVD、低秩近似、PCA）

## 需要的数学知识
- **流形假设**：数据 x ∈ R^D 实际分布在 d << D 维的光滑流形 M 上
  局部可用切空间 T_pM ≈ R^d 线性近似
- **局部坐标卡 (Chart)**：φ: U ⊂ M → R^d，将流形局部映射到低维欧氏空间
  多个坐标卡 {φ_i} 构成图册（Atlas），覆盖整个流形
- **测地线距离**：d_M(p,q) = inf ∫‖γ'(t)‖dt，流形上两点间最短路径
  近似计算：k-NN 图上 Dijkstra/Isomap
- **指数映射/对数映射**：
  exp_p: T_pM → M（切空间到流形），log_p: M → T_pM（流形到切空间）
  用于在切空间中做线性运算后映射回流形

## AI 模块形式

```python
# chart混合：局部仿射近似，不自动构成几何图册
z = zeros(N, d)
for k in range(K):
    z += gate(X)[:, k:k+1] * (X @ W[k].T + bias[k])
# 若各chart坐标不同，混合前先对齐/坐标过渡。

# Euclidean度量Stiefel更新：W形状D x r，W.T @ W = I
G = euclidean_gradient(loss, W)
M = W.T @ G
grad_R = G - W @ ((M + M.T) / 2)
W_next = qr(W - learning_rate * grad_R, mode='reduced').Q
```
`G - W @ (W.T @ G)` 是水平 Grassmann 投影，不是一般 Stiefel 梯度；它丢失框架内部旋转。

测地应力 `mean((D_graph-D_latent)**2)` 是无权 metric stress，不是 Sammon 加权应力。应在连通采样图上估图距离并明确度量；弯曲流形未必能在内在维数的 Euclidean 坐标中全局保距。稀疏 Laplacian 正则 $\operatorname{tr}(Z^TLZ)$ 是边平滑惩罚，单独使用允许坍塌到常数表示。

## 可实现结构
- **Chart MoE**：K 个局部线性投影 + softmax 门控 → 天然与 MoE 框架集成
- **流形正则化**：L_manifold = tr(Z^T L Z) / N²，L 为图拉普拉斯，Z 为表示
  鼓励相邻样本的表示相近
- **内在维度估计**：用 MLE 或 two-norm 方法估计数据的有效维度 d*
- **自适应 d**：不同区域的局部维度不同，用 PCA 局部估计

## GPU 可行性

- **D1/D2[~]**：局部投影用 GEMM；稀疏 Laplacian 损失用 SpMM/边差分。
- **D3[~]**：暴力精确 k-NN 为 $O(N^2D)$；近似索引的构建、查询及召回权衡依赖方法/数据。稀疏 Laplacian 损失为 $O(|E|d)$，并非必然 $O(N^2)$。全对测地距离另有潜在大成本。
- **D4[~]**：chart 权重存 $O(KdD)$ 个数；稀疏边需端点与权重，$O(Nk_{nn})$。不存在通用10 MB上限。
- **D5[~]**：距离与 QR 用 fp32；监控正交性、邻域召回及断连分量。
- **D6/D8[~]**：chart 投影可批处理；路由及索引构造另有开销。对完整编码/路由/正则工作 profiling。
- **D7[~]**：稀疏图正则保持所选边集，不保证未知流形拓扑。

## 论文表述方式
"基于流形假设将 D 维 token 表示建模为低内在维度结构，
通过 K 个局部坐标卡（Chart MoE）实现分段近似，并用图拉普拉斯正则鼓励局部邻域一致性。嵌入误差或测地线保持只在采样密度、流形光滑性、图构造和估计器假设满足时才有理论界，实际应报告邻域保持、重构误差和下游指标。"

## 风险

- 流形假设及内在维数需要证据；局部 PCA 可能混淆噪声与曲率。
- chart 混合需要重叠及坐标一致性；平滑 gate 本身不构成有效过渡映射。
- 邻域错误或断连图扭曲图测地距离。
- 平滑项应配合任务/重建或方差约束，防止坍塌。
