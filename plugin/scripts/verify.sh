#!/usr/bin/env bash
# The factory's definition of "checks pass": run whichever of these package.json scripts exist,
# in order, stopping at the first failure. Used by Claude (via the plugin), by `factory run`,
# and by the generic CI workflow, so all three agree.
set -euo pipefail
cd "${1:-.}"
if [ ! -f package.json ]; then echo "verify: no package.json, nothing to check"; exit 0; fi
if [ ! -d node_modules ]; then
  if [ -f package-lock.json ]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi
fi
ran=0
for s in typecheck check lint test build; do
  if node -e "process.exit(require('./package.json').scripts?.['$s'] ? 0 : 1)"; then
    echo "verify: npm run $s"
    npm run "$s"
    ran=$((ran + 1))
  fi
done
echo "verify: ok ($ran scripts)"
