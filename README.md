# Tone Zone Software Factory

Make a change to any side project by writing one sentence. Claude does the work and opens a PR; you review and merge from your phone.

```
idea ──► issue labeled `claude` ──► Claude (GitHub Actions) ──► PR + preview ──► CI
                                          ▲                                       │ red on claude/*
                                          └────────── Claude fixes it (≤3x) ◄─────┘
```

The logic lives here once, as **reusable GitHub workflows**. Each project gets a ~60-line caller file, so
when you improve the factory, every project picks it up on its next run.

| Project | Repo | Stack | CI the factory watches |
| --- | --- | --- | --- |
| `succulents.info` | tonyjmartinez/succulents.info | Astro → Cloudflare Workers | its own "Check and deploy" (with PR previews) |
| `tonyjmartinez` | tonyjmartinez/tonyjmartinez | Astro → Cloudflare Workers | factory's generic Node CI (installed) |
| `agent-vs-agent` | tonyjmartinez/agent-vs-agent | Greenfield, built from `PLAN.md` | factory's generic Node CI (installed) |

## Setup (about 10 minutes, once)

You need the [GitHub CLI](https://cli.github.com) (`gh auth login`) and Claude Code (`claude`) on your machine.

1. **Install the Claude GitHub App** on your repos: <https://github.com/apps/claude>. Claude pushes as the app,
   which is what makes its pushes trigger CI and preview deploys.
2. **Make a subscription token**, then store it in every project:
   ```sh
   claude setup-token            # prints a long-lived token tied to your Pro/Max plan
   bin/factory secret all        # paste it; sets CLAUDE_CODE_OAUTH_TOKEN on each repo
   ```
3. **If this repo is private**, let the projects call its workflows: this repo's
   Settings → Actions → General → Access → "Accessible from repositories owned by the user".
4. **Wire each project in** (opens a PR per repo; merge them):
   ```sh
   bin/factory install succulents.info
   bin/factory install tonyjmartinez
   bin/factory install agent-vs-agent
   bin/factory doctor                # everything should say ok
   ```

Add `alias factory=~/path/to/tone-zone-software-factory/bin/factory` to your shell rc for the rest.

## Using it

**From the terminal**

```sh
factory task succulents.info "Add a 'Pet safe' filter to the plant library"
factory task tonyjmartinez "Add a Projects section linking succulents.info and agent-vs-agent"
factory status                      # Claude's open issues and PRs everywhere
```

**From your phone (GitHub app)**: open an issue and add the `claude` label, or put `@claude` in it. On any PR,
comment `@claude make the button bigger on mobile` and it pushes to that PR.

**From the Claude app**: start a Claude Code session on the repo and just ask. The installed
`.claude/hooks/session-start.sh` installs dependencies first, so it can test immediately.

**While you sleep**: scheduled cloud tasks in [`routines/`](routines/) build the next `PLAN.md` phase of
agent-vs-agent nightly, do a weekly polish pass on the sites, and turn rough `idea` issues into ready `claude` tasks.

## What's in here

| Path | What it is |
| --- | --- |
| `.github/workflows/claude.yml` | Reusable: implement `claude`-labeled issues, answer `@claude` on issues and PRs |
| `.github/workflows/claude-fix-ci.yml` | Reusable: fix red CI on `claude/*` branches, max 3 attempts per branch |
| `.github/workflows/claude-review.yml` | Reusable, optional: short automatic PR review (commented out in projects) |
| `.github/workflows/ci-node.yml` | Reusable: generic Node CI running whichever of typecheck/check/lint/test/build exist |
| `templates/` | What `factory install` copies into a project: caller workflows, CLAUDE.md, `.claude/` settings and hook |
| `projects/<alias>/` | Per-project config (`project.env`) and the CLAUDE.md seeded into that repo |
| `routines/` | Prompts for scheduled Claude Code cloud tasks |
| `bin/factory` | The CLI: `add`, `install`, `secret`, `doctor`, `task`, `status`, `list` |

Add another project with `factory add <alias> <owner/repo>`, drop a `CLAUDE.md` in `projects/<alias>/`, then
`factory install <alias>`.

## Keeping it cheap

- **Subscription, not API**: `CLAUDE_CODE_OAUTH_TOKEN` bills runs against your Claude plan's usage limits
  instead of per-token API pricing. To use an API key instead, set `ANTHROPIC_API_KEY` as the secret.
- **Sonnet by default**: pass `model: opus` in a project's `factory.yml` for harder work.
- **Hard caps**: `--max-turns` (80 per task, 40 per CI fix), a 60-minute job timeout, 3 CI-fix attempts per
  branch, and one run per issue/PR at a time.
- **Actions minutes**: free on public repos; private repos get 2,000 free minutes a month. A typical task
  run takes 5–15 minutes. Routines run in Anthropic's cloud and use no Actions minutes.
- **Only you can trigger it**: claude-code-action ignores users without write access, and the auto-review is
  off until you uncomment it.

## Tuning a project

Edit the `with:` block in the project's `.github/workflows/factory.yml`:

```yaml
with:
  model: sonnet            # or opus / haiku / a full model ID
  max_turns: 80
  setup: "npm ci"          # runs before Claude starts
  extra_allowed_tools: "Bash(npx playwright test:*)"
  extra_instructions: "Always attach a 360px screenshot to UI PRs."   # avoid double quotes
  allowed_bots: ""         # set to "claude" if routines label issues as the Claude bot and runs don't start
```

Project-specific rules belong in that repo's `CLAUDE.md`; every run reads it first.
