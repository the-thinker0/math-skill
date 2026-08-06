---
name: math-skill
description: Math Skill — 数学研究操作系统项目安全约束与工作目录规则
type: project
---

# Math Skill 项目 - 安全约束

## 关键：目录限制

**所有文件操作必须严格限制在本仓库根目录及其子目录内。**

这是当前工作仓库目录。修改仓库外的文件会影响其他项目或系统环境，必须避免。

规则：
- **绝对不要**在本仓库根目录外的任何路径读、写、编辑或创建文件，除非得到明确授权
- **绝对不要**修改 `~/.bashrc`、`~/.profile`、`~/.gitconfig` 或任何用户主目录配置文件
- **绝对不要**修改仓库外的其他项目目录
- **绝对不要**执行可能破坏数据的命令，如 `rm -rf`、删库、改写系统文件等
- 只在本项目目录内运行命令；若命令涉及其他路径，必须先征求用户确认

如果确实需要访问仓库外的路径，先停下来并询问用户。

## 项目上下文

Math Skill 是一个面向 AI 编程助手（Claude Code、Cursor 等）的技能包（skill package）。v3 将其重构为**数学研究操作系统**：三层正交架构（思想透镜 / 数学知识库 / 设计翻译层）+ 意图诊断自动路由。项目本质是 **Markdown 内容工程**，不是可执行代码库。

### 项目结构（v3）

```
math-skill/
├── package.json                  # npm 包描述（files 列出全部发布目录）
├── README.md / README.en-US.md   # 用户文档（中/英）
├── commands/
│   └── ask.md                    # 唯一 slash 入口（手动 /ask，轻量路由）
├── skills/
│   └── math-research-activator/  # 唯一 skill：意图诊断（5 场景）→ 渐进三层路由
│       ├── SKILL.md / SKILL.en.md
│       └── original-texts.md / original-texts.en.md
├── lenses/                       # 思想透镜层：15 个数学视角 × 中英成对
│   # axiomatization, duality, symmetry, spectral, geometric, projection,
│   # variational, local-to-global, topological, categorical, perturbation,
│   # causal, game, probabilistic, algorithmic
├── knowledge-base/               # 锚点层：8 个共用数学域 33 卡 + 密码学域 4 卡 × 中英成对
│   ├── overview.md / overview.en.md  # 知识库索引
│   └── matrix-analysis/ optimization/ differential-geometry/
│       lie-theory/ topology/ probability/ information-geometry/
│       algebraic-geometry/ cryptography/
├── design-patterns/              # 设计翻译层：5 类 22 个模式 × 中英成对
│   └── attention/ loss/ routing/ representation/ compression/
├── references/                   # 方法论（中英成对）+ 书籍蒸馏层
│   ├── agentic-workflow / gpu-friendly-math / inspiration / musings / skill-index（各含 .en.md）
│   └── books/                    # 10 本双语蒸馏稿（7 AI 方向 + 3 密码学；PDF 不发布）
├── agents/
│   └── math-critic.md / .en.md   # 深度审视 Agent（19 维；仅全面/论文级审查按需加载）
├── math_book/                    # 原书 PDF（本机深挖用，不进 npm 包）
└── tests/
    ├── validate.sh               # Linux/macOS 校验（提交前必跑）
    └── validate.ps1              # Windows 校验（与 sh 同步维护）
```

### 核心设计理念

- **三层正交**：透镜只讲"用什么视角看"（不塞定理），知识卡片只给"具体数学工具"（最小定义/核心公式/适用问题/AI 设计翻译/工程可行性/风险），设计模式只做"数学→AI 模块翻译"（含 GPU 可行性与 [v]/[~]/[x] 严谨性标注）
- **意图诊断路由**：激活器按 5 场景（A 分析 / B 设计 / C 查询 / D 验证 / E 纯工程不介入）与 Domain Router（共用数学 / AI / 密码 / AI×密码）按目标与保证判域；`/ask` 或显式点名本 skill 时跳过自动触发判断，但仍排除与数学/安全语义无关的纯工程工作
- **GPU 相关维度检查**：唯一权威 `references/gpu-friendly-math.md`；只检查适用维度，N/A 不为失败，量化主要 FLOPs/显存/低精度风险；纯概念与纯密码安全审查不以 GPU 清单作验收门
- **双语**：lenses、knowledge-base、design-patterns、references（含 books）、agents、SKILL 均为中英成对文件（`.md` + `.en.md`）。用户消息为英文时读 `.en.md`

### 编辑规则

修改 Math Skill 时：
- **透镜名的唯一权威是 `lenses/` 下的 15 个文件名**。全仓库引用透镜（books 蒸馏稿、design-patterns、agents、SKILL.md 路由表）一律用这些名字；禁止使用 v2 旧名（optimization、transformation、modeling、abstraction、probability-statistics、algorithmic-thinking、topological-thinking、discrete-combinatorial 等）
- **中英成对同步**：改任何 `.md` 时必须同步修改对应 `.en.md`
- **计数一致性**：15 透镜 / 37 知识卡（33 共用 + 4 密码）/ 22 设计模式。全仓统一此口径（33 共用 = 矩阵分析 5 + 最优化 5 + 微分几何 6 + 李理论 5 + 拓扑 3 + 概率与信息 5 + 信息几何 2 + 代数几何 2）。增删条目时同步更新：根 `SKILL.md` / `SKILL.en.md` 路由表、`knowledge-base/overview.md`（含 .en）、README（中英）、`tests/validate.sh` 与 `validate.ps1` 的计数与注释
- **相对路径按文件深度写**：二级目录文件（`skills/*/`、`design-patterns/*/`、`knowledge-base/*/`、`references/books/`）用 `../../` 指向仓库根；一级目录文件（`knowledge-base/overview.md`、`agents/`、`references/*.md`）用 `../`
- **commands/ask.md** 是轻量入口，只做路由，不放方法论内容
- **YAML frontmatter**（`skills/*/SKILL.md` 与 `commands/ask.md` 的 name + description）保持格式正确；description 决定自动触发质量，改动需谨慎
- **agents/math-critic.md** 为 19 维（15 核心审视维度 + 工具选择 + GPU 可行性 + 现代数学激活 + 密码学安全），透镜集合变化时需同步映射
- 新建内容优先放在项目目录内，避免散落到仓库外
- 提交前运行 `bash tests/validate.sh` 做校验

## 运行环境

- 本项目是纯 Markdown 内容包，内容运行时无 Python/Node.js 依赖
- 发布校验脚本（`tests/validate.sh` / `validate.ps1`）需要 bash 或 PowerShell；`npm run validate` 需要 Node.js
- 如涉及 npm 发布，使用 `npm publish`（需用户明确授权）

## Git 安全

- 仅在 `math-skill` 仓库范围内进行提交
- 未经用户明确允许，**不推送**任何变更
- 不修改 git 全局配置

## Claude Code 权限与约束

- 允许在 `math-skill` 内读写、创建和修改 Markdown/文本文件
- 允许读取 skills、commands、agents、lenses、knowledge-base、design-patterns、references 等目录下的所有内容
- 允许在该目录内运行非破坏性命令（如校验脚本、npm 命令）
- 禁止访问或修改仓库外的任何代码、配置或系统文件
- 禁止执行任何会影响系统环境或其他用户项目的操作

## 总结

这个文件的唯一目的，是将系统 prompt 的行为约束注入到 Claude Code。请始终遵守：
- 仅在本仓库根目录内活动
- 不改动主目录配置、不改动其他项目
- 任何越界操作必须先问用户


# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
