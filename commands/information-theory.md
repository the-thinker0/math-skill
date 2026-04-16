---
name: information-theory
description: |
  用信息论思想量化不确定性、评估信息价值、优化通信与压缩。
  English: Quantify uncertainty, assess information value, and optimize communication and compression using information theory thinking.
---

读取并遵循 `skills/information-theory/SKILL.md`。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

输出要求：
1. 一句话概述问题。
2. [信息源]: [描述] H(X) = [值]——定义随机变量 X，计算其熵，量化当前不确定性。
3. [信息增益]: I(X;Y) = [值]——计算互信息，识别最有价值的观察 Y。
4. [编码策略]: [选择]——信源编码（压缩）或信道编码（纠错），说明逼近哪种极限。
5. [信道容量]: C = [值]——计算信道容量，比较传输速率 R 与 C。
6. [信息准则]: [AIC/BIC/KL/MDL]——说明选择的信息准则及理由。
7. [最优决策]: [说明]——基于信息增益最大化或 KL 散度最小化的决策建议。