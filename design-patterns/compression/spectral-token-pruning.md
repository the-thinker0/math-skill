# Spectral Token Pruning（谱 Token 剪枝）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当需要基于 token 的结构性重要性（而非单纯 attention score）进行剪枝时使用：KV-Cache 驱逐、长文档摘要、推理加速（降低 $O(L^2)$）、多模态视觉 token 压缩。核心诉求：**用谱方法量化每个 token 的结构性重要性，实现信息损失最小的剪枝**。

## 数学思想来源
- 透镜：../../lenses/spectral.md（识别主导谱分量、丢弃冗余分量）、../../lenses/algorithmic.md（复杂度分类与近似算法）、../../lenses/perturbation.md（剪枝 = 稀疏扰动，Cauchy 交错定理 / Bauer-Fike 伪谱分析界定谱漂移）
- 知识：../../knowledge-base/matrix-analysis/spectral-decomposition.md（谱半径、特征向量中心性）、../../knowledge-base/matrix-analysis/matrix-perturbation.md（Geršgorin 圆盘、扰动界）、../../knowledge-base/matrix-analysis/positive-semidefinite.md（Gram 矩阵 PSD 结构）

## 需要的数学知识
- **特征向量中心性**：对未 mask、正且不可约的行随机（行 softmax）attention 矩阵 $A$，右主特征向量 $Ax = \lambda_1 x$ 退化为全 1 向量（因 $A \mathbf{1} = \mathbf{1}$），无法区分 token 重要性；可使用左主特征向量 $x^T A = \lambda_1 x^T$（等价于 $A^T x = \lambda_1 x$）作为平稳分布/PageRank 式重要性。对 causal 或强 mask attention，链通常非不可约，平稳分布可能偏向早期 token；应改用 K/V 相似度图、对称化图，或加入 teleportation $A_\alpha=\alpha A+(1-\alpha)\mathbf{1}\pi^T$ 后再解释 PageRank。
- **谱间隙**：$\Delta = \lambda_1 - \lambda_2$ 决定信息扩散速度，$\Delta$ 大 $\Rightarrow$ 少数 token 主导 $\Rightarrow$ 安全剪枝
- **Fiedler 向量**：Laplacian $L_{\text{sym}}$ 的第二小特征向量给出最优二分割，幅值小 = 分割边界 = 重要
- **谱扰动分析**：剪枝改变矩阵维度，不能直接套用 Weyl 定理。对固定 Hermitian 矩阵的主子矩阵（如不重新归一化的对称化矩阵 $S=(A+A^T)/2$），可用 Cauchy 交错定理界定特征值交错；若剪枝后重新归一化 Laplacian/attention graph，矩阵本身已改变，不能直接套该界。对非对称行随机矩阵，谱半径扰动可用 Bauer-Fike 或伪谱分析，但界不如 Hermitian 情形紧凑。

## AI 模块形式
```
模块：SpectralTokenPruner
输入：K ∈ R^{L×d}    参数：保留比例 ρ ∈ (0,1]

方法1 - 谱中心性剪枝（幂迭代，左特征向量）：
  A = softmax(K @ K^T / √d)                  // L×L 行随机相似度图；causal/mask 场景需另行处理
  // ⚠ A 为行随机矩阵，右主特征向量 = 全 1 向量（退化），必须用左主特征向量
  // 左主特征向量 = A^T 的右主特征向量；仅在链不可约/加 teleportation 后可稳定解释为 PageRank
  v = ones(L) / √L
  for t in range(5): v = A^T @ v; v = v / ‖v‖  // 幂迭代 A^T（非 A），O(L²·T)
  indices = topk(v, ceil(ρ * L))              // 保留左特征向量中心性最高的 token

方法2 - Geršgorin 廉价剪枝（零迭代）：
  S = K @ K^T / √d                         // L×L 原始相似度矩阵（非 softmax，行使行和有区分度）
  gersh_score = sum(|S|, dim=1) - |diag(S)|  // Geršgorin 圆盘半径 R_i = Σ_{j≠i}|S_{ij}|，衡量连通度
  indices = topk(gersh_score, ceil(ρ * L))    // O(L²) elementwise，无需幂迭代

方法3 - 可微谱剪枝（端到端）：
  v = power_iteration(A^T, T=5)               // 左主特征向量（A^T 的幂迭代）
  gate = sigmoid(v @ W_gate / τ)               // 软门控，τ 退火
  K_gated = gate * K                            // 逐 token 缩放
  L_sparse = ‖gate‖_1 / L                       // 稀疏正则
```

## 可实现结构
- **幂迭代中心性**：5 步 matvec 估计 $A^T$ 的主特征向量（即 $A$ 的左主特征向量 / 平稳分布），$O(L^2 \cdot 5)$，适合中等序列
- **采样近似**：$L > 4096$ 时采样 $m$ 个锚点，构造 $m \times m$ 子矩阵做谱分析
- **多头融合**：不同头的 attention 图取平均后再做谱分析
- **渐进式剪枝**：逐层递增剪枝比例（浅层少剪、深层多剪）

## GPU 可行性
- 张量化/GEMM：$A = KK^T$ 为 GEMM；幂迭代为 matvec 链；Geršgorin 为 elementwise
- 复杂度：幂迭代 $O(L^2 T)$，$T \leq 10$；Geršgorin $O(L^2)$ elementwise，零迭代
- 显存：$L \times L$ 相似度矩阵在 $L > 8K$ 时超 256MB，需分块或采样
- 低精度：幂迭代在 bf16 下稳定（归一化防溢出）；Geršgorin 纯 elementwise 无精度问题
- 并行：多头/多层谱分析独立并行；matvec 高度并行
- 算子融合：$KK^T$ + row-sum + topk 可融合为单一 kernel

## 论文表述方式
"将 token 剪枝建模为有向图的谱稀疏化：在未 mask 且不可约的行随机图上，利用左主特征向量/PageRank 式中心性量化全局重要性；对 causal 或强 mask attention，则改用 K/V 相似度图、对称化图或 teleportation 后的 PageRank，避免平稳分布退化到早期 token。对固定 Hermitian 子矩阵可用 Cauchy 交错分析谱漂移；重新归一化或非对称图则需改用伪谱、Bauer-Fike 或 Geršgorin 圆盘等更弱但适用的扰动诊断。"

## 风险
- **$L \times L$ 矩阵显存瓶颈**：长序列下相似度矩阵本身可能超出显存，必须采样或分块
- **幂迭代收敛慢**：$\lambda_1 / \lambda_2 \approx 1$ 时需 $O(1/\Delta)$ 步，效率下降
- **语义 ≠ 谱重要性**：某些 token（如标点）谱中心性低但语义关键，纯谱方法可能误剪
- **硬剪枝不可微**：top-k 阻断梯度，端到端训练需 softmax 松弛或 Gumbel-topk
