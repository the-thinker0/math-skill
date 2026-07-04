---
name: optimization
description: |
  触发：问题涉及资源分配、取舍、最大化/最小化目标、约束下决策；或需判断凸性、使用拉格朗日/KKT、分析对偶结构；或为算法/算子/训练设计选择优化方法时调用。
  English: Trigger when a problem involves resource allocation, trade-offs, maximizing/minimizing objectives, decisions under constraints; or needs convexity analysis, Lagrangian/KKT methods, duality structure; or choosing optimization methods for algorithm/operator/training design.
---

> **语言路由**：若用户消息为英文，请读取并遵循同目录下的 `SKILL.en.md`，按其操作规程以英文输出；中文消息则继续使用本文件。

# ⚖️ 优化思想 / Optimization

> "在最一般的约束条件下，寻找目标函数的极值——凸性决定难度，KKT 给出必要条件，对偶揭示结构。"
> "Under the most general constraints, find extrema of the objective — convexity determines difficulty, KKT gives necessity, duality reveals structure."
>
> —— 最优化理论与运筹学 / Optimization Theory & Operations Research

## 核心原则 / Core Principle

**任何决策问题都可以表述为优化问题：在约束条件下最大化（或最小化）某个目标。优化的本质不是追求'最好'，而是在约束下追求'可行中的最好'。**

**Any decision problem can be formulated as optimization: maximizing (or minimizing) an objective subject to constraints. The essence is not 'the best' in the abstract, but 'the best among the feasible'.**

优化的三个核心要素：**目标（Objective）**、**约束（Constraints）**、**可行域（Feasible set）**。

> **数学形式化 / Mathematical Formalization**
>
> 一般优化问题：$\min_{x \in \mathbb{R}^n} f(x) \quad \text{s.t.} \quad g_i(x) \leq 0,\; i=1,\dots,m; \quad h_j(x) = 0,\; j=1,\dots,p$
>
> 拉格朗日函数：$L(x, \lambda, \mu) = f(x) + \sum_i \lambda_i g_i(x) + \sum_j \mu_j h_j(x)$
>
> KKT 条件（核心必要条件，Slater 等正则性下）：① 驻点 $\nabla_x L = 0$；② 原始可行 $g_i \le 0, h_j = 0$；③ 对偶可行 $\lambda_i \ge 0$；④ 互补松弛 $\lambda_i g_i = 0$。
>
> 凸性：若 $f$ 与各 $g_i$ 凸、各 $h_j$ 线性，则问题凸；此时 **KKT 充分**，局部最优 = 全局最优。

## GPU 友好性 / GPU-Friendliness（横切检查）

当优化用于**算法/算子/训练设计**时，求解方法本身必须过 `../../references/gpu-friendly-math.md` 八维门：

- **一阶法（SGD/Adam）**：GEMM 友好、可并行、低精度可行；注意优化器状态精度与分布式通信开销。
- **二阶/牛顿法**：Hessian 求逆 $O(n^3)$、显存爆炸——典型"美但不可算"→ 改造为 **K-FAC / 低秩 / 对角近似**（见 `../../references/books/optimization-ml.md`、`matrix-analysis.md`）。
- **约束投影**：投影是否有闭式、可张量化？迭代投影警惕串行依赖。
- **分布式**：计算/通信能否 overlap；是否需要梯度压缩。

八维最低判定（正式术语）：**张量化**看目标/约束/梯度能否批量；**GEMM 可映射**看主计算是否为矩阵乘、HVP、K-FAC 小矩阵；**复杂度**明确一阶/二阶/组合求解阶；**显存与 KV-Cache**检查优化器状态、Hessian、激活保存；**低精度稳定**检查条件数、阻尼、loss scaling；**并行与通信**检查梯度同步和通信 overlap；**稀疏结构**看预条件/约束是否块结构化；**算子融合**看更新、裁剪、正则能否融合。

> 配合 `../../references/books/optimization-ml.md`（Chong/Lu/Żak）与 `../../references/books/matrix-analysis.md`。

## 不适用场景 / When NOT to Use

- **没有明确评价标准**（不知道什么是"好"）——先定义目标再优化。
- **纯执行性任务**（如格式化代码）——没有优化空间。
- **用户已确定方案**——优化已完成。
- **本质是定性判断而非定量极值**——应先建模再优化。

## 何时使用 / When to Use

- 需要判断问题是否为凸优化以决定求解难度。
- 为算法/算子/训练设计选择优化方法，并评估其 GPU 可行性。
- 在约束条件下做可量化目标的理性决策。
- 实验设计、资源分配、超参/结构搜索的系统优化。
- 不确定当前策略是否最优，想系统分析（凸性、对偶、灵敏度）。

## 方法流程 / Method

### 第一步：定义目标 / Define the Objective
明确最大化/最小化什么。关键：单目标还是多目标？是否可量化（否则找代理变量）？静态还是动态？**$f$ 是否凸**（凸则局部=全局，非凸需警惕局部极值）？方向错了，走得越远越偏。

### 第二步：列出约束 / List the Constraints
区分**硬约束**（物理/预算/deadline）与**软约束**（偏好/质量下限）；数学上分类：不等式 $g_i(x)\le 0$（定义可行域边界）、等式 $h_j(x)=0$（降维）、线性（可行域为凸多面体）vs 非线性（可能非凸）。

### 第三步：类型分类 / Classify the Problem Type

| 类型 | 目标 | 约束 | 核心性质 | 典型方法 |
|------|------|------|----------|----------|
| LP 线性规划 | 线性 | 线性不等式 | 最优在顶点 | 单纯形法 |
| QP 二次规划 | 二次 | 线性 | 正定 QP 为凸 | 内点法 |
| 凸优化 | 凸 | 凸不等式+线性等式 | 局部=全局 | 梯度下降、内点法 |
| 非凸优化 | 非凸 | 任意 | 多局部极值 | 全局搜索、模拟退火 |
| 组合优化 | 离散域 | 任意 | NP-hard 常见 | 分支定界、启发式 |
| 随机优化 | 含随机项 | 可能含随机 | 期望最优 vs 随机可行 | SAA、鲁棒优化 |

### 第四步：寻找最优解 / Find the Optimal Solution
- **LP/QP/凸**：利用凸性，梯度类或内点法保证收敛到全局最优。
- **非凸**：多起点、全局搜索，或松弛为凸近似。
- **组合**：精确解常 NP-hard——小规模分支定界，大规模启发式/近似。
- **随机**：样本平均近似（SAA）转化为确定性近似。
- **信息不足**：满意解（satisficing）即可。

### 第五步：灵敏度分析 / Sensitivity Analysis
拉格朗日乘子 $\lambda_i^*$ 为第 $i$ 个约束的**影子价格**——约束放松一单位，目标改善约 $\lambda_i^*$。互补松弛：$\lambda_i^*=0$ 为非活跃约束（对最优解无影响）；$\lambda_i^*>0$ 为活跃约束（最优解恰在其边界）。关注：约束/目标微小变化时最优解如何变、哪些约束活跃。

### 第六步：多目标与帕累托 / Multi-Objective & Pareto
多目标 $f_1,\dots,f_k$ 通常无单一最优解。帕累托最优：不存在使所有目标同时改善的可行解。方法：**加权求和** $\min\sum w_i f_i$（不同权重对应前沿不同点）；**$\epsilon$-约束法** $\min f_1$ s.t. $f_i\le\epsilon_i$（遍历 $\epsilon_i$ 覆盖前沿）。

### 第七步：监控约束变化 / Monitor Constraint Changes
最优解依赖约束——约束变了就要重新优化。活跃约束的变化影响最大（影子价格高），非活跃约束的微小变化通常不影响最优解。

## 常见错误 / Common Errors

| 错误 / Error | 批评 / Critique | 正确做法 / Correct Approach |
|-------------|----------------|---------------------------|
| 没有明确目标就优化 | 方向不确定 | 先精确定义目标 |
| 忽略隐式约束 | "最优解"实则不可行 | 穷尽检查所有约束 |
| 陷入局部最优 | 非凸贪心不保证全局 | 验证凸性；非凸用多起点/全局法 |
| 把最优当唯一 | 最优解可能不唯一 | 检查是否存在多个等价最优解 |
| 多目标用单目标方法 | 不同目标需 trade-off | 使用帕累托分析 |
| 未验证凸性 | 非凸误用凸方法 | 先判断凸性再选方法 |
| 忽略对偶理论 | 对偶问题可能更易解 | 构造对偶，利用强对偶性 |
| 混淆可行与最优 | 可行不一定最优 | 先验证可行性再验证最优性 |
| 忽略计算/GPU 复杂度 | 二阶法/组合优化可能不可算 | 评估复杂度，过 GPU 八维门，必要时近似 |
| 忘记重新优化 | 约束变了未更新 | 定期检查约束变化 |

## 操作规程 / Operating Procedure

当本 skill 被触发时，输出必须包含：

1. **目标函数**：`[目标]: [描述]` + `[凸性]: [凸/非凸/未知]`
2. **约束清单**：每条标 `[硬/软]` 与 `[不等式/等式]` `[线性/非线性]`
3. **类型分类**：`[类型]: [LP/QP/凸/非凸/组合/随机]`
4. **可行域分析**：哪些选项可行？活跃约束是哪些？
5. **最优解/满意解**：`[策略]: [梯度法/内点法/全局搜索/satisficing/帕累托]`
6. **灵敏度分析**：关键约束影子价格？变化 X% 结论如何变？
7. **GPU 可行性**（若用于算法/算子/训练）：求解方法过八维门，标注友好/可改造/不友好 + 改造建议。
8. **行动建议**：明确写出"接下来我将……"

**输出不得只给分析而无结论。**

## 与其他 skill 的关系 / Relations to Other Skills

- **建模思想**：优化前需先建模——定义目标与约束本身就是建模。
- **概率与统计**：不确定性下的优化需随机/鲁棒优化。
- **变换思想**：变换到对偶问题常更易求解；对偶是优化中最深刻的变换。
- **博弈思想**：多决策者同时优化即博弈，纳什均衡为多人优化的稳定点。
- **算法思想**：求解依赖算法设计——凸优化用梯度法，组合优化需分支定界/启发式。
- **现代数学激活**：`../../references/books/optimization-ml.md`（GPU 友好优化器、二阶法可行性）、`matrix-analysis.md`（条件数、低秩、预条件）。
