---
name: game-theory
description: |
  用博弈论思想分析多方互动决策、计算纳什均衡、设计激励机制。
  English: Analyze multi-party strategic interactions, compute Nash equilibria, and design incentive mechanisms using game theory.
---

读取并遵循 `skills/game-theory/SKILL.md`。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

输出要求：
1. 一句话概述博弈问题（参与者、策略、核心冲突）。
2. 明确参与者列表、策略集和支付函数/矩阵（标注信息结构）。
3. 分析占优策略并消去劣策略，缩小策略空间。
4. 计算纳什均衡（纯策略和/或混合策略），标注多重均衡及其帕累托排序。
5. 分类博弈类型并选择对应分析工具（零和/序列/合作/重复）。
6. 检查均衡稳定性（颤抖手完美/演化稳定/偏离路径激励）。
7. 若均衡不理想，提出机制设计建议（改变支付/增加规则/引入声誉/拍卖设计）。