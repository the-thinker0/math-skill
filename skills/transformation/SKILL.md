---
name: transformation
description: |
  触发：当问题在当前表示下难以处理，需要换个角度、将难题分解为简单问题，或寻找等价的更简单表述时调用。
  English: Trigger when a problem is intractable in its current representation and needs a different perspective, decomposition into simpler problems, or an equivalent but simpler formulation.
---

# 🔄 变换思想

> "通过数学变换将复杂问题转化为更容易解决的等价问题。"
> "Transforming complex problems into equivalent problems that are easier to solve through mathematical transformations."
>
> —— 傅里叶变换、拉普拉斯变换、坐标变换
> —— Fourier Transform, Laplace Transform, Coordinate Transformation

## 核心原则 / Core Principle

**同一个问题可以有不同的表示方式。选择一个好的表示（或变换），可以让困难的问题变得简单。变换的精髓不是改变问题本身，而是改变我们看问题的视角。**

**The same problem can be represented in different ways. Choosing a good representation (or transformation) can make a difficult problem simple. The essence of transformation is not changing the problem itself, but changing our perspective on the problem.**

形式化表述：设变换 T: D₁ → D₂，T 有用当且仅当三个条件同时成立：
1. T 可计算：对 D₁ 中元素 x，T(x) 可以显式求出
2. 简化性：问题在 D₂ 中比在 D₁ 中更容易处理（如微分→乘法、卷积→乘法）
3. T⁻¹ 存在：可以从 D₂ 的解恢复 D₁ 的原解

核心追问：**T⁻¹ 在什么条件下存在？** 这是变换思想最本质的数学问题——存在性决定等价性，收敛域决定有效性。

Formally: let T: D₁ → D₂. T is useful iff three conditions hold simultaneously:
1. T is computable: for x ∈ D₁, T(x) can be explicitly obtained
2. Simplification: the problem is easier in D₂ (e.g., differentiation → multiplication, convolution → multiplication)
3. T⁻¹ exists: the original solution in D₁ can be recovered from D₂

Key question: **Under what conditions does T⁻¹ exist?** This is the most essential mathematical question of transformation — existence determines equivalence, convergence domain determines validity.

变换的核心性质：
- **等价性**：变换前后的问题是等价的（信息不丢失），要求 T⁻¹ 存在
- **简化性**：变换后的问题更容易处理
- **可逆性**：T⁻¹ 存在且可计算时，变换是等价的而非近似的

## 不适用场景 / When NOT to Use

- **问题已经足够简单**——不需要变换 / The problem is already simple enough — no transformation needed
- **变换会丢失关键信息**（如不可逆变换且丢失的信息正是关心的）——需要选择保信息的变换 / Transformation loses critical information (e.g., irreversible transform discards the quantity of interest) — choose an information-preserving transform
- **只需要定性理解**——变换通常是定量工具 / Only qualitative understanding is needed — transformation is typically a quantitative tool
- **收敛条件不满足**——强行变换会产生无意义结果 / Convergence conditions are not met — forcing a transform yields meaningless results

## 何时使用 / When to Use

- 一个问题在当前形式下难以分析或求解 / A problem is hard to analyze or solve in its current form
- 想要揭示数据的隐藏结构（如周期信号→频谱） / Revealing hidden structure in data (e.g., periodic signal → frequency spectrum)
- 需要将复杂运算简化为简单运算（如卷积→乘法） / Simplifying complex operations (e.g., convolution → multiplication)
- 需要将非线性问题线性化 / Linearizing nonlinear problems
- 需要解耦耦合变量 / Decoupling coupled variables
- 在日常生活中换个角度看问题，将难题分解 / In daily life, changing perspective to decompose hard problems

## 方法流程 / Method

### 第一步：分析当前表示的困难 / Analyze the Difficulty in the Current Representation

为什么当前形式难以处理？/ Why is the current form hard to handle?
- 运算复杂？（如微分方程直接求解困难）/ Complex operations? (e.g., solving differential equations directly)
- 结构不清晰？（如时域看不出周期性）/ Unclear structure? (e.g., periodicity invisible in time domain)
- 变量耦合？（如多变量相互依赖）/ Coupled variables? (e.g., mutual dependencies among variables)

### 第二步：选择变换 / Choose the Transformation

根据困难类型选择变换，每种变换必须检查其公式、域映射、收敛条件与简化效果。/ Choose based on difficulty type; for each transform, check formula, domain mapping, convergence conditions, and simplification effect.

| 变换 / Transform | 公式 / Formula | 域映射 / Domain Mapping | 收敛/有效性条件 / Convergence/Validity | 简化效果 / Simplification |
|---|---|---|---|---|
| 傅里叶变换 Fourier | F(ω) = ∫₋∞⁺∞ f(t)e⁻ⁱωᵗdt | t ∈ ℝ → ω ∈ ℝ | Dirichlet条件：f绝对可积、有限极值点数、有限间断点数 | 微分→乘法，卷积→乘法 |
| 拉普拉斯变换 Laplace | F(s) = ∫₀⁺∞ f(t)e⁻ˢᵗdt | t ∈ [0,∞) → s ∈ ℂ, Re(s)>α | ∃α: ∫₀⁺∞ |f(t)|e⁻αᵗdt < ∞ (Re(s)>α 时收敛) | 常系数ODE→代数方程，含初值 |
| Z变换 Z-transform | F(z) = Σₙ₌₀⁺∞ f[n]z⁻ⁿ | n ∈ ℕ → z ∈ ℂ, |z|>R | ∃R: Σ|f[n]|R⁻ⁿ < ∞ (|z|>R 时收敛) | 差分方程→代数方程 |
| 生成函数 Generating | G(x) = Σₙ₌₀⁺∞ aₙxⁿ | n ∈ ℕ → x ∈ ℝ, |x|<ρ | ∃ρ: Σ|aₙ|ρⁿ收敛 (|x|<ρ时) | 递推关系→微分方程 |
| Legendre变换 Legendre | f*(p) = supₓ(px − f(x)) | x → p = f'(x) | f凸且可微时 p↔x 一一对应 | 凸优化→对偶问题，Lagrange力学→Hamilton力学 |
| 小波变换 Wavelet | W(a,b) = ∫ f(t)ψₐᵇ(t)dt, ψₐᵇ=(1/√a)ψ((t−b)/a) | t ∈ ℝ → (a,b) ∈ ℝ⁺×ℝ | f ∈ L²(ℝ), ψ容许：∫|Ψ(ω)|²/|ω|dω<∞ | 时频局部化，多尺度分析 |

### 第三步：执行变换 / Apply the Transformation

将问题变换到新的表示空间，严格按公式执行。/ Transform the problem to the new representation space, executing strictly by formula.

### 第四步：验证收敛与域条件 / Verify Convergence and Domain Conditions

**在应用变换结果之前，必须验证收敛条件是否满足。** / **Before applying transform results, convergence conditions must be verified.**

- 傅里叶变换：检查 f(t) 是否满足 Dirichlet 条件（绝对可积 ∫|f(t)|dt < ∞，有限极值点，有限间断点）；不满足则 F(ω) 无意义
- 拉普拉斯变换：确定收敛域 Re(s) > α；所有运算必须在收敛域内进行，F(s) 在收敛域外无定义
- Z变换：确定收敛域 |z| > R；逆变换依赖收敛域的选择
- 生成函数：确定收敛半径 ρ；|x| < ρ 时级数才有意义
- 小波变换：验证母小波 ψ 的容许条件 ∫|Ψ(ω)|²/|ω|dω < ∞

### 第五步：在变换空间求解 / Solve in the Transformed Space

在新表示下，问题往往变得更简单。所有运算必须在变换的有效域内进行。/ In the new representation, the problem is often simpler. All operations must stay within the transform's valid domain.

### 第六步：逆变换回原空间 / Inverse Transform Back

将解逆变换回原问题的语言。逆变换的存在性需要条件：/ Translate the solution back via inverse transform. Inverse existence requires conditions:

- 傅里叶逆变换：f(t) = (1/2π)∫₋∞⁺∞ F(ω)eⁱωᵗdω，需要 F(ω) 绝对可积
- 拉普拉斯逆变换：f(t) = (1/2πi)∫ᵧ₋ⁱ∞ᵧ₊ⁱ∞ F(s)eˢᵗds (Bromwich积分)，γ > α 确保积分路径在收敛域右侧
- Z逆变换：f[n] = (1/2πi)∮ F(z)zⁿ⁻¹dz，围道必须在收敛域内
- 生成函数逆映射：aₙ = G⁽ⁿ⁾(0)/n!（泰勒展开系数），或 [xⁿ]G(x)

### 第七步：验证等价性 / Verify Equivalence

确认变换过程没有丢失关键信息，逆变换的结果确实是原问题的解。检查：/ Confirm no critical information was lost, and the inverse result is indeed the solution. Check:
- 逆变换是否在收敛域内执行 / Was inverse executed within convergence domain?
- 原函数是否满足变换的前置条件 / Does the original function satisfy transform prerequisites?
- 边界条件/初值条件是否被正确编码 / Were boundary/initial conditions correctly encoded?

## 常见错误 / Common Errors

| 错误 / Error | 数学批评 / Mathematical Critique | 正确做法 / Correct Approach |
|---|---|---|
| 选择不合适的变换 / Choosing an unsuitable transform | 变换没有简化问题，反而增加复杂度 / Transform adds complexity instead of simplifying | 根据问题特征选择变换 / Choose transform based on problem characteristics |
| 使用不可逆变换且丢失信息 / Using irreversible transform that loses information | 变换后无法回到原问题 / Cannot return to original problem after transform | 检查变换是否可逆，或确认丢失的信息不重要 / Verify invertibility or confirm lost info is irrelevant |
| 忘记逆变换 / Forgetting the inverse transform | 在新空间得到解后忘记变回来 / Solution in new space not translated back | 变换只是手段，最终答案必须在原空间 / Transform is a tool; final answer must be in original space |
| 变换后忽略定义域变化 / Ignoring domain changes after transform | 变换可能改变定义域或引入奇异点 / Transform may change domain or introduce singularities | 检查变换后的定义域和边界条件 / Check transformed domain and boundary conditions |
| 把变换当魔法 / Treating transform as magic | 变换只是换了表示，没有改变问题本质 / Transform only changes representation, not the problem itself | 变换是工具，理解力才是核心 / Transform is a tool; understanding is fundamental |
| 对不可积函数用傅里叶变换 / Applying Fourier transform to non-integrable functions | ∫|f(t)|dt = ∞ 时 F(ω) 可能不存在或无意义 / F(ω) may not exist or be meaningless when ∫|f(t)|dt = ∞ | 先检查 Dirichlet 条件，不满足时考虑广义函数或Laplace / Check Dirichlet conditions first; if unsatisfied, use generalized functions or Laplace |
| 忽略Laplace收敛域 / Ignoring Laplace convergence domain | F(s)仅在Re(s)>α有定义，域外运算无意义 / F(s) is defined only for Re(s)>α; operations outside are meaningless | 明确收敛域，所有运算限制在Re(s)>α内 / Specify convergence domain; restrict all operations to Re(s)>α |
| 假设所有变换可逆 / Assuming all transforms are invertible | 部分变换在特定条件下不可逆（如非凸函数的Legendre变换） / Some transforms are non-invertible under certain conditions (e.g., Legendre on non-convex f) | 验证可逆条件后再执行逆变换 / Verify invertibility conditions before applying inverse |
| 忽略离散变换(DFT/FFT) / Ignoring discrete transforms (DFT/FFT) | 连续变换不适用于离散数据，强行使用引入误差 / Continuous transforms unsuitable for discrete data; forced use introduces error | 对离散数据使用DFT: X[k]=Σx[n]e⁻ⁱ2πkn/N / Use DFT for discrete data |

## 操作规程 / Operating Procedure

当本 skill 被触发时，执行以下具体步骤：/ When this skill is triggered, execute the following steps:

1. **当前表示的困难**：描述为什么当前形式难以处理 `[困难]: [描述]`
2. **变换选择**：`[变换]: [选择] 因为 [理由]，公式为 [公式]，收敛条件为 [条件]，预期简化效果是 [效果]`
3. **变换执行**：描述变换后的问题形式
4. **收敛与域条件验证**：`[验证]: [条件是否满足，收敛域是什么]`
5. **变换空间中的求解**：在新表示下的解法
6. **逆变换**：将解翻译回原空间，注明逆变换条件
7. **等价性验证**：验证变换是否可逆、是否丢失信息、收敛域是否正确

**输出必须包含以上 7 项，不得只输出分析性文字而不给出结论。每项必须含具体数学内容，不得仅写概述。**

## 与其他 skill 的关系 / Relations to Other Skills

- **抽象化思想**：变换也是一种抽象——在新的结构中表示同一个对象
- **对称与不变性**：变换下保持不变的性质就是对变换的对称性
- **优化思想**：变换到对偶空间有时使优化更容易
- **建模思想**：变换常常是模型求解的关键步骤
- **算法思想**：FFT将DFT的O(N²)复杂度降为O(N log N)，是变换思想在计算效率上的体现
- **信息论思想**：编码即变换——信源编码将信息变换为高效表示，信道编码变换为抗干扰表示