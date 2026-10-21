# Factory backlog

The overnight builder ([`routines/factory-nightly.md`](routines/factory-nightly.md)) takes the **first unchecked
item**, builds it on the `claude/factory-nightly` branch, proves it works, ticks it here, and moves on. Reorder,
edit or delete items freely; this file is the steering wheel.
Background: [`docs/research/kent-c-dodds-factory-handoff.md`](docs/research/kent-c-dodds-factory-handoff.md).

**Defaults until Tony decides otherwise** (see [`docs/decisions/`](docs/decisions/)):
- Build on stock Claude Code; Kody is not adopted.
- No auto-merge: a human merges everything.
- Reports go to the PR (a comment), not to Discord or Slack.

**To pause the nightly builder**, create a file named `NIGHTLY_PAUSED` at the repo root on `claude/factory-nightly`.

## Now

- [ ] **Router CLAUDE.md for this repo**:
  - Write a thin ~20-line `CLAUDE.md` that names the one validate command (next item) and links to `README.md`,
    `docs/principles/`, `docs/decisions/` and `BACKLOG.md`.
  - Add `docs/principles/` with 4–6 one-page principles taken from the handoff §2d that fit this repo: one source of
    truth, fail closed, examples over prose, lean agent context, test the workflow, delete what's off the common path.
- [ ] **Single fail-closed gate**: add `tests/validate.sh` (and `npm run validate` only if a package.json is added) that:
  - runs `tests/guard.sh`, actionlint on `.github/workflows` and the rendered templates, `bash -n` on every script,
    and `node --check` on every `.mjs`;
  - runs `tests/gha.sh` only when Docker is available, and otherwise prints a clear SKIPPED line;
  - prints one verdict line, `VALIDATE: PASS` or `VALIDATE: FAIL <step>`;
  - fails closed when a tool is missing: exit 2 with `MISCONFIGURED`.

  Install actionlint with `go install github.com/rhysd/actionlint/cmd/actionlint@latest` if it's missing.
- [ ] **ADRs**: add `docs/decisions/` with short ADRs:
  - 0001: the agent is a Claude Code plugin, and every entry point runs the same command files;
  - 0002: no auto-merge yet, with the risk tiers we'd use if Tony grants merge authority later;
  - 0003: stock Claude Code over Kody for now, and what would change that.

  Mark each one "Status: proposed (Tony to accept)".
- [ ] **Friction loop**, following Kent's friction-log:
  - Add `plugin/commands/friction.md` (`/factory:friction`). It files a GitHub issue labeled `friction`, deduped by
    title, only for durable, recurring, clear-owner, reproducible gaps, with a short preliminary investigation and
    relevant files, and never an invented root cause.
  - Make `/factory:implement` end by deciding whether anything qualifies, and filing it only in `ship` mode.
  - Have `factory install` create the `friction` and `friction-skipped` labels.
  - Add `routines/friction-sweep.md`: at most one issue per day; close it if already fixed, ship a fix via
    `/factory:implement ship`, or comment a recommendation and add `friction-skipped`.
  - Extend `tests/guard.sh` for any new allowed-tools.
- [ ] **System recap in every PR**: in `/factory:implement`'s report, add a `## System recap` section that classifies
  each change as **composes** (uses existing primitives), **extends** (changes an existing primitive) or **adds**
  (new primitive). Add a risk tier (low/medium/high) with a one-line reason. Keep it short.
- [ ] **Verifier subagent**: add `plugin/agents/verifier.md`. It reads only the diff and CLAUDE.md, not the
  implementer's report. For each new or changed test, it temporarily reverts the code change and confirms the test
  fails, then restores the change. It reports `VERIFIER: confirmed` or `VERIFIER: unproven <why>`. Have
  `/factory:implement` call it before finishing when tests changed. Test it locally with `bin/factory run`.
- [ ] **ship-pr tick** (Kent's progressive tick):
  - Add `bin/lib/ship-pr-tick.mjs <owner/repo> <pr>`. It uses `gh` to print a short checklist (ready → ci →
    review → merge-policy → friction → report), what's done, and detail plus example commands only for the current
    step. Read-only.
  - Add a `ship-pr` skill that loops: tick, act, tick. Merge stays human, so the loop stops at merge-policy with
    "waiting for Tony".
  - Unit-test the tick's step logic against canned `gh` JSON fixtures in `tests/`.
- [ ] **Accessibility in the gate**: in `plugin/scripts/screenshot.sh` (or a sibling `a11y.sh`), run axe-core through
  Playwright on each screenshotted page and fail on serious or critical WCAG 2.1 AA violations. Pin versions. Make
  `/factory:implement` run it for visible changes.
- [ ] **Morning digest**: add `routines/morning-digest.md`. It summarizes what the factory did overnight across the
  registered projects: PRs opened and their CI state, friction filed, decisions waiting on Tony. It posts as one
  comment on the factory's rolling nightly PR.

## Later (needs Tony)

- [ ] Decide merge authority per risk tier (ADR 0002).
- [ ] Choose where reports land: Discord, Slack, or email via the Gmail connector.
- [ ] Pipe signals in from Sentry, runtime errors and user feedback.
- [ ] Add a nightly "keep tests tight" pass on each project, against a `testing-principles.md`.
- [ ] Evaluate Kody: connect `https://kody.codes/mcp` to a scratch account, and decide whether secrets and packages
  are worth it next to the Tonezone MCP server.

## Done

<!-- The nightly builder moves finished items here with the date and PR link. -->
