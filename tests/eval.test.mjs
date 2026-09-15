import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, rmSync, symlinkSync } from 'node:fs';
import path from 'node:path';
import { ROOT, loadManifest, resolveArtifact, validateSuite, multisetDiff, extractPrompts, isolationProblem } from './eval/eval-lib.mjs';
import { parseArgs, parseTemplate, configuredArgv, buildArgv, judge, runCase, languageWarning } from './eval/behavioral_eval.mjs';

const valid = { id: 'T1', source: 'should-trigger-analysis.md', prompt: '检查这个谱分解的数学条件', lang: 'zh', scenario: 'A', domain: 'ai', trigger: true, may_load: ['lenses/spectral.md'] };
const output = (files = ['lenses/spectral.md']) => ({
  case_id: valid.id, answer: '这里先检查矩阵是否对称，再分别讨论特征值与奇异值，给出适用条件及可能失效的边界。',
  trace: { complete: true, source: 'tool-events', loaded_files: files },
});

function fixture(t) {
  const dir = mkdtempSync(path.join(ROOT, '.eval-test-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}

test('the complete manifest and paper prompts agree', () => {
  const result = validateSuite();
  assert.deepEqual(result.errors, []);
  assert.ok(result.cases.length >= 70);
});

test('manifest schema rejects malformed values instead of repairing or crashing', () => {
  for (const value of [null, [], 42, 'case']) assert.ok(loadManifest(JSON.stringify(value)).errors.length);
  for (const mutate of [
    (c) => delete c.may_load, (c) => { c.may_load = 'lenses/spectral.md'; },
    (c) => { c.may_load = [null]; }, (c) => { c.lang = 'fr'; },
    (c) => { c.domain = 'none'; }, (c) => { c.scenario = 'E'; },
    (c) => { c.trigger = false; }, (c) => { c.prompt = ' '; },
    (c) => { c.may_load.push(c.may_load[0]); },
  ]) {
    const c = structuredClone(valid); mutate(c);
    assert.ok(loadManifest(JSON.stringify(c)).errors.length, JSON.stringify(c));
  }
  assert.match(loadManifest('\n// comment\nnull\n{broken').errors.join('\n'), /line 3/);
  assert.match(loadManifest('\n// comment\nnull\n{broken').errors.join('\n'), /line 4/);
  assert.ok(loadManifest([valid, valid].map(JSON.stringify).join('\n')).errors.some((e) => e.includes('duplicate id')));
});

test('non-trigger consistency holds in all directions', () => {
  const negative = { ...valid, scenario: 'E', domain: 'none', trigger: false, may_load: [] };
  assert.deepEqual(loadManifest(JSON.stringify(negative)).errors, []);
  for (const patch of [{ scenario: 'D' }, { domain: 'ai' }, { trigger: true }, { may_load: ['lenses/spectral.md'] }]) {
    assert.ok(loadManifest(JSON.stringify({ ...negative, ...patch })).errors.length);
  }
});

test('absolute, dot-segment, Windows and directory aliases cannot bypass policy', () => {
  for (const rel of ['/etc/passwd', '../SKILL.md', './SKILL.md', 'C:\\secret.md', 'lenses\\spectral.md',
    'lenses//spectral.md', 'lenses/../knowledge-base/cryptography/prf-prg-owf.md']) {
    assert.throws(() => resolveArtifact(ROOT, rel));
  }
  for (const [domain, may_load] of [['ai', ['knowledge-base/']], ['ai', ['references/books/']],
    ['crypto', ['design-patterns/']], ['crypto', ['references/gpu-friendly-math.en.md']]]) {
    assert.ok(loadManifest(JSON.stringify({ ...valid, domain, may_load })).errors.length);
  }
});

test('realpath checks catch aliases into forbidden content and outside the skill', (t) => {
  const dir = fixture(t);
  mkdirSync(path.join(dir, 'knowledge-base/cryptography'), { recursive: true });
  writeFileSync(path.join(dir, 'knowledge-base/cryptography/anchor.md'), 'crypto');
  try {
    symlinkSync(path.join(dir, 'knowledge-base/cryptography/anchor.md'), path.join(dir, 'alias.md'));
    // ROOT is inside this repository but outside the isolated fixture skill.
    symlinkSync(path.join(ROOT, 'SKILL.md'), path.join(dir, 'escape.md'));
  } catch (err) {
    if (err.code === 'EPERM') { t.skip('symlink creation is unavailable on this Windows installation'); return; }
    throw err;
  }
  assert.match(loadManifest(JSON.stringify({ ...valid, may_load: ['alias.md'] }), { root: dir }).errors.join(), /crypto material/);
  assert.throws(() => resolveArtifact(dir, 'escape.md'), /escapes skill root/);
});

test('paper parity is a multiset and arrows within quoted prompts are preserved', () => {
  assert.deepEqual(multisetDiff(['x', 'x'], ['x']), [['x', 1]]);
  assert.deepEqual(extractPrompts('## Test Cases\n1. "Does A → B hold?" → expected\n## Notes\n1. not a prompt'), ['Does A → B hold?']);
  assert.throws(() => extractPrompts('## Test Cases\n1. "unclosed'), /unclosed/);
});

test('command templates preserve prompt position, quotes, whitespace and literal shell syntax', () => {
  const prompt = '" $(touch SHOULD_NOT_EXIST) `echo no` $HOME';
  const tokens = parseTemplate('node\tadapter.mjs "prefix:{prompt}:suffix" \'{prompt}\' ""');
  assert.deepEqual(buildArgv(tokens.slice(1), prompt), ['adapter.mjs', `prefix:${prompt}:suffix`, prompt, '']);
  for (const template of ['node "open', "node 'open", 'node dangling\\']) assert.throws(() => parseTemplate(template));
  assert.throws(() => configuredArgv({ MATH_SKILL_EVAL_CMD: 'node adapter.mjs' }), /prompt/);
  assert.throws(() => configuredArgv({ MATH_SKILL_EVAL_CMD: '', MATH_SKILL_EVAL_ARGV: '[]' }));
  assert.deepEqual(configuredArgv({ MATH_SKILL_EVAL_ARGV: '["C:\\\\Program Files\\\\node.exe","adapter.mjs","{prompt}"]' }), ['C:\\Program Files\\node.exe', 'adapter.mjs', '{prompt}']);
});

test('CLI options reject empty, duplicate, negative, fractional and unknown values', () => {
  for (const args of [['--limit'], ['--limit', '0'], ['--limit', '-1'], ['--limit', 'NaN'],
    ['--limit', '1.5'], ['--timeout-ms', 'Infinity'], ['--only', '--limit'], ['--oops'],
    ['--only', 'x', '--only', 'y']]) assert.throws(() => parseArgs(args), args.join(' '));
  assert.deepEqual(parseArgs(['--limit', '2', '--only', 'isolation', '--require-runtime']), { limit: 2, only: 'isolation', timeout: 180000, requireRuntime: true });
});

test('trace judges observed loading even when final text contains no paths', () => {
  assert.equal(judge(valid, output()), null);
  assert.match(judge(valid, { ...output(), trace: undefined }), /trace required/);
  assert.match(judge(valid, { ...output(), trace: { ...output().trace, complete: false } }), /trace required/);
  assert.match(judge(valid, output([])), /no skill content/);
  assert.match(judge(valid, { ...output(), case_id: 'another-case' }), /case_id/);
  assert.match(judge(valid, output(['knowledge-base/cryptography/prf-prg-owf.md'])), /crypto material/);
  assert.match(judge({ ...valid, domain: 'crypto' }, output(['references/gpu-friendly-math.md'])), /GPU gate/);
  assert.match(judge({ ...valid, trigger: false, domain: 'none', scenario: 'E' }, output()), /scenario E/);
  assert.equal(judge({ ...valid, trigger: false, domain: 'none', scenario: 'E' }, output([])), null);
  assert.match(judge(valid, output(['lenses/'])), /not a file/);
  assert.match(judge(valid, output(['SKILL.md', 'SKILL.en.md'])), /both language/);
  assert.ok(isolationProblem('ai', 'references/worked-examples/security-reduction.en.md'));
  assert.ok(isolationProblem('crypto', 'references/worked-examples/query-aware-compression.md'));
  assert.ok(isolationProblem('crypto', 'references/construction-moves.en.md'));
  assert.equal(isolationProblem('ai', 'references/construction-moves.md'), null);
  assert.match(judge({ ...valid, domain: 'crypto' }, output(['references/construction-moves.md'])), /AI construction/);
  assert.equal(judge(valid, output(['references/design-workbench.md'])), null);
  assert.ok(isolationProblem('none', 'SKILL.md'));
  assert.ok(languageWarning(valid, 'This answer is written entirely in English.'));
});

test('runtime errors and stderr cannot masquerade as a valid answer', () => {
  const payload = JSON.stringify(output());
  const run = (script, timeout = 1000) => runCase(valid, [process.execPath, '-e', script, '{prompt}'], timeout);
  assert.match(run(`process.stdout.write(${JSON.stringify(payload)});process.exit(7)`).problem, /status 7/);
  assert.match(run(`process.stderr.write(${JSON.stringify(payload)})`).problem, /stdout/);
  assert.match(run('process.stdout.write("ordinary unstructured answer with no observed trace")').problem, /stdout/);
  assert.match(run('process.on(\"SIGTERM\",()=>{});setTimeout(()=>{}, 10000)', 30).problem, /runtime error/);
  assert.match(runCase(valid, [path.join(ROOT, 'nonexistent-eval-runtime'), '{prompt}'], 100).problem, /runtime error/);
  const successful = run(`process.stdout.write(${JSON.stringify(payload)})`);
  assert.equal(successful.problem, null);
});
