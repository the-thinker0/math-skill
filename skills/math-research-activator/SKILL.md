---
name: math-research-activator
description: |
  数学研究操作系统：自动诊断用户意图，路由到思想透镜、激活锚点或设计翻译层。触发于设计/改进模型架构/算子/注意力、分析理论性质、迁移数学结构到 AI 设计，以及密码学安全定义、构造、归约证明与协议分析。不触发于纯工程任务（debug、重构、调参）。
  English: Mathematical research OS — auto-diagnoses user intent, routes to thinking lenses, activation anchors, or design translation layer. Triggers on architecture/operator design, theoretical analysis, math-to-AI transfer, and cryptographic definitions, constructions, reductions, or protocol analysis. Does NOT trigger for pure engineering tasks.
---

> **语言路由与混合输入规则**：看句式/动词/语气词主框架判定主语言。AI/数学/工程术语不计入。代码/路径/公式不计入。中英接近时沿用上一轮，无上下文默认中文。显式要求优先。中文→本文件，英文→`SKILL.en.md`。完整规则见 `../../references/skill-index.md`。

# 数学研究操作系统 / Math Research OS

> "思想系统不负责给定理，知识系统不负责乱启发，设计层不负责装深刻。"

本系统是面向 AI 架构创新与密码学研究的数学参谋部——不是武器库，而是告诉你：**这场仗是什么仗、该用什么兵种、怎么部署、哪里会翻车。**

## 核心原则

> Math Skill 不存储数学，它激活数学、路由数学，并把数学翻译成 AI 研究设计。

- **knowledge-base/** 不是封闭百科，而是数学激活锚点集合（activation anchors）
- 当现有卡片不能覆盖问题时，Agent 不得停止或强行套用，而应基于透镜、参考层和自身数学知识生成"临时知识卡"，继续完成设计翻译
- **design-patterns/** 是 math→AI 翻译原型集合，不是完整模型仓库；无对应模式时根据数学结构临时生成候选设计，并标记为 temporary design pattern

## 三层正交架构

| 层 | 职责 | 目录 | 核心问题 |
|----|------|------|---------|
| **思想透镜** | 诊断问题结构，推荐数学视角 | `../../lenses/*.md` | 这个问题该用什么视角看？ |
| **激活锚点** | 激活高频数学结构，并在不足时触发 Knowledge Gap Protocol | `../../knowledge-base/*/*.md` | 这个视角需要激活哪些数学结构？ |
| **设计翻译** | 把数学变成 AI 模块/loss/算子 | `../../design-patterns/*/*.md` | 这些数学怎么变成模型结构？ |

辅助层：
- `../../references/books/*.md`：10 本书的蒸馏稿，需要深入时的完整上下文；其中 3 本密码学书稿见 `../../references/skill-index.md`
- `../../references/gpu-friendly-math.md`：GPU 八维验收门（唯一权威）
- `../../agents/math-critic.md`：数学-工程双重批判器

## 意图诊断（5 场景）

| 场景 | 诊断信号 | 调用路径 |
|------|---------|---------|
| **A. 问题分析** | "这个设计合理吗？""逻辑链有没有漏洞？" | 透镜 → critic |
| **B. 机制设计** | "设计新 attention""把 X 迁移到 Y" | 透镜 → 激活锚点 → 设计 → critic |
| **C. 知识查询** | "流形上的切空间是什么？""投影定理怎么用？" | 激活锚点 |
| **D. 验证审查** | "这个公式成立吗？""loss 能保证什么？" | 激活锚点 → 相关设计模式（若引用具体 AI 构造）→ critic |
| **E. 纯工程** | debug、重构、调参、代码审查 | **不调用数学系统** |

## 透镜库（15 个数学视角）

15 个透镜覆盖：公理化、对偶、对称性、谱分解、几何、投影与分解、变分、局部到整体、拓扑、范畴化、扰动、因果、博弈、概率统计、算法。目录：`../../lenses/*.md`。完整目录表见 `../../references/skill-index.md`。

## 激活锚点（按数学领域组织）

7 个领域：矩阵分析、最优化、微分几何、李理论、拓扑、概率与信息、信息几何。目录：`../../knowledge-base/*/*.md`。完整目录表见 `../../references/skill-index.md`。

## 设计模式库（按 AI 组件组织）

5 个组件类型：注意力、损失函数、路由、表示、压缩。目录：`../../design-patterns/*/*.md`。完整目录表见 `../../references/skill-index.md`。

## 自动触发条件

**必须同时满足 Gate 1 + Gate 2 + Gate 3 才介入：**

### Gate 0 · 排除门（最高优先级）
以下任务**无论工作区含什么**都不触发：代码审查、debug、重构、调参、构建部署、纯事实查询、通用软件工程。

### Gate 1 · 环境信号
工作区含架构核心代码（attention/transformer/MoE、`*.cu`/kernel）或研究笔记，**或**密码学相关代码/协议描述/安全证明草稿。仅 `model.py`、`trainer.py` 等常规文件**不构成**环境信号。

### Gate 2 · 任务信号
用户任务涉及**设计/改进**新架构/算子、**分析**理论性质、**迁移**数学结构到 AI 设计、**分析密码学构造/安全定义/归约证明/协议**，或**查询与 AI 研究相关的数学知识**（如"切空间在优化中怎么用"）。纯百科式数学或密码学事实查询不自动触发，但可通过 `/ask` 手动进入。

### Gate 3 · 意图匹配
用户意图匹配场景 A/B/C/D 之一。纯工程任务匹配场景 E → 不介入。

> **`/ask` 入口**：手动调用时跳过 Gate 1 和 Gate 2，仅执行 Gate 0（排除门）+ Gate 3（意图匹配），可直接进入任意场景包括知识查询。

## Domain Router（v3.2.0 新增）

> AI 研究与密码学**共享**数学根基，但**独有**各自的专业层。Domain Router 在意图诊断后、调用透镜前，先判定问题归属，决定加载哪些锚点/书稿/设计模式，避免跨域污染与 token 浪费。

### 三层归属判定

| 层 | 信号词示例 | 加载内容 | 独有/共用 |
|----|-----------|---------|----------|
| **AI 研究层** | attention、loss、routing、representation、compression、MoE、transformer、KV-cache、LoRA、SSM、扩散、RL | `../../knowledge-base/`（7 领域 31 锚点）+ `../../design-patterns/`（5 类 22 模式）+ AI 方向 7 本书 | AI 独有 |
| **密码学层** | 加密、签名、MAC、PRF/PRG/PRP、OWF、CCA、CPA、AE、零知识、归约证明、攻击游戏、DL/CDH/DDH、RSA、ECC、格密码 | 3 本密码学书稿 + 共用数学锚点（按需）+ 临时知识卡 | 密码独有 |
| **共用数学层** | 概率、信息论、熵、群、环、域、矩阵、谱、优化、凸性、扰动、复杂度 | `../../knowledge-base/` 中的对应锚点 + `../../lenses/` 透镜 | 共用 |

### 路由规则

1. **先判 domain**：从用户关键词判定主 domain（AI / 密码 / 纯数学查询）。
2. **共用数学不重复加载**：若 domain 是密码学，共用数学锚点（如 `../../knowledge-base/probability/entropy.md`、`../../knowledge-base/matrix-analysis/spectral-decomposition.md`）按需加载，**不**加载 AI 专属的 `../../design-patterns/`。
   - **"按需"判定条件**：当且仅当问题的数学结构映射到该共用锚点的核心定义/公式时加载。即问题陈述中显式出现该锚点对应的核心概念（如"谱""熵""凸""扰动"），或透镜路由/critic 明确指向该锚点。**domain 标签不决定共用锚点加载与否，问题结构决定。**
3. **跨域时显式标注**：若问题确实是 AI×密码交叉（如"用 PRF 做模型水印""对抗样本的归约证明"），Domain Router 显式列出两个 domain 的加载项，并标注交叉点。
   - **交叉点标注模板**（四元组，供 critic 第 19 维第 6 检查点审查）：
     1. **密码学原语 + 安全性质**（如"PRF + 伪随机性"）
     2. **AI 模块 + 功能需求**（如"水印 + 唯一可追踪性"）
     3. **迁移方向**（密码→AI / AI→密码）
     4. **迁移后假设可达性**（原假设在 AI 场景是否仍可达成？如"PRF 的 PRF 假设在 ML 部署中是否可满足"）
4. **不跨域时不污染**：纯 AI 问题不加载密码学书稿；纯密码学问题不加载 AI 设计模式。避免 token 浪费与概念混淆。
5. **缺口协议分 domain**：Knowledge Gap Protocol 生成的临时知识卡标注 domain（AI/密码/共用），便于后续升级到对应正式卡片。

### Domain Router 判定流程图

```
用户问题
  ↓
[Gate 0-3 触发?]
  ↓ 是
Domain Router: 关键词判定主 domain
  ├─ AI 研究 → 加载 knowledge-base + design-patterns + AI 书稿
  ├─ 密码学  → 加载密码学书稿 + 共用数学锚点（按需）
  ├─ 纯数学  → 只加载 lenses + 对应 knowledge-base 锚点
  └─ AI×密码 → 双 domain 加载 + 交叉点标注
  ↓
[场景 A/B/C/D 路由]
  ↓
[透镜 → 锚点/书稿 → 设计翻译（仅 AI）/ 归约模板（仅密码）→ critic]
```

## 主流程

### 第一步：诊断意图
1. 判断用户意图属于场景 A/B/C/D/E 哪个
2. **Domain Router 判定**：问题归属（AI / 密码 / 纯数学 / 交叉）
3. 提取问题核心张力：想保留什么？想抑制什么？约束是什么？工程瓶颈是什么？
4. 输出问题类型分类 + domain 标注

### 第二步：路由调用

```
场景 A（分析）：选 1-3 个透镜 → 输出视角诊断 → critic 审查
场景 B（设计）：选 1-3 个透镜 → 调用相关激活锚点；若无覆盖则进入 Knowledge Gap Protocol → 生成正式/临时设计模式 → critic 审查
  · AI domain：设计模式来自 design-patterns/，产出 attention/loss/routing/representation/compression
  · 密码 domain：设计模式来自密码学书稿的构造范式（SPN/Feistel/Merkle-Damgård/KEM-DEM/Fiat-Shamir），产出加密/MAC/签名/协议
场景 C（查询）：优先加载相关激活锚点或密码学书稿；若无覆盖则生成临时知识卡 → 按知识激活协议输出
场景 D（验证）：加载相关锚点或临时知识卡 → critic 审查条件与边界
  · AI domain：过 GPU 八维验收门
  · 密码 domain：过归约紧度 + 假设依赖 + 实现陷阱检查（不必过 GPU 门）
场景 E（工程）：不介入
```

### 第三步：输出格式

**Token 经济原则**：以下是最长结构，不是默认全文模板。按用户问题裁剪；简单知识查询只给必要定义/公式/风险，设计与 GPU/归约内容只在与问题有关时展开；避免复述已加载卡片全文；**Domain Router 已判定 domain 后，只展开该 domain 的专属小节**。

**场景 A/B 输出**：
1. **[诊断]** 问题类型 + 核心张力
2. **[透镜]** 推荐 1-3 个数学视角（标注为什么适合/不适合）
3. **[知识]**（仅场景 B）激活的数学结构（引用激活锚点或临时知识卡）
4. **[设计]**（仅场景 B）候选 AI 模块草案（引用设计模式或临时设计草案）
5. **[GPU]** 候选过八维门（友好/可改造/不友好）
6. **[结论]** 保留通过双验收门的候选 + 下一步建议

**场景 C 输出**（知识激活协议，按需裁剪）：
1. 最小定义
2. 核心公式
3. 适用问题
4. AI 设计翻译（仅当问题与 AI/算子相关）
5. 工程可行性（仅当涉及实现/GPU）
6. 风险与失效条件
7. 深入参考（仅当用户要追溯或结论依赖外部书稿）

**场景 D 输出**（优先短结论 + 条件边界）：
1. 成立条件
2. 不成立条件
3. 最多能保证什么
4. 不能保证什么
5. 工程可行性（仅当涉及实现/GPU）

**必须给出结论，不得只输出分析而不收敛。**

## GPU 八维验收门

正式术语（唯一权威来源：`../../references/gpu-friendly-math.md`）：
**张量化 / GEMM 可映射 / 复杂度 / 显存与 KV-Cache / 低精度稳定 / 并行与通信 / 稀疏结构 / 算子融合**

**量化评估要求**：对每个候选设计，GPU 评估不应只给 [v]/[~]/[x] 标签，还需回答：
1. 核心操作的 FLOPs 和与 baseline 的比值
2. 峰值显存 (bytes)，是否物化大矩阵
3. bf16/fp8 下的数值稳定性策略
4. 可融合的 kernel 数和预期加速

详见 `../../references/gpu-friendly-math.md` 的量化检查清单。

## 深度查阅协议

- **轻度**：读知识卡片（`../../knowledge-base/*/*.md`），自足可用
- **中度**：读书蒸馏稿（`../../references/books/*.md`），获取更完整上下文；密码学问题优先查阅 `../../references/skill-index.md` 列出的 3 本专门书稿
- **深度**：本机有 `math_book/<PDF>` 时，Agent 自动 `pdftotext` + grep 定位原文页

## 知识缺口协议 / Knowledge Gap Protocol

当用户问题需要的数学工具不在现有 `knowledge-base/` 中时，不得强行套用已有卡片。执行以下流程：

1. **缺口识别**：明确指出现有知识库中没有完全对应的知识卡片。判断缺口属于：新领域、新定理族、新结构、新应用场景，还是已有卡片的组合扩展。

2. **透镜回退**：选择 1-3 个最相关思想透镜，用它们确定问题的数学结构。例如：局部到整体、范畴化、谱分解、投影、因果、扰动等。

3. **候选知识定位**：给出应查找的数学关键词、定理族、概念簇、参考书方向。不要求已有知识卡覆盖，但必须说明为什么这些知识相关。

4. **临时知识卡**：生成一个"临时知识摘要"，格式同正式知识卡：
   - 最小定义
   - 核心结构
   - 适用问题
   - AI 设计翻译
   - GPU 可行性
   - 风险与失效条件
   - **来源与置信度**（必填）：
     - 知识来源：标注为"Agent 推断 / 透镜推导 / 参考书外推 / 需外部验证"
     - 置信度：高（有定理支撑）/ 中（合理推断但未严格证明）/ 低（探索性假说）
     - 未核验声明：列出需要后续验证的关键结论

5. **设计翻译**：若用户目标是机制设计，则将临时知识转译为候选 AI 模块、loss、routing、attention、representation 或 compression 方案。

6. **升级建议**：如果该缺口高频出现，建议新增正式 knowledge card 或 design pattern。

## 工作流范例

完整工作流范例见 `../../references/skill-index.md`。
