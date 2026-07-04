# Low-Rank KV-Cache（低秩 KV 缓存压缩）

## 适用问题
当 LLM 推理的 KV-Cache 显存占用成为瓶颈时使用：长上下文推理（$L > 8K$）、多轮对话累积、边缘部署、投机解码/束搜索。核心诉求：**以可控信息损失将 KV-Cache 从 $O(Ld)$ 压缩到 $O(kd)$，$k \ll L$**。

## 数学思想来源
- 透镜：lenses/spectral.md（谱分量识别与截断）、lenses/variational.md（压缩率与重构误差的帕累托取舍）、lenses/duality.md（核范数-谱范数对偶）
- 知识：knowledge-base/matrix-analysis/low-rank-approximation.md（Eckart-Young 最优逼近、随机化 SVD）、knowledge-base/matrix-analysis/projection.md（正交投影到主子空间）、knowledge-base/matrix-analysis/matrix-perturbation.md（Weyl 扰动界）

## 需要的数学知识
- **Eckart-Young-Mirsky 定理**：$A_k = U_k \Sigma_k V_k^H$，$\|A - A_k\|_F = \sqrt{\sum_{i>k} \sigma_i^2}$，截断 SVD = 最优秩-$k$ 逼近
- **随机化 SVD**：$Y = A\Omega$（$\Omega$ 随机高斯），$Y = QR$，$B = Q^H A$，对 $B$ 做 SVD；复杂度 $O(Ldk)$，核心全是 matmul
- **Weyl 扰动界**：$\|A - A_k\|_2 = \sigma_{k+1}$，压缩后 attention score 最大偏差 $\leq \sigma_{k+1}$
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
- 显存：KV-Cache 从 $O(Ld)$ 到 $O(kd)$，$k/L \sim 1/16$ 可达 16x 压缩
- 低精度：SVD 建议 fp32（小矩阵可接受）；压缩后 KV 可回 bf16 存储
- 并行：多层/多头压缩完全独立；增量更新 $O(kd)$ 极低延迟
- 算子融合：$K\Omega$ + QR 可部分融合；attention 的 QK^T 维度已缩小

## 论文表述方式
"基于 Eckart-Young-Mirsky 定理，采用随机化 SVD 将 KV-Cache 投影到最优秩-$k$ 子空间，以 $O(Ldk)$ 复杂度实现 $L/k$ 倍显存压缩，Weyl 扰动界保证 attention score 偏差不超过 $\sigma_{k+1}$。"

## 风险
- **秩选取不当**：$k$ 过小导致 $\sigma_{k+1}$ 不可忽略，长距离 recall 下降；需监控奇异值衰减曲线
- **增量 SVD 误差累积**：Brand 更新多次后偏离真实 SVD，需定期重压缩校正
- **位置编码失真**：RoPE 与 Key 耦合，压缩可能破坏相对位置；需单独处理或重新注入
- **双缓冲接缝**：压缩区与原始区的 attention score 尺度不一致，需统一归一化
