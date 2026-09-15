# Orthogonality Loss（正交性损失）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

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

```python
# W_i形状d x r、满列秩；QR避免重叠惩罚靠缩小范数坍塌
Q = [qr(W_i, mode='reduced').Q for W_i in W]
L_overlap = sum(((Q[i].T @ Q[j])**2).sum() for i, j in pairs)

# 可选平滑重叠障碍
sigma = svdvals(Q_i.T @ Q_j).clamp(0, 1)
L_barrier = -log((1 - sigma**2 + eps) / (1 + eps)).sum()
```
无 epsilon 时，障碍在正交处为0、完全重叠时发散；有 epsilon 后重叠处有限，上述归一化表达式仍在正交处为0。Epsilon 不解决重根处奇异向量梯度未定义；Gram 重叠损失避免显式奇异向量。

原始 `||W_i.T @ W_j||_F**2` 可通过把任一矩阵缩到0而消失。需归一化/控制方差或使用正交基；若要求严格相互正交，确保 $Kr\le d$。仅 Frobenius 内积 $\operatorname{tr}(A^TB)=0$ **不**蕴含列空间正交。行列式多样性目标需范数约束，防止尺度无界增长。

归一化拼接 Gram 惩罚同时包含块内去相关与块间重叠；若只需专家间重叠，应屏蔽块内项。

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
