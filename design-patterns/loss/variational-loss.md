# Variational Loss（变分损失）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当需要从隐变量分布中采样并生成多样化输出时使用。典型场景：
(1) 专家选择引入离散隐变量 z，需要端到端优化；(2) 表示空间需要建模不确定性；
(3) 生成式路由中需要从后验分布 p(z|x) 采样；(4) 贝叶斯专家混合。
核心诉求：**在潜空间中建模分布而非点估计，获得不确定性感知与多样性**。

## 数学思想来源
- 透镜：../../lenses/variational.md（变分推断与 ELBO）、../../lenses/probabilistic.md（后验与先验）
- 知识：../../knowledge-base/probability/entropy.md（KL 散度、变分族）、
  ../../knowledge-base/probability/kl-divergence.md（ELBO 推导）

## 需要的数学知识
- **ELBO（证据下界）**：log p(x) ≥ E_{q(z|x)}[log p(x|z)] - KL(q(z|x) ‖ p(z))
  第一项为重构似然，第二项为正则项将后验推近先验
- **重参数化技巧 (Reparameterization Trick)**：z = μ + σ ⊙ ε, ε ~ N(0, I)
  使梯度可通过采样操作反向传播
- **KL 散度闭合形式**：当 q 和 p 均为高斯时，
  KL(N(μ,σ²) ‖ N(0,1)) = -½ Σ(1 + log σ² - μ² - σ²)
- **Gumbel-Softmax（离散隐变量）**：
  z = softmax((log π + g) / τ), g ~ Gumbel(0,1)，连续松弛离散采样

## AI 模块形式

```python
# 高斯VAE；beta_vae=1时才是普通负ELBO
mu, logvar = encoder(x)
z = mu + exp(0.5 * logvar) * randn_like(mu)
KL = 0.5 * (mu**2 + exp(logvar) - 1 - logvar).sum(-1)
recon_nll = -decoder_log_prob(x, z)
loss = (recon_nll + beta_vae * KL).mean()

# 松弛分类潜变量：这是路径梯度，不自动是STE
u = clamp(rand_like(logits), min=eps, max=1-eps)
g = -log(-log(u))
z_soft = softmax((logits + g) / tau, dim=-1)
# 可选straight-through硬样本：
z_hard = one_hot(argmax(z_soft, dim=-1), num_classes=K)
z_st = z_hard - z_soft.detach() + z_soft
```
一般 beta 加权目标不自动是 log evidence 下界，退火也不保证避免坍塌。若分类专家输出形状为 $B\times K\times d$，应以 `(z_soft[..., None] * expert_outputs).sum(dim=1)` 合成权重；评估全部专家仍是稠密成本。

VIB 的 `prediction_nll + beta_comp * KL` 经重缩放对应 `I(X;Z) - beta_pred * I(Z;Y)`，其中 `beta_pred = 1/beta_comp`。不要对互为倒数的两种口径复用同一 beta。

## 可实现结构
- **编码器双头输出**：Linear(d, 2·d_z) → split → (μ, log_σ²)，共享底层参数
- **β 退火策略**：β 从0逐渐增大可缓解后验坍塌，但须实测，不保证避免坍塌
- **Free Bits**：每个维度设定 KL 下界 λ，只惩罚超出部分：Σ max(KL_j, λ)
- **IWAE 多粒子**：用 K 个样本的 log-mean-exp 替代单样本 ELBO，获得更紧下界

## GPU 可行性
- **张量化**：μ,σ² 的计算为 Linear 层（GEMM），KL 为 element-wise 运算
- **GEMM 可映射**：编码器 1 次 GEMM → split → 重参数化 → 解码器 1 次 GEMM
- **复杂度**：与标准前向网络同阶 O(B·d²)，KL 计算 O(B·d_z) 可忽略
- **显存与 KV-Cache**：额外存储 μ, σ² 两个 B×d_z 矩阵，开销极小
- **低精度稳定**：KL 的 log/exp 运算建议 fp32；Gumbel softmax 的 log-log 需 fp32
- **并行与通信**：多粒子 IWAE 的 K 个样本可并行采样和计算
- **稀疏结构**：松弛样本在 $\tau\to0$ 时趋近one-hot，但有限温度仍是稠密执行；需硬分发实际跳过非活跃分支
- **算子融合**：μ 和 σ² 的 Linear 可共享一次 GEMM 后 split；KL 的 exp/sub/add 可融合

## 论文表述方式

“我们使用明确的变分族及普通 ELBO，或明确指出 beta 加权代理目标。报告后验坍塌诊断、重建/预测质量及对潜维数和样本数的敏感性；仅从维数不能推出通用 ELBO 收敛率。”

## 风险
- Posterior collapse：KL 项过早收敛到 0，隐变量退化为先验采样，丧失信息
- Gumbel-Softmax 的 τ 退火需要精心调度，过快导致梯度消失，过慢丧失离散性
- IWAE 多粒子在高维下 log-mean-exp 数值不稳定，需 log-sum-exp trick
- β-VAE 的 β 过大导致重构质量下降，需根据任务平衡
