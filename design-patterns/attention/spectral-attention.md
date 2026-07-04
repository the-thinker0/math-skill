# 谱注意力 / Spectral Attention

## 适用问题
当输入信号具有**频域/谱结构**（周期性、循环对称性、图结构）时，在谱域而非空域计算注意力可大幅降低复杂度并利用信号的内在结构。典型场景：时间序列预测（周期性信号）、图神经网络（图 Laplacian 谱分解）、位置编码（RoPE/ALiBi 的频率解释）、长序列注意力的 $O(n \log n)$ 加速。

## 数学思想来源
- 透镜：[transformation（变换思想 — 频域变换）, symmetry-invariance（对称与不变性 — 循环/平移不变性）]
- 知识：[`probability/entropy.md`（谱熵度量信号复杂度）, `probability/concentration-inequality.md`（频域浓度不等式）]

## 需要的数学知识
- **离散傅里叶变换 DFT / FFT**：$O(n \log n)$ 频域变换，循环卷积定理
- **图 Laplacian 谱分解**：$L = U \Lambda U^T$，$U$ 为图 Fourier 基
- **循环群 $\mathbb{Z}_n$ 的不可约表示**：DFT 矩阵即循环群的表示矩阵（参见 `references/books/abstract-algebra.md` Ch.4, Ch.11）

## AI 模块形式

**核心思路**：将注意力从空域的 $Q K^T$ 转换到谱域的对角/稀疏运算：

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
- **维度 1 张量化 ✅**：FFT 和矩阵乘均为标准张量运算
- **维度 2 GEMM 可映射 ✅**：谱投影 $U^T Q$ 为标准 GEMM；FFT 虽非 GEMM 但有高度优化的 cuFFT 实现
- **维度 3 复杂度 ✅**：FFT 注意力 $O(n \log n \cdot d)$，远优于 $O(n^2 d)$
- **维度 4 显存 ✅**：频域表示不增加额外维度，谱投影可降低到 $k \ll n$ 维
- **维度 5 低精度 ⚠️**：复数 FFT 在 fp16 下精度损失，需 fp32 或使用实数 FFT (RFFT)
- **维度 6 并行 ✅**：FFT 可跨 batch/head 并行，cuFFT 支持多流
- **维度 7 稀疏 ✅**：谱域中高频分量可截断（结构化稀疏），只保留 top-k 频率
- **维度 8 算子融合 ⚠️**：FFT 与 attention 融合需自定义 kernel，标准库无现成融合

## 论文表述方式
"我们提出谱域注意力机制，通过将注意力计算转换到 Fourier/Laplacian 谱域，利用循环卷积定理将序列注意力复杂度从 $O(n^2)$ 降至 $O(n \log n)$，同时通过频率自适应权重保留对不同尺度依赖关系的建模能力。"

## 风险
- **非周期性假设违反**：FFT 隐式假设周期性边界条件，对自然语言等非周期信号产生谱泄漏，需加窗函数或零填充。
- **图 Laplacian 预计算成本**：大规模图的特征分解 $O(n^3)$ 不可行，需近似（Nyström/Lanczos），且动态图需重算。
