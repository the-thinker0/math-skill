# 谱注意力 / Spectral Attention
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当输入信号具有**频域/谱结构**（周期性、循环对称性、图结构）时，在谱域而非空域计算注意力可大幅降低复杂度并利用信号的内在结构。典型场景：时间序列预测（周期性信号）、图神经网络（图 Laplacian 谱分解）、位置编码（RoPE/ALiBi 的频率解释）、长序列中**位置依赖型**注意力的 $O(n \log n)$ 加速（需循环/Toeplitz 结构假设，不适用于通用 content-dependent softmax 注意力）。

## 数学思想来源
- 透镜：[duality（对偶透镜 — 频域变换）, symmetry（对称透镜 — 循环/平移不变性）]
- 知识：[`../../knowledge-base/probability/entropy.md`（谱熵度量信号复杂度）, `../../knowledge-base/probability/concentration-inequality.md`（频域浓度不等式）]

## 需要的数学知识
- **离散傅里叶变换 DFT / FFT**：$O(n \log n)$ 频域变换，循环卷积定理
- **图 Laplacian 谱分解**：$L = U \Lambda U^T$，$U$ 为图 Fourier 基
- **循环群 $\mathbb{Z}_n$ 的不可约表示**：DFT 矩阵即循环群的表示矩阵（参见 `../../references/books/abstract-algebra.md` Ch.4, Ch.11）

## AI 模块形式

**核心思路**：将注意力从空域的 $Q K^T$ 转换到谱域的对角/稀疏运算：

> **关键前提条件**：上述「谱域对角化 = 注意力」的等价性**仅在注意力矩阵为循环矩阵（circulant）或 Toeplitz 矩阵时成立**，即注意力权重仅依赖于 token 之间的相对位置 $a_{ij} = f(i-j)$，而与 token 内容无关。此时循环卷积定理保证 FFT 可将卷积核对角化。对于标准的 content-dependent softmax 注意力 $\text{softmax}(QK^T/\sqrt{d})$，注意力矩阵由 query/key 内容决定，一般**不是**循环矩阵或 Toeplitz 矩阵，因此 FFT 逐元素乘法**不能**等价替代 $QK^T$ 计算。方案 A/C 本质上是位置依赖的卷积式注意力近似，而非通用 softmax 注意力的精确替代。

**方案 A：FFT 加速注意力（时间序列）**：
```python
# 将循环卷积写成谱域逐元素乘
Q_hat = fft(Q, dim=seq)        # (n, d) -> (n, d) 频域
K_hat = fft(K, dim=seq)
# 注意力 ≈ 频域滤波：每个频率分量独立加权
attn_hat = Q_hat * conj(K_hat)  # 逐元素乘 = 循环卷积
attn = ifft(attn_hat, dim=seq)
# 复杂度：O(n log n * d) vs 标准 O(n^2 * d)
```

**方案 B：图谱注意力（GNN）**：
```python
# 预计算图 Laplacian 谱分解 L = U Λ U^T（离线）
U = eigenvectors(L)  # (n, k), 取 top-k 低频特征向量
# 谱域注意力：在低频子空间中计算
Q_spec = U^T @ Q   # (k, d) 投影到谱域
K_spec = U^T @ K
scores = (Q_spec @ W_q) @ (K_spec @ W_k).T / sqrt(d)
attn_spec = softmax(scores) @ (U^T @ V)
output = U @ attn_spec  # 反投影回空域
```

**方案 C：频率自适应注意力权重**：
```python
freq_weights = learnable_parameter(num_freq_bands)  # 可学习频谱权重
Q_hat, K_hat = fft(Q), fft(K)
scores_freq = freq_weights.unsqueeze(-1) * (Q_hat * conj(K_hat))
attn = ifft(scores_freq)
```

## 可实现结构
- **Spectral Transformer**：用 FFT 替代 $O(n^2)$ 注意力，适合周期性序列数据（气象、金融、音频）
- **Graph Spectral Attention**：利用图 Laplacian 的前 $k$ 个特征向量做低维注意力，适合大规模图（$n > 10^5$）
- **频率感知位置编码**：RoPE 的本质即循环群 $\mathbb{Z}$ 的酉表示（参见抽象代数 Ch.4），可推广到其他群

## GPU 可行性
- **D1[v]**：FFT 和矩阵乘均为标准张量运算
- **D2[v]**：谱投影 $U^T Q$ 为标准 GEMM；FFT 虽非 GEMM 但有高度优化的 cuFFT 实现
- **D3[~]**：FFT 注意力 $O(n \log n \cdot d)$，远优于 $O(n^2 d)$——**但仅当注意力具有平移不变/位置依赖结构时成立**（如卷积式注意力）。通用 content-dependent softmax 注意力仍为 $O(n^2 d)$；linear attention 近似可达 $O(n d^2)$，但其机制与 FFT 谱方法不同。
- **D4[v]**：频域表示不增加额外维度，谱投影可降低到 $k \ll n$ 维
- **D5[~]**：复数 FFT 在 fp16 下精度损失，需 fp32 或使用实数 FFT (RFFT)
- **D6[v]**：FFT 可跨 batch/head 并行，cuFFT 支持多流
- **D7[v]**：谱域中高频分量可截断（结构化稀疏），只保留 top-k 频率
- **D8[~]**：FFT 与 attention 融合需自定义 kernel，标准库无现成融合

**量化评估示例**（标准 transformer, d=128, n=2048, h=16）：
- D3: FFT 路径 FLOPs ≈ 2·n·log₂(n)·d ≈ 2·2048·11·128 ≈ 5.8M vs 标准 attention 2·n²·d ≈ 1.1G（仅当 attention 为卷积核时）
- D4: 无需物化 n×n attention matrix；FFT 中间结果 O(n·d) ≈ 1MB
- D5: FFT 在 bf16 下 twiddle factor 误差 ~10⁻³，可接受
- D8: FFT + pointwise 可融合为单个 CUDA kernel

## 论文表述方式
"我们提出谱域注意力机制，通过将注意力计算转换到 Fourier/Laplacian 谱域，利用循环卷积定理将**具有平移不变结构的**序列注意力复杂度从 $O(n^2)$ 降至 $O(n \log n)$，同时通过频率自适应权重保留对不同尺度依赖关系的建模能力。注意：此加速**要求注意力模式具有位置依赖（而非内容依赖）结构**；对于通用 content-dependent softmax 注意力，该谱域等价性不成立。"

## 适用条件
- **FFT 谱注意力的核心限制**：方案 A/C 的 FFT 加速**要求注意力矩阵为循环矩阵或 Toeplitz 矩阵**，即注意力权重仅依赖于相对位置 $a_{ij} = f(i-j)$，而与 token 的具体内容（query/key 向量）无关。
- **不满足条件的情形**：大多数 NLP 任务中的标准 softmax 注意力 $\text{softmax}(QK^T/\sqrt{d})$ 是 content-dependent 的——注意力权重由 query 和 key 的内容共同决定，产生的注意力矩阵一般不具有循环/Toeplitz 结构。在此情形下，FFT 逐元素乘法**不能**替代 $QK^T$ 运算，$O(n \log n)$ 复杂度优势也不成立。
- **满足条件的情形**：位置编码（如 RoPE/ALiBi 的频率分量）、时间序列的周期性卷积核、具有平移不变先验的固定模式注意力。方案 B（图谱注意力）不受此限制，因为它在图 Laplacian 特征基上做投影而非利用循环卷积定理。

## 风险
- **[x] Content-dependent 注意力不兼容**：FFT 谱方法的核心假设（循环/Toeplitz 结构）与 NLP 中主流的 content-dependent softmax 注意力**根本矛盾**。将 FFT 方法不加区分地应用于通用注意力机制是数学上的错误——两者计算的是不同的量。使用时必须明确声明所做的位置依赖假设。
- **非周期性假设违反**：FFT 隐式假设周期性边界条件，对自然语言等非周期信号产生谱泄漏，需加窗函数或零填充。
- **图 Laplacian 预计算成本**：大规模图的特征分解 $O(n^3)$ 不可行，需近似（Nyström/Lanczos），且动态图需重算。
