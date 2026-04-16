---
name: probability-statistics
description: |
  用概率与统计量化不确定性、从数据提取规律、评估风险和检验显著性。
  模式：科研模式适用于统计分析、假设检验、回归建模、实验设计、因果推断；生活模式适用于风险评估、解读新闻数据、日常不确定性决策。
  English: Quantify uncertainty, extract patterns from data, assess risk and test significance using probability and statistics.
  Mode: Research mode for statistical analysis, hypothesis testing, regression modeling, experimental design, causal inference; Life mode for risk assessment, interpreting news data, evaluating uncertainty in daily decisions.
---

读取并遵循 `skills/probability-statistics/SKILL.md`。

**模式选择**：如果问题涉及统计分析、假设检验、回归建模、实验设计、因果推断，使用**科研模式**；如果问题涉及风险评估、解读新闻数据、日常不确定性决策，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. **随机变量定义**：明确 `[变量]: [含义] [类型: 离散/连续]`，指定样本空间 Ω 和事件域 𝔽
2. **概率模型**：说明使用的分布及理由 `[分布]: [选择] 因为 [理由]`，注明自由度 df 或关键参数
3. **数据评估**：`[样本量]: N, [偏差检查]: [结果], [质量]: [评估], [收集方式]: [随机/方便]`
4. **统计推断结果**：`[估计值]: [θ̂], [置信区间]: [a, b], [p-value]: [值], [估计方法]: [MLE/Bayesian]`
5. **回归建模（如适用）**：`[模型]: [线性/逻辑], [系数]: [β̂], [选择准则]: [AIC/BIC值], [R²]: [值]`
6. **实验设计评估（如适用）**：`[设计]: [随机化/区组/因子], [功效]: [Power值], [最小样本量]: [n]`
7. **因果评估（如适用）**：`[DAG]: [路径图], [混淆变量]: [列表], [调整集]: [S], [因果效应]: [P(Y|do(X))]`
8. **偏差检查**：逐一检查常见统计谬误，标注 `✅ 无此问题` 或 `⚠️ 发现 [具体问题]`
9. **效应量与不确定性**：报告效应量 Cohen's d / odds ratio 及其置信区间，注明统计功效和剩余不确定性

生活模式输出要求：
1. **[不确定性]:[描述]** — 你面对的不确定性是什么
2. **[已知信息]:[列表]** — 你对这件事了解多少，信息质量如何
3. **[大概率结论]:[判断]** — 基于现有信息最可能的结论是什么
4. **[不确定性余量]:[评估]** — 结论有多可靠，还剩多少不确定
5. **[验证方式]:[建议]** — 如何进一步验证这个结论
6. **[行动建议]:[步骤]** — 在当前不确定性下最务实的行动方案