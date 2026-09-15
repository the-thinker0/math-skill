# 信息瓶颈注意力 / Information Bottleneck Attention
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

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

**注意力熵代理**：
```python
log_attn = log_softmax(Q @ K.T / sqrt(d), dim=-1)
attn = exp(log_attn)
entropy = -(attn * log_attn).sum(-1).mean()
kl_to_uniform = log(n) - entropy
loss_uniform = task_loss + beta * kl_to_uniform  # 鼓励分散注意力
loss_concentrated = task_loss + beta * entropy   # 鼓励集中，不产生精确零
output = attn @ V
```
分类信道 $J\sim\operatorname{Cat}(a(X))$ 满足 $\mathbb E_X KL(a(X)\|r)=I(X;J)+KL(p_J\|r)$。它约束的是**采样索引** $J$ 的信息，不自动约束连续上下文 $Z=a(X)V(X)$，因为 $V$ 也依赖 $X$。把注意力熵称作上下文信息瓶颈需要补上这一信道定义。

**实际随机上下文瓶颈**：
```python
context = attn @ V
mu, logvar = linear_mu(context), linear_logvar(context)
z = mu + exp(0.5 * logvar) * randn_like(mu)
kl = 0.5 * (mu**2 + exp(logvar) - logvar - 1).sum(-1).mean()
loss = prediction_loss(task_head(z), target) + beta_comp * kl
```
softmax 前 logits 的高斯 KL 可通过数据处理给下游单纯形 MI 上界；它一般不是 logistic-normal 单纯形分布的精确 KL。若 `infonce_loss` 返回常见非负损失，应**最小化它**；MI 下界是 `log(num_candidates) - infonce_loss`。最小化 MINE/NWJ 下界不能证明信息压缩。

## 可实现结构

- 熵正则注意力用于可测量的集中/均匀偏好。
- 随机上下文 VIB 用于明确定义的输入—潜变量信息界。
- 各头权重是设计超参数；dropout 率与 IB beta 没有通用一一对应。
- 可执行稀疏需显式 mask/top-k 或稀疏概率变换及支持的核。

## GPU 可行性

- **D1/D2[~]**：KL/熵是逐元素归约；高斯统计还需要额外线性映射及其 GEMM 成本。
- **D3/D4[~]**：稠密注意力熵每头 $O(n^2)$；若暴露完整注意力阵，可抵消显存节省。上下文 VIB 统计存储 $O(nd_z)$，不是固定倍增注意力权重显存。
- **D5[~]**：使用 fp32 log-softmax/归约及有界 log-variance；mask 概率须安全处理 $0\log0$。
- **D6/D8[~]**：熵依赖注意力得分；流式实现可在注意力核内累加，但反向及实际核支持需验证。
- **D7[~]**：低熵不是块稀疏；稀疏化时报告保留块、丢弃质量、输出误差及实际延迟。

## 论文表述方式

“我们区分注意力熵正则与随机上下文瓶颈：前者控制分类权重集中程度，后者具有明确定义的变分信息上界。报告对应熵/KL、预测质量及实测实现成本。”

## 风险
- **互信息估计的方差问题**：方案 C 中的 MINE/NWJ/InfoNCE 估计器在高维空间中方差大，可能导致训练不稳定。建议先用方案 A（KL 正则）验证 IB 注意力的基本效果，再尝试完整 IB 目标。
- **$\beta$ 调参困难**：$\beta$ 控制压缩-预测权衡，不同任务最优 $\beta$ 差异大。$\beta$ 过小退化为标准注意力，$\beta$ 过大导致欠拟合。建议自适应 $\beta$ 调度或信息平面监控。
