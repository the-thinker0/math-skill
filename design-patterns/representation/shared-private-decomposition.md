# Shared-Private Decomposition（共享-私有分解）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
多任务/多领域学习中，需要将表示分解为"跨任务共性部分"和"任务特异部分"。
典型场景：(1) 多任务 MoE——Shared 专家处理语言共性，Private 专家处理任务特异逻辑；
(2) 多领域适配——Shared 表示捕获通用语义，Private 表示捕获领域术语；
(3) 持续学习——Shared 保留稳定知识，Private 容纳新知识而不干扰旧知识。
核心诉求：**显式分离共性与个性，避免负迁移和灾难性遗忘**。

## 数学思想来源
- 透镜：../../lenses/projection.md（子空间分解、直和分解）、../../lenses/probabilistic.md（信息分解）
- 知识：../../knowledge-base/matrix-analysis/projection.md（直和分解 V = U ⊕ W、投影算子）、
  ../../knowledge-base/probability/kl-divergence.md（信息分解：shared/synergy/unique）

## 需要的数学知识
- **直和分解**：R^d = S ⊕ P，其中 S ∩ P = {0}，每个 x = x_S + x_P 唯一
  投影矩阵 P_S + P_P = I，P_S · P_P = 0
- **信息分解 (Williams & Beer PID)**：
  I(X;Y₁,Y₂) = Shared + Unique₁ + Unique₂ + Synergy
  Shared 为冗余信息项；min(I(X;Y₁), I(X;Y₂)) 只是早期/简化代理，不是 Williams-Beer 冗余的一般定义
- **低秩+稀疏分解 (RPCA)**：M = L + S，L 低秩（共性）+ S 稀疏（特异）
  通过核范数 + L1 范数凸松弛求解
- **CCA (典型相关分析)**：max corr(W₁^T X, W₂^T Y)，提取两组变量的共享变异

## AI 模块形式

```python
z_shared = shared_encoder(X)
z_private = private_encoder[task](X)
z = shared_to_output(z_shared) + private_to_output(z_private)

# 判别器最小化CE；梯度反转使共享编码器最大化它。
L_domain = cross_entropy(domain_classifier(gradient_reverse(z_shared)), task)
L_task = task_loss(task_head(z), target)
L = L_task + lambda_adv * L_domain + lambda_decorr * decorrelation(z_shared, z_private)
```
有限判别器预测不出任务，不证明任务独立。用更强留出探针、任务迁移及表示坍塌检查。私有分支预测任务标签是可选目标，可能只鼓励记忆任务ID，而非有用任务专属信息。

加法要求分支输出形状兼容；否则各自映射到共同输出维数或拼接。按参数/计算预算及任务消融选择共享/私有宽度，不存在通用 $dT/(T+1)$ 分配定律。非线性分支加去相关惩罚不会自动构成子空间直和分解。

## 可实现结构
- **双编码器 + 融合层**：shared_encoder (大) + T 个 private_encoder (小) + fusion
- **参数效率**：private 用 LoRA（低秩适配）而非完整编码器，参数 O(d·r) per task
- **动态路由集成**：shared 专家 + private 专家通过 MoE 路由选择
- **渐进扩展**：新任务时只增加 private 编码器，frozen shared 参数

## GPU 可行性

- **D1/D2[~]**：共享/私有编码器是普通神经模块，成本由实际深度和宽度决定。
- **D3/D4[~]**：若每 token 只用一个私有分支，成本为 $C_{shared}(X)+\sum_t C_{private,t}(X_t)$，且 $\sum_t|X_t|=N$，不是通用两倍稠密成本。除按需加载外需存全部私有参数；优化器状态也随任务数增长。
- **D5[~]**：梯度反转是符号/尺度乘法，本身不强制 fp32；按 logits、归约和对抗稳定性作精度诊断。
- **D6/D8[~]**：分支可在硬件上重叠，但收益取决于资源争用及传输成本；融合主要适用于小型组合操作。
- **D7[~]**：只有跳过非活跃分支才节省条件执行工作；这不是稀疏权重存储。

## 论文表述方式
"将多任务表示空间 R^d 分解为共享子空间 S 与任务私有子空间 P：共享分支通过对抗训练降低任务可识别性，私有分支通过正交/去相关正则减少与共享分支的线性重叠。信息互补与负迁移降低需通过任务间迁移矩阵、互信息/PID 代理和消融实验验证，不能仅由正交性自动保证。"

## 风险
- 对抗训练的 min-max 优化不稳定，梯度反转的 scale 和 λ_adv 需精心调节
- Shared 过度压缩导致共性信息不足，Private 负担过重
- T 增大时 Private 参数总量线性增长，需要 LoRA 或 adapter 控制
- 任务相似度低时 Shared 可能学到空洞的"公共部分"
