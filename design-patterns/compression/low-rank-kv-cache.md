# Low-Rank KV-Cache（低秩 KV 缓存压缩）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当 LLM 推理的 KV-Cache 显存占用成为瓶颈时使用：长上下文推理（$L > 8K$）、多轮对话累积、边缘部署、投机解码/束搜索。核心诉求：**以可控信息损失将 KV-Cache 从 $O(Ld)$ 压缩到低秩因子存储 $O(Lk + kd)$，$k \ll d$**。

## 数学思想来源
- 透镜：../../lenses/spectral.md（谱分量识别与截断）、../../lenses/variational.md（压缩率与重构误差的帕累托取舍）、../../lenses/duality.md（核范数-谱范数对偶）
- 知识：../../knowledge-base/matrix-analysis/low-rank-approximation.md（Eckart-Young 最优逼近、随机化 SVD）、../../knowledge-base/matrix-analysis/projection.md（正交投影到主子空间）、../../knowledge-base/matrix-analysis/matrix-perturbation.md（Weyl 扰动界）

## 需要的数学知识
- **Eckart-Young-Mirsky 定理**：$A_k = U_k \Sigma_k V_k^H$，$\|A - A_k\|_F = \sqrt{\sum_{i>k} \sigma_i^2}$，截断 SVD = 最优秩-$k$ 逼近
- **随机化 SVD**：$Y = A\Omega$（$\Omega$ 随机高斯），$Y = QR$，$B = Q^H A$，对 $B$ 做 SVD；复杂度 $O(Ldk)$，核心全是 matmul
- **Eckart-Young 谱范数误差**：$\|A - A_k\|_2 = \sigma_{k+1}$（仅界定矩阵本身的最优秩-$k$ 压缩误差；Weyl 只用于分析扰动后的奇异值变化）。将其推广到 attention 输出误差需要额外条件：$\|\text{Attn}(Q,K,V) - \text{Attn}(Q,K_k,V_k)\|$ 的完整界需要 (a) $\|Q\|$ 有界、(b) softmax 的 Lipschitz 常数（依赖温度和 score 范围）、(c) K 和 V **两者**的压缩误差。粗略地：误差 $\lesssim C \cdot (\|Q\| \cdot \|K - K_k\| \cdot \|V\| + \|Q\| \cdot \|K_k\| \cdot \|V - V_k\|) / \tau$，其中 $C$ 取决于 softmax Lipschitz 常数，$\tau$ 为温度参数。直接用 $\sigma_{k+1}$ 界 attention score 偏差**仅在固定 Q 且忽略 V 压缩误差的简化假设下成立**。
- **有效秩**：$r_{\text{eff}}(K) = \|K\|_F^2 / \|K\|_2^2$，指导 $k$ 的自适应选取

## AI 模块形式
```
模块：LowRankKVCompressor
输入：K ∈ R^{L×d}, V ∈ R^{L×d}    参数：目标秩 k << L，更新频率 M

方法1 - 离线周期压缩（最实用）：
  Omega = randn(d, k+p)                    // 随机投影，p=5 过采样
  Q_base = qr(K @ Omega)[0]                // L×(k+p) 过采样正交基底（GEMM + QR）
  B_k = Q_base^T @ K                       // (k+p)×d 小矩阵 GEMM
  U_r, S_r, Vt_r = svd(B_k)               // 小矩阵 SVD
  Q_final = Q_base @ U_r[:, :k]            // L×k 最终左因子
  K_comp = S_r[:k] * Vt_r[:k, :]           // k×d 压缩 Key（低秩因子）
  // V_comp 定义：对 V 做类似的截断 SVD，V_comp = Σ_k^{(V)} · Vt_k^{(V)}（k×d 压缩 Value）
  // 或者，若 K 和 V 共享左因子 Q_final，则 V_comp = Q_final^T @ V（投影到同一低秩子空间）
  //
  // ⚠ 关键区分——低秩因子不能直接替代原始序列参与 softmax attention：
  //   K ≈ Q_final @ K_comp（L×d 重构），softmax 是非线性操作，
  //   softmax(Q @ K_comp^T / √d) @ V_comp ≠ softmax(Q @ K^T / √d) @ V
  //   因此 k 个"压缩 token"的解释仅对线性注意力成立，对 softmax 注意力不成立。
  //
  // 模式 A - 标准 softmax attention（省显存；可省内积维度但不省序列长度）：
  //   不必物化 K_recon。若 K ≈ Q_final @ K_comp，则
  //   logits = (Q @ K_comp^T) @ Q_final^T / √d // Q 为 m×d 时复杂度 O(mdk + mLk)
  //   attn = softmax(logits)                   // softmax 仍在 L 个位置上归一化
  //   若 V ≈ Q_final @ V_comp，则 output = (attn @ Q_final) @ V_comp
  //   // 优势：存储从 O(Ld) 降至 O(Lk + kd)，QK/AV 的内维从 d 降到 k
  //   // 限制：注意力矩阵仍是 m×L，不能把 k 个因子当作 k 个 token
  //
  // 模式 B - 线性注意力（核特征映射 φ；需压缩 φ(K), V 的可加统计量）：
  //   用核特征映射 φ 替代 softmax，Attn = φ(Q) @ (φ(K)^T @ V) / (φ(Q) @ φ(K)^T @ 1)
  //   只有当压缩对象是 φ(K)^T V、φ(K)^T 1 等可加统计量，或直接在 φ(K) 空间做低秩/聚合时，
  //   历史状态才能从 L 个 token 变成 k 个统计因子。直接对 K_comp 做 φ 一般不等价。

方法2 - 流式增量压缩（低延迟）：
  维护基底 (U_basis ∈ R^{k×d})，新 token 到来：
    残差 p = k_new - U_basis^T @ (U_basis @ k_new)
    if ‖p‖ > τ: brand_update + truncate_to_rank(k)  // 扩展基底
    else: coeff = U_basis @ k_new                    // 投影到现有基底

方法3 - 分层自适应：按有效秩 r_eff[l,h] 分配各层各头的 k
```

## 可实现结构
- **周期压缩层**：每 M=64 步触发随机化 SVD，$L \times d \to (L \times k) + (k \times d)$
- **双缓冲**：压缩基底 + 近期 $w$ 个原始 token，兼顾精度与压缩率
- **共享基底**：多头共享 Key 列空间基底，各头只存系数
- **量化基底**：压缩后进一步 INT8/FP8 量化，双重压缩

## GPU 可行性
- 张量化/GEMM：随机化 SVD = 3 次 GEMM + 1 次小 SVD，完美映射 Tensor Core
- 复杂度：$O(Ldk)$ 远优于 $O(Ld^2)$ 完整 SVD；$k \sim 256$ 时开销可忽略
- 显存：Key-Cache 以低秩因子形式存储（$Q_{\text{final}} \in \mathbb{R}^{L \times k}$ + $B_k \in \mathbb{R}^{k \times d}$），总参数 $Lk + kd$，压缩比 $Ld/(Lk+kd) \approx d/k$（当 $L \gg k$）。注意 $Q_{\text{final}}$ 仍有 $L$ 维，序列长度未缩短；softmax attention 可用因子化 GEMM 计算长度为 $L$ 的 logits，不必物化完整 $L \times d$ 矩阵。V-Cache 需独立做类似压缩。端到端压缩比取决于 K/V 两者的存储格式与秩选取
- 低精度：SVD 建议 fp32（小矩阵可接受）；压缩后 KV 可回 bf16 存储
- 并行：多层/多头压缩完全独立；增量更新 $O(kd)$ 极低延迟
- 算子融合：$K\Omega$ + QR 可部分融合；softmax 路径可把 QK/AV 的内维从 $d$ 降到 $k$，但 softmax 归一化长度仍为 $L$；线性注意力只有在压缩可加统计量时才真正把历史状态降到 $k$

**量化评估示例**（标准 transformer, d=128, n=2048, rank k=64）：
- D3: SVD 计算 O(n·d·k) ≈ 2048·128·64 ≈ 16.8M FLOPs（一次性）；softmax 推理每个 query 的因子化 QK/AV 约 O(dk + n·k)，仍需长度 n 的 softmax；线性注意力若压缩统计量才可消去 n
- D4: KV-Cache 从 O(n·d) = 2048·128·2B ≈ 512KB；因子格式 O(n·k + k·d) ≈ 2048·64·2B + 64·128·2B ≈ 278KB（压缩比 ~1.8x）。最终左因子+系数格式（$Q_{\text{final}} \in \mathbb{R}^{n \times k}$ 正交基 + $B_k \in \mathbb{R}^{k \times d}$）总参数 $nk + kd$，压缩比 $nd/(nk+kd) = d/k \cdot 1/(1 + d/n) \approx d/k = 2x$，V-Cache 需独立压缩
- D5: 截断 SVD 在 bf16 下 σ_k 附近奇异值误差放大 ~κ(A)，需注意
- D8: SVD → matmul 可融合；在线更新用 incremental SVD 避免全量重算

## 论文表述方式
"基于 Eckart-Young-Mirsky 定理，采用随机化 SVD 将 KV-Cache 投影到秩-$k$ 子空间，以 $O(Ldk)$ 复杂度将存储从 $O(Ld)$ 压缩至 $O(Lk + kd)$（基底+系数格式）。对标准 softmax attention，低秩因子不能解释为 $k$ 个压缩 token；softmax 仍在长度 $L$ 上归一化，但可用因子化 GEMM 计算 logits 与 value 聚合，避免物化完整 $L \times d$ 重构并将 QK/AV 的内维从 $d$ 降到 $k$。仅在线性注意力中，且压缩的是 $\phi(K)^T V$、$\phi(K)^T\mathbf{1}$ 等可加统计量时，历史状态才可真正从 $L$ 降至 $k$ 个统计因子。Eckart-Young 的谱范数误差给出 K/V 矩阵本身的最优秩-$k$ 压缩误差 $\sigma_{k+1}$；attention 输出的端到端误差界进一步依赖 query 范数、softmax Lipschitz 常数和温度参数。实际显存压缩比取决于存储格式及 V-Cache 的独立压缩策略。"

## 风险
- **秩选取不当**：$k$ 过小导致 $\sigma_{k+1}$ 不可忽略，长距离 recall 下降；需监控奇异值衰减曲线
- **增量 SVD 误差累积**：Brand 更新多次后偏离真实 SVD，需定期重压缩校正
- **位置编码失真**：RoPE 与 Key 耦合，压缩可能破坏相对位置；需单独处理或重新注入
- **双缓冲接缝**：压缩区与原始区的 attention score 尺度不一致，需统一归一化
