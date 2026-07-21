# Orthogonality Loss（正交性损失）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
多专家/多任务场景中，各子模块学习到的表示高度重叠、冗余，导致参数利用率低下。
当需要将 d 维特征空间分割为 K 个互不干扰的子空间时使用——如 Shared-Private 分离、
MoE 专家差异化、多任务 head 去相关。核心诉求：**让不同模块看到不同的东西**。

## 数学思想来源
- 透镜：../../lenses/projection.md（正交投影与子空间分解）、../../lenses/variational.md（正则化与鞍点）
- 知识：../../knowledge-base/matrix-analysis/projection.md（谱定理、SVD、Schur 分解）、
  ../../knowledge-base/probability/kl-divergence.md（冗余度与互信息）

## 需要的数学知识
- **Frobenius 内积与正交性**：⟨A, B⟩_F = tr(A^T B)，当 ⟨A, B⟩_F = 0 时 A⊥B
- **Stiefel 流形约束**：W ∈ St(d, k) 即 W^T W = I_k，投影到正交矩阵集合
- **DPP 行列式点过程**：det(W^T W) 越大表示列向量越分散，可作为多样性代理
- **cosine 相似度矩阵去对角外元素**：C_ij = |⟨w_i, w_j⟩| / (‖w_i‖‖w_j‖)，最小化 Σ_{i≠j} C_ij²

## AI 模块形式
```
模块：OrthogonalDiversityLoss
输入：K 个特征矩阵 {W_k ∈ R^{d×r}}_{k=1}^K（K 个子模块的权重或特征）
  // 注意：Grassmann 距离需先对 W_i 做 QR 分解取正交基 Q_i

方法1 - Frobenius 正交正则：
  L_orth = Σ_{i<j} ‖W_i^T W_j‖_F²
  // 计算量：O(K² · d · r²)，K 一般 <16 所以可控

方法2 - 子空间重叠对数障碍（基于主角度）：
  σ_k = SVD(Q_i^T Q_j) 的奇异值（= cos(θ_k)，θ_k 为主角度）
  // ⚠ 必须先将 W_i, W_j 正交归一化：Q_i = qr(W_i).Q, Q_j = qr(W_j).Q
  // 否则奇异值可能 > 1，导致 -log(1-σ²+ε) 未定义
  // ⚠ 原公式 σ²(1-σ²) 错误：σ=0（正交）和 σ=1（完全重叠）时惩罚均为 0！
  // 完全重叠的子空间获得零惩罚，违背正交性目标。
  // 正确公式：对数障碍，σ=0 时为 0，σ→1 时 → +∞
  L_grass = Σ_{i<j} Σ_k -log(1 - σ_k² + ε)  // = -Σ log(sin²θ_k)，正交时 θ=π/2 → 0，重叠时 θ→0 → ∞

方法3 - 高效归一化 Gram 去相关：
  W_norm = column_normalize(concat([W_1,...,W_K]))       // 若不归一化，会同时惩罚范数而非只惩罚角度
  G = W_norm^T · W_norm                                  // 一次 GEMM
  L_corr = ‖G ⊙ (1 - I)‖_F²   // mask 掉对角线，惩罚非对角元素
```

## 可实现结构
- **嵌入为 nn.Module**：forward 接收 K 个 tensor，返回标量 loss，可直接 .backward()
- **与主 loss 加权组合**：L_total = L_task + λ · L_orth，λ 可用 cosine annealing 或 warm-up
- **分块计算**：当 K 很大时，对 (i,j) 对做 mini-batch 采样，每步只算 C(K,2) 中的 B 对

## GPU 可行性
- **D1[~]**：核心操作可写成 GEMM；但 $Kr$ 很小时可能受 kernel launch 和低占用率限制，不能默认吃满 Tensor Core
- **D2[v]**：方法3 只需 1 次 GEMM + 1 次 element-wise mask + Frobenius 范数
- **D3[~]**：方法3 的 GEMM 复杂度为 $O(d(Kr)^2)$，除输入 $O(dKr)$ 外还需 $O((Kr)^2)$ Gram 矩阵；只有 $Kr$ 相对较小时才可忽略
- **D4[~]**：无需物化 $d\times d$ 投影，但会物化 $(Kr)\times(Kr)$ Gram；与 KV-Cache 无直接关系
- **D5[~]**：平方和可能在 fp16 溢出或累积误差，建议 fp32 accumulation；QR/SVD 至少用 fp32，并对接近重根的梯度做稳定性测试
- **D6[~]**：$\binom K2$ 个 pair 可并行；只有跨设备拆分该辅助损失时才需要归约，通常留在单卡更合算
- **D7[N/A]**：该损失通常处理稠密小矩阵；mask 对角线不会产生值得利用的结构化稀疏，也不能由 $W_k$ 稀疏推出 Gram 稀疏
- **D8[~]**：mask、平方和归约可做融合 epilogue 或单独 fused reduction，但不能默认与供应商 GEMM 合成一个 kernel；需以 profiler 验证 launch 与读写收益

## 论文表述方式
"我们引入正交性正则项 L_orth = Σ_{i<j}‖Q_i^T Q_j‖_F²（其中 Q_i 为 W_i 的正交基），惩罚不同子模块特征子空间的重叠。该项可降低线性相关冗余，但冗余衰减速率需要随机子空间或数据分布假设支撑，应通过主角度、互信息估计或下游消融实测报告。"

## 风险
- λ 过大导致优化困难（正交约束与任务目标冲突），需 careful tuning 或 adaptive λ
- 方法2 的 SVD 在反向传播时梯度不稳定，需添加 ε-正则化到奇异值
- 当 K·r > d 时正交性不可能严格满足，需降维或接受近似正交
