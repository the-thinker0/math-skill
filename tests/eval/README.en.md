# Eval Suite — three levels of evidence

All three tiers share 70 prompts. Static checks establish consistency between expectations and resources; runtime events establish observed loading; mathematical conclusions still require human review. `may_load` lists potentially relevant resources, not a mandatory route or an answer the model must reproduce.

| Tier | Entry | What it can establish |
|---|---|---|
| 1: static | `npm run eval`; also invoked by `npm run validate` | Manifest schema, bidirectional paper/manifest multiset parity, path existence and containment, isolation rules, scenario/domain/language coverage |
| 2: runtime | `npm run eval:behavioral`, with a trusted adapter | Observed isolation and activation, successful process execution, absence of duplicate bilingual entry loading |
| 3: human | Assertions in the paper files below | Mathematical assumptions, derivations, counterexamples, transferred guarantees, and temporary-card evidence |

## Paper files

| File | Scope |
|---|---|
| [should-trigger-design.md](should-trigger-design.md) | B: lenses, anchors, design patterns and implementation boundaries |
| [should-trigger-knowledge.md](should-trigger-knowledge.md) | C: definitions, formulas, assumptions and applicability |
| [should-trigger-analysis.md](should-trigger-analysis.md) | A: assumptions, logic and boundaries; no default full critic |
| [should-trigger-verification.md](should-trigger-verification.md) | D: anti-patterns, guarantee scope and counterexamples |
| [should-not-trigger.md](should-not-trigger.md) | E: engineering-only work does not load mathematical content |
| [cross-domain-routing.md](cross-domain-routing.md) | AI × crypto: the four-tuple, transfer direction and assumptions |
| [domain-router-isolation.md](domain-router-isolation.md) | Domain isolation; hashing and robustness certificates are not classified by keywords alone |
| [knowledge-gap-protocol.md](knowledge-gap-protocol.md) | Gap types, sources, confidence and unverified claims |
| [mixed-language-routing.md](mixed-language-routing.md) | Sentence frame and explicit language instructions |

## Tier 1: reproducible static checks

Each line of `cases.jsonl` is an object:

```json
{"id":"A1","source":"should-trigger-analysis.md","prompt":"…","lang":"zh","scenario":"A","domain":"ai","trigger":true,"may_load":["lenses/perturbation.md"],"notes":"…"}
```

- `id/source/prompt/lang/scenario/domain` must be nonempty strings; `lang` is `zh/en`, `trigger` is boolean, and `may_load` is a string array. Invalid input fails instead of being silently repaired.
- `trigger=false`, `scenario=E`, and `domain=none` must hold together; E declares no loadable artifacts. A `lang=zh` prompt must contain Han characters.
- The runner extracts numbered or quoted list prompts under Test Cases / Should … / Edge case headings in nine paper files. Bidirectional multiset comparison checks duplicate counts as well as text. At least 70 cases, all scenarios/domains, and both languages are required.
- Paths use canonical POSIX syntax relative to the skill root. Absolute paths, backslashes, dot segments, empty segments and escaping symlinks fail. Isolation checks resolve real paths and recursively inspect declared directories so that parent directories or aliases cannot bypass policy.
- Pure AI excludes crypto anchors, the three crypto books, and the security-reduction example. Pure crypto excludes AI design patterns, AI-specific worked examples, and the GPU checklist.

`npm run validate` also checks bilingual counterparts in both directions, card sections, inventory counts, concrete relative paths and Markdown links, plus exact paths from `npm pack --dry-run --json`. Fenced examples, installation directories, wildcard examples and code paths in README history are not current resource links; actual Markdown links remain checked. Remote URLs and heading anchors are outside the offline check.

`npm test` exercises malformed input, path containment, alias isolation, command options, process status and traces. These tool regressions do not establish mathematical correctness.

## Tier 2: trusted adapter contract

Final CLI text cannot establish which files an agent read. Configure a **maintainer-controlled adapter observing runtime tool or file-access events**. Do not ask the model to generate/self-report a trace, and do not infer reads from path mentions in its answer.

Each case starts a separate adapter process. The prompt is substituted in argv without a shell. `MATH_SKILL_EVAL_CASE_ID` identifies the case and `MATH_SKILL_EVAL_ROOT` identifies the repository. The adapter writes exactly one JSON object to stdout and diagnostics to stderr:

```json
{
  "case_id": "A1",
  "answer": "The actual agent's final answer…",
  "trace": {
    "source": "tool-events",
    "complete": true,
    "loaded_files": ["SKILL.md", "lenses/perturbation.md"]
  }
}
```

- `source` is `tool-events` or `file-access`. This label is a declaration; trust comes from the adapter implementation and event collection. The harness cannot authenticate fabricated JSON.
- `loaded_files` includes every skill file whose content entered the run, including startup preloads, tool reads and shell reads. Reading only frontmatter metadata to decide activation does not count as loading the body. If any reading channel cannot be observed, set `complete` to `false`; do not omit that channel.
- Map paths to canonical POSIX paths under the skill root; only real files are accepted. When evaluating another installation, verify that it matches the current repository before mapping paths. Do not guess by basename.
- Use an independent context for each case, without content cached from earlier cases. The adapter must supervise its agent and descendants, using `MATH_SKILL_EVAL_TIMEOUT_MS` to time out and clean up its process tree before the harness deadline. At the deadline, the harness uses SIGKILL to terminate the adapter directly; descendant cleanup is not guaranteed.
- Startup errors, nonzero exit status, timeout, invalid/missing JSON, incomplete traces, empty selection, missing activation evidence and isolation violations fail. stderr cannot count as an answer. Output above 16 MiB is rejected after process completion; adapters should cap their own logs.
- Positive cases require at least one observed skill content file. This does not mandate the `may_load` examples or prove that the answer used the resource.
- Language heuristics print REVIEW signals only. Han-character ratios are not reliable language classification; review the primary language and conclusion quality manually.

In these examples, `runtime-adapter` is an integration you must provide, not an executable supplied by this package:

```bash
MATH_SKILL_EVAL_ARGV='["runtime-adapter","{prompt}"]' \
  node tests/eval/behavioral_eval.mjs --require-runtime

# A simple template is also supported. Prefer JSON argv for Windows paths or complex quoting.
MATH_SKILL_EVAL_CMD='runtime-adapter "{prompt}"' \
  node tests/eval/behavioral_eval.mjs --only domain-router-isolation --limit 3 --timeout-ms 120000
```

Set only one command variable. With neither configured, the runner prints SKIP: no behavioral checks ran. Use `--require-runtime` when CI requires a real evaluation; missing configuration then fails. Invalid configuration is never treated as a skip.

## Adding cases

1. Add the prompt and human-review assertions to an existing test section in the relevant paper file.
2. Add matching text to `cases.jsonl`, with a unique ID, scenario, domain and potentially relevant resources.
3. Run `npm run eval` and `npm test`. A new paper file also requires updating the source list in `eval-lib.mjs`.

A PASS covers only its own tier. Without a trusted runtime adapter, report “static checks passed; behavioral evaluation not run.” A SKIP is not evidence of successful real-agent behavior.
