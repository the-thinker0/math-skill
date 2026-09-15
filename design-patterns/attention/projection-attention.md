# 投影注意力 / Projection Attention

> 严谨性约定：[v] 表示可直接核查的数学关系或成本计数；[~] 表示需任务/硬件验证的设计。没有 GPU 基准时不把吞吐、融合或低精度质量标为已验证。

## 适用问题
当 Q/K 的特征维度存在可测冗余，或 Key-cache 存储成为瓶颈时，探索低维特征投影。高维本身不意味着注意力均匀：独立零均值单位方差坐标的点积方差为 d，标准 1/√d 缩放正是为控制这一尺度。是否存在可压缩方向，需观察数据、logit 误差和任务表现。

## 数学思想来源
- 透镜：`../../lenses/projection.md`、`../../lenses/spectral.md`、`../../lenses/probabilistic.md`。
- 知识：`../../knowledge-base/matrix-analysis/projection.md`、`../../knowledge-base/probability/concentration-inequality.md`、`../../knowledge-base/probability/entropy.md`。

## 需要的数学知识
- **JL 的边界**：对独立于随机映射的有限点集，在适当分布、目标维度与失败概率条件下近似保欧氏距离；它不自动证明 softmax 输出或任务质量保持。CountSketch、SRHT 等映射的维度条件须分别核验。
- **两种不同目标**：学习独立的 P_Q、P_K 是新双线性度量；用同一缩放随机映射 P 近似已有内积，则需保持原温度。两者不能共享一条未经说明的保证。
- **子空间截断**：K 的右奇异子空间最小化其未中心化重构误差。KᵀK/n 是二阶矩；减去均值后才是协方差，相应均值项须在重构中处理。

## AI 模块形式
Q∈R^(m×d)、K∈R^(n×d)、V∈R^(n×d_v)，P_Q、P_K∈R^(d×r)：

$$O=\operatorname{softmax}_{j}\left(\frac{(QP_Q)(KP_K)^T}{\tau}+M\right)V.$$

M 是同一可见性 mask，每行至少允许一个 Key。

```python
import math
import torch

def projected_attention(Q, K, V, P_Q, P_K, temperature, allowed=None):
    assert temperature > 0
    Q, K, P_Q, P_K = [x.float() for x in (Q, K, P_Q, P_K)]
    scores = ((Q @ P_Q) @ (K @ P_K).T) / temperature
    if allowed is not None:
        assert bool(allowed.any(dim=-1).all())
        scores = scores.masked_fill(~allowed, -torch.inf)
    return torch.softmax(scores, dim=-1) @ V.float()

# 近似原始 QK^T / sqrt(d)：P 必须在缓存生命周期内固定。
def gaussian_projection(d, r, *, device, dtype):
    return torch.randn(d, r, device=device, dtype=dtype) / math.sqrt(r)
# P = gaussian_projection(...)
# output = projected_attention(Q, K, V, P, P, math.sqrt(Q.shape[-1]))
```

**随机映射的尺度 [v]**：P_ab~N(0,1/r) 时 E[PPᵀ]=I，因此 E[(qP)(kP)ᵀ]=qkᵀ。要近似原 attention，应继续除以 √d；再除以 √r 会额外改变温度。该结论只对投影前的点积期望成立，不代表 softmax 的期望无偏。

**可学习投影 [~]**：可用两个 `torch.nn.Linear(d, r, bias=False)`，调用层为 `P_Q(Q)` 与 `P_K(K)`，而不是把层对象用于 `Q @ P_Q`。√r 是新架构的一种温度选择，需训练/校准。

**数据自适应子空间 [~]**：可用 K 的截断 SVD 得到正交 P，再计算 QP、KP。在线改变 P 会使历史 Key 系数失效；需要重投影、更新旧系数或按块记录各自基底。不能保留旧 KP 却只更新 Query 投影。

## 可实现结构
- 每头选择 r，独立记录 Q/K 投影和温度；多头成本需累加。
- 只保存 KP 时仅压缩 Key，Value 仍为 n×d_v。
- 数据相关投影若用于自回归训练，估计子空间不得读取当前 Query 不可见的未来 token；离线校准后冻结或按前缀更新。

## GPU 可行性
- **D1/D2 [v]**：稠密 QP、KP 和投影后的 QK 是 GEMM；**[~]** Tensor Core 利用率取决于形状、dtype 与实现。
- **D3 [v]**：单头成本 O((m+n)dr+mnr+mnd_v)，含投影、分数与 AV；降低 r 不消除序列二次项，也不降低未压缩 V 的 AV 成本。
- **D4 [v]**：Key 元素数从 nd 降到 nr，另计 dr 投影参数；总 KV 比例为 n(d+d_v)/(nr+nd_v+投影开销)。**[~]** 原始 K 是否释放、峰值工作区和缓存布局需实测。
- **D5 [~]**：正交约束只能限制部分放大，不能保证 bf16 的 logit、softmax 或任务误差；保留 fp32 累加/softmax 基线。
- **D6/D7 [~]**：头间可并行；投影到注意力有数据依赖，稀疏映射可能引入 gather/scatter。
- **D8 [~]**：先投影后调用兼容的注意力 kernel 是一个方案；融合进在线 softmax 需要另写并验证 kernel。

## 论文表述方式
“我们比较学习型与固定随机 Q/K 特征投影，分别说明其温度和近似目标。报告投影成本、Key 与总 KV 字节、attention/output 误差及任务指标。JL 的适用结论限于满足假设的有限点集距离保持。”

## 风险
- 秩太小可能丢弃 query 相关而 Key 方差很小的方向；仅看保留方差不够。
- 正交正则是可选约束，并非防坍缩的通用必需条件；应单独消融。
- 同时计算原始与投影 attention 的残差混合会重新引入原始计算和缓存成本。

## 来源
标准缩放见 [Attention Is All You Need](https://arxiv.org/abs/1706.03762)。本模式沿**特征维**投影；[Linformer](https://arxiv.org/abs/2006.04768)的序列维压缩是不同构造，不能直接借用其线性复杂度主张。

JL 条件可核对 [Dasgupta 与 Gupta](https://cseweb.ucsd.edu/~dasgupta/papers/jl.pdf)。
