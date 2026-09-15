# 几何感知注意力 / Geometry-Aware Attention

> 严谨性约定：[v] 表示限定前提下可核查的公式或计数；[~] 表示需实验的设计/实现。本原型不宣称已测 GPU 加速。

## 适用问题
输入有已知的空间、流形、树或时间关系时，可把几何作为显式 attention 偏置。标准注意力也可能从输入特征或位置编码中学到这些关系；增加偏置是一种归纳偏置选择，并不自动保证完整模型的几何不变/等变性。

## 数学思想来源
- 透镜：`../../lenses/symmetry.md`、`../../lenses/geometric.md`。
- 知识：`../../knowledge-base/differential-geometry/geodesic.md`、`../../knowledge-base/lie-theory/equivariance.md`。

## 需要的数学知识
- **距离到偏置**：-αδ 或 -δ²/(2σ²) 在 α≥0、σ>0 时随距离下降；任意 `MLP(δ)` 不保证单调。
- **RBF 边界**：exp(-δ²/(2σ²)) 是正相似度，但任意度量/测地距不保证其 Gram 矩阵 PSD。作为 logit 偏置无须 PSD；若还用于核方法，则需另证。
- **位置与群作用**：RoPE 的旋转块利用 R_iᵀR_j 的相对作用。共同左作用下 g_i^(-1)g_j 保持不变；在一般非交换群上不能任意换成 g_i g_j^(-1)。
- **ALiBi**：给可见位置添加线性距离 logit 惩罚，指数衰减的是未归一化权重的偏置因子；内容分数仍可能使远处权重大于近处。

## AI 模块形式

$$O=\operatorname{softmax}_{j}\left(QK^T/\sqrt d+B+M\right)V,\quad B_{ij}=-\delta(i,j)^2/(2\sigma^2).$$

下面是单头稠密基线；Q、K、V 的 token 维可不同，distance 必须为 (m,n)。

```python
import math
import torch

def geometric_attention(Q, K, V, distance, sigma, allowed=None):
    assert sigma > 0
    assert distance.shape == (Q.shape[0], K.shape[0])
    assert bool(torch.isfinite(distance).all()) and bool((distance >= 0).all())
    scores = (Q.float() @ K.float().T) / math.sqrt(Q.shape[-1])
    bias = -distance.float().square() / (2 * sigma * sigma)
    scores = scores + bias  # 直接使用 log RBF，避免 exp 后再 log 的下溢/eps 偏差
    if allowed is not None:
        assert bool(allowed.any(dim=-1).all())
        scores = scores.masked_fill(~allowed, -torch.inf)
    return torch.softmax(scores, dim=-1) @ V.float()
```

- **欧氏坐标 [v]**：δ_ij=‖x_i−x_j‖₂ 对共同平移/正交变换不变；`MLP(x_i-x_j)` 一般只平移不变，不自动旋转不变。
- **树距离 [v]**：无权树上 δ(i,j)=depth(i)+depth(j)−2depth(LCA(i,j))；LCA 深度本身不是距离。
- **流形 [~]**：从显式 positions 参数计算相应测地距，再传给基线；一般流形没有全局坐标减法，cut locus 或重合点附近梯度也需检查。
- **多维 RoPE [~]**：多个 SO(2) 旋转块形成 SO(2)^k 的块对角表示，嵌入 SO(2k)；这不等于任意 SO(2k) 旋转都保留所需相对位置性质。

## 可实现结构
距离偏置、树位置偏置和分子距离特征可分别消融。若要求输出旋转等变，Value 的表示、内容得分、mask、非线性和输出映射也须兼容；只有距离项不变不够。

## GPU 可行性
- **D1/D2 [v]**：QK 和 AV 是 GEMM，偏置是加法。**[~]** 距离本身可能是归约、图算法或迭代求解，不能一律称为逐元素运算。
- **D3 [v]**：s 维欧氏两两距离朴素成本 O(mns)，attention 为 O(mnd+mnd_v)；通用测地距另计求解成本。
- **D4 [v]**：朴素距离/偏置矩阵各需 O(mn) 存储。**[~]** 只有距离可按 tile 在线生成，或有适当预计算访问方案时，才能避免全矩阵物化。
- **D5 [~]**：大坐标差、球面 arccos、双曲 acosh、过小 σ 和平方均可能不稳；直接负平方避免多余 exp/log，但仍需有限值检查与 fp32 对照。
- **D6 [~]**：tile/头可并行，复杂几何求解的依赖另测。
- **D7 [v]**：很小的 softmax 权重不是实际稀疏计算。**[~]** 需显式窗口/块 mask 与对应稀疏 kernel 才可能节约运算。
- **D8 [~]**：加法偏置在数学上兼容分块 online softmax，但任意偏置 MLP/测地距不必被现有 FlashAttention API 支持；需实测实现与反向。

## 论文表述方式
“我们用指定度量和非正单调偏置引入局部性，并区分偏置项的不变性与完整模块的等变性。报告不同距离尺度下的质量、距离构建与 attention 总成本，以及实际使用的 kernel 支持范围。”

## 风险
固定几何可能与任务相关性冲突；单调衰减可能压低必要的远程联系。离散图/树结构若不训练，无须为其强造可微松弛；只有对距离或结构求导时才需要明确的梯度/估计方案。任意可学习偏置取消了单调保证，应据实描述。

## 来源
[RoFormer](https://arxiv.org/abs/2104.09864)、[ALiBi](https://arxiv.org/abs/2108.12409)给出具体的位置机制；本文的任意几何扩展仍需独立证明和验证。

度量与正定性的关系见 [Jayasumana 等](https://arxiv.org/abs/1412.0265)。
