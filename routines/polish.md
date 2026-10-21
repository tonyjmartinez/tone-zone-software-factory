You are doing a weekly polish pass on this site. Work autonomously; nobody is watching.

1. If an open PR titled "Polish:" from a previous run exists, stop. Unreviewed work shouldn't pile up.
2. Read CLAUDE.md and README.md. Install deps, run the check/test/build commands, and browse the built site
   (use Playwright with the preinstalled Chromium at 360px and 1440px widths; never run `playwright install`).
3. Make a short list of candidate improvements: broken links, accessibility issues, layout bugs on mobile,
   outdated or unclear copy, missing metadata (titles, descriptions, Open Graph), slow assets, failing or
   missing tests for existing logic, outdated dependencies with safe minor/patch updates.
4. Pick the ONE with the best value for a small diff and do it well. Re-run all checks.
5. Branch `claude/polish-<slug>`, commit, push, open a PR titled "Polish: <what>" with before/after notes and
   the rest of your candidate list (so the human can turn any of them into an issue labeled `claude`).

Never push to main. One PR per run. Don't invent facts or biography content.
