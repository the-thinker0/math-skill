---
name: causal-inference
description: |
  区分因果与相关、评估干预效果、进行反事实推理，回答"如果做了X会怎样"。
  模式：科研模式适用于干预效果评估、政策评估、DAG建模；生活模式适用于区分原因与借口、反事实思考、评估某事是否真的有效。
  English: Distinguish causation from correlation, evaluate intervention effects, perform counterfactual reasoning, and answer "what if we did X?"
  Mode: Research mode for intervention effect evaluation, policy evaluation, DAG modeling; Life mode for distinguishing cause from excuse, counterfactual thinking, evaluating whether something truly works.
---

读取并遵循 `skills/causal-inference/SKILL.md`。

**模式选择**：如果问题涉及干预效果评估、政策评估、DAG建模、do-calculus、反事实推理的数学形式化，使用**科研模式**；如果问题涉及区分原因与借口、反事实思考、评估某事是否真的有效、判断"做了X会怎样"而非"看到X时如何"，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. 一句话概述因果问题（区分"看到"vs"做了"vs"想象"）。
2. 画出因果 DAG 并标注因果假设依据。
3. 识别混淆变量（列表标注可观测/不可观测）。
4. 选择识别策略（后门/前门/do算子/IV/DD）并计算 P(y|do(x))。
5. 进行反事实分析（对关键个体或子群体）。
6. 说明验证方法（RCT/自然实验/IV/DD）。
7. 进行敏感性分析（评估因果结论对未观测混淆的脆弱性）。

生活模式输出要求：
1. **[因果链]:[分析]** — X真的导致Y吗？还是它们只是恰好同时出现？画出因果链。
2. **[隐藏因素]:[列表]** — 有没有同时影响X和Y的隐藏因素。
3. **[真实效果]:[判断]** — 如果我真的做了X，结果会怎样（而不是"看到X时结果如何"）。
4. **[反事实]:[思考]** — 如果当初没做X/做了X，结果会怎样。
5. **[验证方式]:[建议]** — 如何验证这个因果判断是否可靠。
6. **[行动建议]:[步骤]** — 在当前因果判断下最务实的行动方案。