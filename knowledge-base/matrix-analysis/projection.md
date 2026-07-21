# 正交投影 (Orthogonal Projection)

## 最小定义

将向量 $v$ 映射到子空间 $\mathcal{S}$ 上，使得残差 $v - Pv$ 与 $\mathcal{S}$ 正交。投影矩阵 $P$ 满足 $P^2 = P$ 且 $P = P^H$（幂等 + Hermitian），是唯一确定最近点的线性算子。

## 核心公式

- 若 $A$ 满列秩且列空间为 $\mathcal{S}$，投影矩阵为 $P = A(A^HA)^{-1}A^H$；一般情形用 Moore--Penrose 伪逆写成 $P=AA^\dagger$
- 若 $A$ 列正交归一（$A^HA = I$），则 $P = AA^H$
- 若 $Q$ 是子空间的正交基，则：$\|v-Q Q^Hv\|^2=\|v\|^2-\|Q^Hv\|^2$
- Courant-Fischer 变分刻画：$\lambda_k = \max_{\dim(S)=k} \min_{x \in S, \|x\|=1} x^HAx$
- 正交补投影：$P^\perp = I - P$

## 适用问题

- 最小二乘回归：$\hat{x} = \arg\min \|Ax - b\|^2$ 即求 $b$ 在 $\text{Col}(A)$ 上的投影
- PCA 降维：数据投影到前 $k$ 个主成分张成的子空间
- 光滑等式约束/流形优化中的可行方向：将梯度投影到切空间；一般凸约束的 projected gradient 则把更新点投影回可行集
- 残差网络的正交分解：将信号分解为已解释部分 + 残差

## AI 设计翻译

- **Linear 层的低秩瓶颈分析**：截断 SVD $W_k=U_k\Sigma_kV_k^H$ 是矩阵范数下的最佳秩-$k$ 逼近，可存为两个因子以把参数量从 $O(mn)$ 降到 $O(k(m+n))$；这不等于说 $W_k$ 本身是投影算子
- **Attention 头的子空间映射**：Q/K/V 通常只是学习到的线性映射；只有满足幂等与 Hermitian 条件时才是正交投影。多头实现仍可用 batched GEMM，但“不同头对应正交子空间”需要额外约束与验证
- **Projection Head（对比学习）**：SimCLR/MoCo 的 projection head 是 MLP；末端 $L_2$ normalization 把非零向量径向归一到单位球面，但它不是线性投影，也不是投到凸集的欧氏最近点映射
- **梯度投影 / 正交梯度下降 (OGD)**：在持续学习中，将新任务梯度投影到旧任务梯度空间的正交补，避免灾难性遗忘；需维护基矩阵 $G$ 并计算 $(I - G(G^TG)^{-1}G^T)\nabla$，核心是两次 matmul

## 工程可行性

- **主要操作**：对已有正交基 $Q\in\mathbb{R}^{n\times k}$ 应直接计算 $Q(Q^Hx)$，避免显式物化 $n\times n$ 的 $P$。若从非正交 $A$ 构造基，优先用 QR/SVD 而非显式形成 $(A^HA)^{-1}$。
- **GPU 友好度**：应用投影主要是两次 GEMV/GEMM；批量足够大时可利用 Tensor Core。小 $k$ 或单向量场景可能受内存/launch 开销限制，不能仅凭“可写成 matmul”断言高利用率。
- **复杂度**：应用投影为每向量 $O(nk)$；对 $n\times k$（$n\ge k$）矩阵做 thin QR 通常为 $O(nk^2)$。
- **低精度**：形成正规方程会把条件数平方。jitter 的大小依赖数据尺度、dtype 与容许偏差，不存在通用的 $10^{-6}$；稳定方案是以 fp32 累加并用 QR/SVD。

## 风险与失效条件

- **基矩阵病态**：当 $A$ 条件数 $\kappa(A) \gg 1$ 时，$(A^HA)^{-1}$ 在低精度下灾难性抵消。解决：先 QR 分解得正交基 $Q$，再用 $P = QQ^H$，避免显式求逆。
- **子空间维度过高**：$k$ 接近 $n$ 时投影退化为恒等映射，计算浪费。需先做随机 SVD 确认有效秩。
- **非平稳子空间**：在线学习/持续学习中投影基随数据漂移，需定期更新基矩阵（增量 QR），否则投影方向过期。
- **斜投影**：$P^2=P$ 但 $P\ne P^H$ 时不再给出欧氏最近点；其稳定性取决于像空间与核空间的夹角/条件数，不能仅用 $\|P-P^H\|_F$ 判定。需要显式监控算子范数或相关基的条件数。

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
