# 信息瓶颈注意力 / Information Bottleneck Attention
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当注意力机制需要**选择性传递有用信息、抑制冗余/噪声信息**时，用信息瓶颈理论指导注意力权重的学习——使注意力分布最大化关于目标 $Y$ 的互信息 $I(Z;Y)$，同时最小化关于输入 $X$ 的互信息 $I(X;Z)$。典型场景：长文档摘要（大量无关 token 需被过滤）、多模态对齐（跨模态噪声抑制）、可解释性（注意力权重作为信息流的可视化）。

## 数学思想来源
- 透镜：[categorical（范畴化透镜 — 信息论框架统一注意力设计）, variational（变分透镜 — 约束优化与拉格朗日对偶）]
- 知识：[`../../knowledge-base/probability/information-bottleneck.md`（IB 目标函数与变分下界）, `../../knowledge-base/probability/kl-divergence.md`（KL 正则项的实现）, `../../knowledge-base/probability/entropy.md`（互信息估计）]

## 需要的数学知识
- **信息瓶颈 IB 目标**：$\min I(X;Z) - \beta I(Z;Y)$，压缩-预测权衡
- **变分信息瓶颈 VIB**：用变分下界替代难以估计的互信息
- **互信息与注意力的对应**：softmax 注意力权重 $\alpha_{ij}$ 可解释为从 key $j$ 到 query $i$ 的信息信道分配

## AI 模块形式

**核心思路**：将注意力视为信息瓶颈——注意力权重决定"让多少信息从 value 流向输出"，同时用 KL 正则约束信息量不过大。

**方案 A：KL 正则化注意力（最简 IB 注意力）**：
```python
# 注意力分布 q(z|x) 与均匀先验的 KL 散度作为 IB 正则
scores = (Q @ K.T) / sqrt(d)
attn = softmax(scores)
uniform_prior = ones_like(attn) / n
kl_reg = (attn * (log(attn + eps) - log(uniform_prior))).sum(dim=-1).mean()
loss = task_loss + beta * kl_reg
output = attn @ V
```

**方案 B：变分信息瓶颈注意力（VIB-Attention）**：
```python
# 引入随机瓶颈 Z ~ q(Z|attention)，限制信息通过量
scores = (Q @ K.T) / sqrt(d)
attn = softmax(scores)
mu_z, log_var_z = attn, linear(attn)  # 均值与可学习方差
z = softmax(mu_z + exp(0.5 * log_var_z) * randn_like(mu_z))  # 重参数化 + softmax
kl = 0.5 * (mu_z^2 + exp(log_var_z) - log_var_z - 1).sum(-1).mean()  # KL vs 先验
output = z @ V
loss = task_loss + beta * kl
```

**方案 C：互信息最大化注意力（DIM 风格）**：
```python
# 用 InfoNCE 直接最大化 I(Z;Y)，配合 KL 约束 I(X;Z)
Z = softmax((Q @ K.T) / sqrt(d)) @ V
info_nce = infonce_loss(Z, target_embedding, negatives, tau=0.1)
kl_bottleneck = estimate_kl(X, Z)  # MINE/NWJ 估计器
loss = -info_nce + beta * kl_bottleneck
```

## 可实现结构
- **IB-Sparse Attention**：将 KL 正则化为注意力稀疏性的软约束——KL 对均匀先越大 → 注意力越集中 → 隐式 Top-K 选择
- **Dropout 的 IB 解释**：Dropout 是一种随机信息瓶颈——随机阻断部分信息通道，迫使模型学习鲁棒表示。Dropout rate 对应 $\beta$ 参数
- **Multi-Head 信息分配**：不同 head 学习不同的信息瓶颈（不同 $\beta$），有的 head 传递全局信息，有的只传递局部信息

## GPU 可行性
- **D1[v]**：KL 正则项为逐元素运算，VIB 重参数化采样为逐元素
- **D2[v]**：主体 $QK^T$ 和 $attn \cdot V$ 为标准 GEMM，正则项不引入新 GEMM
- **D3[v]**：KL 正则 $O(n)$ 逐 token，不增加渐近复杂度
- **D4[~]**：VIB 需额外 $\mu_z$ 和 $\log\sigma_z$，约 2x 注意力权重显存
- **D5[v]**：KL 中 log/exp 在 bf16 下稳定（标准 log-softmax 技巧）
- **D6[v]**：正则项可与前向传播并行，不引入串行依赖
- **D7[v]**：KL 正则隐式诱导注意力稀疏性，可利用 block-sparse 加速
- **D8[v]**：KL 可融入 softmax kernel（FusedSoftmaxKL）

## 论文表述方式
"我们提出信息瓶颈注意力机制，通过将注意力建模为信息瓶颈优化问题，在最大化输出与目标的互信息的同时最小化输入信息的冗余传递，实现理论上最优的信息选择，并在实验中展现出更强的稀疏性和可解释性。"

## 风险
- **互信息估计的方差问题**：方案 C 中的 MINE/NWJ/InfoNCE 估计器在高维空间中方差大，可能导致训练不稳定。建议先用方案 A（KL 正则）验证 IB 注意力的基本效果，再尝试完整 IB 目标。
- **$\beta$ 调参困难**：$\beta$ 控制压缩-预测权衡，不同任务最优 $\beta$ 差异大。$\beta$ 过小退化为标准注意力，$\beta$ 过大导致欠拟合。建议自适应 $\beta$ 调度或信息平面监控。