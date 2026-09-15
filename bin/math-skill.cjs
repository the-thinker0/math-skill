#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const fsp = fs.promises;
const os = require('node:os');
const path = require('node:path');

const PACKAGE_ROOT = path.resolve(__dirname, '..');
const PACKAGE_JSON = require(path.join(PACKAGE_ROOT, 'package.json'));

const SKILL_NAME = 'math-research-activator';
const INSTALL_MARKER = '.math-skill-install.json';

const INSTALL_ENTRIES = [
  'SKILL.md',
  'SKILL.en.md',
  'LICENSE',
  'commands',
  'lenses',
  'design-patterns',
  'agents',
  'knowledge-base',
  'references',
];

const HOME = os.homedir();

const PLATFORMS = {
  codex: {
    baseDir: path.join(HOME, '.codex'),
    skillsDir: path.join(HOME, '.codex', 'skills'),
  },
  claude: {
    baseDir: path.join(HOME, '.claude'),
    skillsDir: path.join(HOME, '.claude', 'skills'),
  },
  // DeepSeek Harness filesystem provider (rank 400 user-dsh).
  // $DSH_HOME overrides the default ~/.dsh. Do not also write ~/.agents/skills
  // here: Codex may scan that shared root and would then see a duplicate.
  dsh: {
    get baseDir() {
      return process.env.DSH_HOME || path.join(HOME, '.dsh');
    },
    get skillsDir() {
      return path.join(this.baseDir, 'skills');
    },
  },
};

function printUsage() {
  console.log(`
Math Skill ${PACKAGE_JSON.version}

Usage:
  math-skill install [--codex|--claude|--dsh|--all]
  math-skill update [--codex|--claude|--dsh|--all]
  math-skill doctor [--codex|--claude|--dsh|--all]
  math-skill uninstall [--codex|--claude|--dsh|--all]

Recommended install:
  npx -y math-skill@latest install --all

Recommended update:
  npx -y math-skill@latest update --all
`);
}

async function exists(filePath) {
  try {
    await fsp.lstat(filePath);
    return true;
  } catch (error) {
    if (error.code === 'ENOENT' || error.code === 'ENOTDIR') return false;
    throw error;
  }
}

async function isDir(p) {
  try {
    return (await fsp.stat(p)).isDirectory();
  } catch (error) {
    if (error.code === 'ENOENT' || error.code === 'ENOTDIR') return false;
    throw error;
  }
}

async function readSkillName(skillFile) {
  try {
    const content = await fsp.readFile(skillFile, 'utf8');
    const frontmatter = content.match(/^---\s*\r?\n([\s\S]*?)\r?\n---/);
    if (!frontmatter) return null;
    const nameMatch = frontmatter[1].match(/^name:\s*['"]?([^'"\r\n]+)['"]?\s*$/m);
    return nameMatch ? nameMatch[1].trim() : null;
  } catch {
    return null;
  }
}

async function selectPlatforms(args) {
  const names = Object.keys(PLATFORMS);
  if (args.includes('--all')) return names;
  const selected = names.filter((name) => args.includes(`--${name}`));
  if (selected.length > 0) return selected;
  const detected = [];
  for (const [name, config] of Object.entries(PLATFORMS)) {
    if (await isDir(config.baseDir)) detected.push(name);
  }
  if (detected.length > 0) return detected;
  throw new Error(
    'No Codex, Claude Code, or DeepSeek Harness detected. Use --codex, --claude, --dsh, or --all.'
  );
}

async function copyRuntime(tempDir) {
  await fsp.mkdir(tempDir, { recursive: true });
  const missing = [];
  for (const entry of INSTALL_ENTRIES) {
    const source = path.join(PACKAGE_ROOT, entry);
    if (!(await exists(source))) {
      missing.push(entry);
      continue;
    }
    await fsp.cp(source, path.join(tempDir, entry), {
      recursive: true, force: true, errorOnExist: false,
      filter: async (sourcePath) => {
        const stat = await fsp.lstat(sourcePath);
        if (!stat.isFile() && !stat.isDirectory()) {
          throw new Error(`Package runtime must contain regular files and directories only: ${sourcePath}`);
        }
        return true;
      },
    });
  }
  if (missing.length > 0) {
    throw new Error(
      `Package incomplete: missing required install entries (${missing.join(', ')}). ` +
      'Refusing to install a partial Math Skill.'
    );
  }
  const marker = {
    package: PACKAGE_JSON.name,
    version: PACKAGE_JSON.version,
    skillName: SKILL_NAME,
    installedAt: new Date().toISOString(),
  };
  await fsp.writeFile(path.join(tempDir, INSTALL_MARKER), JSON.stringify(marker, null, 2) + '\n', 'utf8');
}

async function findSkillFiles(rootDir, maxDepth = Infinity) {
  const results = [];
  async function walk(currentDir, depth) {
    if (depth > maxDepth || !(await exists(currentDir))) return;
    const entries = await fsp.readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        await walk(fullPath, depth + 1);
      } else if (entry.isFile() && entry.name === 'SKILL.md') {
        results.push(fullPath);
      } else if (entry.isSymbolicLink() && await isDir(fullPath)) {
        // Linked skill roots are valid installs; inspect their direct entry
        // without recursively following links or creating traversal cycles.
        const linkedEntry = path.join(fullPath, 'SKILL.md');
        if (await exists(linkedEntry)) results.push(linkedEntry);
      }
    }
  }
  await walk(rootDir, 0);
  return results;
}

async function validateInstall(installDir) {
  for (const entry of ['SKILL.md', 'SKILL.en.md', 'LICENSE']) {
    const file = path.join(installDir, entry);
    if (!(await exists(file)) || !(await fsp.lstat(file)).isFile()) {
      throw new Error(`Missing required file in install content: ${entry}.`);
    }
    if (entry.startsWith('SKILL.')) {
      const skillName = await readSkillName(file);
      if (skillName !== SKILL_NAME) throw new Error(`${entry} name should be ${SKILL_NAME}, got ${skillName || 'unreadable'}.`);
    }
  }
  const skillFiles = await findSkillFiles(installDir);
  if (skillFiles.length !== 1) throw new Error(`Found ${skillFiles.length} SKILL.md files; must have exactly one entry.`);
  // Verify the runtime content is complete, so a partial/trimmed package cannot
  // silently install. These mirror copyRuntime's expected directory layout.
  for (const entry of REQUIRED_DIRS) {
    const directory = path.join(installDir, entry);
    if (!(await isDir(directory))) {
      throw new Error(`Install content missing required directory: ${entry}/`);
    }
    if ((await fsp.readdir(directory)).length === 0) throw new Error(`Install content has empty required directory: ${entry}/`);
  }
}

const REQUIRED_DIRS = ['commands', 'lenses', 'design-patterns', 'agents', 'knowledge-base', 'references'];

async function ensureStateDirs() {
  const stateRoot = path.join(HOME, '.math-skill');
  const tempRoot = path.join(stateRoot, 'tmp');
  const backupRoot = path.join(stateRoot, 'backups');
  await fsp.mkdir(tempRoot, { recursive: true });
  await fsp.mkdir(backupRoot, { recursive: true });
  return { tempRoot, backupRoot };
}

async function movePath(source, destination, { deferSourceRemoval = false } = {}) {
  await fsp.mkdir(path.dirname(destination), { recursive: true });
  try {
    await fsp.rename(source, destination);
  } catch (error) {
    if (error.code !== 'EXDEV') throw error;
    // Preserve relative links when a custom platform home is on another device.
    // Remove a partial copy on failure, while leaving the source untouched.
    try {
      await fsp.cp(source, destination, { recursive: true, force: false, errorOnExist: true, verbatimSymlinks: true });
    } catch (copyError) {
      await fsp.rm(destination, { recursive: true, force: true });
      throw copyError;
    }
    if (!deferSourceRemoval) await fsp.rm(source, { recursive: true, force: true });
  }
}

async function assertSafeTarget(target) {
  // Resolve existing ancestors, but do not follow the final target symlink:
  // replacing that link is safe and must leave its referent untouched.
  async function resolveParent(directory) {
    try {
      return await fsp.realpath(directory);
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      return path.join(await resolveParent(path.dirname(directory)), path.basename(directory));
    }
  }
  const physicalTarget = path.join(await resolveParent(path.dirname(path.resolve(target))), path.basename(target));
  const packageRoot = await fsp.realpath(PACKAGE_ROOT);
  const relative = path.relative(physicalTarget, packageRoot);
  if (!relative || (relative !== '..' && !relative.startsWith(`..${path.sep}`) && !path.isAbsolute(relative))) {
    throw new Error(`Unsafe install target contains the running package: ${target}`);
  }
}

async function moveLegacyDuplicates(platform, canonicalTarget, backupRoot) {
  const skillsDir = PLATFORMS[platform].skillsDir;
  if (!(await exists(skillsDir))) return [];
  const moved = [];
  const children = await fsp.readdir(skillsDir, { withFileTypes: true });
  for (const child of children) {
    if (!child.isDirectory()) continue;
    const candidate = path.join(skillsDir, child.name);
    if (path.resolve(candidate) === path.resolve(canonicalTarget)) continue;
    const candidateSkillName = await readSkillName(path.join(candidate, 'SKILL.md'));
    if (candidateSkillName !== SKILL_NAME) continue;
    try {
      await assertSafeTarget(candidate);
    } catch (error) {
      // A repository installed under a legacy name can also be the package
      // executing this command. Keep that source in place and let doctor
      // report the remaining duplicate instead of moving the running package.
      console.warn(`! ${platform}: preserved duplicate: ${candidate}`);
      console.warn(`  ${error.message}`);
      continue;
    }
    const destination = path.join(backupRoot, `${platform}-duplicate-${child.name}-${Date.now()}`);
    await movePath(candidate, destination);
    moved.push({ source: candidate, backup: destination });
  }
  return moved;
}

async function installPlatform(platform) {
  const skillsDir = PLATFORMS[platform].skillsDir;
  const target = path.join(skillsDir, SKILL_NAME);
  await assertSafeTarget(target);
  const { tempRoot, backupRoot } = await ensureStateDirs();
  const runId = `${Date.now()}-${process.pid}`;
  const tempDir = path.join(tempRoot, `${platform}-${runId}`);
  // Keep rollback on the target filesystem, including custom DSH_HOME mounts.
  const oldVersionBackup = path.join(skillsDir, `.math-skill-backup-${runId}`);
  let oldVersionMoved = false;
  let newVersionMoved = false;
  try {
    await copyRuntime(tempDir);
    await validateInstall(tempDir);
    await fsp.mkdir(skillsDir, { recursive: true });
    // lstat detects dangling links too. Never remove an old target if its
    // backup failed; rollback may only remove a version placed by this run.
    if (await exists(target)) {
      await movePath(target, oldVersionBackup);
      oldVersionMoved = true;
    }
    await movePath(tempDir, target, { deferSourceRemoval: true });
    newVersionMoved = true;
    await validateInstall(target);
  } catch (error) {
    if (newVersionMoved) await fsp.rm(target, { recursive: true, force: true });
    if (oldVersionMoved) await movePath(oldVersionBackup, target);
    throw error;
  } finally {
    await fsp.rm(tempDir, { recursive: true, force: true });
  }
  if (oldVersionMoved) await fsp.rm(oldVersionBackup, { recursive: true, force: true });
  // Only relocate duplicate installs after the replacement is known good.
  const movedDuplicates = await moveLegacyDuplicates(platform, target, backupRoot);
  console.log(`\u2713 ${platform}: Math Skill ${PACKAGE_JSON.version} installed`);
  console.log(`  ${target}`);
  for (const duplicate of movedDuplicates) {
    console.log(`  Removed duplicate: ${duplicate.source}`);
    console.log(`  Backup: ${duplicate.backup}`);
  }
}

async function doctorPlatform(platform) {
  const skillsDir = PLATFORMS[platform].skillsDir;
  const target = path.join(skillsDir, SKILL_NAME);
  if (await exists(target)) {
    try {
      await validateInstall(target);
    } catch (error) {
      console.log(`! ${platform}: incomplete installation: ${error.message}`);
      process.exitCode = 2;
      return;
    }
  }
  const skillFiles = await findSkillFiles(skillsDir, 5);
  const matches = [];
  for (const skillFile of skillFiles) {
    const skillName = await readSkillName(skillFile);
    if (skillName === SKILL_NAME) matches.push(skillFile);
  }
  if (matches.length === 0) {
    console.log(`- ${platform}: Math Skill not installed`);
    return;
  }
  if (matches.length > 1) {
    console.log(`! ${platform}: ${matches.length} duplicate entries detected`);
    for (const skillFile of matches) console.log(`  ${skillFile}`);
    process.exitCode = 2;
    return;
  }
  try {
    await validateInstall(path.dirname(matches[0]));
  } catch (error) {
    console.log(`! ${platform}: incomplete installation: ${error.message}`);
    process.exitCode = 2;
    return;
  }
  const markerFile = path.join(path.dirname(matches[0]), INSTALL_MARKER);
  let version = 'unknown';
  if (await exists(markerFile)) {
    try {
      const marker = JSON.parse(await fsp.readFile(markerFile, 'utf8'));
      version = marker.version || version;
    } catch {}
  }
  console.log(`\u2713 ${platform}: single entry detected, version ${version}`);
  console.log(`  ${matches[0]}`);
}

async function uninstallPlatform(platform) {
  const skillsDir = PLATFORMS[platform].skillsDir;
  if (!(await exists(skillsDir))) {
    console.log(`- ${platform}: not installed`);
    return;
  }
  const children = await fsp.readdir(skillsDir, { withFileTypes: true });
  let removed = 0;
  for (const child of children) {
    if (!child.isDirectory() && !child.isSymbolicLink()) continue;
    const candidate = path.join(skillsDir, child.name);
    const skillName = await readSkillName(path.join(candidate, 'SKILL.md'));
    let managedInstall = false;
    try {
      const marker = JSON.parse(await fsp.readFile(path.join(candidate, INSTALL_MARKER), 'utf8'));
      managedInstall = marker.package === PACKAGE_JSON.name && marker.skillName === SKILL_NAME;
    } catch {}
    if (skillName !== SKILL_NAME && !managedInstall) continue;
    await assertSafeTarget(candidate);
    await fsp.rm(candidate, { recursive: true, force: true });
    console.log(`\u2713 Removed: ${candidate}`);
    removed += 1;
  }
  if (removed === 0) console.log(`- ${platform}: no Math Skill entry found`);
}

async function main() {
  const [, , command = 'help', ...args] = process.argv;
  if (command === 'help' || command === '--help' || command === '-h') {
    printUsage();
    return;
  }
  const allowedCommands = ['install', 'update', 'doctor', 'uninstall'];
  if (!allowedCommands.includes(command)) throw new Error(`Unknown command: ${command}`);
  const allowedOptions = ['--all', '--help', '-h', ...Object.keys(PLATFORMS).map((name) => `--${name}`)];
  for (const arg of args) {
    if (!allowedOptions.includes(arg)) throw new Error(`Unknown option: ${arg}`);
  }
  if (args.includes('--help') || args.includes('-h')) {
    printUsage();
    return;
  }
  const platforms = await selectPlatforms(args);
  for (const platform of platforms) {
    if (command === 'install' || command === 'update') await installPlatform(platform);
    else if (command === 'doctor') await doctorPlatform(platform);
    else if (command === 'uninstall') await uninstallPlatform(platform);
  }
}

main().catch((error) => {
  console.error(`\u2717 ${error.message}`);
  process.exitCode = 1;
});
