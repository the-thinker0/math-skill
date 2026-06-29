# 武器选择器的思想来源 / Intellectual Sources for the Weapon Selector

## 问题分类与工具选择的传统 / The Tradition of Problem Classification and Tool Selection

### Pólya 的问题求解启发法 / Pólya's Problem-Solving Heuristics

George Pólya (1887-1985) 在《怎样解题》(How to Solve It, 1945) 中提出了四步求解法，这是现代问题求解方法论的基础：

1. **理解问题** (Understanding the problem) — 你必须理解问题
2. **拟定方案** (Devising a plan) — 找出已知与未知之间的联系
3. **执行方案** (Carrying out the plan) — 检查每一步
4. **回顾检验** (Looking back) — 检查所得解答

Pólya 的核心洞见：**不同类型的问题需要不同的解题策略**。他列举了数十种启发法（heuristic strategies），包括：
- 如果不能解决提出的问题，尝试先解决某个相关的问题
- 回到定义
- 从特殊到一般，从一般到特殊
- 考虑极端情况
- 逆向推理
- 画图
- 引入辅助元素

> "解题是一种实践技能，就像游泳一样——你可以通过模仿和练习来学习它。" —— Pólya

Pólya 的启发法分类为我们的武器选择器提供了思想基础：**问题的核心特征（如"是否涉及不确定量""是否有对称性""能否分解为子问题"）决定了最合适的解题方法**。

### Newell & Simon 的问题空间理论 / Newell & Simon's Problem Space Theory

Allen Newell 和 Herbert A. Simon 在《人类问题求解》(Human Problem Solving, 1972) 中提出了问题空间理论：

- **问题空间** (Problem Space)：所有可能状态构成的集合，包含初始状态、目标状态和允许的操作
- **搜索策略** (Search Strategy)：在问题空间中从初始状态导航到目标状态的方法
- **启发式搜索** (Heuristic Search)：不是穷举所有状态，而是用启发规则选择最可能导向目标的方向

核心洞见：**问题空间的性质决定了搜索策略的选择**。如果问题空间很小，穷举可行；如果很大，必须用启发式；如果问题空间有特殊结构（如单调性、对称性），可以利用结构加速搜索。

> "选择搜索策略是问题求解中最关键的决策——策略决定了你将在问题空间中的哪个区域搜索。" —— Newell & Simon

### Schoenfeld 的策略选择理论 / Schoenfeld's Strategic Decision Theory

Alan H. Schoenfeld 在《数学问题求解》(Mathematical Problem Solving, 1985) 中分析了为什么学生即使掌握了解题工具也无法解决问题——关键不是缺少工具，而是缺少**策略选择能力**：

- **资源** (Resources)：知识、技能、工具——相当于我们的15种思想武器
- **启发法** (Heuristics)：如何使用资源——相当于每种思想武器的方法流程
- **控制** (Control)：何时使用哪个资源——相当于武器选择器的功能
- **信念系统** (Belief Systems)：对数学和自我的信念——影响是否选择合适的工具

核心洞见：**掌握工具≠能解决问题。关键差异在于'控制'层面——知道何时调用哪个工具**。这正是武器选择器要解决的问题。

> "学生的问题不是缺乏知识或技能，而是缺乏策略性决策能力——他们不知道何时该用什么方法。" —— Schoenfeld

### Rittel & Webber 的棘问题理论 / Wicked Problems Theory

Horst Rittel 和 Melvin Webber 在 "Dilemmas in a General Theory of Planning" (1973) 中区分了"驯问题"(tame problems) 和"棘问题"(wicked problems)：

驯问题的特征：
- 有明确的定义
- 有明确的终止条件
- 解可以客观评价为对或错
- 属于特定领域

棘问题的特征：
- 没有明确的定义——理解问题本身就是解决问题的一部分
- 没有明确的终止条件
- 解没有对错之分，只有好与更好
- 跨越多个领域

核心洞见：**棘问题需要跨领域的思想武器组合，而驯问题可以用单一工具解决**。武器选择器在面对棘问题时推荐多工具组合，面对驯问题时推荐单一聚焦。

> "棘问题没有对错答案，只有更好或更差的处理方式。" —— Rittel & Webber

### Kahneman 的双系统理论 / Kahneman's Dual-System Theory

Daniel Kahneman 在《思考，快与慢》(Thinking, Fast and Slow, 2011) 中提出了双系统理论：

- **系统1** (System 1)：快速、直觉、自动——日常生活中大部分决策
- **系统2** (System 2)：慢速、理性、可控——需要深思熟虑的决策

核心洞见：**不是所有问题都需要系统2级别的理性分析**。生活中的许多决策只需要直觉（系统1），强行调用思想武器是过度分析。武器选择器的"不适用场景"清单正是基于这个洞见——简单问题不需要工具，棘问题才需要。

> "过度思考是决策的敌人——有些决定最好交给直觉。" —— Kahneman

### Lakatos 的方法论 / Lakatos's Methodology

Imre Lakatos 在《证明与反驳》(Proofs and Refutations, 1976) 中展示了数学知识不是线性增长的，而是通过"猜想→反驳→修正"的辩证过程演进：

- **进步的问题转换** (Progressive Problemshift)：每次修正产生新的、更深刻的问题
- **退化的问题转换** (Degenerative Problemshift)：修正只是为了应付反例，没有产生新洞见

核心洞见：**工具选择本身也应该是一个进步的问题转换**——第一次选择可能不理想，但通过使用后反思，选择能力逐步提升。武器选择器的"组合顺序"和"辅助视角"推荐正是这种辩证思维的体现。

> "知识不是从天而降的真理，而是在批评与反驳中不断改进的猜想。" —— Lakatos

## 从思想到实践的映射 / Mapping Ideas to Practice

我们的武器选择器融合了以上思想：

| 思想来源 | 在武器选择器中的体现 |
|---------|-------------------|
| Pólya 启发法 | 决策树中的11个特征分支——每个分支对应一类启发策略 |
| Newell & Simon 问题空间 | 问题特征维度刻画——互动性、不确定性、约束性、结构性、动态性 |
| Schoenfeld 策略选择 | "选对工具比用力分析更重要"的核心原则 |
| 棘问题理论 | 多工具组合推荐——棘问题需要跨领域工具组合 |
| Kahneman 双系统 | "不适用场景"——简单问题不需要工具，避免过度分析 |
| Lakatos 方法论 | 组合顺序建议——先用主工具，再用辅助工具补充视角 |