# Contrastive Loss（对比损失）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

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

单位归一化特征可用对齐与均匀性作总体诊断：
$$L_{align}=\mathbb E_{(x,x^+)}\|f(x)-f(x^+)\|^2,\qquad L_{uniform}=\log\mathbb E_{x,x'}e^{-t\|f(x)-f(x')\|^2},\ t>0.$$
无限负样本分析在相应采样及分布假设下联系对比目标与这些性质。它不保证有限 batch 精确均匀，也没有1024负样本之类通用阈值。温度、正样本构造、模型容量及可达到的分布影响权衡。[Wang 与 Isola 原始分析](https://proceedings.mlr.press/v119/wang20k.html)。

一个来自联合分布的正对，加 $M-1$ 个来自相应边缘的 iid 负样本时，总体界为 $I(U;V)\ge\log M-\mathbb E[L_{NCE}]$。损失本身**不是** MI 下界，且界针对正对中的变量。它受 $\log M$ 饱和上限限制；有限样本估计偏差、困难负采样、相关队列及 critic 受限需单独处理。更多负样本不保证固定学习 critic 的实际估计更紧。[CPC 原论文](https://arxiv.org/abs/1807.03748)。

对齐/均匀性不保证下游语义有效性。除 InfoNCE 外报告正对距离、经验均匀性、坍塌指标及下游任务。

## AI 模块形式

```python
anchors = normalize(encoder_q(x), dim=-1)
positives = normalize(encoder_k(x_positive), dim=-1)
negatives = queue.snapshot()               # 插入当前正样本前先读取
positive_logits = (anchors * positives).sum(-1, keepdim=True)
negative_logits = anchors @ negatives.T
logits = cat([positive_logits, negative_logits], dim=-1) / tau
loss = cross_entropy(logits.float(), zeros(B, dtype=long))
queue.enqueue(positives.detach())          # 存储O(M*d)，不是免费显存
```
按定义从负池排除真实正对/自身。历史队列以陈旧/相关性换更大池，节省重复编码器工作但占用显存。困难负采样改变分布，寻找困难负样本也可能仍需全池打分；报告采样规则，不能默认保留 iid 边缘负样本的 MI 保证。

## 可实现结构
- **双塔编码器 + 投影头**：encoder → projection_head(MLP 2层) → 归一化 → loss
- **负样本队列**：维护 momentum encoder 输出的 FIFO queue，容量 N=65536
- **对称损失**：L = L(a→p) + L(p→a)，正负角色互换，增强训练稳定性
- **多粒度对比**：同时在 token-level、sequence-level、expert-level 施加对比

## GPU 可行性

- **D1/D2[~]**：相似度使用 $B\times d$ 乘 $d\times M$ GEMM；归一化和交叉熵另有归约。
- **D3/D4[~]**：相似度 $O(BMd)$；物化 logits $O(BM)$，队列 $O(Md)$。fp32、$B=256,M=65536$ 时 logits 占64 MiB；$65536\times256$ 队列另占64 MiB。
- **D5[~]**：使用稳定 log-softmax/log-sum-exp 及 fp32 累加；很小温度放大得分误差与梯度。
- **D6[~]**：跨设备负样本需 all-gather（可能还有其梯度通信）；动量队列的通信形态不同。
- **D7[~]**：保留困难负样本只在选择之后减少 logits；除非使用近似索引，全池搜索成本仍在。
- **D8[~]**：分块相似度/交叉熵可降显存，但写成算子链不代表存在单个融合核。

## 论文表述方式
"采用温度缩放的 InfoNCE 对比损失，通过动量编码器维护 N=65536 的负样本队列，
在单位球面上优化正对齐与表示均匀性代理。互信息下界和采样误差界依赖负样本分布、独立性与队列陈旧度假设，论文中应报告队列大小、温度、负样本策略和下游指标的消融。"

## 风险
- τ 过小导致训练不稳定（梯度过大），τ 过大导致所有样本不分难易（退化均匀分布）
- 负样本队列中的过期编码引入 stale representation 偏差
- 假阴性问题：无监督负采样可能采到语义相似但标注不同的样本
- B 过小时 batch 内正负对不平衡，需依赖队列补偿
