# KL 散度 / KL Divergence

## 最小定义
Kullback-Leibler 散度度量一个概率分布 $q$ 相对于真实分布 $p$ 的**信息损失**——即用 $q$ 编码 $p$ 时多花的平均比特数。它不是度量（不对称、不满足三角不等式），但在概率单纯形上定义了自然的"方向性距离"。

## 核心公式

**定义**：
$$D_{KL}(p \| q) = \sum_x p(x) \log \frac{p(x)}{q(x)} = \mathbb{E}_{p}\left[\log \frac{p(X)}{q(X)}\right]$$

**连续版本**：
$$D_{KL}(p \| q) = \int p(x) \log \frac{p(x)}{q(x)}\, dx$$

**基本性质**：
- $D_{KL}(p \| q) \geq 0$（Gibbs 不等式），等号当且仅当 $p = q$
- **不对称**：$D_{KL}(p \| q) \neq D_{KL}(q \| p)$，因此不是度量

**与交叉熵/熵的关系**：
$$D_{KL}(p \| q) = H(p, q) - H(p)$$

**两种方向的语义差异**：
- **前向 KL** $D_{KL}(p \| q)$：$q$ 倾向于覆盖 $p$ 的所有模式（mean-seeking）
- **反向 KL** $D_{KL}(q \| p)$：$q$ 倾向于锁定 $p$ 的某一个模式（mode-seeking）

## 适用问题
- **变分推断**：最小化反向 KL $D_{KL}(q \| p)$ 以寻找近似后验分布
- **知识蒸馏**：教师分布 $p$ 到学生分布 $q$ 的信息损失最小化
- **正则化**：约束模型分布不偏离先验太远（VAE 中的 KL 正则项）

## AI 设计翻译
- **知识蒸馏 Loss**：$\mathcal{L} = (1-\alpha) \cdot CE(y, q_s) + \alpha \cdot T^2 \cdot D_{KL}(p_t \| q_s)$，其中 $T$ 为温度参数
- **VAE 正则项**：$D_{KL}(q_\phi(z|x) \| p(z))$，通常取 $p(z) = \mathcal{N}(0, I)$，解析可算
- **PPO / RLHF**：$D_{KL}(\pi_\theta \| \pi_{\text{ref}})$ 作为策略偏离参考策略的惩罚项

## 工程可行性
- **D1[v]**：逐元素 $p \log(p/q)$ 完全向量化
- **D2[~]**：KL 本身不是 GEMM，但输入（logits）来自 GEMM 层
- **D3[v]**：$O(|\mathcal{X}|)$ 线性
- **D4[~]**：大 vocab 下需同时保留 $p$ 和 $q$ 的完整概率向量，可 chunk 计算
- **D5[v]**：log-softmax 差值在 bf16 下稳定；注意 $q \to 0$ 时 $\log q$ 发散，需 clamp
- **D8[v]**：可与 softmax 融合为 FusedKLDivLoss

## 风险与失效条件
- **$q(x)=0$ 但 $p(x)>0$ 时 KL 发散为无穷**：实践中必须对 $q$ 做 label smoothing 或温度缩放，避免零概率。反向 KL 的 mode-seeking 行为可加剧此问题——学生模型"丢弃"教师分布的低概率区域。
- **梯度方差大**：在 RL（PPO/RLHF）中，KL 估计依赖采样，高方差可导致训练不稳定。常用 clip + 线性近似 $\mathbb{E}[\log p - \log q]$ 替代精确 KL。

## 深入参考
- 蒸馏稿：`references/books/` 暂无专用信息论蒸馏稿
- Cover & Thomas. *Elements of Information Theory*, Ch. 2-3. Wiley, 2006
- Murphy. *Probabilistic Machine Learning: Advanced Topics*, Ch. 6. MIT Press, 2023
- 关联知识卡：`entropy.md`、`information-bottleneck.md`、`fisher-information.md`


## 路由扩展
- 若用于 IB 目标函数 → `information-bottleneck.md`（IB 使用 KL 定义目标）
- 若需要绝对版本 → `entropy.md`（KL 散度退化为熵）
- 若需要局部 KL 几何 → `fisher-information.md`（Fisher 信息是 KL 的局部曲率）

## 可扩展方向
- f-散度族（chi-squared, Hellinger, Jensen-Shannon, total variation）：统一的散度框架
- 逆 KL（reverse KL / mode-seeking）：变分推断中的模式搜索行为
- Bregman 散度（Bregman divergence）：凸函数生成的散度族
- 变分表示（Donsker-Varadhan, Barber-Agakov）：KL 散度的变分上/下界
- 指数族中的 KL（KL in exponential families）：充分统计量的几何
