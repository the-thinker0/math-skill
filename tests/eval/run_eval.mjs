#!/usr/bin/env node
// Tier 1: static expectations, not a claim about real agent behavior.
import { validateSuite } from './eval-lib.mjs';

try {
  const { cases, errors } = validateSuite();
  for (const message of errors) console.error(`[FAIL] ${message}`);
  const counts = (key) => [...new Set(cases.map((c) => c[key]))].sort()
    .map((value) => `${value}:${cases.filter((c) => c[key] === value).length}`).join(' ');
  console.log(`eval manifest: ${cases.length} cases | scenarios ${counts('scenario')} | domains ${counts('domain')}`);
  if (errors.length) process.exitCode = 1;
  else console.log('eval static checks passed: schema, paper parity, artifact containment and domain isolation');
} catch (err) {
  console.error(`[FAIL] ${err.message}`);
  process.exitCode = 1;
}
