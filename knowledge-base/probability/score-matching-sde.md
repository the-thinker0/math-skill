# 分数匹配与随机微分方程 (Score Matching & SDE)

## 最小定义

分数（score）是对数密度的梯度 $\nabla_x \log p(x)$——不知道归一化常数也能定义。分数匹配通过回归分数来学习未归一化的分布；扩散模型把它升级为**随噪声尺度变化的分数族** $s_\theta(x, t) \approx \nabla_x \log p_t(x)$，前向 SDE 加噪、反向 SDE（或概率流 ODE）沿分数去噪生成样本。

## 核心公式

- **分数**：$s(x) = \nabla_x \log p(x)$，与归一化常数无关
- **Fisher 散度（分数匹配目标）**：$J(\theta) = \frac{1}{2}\mathbb{E}_{p}\|s_\theta(x) - \nabla_x \log p(x)\|^2$
- **分部积分消去真分数**（Hyvärinen）：$J(\theta) = \mathbb{E}_{p}\left[\operatorname{tr}(\nabla_x s_\theta) + \frac{1}{2}\|s_\theta\|^2\right] + \text{const}$，只含模型量
- **去噪分数匹配（DSM）**：$\mathbb{E}_{p(x)}\mathbb{E}_{q_\sigma(\tilde{x}|x)}\|s_\theta(\tilde{x}) - \nabla_{\tilde{x}} \log q_\sigma(\tilde{x}|x)\|^2$，高斯核下 $\nabla_{\tilde{x}} \log q_\sigma = -( \tilde{x} - x)/\sigma^2$，即"预测噪声"
- **前向 SDE**：$dx = f(x, t)dt + g(t)dw$；**反向 SDE**（Anderson）：$dx = [f - g^2 \nabla_x \log p_t(x)]dt + g\, d\bar{w}$——知道分数即可反演时间
- **概率流 ODE**：$dx = [f - \frac{1}{2}g^2 \nabla_x \log p_t(x)]dt$，与 SDE 共享边际分布，可确定性采样
- **Tweedie 公式**：$\mathbb{E}[x_0 | x_t] = (x_t + \sigma_t^2\, s(x_t, t))/\alpha_t$——分数给出一步去噪后验均值

## 适用问题

- **生成建模**：图像/音频/分子生成的主流通路（DDPM、score SDE、flow matching 一族）
- **未归一化分布的学习**：能量模型（EBM）避开配分函数；Langevin 采样只需分数
- **逆问题求解**：后验采样 $p(x|y) \propto p(y|x)p(x)$ 中先验分数由扩散模型提供，似然项单独处理
- **密度比与 KL 估计**：分数差给出对数密度比的梯度

## AI 设计翻译

- **扩散模型训练**：DSM 目标 = 预测注入的噪声 $\epsilon$（等价于预测分数，差一个 $-\sigma_t$ 因子）；损失 $\|\epsilon_\theta(x_t, t) - \epsilon\|^2$ 是简单的 MSE，网络用 UNet/DiT
- **采样器设计**：反向 SDE（随机、步数多、质量高）vs 概率流 ODE（确定性、可用高阶 ODE 求解器加速到 10–20 步）；DDIM 是 ODE 的一阶离散化
- **Flow matching / 整流**：直接回归连接噪声与数据的插值路径的速度场，训练目标与 DSM 同构但路径更直，采样步数更少
- **引导（guidance）**：classifier-free guidance 把条件分数写成 $\tilde{s} = s_{\text{uncond}} + w(s_{\text{cond}} - s_{\text{uncond}})$，$w > 1$ 增强条件一致性但损失多样性

## 工程可行性

- **主要操作**：训练 = 一次前向（预测噪声/分数），与常规监督学习同构；采样 = 多步网络评估（10–1000 步），是推理成本主体
- **GPU 友好度**：训练极高（纯回归）；推理取决于步数——每步是一次完整前向，可用 ODE 求解器/蒸馏/一致性模型压缩步数
- **复杂度**：训练 $O(\text{forward})$；采样 $O(K \times \text{forward})$，$K$ 为步数；无对抗训练的稳定性问题
- **低精度**：分数回归对数值误差不敏感，bf16 训练成熟；但长步数采样的误差累积建议关键步 fp32

## 风险与失效条件

- **低噪声区分数爆炸**：$\sigma \to 0$ 时分数方差发散，DSM 目标被小噪声项主导；实践用噪声加权损失（如 $\lambda(t)$ 加权）或截断最小噪声
- **分数只定义在支撑集上**：数据在低维流形上时分数在流形外无定义——这正是必须加噪的原因；外推区域的分数行为决定采样轨迹
- **反向 SDE 的时间离散化误差**：大步长下离散反向 SDE 不再匹配前向边际；ODE 求解器阶数与步数需联合调
- **guidance 不是免费的**：$w$ 大则条件性强但分布锐化、多样性下降，且严格说不再是任何良定义分布的采样
- **与对抗样本的联系**：分数在像素空间的微小变化可导致生成内容大改，下游安全分析不能只测干净输入

## 深入参考

- 蒸馏稿：`../../references/books/` 暂无 SDE 专用蒸馏稿
- Song et al. "Score-Based Generative Modeling through Stochastic Differential Equations." *ICLR*, 2021
- Hyvärinen. "Estimation of non-normalized statistical models by score matching." *JMLR*, 2005
- Vincent. "A Connection Between Score Matching and Denoising Autoencoders." *Neural Computation*, 2011 (DSM)
- Karras et al. "Elucidating the Design Space of Diffusion-Based Generative Models." *NeurIPS*, 2022

## 路由扩展

- 若需要分布散度 → `kl-divergence.md`（Fisher 散度 vs KL 的对称性差）
- 若需要 Langevin 的收敛 → `concentration-inequality.md`（对数 Sobolev 与混合时间）
- 若需要插值路径的几何 → `optimal-transport.md`（flow matching 与位移插值的联系）
- 若需要能量模型 → `../information-geometry/fisher-metric.md`（分数与 Fisher 度量的关系）

## 可扩展方向

- Langevin 动力学（ULA / MALA）：分数驱动的 MCMC 采样及其混合时间
- 扩散桥（Schrödinger bridge）：两端分布都给定的最优扩散
- 一致性模型（consistency models）：把多步采样蒸馏为单步
- 分数恒等式（score identities）：Tweedie、二阶分数与 Hessian 的联系
- 离散扩散（discrete diffusion）：离散状态空间上的分数类比（似然比）
