---
name: meta-selector
description: |
  触发：当面对模糊问题、不确定该调用哪个思想武器时使用。根据问题特征推荐最合适的1-3个工具，并建议使用科研模式还是生活模式。
  模式：本 skill 本身不需要科研/生活模式切换——它是在调用其他 skill 之前的选择器。
  English: Trigger when facing a vague problem and unsure which thinking weapon to use. Recommends the 1-3 most suitable tools based on problem characteristics, and suggests research mode or life mode.
  Mode: This skill itself doesn't need research/life mode switching — it is a selector to be called before invoking other skills.
---

# 🧭 武器选择器 / Weapon Selector

> "不是每把刀都适合切菜，也不是每个问题都需要屠龙刀。先选对工具，再用力。"
> "Not every knife is good for chopping vegetables, and not every problem needs a dragon-slaying sword. Choose the right tool first, then apply force."
>
> —— 元认知、问题分类、工具选择 / Meta-cognition, Problem Classification, Tool Selection

## 核心原则 / Core Principle

**面对一个问题时，最重要的一步不是'用力分析'，而是'选对工具'。不同的思想武器适用于不同类型的问题——用博弈论分析单人决策是浪费，用拓扑思想处理精确数值问题是无用。选择器帮你根据问题的核心特征，找到最合适的1-3个思想武器。**

**When facing a problem, the most important step is not 'analyzing hard' but 'choosing the right tool.' Different thinking weapons suit different problem types — using game theory on a single-player decision is wasteful, using topological thinking on precise numerical problems is useless. The selector helps you find the 1-3 most suitable thinking weapons based on the problem's core characteristics.**

选择原则：
- **问题特征驱动**——不是"我最熟悉哪个工具"，而是"问题的核心特征指向哪个工具"
- **最多3个**——同时用太多工具等于没有工具，聚焦1-3个最相关的
- **优先级排序**——推荐多个工具时标注主次，主工具先深入，辅工具补充视角
- **模式匹配**——科研问题用科研模式，生活问题用生活模式，勿混淆

Selection principles:
- **Problem-characteristic-driven** — not "which tool I'm most familiar with" but "which tool the problem's core characteristics point to"
- **Maximum 3** — using too many tools simultaneously means no tool is used effectively; focus on 1-3 most relevant
- **Priority ordering** — when recommending multiple tools, label primary vs. secondary; primary tool first for depth, secondary for supplementary perspectives
- **Mode matching** — research problems use research mode, life problems use life mode; don't mix

## 不适用场景 / When NOT to Use

- **你已经知道该用哪个思想武器**——不需要选择器，直接调用 `[通用]`
- **问题极其简单**——不需要任何思想武器，直接处理 `[通用]`
- **问题不属于数学思维能帮助的范畴**（如纯粹情感问题、审美判断）——没有合适的工具可用 `[通用]`

## 何时使用 / When to Use

- 面对一个模糊问题，不知道从哪个角度切入
- 多个思想武器似乎都相关，不确定该优先用哪个
- 第一次接触一个新问题类型，想先确认方法论方向
- 想检查自己是否遗漏了更适合的工具

## 方法流程 / Method

### 第一步：描述问题特征 / Describe Problem Characteristics

用以下五个维度刻画问题：

1. **互动性**：问题是否涉及多方互动？你的最优行动是否取决于他人的选择？
2. **不确定性**：问题是否包含随机性或不确定性？你是否需要量化风险？
3. **约束性**：问题是否在限制条件下做选择？是否有明确的"不可逾越的边界"？
4. **结构性**：问题是否需要提取本质结构？表面现象背后的核心模式是什么？
5. **动态性**：问题是静态的（一次性决策）还是动态的（需要持续迭代调整）？

### 第二步：特征匹配 / Characteristic Matching

根据第一步识别的核心特征，使用以下决策树匹配最合适的思想武器：

#### 问题特征决策树 / Problem Character Decision Tree

**1. 问题是否涉及多方互动？**
- 是 → 🎯 **博弈论思想**（主要）
  - 且涉及资源分配 → ⚖️ **优化思想**（辅助）
  - 且涉及信息不对称 → 📡 **信息论思想**（辅助）
- 否 → 继续

**2. 问题是否涉及不确定性/随机性？**
- 是 → 🎲 **概率与统计**（主要）
  - 且需要区分因果而非相关 → 🔗 **因果推断思想**（辅助）
  - 且需要评估信息价值 → 📡 **信息论思想**（辅助）
- 否 → 继续

**3. 问题是否需要"在限制下做最优选择"？**
- 是 → ⚖️ **优化思想**（主要）
  - 且多目标需要取舍 → ⚖️ 优化（帕累托分析）
  - 且需要先建模 → 🌉 **建模思想**（前置）
- 否 → 继续

**4. 问题是否在当前形式下难以处理，需要换个视角？**
- 是 → 🔄 **变换思想**（主要）
- 否 → 继续

**5. 问题是否需要从具体中提取本质结构？**
- 是 → 🧩 **抽象化思想**（主要）
  - 且需要验证假设合理性 → 📐 **公理化思想**（辅助）
  - 且需要简化复杂系统 → ⚛️ **对称与不变性**（辅助）
- 否 → 继续

**6. 问题是否需要严格推理验证？**
- 是 → 🧠 **逻辑演绎**（主要）
  - 且需要验证前提合理性 → 📐 **公理化思想**（辅助）
- 否 → 继续

**7. 问题是否需要从数据/经验中发现规律？**
- 是 → 📈 **归纳与类比**（主要）
  - 且需要跨领域迁移 → 🧩 **抽象化思想**（辅助）
- 否 → 继续

**8. 问题是否需要构建模型来预测或解释？**
- 是 → 🌉 **建模思想**（主要）
  - 且模型需要优化 → ⚖️ **优化思想**（辅助）
  - 且模型涉及不确定 → 🎲 **概率与统计**（辅助）
- 否 → 继续

**9. 问题是否涉及"变化中保持不变"？**
- 是 → ⚛️ **对称与不变性**（主要）
  - 且需要关注连通结构 → 🌀 **拓扑思想**（辅助）
  - 且需要关注规律被打破 → ⚛️ 对称与不变性（对称破缺分析）
- 否 → 继续

**10. 问题是否需要将过程转化为可执行步骤？**
- 是 → 🖥️ **算法与计算思想**（主要）
  - 且需要评估可行性 → 🖥️ 算法与计算思想（可计算性分析）
- 否 → 继续

**11. 问题是否涉及有限对象的计数/枚举/结构？**
- 是 → 🧮 **离散与组合思想**（主要）
- 否 → 重新审视问题描述，可能需要回到第1步

### 第三步：推荐工具 / Recommend Tools

输出1-3个推荐的思想武器，每个标注：
- **[主要]** 或 **[辅助]**：优先级
- **推荐理由**：为什么这个工具适合该问题特征
- **触发命令**：对应的 `/command`
- **建议模式**：科研模式还是生活模式

### 第四步：组合建议 / Combination Suggestions

如果推荐多个工具，说明组合顺序与协作方式：

- **前置工具**：需要先调用的工具（如建模→优化的建模是前置）
- **主工具**：深入分析的核心工具
- **辅助视角**：补充关键视角的工具
- **组合顺序**：先调1号，再用2号补充

## 常见错误 / Common Errors

| 错误 / Error | 批评 / Critique | 正确做法 / Correct Approach | 模式 |
|-------------|-------------------------------|---------------------------|------|
| 选最熟悉的工具而非最合适的 | 熟悉度≠适用性，用博弈论分析单人决策是浪费 | 根据问题特征而非个人偏好选择工具 | `[通用]` |
| 用科研级工具分析生活问题 | KKT 条件分析时间管理是杀鸡用牛刀 | 生活问题用生活模式——保留思维框架的核心步骤，去掉数学符号 | `[生活]` |
| 同时调用太多工具 | 5个工具等于没有工具，每个都浅尝辄止 | 聚焦1-3个，主工具深入，辅工具补充视角 | `[通用]` |
| 忽略工具的前置关系 | 建模是优化的前置，不建模直接优化可能方向错误 | 标注组合顺序——前置工具先调用 | `[通用]` |
| 把"不确定该用哪个"当借口拖延 | 选择器本身就是快速决策工具，3步即出结果 | 直接调用 `/ask`，3步完成选择 | `[通用]` |
| 只推荐一个工具而忽略辅助视角 | 一个视角可能遗漏关键维度 | 至少检查是否有辅助视角补充 | `[科研]` |
| 科研/生活模式混淆 | 用生活模式分析论文，或用科研模式分析人际矛盾 | 根据问题性质选择模式——科研问题用科研模式，生活问题用生活模式 | `[通用]` |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：

1. **[问题特征]:[五维度刻画]** — 用互动性、不确定性、约束性、结构性、动态性五个维度描述问题核心特征
2. **[推荐工具]:[1-3个]** — 每个工具标注 `[主要/辅助]`、推荐理由、触发命令（如 `/optimization`）
3. **[建议模式]:[科研/生活]** — 根据问题性质推荐使用科研模式还是生活模式
4. **[组合顺序]:[描述]** — 如果推荐多个工具，说明前置→主要→辅助的调用顺序
5. **[不适用检查]:[确认]** — 明确标注哪些思想武器不适用于此问题，避免误用

**输出必须包含以上 5 项，不得只输出分析性文字而不给出结论。**

## 与其他 skill 的关系 / Relations to Other Skills

本选择器与全部15个思想武器形成推荐关系：

**按问题类型分类 / By Problem Type**：

| 问题类型 | 主要工具 | 辅助工具 |
|---------|---------|---------|
| 多方互动决策 | 🎯 博弈论 | ⚖️ 优化、📡 信息论 |
| 不确定性下的判断 | 🎲 概率与统计 | 🔗 因果推断、📡 信息论 |
| 约束下的最优选择 | ⚖️ 优化 | 🌉 建模（前置） |
| 需要换个视角 | 🔄 变换 | — |
| 提取本质结构 | 🧩 抽象化 | 📐 公理化、⚛️ 对称与不变性 |
| 严格推理验证 | 🧠 逻辑演绎 | 📐 公理化 |
| 从经验发现规律 | 📈 归纳与类比 | 🧩 抽象化 |
| 构建预测/解释模型 | 🌉 建模 | ⚖️ 优化、🎲 概率与统计 |
| 变化中的不变性 | ⚛️ 对称与不变性 | 🌀 拓扑思想 |
| 可执行步骤与可行性 | 🖥️ 算法与计算 | — |
| 有限对象的计数/结构 | 🧮 离散与组合 | — |

- **公理化思想**：选择器本身依赖隐含的"问题分类公理"——问题特征决定工具适用性
- **抽象化思想**：选择器的核心操作是"提取问题的本质特征"——这本身就是抽象
- **逻辑演绎**：决策树是一种演绎结构——从特征到推荐，每一步都是逻辑推理