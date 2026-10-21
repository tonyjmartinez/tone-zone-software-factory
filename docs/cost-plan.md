# Cost plan: cheap models, bounded runs

## What runs today

The **Night shift** workflow (`.github/workflows/night-shift.yml`) runs daily at 08:17 UTC in this repo's GitHub Actions.
It does one unit of work per registered project. Model and turn cap come from each `projects/<alias>/project.env`:

| Project | Routine | Model | Max turns |
| --- | --- | --- | --- |
| agent-vs-agent | build-next-phase | Sonnet | 100 |
| succulents.info | polish | Sonnet | 40 |
| tonyjmartinez | polish | Sonnet | 40 |
| tone-zone-software-factory | backlog | Sonnet | 80 |

## Why it's cheap

- **Subscription, not API.** `CLAUDE_CODE_OAUTH_TOKEN` bills your Claude plan, not per token. This repo is public, so
  its Actions minutes are free.
- **Sonnet, not Opus,** for every scheduled run. Opus is only for work you start by hand.
- **Back-pressure.** A project with an open `claude/night-*` PR is skipped before Claude even starts. Unreviewed work
  never piles up, and a waiting night costs nothing.
- **Small units.** One backlog item, one phase slice, or one polish fix per run.
- **Measured.** At API prices, local test runs on Sonnet cost $0.08–$0.37 per run (see README). A full night of all four
  is roughly $1.

## Next savings, in order

1. **Model tiering.** Use Haiku for read-only work (review, triage, digest) and Sonnet for implement and fix-ci. Before
   switching, run the same tasks with `bin/factory run --model haiku` and compare: done rate, verify pass, and cost.
2. **Skip idle repos.** A polish run should stop if the default branch has had no commits since the last polish PR
   merged.
3. **Weekly polish.** Once the backlog of obvious fixes is gone, move the site polish runs to weekly.
4. **Turn caps by job:** 40 turns for polish and fix-ci, 80 for phase builds. Already set in the GitHub workflows.

## Pausing

- Remove a project's `NIGHTLY` line to stop that project.
- Disable the Night shift workflow (Actions → Night shift → ⋯ → Disable) to stop everything.
