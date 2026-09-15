# Eval Suite — 三层评测体系

三层共用 70 个 prompt。静态检查能验证期望与资源一致；真实加载需要运行时事件；数学结论仍需要人工审查。`may_load` 是可能有用的材料示例，并非必读清单，也不应作为模型必须照抄的路由答案。

| 层 | 入口 | 能验证什么 |
|---|---|---|
| Tier 1 静态 | `npm run eval`；`npm run validate` 也调用 | manifest schema、纸面与 manifest 双向多重集一致、路径存在与仓库包含关系、域隔离、场景/语言覆盖 |
| Tier 2 运行时 | `npm run eval:behavioral`，需可信适配器 | 观察到的读取路径是否满足隔离和触发要求；子进程是否成功；是否重复加载双语入口 |
| Tier 3 人工 | 下表中的纸面断言 | 数学条件、推导、反例、跨域保证与临时知识卡来源是否成立 |

## 纸面文件索引

| 文件 | 范围 |
|---|---|
| [should-trigger-design.md](should-trigger-design.md) | B：透镜、锚点、设计原型与实现边界 |
| [should-trigger-knowledge.md](should-trigger-knowledge.md) | C：定义、公式、条件及适用边界 |
| [should-trigger-analysis.md](should-trigger-analysis.md) | A：假设、逻辑与边界；不默认加载完整 critic |
| [should-trigger-verification.md](should-trigger-verification.md) | D：反模式、保证范围及反例 |
| [should-not-trigger.md](should-not-trigger.md) | E：纯工程工作不加载数学内容 |
| [cross-domain-routing.md](cross-domain-routing.md) | AI×密码：四元组、迁移方向和假设 |
| [domain-router-isolation.md](domain-router-isolation.md) | 分域隔离；hashing 与鲁棒性证书不靠关键词误判 |
| [knowledge-gap-protocol.md](knowledge-gap-protocol.md) | 缺口类型、来源、置信度与未核验结论 |
| [mixed-language-routing.md](mixed-language-routing.md) | 句框与显式语言指令 |

## Tier 1：可重复的静态检查

`cases.jsonl` 每行一个对象：

```json
{"id":"A1","source":"should-trigger-analysis.md","prompt":"…","lang":"zh","scenario":"A","domain":"ai","trigger":true,"may_load":["lenses/perturbation.md"],"notes":"…"}
```

- `id/source/prompt/lang/scenario/domain` 必须是非空字符串；`lang` 只允许 `zh/en`，`trigger` 必须是布尔值，`may_load` 必须是字符串数组。无效输入报错，不静默修复。
- `trigger=false`、`scenario=E` 与 `domain=none` 必须同时成立；E 不声明可加载材料。`lang=zh` 的 prompt 必含汉字。
- 从 9 份纸面文件的 Test Cases / Should … / Edge case 段提取编号项或引号列表项，进行双向多重集比较。重复项数量也必须一致；保留至少 70 例并覆盖所有场景、域和两种语言。
- 路径采用相对 skill 根目录的规范 POSIX 写法；拒绝绝对路径、反斜杠、`.`/`..`、空路径分段和越界符号链接。检查真实路径，并对声明的目录递归检查隔离，防止用父目录或别名绕过限制。
- 纯 AI 排除密码锚点、三本密码书稿及密码归约案例；纯密码排除 AI 设计模式、AI 专属案例及 GPU 检查文档。

`npm run validate` 还检查双向双语配对、知识卡章节、资源计数、具体相对路径和 Markdown 链接，以及 `npm pack --dry-run --json` 的准确文件清单。代码围栏、安装目录示例、通配符和 README 历史记录中的代码路径不是当前资源链接；真正的 Markdown 链接仍检查。远程 URL 和页内锚点不在离线检查范围内。

`npm test` 包含损坏输入、路径越界、别名隔离、命令参数、退出码和 trace 的工具回归。这些测试不证明数学文本正确。

## Tier 2：可信适配器契约

普通 CLI 的最终文本不能证明它读取了哪些文件。必须配置一个**由维护者控制、观察运行时工具或文件访问事件**的适配器。不要让模型生成或自报 trace，也不要从回答中的路径引用倒推读取记录。

每个用例启动一个独立适配器进程。prompt 在 argv 层替换，不经过 shell；`MATH_SKILL_EVAL_CASE_ID` 给出当前用例 ID，`MATH_SKILL_EVAL_ROOT` 给出仓库根目录。适配器必须向 stdout 只输出一个 JSON 对象，诊断输出到 stderr：

```json
{
  "case_id": "A1",
  "answer": "实际 agent 的最终回答……",
  "trace": {
    "source": "tool-events",
    "complete": true,
    "loaded_files": ["SKILL.md", "lenses/perturbation.md"]
  }
}
```

- `source` 为 `tool-events` 或 `file-access`。这只是来源声明，可信性来自适配器实现与事件采集配置；harness 不能鉴别伪造的 JSON。
- `loaded_files` 包含本次运行全部实际加载的 skill 文件内容，包括启动时预加载、工具读取及 shell 读取；只读取 frontmatter 元数据以判断触发不算加载正文。不能观察某种读取渠道时必须将 `complete` 设为 `false`，不能隐去该渠道。
- 路径映射到 skill 根下的规范 POSIX 相对路径，只接受真实文件。若在另一个安装位置运行，适配器负责核对与当前仓库内容一致后映射，不能仅按文件名猜测。
- 每个用例使用独立上下文，避免复用上个用例的缓存内容。适配器负责监督它启动的 agent 及子进程，利用 `MATH_SKILL_EVAL_TIMEOUT_MS` 在 harness 截止前自行超时并清理进程树；harness 到期使用 SIGKILL 直接终止适配器进程，不保证清理其后代。
- 非零退出、启动错误、超时、错误/缺失 JSON、未完成 trace、空选择、缺失激活证据或域污染均失败。stderr 不能充当答案。输出超过 16 MiB 在进程结束后拒收；适配器应自行限制日志量。
- 正向用例至少观察到一个 skill 内容文件。它不强制 `may_load` 路由，也不能仅凭一次读取证明回答使用了材料。
- 语言启发式只打印 REVIEW 提示，不把汉字占比当成可靠的中英文分类器。结论质量和主语言仍由人工检查。

下面的 `runtime-adapter` 是需要自行接入的适配器命令，并非本包提供的程序：

```bash
MATH_SKILL_EVAL_ARGV='["runtime-adapter","{prompt}"]' \
  node tests/eval/behavioral_eval.mjs --require-runtime

# 简单命令模板也可用；Windows 路径和复杂引号优先使用 JSON argv。
MATH_SKILL_EVAL_CMD='runtime-adapter "{prompt}"' \
  node tests/eval/behavioral_eval.mjs --only domain-router-isolation --limit 3 --timeout-ms 120000
```

两种环境变量只能配置其一。未配置时明确打印 SKIP，表示未运行任何行为检查；CI 要求真实评测时加 `--require-runtime`，缺配置即非零退出。配置错误不会作为 SKIP 处理。

## 新增用例

1. 在对应纸面文件的既有测试段中加入 prompt 和需要人工判断的断言。
2. 在 `cases.jsonl` 中加入同文本记录，使用唯一 ID 并填写场景、域与可能相关材料。
3. 运行 `npm run eval` 和 `npm test`；新增纸面文件时还需更新 `eval-lib.mjs` 的来源清单。

任何 PASS 都只对应本层覆盖的检查。没有可信运行时适配器时，应报告“静态检查通过，行为评测未运行”；不能把 SKIP 写成真实 agent 验证通过。
