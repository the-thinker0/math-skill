# Shared-Private Decomposition（共享-私有分解）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「[v] 已验证 / [~] 可改造需验证 / [x] 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
多任务/多领域学习中，需要将表示分解为"跨任务共性部分"和"任务特异部分"。
典型场景：(1) 多任务 MoE——Shared 专家处理语言共性，Private 专家处理任务特异逻辑；
(2) 多领域适配——Shared 表示捕获通用语义，Private 表示捕获领域术语；
(3) 持续学习——Shared 保留稳定知识，Private 容纳新知识而不干扰旧知识。
核心诉求：**显式分离共性与个性，避免负迁移和灾难性遗忘**。

## 数学思想来源
- 透镜：lenses/projection.md（子空间分解、直和分解）、lenses/probabilistic.md（信息分解）
- 知识：knowledge-base/matrix-analysis/projection.md（直和分解 V = U ⊕ W、投影算子）、
  knowledge-base/probability/kl-divergence.md（信息分解：shared/synergy/unique）

## 需要的数学知识
- **直和分解**：R^d = S ⊕ P，其中 S ∩ P = {0}，每个 x = x_S + x_P 唯一
  投影矩阵 P_S + P_P = I，P_S · P_P = 0
- **信息分解 (Williams & Beer PID)**：
  I(X;Y₁,Y₂) = Shared + Unique₁ + Unique₂ + Synergy
  Shared = min(I(X;Y₁), I(X;Y₂)) 的冗余信息部分
- **低秩+稀疏分解 (RPCA)**：M = L + S，L 低秩（共性）+ S 稀疏（特异）
  通过核范数 + L1 范数凸松弛求解
- **CCA (典型相关分析)**：max corr(W₁^T X, W₂^T Y)，提取两组变量的共享变异

## AI 模块形式
```
模块：SharedPrivateDecomposer
输入：X ∈ R^{N×d}，任务标识 t ∈ {1,...,T}

方法1 - 加法分解（最常用）：
  z_shared = E_shared(X)          // 共享编码器：MLP or Transformer block
  z_private = E_private[t](X)     // 私有编码器：每个任务独立参数
  z = z_shared + z_private        // 加法融合
  // 训练目标：L_task(z, y) + λ₁·OrthLoss(z_shared, z_private)
  // 正交性确保 shared 和 private 学到不同的东西

方法2 - 门控分解（动态权重）：
  z_shared = E_shared(X)
  z_private = E_private[t](X)
  gate = sigmoid(Linear(z_shared ⊕ z_private))  // 动态融合门
  z = gate ⊙ z_shared + (1 - gate) ⊙ z_private
  // 门控允许逐维度选择 shared/private 的贡献比例

方法3 - 对抗分解（信息论保证）：
  z_shared = E_shared(X)
  z_private = E_private[t](X)
  // Shared 应无法区分任务（对抗梯度）：
  task_pred = classifier(z_shared.flip_gradient())
  L_adv = -CE(task_pred, t)       // Shared 不含任务信息
  // Private 应能区分任务：
  L_private = CE(classifier(z_private), t)
  L = L_task + λ_adv·L_adv + λ_priv·L_private

维度分配原则：
  d_shared = d · T/(T+1)          // T 个任务时 shared 占大部分
  d_private = d · 1/(T+1)         // 每个 private 占较小部分
  // 或用 PCA 变异解释率动态分配
```

## 可实现结构
- **双编码器 + 融合层**：shared_encoder (大) + T 个 private_encoder (小) + fusion
- **参数效率**：private 用 LoRA（低秩适配）而非完整编码器，参数 O(d·r) per task
- **动态路由集成**：shared 专家 + private 专家通过 MoE 路由选择
- **渐进扩展**：新任务时只增加 private 编码器，frozen shared 参数

## GPU 可行性
- **张量化**：两个编码器前向为独立 GEMM 链，可并行执行
- **GEMM 可映射**：shared/private 编码器各为标准 Transformer FFN（2×GEMM）
- **复杂度**：shared O(N·d²) + T 个 private O(N·d²/T)，总 ≈ 2× 单编码器
- **显存与 KV-Cache**：T 个 private 编码器参数全存储，T 大时需 LoRA 压缩
- **低精度稳定**：加法/门控融合在 fp16 安全；对抗训练的梯度反转需 fp32
- **并行与通信**：shared 和 private 编码器可分配到不同 GPU；多任务 batch 混合训练
- **稀疏结构**：private 编码器可稀疏化（仅当前任务激活），T 个中仅激活 1 个
- **算子融合**：加法融合 trivial；门控融合的 sigmoid→multiply→add 可融合

## 论文表述方式
"将多任务表示空间 R^d 分解为直和 S ⊕ P，Shared 子空间通过对抗训练确保任务无关性
（H(T|Z_s)→log T），Private 子空间通过正交正则保证与 Shared 的信息互补，
理论分析表明负迁移随正交性以 O(‖P_S·P_P‖_F) 衰减。"

## 风险
- 对抗训练的 min-max 优化不稳定，梯度反转的 scale 和 λ_adv 需精心调节
- Shared 过度压缩导致共性信息不足，Private 负担过重
- T 增大时 Private 参数总量线性增长，需要 LoRA 或 adapter 控制
- 任务相似度低时 Shared 可能学到空洞的"公共部分"
