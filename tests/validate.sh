#!/usr/bin/env bash
# One implementation across platforms; anchor paths to this script, not cwd.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec node "$SCRIPT_DIR/validate.mjs" "$@"
