# 等变注意力 / Equivariant Attention
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当输入具有**明确的对称群 $G$ 作用**（旋转、平移、置换、反射等），且期望模型输出在相同变换下**协变**（equivariant）而非不变时，需要将等变约束直接编入注意力机制。典型场景：3D 点云/分子（$E(3)$ 刚体群）、图像分类（$D_n$ 旋转/镜像群）、集合数据（$S_n$ 置换群）、多视角/多传感器融合。

## 数学思想来源
- 透镜：[symmetry（对称透镜）, categorical（范畴化透镜 — 群作用的统一框架）]
- 知识：[`../../knowledge-base/probability/concentration-inequality.md`（等变约束下的样本效率提升 — 轨道上的数据等价性）, `../../knowledge-base/probability/entropy.md`（等变约束降低输出分布熵 → 更强的归纳偏置）]

## 需要的数学知识
- **群表示论基础**：群 $G$ 的线性表示 $\rho: G \to GL(V)$，不可约表示分解
- **等变映射定义**：$f(g \cdot x) = \rho_{\text{out}}(g) \cdot f(x)$，对所有 $g \in G$
- **轨道-稳定子定理**（参见 `references/books/abstract-algebra.md` Ch.5）：$|orbit| = |G|/|stab|$，参数共享倍率
- **Schur 引理**：不可约表示间的等变线性映射要么为零要么为标量乘

## AI 模块形式

**核心思路**：将标准注意力的 $Q, K, V$ 替换为**等变特征**（steerable features），确保注意力权重在群作用下不变，输出在群作用下等变。

**方案 A：置换等变注意力（$S_n$ 群，集合数据）**：
```python
# DeepSets / Set Transformer 风格
# 注意力权重对置换不变：π(Q)π(K)^T = QK^T（置换抵消）
# 输出对置换等变：π(softmax(QK^T) V) = softmax(QK^T) π(V)
Q, K, V = W_q(X), W_k(X), W_v(X)  # 逐点线性变换
scores = Q @ K.T / sqrt(d)         # 置换不变
attn = softmax(scores)             # 置换不变
output = attn @ V                  # 置换等变（V 是等变的）
```

**方案 B：$E(3)$ 等变注意力（3D 点云/分子）**：
```python
# 将特征分解为标量 + 向量 + 高阶张量（球谐基）
# 注意力权重只用标量特征计算（旋转不变）
scalar_Q = scalar_proj(X_scalar)   # 仅标量 → 旋转不变
scalar_K = scalar_proj(X_scalar)
scores = scalar_Q @ scalar_K.T / sqrt(d_s)  # 旋转不变的注意力权重

# V 包含等变特征（标量 + 向量），用不变的权重加权
output_scalar = softmax(scores) @ V_scalar   # 标量 → 不变
output_vector = softmax(scores) @ V_vector   # 向量 → 等变（旋转协变）
```

**方案 C：$D_n$ 等变注意力（图像旋转/镜像）**：
```python
# G-CNN 风格：对每个群元素 g ∈ D_n，用 ρ(g) 变换输入后计算注意力
# 权重沿轨道共享（同一组 W_q/W_k/W_v），聚合所有群元素输出
output = mean(softmax((rho(g)@X@W_q) @ (rho(g)@X@W_k).T/sqrt(d)) @ (rho(g)@X@W_v) for g in D_n)
```

## 可实现结构
- **SE(3)-Transformer / Equiformer**：球谐特征 + 等变注意力，用于分子性质预测和蛋白质结构
- **Set Transformer**：$S_n$ 置换等变注意力 + Induced Set Attention（低秩诱导点降复杂度）
- **G-CNN 注意力**：$D_n$ 旋转/镜像等变，用于遥感图像和医学影像

## GPU 可行性
- **D1[v]**：群作用实现为 $\rho(g)$ 矩阵乘，等变特征为 batched 张量
- **D2[v]**：$\rho(g) X$ 和 $Q K^T$ 均为 GEMM；$|G|$ 个群元素 → batched GEMM
- **D3[~]**：$|G|$ 倍计算量，小群（$|D_4|=8$）可接受，大群（$|S_n|=n!$）不可。改造：用生成元 + Cayley 图传播替代整群枚举
- **D4[~]**：需存储 $|G|$ 份中间特征，可分块 + gradient checkpointing
- **D5[v]**：正交表示矩阵在 bf16 下数值稳定
- **D6[v]**：$|G|$ 个群元素天然并行（batch 维）
- **D7[~]**：置换 $\rho(g)$ 极度稀疏，可编码为 gather 索引
- **D8[v]**：群作用 + 线性变换可融合为单次 batched GEMM

## 论文表述方式
"我们提出等变注意力机制，通过将注意力权重约束为群不变量、注意力输出约束为群等变量，在不增加数据增强的情况下将对称群 $G$ 的归纳偏置直接编码进模型结构，参数效率提升 $|G|/|stab|$ 倍。"

## 风险
- **群选择错误的代价**：若数据不具有假定的对称性（如分子不具有完全 $E(3)$ 对称性），等变约束会伤害表达能力。需先验证对称性假设，或使用"近似等变"（soft equivariance）。
- **高阶表示的显存爆炸**：$SO(3)$ 的 $L$ 阶球谐表示维度为 $(2L+1)^2$，高阶特征 ($L \geq 3$) 的存储和计算量急剧增长。实践中通常截断到 $L \leq 2$。