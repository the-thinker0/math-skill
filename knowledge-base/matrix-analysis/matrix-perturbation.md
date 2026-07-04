# 矩阵扰动 (Matrix Perturbation Theory)

## 最小定义

研究矩阵 $A$ 在受到小扰动 $E$ 后，其特征值、奇异值、特征子空间如何变化。核心结论：Hermitian 矩阵的特征值对扰动是 Lipschitz 连续的（Weyl 界），而特征向量/子空间的稳定性由特征值间隙（eigengap）决定。

## 核心公式

- **Weyl 特征值扰动界**（Hermitian）：$|\lambda_i(A+E) - \lambda_i(A)| \leq \|E\|_2$
- **Bauer-Fike 定理**（可对角化矩阵）：$\min_j |\lambda_i(A+E) - \lambda_j(A)| \leq \kappa(V) \|E\|_2$，$V$ 为特征向量矩阵
- **Davis-Kahan $\sin\Theta$ 定理**：$\|\sin\Theta(\hat{U}, U)\|_2 \leq \frac{\|E\|_2}{\delta}$，$\delta$ 为子空间与其余谱的间隙
- **奇异值扰动 (Mirsky)**：$|\sigma_i(A+E) - \sigma_i(A)| \leq \|E\|_2$
- **Ger\v{s}gorin 圆盘**：$\lambda_i(A) \in \bigcup_j \{z : |z - a_{jj}| \leq \sum_{k \neq j} |a_{jk}|\}$
- **条件数与相对误差**：$\frac{|\delta x|}{|x|} \leq \kappa(A) \frac{\|\delta A\|}{\|A\|}$

## 适用问题

- 量化/低精度训练的谱漂移分析：bf16/fp8 下权重矩阵的奇异值偏移多少？
- 模型剪枝/蒸馏的误差界：删掉 $k$ 个参数后谱变化有多大？
- LoRA 近似误差：$\|W - W_0 - BA\|_2$ 的扰动如何影响下游输出？
- 训练稳定性证书：梯度噪声 $\|E\|_2 \leq \epsilon$ 时特征值漂移不超过 $\epsilon$
- 数值诊断：不跑完整 EVD，用 Ger\v{s}gorin 圆盘廉价估计谱位置

## AI 设计翻译

- **Ger\v{s}gorin 廉价谱半径监控**：训练循环中每 $N$ 步计算 $\rho_{\text{est}} = \max_j (|a_{jj}| + \sum_{k\neq j}|a_{jk}|)$ 作为谱半径上界，仅 $O(n^2)$ 逐行求绝对值和。实现为 `torch.sum(torch.abs(A), dim=1)`，是 elementwise + reduce，极廉价，可嵌入训练 loop 做稳定性 gate。
- **量化误差的谱漂移界**：$W_{\text{quant}} = W + E$，$\|E\|_2 \leq \epsilon$，由 Weyl 定理 $\sigma_i$ 偏移 $\leq \epsilon$。对 $L$ 层网络，输出扰动 $\leq \prod_i (\sigma_1(W_i) + \epsilon) - \prod_i \sigma_1(W_i)$。指导量化精度选择：若 $\sigma_{\min}(W)$ 接近 $\epsilon$，则该层需更高精度。
- **Davis-Kahan 子空间稳定性**：PCA/LoRA 中子空间的可靠性由 eigengap $\delta = \lambda_k - \lambda_{k+1}$ 决定。$\delta$ 越大，截断子空间越稳定；$\delta \to 0$ 时子空间对噪声极度敏感。可作为选择 LoRA rank $r$ 的诊断工具：选 $\delta_r$ 最大的 $r$。
- **剪枝的扰动建模**：非结构化剪枝 = 稀疏扰动 $E$，$\|E\|_2 \leq \|E\|_F = \sqrt{\sum e_{ij}^2}$。Weyl 界给出谱漂移上界，指导剪枝比例：保持 $\|E\|_2 / \sigma_1(W) < \tau$（如 $\tau = 0.05$）。
- **谱正则化作为鲁棒性证书**：$\mathcal{L}_{\text{robust}} = \mathcal{L}_{\text{task}} + \lambda \max(0, \|E\|_2 - \epsilon)^2$，约束扰动下的谱漂移。结合 power iteration 估计 $\|E\|_2$，实现为附加 loss 项。

## 工程可行性

- **主要操作**：Ger\v{s}gorin = elementwise abs + row-sum（$O(n^2)$）；Weyl 界只需 $\|E\|_2$（power iteration $O(n^2)$/step）；Davis-Kahan 需 eigengap（需部分 EVD，$O(n^2 k)$）。
- **GPU 友好度**：高。Ger\v{s}gorin 是纯 elementwise + reduce；$\|E\|_2$ 估计是 matvec 链；eigengap 用 Lanczos 算法（matmul + tridiag EVD）。所有操作均可 batch。
- **复杂度**：Ger\v{s}gorin $O(n^2)$；单次 power iteration $O(n^2)$；Lanczos $k$ 步 $O(kn^2)$；完整 EVD $O(n^3)$（应避免）。
- **低精度**：Weyl 界本身是 Lipschitz 的，低精度下扰动 $\|E\|_2$ 的估计有 $\sim \sqrt{n} \cdot \text{eps}$ 的浮点噪声，通常可忽略。

## 风险与失效条件

- **非正规矩阵的 Bauer-Fike 放大**：$\kappa(V)$ 可能极大（非正规矩阵的特征向量矩阵条件数高），Weyl 界不再适用，扰动被放大 $\kappa(V)$ 倍。解决：改用 SVD 奇异值（Mirsky 界不依赖正规性），或用 pseudospectra 分析。
- **Ger\v{s}gorin 过松**：圆盘并集可能远大于实际谱范围（尤其对稀疏矩阵），给出过于保守的界。解决：先做对角相似变换 $D^{-1}AD$ 压缩圆盘（Osborne 平衡），或结合稀疏结构修正。
- **Davis-Kahan 的间隙假设**：$\delta \to 0$ 时界退化为 $\infty$（子空间不可辨识），此时低秩逼近本身不唯一。需先检测 eigengap，确认子空间良定义。
- **Weyl 界对非 Hermitian 部分不直接适用**：$A + A^H$ 的扰动界不直接给出 $A$ 本身的特征值扰动。对非对称矩阵需回到 Bauer-Fike 或 pseudospectra。

## 深入参考

- 蒸馏稿：references/books/matrix-analysis.md（§4.3 特征值不等式 Weyl/交错、§6.1-6.3 Ger\v{s}gorin 圆盘与扰动定理、§5.8 条件数）
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., Chapter 4 §4.3 (Eigenvalue Inequalities) + Chapter 6 (Location and Perturbation of Eigenvalues §6.1-6.3)
