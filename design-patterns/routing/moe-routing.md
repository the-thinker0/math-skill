# MoE Routing（混合专家路由）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
大规模模型中需要动态选择少量专家处理每个 token，以实现参数扩展而推理代价可控。
典型场景：(1) Sparse MoE 层——每个 token 选择 top-k 专家（k<<K）；
(2) Shared+Private 专家混合——共享专家处理通用特征，私有专家处理特异特征；
(3) 多粒度 MoE——不同层使用不同粒度的专家分工。
核心诉求：**稀疏激活、负载均衡、端到端可训练**。

## 数学思想来源
- 透镜：../../lenses/variational.md（离散优化松弛、Gumbel-Softmax）、../../lenses/probabilistic.md（信息论路由）
- 知识：../../knowledge-base/optimization/lagrangian-duality.md（对偶分解、拉格朗日松弛）、
  ../../knowledge-base/probability/entropy.md（熵正则化、信息瓶颈）

## 需要的数学知识
- **混合模型 EM**：p(y|x) = Σ_k π_k(x) · p(y|x,θ_k)
  E 步估计责任 γ_{nk} = π_k·p(y_n|x_n,θ_k) / Σ_j π_j·p(y_n|x_n,θ_j)
  M 步更新专家参数 θ_k 和混合权重 π_k
- **Top-k 稀疏 Gate**：G(x) = Softmax(TopK(x·W_g))
  TopK 索引离散，但入选值保留分段梯度；噪声/STE 是可选设计，top-1 权重须按下文明确口径
- **负载均衡辅助损失**：L_aux = α · K · Σ_k f_k · P_k
  f_k = 分配到专家 k 的 token 比例，P_k = 专家 k 的平均门控概率
- **Expert Choice Routing**：专家主动选择 token，而非 token 选择专家
  score_{ki} = sim(e_k, x_i)，每个专家选 top-C 个 token

## AI 模块形式

```python
# K个专家中选k个；可选噪声应作为单独变体验证
logits = (X @ W_gate).float()
p_full = softmax(logits, dim=-1)
topk_idx = topk(logits, k, dim=-1).indices
selected_p = gather(p_full, topk_idx)
# top-1保留完整softmax概率，使任务损失能向router传梯度。
gate_weights = selected_p if k == 1 else selected_p / selected_p.sum(-1, keepdim=True)
output = dispatch_compute_combine(X, topk_idx, gate_weights)

# 在 N*k 次分配上归一化负载比例
f = one_hot(topk_idx, K).float().mean(dim=(0, 1)).detach()  # 形状K
P = p_full.mean(dim=0)
L_aux = K * dot(f, P)  # f或P均匀时为1；一般不保证 >= 1
capacity = ceil(capacity_factor * N * k / K)
```
Top-k **索引**离散，但选中权重可获得普通分段梯度；噪声 gate 或 STE 是设计选项，并非所有稀疏 gate 的必需步骤。只对单个入选 top-1 logit 作 softmax 会恒等于1，权重路径任务梯度为0。[Switch Transformer 原论文](https://arxiv.org/abs/2101.03961)。

Expert-choice 由每个专家选择 top-$C$ token，固定专家负载，但每个 token 的专家数可变，甚至没有被选。需明确组合权重及 fallback。共享专家另有稠密路径成本。溢出处理需明确：丢弃、残差旁路、重路由或无丢弃执行。

## 可实现结构

- gate 网络与 dispatch/combine 配合明确的选中概率口径。
- 一个设备可放多个专家；按实际放置方式计 token 交换。
- 容量计入选分配数，因此随 `N*k/K` 缩放。
- router z-loss 正则 logsumexp 大小；报告溢出、各专家负载及 gate 梯度。

## GPU 可行性

- **D1/D2[~]**：gate 用 GEMM；专家 FFN 用 grouped/batched GEMM，另有 gather/scatter 分发开销。
- **D3[~]**：gate 为 $O(NdK)$；均衡时每专家负载 $Nk/K$，成本 $O((Nk/K)dd_{ff})$，总计 $O(Nkdd_{ff})$。共享专家及容量填充另计。
- **D4[~]**：全部 $K$ 组专家参数都存在；激活显存取决于容量填充、checkpoint 与并发，不只是入选参数比例。
- **D5[~]**：按需以 fp32 计算路由 logits/softmax/归约；测量并列附近 top-k 不稳定。
- **D6[~]**：通信由远程入选分配决定，全远程情况约 $O(Nkd)$ 元素外加 combine 流量；设备拓扑及专家位置决定各设备负载。
- **D7[~]**：稀疏激活属于条件计算，不代表专家稠密权重矩阵稀疏。
- **D8[~]**：router 与 dispatch 融合需具体实现；最终加权求和之前还有专家计算。

## 论文表述方式
"采用 noisy top-k 门控实现稀疏混合专家路由，每个 token 仅激活 k 个专家以降低激活计算，同时用负载均衡辅助损失 L_aux = K·⟨f,P⟩ 和 Router Z-loss 稳定路由 logits。论文中应报告专家利用率、溢出率、all-to-all 通信占比，以及同等 FLOPs/参数预算下相对 dense baseline 的实测质量差异；不得用未实测的固定百分比占位。"

## 风险
- 负载不均衡：少数专家被过度选择（马太效应），其余专家得不到训练
- Top-k 操作不可微，straight-through 估计引入梯度偏差
- All-to-all 通信在多 GPU 下成为瓶颈，尤其 k>1 时通信量翻倍
- 噪声注入虽促进探索但增加训练方差，需 careful annealing
