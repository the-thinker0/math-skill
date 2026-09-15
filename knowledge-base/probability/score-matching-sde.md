# 分数匹配与随机微分方程 (Score Matching & SDE)

## 最小定义

分数（score）是对数密度的梯度 $\nabla_x \log p(x)$——不知道归一化常数也能定义。分数匹配通过回归分数来学习未归一化的分布；扩散模型把它升级为**随噪声尺度变化的分数族** $s_\theta(x, t) \approx \nabla_x \log p_t(x)$，前向 SDE 加噪、反向 SDE（或概率流 ODE）沿分数去噪生成样本。

**范围与符号**：分部积分要求密度/score 可微且边界项消失。下式逆 SDE 从 $T$ 向0运行（$dt<0$），扩散系数是与状态无关的标量 $g(t)$；状态依赖扩散需额外散度项。Tweedie 式使用 $x_t=\alpha_t x_0+\sigma_t\varepsilon$、$\varepsilon\sim N(0,I)$、$\alpha_t\ne0$。SDE/ODE 边缘相同要求精确 score 及正则条件；学习误差与数值求解会破坏精确相等。[score-SDE 原论文](https://arxiv.org/abs/2011.13456)。

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
- **采样器设计**：在匹配网络评估次数与容差下比较逆 SDE 和概率流 ODE 离散化。确定性采样器不因定义就少步或高质；DDIM 与 ODE 的联系需具体参数化和时间表。
- **Flow matching / rectified flow**：对指定插值路径回归条件速度。与 score matching 的联系依赖路径和参数化；路径更直和更少评估次数不是自动保证。
- **引导（guidance）**：classifier-free guidance 把条件分数写成 $\tilde{s} = s_{\text{uncond}} + w(s_{\text{cond}} - s_{\text{uncond}})$，$w > 1$ 增强条件一致性但损失多样性

## 工程可行性

- **主要操作**：训练 = 一次前向（预测噪声/分数），与常规监督学习同构；采样 = 多步网络评估（10–1000 步），是推理成本主体
- **低精度**：score 误差依赖噪声尺度、损失权重及条件数。比较整个轨迹的精度影响；敏感求解状态/归约用 fp32，不假设 score 回归对误差不敏感。
- **复杂度**：训练 $O(\text{forward})$；采样 $O(K \times \text{forward})$，$K$ 为步数；无对抗训练的稳定性问题
- **低精度**：分数回归对数值误差不敏感，bf16 训练成熟；但长步数采样的误差累积建议关键步 fp32

## 风险与失效条件

- **低噪声区分数爆炸**：$\sigma \to 0$ 时分数方差发散，DSM 目标被小噪声项主导；实践用噪声加权损失（如 $\lambda(t)$ 加权）或截断最小噪声
- **引导**：适定的引导 SDE/ODE 仍定义输出分布。任意引导未必采到所需条件分布或时间一致的温度化密度；比较质量、多样性及引导引起的数值误差。
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
