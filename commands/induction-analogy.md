---
name: induction-analogy
description: |
  用归纳与类比从特殊到一般发现规律，从已知到未知迁移知识。
  模式：科研模式适用于数学归纳法证明、科学假说生成、科研中的规律发现；生活模式适用于从经验中学习、跨领域借用经验、做出有根据的猜测。
  English: Discover patterns from specific to general, transfer knowledge from known to unknown using induction and analogy.
  Mode: Research mode for mathematical induction proofs, scientific hypothesis generation, pattern discovery in research; Life mode for learning from experience, cross-domain borrowing, making educated guesses.
---

读取并遵循 `skills/induction-analogy/SKILL.md`。

**模式选择**：如果问题涉及数学归纳法证明、科学假说生成、规律发现与结构映射度量，使用**科研模式**；如果问题涉及从经验中学习、跨领域借用经验、做出有根据的猜测，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. **案例清单**：列出所有观察到的具体案例 `[案例N]: [描述] [关键特征]`，确保覆盖边界值与极端值
2. **模式识别**：`[共同模式]: [描述] [出现频率: N/M] [差异模式]: [描述]`，注意是否有 Borwein 型突然破坏
3. **假说表述**：用精确语言表述假说 `[假说]: [内容] [类型: 强/弱/条件]`，优先尝试强假说
4. **反例搜索**：`[反例]: [找到/未找到]。如找到: [描述]，假说修正: [新表述]`
5. **证明方向**：如适用，选择归纳变体 `[归纳类型: 弱/强/结构/超限]` 并给出证明思路；说明为何选择该变体
6. **类比映射**：`[源领域A] → [目标领域B]: [对应关系] [结构相似度: X/Y] [有效性: 高/中/低]`，逐项检验组件、关系、操作
7. **假说修正**：如需修正，记录 `[修正方式: 怪物排除/引理吸收/策略修订] [修正后假说]`

生活模式输出要求：
1. **[观察案例]:[列表]** —— 具体观察到什么
2. **[共同模式]:[发现]** —— 案例之间的共同点
3. **[初步猜测]:[提出]** —— 基于模式提出什么假设
4. **[反例检查]:[验证]** —— 有没有反例推翻猜测
5. **[经验迁移]:[评估]** —— 能否将经验迁移到其他领域（核心结构是否相似）
6. **[修正方向]:[建议]** —— 如果有反例，如何修正猜测