# Leverage Score Selection（杠杆分数选择）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当需要从大规模矩阵中选取最有代表性的行/列/token，并希望在下游线性代数任务中获得可检验误差界时使用：KV-Cache token 选择、数据 coreset 构建、Nyström landmark 采样、分布式梯度压缩。核心诉求：**基于子空间投影的统计杠杆分数做采样，在矩阵采样理论假设下以高概率逼近全量计算**。

## 数学思想来源
- 透镜：../../lenses/spectral.md（杠杆分数 = 行向量在主子空间上的投影能量）、../../lenses/probabilistic.md（概率采样与浓度不等式保证）、../../lenses/algorithmic.md（随机化算法的复杂度与精度权衡）
- 知识：../../knowledge-base/matrix-analysis/low-rank-approximation.md（随机化 SVD、核范数）、../../knowledge-base/matrix-analysis/projection.md（投影矩阵对角元 = 杠杆分数）、../../knowledge-base/probability/concentration-inequality.md（Bernstein 矩阵浓度界）

## 需要的数学知识

- $A$ 的正交归一秩 $k$ **左**基 $U_k\in\mathbb R^{N\times k}$，行杠杆分数为 $\ell_i=\|U_k[i,:]\|_2^2=(U_kU_k^T)_{ii}$，且 $\sum_i\ell_i=k$。右奇异向量给出列杠杆分数。
- 从 $p_i\ge\beta\ell_i/k$ 独立有放回采样，按 $1/\sqrt{s p_i}$ 缩放行，在标准矩阵集中条件下 $s=O(k\log(k/\delta)/(\beta\epsilon^2))$ 可嵌入这个固定子空间。仅保持低秩基不意味着对任意响应向量的完整最小二乘相对误差保证。
- 原始 sketch 行范数 $\|(A\Omega)_i\|^2$ 是 sketch 能量，不是杠杆分数：先正交化值域。若目标恰为秩 $k$，QR 后还需小投影 SVD 截断。
- 确定性 top-s 不继承独立随机采样定理。DPP 采样由 PSD 主子阵行列式定义，任意邻居惩罚启发式不是 DPP 采样。

## AI 模块形式

```python
Omega = randn(d, k + oversampling)
Q = qr(A @ Omega, mode='reduced').Q
U_small, singular_values, Vh = svd(Q.T @ A, full_matrices=False)
U_k = Q @ U_small[:, :k]
leverage = (U_k**2).sum(-1)
probs = leverage / leverage.sum()
indices = multinomial(probs, s, replacement=True)
weights = 1 / sqrt(s * probs[indices])
A_sampled = A[indices] * weights[:, None]
```
以精确小例检查数值秩、基正交性及嵌入残差。确定性 token 逐出可用 `topk(leverage, s)`，但这是注意力启发式；上述行重加权本身不会保持 softmax token 语义。

多样性选择应使用实际 DPP/k-DPP 采样器或明确的贪心 log-det 算法。若使用杠杆分数加相似性惩罚，标为“多样性启发式”，与均匀/随机/注意力分数基线比较。

## 可实现结构

- 明确线代任务中的独立重加权行采样。
- 作为单独实测注意力启发式的确定性逐出。
- 离线精确杠杆分数用于验证在线近似。
- DPP/log-det 多样性方法各自使用相应采样或优化保证。

## GPU 可行性

- **D1/D2[~]**：sketch 与小投影 SVD 使用 GEMM 加 QR/SVD；QR 不是纯 matmul。
- **D3[~]**：sketch 宽度 $r=k+p$ 时，含 $O(Ndr)$ sketch/投影、$O(Nr^2)$ QR 及 $O(dr^2)$ 小 SVD。加速需 $r\ll\min(N,d)$ 及摊销。
- **D4[~]**：存储 $N\times r$ 的 $Q$、$d\times r$ 的 $\Omega$ 与 $r\times d$ 投影矩阵。逐批独立 QR 不构成全局正交基；分块须用正确 streaming/TSQR 算法。
- **D5[~]**：使用 fp32/fp64 QR/SVD，检查秩亏附近残差。
- **D6/D8[~]**：归约及分解引入同步；算子可用不证明端到端融合已实现。
- **D7[N/A]**：低秩子空间结构不意味着因子元素稀疏。

## 论文表述方式
"采用统计杠杆分数作为 token/行选择的重要性度量：通过随机投影在 $O(Ndk)$ 内近似 rank-$k$ 子空间杠杆分数，并在独立重加权采样、有效秩诊断和目标为子空间/最小二乘近似的前提下，使用 Drineas-Mahoney 类界选择样本数。对 KV-cache eviction，仍需报告 attention/output 误差与任务指标。"

## 风险

- 秩选择及基近似影响分数；报告尾能量与 sketch 残差。
- 大重要性权重增加采样方差；切换确定性选择会改变定理适用性。
- 谱重要性未必等于语义重要性；检查罕见检索 token。
- 流式基漂移需刷新，刷新成本计入解码延迟。
