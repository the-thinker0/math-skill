---
name: modeling
description: |
  用建模思想将现实问题转化为数学形式、构建模型、预测和解释现象。
  模式：科研模式适用于构建数学模型、实验设计、量纲分析与模型选择；生活模式适用于规划预算、选择路线、风险评估、简化复杂生活决策。
  English: Translate real-world problems into mathematical form, build models, predict and explain phenomena using modeling.
  Mode: Research mode for building mathematical models, experimental design, dimensional analysis and model selection; Life mode for planning budgets, choosing routes, risk assessment, simplifying complex life decisions.
---

读取并遵循 `skills/modeling/SKILL.md`。

**模式选择**：如果问题涉及物理系统建模、实验数据、数学方程、量纲分析，使用**科研模式**；如果问题涉及生活决策、预算规划、风险评估、路线选择，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. **问题定义**：用一句话描述要解决的现实问题
2. **假设清单**：列出 `[假设N]: [内容]（合理性：高/中/低）`
3. **量纲检查**：对关键物理量做量纲分析，构造无量纲 Pi 项
4. **模型选择**：说明使用的数学框架及理由 `[框架]: [选择] 因为 [理由]`
5. **变量定义**：定义所有变量、参数及其物理意义
6. **求解方案**：说明求解方法（解析/数值/定性）
7. **敏感度分析**：识别敏感参数，评估其对输出的影响
8. **模型选择准则**：若有候选模型，用 AIC/BIC/CV 比较并选出最优
9. **验证计划**：如何检验模型的有效性？
10. **适用范围**：明确标注模型在什么条件下有效、什么条件下失效

生活模式输出要求：
1. **[核心问题]:[描述]** — 你到底要解决什么问题
2. **[关键因素]:[列表]** — 哪些因素必须考虑，哪些可以忽略
3. **[因素关系]:[框架]** — 什么影响什么，影响有多大
4. **[初步结论]:[推导]** — 在框架下最可能的结论
5. **[现实检验]:[验证]** — 结论和现实是否一致
6. **[适用范围]:[边界]** — 结论在什么条件下有效