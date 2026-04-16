---
name: discrete-combinatorial
description: |
  用离散与组合思想分析计数、枚举、生成函数、鸽巢原理与图论问题。
  模式：科研模式适用于组合计数、图论分析、生成函数计算；生活模式适用于系统性枚举、鸽巢推理、组织有限选项。
  English: Analyze counting, enumeration, generating functions, pigeonhole principle, and graph theory problems using discrete and combinatorial thinking.
  Mode: Research mode for combinatorial counting, graph theory analysis, generating function computation; Life mode for systematic enumeration, pigeonhole reasoning, organizing finite options.
---

读取并遵循 `skills/discrete-combinatorial/SKILL.md`。

**模式选择**：如果问题涉及正式计数、公式推导、存在性证明、生成函数、图论分析等组合数学问题，使用**科研模式**；如果问题涉及日常选择中的系统性枚举、鸽巢推理（选项比需求多则必有重复）、组织有限选项、发现规律，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. 一句话概述问题及其离散结构与计数类型。
2. 说明选择的基本计数原理（乘法/加法/鸽巢/容斥）及理由。
3. 给出生成函数构造（如适用）及其代数性质。
4. 给出图结构分析（如涉及）及关键属性。
5. 给出递推关系与封闭公式（如适用）。
6. 用小案例（n=0,1,2,3）验证公式，对比手动枚举与公式计算结果。
7. 如果信息不足，先指出缺口，再基于现有事实分析。

生活模式输出要求：
1. **[问题类型]:[分类]** — 有限选择/排列/分配/关系。
2. **[可能数量]:[粗略估计]** — 选项很多还是只有几种。
3. **[系统性枚举]:[方法]** — 有没有遗漏。
4. **[关系结构]:[分析]** — 事物之间的连接方式。
5. **[规律发现]:[模式]** — 能否从已知推导未知。
6. **[行动建议]:[步骤]** — 基于枚举和规律的结论。