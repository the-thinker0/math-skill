# Information Bottleneck Loss（信息瓶颈损失）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当需要让表示 Z 在"保留任务相关信息"与"压缩输入冗余信息"之间取得最优平衡时使用。
典型场景：(1) Shared 表示应只保留跨任务共性信息，丢弃任务特异噪声；
(2) Private 表示应只保留单任务独有信息；(3) 路由特征应最大化专家-任务匹配信息。
核心诉求：**信息最优压缩——不多不少，只保留有用的**。

## 数学思想来源
- 透镜：../../lenses/probabilistic.md（信息瓶颈原理、互信息优化）、../../lenses/variational.md（拉格朗日对偶）
- 知识：../../knowledge-base/probability/kl-divergence.md（IB 理论、率失真函数）、
  ../../knowledge-base/probability/entropy.md（互信息与条件熵）

## 需要的数学知识

- Markov 链 $Y-X-Z$ 下，经典 IB 最小化 $I(X;Z)-\beta_{pred}I(Z;Y)$。重缩放后为 $-I(Z;Y)+\beta_{comp}I(X;Z)$，其中 $\beta_{comp}=1/\beta_{pred}$。
- 编码器 $q_\theta(z|x)$ 与参考先验 $r(z)$ 满足 $\mathbb E_x KL(q_\theta(z|x)\|r)=I(X;Z)+KL(q_\theta(z)\|r)\ge I(X;Z)$。
- 预测解码器给出 $I(Z;Y)\ge H(Y)+\mathbb E\log q_\phi(y|z)$。交叉熵估计的是**正的**条件熵加近似误差。
- 受限 critic 的 MINE/NWJ/InfoNCE 是 MI 下界/估计器，不是压缩惩罚的可靠上界。最小化宽松下界可能只把信息藏起来，并未降低真实 MI。神经 critic 的上确界等于真实 MI 还需函数族及优化条件。
- 正交性控制线性重叠，不保证共享/私有统计独立。[Deep VIB 原论文](https://arxiv.org/abs/1612.00410)。

## AI 模块形式

```python
# 随机高斯瓶颈，期望通过 minibatch/采样近似
mu, logvar = encoder(X)
z = mu + exp(0.5 * logvar) * randn_like(mu)
kl_upper = 0.5 * (mu**2 + exp(logvar) - 1 - logvar).sum(-1).mean()
prediction_ce = cross_entropy(decoder(z), Y)
loss = prediction_ce + beta_comp * kl_upper
# beta_comp 越大压缩压力越强；beta_pred = 1 / beta_comp。
```
共享/私有分支分别使用随机编码器、预测目标及压缩权重。去相关项是附加代理目标，不是信息分解定理。确定性连续编码器的 $I(X;Z)$ 可为无穷大；引入噪声/量化或明确有限数据的信息模型。

若使用学习到的 MI critic，应先固定编码器最大化其下界，再作诊断。通过对抗 critic 最小化进行压缩仍是带优化间隙的启发式，不能把下界报告为压缩证书。

## 可实现结构

- 双编码器加预测头，明确哪些标签定义“共享”与“私有”。
- 可按任务从零预热 `beta_comp`；同时报告预测与 KL 曲线。
- 用更丰富编码器族或留出似然诊断高斯后验失配。
- MI critic 使用独立优化器；梯度反转符号须与所写极小极大目标一致。

## GPU 可行性

- **D1/D2[~]**：编码器/解码器用 GEMM；对角高斯 KL 为逐元素运算加归约。
- **D3/D4[~]**：KL 成本 $O(Bd_z)$、统计存储 $O(Bd_z)$。学习 critic 要另计实际网络和激活成本，没有通用显存上限。
- **D5[~]**：exp/log 与 KL 归约在 fp32 计算，约束异常 log-variance，监控后验坍塌。
- **D6[~]**：潜变量样本可批处理；解码器/critic 依赖编码器输出，交替更新是顺序依赖。
- **D7[N/A]**：低 MI 或小 KL 不意味着张量零元素或可执行稀疏通道。
- **D8[~]**：逐元素 KL 可融合；整个编码器/critic 融合需具体核和测量。

## 论文表述方式

“我们优化预测交叉熵与输入—表示互信息的变分上界，报告压缩权重口径、界间隙诊断、预测质量及后验族敏感性；该目标本身不构成泛化误差保证。”

## 风险
- 互信息估计（MINE/NWJ）方差大，训练不稳定，需要大 batch 或 moving average
- β 选择不当导致过度压缩（欠拟合）或压缩不足（过拟合）
- VIB 假设高斯后验，对复杂后验分布近似不足
- 多 IB 联合优化时 β₁, β₂ 的相对比例敏感
