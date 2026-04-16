# 数学出处与经典文献 / Mathematical Sources and Classic Texts

## 命题逻辑 / Propositional Logic

**基本推理规则**：

| 规则名 | 形式 | 有效性 |
|--------|------|--------|
| 假言推理 (Modus Ponens) | P → Q, P ⊢ Q | ✅ 有效 |
| 拒取式 (Modus Tollens) | P → Q, ¬Q ⊢ ¬P | ✅ 有效 |
| 假言三段论 | P → Q, Q → R ⊢ P → R | ✅ 有效 |
| 析取三段论 | P ∨ Q, ¬P ⊢ Q | ✅ 有效 |
| 肯定后件 | P → Q, Q ⊢ P | ❌ 无效 |
| 否定前件 | P → Q, ¬P ⊢ ¬Q | ❌ 无效 |

## Boole 布尔代数 / Boolean Algebra (1854)

George Boole 在 *An Investigation of the Laws of Thought* (1854) 中建立了命题逻辑的代数化系统，将逻辑推理转化为代数运算：

> "逻辑是代数的一种，其变量仅取 0 与 1 两个值。"
> "Logic is a species of algebra whose variables take only the values 0 and 1."

布尔代数的核心运算：∧ (乘法), ∨ (加法), ¬ (补), 满足分配律、德摩根律等代数性质。这是命题逻辑的代数对偶——同一推理结构既可用演绎方式也可用计算方式处理。布尔代数后来成为数字电路设计（Shannon, 1938）与计算机科学的数学基础。

## Frege《概念文字》/ Frege's *Begriffsschrift* (1879)

Frege 发明了第一个完整的一阶逻辑形式系统，引入量词 (∀, ∃) 和函数符号，展示了逻辑推理可以被完全机械化。这是现代数理逻辑的起点——从此，数学证明有了精确的语法规则，而非仅靠直觉叙述。

> "算术真理能否被纯逻辑地证明？概念文字为此提供了工具。"
> "Can arithmetical truths be proved purely logically? The Begriffsschrift provides the instrument for this."

## Peano 公理 / Peano Axioms (1889)

从逻辑出发构建自然数体系：

> 1. 0 是一个自然数。
> 2. 每个自然数 n 有一个后继 S(n)。
> 3. 0 不是任何自然数的后继。
> 4. 不同的自然数有不同的后继。
> 5. （归纳公理）如果一个性质对 0 成立，且对 n 成立则对 S(n) 也成立，则该性质对所有自然数成立。

这展示了如何从最少量的逻辑假设出发构建一个完整的数学体系。Peano 公理是一阶理论的典范——仅用一条二阶归纳公理（或一阶归纳公理模式）即可刻画自然数的全部结构。

## Russell 悖论 / Russell's Paradox (1901)

> "考虑所有不包含自身的集合所组成的集合 R：R 是否包含 R？"
> "Consider the set R of all sets that do not contain themselves: does R contain R?"

若 R ∈ R，则按定义 R ∉ R；若 R ∉ R，则按定义 R ∈ R。矛盾不可消解。此悖论直接摧毁了 Frege 的朴素集合论（Frege 在收到 Russell 信后承认其系统存在根本缺陷），引发了数学基础的"第三次危机"。由此催生了：

- **ZFC 集合论** (Zermelo-Fraenkel + Choice)：通过限制集合构造规则（分离公理模式而非概括公理）排除悖论
- **类型论** (Russell, 1908)：通过类型层级禁止自指
- **直觉主义** (Brouwer)：拒绝将无穷集视为已完成对象

Russell 悖论深刻揭示：逻辑系统的一致性不能被默认，必须被证明或被构造性地保证。

## ZFC 集合论 / ZFC as Background Logic for Mathematics

Zermelo-Fraenkel 集合论加选择公理 (ZFC) 是当代数学的默认基础语言——几乎所有数学对象（数、函数、空间、群）都可以在 ZFC 中被定义为集合，所有数学定理都可以（原则上）被翻译为 ZFC 中的形式证明。

> "数学家在日常工作中不写 ZFC 证明，但他们默认所有证明都可以在 ZFC 中被形式化。"
> "Mathematicians do not write ZFC proofs in daily work, but they presuppose that all proofs can in principle be formalized in ZFC."

ZFC 的九条公理（外延、空集、配对、并集、幂集、无穷、分离、替换、选择）精心规避了 Russell 悖论，同时保留了足够强的构造能力。选择公理 (AC) 引发了持续争议——它允许非构造性选择（如 Zorn 引理、良序定理），在 Banach-Tarski 分球等反直觉结果中显露其代价。

## 一阶逻辑 vs 高阶逻辑 / First-Order vs Higher-Order Logic

**一阶逻辑 (FOL)**：量词仅作用于个体 (∀x, ∃x)，不允许量化谓词或函数。这是数理逻辑的"标准语言"，拥有完备性（Gödel 1929）和紧致性。

**高阶逻辑 (HOL)**：允许量化谓词 (∀P) 和函数 (∀f)，表达力更强但代价沉重——高阶逻辑**不完备**（无递归可枚举的证明系统能覆盖所有有效推理），且不可紧致。

> "一阶逻辑是完备的但表达力受限；高阶逻辑表达力强但不可完备。这是一个根本性的权衡。"
> "First-order logic is complete but limited in expressive power; higher-order logic is expressive but incomplete. This is a fundamental trade-off."

Peano 算术 (PA) 是一阶理论，其归纳公理被编码为无穷多条一阶公理模式；真正的 Peano 公理（二阶归纳）唯一刻画 ℕ，但一阶 PA 有非标准模型。这直接联系到 Löwenheim-Skolem 定理。

## Gödel 完备性 vs 不完备性 / Completeness (1929) vs Incompleteness (1931)

**完备性定理 (1929)**：一阶逻辑的演绎系统是完备的——每个逻辑上有效的公式都可被形式证明。

> "一阶逻辑中，所有逻辑上有效的公式都可以从公理出发通过形式推理得到证明。"
> "In first-order logic, all logically valid formulas can be proved from the axioms through formal inference."

**不完备性定理 (1931)**：任何包含基本算术的一致形式系统都存在不可判定命题——既不可证也不可否证。

> "任何足够强的一致形式系统 T 中，存在语句 G 使得 T ⊬ G 且 T ⊬ ¬G。"
> "In any sufficiently strong consistent formal system T, there exists a sentence G such that T ⊬ G and T ⊬ ¬G."

关键区别：完备性定理说的是**逻辑系统本身**不遗漏有效推理；不完备性定理说的是**算术理论**无法穷尽所有真理。二者不矛盾——完备性保证"推理规则够用"，不完备性揭示"算术真理超出任何固定公理集"。

## Löwenheim-Skolem 定理 / Löwenheim-Skolem Theorem (1920, 1922)

> "若一阶理论 T 有无穷模型，则 T 对每个无穷基数 κ ≥ ℵ₀ 都有模型。"
> "If a first-order theory T has an infinite model, then T has a model of every infinite cardinality κ ≥ ℵ₀."

下 Löwenheim-Skolem：T 必有可数模型。上 Löwenheim-Skolem：T 必有任意大基数模型。

震撼性推论：一阶理论**无法控制其模型的基数**。即使 ZFC 旨在描述一个不可数集合宇宙，ZFC 本身也有可数模型（Skolem 悖论）。这揭示了一阶逻辑的表达力根本性限制——一阶语句无法区分"可数"与"不可数"的内部视角与外部视角。

## Tarski 真理的语义理论 / Tarski's Semantic Theory of Truth (1933)

> "'雪是白的'为真，当且仅当雪是白的。"
> "'Snow is white' is true if and only if snow is white."

Tarski 给出了真理的形式定义 (T-schema)，展示了逻辑中"真"与"可证"的区别——"真"是语义概念（取决于模型），"可证"是语法概念（取决于证明系统）。完备性定理连接二者（在 FOL 中 T ⊢ φ ⇔ T ⊨ φ），但在算术等强理论中二者永久分离（Gödel 不完备性）。

Tarski 还证明了：足够强的语言**不可能在自身内部一致地定义真理**——真理定义必须使用更强的元语言。这与 Russell 悖论和 Gödel 不完备性形成三重不可自指限制。

## Gentzen 自然演绎与相继演算 / Gentzen's Natural Deduction and Sequent Calculus (1935)

Gerhard Gentzen 在 *Investigations into Logical Deduction* 中发明了两种全新的证明结构：

**自然演绎 (Natural Deduction)**：推理规则围绕引入 (I) 和消除 (E) 每个逻辑联结词组织——∧I, ∧E, →I, →E, ∀I, ∀E 等。这捕捉了数学家的实际推理方式：假设一个前提，推导结论，然后取消假设（→I 即条件证明）。

**相继演算 (Sequent Calculus)**：证明的对象是相继式 Γ ⊢ Δ（左边假设，右边结论），规则在相继式之间操作。关键突破：**切割消除定理** (Hauptsatz)——任何使用切割规则 (Cut) 的证明都可以被转化为无切割证明。

> "主定理 (Hauptsatz) 表明：所有证明都可以被转化为无切割的证明，即消除一切'中间公式'。"
> "The Hauptsatz states that all proofs can be transformed into cut-free proofs, eliminating all 'intermediate formulas'."

切割消除是证明论的核心工具：它保证了子公式性质（无切割证明的每一步只涉及最终结论的子公式），使得一致性和可判定性证明成为可能。Gentzen 的工作将逻辑从"公理化"转向"结构化"，开创了证明论 (Proof Theory) 这一学科。

## Turing 停机问题 / Turing's Halting Problem (1936)

Alan Turing 在 *On Computable Numbers* 中定义了 Turing 机，并证明了：

> "不存在通用算法能判定任意 Turing 机是否在任意输入上停机。"
> "There is no general algorithm that can decide whether an arbitrary Turing machine halts on an arbitrary input."

停机问题的不可判定性是计算与逻辑的根本性限制。它的逻辑本质与 Gödel 不完备性等价：若停机可判定，则算术不完备性可被绕过；若算术完备，则停机可被判定。二者互为对偶——同一堵墙的两个面。

停机问题的直接推论：一阶逻辑的**有效性判定问题** (Entscheidungsproblem) 也是不可判定的（Church, 1936; Turing, 1936）——不存在通用算法能判定任意一阶公式是否逻辑有效。逻辑演绎可以被执行，但不可被机械地全面预判。

## Robinson 消解与合一 / Resolution and Unification (1965)

J. A. Robinson 在 *A Machine-Oriented Logic Based on the Resolution Principle* 中引入了消解规则：

> "从 P ∨ Q 和 ¬P ∨ R 消解得到 Q ∨ R。"
> "Resolve P ∨ Q and ¬P ∨ R to obtain Q ∨ R."

消解将所有推理压缩为一条规则加上合一算法 (Unification)——自动寻找使两个项相等的代数替换 σ，使得 σ(P) = σ(P')，从而对互补文字执行消解。

消解-合一是自动定理证明 (Automated Theorem Proving) 和逻辑编程 (Logic Programming, e.g. Prolog) 的数学核心。它证明了：一阶逻辑的证明搜索可以被统一为一个算法过程，尽管效率问题（搜索空间爆炸）在实践中仍然严峻。

## Curry-Howard 对应 / Curry-Howard Correspondence (1969)

> "命题即类型，证明即程序。"
> "Propositions as types, proofs as programs."

Curry (1958) 首先观察到组合逻辑的类型与命题逻辑的公式之间的对应；Howard (1969) 将其扩展到构造性谓词逻辑：

| 逻辑概念 | 类型论/编程概念 |
|----------|----------------|
| 命题 A | 类型 A |
| A ∧ B | A × B (积类型) |
| A ∨ B | A + B (和类型) |
| A → B | A → B (函数类型) |
| ∀x. P(x) | Πx:A. P(x) (依赖函数类型) |
| ∃x. P(x) | Σx:A. P(x) (依赖对类型) |
| 构造性证明 | 可执行程序 |

Curry-Howard 对应揭示了逻辑演绎与计算之间的深层同构：一个构造性证明就是一个程序，程序的执行就是证明的归约 (proof normalization)。这是 Gentzen 切割消除在计算层面的对应——β-归约就是切割消除。

此对应成为类型论 (Martin-Löf, 1972)、依赖类型编程 (Coq, Agda) 和同伦类型论 (HoTT, 2013) 的理论基础，将"证明正确性"与"程序正确性"统一为同一问题。

## 常见逻辑谬误的形式化

| 谬误名 | 形式 | 反例 |
|--------|------|------|
| 肯定后件 | P → Q, Q ∴ P | "如果下雨则地湿，地湿，所以下雨了"（可能是洒水车） |
| 否定前件 | P → Q, ¬P ∴ ¬Q | "如果下雨则地湿，没下雨，所以地不湿"（可能是洒水车） |
| 循环论证 | P ∴ P | "这本书说的是真话，因为书上这么写的" |
| 稻草人 | 攻击 P' ≠ P | A: "应该增加教育预算" B: "你想把所有钱都给学校" |
| 滑坡 | A → B → ... → Z, ∴ ¬A | "允许这个→那个→灾难，所以不能允许" |