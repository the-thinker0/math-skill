# Equivariant Split（等变分割）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当输入具有对称性（如排列、旋转、平移），且表示应保持或反映这些对称性时使用。
典型场景：(1) Token 排列等变——句子中 token 顺序变化，表示应相应变化（位置编码）；
(2) 特征维度的对称性分组——某些特征维度在特定变换下不变，某些等变；
(3) 多专家对称分工——不同专家处理不同对称性子空间；
(4) 几何深度学习——3D 分子/蛋白质结构中 SE(3) 等变性。
核心诉求：**让网络结构编码对称性先验，减少学习负担，提升泛化**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（群作用、不变/等变映射）、../../lenses/probabilistic.md（对称性与信息冗余）
- 知识：../../knowledge-base/matrix-analysis/projection.md（群表示论、不可约表示）、
  ../../knowledge-base/differential-geometry/manifold.md（李群、齐性空间）

## 需要的数学知识
- **群作用与等变性**：映射 f 对群 G 等变 ⟺ f(g·x) = g·f(x), ∀g∈G
  不变性是等变性的特例（g·f(x) = f(x)，即平凡表示）
- **Schur 引理与不可约表示分解**：
  任何有限群表示可分解为不可约表示的直和：V = ⊕_i m_i · V_i
  等变线性映射在不可约分量间是对角/块对角的
- **Peter-Weyl 定理**：紧群上的函数可分解为不可约表示矩阵元的级数
  f(x) = Σ_ρ Σ_{ij} c_{ρ,ij} · ρ_{ij}(g)（广义 Fourier 展开）
- **Steerable 特征空间**：特征按群的不可约表示组织，
  变换 g 作用时各分量按对应的表示矩阵变换：f_i → Σ_j ρ_{ij}(g) f_j

## AI 模块形式
```
模块：EquivariantSplit
输入：X ∈ R^{N×d}，对称群 G（如 S_n 排列群、Z_n 循环群、SO(3) 旋转群）

方法1 - 按不可约表示分割特征维度：
  // 将 d 维特征按群的不可约表示分解
  irreps = decompose(G, d)  // [(d₁, ρ₁), (d₂, ρ₂), ...] 其中 Σdᵢ = d
  X_split = split(X, [d₁, d₂, ...], dim=-1)  // 按不可约分量切分
  // 每个分量用等变层独立处理：
  for (X_i, ρ_i) in zip(X_split, irreps):
    Y_i = EquivariantLinear(X_i, ρ_i)  // 权重受 Schur 约束
  Y = concat(Y_i, dim=-1)              // 重组

方法2 - 位置等变分割（Token 排列群 S_n）：
  // Transformer 自注意力天然对排列等变（无位置编码时）
  // 显式引入可控的排列等变性：
  X_content = X[:, :d_content]           // 排列不变的内容部分
  X_position = X[:, d_content:]          // 位置相关的部分
  // 内容部分用排列不变的池化：
  z_inv = mean(X_content, dim=1)         // 全局不变特征
  // 位置部分用等变操作：
  z_equiv = Attention(X_position, X_position, X_position)  // 排列等变
  output = z_equiv + MLP(z_inv).unsqueeze(1)  // 不变信号广播回去

方法3 - 群卷积/群池化：
  // 特征定义在群 G 上：f: G → R^c
  // 群卷积：(f * ψ)(g) = Σ_{h∈G} f(h) · ψ(h⁻¹g)
  // 群池化：pool over orbits of subgroup H < G
  // 实现为矩阵乘法（群乘法表→稀疏置换矩阵）
  for g in generators(G):
    X_g = permutation_matrix(g) @ X    // 群生成元作用
    features_g = Linear(X_g)            // 共享权重的等变处理
  output = aggregate(features_g)        // 沿群维度聚合
```

## 可实现结构
- **e3nn / lie_learn 集成**：使用现有库处理 SO(3)/SE(3) 的不可约表示和球谐函数
- **特征分块存储**：按不可约表示组织特征维度，每个块独立归一化和处理
- **群操作预计算**：群乘法表、Clebsch-Gordan 系数等一次性计算并缓存
- **对称性增强**：训练时对输入施加随机群元素 g∈G（数据增强），鼓励等变性

## GPU 可行性
- **张量化**：不可约分量的处理为 batched GEMM；群卷积为稀疏 GEMM 或 batched matmul
- **GEMM 可映射**：EquivariantLinear 的每个块为独立 GEMM (N×dᵢ)@(dᵢ×dᵢ_out)，可 batch
- **复杂度**：与标准网络同阶（Schur 约束反而减少参数），群卷积额外 |G| 倍
- **显存与 KV-Cache**：群卷积需存储 |G| 份特征，|G| 大时显存压力显著
- **低精度稳定**：球谐函数 Y_l^m 的计算涉及阶乘和平方根，建议 fp32
- **并行与通信**：不可约分量间独立，完美并行；群卷积的不同 g 可并行
- **稀疏结构**：群卷积的置换矩阵极度稀疏（每行/列恰好一个非零），SpMM 高效
- **算子融合**：split → batched matmul → concat 可融合；群池化的 scatter+reduce 可融合

## 论文表述方式
"利用群表示论的 Schur 引理，将 d 维特征空间按对称群 G 的不可约表示分解为直和 ⊕mᵢVᵢ，
每个分量使用受等变约束的线性层独立处理，从而在满足群作用假设时严格保持等变性并减少可学习自由度。参数节省量取决于具体表示分解与通道重数；泛化收益需在具有相应对称性的任务上实测，不能无条件写成 O(1/√|G|)。"

## 风险
- 群的选择不当（过大约束导致欠拟合，过小无法捕获对称性）
- 不可约表示分解需要领域知识，非标准群的实现复杂
- 群卷积的 |G| 倍特征存储在群阶大时不可行（如 S_10 有 3.6M 个元素）
- 近似等变（soft equivariance）vs 严格等变的权衡难以控制
