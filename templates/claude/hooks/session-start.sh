#!/usr/bin/env bash
# Installed by tone-zone-software-factory. In Claude Code cloud sessions (web, mobile app,
# scheduled tasks), install dependencies up front so Claude can test and build right away.
set -euo pipefail
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0
cd "${CLAUDE_PROJECT_DIR:-.}"
[ -f package.json ] || exit 0
if [ -f package-lock.json ]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi
