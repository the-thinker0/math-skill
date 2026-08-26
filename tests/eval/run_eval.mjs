#!/usr/bin/env node
// math-skill eval automation runner (v3.3.7)
//
// Deterministic, zero-dependency checks over tests/eval/cases.jsonl:
//   1. Schema validation of every manifest case.
//   2. Cross-field consistency (trigger / scenario / domain / lang).
//   3. Bidirectional parity between the human-readable paper files (*.md)
//      and the machine manifest (cases.jsonl) — prevents the two from drifting.
//   4. Existence check for every declared may_load artifact.
//   5. Domain Router isolation policy as static assertions:
//        pure AI        must not touch cryptography anchors/books,
//        pure crypto    must not touch AI design patterns or the GPU gate doc,
//        scenario E     must declare nothing loadable and trigger=false.
//
// Exit code 0 = all green; 1 = at least one failure. Called by
// `npm run eval` and by tests/validate.sh / validate.ps1.

import { readFileSync, existsSync, statSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const MANIFEST = path.join(ROOT, 'tests', 'eval', 'cases.jsonl');

const SOURCES = [
  'should-trigger-analysis.md',
  'should-trigger-design.md',
  'should-trigger-knowledge.md',
  'should-trigger-verification.md',
  'should-not-trigger.md',
  'cross-domain-routing.md',
  'domain-router-isolation.md',
  'knowledge-gap-protocol.md',
  'mixed-language-routing.md',
];

const SCENARIOS = ['A', 'B', 'C', 'D', 'E'];
const DOMAINS = ['ai', 'crypto', 'ai-crypto', 'shared', 'none'];

// Domain Router rule 4 ("no pollution when not cross-domain"), as static policy.
const FORBIDDEN_FOR_AI = [
  'knowledge-base/cryptography/',
  'references/books/applied-cryptography',
  'references/books/foundations-of-cryptography',
  'references/books/introduction-to-modern-cryptography',
];
const FORBIDDEN_FOR_CRYPTO = [
  'design-patterns/',
  'references/gpu-friendly-math',
];

let failures = 0;
let checks = 0;
function fail(msg) {
  failures += 1;
  console.error(`[FAIL] ${msg}`);
}
function ok() {
  checks += 1;
}

// ---------- 1+2. Load manifest & validate schema/consistency ----------

function loadManifest() {
  const text = readFileSync(MANIFEST, 'utf8');
  const lines = text.split(/\r?\n/).filter((l) => l.trim() && !l.trim().startsWith('//'));
  const cases = [];
  const ids = new Set();
  for (let i = 0; i < lines.length; i++) {
    let obj;
    try {
      obj = JSON.parse(lines[i]);
    } catch (e) {
      fail(`cases.jsonl line ${i + 1}: invalid JSON (${e.message})`);
      continue;
    }
    const where = `case ${obj.id || `line ${i + 1}`}`;
    for (const field of ['id', 'source', 'prompt', 'lang', 'scenario', 'domain']) {
      if (typeof obj[field] !== 'string' || obj[field] === '') fail(`${where}: missing field '${field}'`);
    }
    if (ids.has(obj.id)) fail(`${where}: duplicate id`);
    ids.add(obj.id);
    if (!SOURCES.includes(obj.source)) fail(`${where}: unknown source '${obj.source}'`);
    if (!SCENARIOS.includes(obj.scenario)) fail(`${where}: scenario must be one of ${SCENARIOS.join('/')}`);
    if (!DOMAINS.includes(obj.domain)) fail(`${where}: domain must be one of ${DOMAINS.join('/')}`);
    if (typeof obj.trigger !== 'boolean') fail(`${where}: 'trigger' must be boolean`);
    if (!Array.isArray(obj.may_load)) obj.may_load = [];

    // Cross-field consistency.
    if (obj.trigger === false && (obj.scenario !== 'E' || obj.domain !== 'none')) {
      fail(`${where}: trigger=false requires scenario E + domain none`);
    }
    if (obj.trigger === true && obj.scenario === 'E') {
      fail(`${where}: trigger=true cannot have scenario E`);
    }
    if (obj.lang === 'zh' && !/\p{Script=Han}/u.test(obj.prompt)) {
      fail(`${where}: lang=zh but prompt has no Han characters`);
    }
    cases.push(obj);
  }
  return cases;
}

// ---------- 3. Parity: paper files <-> manifest ----------

const QUOTE_OPEN = { '"': '"', '\u201c': '\u201d', '\u300c': '\u300d' };
function norm(s) {
  return s.replace(/[\s\u3000]+/g, ' ').trim();
}

// Extract candidate prompt strings from a paper file. Only sections whose
// heading starts with "Test Cases" / "Should ..." / "Edge case" are scanned
// (this excludes decoy numbered lists such as the cross-domain 4-tuple
// example). Within those sections, a line qualifies iff it is numbered
// ("N. ...", excluding protocol decision items that start with '**') or a
// bullet whose payload opens with a quotation mark. Arrow annotations
// ("... → loads ...") are cut first, then surrounding quotes are stripped.
function extractPrompts(text) {
  const out = [];
  let inPromptSection = false;
  for (const raw of text.split(/\r?\n/)) {
    const h = raw.match(/^#{1,6}\s+(.*)$/);
    if (h) {
      inPromptSection = /^(test cases|should |edge case)/i.test(h[1].trim());
      continue;
    }
    if (!inPromptSection) continue;
    const m = raw.match(/^\s*(\d+\.\s|-\s)(.*)$/);
    if (!m) continue;
    const isBullet = m[1].startsWith('-');
    let p = m[2].trim();
    if (p.startsWith('**')) continue; // e.g. Knowledge Gap six-decision items
    if (isBullet && !(p[0] in QUOTE_OPEN)) continue; // prose bullets like "- Test 3: ..."
    const arrow = p.indexOf(' \u2192 '); // " → "
    if (arrow >= 0) p = p.slice(0, arrow);
    if (p[0] in QUOTE_OPEN) {
      const closeIdx = p.indexOf(QUOTE_OPEN[p[0]], 1);
      if (closeIdx > 0) p = p.slice(1, closeIdx);
    }
    const t = norm(p);
    if (t) out.push(t);
  }
  return out;
}

function multisetDiff(extracted, manifested) {
  const count = (arr) => {
    const m = new Map();
    for (const s of arr) m.set(s, (m.get(s) || 0) + 1);
    return m;
  };
  const a = count(extracted);
  const b = count(manifested);
  const missing = []; // in paper file but not in manifest
  for (const [s, n] of a) {
    if ((b.get(s) || 0) < n) missing.push(s);
  }
  const extra = []; // in manifest but not in paper file
  for (const [s, n] of b) {
    if ((a.get(s) || 0) < n) extra.push(s);
  }
  return { missing, extra };
}

function checkParity(cases) {
  for (const src of SOURCES) {
    const file = path.join(ROOT, 'tests', 'eval', src);
    if (!existsSync(file)) {
      fail(`paper file missing: tests/eval/${src}`);
      continue;
    }
    const extracted = extractPrompts(readFileSync(file, 'utf8'));
    const manifested = cases.filter((c) => c.source === src).map((c) => norm(c.prompt));
    if (extracted.length === 0) {
      fail(`parity extractor found no prompts in tests/eval/${src} (extractor or file broken)`);
      continue;
    }
    const { missing, extra } = multisetDiff(extracted, manifested);
    for (const s of missing) fail(`tests/eval/${src}: prompt not in cases.jsonl -> "${s}"`);
    for (const s of extra) fail(`tests/eval/${src}: cases.jsonl prompt not found in paper file -> "${s}"`);
    if (missing.length === 0 && extra.length === 0) ok();
  }
}

// ---------- 4+5. Artifact existence & isolation policy ----------

function checkArtifactsAndPolicy(cases) {
  for (const c of cases) {
    const where = `case ${c.id}`;
    c.may_load.forEach((rel, idx) => {
      const abs = path.join(ROOT, rel);
      let exists = false;
      try {
        exists = existsSync(abs) && (statSync(abs).isFile() || statSync(abs).isDirectory());
      } catch { /* fall through */ }
      if (!exists) fail(`${where}: may_load[${idx}] does not exist: ${rel}`);
    });
    if (c.may_load.length > 0) ok();

    if (c.domain === 'none' && c.may_load.length > 0) {
      fail(`${where}: scenario E must declare no loadable artifacts`);
    }
    const forbidden =
      c.domain === 'ai' ? FORBIDDEN_FOR_AI :
      c.domain === 'crypto' ? FORBIDDEN_FOR_CRYPTO :
      null;
    if (forbidden) {
      for (const rel of c.may_load) {
        for (const bad of forbidden) {
          if (rel.startsWith(bad) || rel.includes('/' + bad)) {
            fail(`${where}: isolation violation - domain=${c.domain} declares '${rel}' (matches forbidden '${bad}')`);
          }
        }
      }
      ok();
    }
  }
}

// ---------- main ----------

const cases = loadManifest();
if (cases.length < 60) fail(`manifest too small: ${cases.length} cases (expected >=60); possible truncation`);
checkParity(cases);
checkArtifactsAndPolicy(cases);

// Coverage summary.
const byScenario = {};
const byDomain = {};
for (const c of cases) {
  byScenario[c.scenario] = (byScenario[c.scenario] || 0) + 1;
  byDomain[c.domain] = (byDomain[c.domain] || 0) + 1;
}
console.log(
  `eval manifest: ${cases.length} cases | scenarios ` +
  Object.keys(byScenario).sort().map((k) => `${k}:${byScenario[k]}`).join(' ') +
  ' | domains ' +
  Object.keys(byDomain).sort().map((k) => `${k}:${byDomain[k]}`).join(' ')
);

if (failures > 0) {
  console.error(`eval automation: ${failures} failure(s), ${checks} passing group(s)`);
  process.exit(1);
}
console.log(`eval automation: all parity/schema/isolation checks passed (${checks} groups)`);
