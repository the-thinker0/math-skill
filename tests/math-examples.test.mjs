import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

// Execute the shipped examples themselves, so documentation edits are checked.
// These finite counterexamples and ideal-game checks are not theorem proofs.
for (const name of ['query-aware-compression', 'equivariance-check', 'security-reduction']) {
  test(`worked example: ${name} (both languages)`, () => {
    const snippets = ['', '.en'].map((language) => {
      const url = new URL(`../references/worked-examples/${name}${language}.md`, import.meta.url);
      const blocks = [...readFileSync(url, 'utf8').matchAll(/^```javascript\r?\n([\s\S]*?)^```\s*$/gm)];
      assert.equal(blocks.length, 1, `${url.pathname}: expected one runnable check`);
      return blocks[0][1];
    });
    assert.equal(snippets[0], snippets[1], 'Bilingual examples must implement the same check');
    for (const source of snippets) vm.runInNewContext(source, {}, { timeout: 1000 });
  });
}
