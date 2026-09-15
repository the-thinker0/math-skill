#!/usr/bin/env node
// Both shell wrappers and npm use this single set of release checks.
import { existsSync } from 'node:fs';
import path from 'node:path';
import { runCaptured } from './eval/process-lib.mjs';
import { ROOT, validateSuite } from './eval/eval-lib.mjs';
import { validateContent, checkPack } from './content-lib.mjs';

const errors = [];
try {
  const content = validateContent(ROOT);
  errors.push(...content.errors);
  console.log(`content inventory: ${Object.entries(content.counts).map(([name, count]) => `${name}=${count}`).join(', ')}`);
  const evaluation = validateSuite();
  errors.push(...evaluation.errors);
  console.log(`eval manifest: ${evaluation.cases.length} cases checked (static expectations only)`);

  const packArgs = ['pack', '--dry-run', '--ignore-scripts', '--json', '--cache', path.join(ROOT, '.npm-cache')];
  // npm.cmd cannot be spawned without a shell on Windows. Use the JS CLI with
  // Node there, and npm_execpath when npm launched this validator.
  const npmCli = process.env.npm_execpath || (process.platform === 'win32' ? path.join(path.dirname(process.execPath), 'node_modules/npm/bin/npm-cli.js') : null);
  if (npmCli && !existsSync(npmCli)) throw new Error(`npm CLI not found: ${npmCli}`);
  const pack = runCaptured(npmCli ? process.execPath : 'npm', npmCli ? [npmCli, ...packArgs] : packArgs, {
    cwd: ROOT, encoding: 'utf8', timeout: 60000, maxBuffer: 16 * 1024 * 1024, shell: false,
  });
  if (pack.error || pack.signal || pack.status !== 0) {
    errors.push(`npm pack failed: ${pack.error?.message || pack.signal || `exit ${pack.status}`} ${(pack.stderr || '').trim()}`);
  } else {
    const expected = content.files.filter((file) => !file.startsWith('skills/') && !file.startsWith('tests/'));
    expected.push('package.json', 'LICENSE', 'bin/math-skill.cjs');
    try { errors.push(...checkPack(JSON.parse(pack.stdout), expected)); }
    catch (err) { errors.push(`cannot parse npm pack JSON: ${err.message}`); }
  }
} catch (err) { errors.push(err.message); }

for (const error of errors) console.error(`[FAIL] ${error}`);
if (errors.length) {
  console.error(`validation failed: ${errors.length} issue(s)`);
  process.exitCode = 1;
} else {
  console.log('validation passed: bilingual structure, local links, inventory, eval expectations and package contents');
  console.log('Mathematical correctness and real-agent behavior require separate review; run npm test for tool regressions.');
}
