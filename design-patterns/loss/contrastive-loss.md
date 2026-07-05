# Contrastive Loss（对比损失）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当需要让模型学会"什么和什么相似、什么和什么不同"时使用。典型场景：
(1) 同一输入的不同增强视图应拉近（正对），不同输入应推远（负对）；
(2) Shared 表示应包含跨任务共性，Private 表示应区分任务特异性；
(3) 专家嵌入空间中相似输入应路由到同一专家。核心诉求：**学习相对关系而非绝对值**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（度量空间与距离函数）、../../lenses/probabilistic.md（互信息最大化）
- 知识：../../knowledge-base/probability/entropy.md（条件分布与似然）、
  ../../knowledge-base/differential-geometry/manifold.md（测地线与曲率）

## 需要的数学知识
- **InfoNCE 损失**：L = -log[exp(sim(q,k⁺)/τ) / Σ_j exp(sim(q,k_j)/τ)]
  本质是对比学习中的互信息下界估计，τ 为温度参数控制分布锐度
- **Margin-based 度量学习**：Triplet Loss = max(0, d(a,p) - d(a,n) + margin)
  在度量空间中显式拉开正负对距离差
- **NT-Xent (Normalized Temperature-scaled Cross Entropy)**：
  在单位球面 S^{d-1} 上的 softmax 对比，归一化消除尺度影响
- **去偏对比学习 (Debiased Contrastive)**：
  修正负样本中的假阴性问题，使用先验 τ⁺ 估计真实负样本分布

## 对齐-均匀性理论 (Alignment-Uniformity Framework)

对比学习的表示质量可分解为两个独立目标（Wang & Isola, 2020）：

- **对齐 (Alignment)**：正对的表示应接近
  $L_{\text{align}} = \mathbb{E}_{(x, x^+)}[\|f(x) - f(x^+)\|^2]$
- **均匀性 (Uniformity)**：表示应在单位超球面 $S^{d-1}$ 上均匀分布
  $L_{\text{uniform}} = \log \mathbb{E}_{x, x'}[\exp(-2\|f(x) - f(x')\|^2)]$

**InfoNCE 与对齐-均匀性的关系**：当 $N \to \infty$ 且温度 $\tau$ 适当时，InfoNCE 损失渐近分解为 alignment + uniformity 之和。有限 $N$ 下，InfoNCE 给出 $I(X;Z)$ 的下界，下界紧度随 $N$ 增大。

**均匀性成立的条件**：
- 负样本数 $N$ 充分大（理论要求 $N \to \infty$，实践中 $N \geq 1024$ 通常足够）
- 温度 $\tau$ 不过大（$\tau \to \infty$ 时 loss 退化为常数，丧失均匀性驱动力）
- 表示维度 $d$ 足够支撑数据的本征维度

**均匀性不成立的条件**：
- 负样本不足 → 均匀性驱动力弱，表示可能聚集在球面局部
- 表示坍塌 (representation collapse)：所有输入映射到同一/少数点，trivially 最小化 alignment 但完全丧失 uniformity
- 温度 $\tau$ 过大 → softmax 趋于均匀分布，梯度消失，无均匀性保证
- batch 内正负对比例严重失衡且未通过队列补偿

**最多能保证什么**：在理想条件下（$N$ 充分大、$\tau$ 合适、无坍塌），对比损失最小化等价于同时最大化正对对齐度和表示均匀性。

**不能保证什么**：不能保证学到的表示对下游任务最优（均匀性 ≠ 任务相关性）；不能保证语义层级的对齐（仅保证几何层面的正对接近）。

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
- **D1[v]**：sim 计算为 z_a @ z_n^T → 标准 GEMM (B×d) @ (d×N) = B×N
- **D2[v]**：核心就是 1-2 次矩阵乘法，完美映射 cuBLAS
- **D3[v]**：O(B·N·d) 计算 + O(B·N) 存储 logits 矩阵，B=256,N=65536 时约 64MB
- **D4[v]**：负样本队列占 N·d·4 bytes ≈ 65536·256·4 = 64MB，固定开销
- **D5[v]**：cosine 相似度 + softmax 在 fp16 下需注意 exp 溢出，用 log-sum-exp trick
- **D6[v]**：多 GPU 时用 all-gather 收集其他 GPU 的负样本扩大 N（MoCo v3 策略）
- **D7[v]**：hard negative mining 后只保留 k<<N 个负样本，有效稀疏化 logits
- **D8[v]**：L2-norm → matmul → scale → log-softmax → nll_loss 可融合

## 论文表述方式
"采用温度缩放的 InfoNCE 对比损失，通过动量编码器维护 N=65536 的负样本队列，
在单位球面上优化正对齐与表示均匀性代理。互信息下界和采样误差界依赖负样本分布、独立性与队列陈旧度假设，论文中应报告队列大小、温度、负样本策略和下游指标的消融。"

## 风险
- τ 过小导致训练不稳定（梯度过大），τ 过大导致所有样本不分难易（退化均匀分布）
- 负样本队列中的过期编码引入 stale representation 偏差
- 假阴性问题：无监督负采样可能采到语义相似但标注不同的样本
- B 过小时 batch 内正负对不平衡，需依赖队列补偿
