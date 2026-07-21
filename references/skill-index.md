# Skill 索引：透镜库、激活锚点、设计翻译原型、工作流范例

> 本文件是 `../SKILL.md` 的按需目录。主入口只保留选择规则；不要为清晰问题默认加载本索引。

## Domain Router 总览（v3.2.0）

> 完整定义见 `../SKILL.md` 的 Domain Router 小节。此处仅列摘要表：

| Domain | 加载内容 | 信号词 |
|--------|---------|--------|
| **共用数学** | 8 域 33 锚点（排除 cryptography）+ 相关透镜 | 概率/信息/代数/几何/矩阵/谱/优化/拓扑/复杂度 |
| **AI 研究** | 共用数学按需 + `../design-patterns/`（5 类 22 模式）；书稿仅深查 | attention/loss/routing/representation/compression/MoE/transformer/KV-cache/LoRA/SSM/扩散/RL |
| **密码学** | 4 张密码锚点；不足时才加载 3 本密码学书稿；共用数学按需 | 加密/签名/MAC/PRF/PRG/PRP/OWF/CCA/CPA/AE/零知识/归约/DL/CDH/DDH/RSA/ECC/格密码 |
| **AI×密码交叉** | 双 domain 加载 + 交叉点标注 | "PRF 做模型水印""对抗样本归约""可验证推理" |

> 核心规则：domain 判定先于透镜调用；共用数学按问题结构（非 domain 标签）按需加载；不跨域时不污染；缺口协议临时卡标注 domain。

## v3.2.1 设计哲学修正

> 完整定义见 `../SKILL.md` 的目标、Domain Router 与渐进加载小节。要点：
>
> 1. knowledge-base/ 锚点描述数学结构本身（流形、谱、层上同调、伪随机函数族等），不固化具体 AI 架构（diffusion、SSM、transformer 变体）。
> 2. design-patterns/ 是"数学→AI 模块"的翻译范式示范，不是可复制的模板库；遇新问题应基于数学结构临时生成候选设计。
> 3. 兼容性原则：对未预置架构的研究问题（如未来新范式）通过透镜路由 + 锚点激活 + 临时知识卡完成引导，不声明"不覆盖"。

## 语言路由与混合输入规则（完整版）

语言路由只决定"读取哪个语言版本的说明"和"最终用什么语言回答"，不参与数学系统是否触发、也不参与 A/B/C/D/E 场景判断。

### 判定规则

1. **先判断自然语言主框架**
   - 如果用户的请求句式、动词、语气词主要是中文，即使夹杂英文技术词，也按中文处理。
   - 例如："帮我 design 一个 attention""这个 loss 有没有理论问题""能不能用 manifold 做 routing"均按中文处理。

2. **英文技术词不计入英文主语言**
   - attention、loss、routing、embedding、manifold、operator、kernel、KV-cache、transformer、MoE 等 AI/数学/工程术语视为领域术语，不作为切换到英文的依据。

3. **代码、路径、公式不参与语言判定**
   - 文件路径、函数名、变量名、LaTeX 公式、命令行参数不计入语言比例。

4. **主语言不明显时，沿用用户上一轮主要语言**
   - 若中英文比例接近且无法判断，以用户最近一次明确使用的自然语言为准。
   - 若没有上下文，默认中文。

5. **输出语言与主语言一致**
   - Codex 始终读取权威入口 `../SKILL.md`，按用户主语言回答，不为英文输入重复加载另一份正文。
   - 显式英文命令入口可直接读取 `../SKILL.en.md`，但不得再加载中文入口。
   - 用户明确要求"用英文/用中文"时，以用户显式要求为准。

## 透镜库（15 个数学视角）

每个透镜回答：这是什么视角？适合诊断什么问题？会路由到哪些知识域？

| 透镜 | 文件 | 核心视角 |
|------|------|---------|
| 公理化 | `../lenses/axiomatization.md` | 审查假设的相容性/独立性/完备性 |
| 对偶 | `../lenses/duality.md` | 转换到对偶空间暴露约束与不变量 |
| 对称性 | `../lenses/symmetry.md` | 变换下的不变量与守恒律 |
| 谱分解 | `../lenses/spectral.md` | 特征值/奇异值揭示主导结构 |
| 几何 | `../lenses/geometric.md` | 度量/曲率/流形上的空间结构 |
| 投影与分解 | `../lenses/projection.md` | 正交分解、子空间分离、冲突消除 |
| 变分 | `../lenses/variational.md` | 约束下极值、能量最小化 |
| 局部到整体 | `../lenses/local-to-global.md` | 局部性质拼接为全局、层上同调障碍 |
| 拓扑 | `../lenses/topological.md` | 连续变形不变量、连通性、空洞 |
| 范畴化 | `../lenses/categorical.md` | 泛性质、函子、自然变换 |
| 扰动 | `../lenses/perturbation.md` | 小扰动的传播、稳定性、鲁棒性 |
| 因果 | `../lenses/causal.md` | 相关≠因果、干预、反事实 |
| 博弈 | `../lenses/game.md` | 多方策略互动、均衡、机制设计 |
| 概率统计 | `../lenses/probabilistic.md` | 量化不确定性、贝叶斯更新 |
| 算法 | `../lenses/algorithmic.md` | 复杂度、可行性、并行性 |

## 激活锚点（按数学领域组织）

每个锚点不是封闭知识卡，而是回答：激活什么数学结构、连接哪些更深知识、可翻译成哪些 AI 设计动作、不足时如何扩展。

| 领域 | 目录 | 锚点 |
|------|------|---------|
| 矩阵分析 | `../knowledge-base/matrix-analysis/` | projection, spectral-decomposition, low-rank-approximation, positive-semidefinite, matrix-perturbation |
| 最优化 | `../knowledge-base/optimization/` | lagrangian-duality, convex-optimization, constrained-optimization, riemannian-optimization, proximal-method |
| 微分几何 | `../knowledge-base/differential-geometry/` | manifold, tangent-space, metric-tensor, geodesic, curvature, connection |
| 李理论 | `../knowledge-base/lie-theory/` | group-action, lie-group, lie-algebra, representation, equivariance |
| 拓扑 | `../knowledge-base/topology/` | persistent-homology, euler-characteristic, fundamental-group |
| 概率与信息 | `../knowledge-base/probability/` | concentration-inequality, entropy, kl-divergence, information-bottleneck, fisher-information |
| 信息几何 | `../knowledge-base/information-geometry/` | natural-gradient, fisher-metric |
| 代数几何 | `../knowledge-base/algebraic-geometry/` | sheaf-cohomology, grassmannian-plucker |

## 设计模式库（按 AI 组件组织）

每个设计模式回答：数学来源、AI 模块形式、可实现结构、GPU 可行性、论文表述、风险。

| 组件类型 | 目录 | 模式 |
|---------|------|------|
| 注意力 | `../design-patterns/attention/` | projection-attention, spectral-attention, equivariant-attention, geometry-aware-attention, information-bottleneck-attention |
| 损失函数 | `../design-patterns/loss/` | orthogonality-loss, contrastive-loss, variational-loss, information-bottleneck-loss, constraint-penalty |
| 路由 | `../design-patterns/routing/` | optimal-transport-routing, graph-routing, moe-routing, spectral-clustering-routing |
| 表示 | `../design-patterns/representation/` | shared-private-decomposition, manifold-representation, equivariant-split, subspace-alignment |
| 压缩 | `../design-patterns/compression/` | low-rank-kv-cache, spectral-token-pruning, topology-preserving-compression, leverage-score-selection |

## 密码学参考书蒸馏稿（新增 3 本）

参考层现共 10 本书，全部中英配对。以下 3 本用于密码学安全定义、构造、归约证明与协议分析；按主语言选择 .md 或 .en.md，只有锚点不足时才按需读取。

| 书目 | 文件 | 主要用途 | 激活家族 |
|------|------|---------|---------|
| Boneh & Shoup, *A Graduate Course in Applied Cryptography* | `books/applied-cryptography.md` | 攻击游戏、归约证明、对称/公钥构造、零知识与协议 | 定义系/归约系/原语系/协议系 |
| Goldreich, *Foundations of Cryptography, Volume 1: Basic Tools* | `books/foundations-of-cryptography.md` | 计算不可区分、OWF/PRG/PRF、零知识与承诺、元定理 | 定义系/证明系/构造系/元理系 |
| Katz & Lindell, *Introduction to Modern Cryptography*, 2nd ed. | `books/introduction-to-modern-cryptography.md` | 形式化安全定义、IND/CCA、MAC、哈希与数字签名、构造范式 | 定义系/证明系/原语系/假设系/构造系 |

> **Domain Router 提示**：这三本书属**密码学层**，仅当 Domain Router 判定问题属密码学或 AI×密码交叉时加载。纯 AI 问题不加载。共用数学锚点（概率/信息/代数）按需加载，不重复。
>
> **v3.2.1 补齐**：新增 knowledge-base/cryptography/ 锚点目录（含 prf-prg-owf、reduction-proof-template、attack-game-framework、cca-cpa-ae-hierarchy 四张卡）与 knowledge-base/algebraic-geometry/ 目录（含 sheaf-cohomology、grassmannian-plucker 两张卡）。密码学层不再仅有书稿，有结构化锚点可供轻度查阅。

## 工作流范例

**用户**："设计新的 KV Cache 压缩方法，保留长期依赖，不想只做 top-k"

```
第一步 诊断：场景 B（机制设计）
  问题类型：序列记忆压缩 + 信息保留 + 长程结构
  核心张力：压缩 token 数量 vs 不破坏长期依赖

第二步 透镜选择：
  1. 谱分解（保留主导子空间）
  2. 信息论（保留最大互信息状态）
  3. 拓扑（保留序列结构关键连接点）

第三步 激活锚点：
  → low-rank-approximation（矩阵分析锚点）
  → leverage-score-selection（压缩设计模式）
  → information-bottleneck（概率与信息锚点）
  若现有锚点不足，进入 Knowledge Gap Protocol 生成临时知识卡。

第四步 设计翻译：
  候选 A：Spectral KV Compression（低秩 + leverage score）
  候选 B：Information-Preserving Cache（query sensitivity）
  候选 C：Topology-Preserving Cache（图桥接节点保留）

第五步 Critic 审查：
  A 最 GPU 友好，B 需估计未来 query 有不确定性，C 图构建成本过高
  建议：优先 A，B 作轻量 gate
```
