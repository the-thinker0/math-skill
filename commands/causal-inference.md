---
name: causal-inference
description: |
  区分因果与相关、评估干预效果、进行反事实推理，回答"如果做了X会怎样"。
  English: Distinguish causation from correlation, evaluate intervention effects, perform counterfactual reasoning, and answer "what if we did X?"
---

读取并遵循 `skills/causal-inference/SKILL.md`。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

输出要求：
1. 一句话概述因果问题（区分"看到"vs"做了"vs"想象"）。
2. 画出因果 DAG 并标注因果假设依据。
3. 识别混淆变量（列表标注可观测/不可观测）。
4. 选择识别策略（后门/前门/do算子/IV/DD）并计算 P(y|do(x))。
5. 进行反事实分析（对关键个体或子群体）。
6. 说明验证方法（RCT/自然实验/IV/DD）。
7. 进行敏感性分析（评估因果结论对未观测混淆的脆弱性）。