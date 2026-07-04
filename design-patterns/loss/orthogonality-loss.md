# Orthogonality Loss（正交性损失）

## 适用问题
多专家/多任务场景中，各子模块学习到的表示高度重叠、冗余，导致参数利用率低下。
当需要将 d 维特征空间分割为 K 个互不干扰的子空间时使用——如 Shared-Private 分离、
MoE 专家差异化、多任务 head 去相关。核心诉求：**让不同模块看到不同的东西**。

## 数学思想来源
- 透镜：lenses/geometric.md（正交投影与子空间分解）、lenses/variational.md（正则化与鞍点）
- 知识：knowledge-base/matrix-analysis/projection.md（谱定理、SVD、Schur 分解）、
  knowledge-base/probability/kl-divergence.md（冗余度与互信息）

## 需要的数学知识
- **Frobenius 内积与正交性**：⟨A, B⟩_F = tr(A^T B)，当 ⟨A, B⟩_F = 0 时 A⊥B
- **Stiefel 流形约束**：W ∈ St(d, k) 即 W^T W = I_k，投影到正交矩阵集合
- **DPP 行列式点过程**：det(W^T W) 越大表示列向量越分散，可作为多样性代理
- **cosine 相似度矩阵去对角外元素**：C_ij = |⟨w_i, w_j⟩| / (‖w_i‖‖w_j‖)，最小化 Σ_{i≠j} C_ij²

## AI 模块形式
```
模块：OrthogonalDiversityLoss
输入：K 个特征矩阵 {W_k ∈ R^{d×r}}_{k=1}^K（K 个子模块的权重或特征）

方法1 - Frobenius 正交正则：
  L_orth = Σ_{i<j} ‖W_i^T W_j‖_F²
  // 计算量：O(K² · d · r²)，K 一般 <16 所以可控

方法2 - Grassmann 距离（基于主角度）：
  σ_k = SVD(W_i^T W_j) 的奇异值
  L_grass = Σ_{i<j} Σ_k σ_k²(1 - σ_k²)  // 惩罚非 0 非 1 的奇异值

方法3 - 高效 cosine 去相关：
  G = concat([W_1,...,W_K])^T · concat([W_1,...,W_K])  // 一次 GEMM
  L_corr = ‖G ⊙ (1 - I)‖_F²   // mask 掉对角线，惩罚非对角元素
```

## 可实现结构
- **嵌入为 nn.Module**：forward 接收 K 个 tensor，返回标量 loss，可直接 .backward()
- **与主 loss 加权组合**：L_total = L_task + λ · L_orth，λ 可用 cosine annealing 或 warm-up
- **分块计算**：当 K 很大时，对 (i,j) 对做 mini-batch 采样，每步只算 C(K,2) 中的 B 对

## GPU 可行性
- **张量化**：核心操作为 matmul（W^T W）→ 标准 GEMM，完美映射 Tensor Core
- **GEMM 可映射**：方法3 只需 1 次 GEMM + 1 次 element-wise mask + Frobenius 范数
- **复杂度**：O(K·d·r) 存储 + O(d·r²·K) 或 O(K²·d·r²) 计算，K<16 时 negligible
- **显存与 KV-Cache**：中间矩阵 d×r·K 量级，不增加 KV-Cache 负担
- **低精度稳定**：Frobenius 范数为平方和，fp16 下 OK；Grassmann SVD 建议 fp32
- **并行与通信**：K 对之间 embarrassingly parallel，可分 GPU 计算后 all-reduce
- **稀疏结构**：若 W_k 本身稀疏（如 MoE gate），mask 后稀疏度进一步提升
- **算子融合**：matmul → mask → square → sum 可融合为单个 CUDA kernel

## 论文表述方式
"我们引入正交性正则项 L_orth = Σ_{i<j}‖W_i^T W_j‖_F²，将各子模块的特征空间约束
到近似正交的 Grassmann 子流形上，理论上保证 K 个子空间的冗余度以 O(1/√d) 衰减。"

## 风险
- λ 过大导致优化困难（正交约束与任务目标冲突），需 careful tuning 或 adaptive λ
- 方法2 的 SVD 在反向传播时梯度不稳定，需添加 ε-正则化到奇异值
- 当 K·r > d 时正交性不可能严格满足，需降维或接受近似正交
