# 最优传输 (Optimal Transport)

## 最小定义

最优传输研究如何以最小总代价把一个概率分布"搬运"成另一个：给定代价函数 $c(x, y)$，在边际约束 $\pi \in \Pi(\mu, \nu)$ 下最小化 $\int c\, d\pi$。其最优值定义了分布间的 **Wasserstein 距离**——一种尊重底空间几何的分布度量，不像 KL 那样要求支撑集重叠。

## 核心公式

- **Kantorovich 松弛**：$W_c(\mu, \nu) = \min_{\pi \in \Pi(\mu, \nu)} \langle C, \pi \rangle$，$\Pi(\mu, \nu) = \{\pi \geq 0 : \pi \mathbf{1} = \mu,\ \pi^T \mathbf{1} = \nu\}$
- **Wasserstein-$p$ 距离**：$W_p(\mu, \nu) = \left(\inf_{\pi \in \Pi(\mu,\nu)} \int \|x - y\|^p d\pi\right)^{1/p}$
- **对偶形式**：$W_1(\mu, \nu) = \sup_{\|f\|_{\text{Lip}} \leq 1} \mathbb{E}_\mu[f] - \mathbb{E}_\nu[f]$（Kantorovich–Rubinstein），是 WGAN 判别器的理论来源
- **熵正则化（Sinkhorn）**：$\min_{\pi \in \Pi} \langle C, \pi \rangle - \epsilon H(\pi)$，解为 $\pi^* = \operatorname{diag}(u)\, e^{-C/\epsilon}\, \operatorname{diag}(v)$，交替行列缩放 $O(n^2)$/轮
- **位移插值（McCann）**：Wasserstein 测地线 $\mu_t = ((1-t)\,\mathrm{id} + tT)_\# \mu$，分布间的"直线"是逐粒子匀速运动

## 适用问题

- **分布对齐与匹配**：域适应、多模态对齐、模型合并——需要一个尊重几何的分布距离
- **全局最优分配**：MoE 路由、batch 分配、特征匹配——边际约束天然表达容量/负载均衡
- **生成模型**：WGAN 的 Lipschitz 判别器、Sinkhorn 散度做分布匹配损失
- **点集比较**：两组 embedding / 点云之间的软对应（soft assignment）

## AI 设计翻译

- **Sinkhorn 路由层**：MoE 中把 token→专家分配建模为熵正则 OT，代价矩阵 $C = -S$（负相似度），专家容量作为边际约束；实现为 $K$ 轮交替行/列归一化（log-domain 稳定版），全程 matmul + softmax 类操作
- **Wasserstein 梯度流**：把训练看作分布在 Wasserstein 几何下的梯度下降（如 Mean-field Langevin 动力学），给出全局收敛分析的框架
- **分布匹配损失**：用 Sinkhorn 散度 $S_\epsilon(\mu, \nu) = W_\epsilon(\mu,\nu) - \frac{1}{2}W_\epsilon(\mu,\mu) - \frac{1}{2}W_\epsilon(\nu,\nu)$ 替代 MMD/KL 做生成模型或蒸馏损失
- **批次级最优分配**：对比学习/聚类中把样本→原型分配换成 Sinkhorn 平衡分配（SwAV 范式），避免塌缩到单一原型

## 工程可行性

- **主要操作**：Sinkhorn = 迭代 matmul（$e^{-C/\epsilon}$ 与向量交替相乘）+ 行/列归一化；代价矩阵 $C$ 本身是 $n \times m$ 的成对距离
- **GPU 友好度**：中高。Sinkhorn 迭代全张量化；但代价矩阵 $O(nm)$ 显存，大 $n$ 需分块或低秩近似
- **复杂度**：每轮 Sinkhorn $O(nm)$，轮数随 $\epsilon$ 减小而增加（典型 20–100 轮）；精确 LP 求解 $O(n^3)$ 不可扩展
- **低精度**：log-domain Sinkhorn 在 fp32 下稳定；$\epsilon$ 小时 kernel $e^{-C/\epsilon}$ 下溢，必须 log-space 实现

## 风险与失效条件

- **$\epsilon$ 的偏差-计算权衡**：$\epsilon$ 大则快但偏离真实 OT（熵偏差）；$\epsilon$ 小则迭代慢且数值不稳。Sinkhorn 散度可去偏差但不等于真实 $W$
- **样本复杂度灾难**：$W_p$ 的经验估计误差随维度指数恶化（$n^{-1/d}$），高维下迷你批次估计的系统性偏差不可忽略
- **不平衡/部分传输**：标准 OT 要求两边总质量相等；实际数据常有离群点，需用 unbalanced OT（KL 松弛边际）或 partial OT
- **WGAN 的 Lipschitz 约束只是对偶的近似**：weight clipping / gradient penalty 都是 1-Lipschitz 约束的启发式实现，不等于精确对偶

## 深入参考

- 蒸馏稿：`../../references/books/optimization-ml.md`（对偶与凸优化基础；OT 专门理论超出该书范围）
- Peyré & Cuturi. *Computational Optimal Transport*. NOW, 2019（Sinkhorn 与数值方法的标准参考）
- Villani. *Optimal Transport: Old and New*. Springer, 2009（理论全书）
- Santambrogio. *Optimal Transport for Applied Mathematicians*. Birkhäuser, 2015

## 路由扩展

- 若需要对偶理论 → `../optimization/lagrangian-duality.md`（Kantorovich 对偶是 LP 对偶）
- 若需要熵正则的理解 → `entropy.md`（$-\epsilon H(\pi)$ 项的作用）
- 若需要分布散度对比 → `kl-divergence.md`（KL vs Wasserstein 的支撑集/几何差异）
- 若用于路由设计 → `../../design-patterns/routing/optimal-transport-routing.md`（MoE 的 OT 路由原型）

## 可扩展方向

- 非平衡最优传输（unbalanced OT）：质量不守恒的松弛（HK 距离）
- Gromov–Wasserstein：无共同底空间的分布/图比较
- Wasserstein 梯度流（JKO 格式）：分布空间上的优化与 PDE
-  sliced Wasserstein：一维投影的快速近似，$O(n \log n)$
- OT 重心（Wasserstein barycenter）：多分布的平均与集成
