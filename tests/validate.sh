#!/usr/bin/env bash
# The factory's one gate: run it before every PR (CI runs it too). Fails closed.
#   tests/validate.sh
# Last line is the verdict to quote: VALIDATE: PASS | VALIDATE: FAIL <step> | VALIDATE: MISCONFIGURED <tool>
# Optional: VALIDATE_GHA_PROJECT=<checkout> [VALIDATE_GHA_CI=<name>] also runs tests/gha.sh (needs Docker).
set -uo pipefail
cd "$(dirname "$0")/.."

need() {
  command -v "$1" >/dev/null && return 0
  [ "$1" = actionlint ] && [ -x "$HOME/go/bin/actionlint" ] && return 0
  echo "missing tool: $1 ($2)"
  echo "VALIDATE: MISCONFIGURED $1"
  exit 2
}
need bash "it runs everything"
need node "Node 22+"
need git "git"
need actionlint "go install github.com/rhysd/actionlint/cmd/actionlint@latest"
ACTIONLINT=$(command -v actionlint || echo "$HOME/go/bin/actionlint")
LOG=$(mktemp); trap 'rm -f "$LOG"' EXIT

step() {
  local name="$1"; shift
  if "$@" >"$LOG" 2>&1; then
    echo "ok    $name"
  else
    echo "FAIL  $name"; sed 's/^/      /' "$LOG" | tail -20
    echo "VALIDATE: FAIL $name"
    exit 1
  fi
}

syntax() {
  for f in bin/factory plugin/scripts/*.sh templates/claude/hooks/*.sh tests/*.sh; do bash -n "$f" || return 1; done
  node --check bin/lib/*.mjs plugin/scripts/*.mjs
}

json() {
  for f in .claude-plugin/marketplace.json plugin/.claude-plugin/plugin.json templates/claude/settings.json; do
    node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" || { echo "bad JSON: $f"; return 1; }
  done
}

# The project caller templates, rendered the way `factory install` writes them.
templates() {
  local dir; dir=$(mktemp -d)
  mkdir -p "$dir/.github/workflows"
  sed -e 's/__CI_WORKFLOW__/CI/' -e 's/__SETUP__/npm ci/' templates/workflows/factory.yml > "$dir/.github/workflows/factory.yml"
  cp templates/workflows/ci.yml "$dir/.github/workflows/ci.yml"
  (cd "$dir" && git init -q && "$ACTIONLINT")
  local rc=$?; rm -rf "$dir"; return $rc
}

# Every registered project resolves and its routine exists.
projects() {
  local list; list=$(bin/factory nightly-projects) || return 1
  node -e 'JSON.parse(process.argv[1])' "$list" || return 1
  for p in projects/*/project.env; do
    ( set -e; . "$p"; [ -n "$REPO" ]; [ -z "${NIGHTLY:-}" ] || [ -f "routines/$NIGHTLY.md" ] ) || { echo "bad: $p"; return 1; }
  done
}

step "script syntax" syntax
step "JSON files" json
step "permission guard (tests/guard.sh)" tests/guard.sh
step "actionlint: factory workflows" "$ACTIONLINT" .github/workflows/*.yml
step "actionlint: rendered project templates" templates
step "registered projects and routines" projects

if [ -n "${VALIDATE_GHA_PROJECT:-}" ]; then
  if docker info >/dev/null 2>&1; then
    step "workflows under act (tests/gha.sh)" tests/gha.sh "$VALIDATE_GHA_PROJECT" "${VALIDATE_GHA_CI:-CI}"
  else
    echo "SKIPPED workflows under act: Docker isn't running"
  fi
else
  echo "SKIPPED workflows under act: set VALIDATE_GHA_PROJECT=<project checkout> to include it"
fi

echo "VALIDATE: PASS"
