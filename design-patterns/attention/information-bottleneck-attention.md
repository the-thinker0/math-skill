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
# ⚠ 注意 KL 方向的语义：
# KL(attn || uniform) = log(n) - H(attn)
# 最小化 +beta * KL(attn || uniform) = 最大化 H(attn) → 推向均匀分布（最大熵/最大压缩）
# 这本身不诱导稀疏性！稀疏性来自压缩项与 task_loss 的张力。
# 若需要显式诱导稀疏注意力，应使用熵惩罚 +beta * H(attn)（最小化熵）。

scores = (Q @ K.T) / sqrt(d)
attn = softmax(scores)
uniform_prior = ones_like(attn) / n

# 正确的 IB 压缩项：KL(q(z|x) || p(z))，p(z) 为固定先验
# 最小化此项 → 压缩信息（推向先验），与 task_loss 的张力产生有用注意力
kl_compression = (attn * (log(attn + eps) - log(uniform_prior))).sum(dim=-1).mean()
# = log(n) - H(attn)

# IB 目标：min task_loss + beta * I(X;Z)，其中 I(X;Z) ≈ KL(attn || prior)
loss_ib = task_loss + beta * kl_compression
# 注意：此项单独作用会推向均匀；稀疏性来自 task_loss 的反向拉力

# 替代方案：显式稀疏性诱导（非 IB 压缩，而是熵惩罚）
entropy = -(attn * log(attn + eps)).sum(dim=-1).mean()
loss_sparse = task_loss + beta * entropy  # 最小化熵 → 注意力集中 → 隐式 Top-K

output = attn @ V
```

**方案 B：变分信息瓶颈注意力（VIB-Attention）**：
```python
# 引入随机连续瓶颈 Z ~ q(Z|context)，限制 value 聚合后的信息通过量
scores = (Q @ K.T) / sqrt(d)
attn = softmax(scores)
context = attn @ V
mu_z, log_var_z = linear_mu(context), linear_logvar(context)
z = mu_z + exp(0.5 * log_var_z) * randn_like(mu_z)  # 高斯重参数化
kl = 0.5 * (mu_z^2 + exp(log_var_z) - log_var_z - 1).sum(-1).mean()  # KL[q(z|context)||N(0,I)]
output = linear_out(z)
loss = task_loss + beta * kl
```

若瓶颈直接作用在 attention simplex 上（如对 logits 加噪后 softmax），变量分布是 logistic-normal / Concrete 类，不能再使用普通高斯到标准正态的闭式 KL；应使用 Monte Carlo KL、Concrete KL 近似，或把 KL 放在 softmax 前的 logits 高斯变量上。

**方案 C：互信息最大化注意力（DIM 风格）**：
```python
# 用 InfoNCE 直接最大化 I(Z;Y)，配合 KL 约束 I(X;Z)
Z = softmax((Q @ K.T) / sqrt(d)) @ V
info_nce = infonce_loss(Z, target_embedding, negatives, tau=0.1)
kl_bottleneck = estimate_kl(X, Z)  # MINE/NWJ 估计器
loss = -info_nce + beta * kl_bottleneck
```

## 可实现结构
- **IB-Sparse Attention**：IB 压缩项 KL(attn || uniform) 本身推向均匀分布（最大熵），但与 task_loss 的张力迫使注意力在"压缩所有信息"与"选择性传递有用信息"之间取舍，从而隐式产生非均匀注意力。若要**显式**诱导稀疏（Top-K 选择），应使用熵惩罚 `+beta * H(attn)`（最小化注意力熵 → 集中化），而非依赖 IB 压缩项
- **Dropout 的 IB 解释**：Dropout 是一种随机信息瓶颈——随机阻断部分信息通道，迫使模型学习鲁棒表示。Dropout rate 对应 $\beta$ 参数
- **Multi-Head 信息分配**：不同 head 学习不同的信息瓶颈（不同 $\beta$），有的 head 传递全局信息，有的只传递局部信息

## GPU 可行性
- **D1[v]**：KL 正则项为逐元素运算，VIB 重参数化采样为逐元素
- **D2[v]**：主体 $QK^T$ 和 $attn \cdot V$ 为标准 GEMM，正则项不引入新 GEMM
- **D3[v]**：KL 正则 $O(n)$ 逐 token，不增加渐近复杂度
- **D4[~]**：VIB 需额外 $\mu_z$ 和 $\log\sigma_z$，约 2x 注意力权重显存
- **D5[v]**：KL 中 log/exp 在 bf16 下稳定（标准 log-softmax 技巧）
- **D6[v]**：正则项可与前向传播并行，不引入串行依赖
- **D7[~]**：KL 正则本身不诱导稀疏性（推向均匀分布）；若需稀疏，应改用熵惩罚 +beta * H(attn)，此时可 block-sparse 加速
- **D8[v]**：KL 可融入 softmax kernel（FusedSoftmaxKL）

## 论文表述方式
"我们提出信息瓶颈注意力机制，通过将注意力建模为信息瓶颈优化问题，在最大化输出与目标的互信息的同时约束输入信息的冗余传递。IB 压缩项本身推向均匀分布（最大熵），与任务损失的张力产生非均匀注意力；若要显式诱导稀疏性，需额外使用熵惩罚项。"

## 风险
- **互信息估计的方差问题**：方案 C 中的 MINE/NWJ/InfoNCE 估计器在高维空间中方差大，可能导致训练不稳定。建议先用方案 A（KL 正则）验证 IB 注意力的基本效果，再尝试完整 IB 目标。
- **$\beta$ 调参困难**：$\beta$ 控制压缩-预测权衡，不同任务最优 $\beta$ 差异大。$\beta$ 过小退化为标准注意力，$\beta$ 过大导致欠拟合。建议自适应 $\beta$ 调度或信息平面监控。
