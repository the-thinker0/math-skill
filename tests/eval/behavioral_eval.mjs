#!/usr/bin/env node
// Tier 2 requires a trusted runtime adapter that observes file/tool events.
// Final-answer path mentions and model self-reports are NOT read traces.
import { runCaptured } from './process-lib.mjs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { ROOT, validateSuite, resolveArtifact, isolationProblem } from './eval-lib.mjs';

export function parseArgs(args) {
  const options = { only: '', limit: Infinity, timeout: 180000, requireRuntime: false };
  const seen = new Set();
  for (let i = 0; i < args.length; i++) {
    const flag = args[i];
    if (seen.has(flag)) throw new Error(`duplicate option: ${flag}`);
    seen.add(flag);
    if (flag === '--require-runtime') { options.requireRuntime = true; continue; }
    if (!['--only', '--limit', '--timeout-ms'].includes(flag)) throw new Error(`unknown option: ${flag}`);
    const value = args[++i];
    if (value === undefined || value.startsWith('--') || !value.trim()) throw new Error(`missing value for ${flag}`);
    if (flag === '--only') options.only = value;
    else {
      if (!/^[1-9]\d*$/.test(value) || !Number.isSafeInteger(Number(value)) || Number(value) > 2147483647) {
        throw new Error(`${flag} requires a positive integer <= 2147483647`);
      }
      options[flag === '--limit' ? 'limit' : 'timeout'] = Number(value);
    }
  }
  return options;
}

// This is argv tokenization, never shell execution. Prefer the JSON argv env
// variable for Windows paths and complex arguments. Placeholders retain suffixes.
export function parseTemplate(template) {
  const tokens = [];
  let current = '', quote = null, started = false;
  for (let i = 0; i < template.length; i++) {
    const ch = template[i];
    if (quote) {
      if (ch === quote) quote = null;
      else if (quote === '"' && ch === '\\' && ['"', '\\'].includes(template[i + 1])) current += template[++i];
      else current += ch;
    } else if (/\s/.test(ch)) {
      if (started) tokens.push(current);
      current = ''; started = false;
    } else if (ch === '"' || ch === "'") { quote = ch; started = true; }
    else if (ch === '\\') {
      if (i + 1 === template.length) throw new Error('trailing escape in command template');
      current += template[++i]; started = true;
    } else { current += ch; started = true; }
  }
  if (quote) throw new Error('unbalanced quote in command template');
  if (started) tokens.push(current);
  return tokens;
}

export function configuredArgv(env) {
  const json = env.MATH_SKILL_EVAL_ARGV;
  const template = env.MATH_SKILL_EVAL_CMD;
  if (json !== undefined && template !== undefined) throw new Error('set only MATH_SKILL_EVAL_ARGV or MATH_SKILL_EVAL_CMD');
  if (json === undefined && template === undefined) return null;
  const tokens = json !== undefined ? JSON.parse(json) : parseTemplate(template);
  if (!Array.isArray(tokens) || tokens.length < 2 || tokens.some((t) => typeof t !== 'string') || !tokens[0].trim()) {
    throw new Error('runtime command must be an argv array with an executable and arguments');
  }
  if (tokens[0].includes('{prompt}') || !tokens.slice(1).some((t) => t.includes('{prompt}'))) {
    throw new Error('runtime arguments must contain {prompt}; executable must not');
  }
  return tokens;
}

export const buildArgv = (tokens, prompt) => tokens.map((token) => token.split('{prompt}').join(prompt));

export function judge(c, result, root = ROOT) {
  if (!result || typeof result !== 'object' || Array.isArray(result)) return 'adapter output must be a JSON object';
  if (result.case_id !== c.id) return `adapter case_id must equal ${c.id}`;
  if (typeof result.answer !== 'string' || result.answer.trim().length < 30) return 'missing or too-short answer';
  const trace = result.trace;
  if (!trace || trace.complete !== true || !['tool-events', 'file-access'].includes(trace.source) || !Array.isArray(trace.loaded_files)) {
    return 'complete file-access/tool-events trace required; answer text or self-report is not loading evidence';
  }
  const loaded = [];
  for (const file of trace.loaded_files) {
    try {
      const artifact = resolveArtifact(root, file, { fileOnly: true });
      const problem = isolationProblem(c.domain, artifact.rel);
      if (problem) return problem;
      loaded.push(artifact.rel);
    } catch (err) { return `invalid trace path: ${err.message}`; }
  }
  // A positive trigger needs observed skill content, even if the response hides
  // internal paths as instructed. may_load lists examples, not a required route.
  if (c.trigger && !loaded.some((p) => /^(?:lenses|knowledge-base|design-patterns|references|agents)\//.test(p) || /^SKILL(?:\.en)?\.md$/.test(p))) {
    return 'trigger expected but no skill content was observed';
  }
  if (loaded.includes('SKILL.md') && loaded.includes('SKILL.en.md')) return 'both language entries were loaded';
  return null;
}

// Language is a review signal, not a reliable language classifier or pass gate.
export function languageWarning(c, answer) {
  const prose = answer.replace(/```[\s\S]*?```/g, '').replace(/\$\$[\s\S]*?\$\$/g, '');
  const han = (prose.match(/\p{Script=Han}/gu) || []).length;
  const latin = (prose.match(/[A-Za-z]/g) || []).length;
  if (c.lang === 'zh' && han === 0) return 'expected Chinese prose; manual language review needed';
  if (c.lang === 'en' && han > latin) return 'expected English prose; manual language review needed';
  return null;
}

export function runCase(c, tokens, timeout, root = ROOT) {
  const res = runCaptured(tokens[0], buildArgv(tokens.slice(1), c.prompt), {
    cwd: root, encoding: 'utf8', timeout, maxBuffer: 16 * 1024 * 1024,
    env: { ...process.env, MATH_SKILL_EVAL_CASE_ID: c.id, MATH_SKILL_EVAL_ROOT: root, MATH_SKILL_EVAL_TIMEOUT_MS: String(timeout) },
    shell: false, killSignal: 'SIGKILL',
  });
  if (res.error) return { problem: `runtime error: ${res.error.message}` };
  if (res.signal || res.status !== 0) return { problem: `runtime exited with ${res.signal ? `signal ${res.signal}` : `status ${res.status}`}` };
  let result;
  try { result = JSON.parse(res.stdout); } catch { return { problem: 'stdout must be one adapter JSON object (stderr is diagnostics only)' }; }
  return { problem: judge(c, result, root), warning: typeof result?.answer === 'string' ? languageWarning(c, result.answer) : null };
}

export function main(args = process.argv.slice(2), env = process.env) {
  try {
    const options = parseArgs(args);
    const { cases: allCases, errors } = validateSuite();
    if (errors.length) throw new Error(`manifest validation failed: ${errors.join('; ')}`);
    const cases = allCases.filter((c) => c.source.includes(options.only)).slice(0, options.limit);
    if (!cases.length) throw new Error('no cases selected; check --only');
    const tokens = configuredArgv(env);
    if (!tokens) {
      console.log('SKIP: no runtime adapter configured. No behavioral checks were performed.');
      console.log('Set MATH_SKILL_EVAL_ARGV or MATH_SKILL_EVAL_CMD; see tests/eval/README.md for the observed-trace contract.');
      return options.requireRuntime ? 1 : 0;
    }
    let failed = 0;
    for (const c of cases) {
      const { problem, warning } = runCase(c, tokens, options.timeout);
      if (problem) failed++;
      console.log(`[${c.id}] ${problem ? `FAIL (${problem})` : 'PASS (observed isolation/activation only)'}`);
      if (warning) console.log(`[${c.id}] REVIEW: ${warning}`);
    }
    console.log(`behavioral eval: ${cases.length - failed} passed, ${failed} failed, ${cases.length} total; semantic quality requires human review`);
    return failed ? 1 : 0;
  } catch (err) {
    console.error(`behavioral eval: ${err.message}`);
    return 1;
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) process.exitCode = main();
