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
};

function printUsage() {
  console.log(`
Math Skill ${PACKAGE_JSON.version}

Usage:
  math-skill install [--codex|--claude|--all]
  math-skill update [--codex|--claude|--all]
  math-skill doctor [--codex|--claude|--all]
  math-skill uninstall [--codex|--claude|--all]

Recommended install:
  npx -y math-skill@latest install --all

Recommended update:
  npx -y math-skill@latest update --all
`);
}

async function exists(filePath) {
  try {
    await fsp.access(filePath);
    return true;
  } catch {
    return false;
  }
}

async function isDir(p) {
  try {
    return (await fsp.stat(p)).isDirectory();
  } catch {
    return false;
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
  if (args.includes('--all')) return ['codex', 'claude'];
  const selected = [];
  if (args.includes('--codex')) selected.push('codex');
  if (args.includes('--claude')) selected.push('claude');
  if (selected.length > 0) return selected;
  const detected = [];
  for (const [name, config] of Object.entries(PLATFORMS)) {
    if (await exists(config.baseDir)) detected.push(name);
  }
  if (detected.length > 0) return detected;
  throw new Error('No Codex or Claude Code detected. Use --codex, --claude, or --all.');
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

async function findSkillFiles(rootDir, maxDepth = 5) {
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
      }
    }
  }
  await walk(rootDir, 0);
  return results;
}

async function validateInstall(installDir) {
  const rootSkill = path.join(installDir, 'SKILL.md');
  if (!(await exists(rootSkill))) throw new Error('Missing root SKILL.md in install content.');
  const skillName = await readSkillName(rootSkill);
  if (skillName !== SKILL_NAME) throw new Error(`SKILL.md name should be ${SKILL_NAME}, got ${skillName || 'unreadable'}.`);
  const skillFiles = await findSkillFiles(installDir);
  if (skillFiles.length !== 1) throw new Error(`Found ${skillFiles.length} SKILL.md files; must have exactly one entry.`);
  // Verify the runtime content is complete, so a partial/trimmed package cannot
  // silently install. These mirror copyRuntime's expected directory layout.
  for (const entry of REQUIRED_DIRS) {
    if (!(await exists(path.join(installDir, entry)))) {
      throw new Error(`Install content missing required directory: ${entry}/`);
    }
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

async function movePath(source, destination) {
  await fsp.mkdir(path.dirname(destination), { recursive: true });
  try {
    await fsp.rename(source, destination);
  } catch (error) {
    if (error.code !== 'EXDEV') throw error;
    await fsp.cp(source, destination, { recursive: true, force: true });
    await fsp.rm(source, { recursive: true, force: true });
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
    const destination = path.join(backupRoot, `${platform}-duplicate-${child.name}-${Date.now()}`);
    await movePath(candidate, destination);
    moved.push({ source: candidate, backup: destination });
  }
  return moved;
}

async function installPlatform(platform) {
  const skillsDir = PLATFORMS[platform].skillsDir;
  const target = path.join(skillsDir, SKILL_NAME);
  const { tempRoot, backupRoot } = await ensureStateDirs();
  const runId = `${Date.now()}-${process.pid}`;
  const tempDir = path.join(tempRoot, `${platform}-${runId}`);
  const oldVersionBackup = path.join(backupRoot, `${platform}-${runId}`);
  await fsp.mkdir(skillsDir, { recursive: true });
  await copyRuntime(tempDir);
  await validateInstall(tempDir);
  const movedDuplicates = await moveLegacyDuplicates(platform, target, backupRoot);
  // Defensive: a stale NON-directory at `target` (e.g. a leftover file/symlink
  // from a broken prior install) would make the swap rename fail with ENOTDIR.
  // Detect it via stat and relocate it like an old version so it is never lost
  // and the swap can always proceed.
  let targetStat = null;
  try { targetStat = await fsp.stat(target); } catch { targetStat = null; }
  const hadOldVersion = targetStat !== null;
  if (hadOldVersion && !targetStat.isDirectory()) {
    await movePath(target, oldVersionBackup);
  }
  try {
    if (hadOldVersion && (await isDir(target))) await movePath(target, oldVersionBackup);
    await movePath(tempDir, target);
    await validateInstall(target);
    if (hadOldVersion) await fsp.rm(oldVersionBackup, { recursive: true, force: true });
  } catch (error) {
    await fsp.rm(target, { recursive: true, force: true });
    if (hadOldVersion && (await exists(oldVersionBackup))) await movePath(oldVersionBackup, target);
    await fsp.rm(tempDir, { recursive: true, force: true });
    throw error;
  }
  console.log(`\u2713 ${platform}: Math Skill ${PACKAGE_JSON.version} installed`);
  console.log(`  ${target}`);
  for (const duplicate of movedDuplicates) {
    console.log(`  Removed duplicate: ${duplicate.source}`);
    console.log(`  Backup: ${duplicate.backup}`);
  }
}

async function doctorPlatform(platform) {
  const skillsDir = PLATFORMS[platform].skillsDir;
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
    if (!child.isDirectory()) continue;
    const candidate = path.join(skillsDir, child.name);
    const skillName = await readSkillName(path.join(candidate, 'SKILL.md'));
    if (skillName !== SKILL_NAME) continue;
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