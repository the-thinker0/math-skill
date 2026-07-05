# Subspace Alignment（子空间对齐）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当两个或多个表示空间需要对齐到共同的子空间时使用。典型场景：
(1) 多模态对齐——将文本和图像的表示对齐到共享语义子空间；
(2) 跨层对齐——将浅层特征对齐到深层特征的子空间，便于残差连接或蒸馏；
(3) 专家输出对齐——不同专家的输出维度/分布不同，需要对齐后融合；
(4) 领域适配——源域和目标域的特征分布不同，需要对齐子空间。
核心诉求：**找到两个空间之间的最优线性/非线性映射，使对应语义对齐**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（Grassmann 流形、主角度）、../../lenses/variational.md（Procrustes 问题）
- 知识：../../knowledge-base/matrix-analysis/projection.md（SVD、正交 Procrustes）、
  ../../knowledge-base/differential-geometry/manifold.md（Grassmann 距离、测地线）

## 需要的数学知识
- **正交 Procrustes 问题**：min_{W∈O(d)} ‖AW - B‖_F²
  闭合解：W* = UV^T，其中 USV^T = SVD(A^T B)
- **CCA (典型相关分析)**：max_W₁,W₂ tr(W₁^T Σ_XY W₂) s.t. W₁^T Σ_XX W₁ = I
  解为广义特征值问题或 SVD(Σ_XX^{-1/2} Σ_XY Σ_YY^{-1/2})
- **Grassmann 流形上的距离**：Gr(d, r) = {r 维子空间 ⊂ R^d}
  两点（子空间）的距离由主角度 θ_i 决定：d_G(U,V) = √(Σ θ_i²)
  cos(θ_i) = σ_i(U^T V)（U^T V 的奇异值）
- **子空间追踪 (Subspace Tracking)**：在线更新子空间基
  Oja 规则：W_{t+1} = W_t + η(x_t x_t^T W_t - W_t diag(W_t^T x_t x_t^T W_t))

## AI 模块形式
```
模块：SubspaceAligner
输入：源表示 A ∈ R^{N×d_a}，目标表示 B ∈ R^{N×d_b}（配对数据）

方法1 - 线性 Procrustes 对齐（最常用）：
  // 找最优线性变换 W 使 A@W ≈ B
  M = A^T @ B                       // d_a × d_b，一次 GEMM
  U, S, V^T = SVD(M)                // 奇异值分解
  W* = U @ V^T                      // d_a × d_b 最优正交变换
  // 可微版本：将 W 参数化为 nn.Parameter，用 SGD 优化
  L_align = ‖A @ W - B‖_F² / N     // 对齐损失

方法2 - 深度 CCA（非线性子空间对齐）：
  f_A = MLP_A(A)                    // R^{d_a} → R^r（非线性投影）
  f_B = MLP_B(B)                    // R^{d_b} → R^r
  Σ_AA = f_A^T @ f_A / N + λI       // r×r 自协方差
  Σ_BB = f_B^T @ f_B / N + λI
  Σ_AB = f_A^T @ f_B / N            // r×r 互协方差
  T = Σ_AA^{-1/2} @ Σ_AB @ Σ_BB^{-1/2}  // 白化互相关
  L_cca = -tr(SVD(T).S[:k])         // 最大化前 k 个典型相关的和
  // 等效于最小化 Grassmann 距离

方法3 - 子空间角度正则（多专家输出对齐）：
  // 多个专家的输出应对齐到同一子空间
  U_k = SVD(expert_k_output)[0][:, :r]  // 各专家输出的 r 维主成分
  for i, j in expert_pairs:
    cos_angles = SVD(U_i^T @ U_j).S    // 主角度的余弦
    L_subspace = -mean(cos_angles)       // 最大化主角度余弦 → 最小化角度
  // 或使用 Grassmann 距离：
  L_grass = sum(angles²)                 // angles = arccos(cos_angles)

在线子空间追踪（推理时适配）：
  // 测试时新样本到来，增量更新对齐矩阵
  W_new = W_old + η · (x_new @ (y_new^T - x_new^T @ W_old))  // Oja-like
  // 无需重新 SVD，O(d²) 在线更新
```

## 可实现结构
- **对齐层 (AlignmentLayer)**：nn.Linear(d_a, d_b, bias=False) 初始化为 Procrustes 解
- **白化层**：用 running mean/variance 做在线白化，避免每步计算 Σ^{-1/2}
- **CCA 替代方案**：用 Barlow Twins 式的冗余减少损失替代 CCA（避免矩阵逆）
  L_BT = ‖C - I‖_F² 其中 C = corr(f_A, f_B)
- **分块 SVD**：大规模时用 randomized SVD 近似，精度足够且更快

## GPU 可行性
- **D1[v]**：A^T@B 为标准 GEMM (d×N)@(N×d)；SVD 有 cuSOLVER 实现
- **D2[v]**：Procrustes 核心 1 次 GEMM + 1 次 SVD；CCA 2 次 GEMM + 1 次 SVD
- **D3[v]**：GEMM O(N·d²)；SVD O(d³)（d 通常 <1024，可接受）；在线追踪 O(d²)
- **D4[v]**：存储协方差矩阵 d×d（~4MB for d=1024），不增加 KV-Cache
- **D5[~]**：SVD 强烈建议 fp32；白化的矩阵逆需 fp32 + ε 正则化
- **D6[v]**：多专家对的子空间角度计算独立并行；CCA 的 GEMM 高度并行
- **D7[~]**：当源/目标表示稀疏时，协方差矩阵 Σ 稀疏，可用稀疏 SVD
- **D8[~]**：白化 (mean-sub → cov → inv_sqrt → transform) 可部分融合

## 论文表述方式
"基于正交 Procrustes 理论求得源-目标表示间的最优等距映射 W*=UV^T（USV^T=SVD(A^TB)），
将其扩展为深度 CCA 实现非线性子空间对齐，Grassmann 流形上的主角度分析表明
对齐前后的子空间距离可由主角度度量。收敛速率依赖样本独立性、谱间隙和协方差估计条件；Barlow Twins 目标只惩罚交叉相关，不能单独保证语义解耦，应报告主角度、CCA 相关系数和下游迁移指标。"

## 风险
- SVD 在反向传播时奇异值重合导致梯度未定义，需添加 ε 正则化
- CCA 的白化步骤需要矩阵逆，协方差矩阵近奇异时数值不稳定
- 非线性 CCA（深度 CCA）可能过拟合，特别是在小数据集上
- 在线子空间追踪的学习率 η 需要衰减调度，否则持续漂移
