# Contrastive Loss（对比损失）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当需要让模型学会"什么和什么相似、什么和什么不同"时使用。典型场景：
(1) 同一输入的不同增强视图应拉近（正对），不同输入应推远（负对）；
(2) Shared 表示应包含跨任务共性，Private 表示应区分任务特异性；
(3) 专家嵌入空间中相似输入应路由到同一专家。核心诉求：**学习相对关系而非绝对值**。

## 数学思想来源
- 透镜：lenses/geometric.md（度量空间与距离函数）、lenses/probabilistic.md（互信息最大化）
- 知识：knowledge-base/probability/entropy.md（条件分布与似然）、
  knowledge-base/differential-geometry/manifold.md（测地线与曲率）

## 需要的数学知识
- **InfoNCE 损失**：L = -log[exp(sim(q,k⁺)/τ) / Σ_j exp(sim(q,k_j)/τ)]
  本质是对比学习中的互信息下界估计，τ 为温度参数控制分布锐度
- **Margin-based 度量学习**：Triplet Loss = max(0, d(a,p) - d(a,n) + margin)
  在度量空间中显式拉开正负对距离差
- **NT-Xent (Normalized Temperature-scaled Cross Entropy)**：
  在单位球面 S^{d-1} 上的 softmax 对比，归一化消除尺度影响
- **去偏对比学习 (Debiased Contrastive)**：
  修正负样本中的假阴性问题，使用先验 τ⁺ 估计真实负样本分布

## AI 模块形式
```
模块：ContrastiveLoss
输入：锚点 z_a ∈ R^{B×d}，正样本 z_p ∈ R^{B×d}，负样本库 z_n ∈ R^{N×d}

核心公式 (InfoNCE + 温度缩放)：
  sim(q, k) = q^T k / (‖q‖ · ‖k‖)       // cosine 相似度
  logits_i = [sim(z_a_i, z_p_i)] ⊕ [sim(z_a_i, z_n_j)]_{j=1}^N  // 拼接
  L_contrast = -1/B · Σ_i log( exp(logits_i[0]/τ) / Σ_j exp(logits_i[j]/τ) )

Queue 机制（MoCo 风格）:
  z_n = FIFO_queue.enqueue(z_p.detach())   // 负样本队列，容量 N >> B
  // 队列中存储的是历史 batch 的编码，增大负样本数而不增加显存

Hard Negative Mining:
  top-k indices = argsort(sim(z_a, z_n), descending=True)[:k]
  z_n_hard = z_n[top-k indices]            // 只保留最难的 k 个负样本
```

## 可实现结构
- **双塔编码器 + 投影头**：encoder → projection_head(MLP 2层) → 归一化 → loss
- **负样本队列**：维护 momentum encoder 输出的 FIFO queue，容量 N=65536
- **对称损失**：L = L(a→p) + L(p→a)，正负角色互换，增强训练稳定性
- **多粒度对比**：同时在 token-level、sequence-level、expert-level 施加对比

## GPU 可行性
- **张量化**：sim 计算为 z_a @ z_n^T → 标准 GEMM (B×d) @ (d×N) = B×N
- **GEMM 可映射**：核心就是 1-2 次矩阵乘法，完美映射 cuBLAS
- **复杂度**：O(B·N·d) 计算 + O(B·N) 存储 logits 矩阵，B=256,N=65536 时约 64MB
- **显存与 KV-Cache**：负样本队列占 N·d·4 bytes ≈ 65536·256·4 = 64MB，固定开销
- **低精度稳定**：cosine 相似度 + softmax 在 fp16 下需注意 exp 溢出，用 log-sum-exp trick
- **并行与通信**：多 GPU 时用 all-gather 收集其他 GPU 的负样本扩大 N（MoCo v3 策略）
- **稀疏结构**：hard negative mining 后只保留 k<<N 个负样本，有效稀疏化 logits
- **算子融合**：L2-norm → matmul → scale → log-softmax → nll_loss 可融合

## 论文表述方式
"采用温度缩放的 InfoNCE 对比损失，通过动量编码器维护 N=65536 的负样本队列，
在单位球面上最大化正对互信息的下界，理论分析表明该下界以 O(1/√N) 收敛。"

## 风险
- τ 过小导致训练不稳定（梯度过大），τ 过大导致所有样本不分难易（退化均匀分布）
- 负样本队列中的过期编码引入 stale representation 偏差
- 假阴性问题：无监督负采样可能采到语义相似但标注不同的样本
- B 过小时 batch 内正负对不平衡，需依赖队列补偿
