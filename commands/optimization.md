---
name: optimization
description: |
  用优化思想在约束条件下寻找最优解或满意解，进行资源分配和决策。
  模式：科研模式适用于数学推导、论文审查、实验设计优化；生活模式适用于日常决策、时间管理、生活规划。
  English: Find optimal or satisfactory solutions under constraints, perform resource allocation and decision-making using optimization.
  Mode: Research mode for mathematical derivation, paper review, experimental design; Life mode for daily decisions, time management, life planning.
---

读取并遵循 `skills/optimization/SKILL.md`。

**模式选择**：如果问题涉及数学推导、论文审查、实验设计优化、需要判断凸性或使用对偶理论，使用**科研模式**；如果问题涉及日常决策、人际互动、时间管理、生活规划、资源分配或取舍判断，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. 一句话概述决策问题。
2. 明确目标函数和约束条件（标注硬约束/软约束）。
3. 分析可行域和可能的最优解。
4. 进行灵敏度分析（影子价格）。
5. 给出明确的行动建议。
6. 如果信息不足，先指出缺口，再基于现有事实分析。

生活模式输出要求：
1. 一句话说清"我最想要什么"。
2. 列出限制条件（标注不可逾越/可以协商）。
3. 在这些限制下，实际有哪些选择。
4. 哪个限制一旦放宽收益最大。
5. 给出明确的行动建议。
6. 如果信息不足，先指出缺口，再基于现有事实分析。