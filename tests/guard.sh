#!/usr/bin/env bash
# Unit test for bin/lib/guard.mjs: the local permission guard must allow and deny what GitHub Actions would.
set -u; fails=0
G="$(dirname "$0")/../bin/lib/guard.mjs"
C="$(dirname "$0")/../plugin/commands/implement.md"
t() { want=$1; shift; printf '%s' "$1" | node $G $C 2>/dev/null; got=$([ $? -eq 0 ] && echo allow || echo deny); [ $got = $want ] && echo "ok   $want  $1" || { fails=$((fails+1)); echo "FAIL want=$want got=$got  $1"; }; }
j() { node -e 'console.log(JSON.stringify({tool_name:process.argv[1],tool_input:process.argv[2]?{command:process.argv[2]}:{}}))' "$@"; }
t allow "$(j Bash 'npm run build')"
t allow "$(j Bash 'cd src && grep -n "wrap\|card" styles/*.css | head -30')"
t allow "$(j Bash 'npm run build 2>&1 | tail -20')"
t allow "$(j Bash 'npx vitest run > /dev/null')"
t allow "$(j Bash 'bash "/x/plugin/scripts/verify.sh"')"
t allow "$(j Bash 'git status --short')"
t allow "$(j Bash 'gh issue view 7 --comments')"
t allow "$(j Edit)"
t allow "$(j Read)"
t deny  "$(j Bash "python3 - <<'E'
open('a','w').write('x')
E")"
t deny  "$(j Bash "cat > src/a.ts <<'EOF'
x
EOF")"
t deny  "$(j Bash "sed -i 's/a/b/' f.ts")"
t deny  "$(j Bash 'echo hi > notes.txt')"
t deny  "$(j Bash 'curl https://example.com')"
t deny  "$(j Bash 'gh pr merge 3')"
t deny  "$(j WebFetch)"
[ "$fails" -eq 0 ] && echo "guard: all cases pass" || { echo "guard: $fails failing"; exit 1; }
