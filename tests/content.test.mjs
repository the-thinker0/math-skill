import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, rmSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { ROOT } from './eval/eval-lib.mjs';
import { checkPairs, checkReferences, extractLocalReferences, checkFrontmatter, checkPack, checkAnchorIndex } from './content-lib.mjs';

function fixture(t) {
  const dir = mkdtempSync(path.join(ROOT, '.content-test-'));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  return dir;
}

test('pairing checks identities in both directions, not just equal totals', () => {
  assert.deepEqual(checkPairs(['a.md', 'a.en.md']), []);
  assert.equal(checkPairs(['a.md', 'b.en.md']).length, 2);
  assert.equal(checkPairs(['orphan.en.md']).length, 1);
});

test('local Markdown, reference-style and code paths are checked relative to each document', (t) => {
  const root = fixture(t);
  mkdirSync(path.join(root, 'docs'));
  writeFileSync(path.join(root, 'present.md'), 'present');
  writeFileSync(path.join(root, 'with space.md'), 'present');
  assert.deepEqual(checkReferences(root, 'docs/index.md', '[valid](../present.md#heading) `../present.md` [space](<../with space.md>)'), []);
  const errors = checkReferences(root, 'docs/index.md', '[bad](missing.md)\n`other.md`\n[id]: missing-too.md\n[escape](../../README.md)');
  assert.equal(errors.length, 4);
  assert.ok(errors.some((e) => e.includes('escapes repository')));
});

test('examples are excluded without hiding ordinary links or code paths', () => {
  const text = '```md\n[example](missing.md)\n```\n`*.md` `~/.agents/skills/` `real.md`\n[website](https://example.org)';
  const refs = extractLocalReferences(text);
  assert.ok(refs.some((r) => r.ref === 'real.md'));
  assert.ok(!refs.some((r) => r.ref === 'missing.md' || r.ref === '*.md' || r.ref.startsWith('~/')));
});

test('reference-style links require defined labels and respect code examples', (t) => {
  const root = fixture(t);
  writeFileSync(path.join(root, 'present.md'), 'present');
  assert.deepEqual(checkReferences(root, 'index.md', '[target][ Mixed  CASE ]\n[Mixed CASE][]\n[mixed case]: present.md'), []);
  const errors = checkReferences(root, 'index.md', '[target][missing-label]\n[collapsed][]');
  assert.equal(errors.length, 2);
  assert.ok(errors.every((error) => error.includes('undefined reference label')));
  assert.deepEqual(checkReferences(root, 'index.md', '`[target][missing-label]`\n```md\n[target][missing]\n```\n[v] [ordinary text]'), []);
});

test('frontmatter rejects prefix bytes, missing fields, duplicates and missing delimiter', () => {
  const valid = '---\nname: router\ndescription: Routes math research\n---\nBody';
  assert.deepEqual(checkFrontmatter('SKILL.md', valid), []);
  for (const text of ['\ufeff' + valid, 'prefix\n' + valid, valid.replace('name: router\n', ''),
    valid.replace('name: router', 'name: router\nname: duplicate'), '---\nname: router\ndescription: missing end', '---\nname: router\ndescription: |\n---\nBody', valid.replace('name: router', 'name: [router]'), valid.replace('Routes math research', 'invalid: plain scalar'), valid.replace('Routes math research', '[list, not, text]')]) {
    assert.ok(checkFrontmatter('SKILL.md', text).length);
  }
});

test('frontmatter descriptions must decode to nonempty strings and entry names must match', () => {
  const frontmatter = (description) => `---\nname: math-research-activator\ndescription: ${description}\n---\nBody`;
  for (const scalar of ['123', '1.5', '-2e3', '0xFF', '1_000', '.inf', 'null', 'false', '""', "'  '", '"\\u0020"', '# empty comment', '', '|\n  \n  ']) {
    assert.ok(checkFrontmatter('SKILL.md', frontmatter(scalar)).length, scalar);
  }
  for (const scalar of ['"123"', "'1.5'", "'It''s math'", '|\n\n  Routes research', '>\n  Routes research']) {
    assert.deepEqual(checkFrontmatter('SKILL.md', frontmatter(scalar)), [], scalar);
  }
  assert.ok(checkFrontmatter('SKILL.md', '---\ndescription:\nname: router\n---').length);
  assert.deepEqual(checkFrontmatter('SKILL.md', frontmatter('Routes research'), 'math-research-activator'), []);
  assert.ok(checkFrontmatter('SKILL.md', frontmatter('Routes research'), 'another-router').length);
});

test('package checks use exact JSON paths, reject missing resources and PDFs', () => {
  const result = (paths) => [{ files: paths.map((p) => ({ path: p })) }];
  assert.deepEqual(checkPack(result(['SKILL.md']), ['SKILL.md']), []);
  assert.ok(checkPack(result(['renamed-SKILL.md']), ['SKILL.md']).length);
  for (const forbidden of ['references/book.PDF', 'math_book/input.md', 'skills/math-research-activator/SKILL.md', 'tests/eval/cases.jsonl']) {
    assert.ok(checkPack(result(['SKILL.md', forbidden]), ['SKILL.md']).length, forbidden);
  }
  assert.ok(checkPack('total files: success', []).length);
});

test('anchor index detects a missing entry even when domain counts still match', () => {
  const errors = checkAnchorIndex('overview.md', '| matrix | `matrix-analysis/` | old-card |', ['knowledge-base/matrix-analysis/new-card.md']);
  assert.ok(errors.some((e) => e.includes('matrix-analysis anchor list differs')));
});
