---
name: modeling
description: |
  触发：当需要将现实问题转化为数学形式、构建科研模型、预测实验结果，或规划生活决策（预算、路线、风险评估）时调用。
  English: Trigger when needing to translate real-world problems into mathematical form, build scientific models, predict experimental results, or plan life decisions (budget, route, risk assessment).
---

# 🌉 建模思想

> "将现实世界的问题转化为数学问题，通过求解数学问题来解释和预测现实。所有模型都是错的，但有些是有用的。"
> "Transforming real-world problems into mathematical problems, solving them mathematically to explain and predict reality. All models are wrong, but some are useful."
>
> —— 应用数学、数学建模 / Applied Mathematics, Mathematical Modeling

## 核心原则 / Core Principle

**模型是现实的简化表示，不是现实本身。一个好的模型不是"真实"的模型，而是在其适用范围内能做出准确预测的模型。**

**A model is a simplified representation of reality, not reality itself. A good model is not a 'true' model, but one that makes accurate predictions within its scope of applicability.**

建模的黄金循环：
1. **现实问题 → 数学问题**（翻译 / Translation）
2. **数学问题 → 数学解**（求解 / Solution）
3. **数学解 → 现实解释**（回译 / Back-translation）
4. **现实解释 → 实验验证**（检验 / Verification）

> 详细数学依据见 `original-texts.md`

## 不适用场景 / When NOT to Use

- **问题无法量化或结构化**——建模需要可定义的变量和关系 / Problems cannot be quantified or structured — modeling requires definable variables and relations
- **只需要定性理解**（如"这个现象大概是怎么回事"）——建模会过度精确 / Only qualitative understanding needed — modeling over-specifies
- **缺乏基本数据**——没有数据的模型只是猜测 / Insufficient data — a model without data is mere speculation

## 何时使用 / When to Use

- 需要将一个现实问题用数学语言精确表述 / Need to express a real-world problem precisely in mathematical language
- 构建科研模型来解释实验数据或预测新现象 / Building scientific models to explain data or predict new phenomena
- 规划生活决策（预算分配、路线规划、风险评估）需要系统分析 / Planning life decisions requiring systematic analysis
- 评估风险或预测未来趋势 / Assessing risk or forecasting trends
- 需要理解复杂系统中各因素的相互作用 / Understanding interactions among factors in a complex system

## 方法流程 / Method

### 第一步：明确现实问题 / Step 1: Clarify the Real-World Problem

用最清晰的语言描述你要解决的问题。关键问题：
- 系统的**输入**是什么？ / What are the system's **inputs**?
- 系统的**输出**是什么？ / What are the system's **outputs**?
- 系统的**目标**是什么？（预测？解释？优化？）/ What is the **goal**? (Prediction? Explanation? Optimization?)

### 第二步：做出假设 / Step 2: Make Assumptions

这是建模中最关键也最危险的一步。所有模型都需要简化，但必须**明确记录每一个假设**：
- 哪些因素是重要的？哪些可以忽略？ / Which factors matter? Which can be neglected?
- 系统是确定性的还是随机的？ / Is the system deterministic or stochastic?
- 系统是静态的还是动态的？ / Is the system static or dynamic?
- 变量之间是线性的还是非线性的？ / Are variable relations linear or nonlinear?

### 第三步：建立数学结构 / Step 3: Build the Mathematical Structure

根据假设，选择合适的数学框架：
- **变量间的因果关系** → 微分方程 / 差分方程 / Causal relations → ODE/PDE, difference equations
- **空间分布与传播** → 偏微分方程（热传导、波动、扩散）/ Spatial distribution → PDE (heat, wave, diffusion)
- **离散对象的关系** → 图论 / Discrete object relations → Graph theory
- **不确定性下的决策** → 概率模型 / Decision under uncertainty → Probabilistic models
- **资源分配** → 优化模型 / Resource allocation → Optimization
- **群体行为与交互** → 统计模型 / 马尔可夫链 / Agent-based models / Population behavior → Statistical models, Markov chains, ABM
- **分类与预测** → 函数逼近 / 回归模型 / Classification & prediction → Function approximation, regression

**量纲分析（Buckingham Pi 定理）**：在建立方程之前，必须检查量纲一致性。若系统有 n 个物理量涉及 m 个基本量纲，则可构造 k = n − m 个无量纲 Pi 项，从而减少变量个数、简化方程形式。量纲不一致的方程是物理上不可接受的。

**Buckingham Pi Theorem**: Before writing equations, check dimensional consistency. If a system has n physical quantities involving m fundamental dimensions, one can construct k = n − m dimensionless Pi groups, reducing the number of variables and simplifying the equation. Dimensionally inconsistent equations are physically inadmissible.

### 第四步：求解 / Step 4: Solve

用数学方法求解模型。注意：
- **解析解**（精确但可能不存在）/ Analytical solutions (exact but may not exist)
- **数值解**（近似但总能得到）/ Numerical solutions (approximate but always obtainable)
- **定性分析**（不求具体解，只求性质）/ Qualitative analysis (study properties without explicit solutions)

### 第五步：解释与验证 / Step 5: Interpret and Validate

- 将数学解翻译回现实语言 / Translate mathematical solutions back to real-world language
- 与已有数据或实验结果对比 / Compare with existing data or experimental results
- 检查模型预测是否合理（sanity check）/ Sanity check predictions

### 第六步：敏感度分析与模型选择 / Step 6: Sensitivity Analysis & Model Selection

**敏感度分析**：检验模型输出对输入参数的依赖程度。若某参数的小扰动导致输出大幅变化，则该参数为敏感参数，需重点关注其取值精度。

**Sensitivity Analysis**: Examine how model outputs depend on input parameters. If a small perturbation in a parameter causes large output variation, that parameter is sensitive and requires careful estimation.

**偏差-方差权衡**：简单模型偏差高、方差低（欠拟合风险）；复杂模型偏差低、方差高（过拟合风险）。最优模型在偏差与方差之间取得平衡。

**Bias-Variance Tradeoff**: Simple models have high bias and low variance (underfitting risk); complex models have low bias and high variance (overfitting risk). The optimal model balances bias and variance.

**模型选择准则**：
- AIC = −2 log L + 2k（倾向于选择更复杂模型，适用于预测目标）/ AIC = −2 log L + 2k (favors slightly more complex models, suited for prediction)
- BIC = −2 log L + k · log(n)（惩罚更重，倾向于选择更简约模型，适用于解释目标）/ BIC = −2 log L + k · log(n) (heavier penalty, favors parsimony, suited for explanation)
- 交叉验证（CV）：评估样本外预测性能，防止过拟合 / Cross-validation: assess out-of-sample predictive performance, guard against overfitting

### 第七步：迭代与改进 / Step 7: Iterate and Refine

模型几乎总需要改进。如果模型预测与事实不符：
- 是哪个假设出了问题？ / Which assumption failed?
- 是否需要增加新的因素？ / Are new factors needed?
- 是否需要改变数学框架？ / Should the mathematical framework change?

### 第八步：适用范围声明 / Step 8: Declare the Scope of Applicability

明确标注模型在什么条件下有效、什么条件下失效。所有模型都有边界——适用范围声明是模型的"保质期标签"。

Explicitly state under what conditions the model is valid and when it breaks down. Every model has boundaries — the scope declaration is the model's "expiration label."

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|-------------|-------------------------------|---------------------------|
| 过度拟合 / Overfitting | 模型太复杂，拟合了噪声而非信号 / Model fits noise, not signal | 用奥卡姆剃刀：如无必要，勿增实体 / Apply Occam's razor: do not multiply entities beyond necessity |
| 欠拟合 / Underfitting | 模型太简单，无法捕捉关键现象 / Model too simple to capture key phenomena | 检查残差模式，识别缺失的因素 / Check residual patterns, identify missing factors |
| 忽略假设的合理性 / Ignoring assumption validity | 假设只为数学方便而非现实合理 / Assumptions made for mathematical convenience, not realism | 每个假设都要有现实依据 / Every assumption needs real-world justification |
| 外推超出适用范围 / Extrapolating beyond scope | 模型只在某个范围内有效，超出范围失效 / Model only valid within a specific range | 明确标注模型的适用范围 / Explicitly declare scope of applicability |
| 把相关性当因果性 / Confusing correlation with causation | 模型中的关系不等于因果关系 / Statistical relation ≠ causal relation | 区分描述性模型和因果模型 / Distinguish descriptive and causal models |
| 忘记验证 / Skipping validation | 建完模型就直接使用，不检验预测 / Using model without testing predictions | 必须用独立数据验证 / Must validate with independent data |
| 忽略量纲一致性 / Ignoring dimensional consistency | 方程两侧量纲不匹配，物理上不可接受 / Equation sides have mismatched dimensions, physically inadmissible | 建方程前做量纲分析，构造无量纲 Pi 项 / Perform dimensional analysis, form dimensionless Pi groups |
| 仅用样本内拟合选模型（过拟合）/ Selecting models by in-sample fit only | 样本内误差低估真实预测误差；越复杂模型样本内表现越好 / In-sample error underestimates true prediction error; more complex models always look better in-sample | 使用 AIC/BIC 或交叉验证评估样本外性能 / Use AIC/BIC or cross-validation for out-of-sample performance |
| 忽略敏感度分析 / Skipping sensitivity analysis | 不知哪些参数对结果影响最大，可能在不敏感参数上浪费精力 / Unknown which parameters drive results; effort wasted on insensitive parameters | 对关键参数做敏感度分析，重点关注敏感参数 / Perform sensitivity analysis on key parameters, focus on sensitive ones |
| 混淆模型验证与模型选择 / Confusing validation with model selection | 验证检验已有模型是否可靠；选择在候选模型间做比较 / Validation checks reliability of a given model; selection compares candidate models | 先用选择准则(AIC/BIC/CV)选出模型，再用独立数据验证 / First select model (AIC/BIC/CV), then validate with independent data |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：

1. **问题定义**：用一句话描述要解决的现实问题 / Define the real-world problem in one sentence
2. **假设清单**：列出 `[假设N]: [内容]（合理性：高/中/低）` / List assumptions with validity ratings
3. **量纲检查**：对关键物理量做量纲分析，构造无量纲 Pi 项 / Perform dimensional analysis, form dimensionless Pi groups
4. **模型选择**：说明使用的数学框架及理由 `[框架]: [选择] 因为 [理由]` / State mathematical framework and rationale
5. **变量定义**：定义所有变量、参数及其物理意义 / Define all variables, parameters, and their physical meaning
6. **求解方案**：说明求解方法（解析/数值/定性）/ State solution method (analytical/numerical/qualitative)
7. **敏感度分析**：识别敏感参数，评估其对输出的影响 / Identify sensitive parameters, assess their impact on outputs
8. **模型选择准则**：若有候选模型，用 AIC/BIC/CV 比较并选出最优 / If multiple candidates exist, compare via AIC/BIC/CV
9. **验证计划**：如何检验模型的有效性？/ How to validate the model?
10. **适用范围**：明确标注模型在什么条件下有效、什么条件下失效 / Declare conditions where model is valid and where it breaks down

**输出必须包含以上 10 项，不得只输出分析性文字而不给出结论。**
**Output must include all 10 items above. No purely analytical text without conclusions.**

## 与其他 skill 的关系 / Relations to Other Skills

- **公理化思想**：模型的假设类似于公理，需要检验相容性
- **抽象化思想**：建模是抽象化的应用——从现实抽象为数学结构
- **优化思想**：很多模型的目标函数就是优化问题
- **概率与统计**：不确定性建模需要概率论工具
- **变换思想**：模型的求解常常需要变换到更容易处理的表示
- **算法思想**：计算模型（如agent-based模型、元胞自动机）将算法作为建模框架
- **因果推断思想**：因果模型（如DAG、结构因果模型）明确区分因果与相关