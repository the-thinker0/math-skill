# Leverage Score Selection（杠杆分数选择）

## 适用问题
当需要从大规模矩阵中选取最有代表性的行/列/token，且需保证下游线性代数运算精度时使用：KV-Cache token 选择、数据 coreset 构建、Nyström landmark 采样、分布式梯度压缩。核心诉求：**基于子空间投影的统计杠杆分数做采样，以概率保证逼近全量计算精度**。

## 数学思想来源
- 透镜：lenses/spectral.md（杠杆分数 = 行向量在主子空间上的投影能量）、lenses/probabilistic.md（概率采样与浓度不等式保证）、lenses/algorithmic.md（随机化算法的复杂度与精度权衡）
- 知识：knowledge-base/matrix-analysis/low-rank-approximation.md（随机化 SVD、核范数）、knowledge-base/matrix-analysis/projection.md（投影矩阵对角元 = 杠杆分数）、knowledge-base/probability/concentration-inequality.md（Bernstein 矩阵浓度界）

## 需要的数学知识
- **统计杠杆分数**：$\ell_i = \|(V_k V_k^T)_i\|^2 = (V_k V_k^T)_{ii}$，第 $i$ 行在 rank-$k$ 子空间的投影能量；$\sum_i \ell_i = k$
- **杠杆分数采样保证**：以 $p_i = \ell_i / k$ 采样 $s = O(k \log k / \epsilon^2)$ 行，$(1+\epsilon)$ 近似全量最小二乘（Drineas-Mahoney）
- **Bernstein 矩阵界**：采样后 $\|\hat{A}^T \hat{A} - A^T A\|_2 \leq \epsilon \|A\|_F^2$，概率 $\geq 1-\delta$
- **快速近似**：$\tilde{\ell}_i = \|(A\Omega)_i\|^2$（$\Omega$ 随机高斯），避免完整 SVD，$O(Ndk)$
- **DPP 扩展**：行列式点过程 $P(S) \propto \det(L_S)$ 在杠杆分数基础上增加多样性保证

## AI 模块形式
```
模块：LeverageScoreSelector
输入：A ∈ R^{N×d}    参数：采样数 s << N，秩参数 k

方法1 - 随机投影杠杆分数（在线/大规模）：
  Omega = randn(d, k+p)                       // 随机矩阵，p=5 过采样
  Q = qr(A @ Omega)[0]                        // N×(k+p)，GEMM + QR
  leverage = sum(Q ** 2, dim=1)               // N 维，逐行平方和
  indices = topk(leverage, s)                 // 确定性选 top-s
  A_selected = A[indices]

方法2 - 精确杠杆分数（离线/小矩阵）：
  U_k = svd(A)[:k][0]                         // 截断 SVD 左奇异向量
  leverage = sum(U_k ** 2, dim=1)             // 精确 rank-k 杠杆分数
  probs = leverage / leverage.sum()
  indices = multinomial_sample(N, s, probs)    // 概率采样 + 重加权
  weights = 1 / sqrt(s * probs[indices])

方法3 - KV-Cache 滑动窗口驱逐：
  每 M 步更新 Q = qr(K_cache @ Omega)[0]
  leverage = sum(Q ** 2, dim=1)
  驱逐 leverage 最低的 token（对子空间贡献最小）

方法4 - DPP 贪心多样化选择：
  scores = leverage.clone(); L = A @ A^T       // PSD 核矩阵
  for _ in range(s):
    idx = argmax(scores); selected.append(idx)
    scores -= α * |L[:, idx]|                   // 惩罚已选 token 的邻居
```

## 可实现结构
- **随机投影杠杆层**：1 次 GEMM + 1 次 QR 即得近似杠杆分数，$O(Ndk)$
- **KV-Cache 驱逐策略**：按杠杆分数排序驱逐，比 attention score 驱逐更有理论保证
- **Coreset 构建器**：杠杆分数采样 + 重要性重加权，保证经验风险逼近全量
- **DPP 贪心扩展**：杠杆分数 + 互斥惩罚，兼顾重要性与多样性

## GPU 可行性
- 张量化/GEMM：$A\Omega$ 为 GEMM；QR 有 cuSOLVER；杠杆分数 = elementwise 逐行平方和
- 复杂度：$O(Ndk)$ 远优于 $O(Nd^2)$ 完整 SVD；top-s 选择 $O(N \log s)$
- 显存：$\Omega$ 仅 $d \times k$（KB 级）；$Q$ 与 $A$ 同尺寸但可分批计算
- 低精度：QR 建议 fp32（小矩阵 $k+p$ 列，开销可忽略）；杠杆分数可回 bf16
- 并行：$A\Omega$ 的 GEMM 高度并行；top-s 可用 radix sort 并行
- 算子融合：$A\Omega$ + QR + row-norm² 可融合避免物化中间矩阵

## 论文表述方式
"采用统计杠杆分数作为 token 选择的重要性度量：通过随机投影在 $O(Ndk)$ 内近似 rank-$k$ 子空间杠杆分数，Drineas-Mahoney 理论保证 $O(k \log k / \epsilon^2)$ 次采样即可 $(1+\epsilon)$ 近似全量子空间。"

## 风险
- **秩参数 $k$ 选择**：杠杆分数依赖 rank-$k$ 子空间，$k$ 选错导致采样偏差；需先诊断有效秩
- **采样方差**：概率采样引入方差，低概率行偶尔被选中产生大权重噪声；可改用确定性 top-s
- **杠杆分数 vs. 语义重要性不一致**：度量的是子空间贡献，不一定反映语义；可与 attention score 加权融合
- **DPP 贪心次优**：精确 DPP 采样 $O(N^3)$，贪心近似可能漏掉全局最优子集
- **动态数据过时**：streaming 场景下杠杆分数随数据漂移，需定期重算或增量更新
