# Tone Zone Software Factory

Make a change to any side project by writing one sentence. Claude does the work and opens a PR; you review and merge from your phone.

```
idea ──► issue labeled `claude` ──► /factory:implement ship #N ──► PR + preview ──► CI
                                          ▲                                        │ red on claude/*
                                          └──────── /factory:fix-ci ship (≤3x) ◄───┘
```

**The agent is a Claude Code plugin** ([`plugin/`](plugin/)): three commands (`implement`, `fix-ci`, `review`),
a standards skill, and scripts for verify and screenshots. Every entry point runs those same files:

| Where | How it runs the plugin |
| --- | --- |
| GitHub Actions | reusable workflows load it into `claude-code-action` (`plugins: factory@tone-zone`) |
| Your terminal | `bin/factory run` runs it with `claude -p --plugin-dir plugin/` on a throwaway copy |
| Claude app / web / scheduled tasks | projects enable it in `.claude/settings.json`, so `/factory:implement` just works |

So a local run tests exactly what GitHub will do, and when you improve the plugin every project gets the change.

| Project | Repo | Stack | CI the factory watches |
| --- | --- | --- | --- |
| `succulents.info` | tonyjmartinez/succulents.info | Astro → Cloudflare Workers | its own "Check and deploy" (with PR previews) |
| `tonyjmartinez` | tonyjmartinez/tonyjmartinez | Astro → Cloudflare Workers | factory's generic Node CI (installed) |
| `agent-vs-agent` | tonyjmartinez/agent-vs-agent | Greenfield, built from `PLAN.md` | factory's generic Node CI (installed) |

## Try it locally first (nothing is committed or pushed)

```sh
bin/factory run succulents.info "Show the plant count in the plant library header"
bin/factory run agent-vs-agent --max-turns 150 "Build Phase 0 of PLAN.md"
bin/factory fix-ci succulents.info --from ../succulents.info path/to/failing-ci.log
bin/factory review path/to/a/checkout          # reviews its uncommitted changes
```

`factory run` clones the project (or copies `--from DIR`) into a throwaway folder. It removes the git remote,
adds the factory files the way `factory install` would, and runs `/factory:implement`. Then it prints:

- **the agent's report**: summary, what it verified, open questions, and a `FACTORY_RESULT` line
- **an independent verify**: the factory re-runs typecheck/check/lint/test/build itself and doesn't trust the agent
- **a permission check**: a PreToolUse hook (`bin/lib/guard.mjs`) **enforces** the command's `allowed-tools`, so
  anything GitHub Actions would deny is denied locally too. The transcript is audited again afterwards.
- **the diff**, turns, time and cost, with paths to the workspace, diff and transcript

Exit code 0 means done, verified, and within permissions.

### What the local test runs showed (Oct 2026, Sonnet)

| Run | Result | Turns | Time | API-equivalent cost |
| --- | --- | --- | --- | --- |
| succulents.info: plant count in library header | done, verify pass | 7 | 38s | $0.09 |
| tonyjmartinez: Projects section (screenshots at 360/1440 checked) | done, verify pass | 12 | 54s | $0.16 |
| agent-vs-agent: PLAN.md Phase 0 (Vite + Phaser 4 + Vitest + Playwright) | done, verify + e2e pass | 37 | 3m | $0.37 |
| succulents.info: fix-ci on an injected sort bug | root cause fixed, no tests touched | 8 | 41s | $0.08 |
| tonyjmartinez: review of the Projects change | verdict + findings | 11 | 21s | $0.09 |

With `CLAUDE_CODE_OAUTH_TOKEN` these runs come out of your Claude plan's usage, not API billing.

### Testing the factory itself

```sh
tests/guard.sh                                        # permission guard: allow/deny cases
tests/gha.sh ../succulents.info "Check and deploy"   # GitHub workflows under `act` (needs Docker)
```

`tests/gha.sh` runs the real caller and reusable workflows with [act](https://github.com/nektos/act). A stub
replaces `claude-code-action` and asserts what it was handed: agent or tag mode, the prompt, the plugin, the
allowlist, and that `.factory/` is git-ignored. It covers labeled and @claude issues, PR comments with and without
@claude, CI failures on `claude/*` versus `main`, the 3-attempt fix budget, and a real run of the generic CI.

## Kick off the Night shift (5 minutes, this repo only)

1. **Claude token:** run `claude setup-token` locally and add the token as the repository secret
   `CLAUDE_CODE_OAUTH_TOKEN` (Settings → Secrets and variables → Actions).
2. **GitHub token:** create a fine-grained personal access token (GitHub → Settings → Developer settings).
   - Repository access: succulents.info, tonyjmartinez, agent-vs-agent and tone-zone-software-factory.
   - Permissions: Contents read & write, Pull requests read & write, Metadata read.

   Add it as the repository secret `FACTORY_GH_TOKEN`.
3. **Test one project:** Actions → Night shift → Run workflow, with project `tonyjmartinez` and trial ticked. Trial
   runs the agent end to end but doesn't push.
4. **Run it for real:** run it again without trial, or just wait for 08:17 UTC.

Add another project by committing `projects/<alias>/project.env` with `REPO=` and `NIGHTLY=`. No setup is needed in
the project repo. The `factory install` steps below are optional: they add `@claude` and labeled-issue
automation inside a project.

## Setup (about 10 minutes, once)

You need the [GitHub CLI](https://cli.github.com) (`gh auth login`) and Claude Code (`claude`).

1. **Merge this branch into `main`.** Projects load the workflows and plugin from `...@main`.
2. **Keep this repo public**, the simplest option: it holds prompts and workflows, no secrets. If it's private, set
   Settings → Actions → General → Access → "Accessible from repositories owned by the user", **and** add a
   `FACTORY_TOKEN` secret (a fine-grained PAT with read access to this repo) to each project, because the
   workflows check out `plugin/`.
3. **Install the Claude GitHub App** on your repos: <https://github.com/apps/claude>. Claude pushes as the app,
   which is what makes its pushes trigger CI and preview deploys.
4. **Make a subscription token** and store it in every project:
   ```sh
   claude setup-token            # long-lived token tied to your Pro/Max plan
   bin/factory secret all        # paste it; sets CLAUDE_CODE_OAUTH_TOKEN on each repo
   ```
5. **Wire each project in.** This opens one PR per repo; merge them:
   ```sh
   bin/factory install succulents.info
   bin/factory install tonyjmartinez
   bin/factory install agent-vs-agent
   bin/factory doctor
   ```

Add `alias factory=~/path/to/tone-zone-software-factory/bin/factory` to your shell rc.

## The factory works on itself

This repo is wired in too. `.github/workflows/factory.yml` calls the reusable workflows locally, and `ci.yml`
runs the factory's own checks: script syntax, `tests/guard.sh`, actionlint on the workflows and rendered templates,
and JSON validity. So you can:

- open an issue here labeled `claude`, or run `factory task tone-zone-software-factory "..."`, and get a PR;
- comment `@claude` on any PR here;
- let the Night shift work through `BACKLOG.md` (`routines/backlog.md`), one PR at a time.

**Auto-merge (this repo only):** `.github/workflows/automerge.yml` squash-merges a `claude/*` or `ccr-*` PR once CI
passes on its head commit. No exceptions, workflow
and `tests/validate.sh` changes included. Drafts and PRs labeled `no-automerge` wait for you. The agents still can't run `gh pr merge` themselves.

It needs the same one-time setup as a project: the `CLAUDE_CODE_OAUTH_TOKEN` secret on this repo, and the Claude
GitHub App installed on it.

## Using it

- **Terminal:** `factory task succulents.info "Add a 'Pet safe' filter to the plant library"` files a
  `claude`-labeled issue, and the PR follows. `factory status` lists Claude's open issues and PRs everywhere.
- **Phone (GitHub app):** open an issue and add the `claude` label, or put `@claude` in it. Claude comments
  "On it" with a link to the run. On a PR, comment `@claude make the button bigger on mobile`.
- **Claude app:** in a Claude Code session on the repo, run `/factory:implement ship <what you want>`.
- **While you sleep:** the **Night shift** workflow gives every registered project one PR a night (see
  [`routines/`](routines/)): agent-vs-agent gets its next PLAN.md phase, the two sites get a polish fix, and this repo
  gets its next BACKLOG item. Projects with an open night PR are skipped until you review it.

## What's in here

| Path | What it is |
| --- | --- |
| `plugin/commands/implement.md` | `/factory:implement [ship] <task or #issue>`: implement, verify, screenshot; with `ship`, branch + PR |
| `plugin/commands/fix-ci.md` | `/factory:fix-ci [ship] <log>`: root-cause a CI failure; with `ship`, push the fix |
| `plugin/commands/review.md` | `/factory:review [<pr>]`: read-only review against CLAUDE.md |
| `plugin/skills/factory-standards/` | Shared rules: small changes, edit with tools, verify for real, the report format |
| `plugin/scripts/verify.sh` | What "green" means: typecheck/check/lint/test/build, whichever exist (also the generic CI) |
| `plugin/scripts/screenshot.sh` | Serves `dist/` and screenshots pages at 360px and 1440px for Claude to look at |
| `.github/workflows/` | Reusable workflows: `claude.yml`, `claude-fix-ci.yml`, `claude-review.yml` (optional), `ci-node.yml` |
| `templates/` | What `factory install` adds to a project: caller workflows, CLAUDE.md, `.claude/` settings + hook |
| `projects/<alias>/` | Per-project config (`project.env`) and the CLAUDE.md seeded into that repo |
| `routines/` | Prompts for scheduled Claude Code cloud tasks |
| `bin/factory` | CLI: `run`, `fix-ci`, `review`, `install`, `secret`, `doctor`, `task`, `status`, `add`, `list` |
| `bin/lib/` | `allow.mjs` (permission model), `guard.mjs` (enforcing hook), `report.mjs` (run report + audit) |
| `tests/` | `guard.sh` and `gha.sh` (above) |

To add a project, run `factory add <alias> <owner/repo>`, optionally put a `CLAUDE.md` in `projects/<alias>/`, then run
`factory run <alias> "something small"` to see how the agent does before you `factory install` it.

## Keeping it cheap

- **Subscription, not API:** `CLAUDE_CODE_OAUTH_TOKEN` bills runs against your Claude plan. Use `ANTHROPIC_API_KEY`
  instead if you prefer per-token billing.
- **Sonnet by default.** Set `model: opus` in a project's `factory.yml` for harder work.
- **Hard caps:** `--max-turns` is 80 per task and 40 per CI fix. There's a 60-minute job timeout, 3 CI-fix attempts
  per branch, and one run per issue or PR at a time.
- **Actions minutes:** free on public repos. Private repos get 2,000 free minutes a month, and a typical run takes 2–10
  minutes. Routines run in Anthropic's cloud and use no Actions minutes.
- **Only you can trigger it:** claude-code-action ignores users without write access and bot accounts. The automatic
  review stays off until you uncomment it.

## Tuning a project

Edit the `with:` block in the project's `.github/workflows/factory.yml`:

```yaml
with:
  model: sonnet            # or opus / haiku / a full model ID
  max_turns: 80
  setup: "npm ci"          # runs before Claude starts
  factory_ref: main        # pin the plugin to a tag or SHA if you want
  allowed_bots: ""         # set to "claude" if routines label issues as the Claude bot and runs don't start
```

Project-specific rules belong in that repo's `CLAUDE.md`. To change what the agent may do everywhere, edit the
`allowed-tools` line in `plugin/commands/*.md`. GitHub, the local guard and the audit all read it from there.
