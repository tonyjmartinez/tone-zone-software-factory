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

## Live now: the no-touch nightly (cloud sessions, no secrets)

Set up and verified on 2026-10-21. Each project has its own cloud session with the repo attached and a daily
scheduled task. The task's message says "follow `routines/cloud-run.md` for PROJECT=x", so the procedure lives in this
repo; edit `routines/cloud-run.md` to change all four at once.

| Scheduled task | Time (UTC) | Session | Model |
| --- | --- | --- | --- |
| `trig_0127NSCWT2PxPSavrYMY2kQg` factory | 07:07 | `session_015UrYtFCo7bkBmaoynzihjK` | Sonnet |
| `trig_01N3YaD2gGeJgo68Z7vMZQe4` agent-vs-agent | 07:21 | `session_01EW3QjXmYGxz66G68ZevrST` | Sonnet |
| `trig_01S7t6qT6Z9HsZjx1axEBRLe` succulents.info | 07:33 | `session_01Wf4tFVEwMgEJo17X6J1D34` | Haiku |
| `trig_01EDajUFkSXZQ6skXEHDprsh` tonyjmartinez | 07:47 | `session_01XvvdCFrgLuzdDgEdL7TT3s` | Haiku |

- **Delivery is verified.** A one-shot test task fired into the factory session at 04:46 and was answered, and these
  sessions open their own PRs. One catch: a session must have had at least one turn before scheduled messages reach
  it. Start a new session with `send_message` first.
- **Back-pressure.** Open `claude/night-*`, `claude/polish-*` or `claude/phase-*` PRs make a run stop. Tony's only job
  is merging PRs.
- **Cost watch.** These are long-lived sessions, so every wake-up re-reads the session's history. A one-line reply on a
  session with ~100k tokens of history cost about $0.87 at API rates. Check `get_session` → `usage` /
  `context_usage` weekly. When a session passes ~300k tokens, rotate it:
  1. `create_session` with the same repo and model;
  2. a `send_message` "ready" ping;
  3. delete the old task and create a new one for the new session;
  4. `archive_session` the old session.
- **If Tony adds the GitHub secrets,** the Night shift workflow (08:17 UTC) becomes the primary path. Delete these four
  tasks then, so nothing runs twice. Until then the workflow stays idle.

## Loose ends to tidy

- Factory PR #1 was reviewed and merged on 2026-10-21, and `tests/validate.sh` was added. BACKLOG items 1 and 2 are done.
- First-run PRs are waiting for Tony to merge: agent-vs-agent#1 (Phase 0), succulents.info#1 (noindex utility
  pages) and tonyjmartinez#8 (title and meta tags). Back-pressure holds each project until its PR is merged or
  closed.
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
