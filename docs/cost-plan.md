# Cost plan: cheap models, bounded runs

## What runs today

| Scheduled task (claude.ai → Scheduled) | Repo | When (UTC) | Model |
| --- | --- | --- | --- |
| Factory nightly builder | tone-zone-software-factory | 07:36, 09:36, 11:36 | Sonnet 5.5 |
| Factory: agent-vs-agent nightly build | agent-vs-agent | 08:12 | Sonnet 5.5 |
| Factory: succulents.info nightly polish | succulents.info | 08:48 | Sonnet 5.5 |
| Factory: tonyjmartinez nightly polish | tonyjmartinez | 09:24 | Sonnet 5.5 |

Each fires into its own Claude Code cloud session with the repo attached. Each run pulls the latest factory from
this repo, so improvements here reach every project the next night.

## Why it's cheap

- **Subscription, not API.** Cloud sessions and scheduled tasks use your Claude plan's usage. There is no per-token
  bill and no GitHub Actions minutes.
- **Sonnet, not Opus,** for every scheduled run. Opus is only for work you start by hand.
- **Back-pressure.** Each project keeps at most one unreviewed factory PR. A run that finds one open stops within a
  turn or two, so unreviewed work never piles up and idle nights cost almost nothing.
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

- Disable a task in claude.ai → Scheduled.
- Or add `NIGHTLY_PAUSED` to the factory repo, which stops the factory builder.
- Closing a project's open factory PR without merging makes the next run start over.
