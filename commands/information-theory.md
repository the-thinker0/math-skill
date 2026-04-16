---
name: information-theory
description: |
  用信息论思想量化不确定性、评估信息价值、优化通信与压缩。
  模式：科研模式适用于熵计算、信道容量、编码理论、模型选择；生活模式适用于评估信息价值、减少冗余、判断该获取哪些信息。
  English: Quantify uncertainty, assess information value, and optimize communication and compression using information theory thinking.
  Mode: Research mode for entropy computation, channel capacity, coding theory, model selection; Life mode for assessing information value, reducing redundancy, evaluating what information to seek.
---

读取并遵循 `skills/information-theory/SKILL.md`。

**模式选择**：如果问题涉及熵计算、信道容量、编码理论、模型选择等信息论数学形式化问题，使用**科研模式**；如果问题涉及评估信息价值、减少冗余、判断该获取哪些信息等日常信息决策问题，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. 一句话概述问题。
2. [信息源]: [描述] H(X) = [值]——定义随机变量 X，计算其熵，量化当前不确定性。
3. [信息增益]: I(X;Y) = [值]——计算互信息，识别最有价值的观察 Y。
4. [编码策略]: [选择]——信源编码（压缩）或信道编码（纠错），说明逼近哪种极限。
5. [信道容量]: C = [值]——计算信道容量，比较传输速率 R 与 C。
6. [信息准则]: [AIC/BIC/KL/MDL]——说明选择的信息准则及理由。
7. [最优决策]: [说明]——基于信息增益最大化或 KL 散度最小化的决策建议。

生活模式输出要求：
1. **[核心不确定性]:[描述]** — 你最想搞清楚什么。
2. **[信息价值排序]:[列表]** — 哪些信息最能减少不确定性，价值高低排序。
3. **[信息瓶颈]:[识别]** — 信息传递或获取的限制在哪。
4. **[精炼传递]:[建议]** — 如何用最精炼的方式聚焦关键信息。
5. **[最优解释]:[判断]** — 哪个解释最简洁且最有力。
6. **[行动建议]:[步骤]** — 在当前信息水平下最务实的行动方案。