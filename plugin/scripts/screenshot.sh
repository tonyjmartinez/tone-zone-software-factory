#!/usr/bin/env bash
# Screenshot built pages at phone (360px) and desktop (1440px) widths so Claude can look at them.
#   screenshot.sh [page path ...]      e.g. screenshot.sh / /plants/
# Serves ./dist (override with SITE_DIR); prints the PNG paths. Run the build first.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="${SITE_DIR:-dist}"
OUT="${SHOT_DIR:-${TMPDIR:-/tmp}/factory-shots}"
PW="playwright@${PLAYWRIGHT_VERSION:-1.56.1}"
PORT="${SHOT_PORT:-4599}"
[ -d "$SITE_DIR" ] || { echo "screenshot: no $SITE_DIR/ (run the build first, or set SITE_DIR)"; exit 1; }
[ $# -gt 0 ] || set -- /
mkdir -p "$OUT"

# GitHub runners don't ship a browser; install one the first time (about a minute).
if [ -n "${GITHUB_ACTIONS:-}" ] && [ ! -f "$OUT/.browser-ready" ]; then
  npx -y "$PW" install --with-deps chromium >/dev/null 2>&1 && touch "$OUT/.browser-ready"
fi

node "$ROOT/serve.mjs" "$SITE_DIR" "$PORT" & server=$!
trap 'kill $server 2>/dev/null' EXIT
for _ in $(seq 50); do curl -s -o /dev/null "http://127.0.0.1:$PORT/" && break; sleep 0.1; done

for page in "$@"; do
  slug=$(printf '%s' "$page" | tr -c 'a-zA-Z0-9' '-' | sed 's/^-*//; s/-*$//'); slug=${slug:-home}
  for size in "360,800" "1440,900"; do
    file="$OUT/${slug}-${size%%,*}.png"
    npx -y "$PW" screenshot --full-page --viewport-size="$size" "http://127.0.0.1:$PORT$page" "$file" >/dev/null 2>&1 \
      || { echo "screenshot: failed for $page at ${size%%,*}px"; continue; }
    echo "$file"
  done
done
