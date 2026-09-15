// File-backed capture works in restricted runtimes where Node pipe setup fails.
// All temporary output stays inside the repository and is removed after use.
import { mkdtempSync, openSync, closeSync, readFileSync, statSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';

export function runCaptured(command, args, { cwd, maxBuffer = 16 * 1024 * 1024, ...options }) {
  const dir = mkdtempSync(path.join(cwd, '.eval-output-'));
  const stdoutPath = path.join(dir, 'stdout');
  const stderrPath = path.join(dir, 'stderr');
  const descriptors = [];
  try {
    descriptors.push(openSync(stdoutPath, 'w', 0o600));
    descriptors.push(openSync(stderrPath, 'w', 0o600));
    const result = spawnSync(command, args, { ...options, cwd, shell: false, stdio: ['ignore', ...descriptors] });
    if (statSync(stdoutPath).size + statSync(stderrPath).size > maxBuffer) {
      return { ...result, error: result.error || new Error(`runtime output exceeds ${maxBuffer} bytes`), stdout: '', stderr: '' };
    }
    return { ...result, stdout: readFileSync(stdoutPath, 'utf8'), stderr: readFileSync(stderrPath, 'utf8') };
  } finally {
    for (const descriptor of descriptors) closeSync(descriptor);
    rmSync(dir, { recursive: true, force: true });
  }
}
