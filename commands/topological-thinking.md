---
name: topological-thinking
description: |
  用拓扑思想关注连续变形下不变的性质、连通结构、洞与空洞的分类，以及拓扑数据分析。
  模式：科研模式适用于拓扑数据分析、持续同调、同调计算；生活模式适用于理解连通性、鲁棒性分析、识别变化中持续存在的事物。
  English: Focus on properties preserved under continuous deformation, connectivity structure, classification via holes and voids, and topological data analysis.
  Mode: Research mode for topological data analysis, persistent homology, homology computation; Life mode for understanding connectivity, robustness analysis, recognizing what persists through change.
---

读取并遵循 `skills/topological-thinking/SKILL.md`。

**模式选择**：如果问题涉及拓扑数据分析、持续同调、同调计算、单纯复形与滤流等数学/计算任务，使用**科研模式**；如果问题涉及连通性理解、鲁棒性判断、识别变化中的不变、判断表面不同的事物是否本质同类，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. 一句话概述问题的拓扑本质。
2. 识别连续性要求（同胚/同伦/微分同胚），明确什么可变、什么必须固定。
3. 列出所有可计算的拓扑不变量（χ、π₁、β_n、连通性、紧致性）。
4. 用不变量对研究对象进行分类。
5. 构造拓扑模型（单纯复形/滤流/持续同调/网络图）并验证拓扑等价。
6. 基于拓扑性质给出推理结论。

生活模式输出要求：
1. **[什么可变/什么不变]:[区分]** — 精确数值不重要，什么核心特征必须保持。
2. **[不变特征]:[发现]** — 不管怎么变化，什么始终存在。
3. **[本质分类]:[判断]** — 看似不同的东西核心是否同类。
4. **[连接结构]:[分析]** — 事物之间的连通、断裂、循环、空洞。
5. **[结构可靠性]:[验证]** — 识别的结构是否真的可靠。
6. **[行动建议]:[步骤]** — 基于结构洞察的结论。