# Handoff: continue the Tone Zone Software Factory

Written 2026-10-21 by the agent that built v1. For the next agent: read this, then `README.md`, `CLAUDE.md`,
`BACKLOG.md` and `docs/cost-plan.md`. Tony wants this running **without touching anything himself**. Respect that, but
never fake an outcome. If something needs a human, say exactly what, once, and keep going on everything else.

## Goal

Keep Tony's side projects improving automatically and cheaply: one small, verified PR per project per night, on a
cheap model, merged and deployed with as little human effort as safety allows.

| Project | Repo | Default branch | Deploys from | Nightly routine (`projects/<alias>/project.env`) |
| --- | --- | --- | --- | --- |
| succulents.info | tonyjmartinez/succulents.info (private) | `ccr-13aa8584-ctlf4s` (!) | `main` via its "Check and deploy" workflow | polish, Haiku |
| tonyjmartinez | tonyjmartinez/tonyjmartinez | `main` | `main` via Cloudflare Git integration | polish, Haiku |
| agent-vs-agent | tonyjmartinez/agent-vs-agent | `ccr-70e6488c-az6mm9` (!) | nothing yet (PLAN.md phase 7) | build-next-phase, Sonnet |
| factory | tonyjmartinez/tone-zone-software-factory (public) | `claude/nice-hamilton-er5d8e` | n/a | backlog, Sonnet |

**(!)** PRs target the default branch, but deploys only happen from `main`. Until Tony switches the default branch to
`main`, merged night PRs on these two repos won't deploy.

## What exists and is verified

- **The agent is a Claude Code plugin** (`plugin/`) with three commands, `/factory:implement`, `/factory:fix-ci` and
  `/factory:review`, plus a standards skill and `verify.sh` / `screenshot.sh`. Each command's `allowed-tools` line is
  the single source of what the agent may do.
- **`bin/factory`**:
  - `run`, `fix-ci`, `review` and `night [--trial]` run the plugin headless, on a throwaway copy or in ship mode.
  - A PreToolUse guard (`bin/lib/guard.mjs`) enforces each command's allowlist locally, and the transcript is
    audited afterwards.
  - Each run gets an independent verify and a report.
- **Night shift** (`.github/workflows/night-shift.yml`) runs daily at 08:17 UTC.
  - It loops over every project with `NIGHTLY=` and runs `bin/factory night <alias>`.
  - It skips a project while a `claude/night-*` PR is still open there (back-pressure).
  - It stays **idle until two repo secrets exist** (see Blocked).
- **Local evidence**, all with Sonnet unless noted:
  - implement runs on all 3 projects, done and verified, $0.09–0.37 each;
  - agent-vs-agent Phase 0 built with e2e passing;
  - a fix-ci run on an injected bug;
  - Haiku polish at $0.01 versus Sonnet at $0.14, same quality (`docs/cost-plan.md`);
  - a ship-mode run against a local bare remote with a stub `gh` (branch pushed, PR created);
  - `tests/guard.sh` passing;
  - `tests/gha.sh`: every workflow trigger case under `act` with a stubbed claude-code-action;
  - actionlint clean.
- **Never tested on real GitHub Actions**: Night shift, Factory, and fix-ci. The first real run is the real test.

## Blocked on Tony (ask once, clearly; don't nag)

1. **Secrets for Night shift**, on the factory repo:
   - `CLAUDE_CODE_OAUTH_TOKEN`, from `claude setup-token`;
   - `FACTORY_GH_TOKEN`, a fine-grained PAT for the 4 repos with Contents and Pull requests read & write.

   README.md has step-by-step instructions. No agent can create these.
2. **Default branches:** set `main` as default on succulents.info and agent-vs-agent. Merge the `ccr-*` work into
   `main` first if it has anything `main` lacks. Also check that succulents.info has the `CLOUDFLARE_API_TOKEN` and
   `CLOUDFLARE_ACCOUNT_ID` secrets.
3. **Auto-merge:** Tony asked for it. The previous agent's code change, `gh pr merge --auto` after a clean run (opt-in
   per project, never for PRs touching `.github/`), was **blocked by Claude Code's permission classifier ("Merge
   Without Review")**. Don't work around that. Either Tony allows it in his Claude Code permission settings, or he
   pastes the change himself. On top of that, each project needs "Allow auto-merge" plus a ruleset requiring its CI
   check, which are repo settings only Tony can change.

## The no-touch path (use this while the secrets are missing)

Cloud scheduled sessions need no secrets, because they run on Tony's Claude plan with the repo attached. The pattern
that worked:

1. `create_session` with `source_url` set to the project repo, `model: claude-sonnet-5-5` (or Haiku for polish), and
   a tag such as `factory-nightly`.
2. Kick it off with `send_message`. A trigger fired into a brand-new session never got delivered; a direct message
   did. The factory builder session, kicked off this way, pushed `claude/factory-nightly` and **opened PR #1** on its
   own.
3. Bind a daily `create_trigger` with `persistent_session_id`, so it fires into that session.
   - **Unverified:** whether later scheduled fires reliably wake a session that has already had a first turn. Check
     `get_trigger` → `last_run` and the session's `list_events` the morning after.
   - The prompt for each project: clone the factory, follow `plugin/commands/implement.md` in SHIP mode with
     `${CLAUDE_PLUGIN_ROOT}` = the clone's `plugin/`, and use the project's routine from `routines/<NIGHTLY>.md`.
     Use `claude/night-*` branch names so the GitHub Night shift's back-pressure also sees them later.
4. Before starting new work, check for an open `claude/night-*` PR on that repo and stop if there is one. That's the
   same back-pressure the workflow uses, and it keeps the cost of an idle night near zero.
5. Once Tony adds the secrets, switch to the GitHub Night shift and delete these triggers, so nothing runs twice.

All earlier triggers were deleted. The four sessions that remain from setup can be archived:
`session_015UrYtFCo7bkBmaoynzihjK` (factory), `session_01EW3QjXmYGxz66G68ZevrST` (agent-vs-agent),
`session_012D2QvyVEujpsG8X8cM5wtg` (succulents.info) and `session_01MppW5gK8MnK1hEutWn9sVb` (tonyjmartinez).

## Loose ends to tidy

- **Factory PR #1** (`claude/factory-nightly`, router CLAUDE.md and principles pages): review it, and if it's good,
  tick BACKLOG item 1. If it stays open, the backlog routine will rebuild the same thing.
- **Stray branches** from the first runs, not `night-` prefixed: `claude/polish-noindex-utility-pages`
  (succulents.info), `claude/phase-0-scaffold` (agent-vs-agent) and `claude/polish-page-title-meta`
  (tonyjmartinez). Open PRs for them or delete them.
- **`factory install` and project caller workflows** reference `tonyjmartinez/tone-zone-software-factory/...@main`,
  but this repo has no `main` branch yet. Either create `main` from the default branch and make it default, or change
  the references.

## Rules (from CLAUDE.md, and how Tony works)

- Change agent permissions only in `plugin/commands/*.md`, then extend `tests/guard.sh`.
- Prove agent-facing changes with a real `bin/factory run <project> --from <checkout> "<task>"`.
- Cheap by default: Haiku where a measured trial shows it holds up, Sonnet otherwise, and Opus never on a schedule.
- Never auto-merge without Tony's explicit, platform-permitted go-ahead.
- Never put secrets where an agent can read them.
- Commits end with the session attribution lines. Work on a `claude/*` branch, and open PRs only when asked or when
  a routine does it.
