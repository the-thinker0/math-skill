# Low-Rank KV-Cache（低秩 KV 缓存压缩）

> 严谨性约定：[v] 表示可核查的公式或成本计数；[~] 表示需要实验的压缩/实现方案。本原型没有已测 GPU 吞吐结论。

## 适用问题
当推理 KV-Cache 存储成为瓶颈，且 K/V 在实际 query 分布下具有可利用冗余时，探索因子存储。低秩保持的是指定矩阵的近似，不能直接承诺长程检索或生成质量。

## 数学思想来源
- 透镜：`../../lenses/spectral.md`、`../../lenses/variational.md`、`../../lenses/duality.md`。
- 知识：`../../knowledge-base/matrix-analysis/low-rank-approximation.md`、`../../knowledge-base/matrix-analysis/projection.md`、`../../knowledge-base/matrix-analysis/matrix-perturbation.md`。

## 需要的数学知识
- **Eckart-Young-Mirsky [v]**：精确截断 SVD 的最优误差为 ‖A−A_k‖₂=σ_(k+1)、‖A−A_k‖_F²=Σ_(i>k)σ_i²。随机化 SVD 还包含随机子空间误差，不能把它的实际误差直接等同上述最优值。
- **随机化 SVD [v]**：草图宽度 ℓ=k+p≤min(L,d) 的稠密基础算法约 O(Ldℓ+(L+d)ℓ²)，包含 QR 与小 SVD；power iteration 另加数据遍历。
- **Stable rank [v]**：‖K‖_F²/‖K‖₂² 是稳定秩，K=0 时可约定为 0；不是熵定义的 effective rank，也不单独决定给定误差容忍度所需的 k。秩选择还应检查尾谱与 query 加权误差。

**明确的单 Query 输出误差界 [v]**：设 q 固定，K、K̂ 与 V、V̂ 有相同 token 行数，使用相同可见性 mask（至少一项可见）及温度 τ>0。对 o=softmax(qKᵀ/τ)V 与 ô=softmax(qK̂ᵀ/τ)V̂，有

$$\|o-\hat o\|_2\le\frac{\|q\|_2\|K-\hat K\|_2\|V\|_2}{2\tau}+\|V-\hat V\|_2.$$

理由：softmax Jacobian 的 2-算子范数至多 1/2，概率向量 2-范数至多 1，再将差写成 (a−â)V+â(V−V̂)。标准 attention 取 τ=√d。第二项不随 q 消失；即使 q=0，V 近似仍会改变均值输出。该界不涵盖后续层放大或额外舍入误差。

## AI 模块形式
设 K∈R^(L×d)、V∈R^(L×d_v)。分别保存 K̂=U_K B_K、V̂=U_V B_V，允许两个秩不同。下面是 fp32 的稠密参考实现，使用**因子化 GEMM**，不是融合 kernel：

```python
import math
import torch

def low_rank_factors(A, rank, oversample=8):
    A = A.float()
    rows, cols = A.shape
    assert 1 <= rank <= min(rows, cols) and oversample >= 0
    ell = min(rank + oversample, rows, cols)
    omega = torch.randn(cols, ell, device=A.device, dtype=A.dtype)
    Q_base = torch.linalg.qr(A @ omega, mode="reduced").Q
    U_small, S, Vh = torch.linalg.svd(Q_base.T @ A, full_matrices=False)
    Q_final = Q_base @ U_small[:, :rank]
    A_comp = S[:rank, None] * Vh[:rank, :]  # Row scaling, shape (rank, cols).
    return Q_final, A_comp

def factorized_attention(Q, U_K, B_K, U_V, B_V, allowed=None):
    Q, U_K, B_K, U_V, B_V = [x.float() for x in (Q, U_K, B_K, U_V, B_V)]
    logits = ((Q @ B_K.T) @ U_K.T) / math.sqrt(Q.shape[-1])
    if allowed is not None:
        assert bool(allowed.any(dim=-1).all())
        logits = logits.masked_fill(~allowed, -torch.inf)
    weights = torch.softmax(logits, dim=-1)  # Normalize over all L positions.
    return (weights @ U_V) @ B_V
# U_K, B_K = low_rank_factors(K, rank_k)
# U_V, B_V = low_rank_factors(V, rank_v)
# output = factorized_attention(Q, U_K, B_K, U_V, B_V, allowed)
```

**关键区分 [v]**：Q_final 等左因子仍含 L 行，softmax 仍在 L 个位置归一化。因子化 GEMM 无须重构完整 K/V，但 k 个因子不是 k 个 token。若令 U_V=U_K，必须另算 B_V=U_KᵀV 并测 Value 投影误差；独立 V-SVD 的 B_V 不能错误地配给 U_K。

**线性注意力 [v/条件]**：对指定有限维特征映射 φ(x)∈R^s，可累积 S=Σφ(k_i)v_iᵀ 与 z=Σφ(k_i)，输出 φ(q)ᵀS/(φ(q)ᵀz)，要求分母非零。状态大小 O(sd_v+s)，特征维 s 不等于 K 的 SVD 秩 k。对 K_comp 直接施加非线性 φ 一般不保原统计量；这不是标准 softmax 的无条件等价替代。

## 可实现结构
- **周期压缩 [~]**：压缩频率 M 由摊销成本和质量决定，没有统一的 M=64。该离线基线需要原始 A 和工作区，峰值显存可能高于最终因子存储。
- **流式固定基底 [v]**：若 R∈R^(k×d)、RRᵀ=I，行向量新 Key 的系数为 c=k_new Rᵀ，残差为 k_new−cR，成本 O(kd)。**[~]** 改变基底后须同步旋转/重算历史系数；增量 SVD 并非总共只有 O(kd)。
- **双缓冲 [~]**：压缩旧 token，保留近期原始 token；统一温度、原始位置与 mask，并对两区 logits 做一次共同 softmax。
- **跨头共享/量化 [~]**：须测不同头的子空间兼容性与量化误差；低秩不意味着因子中存在可利用的零元素稀疏性。

## GPU 可行性
- **D1/D2 [v]**：草图和因子应用包含 GEMM，QR/SVD 仍有独立代价。**[~]** 不据此宣称 Tensor Core 满载或分解可整体融合。
- **D3 [v]**：对 m 个 query，因子化 QK 成本 O(mdk_K+mLk_K)，AV 为 O(mLk_V+mk_Vd_v)，另计长度 L 的 softmax、压缩和更新。k 必须小于相关维度，不能对 d=128 固定取 k=256。
- **D4 [v]**：只压 K 时元素数为 Lk+kd，压缩比 Ld/[k(L+d)]，仅当 k<Ld/(L+d) 才省元素；近似 d/k 还需 L≫d。独立压 V 时另加 Lk_V+k_Vd_v。
- **D5 [~]**：用 fp32 QR/SVD 作基准，量化/低精度需检查正交误差、尾谱、logit 和输出误差；不存在统一的“σ_k 误差放大 κ 倍”结论。
- **D6/D8 [~]**：头间独立任务可并行，单次分解和基底更新仍有依赖；因子注意力可探索分块融合，但以实际 kernel 与端到端基准确认。

**字节与 FLOPs 核算 [v]**：L=2048、d=128、k=64，所有持久因子每元素 2 bytes：单个 K 为 512 KiB，因子为 272 KiB，比例约 1.882×。若 V 同样独立压缩，总 KV 从 1024 降为 544 KiB；若仅压 K 则为 784 KiB。上述不含工作区/元数据。只计算 KΩ 且 ℓ=64，一次 GEMM 就约 2Ldℓ=33.6M FLOPs；这不是完整 SVD 的 FLOPs。

## 论文表述方式
“我们以随机低秩因子存储 KV，并报告实际重构、logit 与输出误差。Eckart-Young 谱范数误差作为精确截断 SVD 的参照；随机近似单独测误差。标准 softmax 仍归一化全部历史位置；我们比较包含分解、更新、工作区的端到端显存和延迟。”

## 风险
保留能量高的方向不一定保留未来 Query 需要的方向。增量截断误差不能仅靠旋转现有因子恢复已丢弃信息。RoPE 后的 Key 可直接按其实际形式压缩；若改在 RoPE 前压缩，则必须证明投影与逐位置旋转的兼容性，不能把每位置旋转随意挪到共享系数之后。自回归训练的压缩器不得读取当前 Query 不可见的未来数据。

## 来源
[Halko、Martinsson 与 Tropp](https://arxiv.org/abs/0909.4061)分析随机低秩近似；[Performers](https://research.google/pubs/rethinking-attention-with-performers/)讨论核特征注意力。上述输出误差界由所列 Jacobian 与范数不等式直接推出，不把矩阵最优重构误差当任务保证。
