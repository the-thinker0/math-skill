// Shared manifest and runtime isolation rules. No agent or network is needed.
import { readFileSync, realpathSync, statSync, readdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
export const SOURCES = [
  'should-trigger-analysis.md', 'should-trigger-design.md',
  'should-trigger-knowledge.md', 'should-trigger-verification.md',
  'should-not-trigger.md', 'cross-domain-routing.md',
  'domain-router-isolation.md', 'knowledge-gap-protocol.md', 'mixed-language-routing.md',
];
const SCENARIOS = ['A', 'B', 'C', 'D', 'E'];
const DOMAINS = ['ai', 'crypto', 'ai-crypto', 'shared', 'none'];
const MATERIAL = /^(?:lenses|knowledge-base|design-patterns|references|agents)\//;
const CRYPTO = /^(?:knowledge-base\/cryptography(?:\/|$)|references\/books\/(?:applied-cryptography|foundations-of-cryptography|introduction-to-modern-cryptography)(?:\.en)?\.md$)/;

export function isolationProblem(domain, rel) {
  // Windows installations can report a different path casing.
  rel = rel.toLowerCase();
  if (domain === 'none' && (MATERIAL.test(rel) || /(?:^|\/)skill(?:\.en)?\.md$/.test(rel))) {
    return `scenario E loaded skill material: ${rel}`;
  }
  if (domain === 'ai' && (CRYPTO.test(rel) || /^references\/worked-examples\/security-reduction(?:\.en)?\.md$/.test(rel))) return `pure AI loaded crypto material: ${rel}`;
  if (domain === 'crypto' && /^(?:design-patterns\/|references\/(?:gpu-friendly-math|construction-moves)(?:\.en)?\.md$|references\/worked-examples\/(?:query-aware-compression|equivariance-check)(?:\.en)?\.md$)/.test(rel)) {
    return `pure crypto loaded AI construction/design material or GPU gate: ${rel}`;
  }
  return null;
}

function inside(root, target) {
  const rel = path.relative(root, target);
  return rel !== '..' && !rel.startsWith(`..${path.sep}`) && !path.isAbsolute(rel);
}

// Paths in the manifest/trace are canonical POSIX paths relative to the skill.
// Checking both spelling and realpath prevents ../, Windows and symlink aliases
// from bypassing isolation or reading outside the skill directory.
export function resolveArtifact(root, rel, { fileOnly = false } = {}) {
  if (typeof rel !== 'string' || !rel || /[\\\u0000-\u001f]/.test(rel) ||
      path.posix.isAbsolute(rel) || path.win32.isAbsolute(rel) || /^[a-z][a-z\d+.-]*:/i.test(rel)) {
    throw new Error(`artifact must be a relative POSIX path: ${String(rel)}`);
  }
  const clean = rel.replace(/\/$/, '');
  if (!clean || clean.split('/').some((part) => !part || part === '.' || part === '..')) {
    throw new Error(`artifact path is not canonical: ${rel}`);
  }
  const realRoot = realpathSync(root);
  const abs = realpathSync(path.join(realRoot, clean));
  if (!inside(realRoot, abs)) throw new Error(`artifact escapes skill root: ${rel}`);
  const stat = statSync(abs);
  if ((!stat.isFile() && !stat.isDirectory()) || (fileOnly && !stat.isFile())) {
    throw new Error(`artifact is not a ${fileOnly ? 'file' : 'file or directory'}: ${rel}`);
  }
  if (stat.isFile() && rel.endsWith('/')) throw new Error(`file path has trailing slash: ${rel}`);
  return { abs, rel: path.relative(realRoot, abs).split(path.sep).join('/'), directory: stat.isDirectory() };
}

function artifactPolicy(root, domain, rel, seen = new Set()) {
  const artifact = resolveArtifact(root, rel);
  if (seen.has(artifact.abs)) return;
  seen.add(artifact.abs);
  const problem = isolationProblem(domain, artifact.rel);
  if (problem) throw new Error(problem);
  if (artifact.directory) {
    for (const name of readdirSync(artifact.abs)) artifactPolicy(root, domain, `${artifact.rel}/${name}`, seen);
  }
}

export function loadManifest(text, { root = ROOT } = {}) {
  const errors = [];
  const cases = [];
  const ids = new Set();
  for (const [index, line] of text.split(/\r?\n/).entries()) {
    if (!line.trim() || line.trim().startsWith('//')) continue;
    let obj;
    try { obj = JSON.parse(line); } catch (err) {
      errors.push(`line ${index + 1}: invalid JSON (${err.message})`);
      continue;
    }
    const where = `line ${index + 1}${obj?.id ? ` (${obj.id})` : ''}`;
    if (!obj || typeof obj !== 'object' || Array.isArray(obj)) {
      errors.push(`${where}: case must be an object`);
      continue;
    }
    const before = errors.length;
    const fail = (message) => errors.push(`${where}: ${message}`);
    for (const field of ['id', 'source', 'prompt', 'lang', 'scenario', 'domain']) {
      if (typeof obj[field] !== 'string' || !obj[field].trim()) fail(`invalid or missing '${field}'`);
    }
    if (ids.has(obj.id)) fail('duplicate id');
    ids.add(obj.id);
    if (!SOURCES.includes(obj.source)) fail('unknown source');
    if (!SCENARIOS.includes(obj.scenario)) fail('scenario must be A/B/C/D/E');
    if (!DOMAINS.includes(obj.domain)) fail('domain must be ai/crypto/ai-crypto/shared/none');
    if (!['zh', 'en'].includes(obj.lang)) fail('lang must be zh/en');
    if (typeof obj.trigger !== 'boolean') fail('trigger must be boolean');
    if (obj.notes !== undefined && typeof obj.notes !== 'string') fail('notes must be a string');
    if (obj.trigger === false ? obj.scenario !== 'E' || obj.domain !== 'none' :
        obj.trigger === true && (obj.scenario === 'E' || obj.domain === 'none')) {
      fail('trigger=false iff scenario=E iff domain=none');
    }
    if (obj.lang === 'zh' && typeof obj.prompt === 'string' && !/\p{Script=Han}/u.test(obj.prompt)) {
      fail('lang=zh but prompt has no Han characters');
    }
    if (!Array.isArray(obj.may_load)) {
      fail('may_load must be an array');
    } else {
      if (obj.domain === 'none' && obj.may_load.length) fail('scenario E must declare no loadable artifacts');
      const paths = new Set();
      for (const rel of obj.may_load) {
        try {
          const artifact = resolveArtifact(root, rel);
          if (paths.has(artifact.rel)) fail(`duplicate may_load artifact: ${rel}`);
          paths.add(artifact.rel);
          artifactPolicy(root, obj.domain, rel);
        } catch (err) { fail(`may_load: ${err.message}`); }
      }
    }
    if (errors.length === before) cases.push(obj);
  }
  return { cases, errors };
}

export function readManifest(root = ROOT) {
  return loadManifest(readFileSync(path.join(root, 'tests/eval/cases.jsonl'), 'utf8'), { root });
}

export const norm = (s) => s.replace(/[\s\u3000]+/g, ' ').trim();
const QUOTES = { '"': '"', '“': '”', '「': '」' };
export function extractPrompts(text) {
  const prompts = [];
  let inSection = false;
  for (const raw of text.split(/\r?\n/)) {
    const heading = raw.match(/^#{1,6}\s+(.*)$/);
    if (heading) { inSection = /^(test cases|should |edge case)/i.test(heading[1].trim()); continue; }
    if (!inSection) continue;
    const match = raw.match(/^\s*(\d+\.\s|-\s)(.*)$/);
    if (!match) continue;
    let prompt = match[2].trim();
    if (prompt.startsWith('**') || (match[1].startsWith('-') && !(prompt[0] in QUOTES))) continue;
    if (prompt[0] in QUOTES) {
      const end = prompt.indexOf(QUOTES[prompt[0]], 1);
      if (end < 0) throw new Error(`unclosed prompt quote: ${raw}`);
      prompt = prompt.slice(1, end);
    } else {
      prompt = prompt.split(' → ')[0];
    }
    if (norm(prompt)) prompts.push(norm(prompt));
  }
  return prompts;
}

export function multisetDiff(a, b) {
  const counts = new Map();
  for (const s of a) counts.set(s, (counts.get(s) || 0) + 1);
  for (const s of b) counts.set(s, (counts.get(s) || 0) - 1);
  return [...counts].filter(([, count]) => count !== 0);
}

export function validateSuite(root = ROOT) {
  const { cases, errors } = readManifest(root);
  if (cases.length < 70) errors.push(`manifest contains ${cases.length} valid cases; expected at least 70`);
  for (const source of SOURCES) {
    try {
      const extracted = extractPrompts(readFileSync(path.join(root, 'tests/eval', source), 'utf8'));
      if (!extracted.length) errors.push(`${source}: no paper prompts found`);
      for (const [prompt, delta] of multisetDiff(extracted, cases.filter((c) => c.source === source).map((c) => norm(c.prompt)))) {
        errors.push(`${source}: ${delta > 0 ? 'missing from manifest' : 'missing from paper'} (${Math.abs(delta)}): ${prompt}`);
      }
    } catch (err) { errors.push(`${source}: ${err.message}`); }
  }
  for (const value of SCENARIOS) if (!cases.some((c) => c.scenario === value)) errors.push(`uncovered scenario: ${value}`);
  for (const value of DOMAINS) if (!cases.some((c) => c.domain === value)) errors.push(`uncovered domain: ${value}`);
  for (const value of ['zh', 'en']) if (!cases.some((c) => c.lang === value)) errors.push(`uncovered language: ${value}`);
  return { cases, errors };
}
