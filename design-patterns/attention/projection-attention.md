# 投影注意力 / Projection Attention

## 适用问题
当输入的 token/key 空间维度过高，标准注意力的 $Q K^T$ 内积在高维空间中趋于均匀（"注意力坍缩"）时，需要先将 key/query 投影到一个**几何结构更优的子空间**再做注意力计算。典型场景：长上下文 LLM 的 KV-Cache 压缩、高维嵌入空间的注意力稀疏化、多模态融合中异构特征的注意力对齐。

## 数学思想来源
- 透镜：[transformation（变换思想）, abstraction（抽象化思想）]
- 知识：[`probability/concentration-inequality.md`（高维浓度不等式 → 注意力坍缩的理论解释）, `probability/entropy.md`（注意力分布的熵作为质量指标）]

## 需要的数学知识
- **Johnson-Lindenstrauss 引理**：高维点集可投影到 $O(\log n / \epsilon^2)$ 维子空间而近似保持距离
- **随机投影与子空间嵌入**：稀疏投影矩阵（如 CountSketch、SRHT）近似保持内积
- **SVD / PCA 截断**：最优低秩子空间投影，最大化保留方差

## AI 模块形式

**核心思路**：将 $Q, K \in \mathbb{R}^{n \times d}$ 先投影到 $r$ 维子空间（$r \ll d$），再计算注意力：

$$\text{ProjAttn}(Q, K, V) = \text{softmax}\left(\frac{Q P_Q (K P_K)^T}{\sqrt{r}}\right) V$$

其中 $P_Q, P_K \in \mathbb{R}^{d \times r}$ 为投影矩阵。

**三种投影策略**：

1. **可学习投影**（$P$ 为训练参数）：
```
P_Q = Linear(d, r, bias=False)  # r << d
P_K = Linear(d, r, bias=False)
scores = (Q @ P_Q) @ (K @ P_K).T / sqrt(r)
attn = softmax(scores) @ V
```

2. **随机固定投影**（JL 引理保证）：
```
P = random_gaussian(d, r) / sqrt(r)  # 固定不训练
scores = (Q @ P) @ (K @ P).T / sqrt(r)
```

3. **数据自适应投影**（在线 PCA）：
```
# 维护 K 的 running covariance，取 top-r 特征向量
C = running_mean(K^T @ K)  # d x d
eigenvecs = top_r_eigenvectors(C)  # d x r
scores = (Q @ eigenvecs) @ (K @ eigenvecs).T / sqrt(r)
```

## 可实现结构
- **Multi-Head 投影**：每个 head 使用不同的 $P_h \in \mathbb{R}^{d_h \times r}$，总计算量 $O(n \cdot d \cdot r + n^2 \cdot r)$，当 $r \ll d$ 时节省 $Q K^T$ 的 $O(n^2 d)$ 开销
- **KV-Cache 压缩**：投影后的 $K' = K P_K \in \mathbb{R}^{n \times r}$ 替代原始 $K$ 存储，显存节省 $d/r$ 倍
- **分层投影**：浅层用小 $r$（粗筛），深层用大 $r$（精排）

## GPU 可行性
- **维度 1 张量化 ✅**：投影 = 矩阵乘，注意力 = 矩阵乘链，全程张量运算
- **维度 2 GEMM 可映射 ✅**：$Q P_Q$ 和 $K P_K$ 均为标准 GEMM，吃满 Tensor Core
- **维度 3 复杂度 ✅**：投影 $O(ndr)$ 远低于注意力 $O(n^2 d)$，且投影后 $r \ll d$ 使注意力 $O(n^2 r)$
- **维度 4 显存 ✅**：KV-Cache 压缩 $d/r$ 倍，直接降低显存峰值
- **维度 5 低精度 ✅**：投影矩阵正交/近正交时数值稳定，bf16 可接受
- **维度 6 并行 ✅**：投影可与注意力流水线并行，Multi-Head 天然跨头并行
- **维度 7 稀疏 ⚠️**：投影矩阵本身稠密；若用稀疏投影（CountSketch），可能引入 gather/scatter
- **维度 8 算子融合 ✅**：投影可融入 FlashAttention 的 online softmax 循环中

## 论文表述方式
"我们将注意力计算分解为低维子空间投影与投影空间注意力两步，在保持注意力质量的同时将 KV-Cache 压缩 $d/r$ 倍，并保证 Johnson-Lindenstrauss 距离保持性。"

## 风险
- **投影方向退化**：可学习投影可能坍缩到少数方向（$P^T P$ 条件数恶化），导致注意力分布退化。需加正交正则化 $\|P^T P - I\|_F^2$。
- **信息丢失不可逆**：投影丢弃了 $(d-r)$ 维信息，若任务恰需这些维度的特征则性能下降。建议配合残差连接（原始注意力 + 投影注意力的加权组合）。
