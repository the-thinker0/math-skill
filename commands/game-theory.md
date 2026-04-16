---
name: game-theory
description: |
  用博弈论思想分析多方互动决策、计算纳什均衡、设计激励机制。
  模式：科研模式适用于多方决策分析、机制设计、纳什均衡计算；生活模式适用于谈判策略、竞争分析、人际互动。
  English: Analyze multi-party strategic interactions, compute Nash equilibria, and design incentive mechanisms using game theory.
  Mode: Research mode for multi-party decision analysis, mechanism design, Nash equilibrium computation; Life mode for negotiation strategies, competitive analysis, interpersonal interaction.
---

读取并遵循 `skills/game-theory/SKILL.md`。

**模式选择**：如果问题涉及数学建模、论文分析、算法设计中的多方互动决策、纳什均衡计算、机制设计，使用**科研模式**；如果问题涉及日常决策受他人影响、人际互动策略、谈判与利益协调、生活规划中的冲突与竞争，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. 一句话概述博弈问题（参与者、策略、核心冲突）。
2. 明确参与者列表、策略集和支付函数/矩阵（标注信息结构）。
3. 分析占优策略并消去劣策略，缩小策略空间。
4. 计算纳什均衡（纯策略和/或混合策略），标注多重均衡及其帕累托排序。
5. 分类博弈类型并选择对应分析工具（零和/序列/合作/重复）。
6. 检查均衡稳定性（颤抖手完美/演化稳定/偏离路径激励）。
7. 若均衡不理想，提出机制设计建议（改变支付/增加规则/引入声誉/拍卖设计）。

生活模式输出要求：
1. **[参与者]:[谁在影响你的决策]** — 列出所有相关方及其可能的行动。
2. **[得失]:[各方的利益]** — 不同选择下每个人的得失。
3. **[稳定状态]:[分析]** — 是否存在没人愿意单方面改变的策略组合？标注多重稳定状态。
4. **[互动类型]:[竞争/合作/谈判]** — 分类互动结构，选择对应策略。
5. **[稳定性]:[评估]** — 这个稳定状态是否对小错误鲁棒？能否在重复互动中持续？
6. **[规则建议]:[改进]** — 如果当前规则下结局不理想，如何改变规则让好结局更自然。