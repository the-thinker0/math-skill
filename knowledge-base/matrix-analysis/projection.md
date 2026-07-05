# 正交投影 (Orthogonal Projection)

## 最小定义

将向量 $v$ 映射到子空间 $\mathcal{S}$ 上，使得残差 $v - Pv$ 与 $\mathcal{S}$ 正交。投影矩阵 $P$ 满足 $P^2 = P$ 且 $P = P^H$（幂等 + Hermitian），是唯一确定最近点的线性算子。

## 核心公式

- 投影矩阵：$P = A(A^HA)^{-1}A^H$，其中 $A$ 的列张成子空间 $\mathcal{S}$
- 若 $A$ 列正交归一（$A^HA = I$），则 $P = AA^H$
- 投影后最近距离：$\|v - Pv\|^2 = \|v\|^2 - \|A^Hv\|^2$
- Courant-Fischer 变分刻画：$\lambda_k = \max_{\dim(S)=k} \min_{x \in S, \|x\|=1} x^HAx$
- 正交补投影：$P^\perp = I - P$

## 适用问题

- 最小二乘回归：$\hat{x} = \arg\min \|Ax - b\|^2$ 即求 $b$ 在 $\text{Col}(A)$ 上的投影
- PCA 降维：数据投影到前 $k$ 个主成分张成的子空间
- 约束优化中的可行方向：将梯度投影到约束切空间（投影梯度法）
- 残差网络的正交分解：将信号分解为已解释部分 + 残差

## AI 设计翻译

- **Linear 层的低秩瓶颈分析**：$W = U_k \Sigma_k V_k^H$ 的截断即投影到秩-$k$ 子空间；用 `torch.mm(U_k, torch.mm(Sigma_k, V_k.t()))` 三步 matmul 实现，显存从 $O(mn)$ 降到 $O(k(m+n))$
- **Attention 头的子空间投影**：Q/K/V 矩阵本质是把输入投影到不同子空间做相似度计算；多头 = 多个投影子空间的并行，可直接 batched matmul
- **Projection Head (对比学习)**：SimCLR/MoCo 的 projection head = 多层 MLP 后接 $L_2$-normalize，等价于投影到单位球面；实现为 `F.normalize(self.mlp(x), dim=-1)`，是 elementwise norm 操作
- **梯度投影 / 正交梯度下降 (OGD)**：在持续学习中，将新任务梯度投影到旧任务梯度空间的正交补，避免灾难性遗忘；需维护基矩阵 $G$ 并计算 $(I - G(G^TG)^{-1}G^T)\nabla$，核心是两次 matmul
- **ResNet 的正交残差**：残差连接 $x + F(x)$ 可理解为在恒等子空间上的投影 + 正交修正；谱归一化约束 $F$ 的 Lipschitz 使投影稳定

## 工程可行性

- **主要操作**：矩阵乘法 (matmul) + 矩阵求逆/Cholesky。当子空间维度 $k$ 远小于 $n$ 时，$(A^HA)^{-1}$ 只需对 $k \times k$ 矩阵求逆，代价可忽略。
- **GPU 友好度**：高。$P = AA^H$（列正交情形）是两次 matmul，完美映射 tensor core。非正交情形的 Cholesky 分解有 cuSOLVER batched 实现。
- **复杂度**：投影操作 $O(nk)$ per vector（正交基情形），构造基 $O(nk^2)$（Gram-Schmidt）或 $O(n^2k)$（QR 分解）。
- **低精度**：bf16 下 $A^HA$ 可能丢正定性，需加 jitter $\epsilon I$（$\epsilon \sim 10^{-6}$）。

## 风险与失效条件

- **基矩阵病态**：当 $A$ 条件数 $\kappa(A) \gg 1$ 时，$(A^HA)^{-1}$ 在低精度下灾难性抵消。解决：先 QR 分解得正交基 $Q$，再用 $P = QQ^H$，避免显式求逆。
- **子空间维度过高**：$k$ 接近 $n$ 时投影退化为恒等映射，计算浪费。需先做随机 SVD 确认有效秩。
- **非平稳子空间**：在线学习/持续学习中投影基随数据漂移，需定期更新基矩阵（增量 QR），否则投影方向过期。
- **非正交投影**：$P^2 = P$ 但 $P \neq P^H$ 的斜投影在浮点下不稳定，应避免；若必须用，需监控 $\|P - P^H\|_F$。

## 深入参考

- 蒸馏稿：../../references/books/matrix-analysis.md（§2.1 QR 分解、§4.2 Courant-Fischer 变分刻画、§2.6 SVD）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 2 (Unitary Similarity) + Chapter 4 (Hermitian Matrices §4.2 Variational Characterizations)


## 路由扩展
- 若目标是压缩/降维 → `low-rank-approximation.md`（截断 SVD 实现）
- 若需要在流形上做投影约束 → `../optimization/riemannian-optimization.md`（黎曼流形上的约束优化）
- 若涉及共享与私有子空间分离 → `shared-private-decomposition`（设计模式层）

## 可扩展方向
- 斜投影（oblique projection）：非正交投影算子
- 交替投影（alternating projection）：Von Neumann 交替投影收敛定理
- 凸集投影（POCS）：投影到多个凸集交集的方法
- 随机投影（randomized projection）：Johnson-Lindenstrauss 引理与随机投影
- 子空间跟踪（subspace tracking）：在线更新的子空间估计方法
