---
name: induction-analogy
description: |
  科研模式触发：数学归纳法证明、科学假说生成、科研中的规律发现。
  生活模式触发：从经验中学习、跨领域借用经验、做出有根据的猜测。
  English (Research mode): Trigger for mathematical induction proofs, scientific hypothesis generation, pattern discovery in research.
  English (Life mode): Trigger for learning from experience, cross-domain borrowing, making educated guesses.
---

# 📈 归纳与类比

> "从特殊到一般，从已知到未知——归纳发现规律，类比迁移经验，两者都不等于证明"
> "From the specific to the general, from the known to the unknown—induction discovers patterns, analogy transfers experience, but neither equals proof"
>
> —— Pólya《数学与猜想》、Lakatos《证明与反驳》
> —— Pólya "Mathematics and Plausible Reasoning", Lakatos "Proofs and Refutations"

## 核心原则 / Core Principle

**归纳是从有限实例中发现一般规律的过程，它是创造新知识的引擎。类比是将一个领域的理解迁移到另一个领域的桥梁。两者都不是严格证明，但它们是发现定理、提出假说、产生创新的根本方法。严格性是验证的工具，而非发现的工具——Pólya。**

**Induction is the process of discovering general patterns from limited instances—it is the engine of creating new knowledge. Analogy is the bridge that transfers understanding from one domain to another. Neither is rigorous proof, but both are fundamental methods for discovering theorems, proposing hypotheses, and generating innovation. Rigor is a tool of verification, not of discovery—Pólya.**

归纳与类比的区别与联系：
- **归纳**：从 N 个具体案例 → 一般规律（纵向深入） / From N concrete cases → general pattern (vertical deepening)
- **类比**：从领域 A 的结构 → 领域 B 的结构（横向迁移） / From domain A's structure → domain B's structure (horizontal transfer)
- **共同点**：都产生假设而非定理——需要后续验证 / Both produce hypotheses, not theorems—require subsequent verification

归纳推理与归纳证明的区分：
- **归纳推理**（inductive reasoning）：经验性的，从观察中提出假说 / Empirical, proposing hypotheses from observations
- **归纳证明**（inductive proof）：逻辑性的，数学归纳法是严格的演绎证明格式 / Logical, mathematical induction is a rigorous deductive proof format
- **关键**：归纳推理产生猜想，归纳证明验证猜想——两者不可混淆 / Key: inductive reasoning generates conjectures, inductive proof verifies them—these must not be conflated

> **数学形式化**（科研模式参考 / Research mode reference）
>
> 归纳证明与归纳推理的严格区分：
> - 归纳推理（inductive reasoning）：经验性的，从观察中提出假说
> - 归纳证明（inductive proof）：逻辑性的，数学归纳法是严格的演绎证明格式
> - 关键：归纳推理产生猜想，归纳证明验证猜想——两者不可混淆
>
> 归纳证明的变体及其适用场景：
> - **弱归纳法（Weak Induction）**：证明 P(1) 成立 + 证明 ∀k(P(k)→P(k+1)) → 得出 ∀n P(n)；适用：P(k+1) 仅依赖 P(k)
> - **强归纳法（Strong / Complete Induction）**：假设 P(1), P(2), …, P(k) 全部成立，证明 P(k+1) 成立；适用：P(k+1) 依赖多个前驱
> - **结构归纳法（Structural Induction）**：证明 P(base) 成立 + P(composite) 由 P(components) 推出；适用：递归定义的结构（树、列表、表达式）
> - **超限归纳法（Transfinite Induction）**：对良序集 (W, <)，证明 ∀α∈W(∀β<α P(β) → P(α)) → ∀α∈W P(α)；适用：索引超越自然数的良序集
>
> Lakatos 方法论的形式化描述：
> - **怪物排除（monster-barring）**：将反例归为不属于假说本意范围的对象，在假说中显式排除——最简单的修正，但需警惕过度排除导致假说空洞化
> - **引理吸收（lemma-incorporation）**：将反例暴露的隐藏条件纳入假说作为新引理——使假说更精确
> - **证明策略修订（proof-strategy revision）**：反例揭示原证明思路有根本缺陷，需换一种证明框架——最深刻的修正
>
> 类比的结构性相似度度量：
> - 结构相似度 = (成功映射的关系数 + 成功映射的组件数) / (源关系总数 + 源组件总数)
> - 高有效性（同态映射 homomorphism）：大部分结构有对应，关键关系保持
> - 中有效性（部分同态 partial homomorphism）：部分结构和关系保持，部分失真
> - 低有效性（表面相似 surface similarity）：仅外观或术语相似，深层结构不同

> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **需要严格证明** `[科研]` ——归纳推理和类比只能产生假设，不是证明；但数学归纳法本身是证明方法 / Need rigorous proof—inductive reasoning and analogy only produce hypotheses, not proofs; but mathematical induction itself is a proof method
- **样本只有一个或极少** `[通用]` ——归纳推理需要足够的实例支撑 / Only one or very few samples—inductive reasoning requires sufficient instances
- **两个领域差异太大** `[科研/生活]` ——类比需要结构相似性，而非表面相似 / Domains are too different—analogy requires structural similarity, not surface similarity
- **结论必须零误差** `[科研]` ——归纳推理有不确定性，类比有失真风险 / Conclusion must have zero error—inductive reasoning has uncertainty, analogy has distortion risk
- **问题可用演绎直接解决** `[科研/通用]` ——不必绕道归纳 / Problem can be solved directly by deduction—no need to detour through induction
- **从太少例子推广** `[生活]` ——两三个个案不足以支撑"规律" / Generalizing from too few examples—two or three cases cannot support a "pattern"
- **只找正面证据不找反例** `[生活]` ——确认偏差让人只看到支持自己的例子 / Only seeking confirming evidence, not counterexamples—confirmation bias makes you only see cases that support your view
- **表面类比（结构不相似却强行迁移）** `[生活]` ——游泳的经验不能直接迁移到跑步 / Surface analogy (forcing transfer when structures don't match)—swimming experience can't directly transfer to running

## 何时使用 / When to Use

### 科研触发条件 / Research Trigger Conditions

- 观察到多个案例有共同模式，想要提出一般性假说 / Observed common patterns across multiple cases, want to propose a general hypothesis
- 在科研中尝试发现新定理或新规律 / Attempting to discover new theorems or laws in research
- 需要对递归定义的结构（树、列表、表达式）进行性质证明——使用结构归纳法 / Need to prove properties of recursively defined structures (trees, lists, expressions)—use structural induction
- 需要证明涉及分解的命题（如整数的素因子分解）——使用强归纳法 / Need to prove propositions involving decomposition (e.g., prime factorization of integers)—use strong induction
- 需要对超越自然数的良序集进行论证——使用超限归纳法 / Need to reason about well-ordered sets beyond natural numbers—use transfinite induction
- 跨学科借鉴——其他领域的方法能否用到我的问题？ / Cross-disciplinary borrowing—can methods from other fields apply to my problem?

### 生活触发条件 / Life Trigger Conditions

- 从自己的经历中总结经验教训，想知道"这个教训是不是普遍适用" / Summarizing lessons from your own experience, wondering "is this lesson generally applicable?"
- 面对新问题时，想借鉴过去类似问题的解决经验 / Facing a new problem, wanting to borrow experience from similar past problems
- 需要做判断但没有完整信息，只能基于有限观察做出猜测 / Need to make a judgment without complete information, only able to guess based on limited observations
- 学习新领域时，想用已知领域的理解来加速学习 / Learning a new domain, wanting to use understanding from a known domain to accelerate learning
- 做决策时需要评估"这个方案在其他类似场景中效果如何" / Making decisions, needing to evaluate "how did this approach work in other similar scenarios?"

## 方法流程 / Method

### 第一步：收集具体案例 / Step 1: Collect Concrete Cases

**科研模式 / Research Mode**
系统地收集和观察具体实例：
- 阅读相关文献，提取关键案例 / Read relevant literature, extract key cases
- 收集实验数据中的模式 / Collect patterns in experimental data
- 整理已知的定理或结果 / Organize known theorems or results
- 确保案例覆盖不同类型（边界值、典型值、极端值） / Ensure cases cover different types (boundary, typical, extreme values)

**生活模式 / Life Mode**
你观察到了哪些具体例子？——积累足够的经验案例是归纳的基础 / What specific examples have you observed?—accumulating enough experience cases is the foundation of induction
- 回忆自己经历过的类似情况 / Recall similar situations you've experienced
- 询问他人的经验——拓宽案例来源 / Ask others about their experiences—broaden the source of cases
- 注意不同条件下的表现——同一做法在不同环境下可能效果不同 / Note performance under different conditions—the same approach may work differently in different environments

**共通要点 / Shared Key Point**
案例的多样性和覆盖度决定归纳的质量——太少或太单一的案例会误导你 / The diversity and coverage of cases determine the quality of induction—too few or too uniform cases will mislead you

### 第二步：识别模式 / Step 2: Identify Patterns

**科研模式 / Research Mode**
比较案例之间的共同点和差异 / Compare commonalities and differences across cases：
- 什么特征在所有（或大多数）案例中都出现？ / What features appear in all (or most) cases?
- 什么特征只出现在部分案例中？ / What features appear only in some cases?
- 案例之间的差异有没有规律？ / Do the differences across cases follow a pattern?
- 注意：模式可能在若干案例后突然破坏（如 Borwein 积分现象） / Note: patterns may suddenly break after several cases (e.g., Borwein integral phenomenon)

**生活模式 / Life Mode**
这些例子之间有什么共同点？——找到看似不同的事物背后的共同模式 / What do these examples have in common?—find the shared pattern behind seemingly different things
- 列出每个例子中重复出现的要素 / List the elements that repeat in each example
- 找出例外——哪些例子不符合你看到的模式 / Identify exceptions—which examples don't fit the pattern you see
- 区分"核心共同点"和"偶然巧合"——真正的模式在更多案例中会持续出现，巧合则不会 / Distinguish "core commonality" from "coincidental coincidence"—true patterns persist across more cases, coincidences do not

**共通要点 / Shared Key Point**
模式识别要同时关注共同点和差异——只看共同点会忽视反例 / Pattern identification must attend to both commonalities and differences—focusing only on commonalities will miss counterexamples

### 第三步：提出假说 / Step 3: Formulate a Hypothesis

**科研模式 / Research Mode**
基于观察到的模式，提出一般性的假说或猜想 / Based on observed patterns, propose a general hypothesis or conjecture：
- **强假说**：模式在所有情况下都成立（∀n P(n)) / Strong hypothesis: the pattern holds in all cases
- **弱假说**：模式在大多数情况下成立，存在例外（P(n) 对足够大的 n 成立） / Weak hypothesis: the pattern holds in most cases, with exceptions
- **条件假说**：模式在特定条件下成立（∀n∈S P(n)，S 为特定子集） / Conditional hypothesis: the pattern holds under specific conditions
- 选择原则：优先尝试强假说，再用反例逐级弱化 / Selection principle: prioritize strong hypotheses, then progressively weaken with counterexamples

**生活模式 / Life Mode**
基于观察到模式提出猜测——"看起来规律是这样的"，但记住这只是猜测，还需要验证 / Based on observed patterns, make a guess—"it seems the pattern works this way", but remember this is only a guess, it still needs verification
- 先大胆猜测：规律可能是什么？ / First, make a bold guess: what might the pattern be?
- 标记猜测的强度：你觉得它是"总是这样"、"通常这样"还是"在某些条件下这样"？ / Mark the strength of your guess: do you think it's "always like this", "usually like this", or "under certain conditions like this"?
- 更强的猜测更有用但也更可能出错——先试最强的，再根据实际情况调整 / Stronger guesses are more useful but also more likely to be wrong—try the strongest first, then adjust based on reality

**共通要点 / Shared Key Point**
假说/猜测是从模式到可检验陈述的跃迁——它必须足够明确以至于可以被推翻 / A hypothesis/guess is the leap from pattern to a testable statement—it must be specific enough to be falsifiable

### 第四步：搜索反例 / Step 4: Search for Counterexamples

**科研模式 / Research Mode**
主动寻找推翻假说的反例。这是区分科学与伪科学的关键步骤 / Actively seek counterexamples that refute the hypothesis. This is the key step distinguishing science from pseudoscience：
- 如果能找到反例：修改假说（弱化或加条件） / If counterexamples found: modify the hypothesis (weaken or add conditions)
- 如果找不到反例：假说暂时成立 / If no counterexamples found: hypothesis tentatively holds
- 特别关注边界条件、极端值、参数变化时模式是否突然失效 / Pay special attention to boundary conditions, extreme values, and whether patterns suddenly fail when parameters change

**生活模式 / Life Mode**
有没有反例推翻你的猜测？——一个反例就够了。主动寻找反例比不断确认正面例子更重要 / Are there counterexamples that overturn your guess?—one counterexample is enough. Actively seeking counterexamples is more important than endlessly confirming positive examples
- 刻意寻找"不符合猜测"的情况——这比找更多正面例子更有价值 / Deliberately look for cases that "don't fit the guess"—this is more valuable than finding more positive examples
- 检查极端情况——压力下、资源不足时、条件变化时，规律还成立吗？ / Check extreme situations—under pressure, with insufficient resources, or when conditions change, does the pattern still hold?
- 问问反对者——不同视角的人更容易发现你看不到的反例 / Ask dissenters—people with different perspectives are more likely to find counterexamples you can't see

**共通要点 / Shared Key Point**
反例检验是归纳的保险——没有经过反例检验的猜测不可信赖 / Counterexample testing is induction's insurance—an untested guess is unreliable

### 第五步：尝试证明 / Step 5: Attempt a Proof / Attempt Verification

**科研模式 / Research Mode**
对于数学假说，尝试严格证明。归纳证明有多种变体，选择正确的变体是关键 / For mathematical hypotheses, attempt rigorous proof. Inductive proof has multiple variants; choosing the correct variant is key：

**弱归纳法（Weak Induction）**：
- 格式：证明 P(1) 成立 + 证明 ∀k(P(k)→P(k+1)) → 得出 ∀n P(n)
- 适用：P(k+1) 仅依赖 P(k) 一个前驱（如求和公式、简单递推关系）
- 示例：1+2+…+n = n(n+1)/2

**强归纳法（Strong / Complete Induction）**：
- 格式：假设 P(1), P(2), …, P(k) 全部成立，证明 P(k+1) 成立
- 适用：P(k+1) 依赖多个前驱（涉及分解、拆分的命题）
- 示例：每个大于 1 的整数都是素数的乘积；斐波那契数列的性质
- 关键区分：当证明 P(k+1) 需引用 P(j)（j < k），必须用强归纳而非弱归纳

**结构归纳法（Structural Induction）**：
- 格式：证明 P(base) 成立 + P(composite) 由 P(components) 推出
- 适用：递归定义的结构——树、列表、表达式、公式、程序语义
- 示例：二叉树叶节点数 = 内部节点数 + 1；BNF 语法定义的公式性质
- 与弱归纳的关系：结构归纳法是数学归纳法在递归结构上的自然推广

**超限归纳法（Transfinite Induction）**：
- 格式：对良序集 (W, <)，证明 ∀α∈W(∀β<α P(β) → P(α)) → ∀α∈W P(α)
- 适用：索引超越自然数的良序集——序数、偏序集、拓扑中的传递闭包论证
- 示例：Zorn 引理的应用、集合论中的递归构造

**良序原理等价性**：
- 良序原理：每个非空子集有最小元 ↔ 自然数上的归纳法 ↔ 强归纳法 ↔ 超限归纳法（在良序集上）
- 实践意义：选择哪种形式取决于问题结构——用最自然的形式

**生活模式 / Life Mode**
尝试验证猜测——不是所有猜测都能被严格证明，但至少要检查它在更多情况下是否成立 / Try to verify your guess—not all guesses can be rigorously proven, but at least check whether it holds in more situations
- 在更多场景中检验：把猜测用到还没检查过的情况中，看是否依然成立 / Test in more scenarios: apply the guess to untested situations and see if it still holds
- 寻找因果机制：如果猜测成立，背后的原因是什么？有原因支撑比纯统计相关更可靠 / Look for causal mechanisms: if the guess holds, what's the underlying reason? Causal support is more reliable than pure statistical correlation
- 量化检验：如果可能，用数据或实验检验，而不是仅凭感觉 / Quantitative testing: if possible, verify with data or experiments, not just feelings

**共通要点 / Shared Key Point**
验证是猜测走向可靠知识的桥梁——未经验证的猜测只是直觉 / Verification is the bridge from guess to reliable knowledge—an unverified guess is just intuition

### 第六步：类比迁移 / Step 6: Analogical Transfer

**科研模式 / Research Mode**
如果使用了类比，必须进行定量评估而非仅凭直觉 / If analogy is used, quantitative assessment is required, not just intuition：

**结构性相似度度量 / Structural Similarity Metric**：
- 计算源领域到目标领域的结构映射覆盖率：多少组件有对应？多少关系保持？
- 结构相似度 = (成功映射的关系数 + 成功映射的组件数) / (源关系总数 + 源组件总数)

**类比有效性分级 / Analogy Effectiveness Grading**：
- **高有效性（同态映射 homomorphism）**：源领域的大部分结构在目标领域有对应，关键关系保持——类比结论可信度高
- **中有效性（部分同态 partial homomorphism）**：部分结构和关系保持，部分失真——类比结论需修正后使用
- **低有效性（表面相似 surface similarity）**：仅外观或术语相似，深层结构不同——类比结论基本不可信

**系统性检验清单 / Systematic Inspection Checklist**：
1. 对源领域的每个组件：目标领域是否有对应组件？ / For each component in the source domain: does the target domain have a corresponding component?
2. 对源领域的每个关系：该关系在目标领域中是否成立？ / For each relation in the source domain: does it hold in the target domain?
3. 对源领域的每个操作：该操作在目标领域中是否有定义？ / For each operation in the source domain: is it defined in the target domain?
4. 检验映射的一致性：若 a↦a', b↦b'，则 R(a,b) 是否蕴含 R'(a',b')？ / Verify mapping consistency: if a↦a', b↦b', does R(a,b) entail R'(a',b')?

**生活模式 / Life Mode**
你在一个领域学到的经验能否迁移到另一个领域？——关键看两个领域的核心结构是否相似，不是表面相似。游泳的经验不能直接迁移到跑步，但"循序渐进"的策略可以 / Can experience learned in one domain transfer to another?—the key is whether the core structures of the two domains are similar, not whether they look similar on the surface. Swimming experience can't directly transfer to running, but the "gradual progression" strategy can
- 先问：两个领域的核心挑战是什么？如果核心挑战相似，迁移更有可能成功 / First ask: what are the core challenges in both domains? If the core challenges are similar, transfer is more likely to succeed
- 区分"策略迁移"和"技能迁移"：策略（如分解问题、循序渐进）更容易跨领域，技能（如具体操作）更难迁移 / Distinguish "strategy transfer" from "skill transfer": strategies (e.g., breaking down problems, gradual progression) transfer more easily across domains; skills (e.g., specific operations) are harder to transfer
- 检验迁移效果：把迁移后的做法实际试一下，看效果是否如预期 / Verify transfer effectiveness: actually try the transferred approach and see if results match expectations

**共通要点 / Shared Key Point**
类比的有效性取决于结构相似度而非表面相似度——核心挑战匹配的类比比外观匹配的类比更可靠 / Analogy effectiveness depends on structural similarity, not surface similarity—analogies matching on core challenges are more reliable than those matching on appearance

### 第七步：假说修正 / Step 7: Hypothesis Revision

**科研模式 / Research Mode**
根据反例和证明尝试的结果修正假说，遵循 Lakatos 的方法论 / Revise hypotheses based on counterexamples and proof attempts, following Lakatos's methodology：
- **怪物排除（monster-barring）**：将反例归为不属于假说本意范围的对象，在假说中显式排除——最简单的修正，但需警惕过度排除导致假说空洞化
- **引理吸收（lemma-incorporation）**：将反例暴露的隐藏条件纳入假说作为新引理——使假说更精确
- **证明策略修订（proof-strategy revision）**：反例揭示原证明思路有根本缺陷，需换一种证明框架——最深刻的修正
- 修正后回到第四步，迭代直至假说稳定 / After revision, return to Step 4, iterate until the hypothesis stabilizes

**生活模式 / Life Mode**
遇到反例怎么办？——要么修正猜测的范围（"在什么条件下成立"），要么深化猜测（"真正的规律是什么"） / What to do when you encounter a counterexample?—either narrow the scope of your guess ("under what conditions it holds"), or deepen the guess ("what the real pattern is")
- 收缩范围："也许这个规律只在特定条件下成立"——明确条件是什么 / Narrow the scope: "maybe this pattern only holds under specific conditions"—clarify what those conditions are
- 深化理解："反例暴露了什么？真正的规律可能比我的猜测更复杂"——反例是深化理解的契机 / Deepen understanding: "what does the counterexample reveal? The real pattern may be more complex than my guess"—counterexamples are opportunities to deepen understanding
- 不要固执于最初的猜测——猜测是临时的，修正才是进步 / Don't cling to your initial guess—guesses are temporary, revision is progress

**共通要点 / Shared Key Point**
修正不是失败而是进步——每次修正都让假说/猜测更接近真相 / Revision is not failure but progress—each revision brings the hypothesis/guess closer to the truth

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach | 标签 / Tag |
|-------------|-------------------------------|---------------------------|-----------|
| 样本不足就归纳 | 从 2-3 个案例归纳的"规律"极不可靠 / "Patterns" induced from 2-3 cases are extremely unreliable | 样本量要足够大，且覆盖各种情况 / Sample size must be large enough and cover various situations | `[科研/生活]` |
| 把归纳推理当证明 | 归纳推理只产生假设，不是证明；数学归纳法才是证明 / Inductive reasoning only produces hypotheses, not proofs; mathematical induction is proof | 区分归纳推理与归纳证明，前者产猜想后者验证 / Distinguish inductive reasoning from inductive proof | `[科研]` |
| 确认偏差 | 只看到支持假说的案例，忽视反例 / Only seeing cases that support the hypothesis, ignoring counterexamples | 主动寻找反例，这是最关键的一步 / Actively seek counterexamples—this is the most crucial step | `[科研/生活]` |
| 表面类比 | 基于表面相似而非结构相似的类比 / Analogy based on surface similarity, not structural similarity | 类比的依据是结构同构/同态，不是表面相似 / Analogy should be based on structural isomorphism/homomorphism, not surface similarity | `[科研/生活]` |
| 类比过度 | 两个领域不完全同构，类比结论不完全成立 / Two domains are not fully isomorphic, analogy conclusions don't fully hold | 用结构性相似度量化评估类比强度 / Quantitatively assess analogy strength using structural similarity metrics | `[科研]` |
| 归纳后不验证 | 提出假说后不去检验 / Proposing a hypothesis but not testing it | 假说必须经过反例检验和/或证明 / Hypotheses must undergo counterexample testing and/or proof | `[科研/生活]` |
| 需强归纳却用弱归纳 | P(k+1) 依赖多个前驱时，弱归纳无法完成归纳步骤 / When P(k+1) depends on multiple predecessors, weak induction can't complete the inductive step | 识别依赖结构：若 P(k+1) 需引用 P(j)(j<k)，用强归纳 / Identify dependency structure: use strong induction when P(k+1) needs P(j)(j<k) | `[科研]` |
| 仅凭表面特征评估类比 | 表面特征相似不意味着结构相似，类比结论可能完全错误 / Surface feature similarity doesn't mean structural similarity, analogy conclusions may be completely wrong | 用系统映射检验：逐一比较组件、关系、操作 / Use systematic mapping: compare components, relations, operations one by one | `[科研]` |
| 混淆归纳推理与归纳证明 | 归纳推理是经验性的，归纳证明是演绎性的——性质完全不同 / Inductive reasoning is empirical, inductive proof is deductive—completely different in nature | 明确区分：推理→假说，证明→定理 / Clearly distinguish: reasoning → hypothesis, proof → theorem | `[科研]` |
| 忽略模式破坏（Borwein积分） | 模式在前若干案例中成立后可能突然失效，归纳推理有盲区 / Patterns holding for several cases may suddenly fail; inductive reasoning has blind spots | 检查足够多案例，特别关注边界与参数变化时的模式突变 / Check enough cases, especially boundary and parameter-change pattern mutations | `[科研]` |
| 从太少例子推广 | 两三个个案不足以支撑"规律"，生活经验也需要足够样本 / Two or three cases can't support a "pattern"; life experience also needs sufficient samples | 积累更多经验，或明确标注"这只是初步印象" / Accumulate more experience, or clearly label "this is only an initial impression" | `[生活]` |
| 只找正面证据不找反例 | 确认偏差在生活中同样常见——只记住成功的案例 / Confirmation bias is equally common in life—only remembering successful cases | 刻意回忆失败案例，问"什么时候这个做法不灵？" / Deliberately recall failure cases, ask "when did this approach not work?" | `[生活]` |
| 表面类比（结构不相似却强行迁移） | 游泳的经验不能直接迁移到跑步——核心挑战不同 / Swimming experience can't directly transfer to running—core challenges are different | 先比核心挑战，再比表面特征——核心挑战匹配的类比更可靠 / Compare core challenges first, then surface features—analogies matching on core challenges are more reliable | `[生活]` |

## 操作规程 / Operating Procedure

当本 skill 被触发时，首先判断模式 / When this skill is triggered, first determine the mode：

**模式选择 / Mode Selection**：
- **科研模式**：涉及数学证明、科学假说、定理发现、结构映射度量 / Involves mathematical proofs, scientific hypotheses, theorem discovery, structural mapping metrics
- **生活模式**：涉及日常经验总结、跨领域借鉴、初步猜测、决策辅助 / Involves daily experience summarization, cross-domain borrowing, initial guesses, decision support

---

### 科研模式输出格式 / Research Mode Output Format

1. **案例清单**：列出所有观察到的具体案例 `[案例N]: [描述] [关键特征]`，确保覆盖边界值与极端值 / Case list: list all observed concrete cases, ensuring coverage of boundary and extreme values
2. **模式识别**：`[共同模式]: [描述] [出现频率: N/M] [差异模式]: [描述]`，注意是否有 Borwein 型突然破坏 / Pattern identification with frequency and difference patterns, noting potential Borwein-type sudden breaks
3. **假说表述**：用精确语言表述假说 `[假说]: [内容] [类型: 强/弱/条件]`，优先尝试强假说 / Hypothesis formulation with precise language, prioritizing strong hypotheses
4. **反例搜索**：`[反例]: [找到/未找到]。如找到: [描述]，假说修正: [新表述]` / Counterexample search results
5. **证明方向**：如适用，选择归纳变体 `[归纳类型: 弱/强/结构/超限]` 并给出证明思路；说明为何选择该变体 / Proof direction with induction variant selection and reasoning
6. **类比映射**：`[源领域A] → [目标领域B]: [对应关系] [结构相似度: X/Y] [有效性: 高/中/低]`，逐项检验组件、关系、操作 / Analogy mapping with structural similarity and effectiveness grading
7. **假说修正**：如需修正，记录 `[修正方式: 怪物排除/引理吸收/策略修订] [修正后假说]` / Hypothesis revision with Lakatos methodology notation

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。**

---

### 生活模式输出格式 / Life Mode Output Format

1. **[观察案例]:[列表]** —— 具体观察到什么 / What you specifically observed
2. **[共同模式]:[发现]** —— 案例之间的共同点 / Commonality among the cases
3. **[初步猜测]:[提出]** —— 基于模式提出什么假设 / What hypothesis you propose based on the pattern
4. **[反例检查]:[验证]** —— 有没有反例推翻猜测 / Whether counterexamples overturn the guess
5. **[经验迁移]:[评估]** —— 能否将经验迁移到其他领域（核心结构是否相似） / Whether experience can transfer to other domains (are core structures similar)
6. **[修正方向]:[建议]** —— 如果有反例，如何修正猜测 / If counterexamples exist, how to revise the guess

**输出必须包含以上 6 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **逻辑演绎**：归纳产生假说，演绎证明假说——两者是发现与验证的双翼 / Induction produces hypotheses, deduction proves them—the two wings of discovery and verification
- **抽象化思想**：类比本质上是识别两个领域的共同抽象结构 / Analogy is essentially identifying the shared abstract structure of two domains
- **概率与统计**：归纳推理的概率版本就是统计推断 / The probabilistic version of inductive reasoning is statistical inference
- **建模思想**：从数据中发现规律的归纳过程也是建模的一部分 / The inductive process of discovering patterns from data is also part of modeling
- **算法思想**：归纳作为正确性证明范式——循环不变量即归纳假设，递归程序正确性依赖结构归纳 / Induction as a correctness proof paradigm—loop invariants are induction hypotheses, recursive program correctness relies on structural induction
- **离散/组合思想**：组合归纳——对组合对象的归纳论证，如图论归纳、生成函数方法中的归纳递推 / Combinatorial induction—inductive arguments on combinatorial objects, e.g., graph induction, inductive recursion in generating function methods