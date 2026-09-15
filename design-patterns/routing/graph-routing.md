# Graph Routing（图路由）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当模块/专家之间存在已知的或可学习的拓扑结构时使用。典型场景：
(1) 层次化 MoE——专家按树形结构组织，路由沿树的边进行；
(2) Pipeline/串行路由——输入按 DAG 顺序经过多个处理阶段；
(3) 空间/时间相关路由——相邻位置的 token 倾向路由到相近专家（空间连续性）；
(4) 知识图谱引导的专家选择——专家按概念图谱组织。
核心诉求：**利用结构化先验约束路由决策，减少搜索空间**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（图拉普拉斯、谱图论）、../../lenses/probabilistic.md（消息传递、信息流）
- 知识：../../knowledge-base/matrix-analysis/projection.md（邻接矩阵、谱分解）、
  ../../knowledge-base/optimization/lagrangian-duality.md（图上优化、扩散过程）

## 需要的数学知识

- 对称非负邻接 $A$ 下，$L=D-A$、$L_{sym}=I-D^{-1/2}AD^{-1/2}$；明确孤立节点处理。
- GCN 平滑使用归一化**邻接** $S=\tilde D^{-1/2}(A+I)\tilde D^{-1/2}$，不是 $L_{sym}$ 本身；$H'=\sigma(SHW)$。
- 随机游走用 $P=D^{-1}A$，需悬挂节点约定。学习的边 logits 可用 mask softmax 归一化；不加 mask 会让不存在的边也为正，改变图。
- Fiedler 向量求解图割目标的连续松弛；阈值化通常不产生精确平衡最小割，也不证明路由多样性。
- 平衡二叉树每 token 访问 $O(\log K)$ 个节点，但通常存 $O(Kd)$ 节点参数，不是 $O(d\log K)$。

## AI 模块形式

```python
# A：非负专家邻接，明确自环/悬挂节点处理
P = A / A.sum(-1, keepdim=True)
route = softmax(X @ W_gate, dim=-1)  # 概率，N x K
for _ in range(t):
    route = route @ P               # 稀疏扩散，不显式构造 P**t

A_tilde = A + eye(K)
deg = A_tilde.sum(-1)
S = deg[:, None]**(-0.5) * A_tilde * deg[None, :]**(-0.5)
H1 = relu(S @ expert_embeddings @ W1)
score = X @ (S @ H1 @ W2).T

# 硬树遍历：每个 token 有自己的当前节点
node = root_index_for_each_token(N)
for level in range(tree_depth):
    p_right = sigmoid((X * node_weights[node]).sum(-1) + node_bias[node])
    take_right = p_right > 0.5
    node = where(take_right, right_child[node], left_child[node])
```
硬遍历含条件分支，决策处不可微；需监督路由、随机估计器或明确的松弛。为可微软路由评估所有分支通常会失去对数级推理成本。

## 可实现结构
- **稀疏邻接矩阵**：用 torch.sparse 存储 A，稀疏 matmul 替代 dense
- **预计算扩散核**：P_t 在训练初期固定，周期性重计算（每 epoch 一次）
- **图结构学习**：A = softmax(MLP(E_i ⊕ E_j)) 参数化边权重，端到端学习
- **层次树实现**：用完全二叉树的数组表示，level-wise 向量化

## GPU 可行性

- **D1/D2[~]**：gate GEMM 加稀疏邻接传播；稀疏 GPU 收益取决于度分布及批处理。
- **D3[~]**：gate 为 $O(NdK)$，$t$ 次稀疏扩散为 $O(tN|E|)$；预计算稠密 $P^t$ 应用为 $O(NK^2)$，且幂可能稠密化。硬平衡树为 $O(Nd\log K)$，含不规则 gather。
- **D4[~]**：图存储 $O(|E|)$；一般二叉树参数 $O(Kd)$；若物化路由概率还需 $O(NK)$。
- **D5[~]**：fp32 累加概率，监控行和漂移及首选分数间隔。
- **D6[~]**：token 及同深度节点可批处理，但遍历层和扩散轮之间串行。
- **D7/D8[~]**：稀疏传播与稠密特征 GEMM 是不同操作；融合及稀疏盈亏点需具体核测量。

## 论文表述方式

“我们用归一化邻接扩散或条件决策树编码指定的专家图，报告遍历深度、访问专家数、混合行为、图消融及实际计算与延迟；谱连通性本身不保证多样性与一致性的权衡。”

## 风险
- 图结构先验不正确时，路由被误导到次优专家
- 图扩散过度平滑（t 过大）导致所有 token 路由到同一专家（oversmoothing）
- 可学习图结构增加参数量和过拟合风险
- 层次树的二分类误差逐层累积，depth 过深时性能下降
