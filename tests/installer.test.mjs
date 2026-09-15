import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { openSync, closeSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const skillName = 'math-research-activator';
const runtimeDirs = ['commands', 'lenses', 'design-patterns', 'agents', 'knowledge-base', 'references'];
const entry = '---\nname: math-research-activator\ndescription: Fixture\n---\n';

async function fixture(t, packageLocation = 'package') {
  const dir = await fs.mkdtemp(path.join(root, '.installer-test-'));
  t.after(() => fs.rm(dir, { recursive: true, force: true }));
  const home = path.join(dir, 'home');
  const pkg = path.join(dir, packageLocation);
  const cli = path.join(pkg, 'bin', 'math-skill.cjs');
  const hook = path.join(dir, 'isolate.cjs');
  await fs.mkdir(path.dirname(cli), { recursive: true });
  await fs.mkdir(home, { recursive: true });
  await fs.copyFile(path.join(root, 'bin', 'math-skill.cjs'), cli);
  await fs.writeFile(path.join(pkg, 'package.json'), JSON.stringify({ name: 'math-skill', version: '0.0.0-test' }));
  await fs.writeFile(path.join(pkg, 'SKILL.md'), entry);
  await fs.writeFile(path.join(pkg, 'SKILL.en.md'), entry + 'English fixture\n');
  await fs.writeFile(path.join(pkg, 'LICENSE'), 'Fixture license\n');
  for (const name of runtimeDirs) {
    await fs.mkdir(path.join(pkg, name));
    await fs.writeFile(path.join(pkg, name, 'sample.md'), `${name} Chinese\n`);
    await fs.writeFile(path.join(pkg, name, 'sample.en.md'), `${name} English\n`);
  }
  // Stub only the child's home lookup; never read or change the real home.
  await fs.writeFile(hook, `
require('node:os').homedir = () => process.env.MATH_SKILL_TEST_HOME;
const fs = require('node:fs');
const path = require('node:path');
const rename = fs.promises.rename;
const copy = fs.promises.cp;
fs.promises.cp = async (source, target, options) => {
  if (process.env.MATH_SKILL_TEST_COPY_FAILURE === target) {
    await fs.promises.mkdir(target, { recursive: true });
    await fs.promises.writeFile(path.join(target, 'partial-copy.txt'), 'partial');
    throw new Error('simulated interrupted cross-device copy');
  }
  return copy(source, target, options);
};
fs.promises.rename = async (source, target) => {
  if (source === process.env.MATH_SKILL_TEST_RENAME_FAILURE) {
    const error = new Error('simulated backup permission failure');
    error.code = 'EACCES';
    throw error;
  }
  if (process.env.MATH_SKILL_TEST_EXDEV_TARGET === target && source.includes(path.sep + 'tmp' + path.sep)) {
    const error = new Error('simulated cross-device staging');
    error.code = 'EXDEV';
    throw error;
  }
  const result = await rename(source, target);
  if (process.env.MATH_SKILL_TEST_CORRUPT_TARGET === target && source.includes(path.sep + 'tmp' + path.sep)) {
    await fs.promises.unlink(path.join(target, 'SKILL.en.md'));
  }
  return result;
};
`);
  const target = (platform = 'codex') => path.join(home, `.${platform}`, 'skills', skillName);
  const run = (args, env = {}) => {
    const stdoutPath = path.join(dir, 'stdout.txt');
    const stderrPath = path.join(dir, 'stderr.txt');
    const stdout = openSync(stdoutPath, 'w');
    const stderr = openSync(stderrPath, 'w');
    let result;
    try {
      result = spawnSync(process.execPath, ['--require', hook, cli, ...args], {
        cwd: dir,
        stdio: ['ignore', stdout, stderr],
        env: { ...process.env, DSH_HOME: path.join(home, '.dsh'), MATH_SKILL_TEST_HOME: home, ...env },
      });
    } finally {
      closeSync(stdout);
      closeSync(stderr);
    }
    assert.ifError(result.error);
    return { ...result, stdout: readFileSync(stdoutPath, 'utf8'), stderr: readFileSync(stderrPath, 'utf8') };
  };
  return { dir, home, pkg, target, run };
}

function succeeds(result) {
  assert.equal(result.status, 0, result.stderr || result.stdout);
}

test('install/update/doctor/uninstall work from another cwd and preserve bilingual runtime', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--all']));
  for (const platform of ['codex', 'claude', 'dsh']) {
    assert.equal(await fs.readFile(path.join(f.target(platform), 'SKILL.en.md'), 'utf8'), entry + 'English fixture\n');
  }
  await fs.writeFile(path.join(f.target(), 'obsolete.md'), 'obsolete');
  succeeds(f.run(['update', '--all']));
  await assert.rejects(fs.access(path.join(f.target(), 'obsolete.md')), { code: 'ENOENT' });
  succeeds(f.run(['doctor', '--all']));
  succeeds(f.run(['uninstall', '--all']));
  await assert.rejects(fs.access(f.target()), { code: 'ENOENT' });
});

test('unknown options fail before creating installation or state directories', async (t) => {
  const f = await fixture(t);
  const result = f.run(['install', '--codex', '--typo']);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Unknown option/);
  assert.deepEqual(await fs.readdir(f.home), []);
});

test('command help does not install anything', async (t) => {
  const f = await fixture(t);
  const result = f.run(['install', '--codex', '--help']);
  succeeds(result);
  assert.match(result.stdout, /Usage:/);
  assert.deepEqual(await fs.readdir(f.home), []);
});

test('doctor fails for a partial installation', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  await fs.rm(path.join(f.target(), 'lenses'), { recursive: true });
  const result = f.run(['doctor', '--codex']);
  assert.notEqual(result.status, 0);
  assert.match(result.stdout + result.stderr, /missing|Missing|incomplete/i);
});

test('doctor fails when the root entry is missing', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  await fs.unlink(path.join(f.target(), 'SKILL.md'));
  const result = f.run(['doctor', '--codex']);
  assert.notEqual(result.status, 0);
});

test('a failed old-version backup leaves the old installation intact', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  const custom = path.join(f.target(), 'user-note.md');
  await fs.writeFile(custom, 'irreplaceable note');
  const result = f.run(['update', '--codex'], { MATH_SKILL_TEST_RENAME_FAILURE: f.target() });
  assert.notEqual(result.status, 0);
  assert.equal(await fs.readFile(custom, 'utf8'), 'irreplaceable note');
  assert.equal(await fs.readFile(path.join(f.target(), 'SKILL.md'), 'utf8'), entry);
});

test('update replaces a dangling symlink without touching its referent', async (t) => {
  const f = await fixture(t);
  const referent = path.join(f.dir, 'missing-referent');
  await fs.mkdir(path.dirname(f.target()), { recursive: true });
  try {
    await fs.symlink(referent, f.target(), 'junction');
  } catch (error) {
    if (error.code === 'EPERM') return t.skip('Creating symlinks requires OS permission');
    throw error;
  }
  succeeds(f.run(['update', '--codex']));
  assert.equal((await fs.lstat(f.target())).isDirectory(), true);
  await assert.rejects(fs.access(referent), { code: 'ENOENT' });
});

test('incomplete package fails without changing old install and cleans staging data', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  const before = await fs.readFile(path.join(f.target(), '.math-skill-install.json'), 'utf8');
  await fs.rm(path.join(f.pkg, 'SKILL.en.md'));
  const result = f.run(['update', '--codex']);
  assert.notEqual(result.status, 0);
  assert.equal(await fs.readFile(path.join(f.target(), '.math-skill-install.json'), 'utf8'), before);
  assert.deepEqual(await fs.readdir(path.join(f.home, '.math-skill', 'tmp')), []);
});

test('update removes nested legacy entries and backs up a direct duplicate', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  const nested = path.join(f.target(), 'skills', skillName);
  const duplicate = path.join(path.dirname(f.target()), 'old-math-skill');
  await fs.mkdir(nested, { recursive: true });
  await fs.writeFile(path.join(nested, 'SKILL.md'), entry);
  await fs.mkdir(duplicate);
  await fs.writeFile(path.join(duplicate, 'SKILL.md'), entry);
  await fs.writeFile(path.join(duplicate, 'note.txt'), 'keep duplicate data');
  assert.notEqual(f.run(['doctor', '--codex']).status, 0);
  succeeds(f.run(['update', '--codex']));
  succeeds(f.run(['doctor', '--codex']));
  await assert.rejects(fs.access(duplicate), { code: 'ENOENT' });
  const backups = await fs.readdir(path.join(f.home, '.math-skill', 'backups'));
  const saved = backups.find((name) => name.startsWith('codex-duplicate-'));
  assert.ok(saved);
  assert.equal(await fs.readFile(path.join(f.home, '.math-skill', 'backups', saved, 'note.txt'), 'utf8'), 'keep duplicate data');
});

test('custom relative DSH_HOME resolves against the caller cwd', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--dsh'], { DSH_HOME: 'custom dsh' }));
  assert.equal(await fs.readFile(path.join(f.dir, 'custom dsh', 'skills', skillName, 'SKILL.md'), 'utf8'), entry);
});

test('post-swap validation failure restores the complete previous installation', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  const custom = path.join(f.target(), 'user-note.md');
  await fs.writeFile(custom, 'keep me');
  const result = f.run(['update', '--codex'], { MATH_SKILL_TEST_CORRUPT_TARGET: f.target() });
  assert.notEqual(result.status, 0);
  assert.equal(await fs.readFile(custom, 'utf8'), 'keep me');
  assert.equal(await fs.readFile(path.join(f.target(), 'SKILL.en.md'), 'utf8'), entry + 'English fixture\n');
  succeeds(f.run(['doctor', '--codex']));
});

test('cross-device staging completes with a clean temporary directory', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  succeeds(f.run(['update', '--codex'], { MATH_SKILL_TEST_EXDEV_TARGET: f.target() }));
  succeeds(f.run(['doctor', '--codex']));
  assert.deepEqual(await fs.readdir(path.join(f.home, '.math-skill', 'tmp')), []);
  assert.deepEqual(await fs.readdir(path.dirname(f.target())), [skillName]);
});

test('uninstall recognizes its marker when the root skill file is damaged', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  await fs.unlink(path.join(f.target(), 'SKILL.md'));
  succeeds(f.run(['uninstall', '--codex']));
  await assert.rejects(fs.access(f.target()), { code: 'ENOENT' });
});

test('linked installs are diagnosed and unlinked without deleting the source', async (t) => {
  const f = await fixture(t);
  await fs.mkdir(path.dirname(f.target()), { recursive: true });
  try {
    await fs.symlink(f.pkg, f.target(), 'junction');
  } catch (error) {
    if (error.code === 'EPERM') return t.skip('Creating symlinks requires OS permission');
    throw error;
  }
  succeeds(f.run(['doctor', '--codex']));
  succeeds(f.run(['uninstall', '--codex']));
  assert.equal(await fs.readFile(path.join(f.pkg, 'SKILL.md'), 'utf8'), entry);
  await assert.rejects(fs.lstat(f.target()), { code: 'ENOENT' });
});

test('installer rejects a target containing the running package', async (t) => {
  const f = await fixture(t, path.join('skills', skillName, 'package'));
  const result = f.run(['install', '--dsh'], { DSH_HOME: f.dir });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Unsafe install target/);
  assert.equal(await fs.readFile(path.join(f.pkg, 'SKILL.md'), 'utf8'), entry);
  assert.deepEqual(await fs.readdir(f.home), []);
});

test('interrupted cross-device staging restores the previous installation', async (t) => {
  const f = await fixture(t);
  succeeds(f.run(['install', '--codex']));
  await fs.writeFile(path.join(f.target(), 'user-note.md'), 'retain after failed copy');
  const result = f.run(['update', '--codex'], {
    MATH_SKILL_TEST_EXDEV_TARGET: f.target(), MATH_SKILL_TEST_COPY_FAILURE: f.target(),
  });
  assert.notEqual(result.status, 0);
  assert.equal(await fs.readFile(path.join(f.target(), 'user-note.md'), 'utf8'), 'retain after failed copy');
  await assert.rejects(fs.access(path.join(f.target(), 'partial-copy.txt')), { code: 'ENOENT' });
  succeeds(f.run(['doctor', '--codex']));
});

test('runtime symlinks cannot make an installation depend on an external source', async (t) => {
  const f = await fixture(t);
  const source = path.join(f.dir, 'external.md');
  await fs.writeFile(source, 'outside the package');
  try {
    await fs.symlink(source, path.join(f.pkg, 'lenses', 'external.md'));
  } catch (error) {
    if (error.code === 'EPERM') return t.skip('Creating symlinks requires OS permission');
    throw error;
  }
  const result = f.run(['install', '--codex']);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /regular files and directories only/);
  await assert.rejects(fs.access(f.target()), { code: 'ENOENT' });
  assert.equal(await fs.readFile(source, 'utf8'), 'outside the package');
});

test('duplicate cleanup preserves a legacy directory containing the running package', async (t) => {
  const f = await fixture(t, path.join('home', '.codex', 'skills', 'legacy-math-skill'));
  const result = f.run(['install', '--codex']);
  succeeds(result);
  assert.equal(await fs.readFile(path.join(f.pkg, 'SKILL.md'), 'utf8'), entry);
  assert.equal(await fs.readFile(path.join(f.target(), 'SKILL.md'), 'utf8'), entry);
  assert.match(result.stderr, /preserved duplicate/i);
  const diagnosis = f.run(['doctor', '--codex']);
  assert.equal(diagnosis.status, 2);
  assert.match(diagnosis.stdout, /duplicate entries/i);
});
