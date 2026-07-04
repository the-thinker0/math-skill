# Constraint Penalty（约束惩罚损失）

## 适用问题
当设计中有硬约束（如概率单纯形、正交性、容量限制、负载均衡）但需要端到端训练时使用。
典型场景：(1) MoE 路由概率必须在 K-simplex 上且负载均衡；(2) 专家激活数量受限（top-k）；
(3) 子空间投影矩阵必须满足正交性 W^TW = I；(4) 特征范数有界 ‖z‖ ≤ R。
核心诉求：**将数学约束转化为可微惩罚项，融入梯度优化流程**。

## 数学思想来源
- 透镜：lenses/variational.md（约束优化、拉格朗日对偶、KKT 条件）、lenses/geometric.md（流形投影）
- 知识：knowledge-base/optimization/lagrangian-duality.md（增广拉格朗日法、惩罚函数法）、
  knowledge-base/matrix-analysis/projection.md（投影算子、约束集）

## 需要的数学知识
- **罚函数法**：min f(x) s.t. g(x)=0 → min f(x) + ρ/2 · ‖g(x)‖²
  ρ 逐步增大（外点法），约束违反量 ‖g(x)‖ → 0
- **增广拉格朗日法**：min f(x) + λ^T g(x) + ρ/2 · ‖g(x)‖²
  引入对偶变量 λ，交替更新 λ ← λ + ρ·g(x) 和优化 x，比纯罚函数收敛更好
- **投影梯度法**：x_{k+1} = Proj_C(x_k - α∇f(x_k))
  对简单约束集 C（如 simplex、球面）有闭合投影公式
- **屏障函数法**：min f(x) - μ Σ log(-g_i(x))  对不等式约束 g_i(x) ≤ 0
  μ → 0 时逼近约束最优解

## AI 模块形式
```
模块：ConstraintPenalty
输入：约束违反量 g(x) ∈ R^m（等式约束），h(x) ∈ R^p（不等式约束）

方法1 - 自适应罚函数（最常用）：
  L_penalty = Σ_i ρ_i/2 · g_i(x)²  +  Σ_j ρ_j/2 · max(0, h_j(x))²
  // ρ 动态更新：每个 epoch ρ_i *= γ（γ=2~10）直到约束满足
  // 不同约束可有不同的 ρ，按违反程度自适应

方法2 - 增广拉格朗日（ALM）：
  L_ALM = λ^T · g(x) + ρ/2 · ‖g(x)‖²
  // λ 为可学习参数（nn.Parameter），通过梯度上升更新：
  λ.data += ρ * g(x).detach()   // 对偶上升步
  // 比纯罚函数收敛快，避免 ρ → ∞

方法3 - Softmax 投影到单纯形（负载均衡特例）：
  p = softmax(logits / τ)           // 投影到 Δ^{K-1}
  L_balance = ‖p - 1/K‖²            // 均匀性惩罚
  // 或 Switch Transformer 的辅助损失：
  L_aux = K · Σ_k f_k · P_k         // f_k = 分配比例, P_k = 平均概率

方法4 - 正交约束投影：
  W_proj = W · (W^T W)^{-1/2}       // 通过矩阵平方根反投影到 Stiefel 流形
  // 或用 Cayley 变换参数化：W = (I-A)(I+A)^{-1} · W_0, A 为反对称矩阵
```

## 可实现结构
- **Loss Wrapper**：ConstraintLoss(base_loss, constraints, ρ_schedule)
  forward 时计算 base_loss + Σ constraint.penalty()
- **对偶变量管理**：nn.Parameter 存储 λ，optimizer 中为 λ 设置负学习率实现梯度上升
- **warm-up 策略**：前 N 步只优化 base_loss，之后逐步激活约束惩罚
- **约束监控**：每 step 记录 ‖g(x)‖ 用于可视化和自适应 ρ 调整

## GPU 可行性
- **张量化**：约束违反量为向量/矩阵运算，罚项为 element-wise 平方和
- **GEMM 可映射**：负载均衡的 f_k, P_k 计算为 softmax + reduce_sum；正交约束为 matmul
- **复杂度**：罚项计算 O(m) 或 O(m²)，远小于主网络前向，可忽略
- **显存与 KV-Cache**：仅额外存储 λ (m 维) 和 ρ (m 维)，极小开销
- **低精度稳定**：罚项为平方运算，fp16 安全；ALM 的 λ 更新建议 fp32 避免累积误差
- **并行与通信**：各约束独立计算，可并行；多 GPU 时 λ 更新需 all-reduce g(x)
- **稀疏结构**：max(0, h(x))² 在约束满足时梯度为零，天然稀疏激活
- **算子融合**：constraint 计算 + 加权求和 + 与 base_loss 合并可融合为单 kernel

## 论文表述方式
"采用增广拉格朗日法将硬约束 g(x)=0 转化为可微惩罚项 λ^Tg(x) + ρ/2‖g(x)‖²，
通过对偶变量 λ 的交替上升更新，在无需 ρ→∞ 的条件下保证约束满足度以 O(1/ρ) 收敛，
相比纯罚函数法在实验中减少 3× 的约束违反。"

## 风险
- ρ 增大过快导致优化 landscape 病态（条件数恶化），梯度消失或爆炸
- ALM 的 λ 更新频率和步长需调参，更新过快震荡、过慢收敛
- 多个约束同时存在时 ρ 的相对比例影响优化路径
- 投影操作（如矩阵平方根逆）计算代价高且数值不稳定
