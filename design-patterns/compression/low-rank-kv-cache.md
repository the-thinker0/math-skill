# Low-Rank KV-Cache（低秩 KV 缓存压缩）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当 LLM 推理的 KV-Cache 显存占用成为瓶颈时使用：长上下文推理（$L > 8K$）、多轮对话累积、边缘部署、投机解码/束搜索。核心诉求：**以可控信息损失将 KV-Cache 从 $O(Ld)$ 压缩到 $O(kd)$，$k \ll L$**。

## 数学思想来源
- 透镜：../../lenses/spectral.md（谱分量识别与截断）、../../lenses/variational.md（压缩率与重构误差的帕累托取舍）、../../lenses/duality.md（核范数-谱范数对偶）
- 知识：../../knowledge-base/matrix-analysis/low-rank-approximation.md（Eckart-Young 最优逼近、随机化 SVD）、../../knowledge-base/matrix-analysis/projection.md（正交投影到主子空间）、../../knowledge-base/matrix-analysis/matrix-perturbation.md（Weyl 扰动界）

## 需要的数学知识
- **Eckart-Young-Mirsky 定理**：$A_k = U_k \Sigma_k V_k^H$，$\|A - A_k\|_F = \sqrt{\sum_{i>k} \sigma_i^2}$，截断 SVD = 最优秩-$k$ 逼近
- **随机化 SVD**：$Y = A\Omega$（$\Omega$ 随机高斯），$Y = QR$，$B = Q^H A$，对 $B$ 做 SVD；复杂度 $O(Ldk)$，核心全是 matmul
- **Weyl 扰动界**：$\|A - A_k\|_2 = \sigma_{k+1}$（仅界定矩阵本身的压缩误差）。将其推广到 attention 输出误差需要额外条件：$\|\text{Attn}(Q,K,V) - \text{Attn}(Q,K_k,V_k)\|$ 的完整界需要 (a) $\|Q\|$ 有界、(b) softmax 的 Lipschitz 常数（依赖温度和 score 范围）、(c) K 和 V **两者**的压缩误差。粗略地：误差 $\lesssim C \cdot (\|Q\| \cdot \|K - K_k\| \cdot \|V\| + \|Q\| \cdot \|K_k\| \cdot \|V - V_k\|) / \tau$，其中 $C$ 取决于 softmax Lipschitz 常数，$\tau$ 为温度参数。直接用 $\sigma_{k+1}$ 界 attention score 偏差**仅在固定 Q 且忽略 V 压缩误差的简化假设下成立**。
- **有效秩**：$r_{\text{eff}}(K) = \|K\|_F^2 / \|K\|_2^2$，指导 $k$ 的自适应选取

## AI 模块形式
```
模块：LowRankKVCompressor
输入：K ∈ R^{L×d}, V ∈ R^{L×d}    参数：目标秩 k << L，更新频率 M

方法1 - 离线周期压缩（最实用）：
  Omega = randn(d, k+p)                    // 随机投影，p=5 过采样
  Q_k = qr(K @ Omega)[0]                   // L×(k+p) 正交基底（GEMM + QR）
  B_k = Q_k^T @ K                          // (k+p)×d 小矩阵 GEMM
  U_r, S_r, Vt_r = svd(B_k)               // 小矩阵 SVD
  K_comp = S_r[:k] * Vt_r[:k, :]           // k×d 压缩 Key
  // V_comp 定义：对 V 做类似的截断 SVD，V_comp = Σ_k^{(V)} · Vt_k^{(V)}（k×d 压缩 Value）
  // 或者，若 K 和 V 共享列空间基底 Q_k，则 V_comp = Q_k^T @ V（投影到同一低秩子空间）
  // Attention: softmax(Q @ K_comp^T / √d) @ V_comp，序列维度 L → k

方法2 - 流式增量压缩（低延迟）：
  维护基底 (U_basis ∈ R^{k×d})，新 token 到来：
    残差 p = k_new - U_basis^T @ (U_basis @ k_new)
    if ‖p‖ > τ: brand_update + truncate_to_rank(k)  // 扩展基底
    else: coeff = U_basis @ k_new                    // 投影到现有基底

方法3 - 分层自适应：按有效秩 r_eff[l,h] 分配各层各头的 k
```

## 可实现结构
- **周期压缩层**：每 M=64 步触发随机化 SVD，$L \times d \to k \times d$
- **双缓冲**：压缩基底 + 近期 $w$ 个原始 token，兼顾精度与压缩率
- **共享基底**：多头共享 Key 列空间基底，各头只存系数
- **量化基底**：压缩后进一步 INT8/FP8 量化，双重压缩

## GPU 可行性
- 张量化/GEMM：随机化 SVD = 3 次 GEMM + 1 次小 SVD，完美映射 Tensor Core
- 复杂度：$O(Ldk)$ 远优于 $O(Ld^2)$ 完整 SVD；$k \sim 256$ 时开销可忽略
- 显存：序列维度从 $L$ 降至 $k$；Key-Cache 以基底+系数格式存储（$Q_k \in \mathbb{R}^{L \times k}$ + $B_k \in \mathbb{R}^{k \times d}$）可获 $L/k$ 倍压缩，V-Cache 需独立做类似压缩。端到端压缩比取决于 K/V 两者的存储格式与秩选取
- 低精度：SVD 建议 fp32（小矩阵可接受）；压缩后 KV 可回 bf16 存储
- 并行：多层/多头压缩完全独立；增量更新 $O(kd)$ 极低延迟
- 算子融合：$K\Omega$ + QR 可部分融合；attention 的 QK^T 维度已缩小

**量化评估示例**（标准 transformer, d=128, n=2048, rank k=64）：
- D3: SVD 计算 O(n·d·k) ≈ 2048·128·64 ≈ 16.8M FLOPs（一次性）；推理时 matmul O(n·k) per query
- D4: KV-Cache 从 O(n·d) = 2048·128·2B ≈ 512KB；物化格式 O(n·k + k·d) ≈ 2048·64·2B + 64·128·2B ≈ 278KB（压缩比 ~1.8x）；若改用基底+系数格式（$Q_k \in \mathbb{R}^{n \times k}$ 的 $k$ 列 + $B_k = Q_k^T K \in \mathbb{R}^{k \times d}$），Key-Cache 压缩至 ~272KB（~32x），V-Cache 需独立压缩
- D5: 截断 SVD 在 bf16 下 σ_k 附近奇异值误差放大 ~κ(A)，需注意
- D8: SVD → matmul 可融合；在线更新用 incremental SVD 避免全量重算

## 论文表述方式
"基于 Eckart-Young-Mirsky 定理，采用随机化 SVD 将 KV-Cache 投影到最优秩-$k$ 子空间，以 $O(Ldk)$ 复杂度将序列维度从 $L$ 降至 $k$。Weyl 扰动界保证 K/V 矩阵本身的压缩误差不超过 $\sigma_{k+1}$；attention 输出的端到端误差界进一步依赖 query 范数、softmax Lipschitz 常数和温度参数。实际显存压缩比取决于存储格式（物化 vs 基底+系数）及 V-Cache 的独立压缩策略。"

## 风险
- **秩选取不当**：$k$ 过小导致 $\sigma_{k+1}$ 不可忽略，长距离 recall 下降；需监控奇异值衰减曲线
- **增量 SVD 误差累积**：Brand 更新多次后偏离真实 SVD，需定期重压缩校正
- **位置编码失真**：RoPE 与 Key 耦合，压缩可能破坏相对位置；需单独处理或重新注入
- **双缓冲接缝**：压缩区与原始区的 attention score 尺度不一致，需统一归一化
