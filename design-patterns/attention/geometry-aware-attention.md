# 几何感知注意力 / Geometry-Aware Attention
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「✅ 已验证 / ⚠️ 可改造需验证 / ❌ 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当 token/key 之间存在**已知的几何关系**（空间距离、流形测地距、层级结构、时序间隔）时，标准注意力的位置无关内积无法利用这些结构信息。几何感知注意力将**几何先验直接注入注意力权重计算**，使模型天然尊重底空间的度量结构。典型场景：3D 场景理解、分子构象、时序预测、层级文本结构（段落-句子-词）、知识图谱。

## 数学思想来源
- 透镜：[symmetry（对称透镜 — 度量不变性）, duality（对偶透镜 — 坐标系无关表达）]
- 知识：[`information-geometry/fisher-metric.md`（分布空间的几何度量）, `probability/concentration-inequality.md`（几何约束下的浓度行为）]

## 需要的数学知识
- **度量空间与距离函数**：欧氏距离、测地距、树距离、Wasserstein 距离
- **RBF / 核方法**：$k(x, y) = \exp(-d(x,y)^2 / 2\sigma^2)$，距离→相似度的转换
- **位置编码的几何解释**：RoPE = 旋转群 $SO(2)$ 的作用（相对距离编码为旋转角度差）；ALiBi = 指数衰减的距离偏置

## AI 模块形式

**核心思路**：在注意力分数中显式引入几何距离项，使远距离 token 的注意力天然衰减：

$$\text{GeoAttn}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d}} + \text{GeoBias}(i, j)\right) V$$

**方案 A：距离偏置注意力（通用度量空间）**：
```python
# d_ij 为 token i 和 j 之间的几何距离（预计算或在线计算）
# 可学习距离偏置函数
distance_bias = MLP(d_ij)  # 或简单的 -α * d_ij
scores = (Q @ K.T) / sqrt(d) + distance_bias
attn = softmax(scores) @ V
```

**方案 B：相对位置编码（RoPE / ALiBi 的几何推广）**：
```python
# 推广 RoPE：位置 → 群元素 g_i，相对位置 → g_i g_j^{-1}
# 可学习任意度量空间上的相对位置偏置
def geo_attention(Q, K, V, positions):
    rel_pos = pairwise_difference(positions)       # (n, n, coord_dim)
    geo_bias = geo_encoder(rel_pos)               # (n, n) 可学习映射
    scores = (Q @ K.T) / sqrt(d) + geo_bias
    return softmax(scores) @ V
```

**方案 C：流形感知注意力（非欧空间）**：
```python
# token 位于非欧流形（双曲空间、球面）时，用测地距替代欧氏距
def manifold_attention(Q, K, V, manifold):
    geodist = manifold.geodesic_distance_matrix(positions)  # (n, n)
    geo_kernel = exp(-geodist^2 / (2 * sigma^2))  # RBF 核
    scores = (Q @ K.T) / sqrt(d) + log(geo_kernel + eps)
    return softmax(scores) @ V
```

## 可实现结构
- **RoPE 扩展**：从 $SO(2)$ 旋转到更高维旋转群 $SO(2k)$，编码多维位置信息（2D 图像 patch、3D voxel）
- **层级位置偏置**：树结构中用 LCA（最近公共祖先）深度作为距离，适合文档/代码的层级建模
- **分子构象注意力**：3D 原子坐标 → 距离矩阵 → 几何偏置，用于分子 GNN 和蛋白质结构预测

## GPU 可行性
- **维度 1 张量化 ✅**：距离矩阵和偏置矩阵均为稠密张量，逐元素运算
- **维度 2 GEMM 可映射 ✅**：主体 $Q K^T$ 为标准 GEMM；几何偏置为加法，不阻断 GEMM
- **维度 3 复杂度 ⚠️**：成对距离矩阵 $O(n^2)$ 构建和存储；但可用分块计算 + online softmax 避免物化完整矩阵
- **维度 4 显存 ⚠️**：$n \times n$ 距离矩阵占用显存；可分块/流式计算（与 FlashAttention 兼容）
- **维度 5 低精度 ✅**：距离计算和偏置加法在 bf16 下稳定；RBF 的 exp 需注意上溢（clamp 距离）
- **维度 6 并行 ✅**：距离计算和注意力可流水线并行，成对距离可分块并行
- **维度 7 稀疏 ✅**：远距离偏置趋于 $-\infty$（softmax 后趋零），天然诱导结构化稀疏（局部注意力窗口）
- **维度 8 算子融合 ✅**：几何偏置可融入 FlashAttention 的 online softmax 循环中（加在 $QK^T$ 之后、softmax 之前）

## 论文表述方式
"我们提出几何感知注意力，通过在注意力分数中显式注入可学习的几何距离偏置项，使模型天然尊重输入空间的度量结构，在不增加参数量的情况下将远距离 token 的注意力指数衰减，同时保持与 FlashAttention 的兼容性。"

## 风险
- **几何先验与数据冲突**：若几何距离与语义相关性不一致（如文本中远距离但语义相关的 token），强几何偏置会伤害模型表达。需让偏置可学习且可被内容注意力覆盖。
- **距离计算的非可微性**：某些距离（图最短路径、树 LCA 深度）不可微或计算复杂。需使用可微松弛（softmin 替代 min）或预计算距离矩阵。