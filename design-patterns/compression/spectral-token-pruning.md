# Spectral Token Pruning（谱 Token 剪枝）

> 严谨性约定：[v] 表示可核查的图/矩阵关系或计数；[~] 表示需要任务与硬件验证的启发式。中心性不是信息保留保证。

## 适用问题
探索基于图中心性、连通结构或谱表示的 token 选择，用于 KV 驱逐、视觉 token 压缩或长文档处理。目标是提出可比较的剪枝分数；未经独立证明，不称为最小信息损失或有谱保持保证的稀疏化。

## 数学思想来源
- 透镜：`../../lenses/spectral.md`、`../../lenses/algorithmic.md`、`../../lenses/perturbation.md`。
- 知识：`../../knowledge-base/matrix-analysis/spectral-decomposition.md`、`../../knowledge-base/matrix-analysis/matrix-perturbation.md`、`../../knowledge-base/matrix-analysis/positive-semidefinite.md`。

## 需要的数学知识
- **左右特征向量 [v]**：行随机 A 总有 A1=1；未 mask 且不可约、非周期时，左平稳概率向量可作为一个中心性分数。causal/mask 图可能可约；teleportation A_α=αA+(1−α)1πᵀ 在 0<α<1、π 各项正时给唯一平稳分布。
- **本例可省去幂迭代 [v]**：若 S=KKᵀ/√d、W_ij=exp(S_ij)，则 W 对称且正。A_ij=W_ij/Σ_jW_ij 的平稳分布恰为 p_i=s_i/Σ_js_j，s_i=Σ_jW_ij；因为 p_iA_ij=W_ij/Σ_js_j=p_jA_ji。可用 logsumexp 直接算，不必声称固定 5 步已收敛。
- **谱间隙边界 [v]**：混合与非主特征值的模、图条件及非正规瞬态有关，不是“gap 大所以少数 token 主导”。反例 A=11ᵀ/L 的间隙为 1，但平稳分布完全均匀。
- **Fiedler 向量 [v/条件]**：对适当的无向非负图，它对应连续的谱分割松弛；阈值化不保证最优离散二分割，幅值小也不是通用 token 重要性标准。
- **扰动边界 [v]**：Cauchy 交错适用于固定 Hermitian 矩阵的主子矩阵；重新归一化会改变对象。Bauer–Fike 需同尺寸、可对角化参考矩阵及特征向量条件数；不能把它直接当删节点误差界。Geršgorin 半径是谱定位量，不是语义信息损失证书。

## AI 模块形式
下列是稠密单头参考。第一种针对对称 Key 相似度图直接计算平稳质量；第二种处理给定的有向行随机图并报告收敛残差。

```python
import math
import torch

def symmetric_key_centrality(K):
    scores = (K.float() @ K.float().T) / math.sqrt(K.shape[-1])
    log_degree = torch.logsumexp(scores, dim=-1)
    return torch.softmax(log_degree, dim=0)  # Exact stationary mass for this graph.

def teleported_pagerank(A, alpha=0.85, max_steps=100, tolerance=1e-6):
    A = A.float()
    assert A.ndim == 2 and A.shape[0] == A.shape[1] and A.shape[0] > 0
    assert 0 < alpha < 1 and bool(torch.isfinite(A).all()) and bool((A >= 0).all())
    assert torch.allclose(A.sum(dim=-1), torch.ones(A.shape[0], device=A.device), atol=1e-5)
    prior = torch.full((A.shape[0],), 1 / A.shape[0], device=A.device)
    v = prior.clone()
    for _ in range(max_steps):
        next_v = alpha * (A.T @ v) + (1 - alpha) * prior
        change = (next_v - v).abs().sum()
        v = next_v
        if change <= (1 - alpha) * tolerance:
            break
    residual = (alpha * (A.T @ v) + (1 - alpha) * prior - v).abs().sum()
    return v, residual  # In exact arithmetic: l1 error <= residual/(1-alpha).

def keep_by_score(K, V, score, retention):
    assert 0 < retention <= 1 and K.shape[0] == V.shape[0] > 0
    assert score.shape == (K.shape[0],)
    count = math.ceil(retention * K.shape[0])
    indices = torch.topk(score, count).indices.sort().values
    return K[indices], V[indices], indices  # Retain original token order.
```

**Geršgorin 启发式 [~]**：对原始 S，可取 Σ_(j≠i)|S_ij| 排序；这仅反映该矩阵的绝对连接权重，构图成本仍为 O(L²d)，高范数或重复 token 可能占优。

**软门控 [~]**：若 score∈R^L，使用标量 w、b 构造 g=sigmoid((w·score+b)/τ)∈R^L。若意图降低 token 的注意力质量，应把 log(g_j) 加到第 j 列 logits（用稳定的 log-sigmoid），再归一化；仅令 K_j←g_jK_j 不等于删除该 token，零 Key 的 score=0 仍会获得权重。软门控保留 L 个位置，不自动省计算/缓存；之后的硬 gather 需另外验证。

## 可实现结构
- **完整图 [~]**：适合构图成本可摊销的规模；序列阈值应由基准决定。
- **锚点近似 [~]**：只做 m×m 子图只能给锚点评分；要给全部 L 个 token 评分还需 L×m 交叉相似度及明确的延拓/分配规则，并验证其偏差。
- **多头与渐进剪枝 [~]**：平均图改变所衡量的中心性；逐层误差需累积评估，不能假定各层可同时执行。
- **部署约束 [~]**：保留 K/V 一一对应、原始位置、特殊/近期必保 token，并同步更新 mask。用于自回归训练时，选择规则不能利用 Query 不可见的未来内容。

## GPU 可行性
- **D1/D2 [v]**：KKᵀ 是 GEMM；softmax、行归约和 top-k 是不同运算。**[~]** matvec 常受带宽限制，不能以张量形式推断高利用率。
- **D3 [v]**：稠密构图 O(L²d)；对称图的行和 O(L²)，一般 PageRank 另需 O(TL²)。T 由残差控制，不能统一限定为 5 或 10。
- **D4 [v]**：L=8192 时，单个 L×L bf16 矩阵是 128 MiB，fp32 是 256 MiB，工作区/梯度另计。**[~]** 分块可降低峰值存储，但反复传播可能要求重复计算图块。
- **D5 [~]**：低精度归约、谱间隙、softmax 动态范围及 top-k 近似并列值影响排序；归一化不能保证 bf16 正确，Geršgorin 行和也有舍入误差。
- **D6/D8 [~]**：图块与部分头任务可并行，但构图、归约和全局 top-k 有依赖。是否融合及是否快于简单评分，需实际 kernel 和完整延迟基准。

## 论文表述方式
“我们采用图中心性启发式选择 token，区分对称相似度图的精确平稳分数与有向图的近似 PageRank。我们报告构图、选择、缓存重排和后续 attention 的总成本，以及任务损失和保留策略；不把节点删除称为已经满足 Laplacian 二次型保证的谱稀疏化。”

## 风险
谱中心性与语义重要性可能冲突，均匀图或重复向量还会导致分数并列。PageRank 的解释取决于边方向与 teleportation 先验；与真实 Query 无关的 Key 图未必预测未来访问。硬选择的索引不可微，但被选中的 K/V 值仍可接收梯度；若不学习选择器，不必强制加入可微松弛。

## 来源
[Fiedler/谱分割的条件与松弛](https://arxiv.org/abs/0711.0189)见 von Luxburg 的教程。本例平稳分布的直接算法由上面的 detailed balance 等式推导；它支持中心性计算，不证明剪枝安全。
