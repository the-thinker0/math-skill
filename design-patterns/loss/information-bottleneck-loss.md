# Information Bottleneck Loss（信息瓶颈损失）

## 适用问题
当需要让表示 Z 在"保留任务相关信息"与"压缩输入冗余信息"之间取得最优平衡时使用。
典型场景：(1) Shared 表示应只保留跨任务共性信息，丢弃任务特异噪声；
(2) Private 表示应只保留单任务独有信息；(3) 路由特征应最大化专家-任务匹配信息。
核心诉求：**信息最优压缩——不多不少，只保留有用的**。

## 数学思想来源
- 透镜：lenses/information.md（信息瓶颈原理、互信息优化）、lenses/optimization.md（拉格朗日对偶）
- 知识：knowledge-base/fundamentals/information-theory.md（IB 理论、率失真函数）、
  knowledge-base/fundamentals/probability.md（互信息与条件熵）

## 需要的数学知识
- **信息瓶颈目标**：min I(X;Z) - β·I(Z;Y)，压缩 X→Z 同时保留 Z 对 Y 的预测力
- **互信息变分下界/上界**：
  I(X;Z) ≤ E_{p(x,z)}[log q(z|x)] - E_{p(z)}[log q(z)]  (用上界估计压缩项)
  I(Z;Y) ≥ E_{p(z,y)}[log q(y|z)] + H(Y)  (用下界估计预测项)
- **CPC (Contrastive Predictive Coding)**：I(Z_t; Z_{t+k}) 的 InfoNCE 下界
- **MINE (Mutual Information Neural Estimation)**：
  I(X;Z) = sup_θ { E[log T_θ(x,z)] - log E[T_θ(x,z')] }

## AI 模块形式
```
模块：InformationBottleneckLoss
输入：表示 Z ∈ R^{B×d}，输入 X（或其编码），标签 Y

方法1 - VIB (Variational Information Bottleneck)：
  // 压缩项上界：用变分近似 q(z) = N(0, I)
  I_upper = KL(q(z|x) ‖ p(z))  // 标准 VAE 的 KL 项
  // 预测项下界：用分类器/回归器 q(y|z)
  I_lower = CE(q(y|z), y)  // 交叉熵 = -H(Y|Z) 的估计
  L_IB = I_upper + β · I_lower
  // β 控制压缩-预测权衡：β↑ 更激进压缩，β↓ 保留更多预测信息

方法2 - 对比式互信息估计（无需分布假设）：
  // 用 NWJ 估计器替代 KL
  I_nwj(x;z) = E[f(x,z)] - exp(E[f(x,z')] - 1)  // f 为判别网络
  L_IB_contrast = I_nwj(x;z) - β · InfoNCE(z, y)  // 两项均可微

方法3 - Shared/Private IB 分解：
  Z_s = enc_shared(x), Z_p = enc_private(x)
  L = I(Z_s; X) + I(Z_p; X)           // 总压缩
    - β₁ · I(Z_s; Y_common)            // Shared 保留公共信息
    - β₂ · I(Z_p; Y_specific)          // Private 保留特异信息
    + γ · OrthLoss(Z_s, Z_p)           // 正交性确保分解
```

## 可实现结构
- **双编码器架构**：enc_shared 和 enc_private 共享底层 trunk，分叉出各自 head
- **互信息估计器**：小型 MLP 判别器 T(x,z) → scalar，与主网络交替优化
- **β 调度**：训练初期 β=0（不压缩），随训练进行逐步增大到目标值
- **梯度反转**：I(X;Z) 的梯度通过 z.flip_gradient() 反转，实现对抗式压缩

## GPU 可行性
- **张量化**：互信息估计器为标准 MLP → GEMM 链；KL 为 element-wise
- **GEMM 可映射**：VIB 方法仅需 encoder GEMM + KL 计算；对比方法额外 1 次 GEMM 做 shuffle 负样本
- **复杂度**：比标准网络多 1 个 KL 项 O(B·d) 或 1 个判别器前向 O(B·d²)，可接受
- **显存与 KV-Cache**：需额外存储判别器参数（小型 MLP）和中间激活，<10MB
- **低精度稳定**：MINE 估计器的 exp 运算在 fp16 下需 clip；VIB 的 KL 建议 fp32
- **并行与通信**：判别器与主网络可并行前向，梯度通过共享表示层同步
- **稀疏结构**：压缩后的 Z 维度可动态裁剪（自动相关性确定 ARD）
- **算子融合**：encoder 前向 + KL 计算 + 判别器前向可部分融合

## 论文表述方式
"基于信息瓶颈理论，将 Shared/Private 分解形式化为 min I(X;Z_s)+I(X;Z_p)-β₁I(Z_s;Y_c)-β₂I(Z_p;Y_s)，
通过变分上下界替代互信息项实现端到端优化，理论上保证压缩-预测 Pareto 前沿的 β-最优性。"

## 风险
- 互信息估计（MINE/NWJ）方差大，训练不稳定，需要大 batch 或 moving average
- β 选择不当导致过度压缩（欠拟合）或压缩不足（过拟合）
- VIB 假设高斯后验，对复杂后验分布近似不足
- 多 IB 联合优化时 β₁, β₂ 的相对比例敏感
