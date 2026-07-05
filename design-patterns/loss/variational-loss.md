# Variational Loss（变分损失）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当需要从隐变量分布中采样并生成多样化输出时使用。典型场景：
(1) 专家选择引入离散隐变量 z，需要端到端优化；(2) 表示空间需要建模不确定性；
(3) 生成式路由中需要从后验分布 p(z|x) 采样；(4) 贝叶斯专家混合。
核心诉求：**在潜空间中建模分布而非点估计，获得不确定性感知与多样性**。

## 数学思想来源
- 透镜：../../lenses/probabilistic.md（变分推断与 ELBO）、../../lenses/probabilistic.md（后验与先验）
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
```
模块：VariationalLoss
输入：编码器输出 (μ, log_σ²) ∈ R^{B×d_z}，重构输出 x̂ ∈ R^{B×d_x}，原始输入 x

方法1 - 高斯 VAE 损失：
  KL = -0.5 * sum(1 + log_σ² - μ² - exp(log_σ²), dim=-1)   // 闭合形式
  recon = -log p(x|x̂)  // MSE 或 BCE 取决于数据分布
  L_vae = recon + β · KL    // β-VAE 控制解耦程度

方法2 - Gumbel-Softmax（离散专家选择）：
  logits = encoder(x)  ∈ R^{B×K}    // K 个专家的 logits
  g = -log(-log(uniform(B×K) + ε) + ε)   // Gumbel 噪声采样
  z_soft = softmax((logits + g) / τ)       // 温度 τ 从 1.0 退火到 0.1
  L_gumbel = CE(task_head(z_soft ⊙ features), y)  // 直通估计器反向传播

方法3 - 信息瓶颈变分：
  L_IB = I(X; Z) - β · I(Z; Y)  // 最小化 Z 对 X 的信息冗余，最大化 Z 对 Y 的预测能力
  ≈ E[-log q(y|z)] + β · KL(q(z|x) ‖ p(z))  // 变分近似（第一项为预测损失，第二项为压缩惩罚）
```

## 可实现结构
- **编码器双头输出**：Linear(d, 2·d_z) → split → (μ, log_σ²)，共享底层参数
- **β 退火策略**：β 从 0 线性增长到目标值，防止 KL 坍塌（posterior collapse）
- **Free Bits**：每个维度设定 KL 下界 λ，只惩罚超出部分：Σ max(KL_j, λ)
- **IWAE 多粒子**：用 K 个样本的 log-mean-exp 替代单样本 ELBO，获得更紧下界

## GPU 可行性
- **张量化**：μ,σ² 的计算为 Linear 层（GEMM），KL 为 element-wise 运算
- **GEMM 可映射**：编码器 1 次 GEMM → split → 重参数化 → 解码器 1 次 GEMM
- **复杂度**：与标准前向网络同阶 O(B·d²)，KL 计算 O(B·d_z) 可忽略
- **显存与 KV-Cache**：额外存储 μ, σ² 两个 B×d_z 矩阵，开销极小
- **低精度稳定**：KL 的 log/exp 运算建议 fp32；Gumbel softmax 的 log-log 需 fp32
- **并行与通信**：多粒子 IWAE 的 K 个样本可并行采样和计算
- **稀疏结构**：离散隐变量 (Gumbel) 在 τ→0 时退化为 one-hot，天然稀疏
- **算子融合**：μ 和 σ² 的 Linear 可共享一次 GEMM 后 split；KL 的 exp/sub/add 可融合

## 论文表述方式
"采用变分推断框架，将专家选择建模为离散隐变量 z 的后验推断，通过 Gumbel-Softmax
松弛实现端到端优化，配合 β 退火策略有效避免 posterior collapse，
ELBO 下界随隐变量维度以 O(√d/n) 收敛。"

## 风险
- Posterior collapse：KL 项过早收敛到 0，隐变量退化为先验采样，丧失信息
- Gumbel-Softmax 的 τ 退火需要精心调度，过快导致梯度消失，过慢丧失离散性
- IWAE 多粒子在高维下 log-mean-exp 数值不稳定，需 log-sum-exp trick
- β-VAE 的 β 过大导致重构质量下降，需根据任务平衡
