#!/usr/bin/env bash
# Runs the factory's GitHub workflows locally with `act` (needs Docker) against a copy of a project,
# with claude-code-action replaced by a stub that checks what it would be handed: the prompt,
# the mode, the plugin, and the allowlist. Nothing is pushed anywhere.
#
#   tests/gha.sh <project dir> [ci workflow name]
#
# What it changes for the test (and only for the test):
#   - callers use the reusable workflows from this checkout instead of tonyjmartinez/...@main
#   - "Load the factory plugin" copies this checkout instead of cloning it from GitHub
#   - project setup is skipped (dependencies don't matter to the stub)
#   - fix-ci checks out the copy's HEAD (already the claude/* branch) instead of the event's ref
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
FACTORY="$(cd "$HERE/.." && pwd)"
SRC="$(cd "${1:?usage: tests/gha.sh <project dir> [ci workflow name]}" && pwd)"
CI_NAME="${2:-CI}"
ACT="${ACT:-act}"
command -v "$ACT" >/dev/null || ACT="$HOME/go/bin/act"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp -a "$SRC" "$WORK/repo"
rm -rf "$WORK/repo/node_modules"
cd "$WORK/repo"
git remote | xargs -r -n1 git remote remove
# act derives github.repository from origin; the push URL is invalid so nothing can be pushed.
git remote add origin https://github.com/tonyjmartinez/succulents.info
git remote set-url --push origin no-push://disabled
mkdir -p .github/workflows

# Reusable workflows, loading the plugin from a mounted copy of this checkout.
for f in claude claude-fix-ci claude-review ci-node; do
  python3 - "$FACTORY/.github/workflows/$f.yml" ".github/workflows/factory-$f.yml" <<'PY'
import re, sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src).read()
s = re.sub(
    r"      - name: Load the factory (plugin|scripts)\n(        if: .*\n)?        uses: actions/checkout@v6\n        with:\n(          .*\n)+?          persist-credentials: false\n",
    lambda m: f"      - name: Load the factory {m.group(1)} from local checkout\n{m.group(2) or ''}        run: cp -a /factory-src .factory\n",
    s,
)
# act only fakes actions/checkout for the current commit; the copy's HEAD is already the branch.
s = s.replace("          ref: ${{ github.event.workflow_run.head_branch }}\n", "")
open(dst, "w").write(s)
PY
done

sed -e "s|__CI_WORKFLOW__|$CI_NAME|" -e 's|__SETUP__|echo setup skipped in test|' \
    -e 's|tonyjmartinez/tone-zone-software-factory/.github/workflows/\([a-z-]*\).yml@main|./.github/workflows/factory-\1.yml|' \
    "$FACTORY/templates/workflows/factory.yml" > .github/workflows/factory.yml

git add -A >/dev/null
git -c user.name=t -c user.email=t@t commit -qm "test: factory wiring" --no-verify
git branch -f claude/finder-tweak >/dev/null

# Behind a TLS-inspecting proxy (like Claude Code cloud sessions), let the job containers trust it.
CA_MOUNT="" CA_ENV=""
if [ -n "${NODE_EXTRA_CA_CERTS:-}" ] && [ -f "$NODE_EXTRA_CA_CERTS" ]; then
  CA_MOUNT="-v $NODE_EXTRA_CA_CERTS:/etc/factory-ca.crt:ro"
  CA_ENV="--env NODE_EXTRA_CA_CERTS=/etc/factory-ca.crt --env GIT_SSL_CAINFO=/etc/factory-ca.crt"
fi

fails=0
# expect: "agent:<prompt prefix>" | "tag" | "skip" | "fix:<prompt prefix>"
run_case() {
  local event="$1" file="$2" expect="$3" log="$WORK/$2.log" payload="$WORK/$2.json"
  # workflow_run events name the CI workflow that finished; the caller filters on it.
  CI_NAME="$CI_NAME" node -e 'const e = require(process.argv[1]); if (e.workflow_run) { e.workflow_run.name = process.env.CI_NAME; e.workflow = { name: process.env.CI_NAME }; } console.log(JSON.stringify(e))' \
    "$HERE/gha/events/$file.json" > "$payload"
  # The session's GITHUB_TOKEN only works through its proxy; act would send it to GitHub directly.
  env -u GITHUB_TOKEN -u GH_TOKEN "$ACT" "$event" -e "$payload" -W .github/workflows/factory.yml \
    -P ubuntu-latest=catthehacker/ubuntu:act-latest --pull=false \
    --local-repository "anthropics/claude-code-action@v1=$HERE/gha/stub-claude-action" \
    --container-options "-v $FACTORY:/factory-src:ro $CA_MOUNT" $CA_ENV \
    -s CLAUDE_CODE_OAUTH_TOKEN=test >"$log" 2>&1 || true
  local got
  if grep -q "^Error:" "$log"; then got="act-error: $(grep -m1 '^Error:' "$log")"
  elif grep -q "| STUB FAIL" "$log"; then got="stub-fail: $(grep -m1 "| STUB FAIL" "$log" | sed 's/.*STUB FAIL: //')"
  elif grep -q "| STUB OK" "$log"; then
    local mode prompt
    mode=$(grep -m1 "| STUB mode=" "$log" | sed 's/.*STUB mode=//')
    prompt=$(grep -m1 "| STUB prompt=" "$log" | sed 's/.*STUB prompt=\[\(.*\)\]/\1/')
    got="$mode${prompt:+:$prompt}"
  elif grep -q "Job failed\|🏁  Job failed\|exitcode '[1-9]" "$log"; then got="job-failed"
  else got="skip"
  fi
  if [[ "$got" == $expect* ]]; then echo "ok    $file -> $got"
  else echo "FAIL  $file -> got [$got], want [$expect]  (log: $log)"; fails=$((fails + 1)); trap - EXIT; fi
}

run_case issues        issue-labeled-claude   "agent:/factory:implement ship #7"
run_case issues        issue-opened-mention   "agent:/factory:implement ship #9"
run_case issues        issue-labeled-bug      "skip"
run_case issue_comment pr-comment-mention     "tag"
run_case issue_comment pr-comment-plain       "skip"
run_case workflow_run  run-failure-fix        "agent:/factory:fix-ci ship"
run_case workflow_run  run-failure-main       "skip"
run_case workflow_run  run-success-ok         "skip"

# Budget: after 3 fix attempts on a branch, fix-ci stands down.
for i in 1 2 3; do git -c user.name=t -c user.email=t@t commit -q --allow-empty -m "attempt $i [factory-fix-ci]"; done
git branch -f claude/finder-tweak >/dev/null
run_case workflow_run  run-failure-fix        "skip"
if grep -q "CI fix budget spent (3/3)" "$WORK/run-failure-fix.log"; then echo "ok    budget warning printed"
else echo "FAIL  budget warning missing"; fails=$((fails + 1)); fi

# Generic CI (installed for projects without their own): runs verify.sh for real in the container.
if [ "${GHA_SKIP_CI:-}" != 1 ]; then
  sed -e 's|tonyjmartinez/tone-zone-software-factory/.github/workflows/ci-node.yml@main|./.github/workflows/factory-ci-node.yml|' \
    "$FACTORY/templates/workflows/ci.yml" > .github/workflows/ci.yml
  git add -A >/dev/null && git -c user.name=t -c user.email=t@t commit -qm "test: ci" --no-verify
  env -u GITHUB_TOKEN -u GH_TOKEN "$ACT" push -W .github/workflows/ci.yml \
    -P ubuntu-latest=catthehacker/ubuntu:act-latest --pull=false \
    --container-options "-v $FACTORY:/factory-src:ro $CA_MOUNT" $CA_ENV >"$WORK/ci.log" 2>&1 || true
  if grep -q "verify: ok" "$WORK/ci.log" && grep -q "Job succeeded" "$WORK/ci.log"; then
    echo "ok    generic CI -> $(grep -m1 -o 'verify: ok ([0-9]* scripts)' "$WORK/ci.log")"
  else echo "FAIL  generic CI (log: $WORK/ci.log)"; fails=$((fails + 1)); trap - EXIT; fi
fi

[ "$fails" -eq 0 ] && echo "gha: all cases pass" || { echo "gha: $fails failing (work dir kept: $WORK)"; exit 1; }
