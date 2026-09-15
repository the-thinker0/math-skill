// Cross-platform content checks. These validate structure, not theorem truth.
import { readFileSync, readdirSync, existsSync, realpathSync } from 'node:fs';
import path from 'node:path';

export const CONTENT_DIRS = ['commands', 'skills', 'agents', 'lenses', 'knowledge-base', 'design-patterns', 'references'];
export const EXPECTED = { lenses: 15, 'knowledge-base': 41, 'design-patterns': 22 };
const LENSES = 'axiomatization categorical variational duality symmetry perturbation topological probabilistic geometric local-to-global algorithmic spectral game causal projection'.split(' ');
const DOMAINS = ['matrix-analysis', 'optimization', 'differential-geometry', 'lie-theory', 'topology', 'probability', 'information-geometry', 'algebraic-geometry', 'cryptography'];
const COMPONENTS = ['attention', 'loss', 'routing', 'representation', 'compression'];
const inside = (root, file) => { const rel = path.relative(root, file); return rel !== '..' && !rel.startsWith(`..${path.sep}`) && !path.isAbsolute(rel); };

export function walkMarkdown(root, dir) {
  const files = [];
  for (const entry of readdirSync(path.join(root, dir), { withFileTypes: true })) {
    const rel = `${dir}/${entry.name}`;
    if (entry.isSymbolicLink()) throw new Error(`content symlink is not supported: ${rel}`);
    if (entry.isDirectory()) files.push(...walkMarkdown(root, rel));
    else if (entry.isFile() && entry.name.endsWith('.md')) files.push(rel);
  }
  return files;
}

export function checkPairs(files) {
  const inventory = new Set(files);
  return files.flatMap((file) => {
    const pair = file.endsWith('.en.md') ? file.replace(/\.en\.md$/, '.md') : file.replace(/\.md$/, '.en.md');
    return inventory.has(pair) ? [] : [`${file}: missing bilingual counterpart ${pair}`];
  });
}

// Ignore fenced examples: they can intentionally show uninstalled/local paths.
// Inline links (including reference-style definitions) are documentation links;
// inline code is checked only when it is a single concrete relative .md/path.
export function extractLocalReferences(text, { readme = false } = {}) {
  const refs = [];
  const definitions = new Set(), usages = [];
  const labelKey = (label) => label.trim().replace(/\s+/g, ' ').toLowerCase();
  let fence = null, historical = false;
  for (const [index, line] of text.split(/\r?\n/).entries()) {
    if (readme && /^## (?:变更日志|Changelog)/i.test(line)) historical = true;
    const marker = line.match(/^\s*(`{3,}|~{3,})/);
    if (marker) {
      if (!fence) fence = marker[1];
      else if (marker[1][0] === fence[0] && marker[1].length >= fence.length) fence = null;
      continue;
    }
    if (fence) continue;
    const add = (ref, kind) => refs.push({ ref: ref.replace(/^<|>$/g, ''), line: index + 1, kind });
    const prose = line.replace(/(`+).*?\1/g, '');
    for (const match of prose.matchAll(/\]\(\s*(<[^>\n]+>|[^\s)]+)(?:\s+["'][^\n]*?["'])?\s*\)/g)) add(match[1], 'link');
    const definition = prose.match(/^\s{0,3}\[([^\]]+)\]:\s*(<[^>\n]+>|\S+)/);
    if (definition) {
      definitions.add(labelKey(definition[1]));
      add(definition[2], 'link');
    } else {
      for (const match of prose.matchAll(/(?<!\\)\[([^\]\n]+)\]\[([^\]\n]*)\]/g)) {
        usages.push({ ref: match[2] || match[1], line: index + 1, kind: 'undefined-label' });
      }
    }
    for (const match of line.matchAll(/(?<!`)`([^`\n]+)`(?!`)/g)) {
      const ref = match[1];
      if (historical || /^(?:~\/|\.(?:dsh|agents|claude|cursor|codex)\/|\.(?:en\.)?md$)/.test(ref)) continue;
      if (/[\s*|($<>]/.test(ref) || !/(?:\.md(?:#[^\s]*)?|\/)$/i.test(ref)) continue;
      if (/^(?:.*\/)?math_book\/$/.test(ref)) continue; // optional, unpublished source PDFs
      add(ref, 'code');
    }
  }
  refs.push(...usages.filter(({ ref }) => !definitions.has(labelKey(ref))));
  return refs;
}

export function checkReferences(root, file, text) {
  const errors = [];
  for (const { ref, line, kind } of extractLocalReferences(text, { readme: /^README(?:\.en-US)?\.md$/.test(file) })) {
    if (kind === 'undefined-label') { errors.push(`${file}:${line}: undefined reference label [${ref}]`); continue; }
    if (/^(?:[a-z][a-z\d+.-]*:|\/\/|#)/i.test(ref)) continue;
    let pathname;
    try { pathname = decodeURIComponent(ref.split('#')[0].split('?')[0]); }
    catch { errors.push(`${file}:${line}: invalid encoded path ${ref}`); continue; }
    if (!pathname) continue;
    const target = path.resolve(root, path.dirname(file), pathname);
    if (!inside(root, target)) { errors.push(`${file}:${line}: reference escapes repository: ${ref}`); continue; }
    if (!existsSync(target)) errors.push(`${file}:${line}: missing reference ${ref}`);
    else if (!inside(realpathSync(root), realpathSync(target))) errors.push(`${file}:${line}: reference escapes repository via symlink: ${ref}`);
  }
  return errors;
}

export function checkFrontmatter(file, text, expectedName) {
  const errors = [];
  const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
  if (!match) return [`${file}: missing initial YAML frontmatter or closing delimiter`];
  for (const key of ['name', 'description']) {
    const fields = [...match[1].matchAll(new RegExp(`^${key}:[ \\t]*([^\\r\\n]*)`, 'gm'))];
    if (fields.length !== 1 || !fields[0][1].trim()) errors.push(`${file}: frontmatter requires one nonempty ${key}`);
    else {
      const value = fields[0][1].trim();
      if (key === 'name' && !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(value)) {
        errors.push(`${file}: frontmatter name must be a plain kebab-case string`);
      }
      if (key === 'name' && expectedName && value !== expectedName) errors.push(`${file}: frontmatter name must be ${expectedName}`);
      if (/^[|>][-+]?$/.test(value)) {
        const rest = match[1].slice(fields[0].index + fields[0][0].length);
        const block = rest.split(/\r?\n/).slice(1);
        const end = block.findIndex((line) => /^\S/.test(line));
        if (!block.slice(0, end < 0 ? undefined : end).some((line) => /^[ \t]+\S/.test(line))) errors.push(`${file}: empty frontmatter block ${key}`);
      } else if (key === 'description') {
        const quoted = /^(?:"[^"\\]*(?:\\.[^"\\]*)*"|'(?:[^']|'')*')$/.test(value);
        let decoded = value;
        if (quoted) {
          try { decoded = value[0] === '"' ? JSON.parse(value) : value.slice(1, -1).replace(/''/g, "'"); }
          catch { decoded = ''; }
        }
        const numeric = /^[-+]?(?:(?:\d[\d_]*(?:\.[\d_]*)?|\.[\d_]+)(?:e[-+]?\d+)?|0[xob][\da-f_]+|\.(?:inf|nan))$/i.test(value);
        if ((quoted && !decoded.trim()) || (!quoted && (numeric || /^[#\[\]{},&*!|>'"%@`]/.test(value) || /:\s|\s#/.test(value) || /^(?:null|true|false|~)$/i.test(value)))) {
          errors.push(`${file}: description must be a string; use a YAML block scalar for complex text`);
        }
      }
    }
  }
  return errors;
}

function contentSections(file, text) {
  const en = file.endsWith('.en.md');
  const crypto = file.startsWith('knowledge-base/cryptography/');
  const required = en ? ['Minimal Definition', 'Core Formulas', 'Applicable Problems',
    ...(crypto ? ['Cryptographic Construction and Cross-Domain Boundary', 'Implementation Considerations'] : ['AI Design Translation', 'Engineering Feasibility']), 'Risks and Failure Conditions'] :
    ['最小定义', '核心公式', '适用问题', ...(crypto ? ['密码学构造与跨域边界', '实现注意事项'] : ['AI 设计翻译', '工程可行性']), '风险与失效条件'];
  const headings = [...text.matchAll(/^## (.+)\r?$/gm)];
  return required.flatMap((heading) => {
    const found = headings.findIndex((m) => m[1].trim() === heading);
    if (found < 0) return [`${file}: missing required section ${heading}`];
    const start = headings[found].index + headings[found][0].length;
    const end = headings[found + 1]?.index ?? text.length;
    return text.slice(start, end).trim() ? [] : [`${file}: empty required section ${heading}`];
  });
}

function checkDocumentedCounts(file, text, inventory) {
  const errors = [];
  for (const line of text.split(/\r?\n/)) {
    // Count cells associated with explicit inventory globs in architecture tables.
    if (!line.startsWith('|')) continue;
    const cells = line.split('|').map((s) => s.trim());
    for (const [dir, count] of Object.entries(inventory)) {
      if (!line.includes(`\`${dir}/`)) continue;
      const numbers = cells.filter((s) => /^\d+$/.test(s)).map(Number);
      if (numbers.length === 1 && numbers[0] !== count) errors.push(`${file}: ${dir} table says ${numbers[0]}, filesystem has ${count}`);
    }
  }
  return errors;
}


export function checkAnchorIndex(file, text, files) {
  const errors = [];
  for (const domain of DOMAINS) {
    const row = text.split(/\r?\n/).find((line) => line.startsWith('|') && line.includes('`' + domain + '/`'));
    if (!row) { errors.push(`${file}: missing domain inventory row ${domain}`); continue; }
    const cells = row.split('|').map((s) => s.trim());
    const at = cells.findIndex((s) => s === '`' + domain + '/`');
    const listed = (cells[at + 1] || '').split(',').map((s) => s.trim()).sort();
    const actual = files.filter((f) => f.startsWith(`knowledge-base/${domain}/`) && !/(?:\.en\.md|\/index\.md)$/.test(f))
      .map((f) => path.basename(f, '.md')).sort();
    if (JSON.stringify(listed) !== JSON.stringify(actual)) errors.push(`${file}: ${domain} anchor list differs from filesystem inventory`);
  }
  return errors;
}

export function validateContent(root) {
  const errors = [];
  const documents = new Map();
  const files = [];
  for (const dir of CONTENT_DIRS) {
    try { files.push(...walkMarkdown(root, dir)); } catch (err) { errors.push(err.message); }
  }
  errors.push(...checkPairs(files));
  const roots = ['README.md', 'README.en-US.md', 'SKILL.md', 'SKILL.en.md'];
  try { roots.push(...walkMarkdown(root, 'tests/eval')); } catch (err) { errors.push(err.message); }
  for (const file of [...files, ...roots]) {
    try {
      const text = readFileSync(path.join(root, file), 'utf8');
      if (!text.trim()) errors.push(`${file}: empty document`);
      documents.set(file, text);
      errors.push(...checkReferences(root, file, text));
    } catch (err) { errors.push(`${file}: ${err.message}`); }
  }
  for (const file of ['SKILL.md', 'SKILL.en.md', 'skills/math-research-activator/SKILL.md', 'skills/math-research-activator/SKILL.en.md', 'commands/ask.md', 'commands/ask.en.md']) {
    errors.push(...checkFrontmatter(file, documents.get(file) || '', file.startsWith('commands/') ? 'ask' : 'math-research-activator'));
  }
  const required = [
    ...LENSES.flatMap((name) => [`lenses/${name}.md`, `lenses/${name}.en.md`]),
    ...DOMAINS.flatMap((name) => [`knowledge-base/${name}/index.md`, `knowledge-base/${name}/index.en.md`]),
    'knowledge-base/overview.md', 'knowledge-base/overview.en.md', 'design-patterns/overview.md', 'design-patterns/overview.en.md',
    'references/gpu-friendly-math.md', 'references/gpu-friendly-math.en.md', 'references/skill-index.md', 'references/skill-index.en.md',
    'agents/math-critic.md', 'agents/math-critic.en.md',
  ];
  for (const file of required) if (!documents.has(file)) errors.push(`missing required resource: ${file}`);
  for (const component of COMPONENTS) if (!files.some((f) => f.startsWith(`design-patterns/${component}/`))) errors.push(`empty design component: ${component}`);
  if (files.filter((f) => f.startsWith('commands/')).some((f) => !/^commands\/ask(?:\.en)?\.md$/.test(f))) errors.push('commands/ must only contain the bilingual ask entry');
  const counts = {};
  for (const [dir, expected] of Object.entries(EXPECTED)) {
    const entries = files.filter((file) => file.startsWith(`${dir}/`) && !/(?:\.en\.md|\/(?:index|overview)\.md)$/.test(file));
    counts[dir] = entries.length;
    if (entries.length !== expected) errors.push(`${dir}: expected ${expected} entries, found ${entries.length}; update release inventory deliberately when adding/removing content`);
  }
  for (const file of ['knowledge-base/overview.md', 'knowledge-base/overview.en.md']) {
    errors.push(...checkAnchorIndex(file, documents.get(file) || '', files));
  }
  for (const [file, text] of documents) {
    errors.push(...checkDocumentedCounts(file, text, counts));
    if (file.startsWith('knowledge-base/') && !/\/(?:index|overview)(?:\.en)?\.md$/.test(file)) errors.push(...contentSections(file, text));
    if (file.startsWith('design-patterns/') && !/\/overview(?:\.en)?\.md$/.test(file)) {
      const section = text.match(/^## (?:GPU 可行性|GPU Feasibility)[^\n]*\r?\n([\s\S]*?)(?=^## |$(?![\s\S]))/m);
      if (!section || !/O\(|FLOPs|[Bb]ytes|显存|[Mm]emory|复杂度|[Cc]omplexity|[Cc]ost|[Cc]omput|[Bb]andwidth|计算|开销|带宽|成本|存储/.test(section[1])) errors.push(`${file}: GPU section needs a cost/memory discussion`);
      if (!/\[(?:v|~|x)\]/.test(text)) errors.push(`${file}: missing rigor annotation [v]/[~]/[x]`);
    }
  }
  return { errors, counts, files: [...documents.keys()] };
}

export function checkPack(result, expectedFiles) {
  if (!Array.isArray(result) || result.length !== 1 || !Array.isArray(result[0]?.files)) return ['npm pack returned an invalid file manifest'];
  const paths = new Set(result[0].files.map((entry) => entry.path));
  const errors = [];
  for (const file of expectedFiles) if (!paths.has(file)) errors.push(`npm package missing ${file}`);
  for (const file of paths) {
    if (typeof file !== 'string' || /^(?:math_book|skills|tests|\.git|\.npm-cache)\//.test(file) || /\.pdf$/i.test(file)) errors.push(`npm package contains excluded path ${String(file)}`);
  }
  return errors;
}
