# Eval Suite — 三层评测体系

math-skill 的评测分三层。**Tier 1 在 CI 里必跑且零依赖**；Tier 2 配置 agent CLI 后可跑；Tier 3 是人工判读清单（结论质量等无法机械判定的断言）。三层共用同一批 prompt，单一事实来源由 Tier 1 强制对齐。

| 层 | 入口 | 跑什么 | 何时跑 |
|---|---|---|---|
| **Tier 1 静态自动化** | `node tests/eval/run_eval.mjs` | schema 校验、纸面 ↔ manifest 双向 parity、Domain Router 隔离策略、may_load 引用存在性 | 每次提交（`validate.sh` 自动调用 / `npm run eval`） |
| **Tier 2 行为级评测** | `MATH_SKILL_EVAL_CMD='…' node tests/eval/behavioral_eval.mjs` | 真实 agent 对每个 prompt 的输出做机械判定：E 场景不引用任何 skill 材料、纯 AI 不引密码材料、纯密码不引设计模式、中文主语言 CJK 占比达标 | 接入 agent 运行时后（CI 可选，未配置时安全跳过） |
| **Tier 3 人工判读** | 本目录 9 个 `*.md` 纸面文件 | 结论先行、四元组完整性、临时卡来源/置信度校准、反模式识别等语义断言 | 版本发布前人工抽查 |

## 纸面文件索引

| 文件 | 场景 | 预期行为 |
|------|------|---------|
| `should-trigger-design.md` | B 设计 | 最小路径：透镜 → 锚点 → 0–2 原型 → 紧凑审查 |
| `should-trigger-knowledge.md` | C 查询 | 直接加载知识卡：定义 + 公式/直觉 + 适用边界 |
| `should-trigger-analysis.md` | A 分析 | 1–2 透镜 → 假设/逻辑/边界紧凑审查；完整 critic 仅显式全面审查时加载 |
| `should-trigger-verification.md` | D 验证 | 1–2 锚点 → 短结论 + 条件/边界；识别已知反模式 |
| `should-not-trigger.md` | E 纯工程 | 不加载任何数学材料 |
| `cross-domain-routing.md` | AI×密码 | 双域材料 + 四元组交叉标注一次 |
| `domain-router-isolation.md` | 分域隔离 | 纯 AI 不载密码；纯密码不载 AI 设计模式；边界例不误判 |
| `knowledge-gap-protocol.md` | 缺口协议 | 六步协议 + 临时卡必须带 domain/来源/置信度/未核验结论 |
| `mixed-language-routing.md` | 语言路由 | 句框决定主语言；术语词不触发换语 |

## Tier 1：manifest 与 parity 机制

- `cases.jsonl` 是全部 68 个用例的机器可读 manifest，每行一个对象：

  ```json
  {"id":"A1","source":"should-trigger-analysis.md","prompt":"…","lang":"zh",
   "scenario":"A","domain":"ai","trigger":true,
   "may_load":["knowledge-base/matrix-analysis/matrix-perturbation.md"],"notes":"…"}
  ```

- runner 断言（任一失败即非零退出）：
  - **schema**：必填字段、枚举值（scenario A–E / domain 五类）、id 唯一；
  - **一致性**：`trigger=false ⇔ scenario=E ∧ domain=none`；`lang=zh` 必含汉字；
  - **parity（防漂移核心）**：从 9 个纸面文件的 Test Cases / Should … / Edge case 段提取 prompt，与 manifest 做**双向多重集比对**——纸面加例而忘更 manifest（或反之）都会失败；
  - **隔离策略**：`domain=ai` 的 may_load 触碰密码锚点/书稿即失败；`domain=crypto` 触碰 `design-patterns/` 即失败；E 用例必须声明零加载；
  - **存在性**：每条 may_load 路径必须在仓库中真实存在；
  - **规模下限**：manifest < 60 例视为截断事故。

## Tier 2：接入真实 agent

```bash
# 以 Claude Code headless 为例
MATH_SKILL_EVAL_CMD='claude -p "{prompt}"' node tests/eval/behavioral_eval.mjs

# 只跑某个纸面文件 / 限量 / 调超时
MATH_SKILL_EVAL_CMD='codex exec "{prompt}"' \
  node tests/eval/behavioral_eval.mjs --only should-not-trigger --limit 5 --timeout-ms 120000
```

- `{prompt}` 是占位符，在 argv 层拼接（不经过 shell），prompt 内的 `$`、引号、反引号不会破坏命令模板；
- 未配置 `MATH_SKILL_EVAL_CMD` 时打印 SKIP 并以 0 退出，因此可以安全常驻 CI；
- 判定是确定性的（路径引用、CJK 占比、长度阈值），不依赖第二个 LLM；语义质量判读归 Tier 3。

## 如何新增用例

1. 在对应纸面 `.md` 的既有段落里按原格式加一行 prompt；
2. 在 `cases.jsonl` 加一行同文本的 manifest 记录（id 续号、scenario/domain/trigger/may_load 按实填写）；
3. 跑 `npm run eval`——parity 双向校验会抓住任何一侧漏改或文本不一致。

## 已知边界

- Tier 1 只能证明「期望与仓库静态事实一致」，不能证明运行时真的如此路由——那一步由 Tier 2（机械判定）与 Tier 3（语义判读）补齐；
- parity 提取器只认三种段首（Test Cases / Should … / Edge case）和两种行式（编号项、引号起头的列表项）；新文件若用别的排版，需同步扩展 `run_eval.mjs` 的提取规则。
