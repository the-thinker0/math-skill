#!/usr/bin/env node
// math-skill behavioral eval harness (v3.3.7)
//
// Tier-2 eval: runs manifest cases through a REAL agent and applies
// deterministic judges that need no second LLM:
//   - every case: answer must be non-trivial;
//   - scenario E (should-not-trigger): output must NOT cite skill material
//     (lenses/, knowledge-base/, design-patterns/, math-critic);
//   - domain=ai: output must not cite cryptography anchors or crypto books;
//   - domain=crypto: output must not cite design-patterns/;
//   - lang=zh: CJK ratio of the output must exceed ZH_CJK_RATIO.
// Conclusion-quality judgments stay in the Tier-3 paper files (human review).
//
// Usage:
//   MATH_SKILL_EVAL_CMD='claude -p "{prompt}"' node tests/eval/behavioral_eval.mjs
//   MATH_SKILL_EVAL_CMD='codex exec "{prompt}"' node tests/eval/behavioral_eval.mjs --only should-not-trigger
//
// Without MATH_SKILL_EVAL_CMD this prints SKIP and exits 0, so it is safe to
// wire into CI before an agent runtime is attached. The {prompt} placeholder
// is spliced at the argv level (no shell), so $, backticks and quotes inside
// prompts cannot break out of the command template.

import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const TEMPLATE = process.env.MATH_SKILL_EVAL_CMD;

// Args: --only <source-substring>  --limit <n>  --timeout-ms <n>
const args = process.argv.slice(2);
function argValue(name) {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : undefined;
}
const ONLY = argValue('--only') || '';
const LIMIT = Number(argValue('--limit') || Infinity);
const TIMEOUT_MS = Number(argValue('--timeout-ms') || 180000);

const MIN_ANSWER_CHARS = 30;
const ZH_CJK_RATIO = 0.05;
const FORBIDDEN_IF_NOT_TRIGGERED = ['lenses/', 'knowledge-base/', 'design-patterns/', 'math-critic'];
const FORBIDDEN_FOR_AI = [
  'knowledge-base/cryptography',
  'cryptography/applied-cryptography',
  'applied-cryptography.md',
  'foundations-of-cryptography',
  'introduction-to-modern-cryptography',
];
const FORBIDDEN_FOR_CRYPTO = ['design-patterns/'];

function parseTemplate(tpl) {
  const tokens = [];
  let cur = '';
  let hasToken = false;
  let isPromptSlot = false;
  const flush = () => {
    if (hasToken) tokens.push(isPromptSlot ? { promptSlot: true, prefix: cur } : cur);
    cur = '';
    hasToken = false;
    isPromptSlot = false;
  };
  for (let i = 0; i < tpl.length; i++) {
    const ch = tpl[i];
    if (ch === ' ') { flush(); continue; }
    hasToken = true;
    if (ch === '\'') {
      const j = tpl.indexOf('\'', i + 1);
      if (j < 0) throw new Error('unbalanced single quote in MATH_SKILL_EVAL_CMD');
      let k = i + 1;
      while (k < j) {
        if (tpl.startsWith('{prompt}', k)) { isPromptSlot = true; k += 8; } else { cur += tpl[k]; k += 1; }
      }
      i = j;
      continue;
    }
    if (ch === '"') {
      let j = i + 1;
      while (j < tpl.length && tpl[j] !== '"') {
        if (tpl.startsWith('{prompt}', j)) { isPromptSlot = true; j += 8; continue; }
        if (tpl[j] === '\\') { cur += tpl[j + 1]; j += 2; } else { cur += tpl[j]; j += 1; }
      }
      i = j;
      continue;
    }
    if (ch === '\\') { cur += tpl[i + 1]; i += 1; continue; }
    if (tpl.startsWith('{prompt}', i)) { isPromptSlot = true; i += 7; continue; }
    cur += ch;
  }
  flush();
  return tokens;
}

function buildArgv(tokens, prompt) {
  return tokens.map((t) => (t && t.promptSlot ? t.prefix + prompt : t));
}

const cjkCount = (s) => (s.match(/\p{Script=Han}/gu) || []).length;

function judge(c, output) {
  const trimmed = output.trim();
  if (trimmed.length < MIN_ANSWER_CHARS) return `answer too short (${trimmed.length} chars)`;
  if (!c.trigger) {
    for (const bad of FORBIDDEN_IF_NOT_TRIGGERED) {
      if (trimmed.includes(bad)) return `scenario E cited skill material: "${bad}"`;
    }
  }
  if (c.domain === 'ai') {
    for (const bad of FORBIDDEN_FOR_AI) {
      if (trimmed.includes(bad)) return `pure-AI case cited crypto material: "${bad}"`;
    }
  }
  if (c.domain === 'crypto') {
    for (const bad of FORBIDDEN_FOR_CRYPTO) {
      if (trimmed.includes(bad)) return `pure-crypto case cited AI design patterns: "${bad}"`;
    }
  }
  if (c.lang === 'zh') {
    const ratio = cjkCount(trimmed) / Math.max(trimmed.length, 1);
    if (ratio < ZH_CJK_RATIO) return `lang=zh but CJK ratio ${(ratio * 100).toFixed(1)}% < ${ZH_CJK_RATIO * 100}%`;
  }
  return null;
}

function main() {
  if (!TEMPLATE || !TEMPLATE.includes('{prompt}')) {
    console.log('SKIP: set MATH_SKILL_EVAL_CMD (template containing {prompt}) to run behavioral eval.');
    console.log('Example: MATH_SKILL_EVAL_CMD=\'claude -p "{prompt}"\' node tests/eval/behavioral_eval.mjs');
    process.exit(0);
  }
  const tokens = parseTemplate(TEMPLATE);
  const lines = readFileSync(path.join(ROOT, 'tests', 'eval', 'cases.jsonl'), 'utf8')
    .split(/\r?\n/).filter((l) => l.trim() && !l.trim().startsWith('//'));
  const cases = lines.map((l) => JSON.parse(l)).filter((c) => c.source.includes(ONLY)).slice(0, LIMIT);

  let pass = 0;
  let fail = 0;
  for (const c of cases) {
    process.stdout.write(`[${c.id}] ${c.source} ... `);
    const res = spawnSync(tokens[0], buildArgv(tokens.slice(1), c.prompt), {
      cwd: ROOT,
      encoding: 'utf8',
      timeout: TIMEOUT_MS,
      maxBuffer: 16 * 1024 * 1024,
    });
    if (res.error) {
      fail += 1;
      console.log(`FAIL (${res.error.message})`);
      continue;
    }
    const problem = judge(c, `${res.stdout || ''}\n${res.stderr || ''}`);
    if (problem) {
      fail += 1;
      console.log(`FAIL (${problem})`);
    } else {
      pass += 1;
      console.log('PASS');
    }
  }
  console.log(`behavioral eval: ${pass} passed, ${fail} failed, ${cases.length} total`);
  process.exit(fail > 0 ? 1 : 0);
}

main();
