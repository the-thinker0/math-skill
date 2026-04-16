---
name: symmetry-invariance
description: |
  用对称与不变性寻找变化中的不变性质、揭示隐藏规律、分类研究对象。
  模式：科研模式适用于群论分析、Galois理论、Noether定理、轨道分类与商空间推理；生活模式适用于寻找变化中的规律、识别混乱中不变的东西、判断表面不同的事物本质是否相同。
  English: Find invariants amidst change, reveal hidden patterns, classify objects using symmetry and invariance.
  Mode: Research mode for group theory, Galois theory, Noether theorem, orbit classification, quotient space reasoning; Life mode for finding patterns amidst change, recognizing constants amid chaos, judging whether superficially different things are fundamentally the same.
---

读取并遵循 `skills/symmetry-invariance/SKILL.md`。

**模式选择**：如果问题涉及群论、不变量计算、Galois理论、Noether定理、轨道分类等正式数学结构，使用**科研模式**；如果问题涉及寻找变化中的规律、简化复杂局面、判断本质分类、发现规律破缺等日常认知场景，使用**生活模式**。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

科研模式输出要求：
1. **变换清单**：列出所有可识别的变换 `[变换N]: [描述] [类型: 空间/时间/代数/逻辑/规范]`，组织为候选群，标注验证了哪些群公理（封闭性✓/✗, 结合律✓/✗, 单位元✓/✗, 逆元✓/✗）
2. **不变量发现**：对每种群作用，标注 `[在群G下]: [不变量Y] 保持不变`；若为有限群，写出 Reynolds 算子形式 R(f)=1/|G| Σ f(g·x)；用 Burnside 引理计数轨道 |X/G|=1/|G| Σ |Fix(g)|
3. **简化策略**：说明如何利用不变量简化问题 `[利用不变量Y]: [如何简化]`；标注是否在商空间 X/G 或基本域 D 上工作，估计维度缩减量
4. **对称分类**：给出轨道-稳定子分析 `[对象x]: |O(x)|=[值], |Stab(x)|=[值]`，基于轨道的分类结果，评估不变量是否完备
5. **对称破缺检查**：`[对称性Z]: [存在/破缺]，破缺方式: [自发/显式]`；若为连续破缺 G→H，标注 Goldstone 模数 dim(G/H)；标注破缺后的有效对称群 H
6. **代数/物理对称**：若涉及方程求解，标注 Galois 群 Gal(f) 及其可解性（可解/不可解）和求解链结构；若涉及物理系统，标注 Noether 对应：`[对称群G]: [守恒律]`
7. **结论**：明确写出利用对称性/不变性得出的结论，包括：发现了哪些不变量，实现了多少维度缩减，分类结果是什么

生活模式输出要求：
1. **[变化模式]:[描述]** — 什么在变化，变化的规律是什么（循环往复？线性推进？随机波动？）
2. **[不变量]:[发现]** — 不管怎么变，什么始终不变（找到变化中恒定的核心）
3. **[简化策略]:[方法]** — 如何利用不变量简化问题（从关注细节升级为关注核心模式）
4. **[本质分类]:[判断]** — 表面不同的东西本质是否同类（关键不变量是否相同？）
5. **[规律破缺]:[检查]** — 规律是否被打破？打破的方式是什么（打破可能比规律本身更重要）
6. **[行动建议]:[步骤]** — 基于不变量和规律破缺的结论，明确下一步行动