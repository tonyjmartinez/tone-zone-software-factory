# Routines: scheduled Claude Code cloud sessions

These run as **scheduled tasks in Claude Code on the web** (claude.ai/code → Scheduled, or ask Claude in any
cloud session to "create a scheduled task"). They use your Claude subscription and Anthropic's cloud
containers, so they cost **no GitHub Actions minutes and no API billing**. Each run starts a fresh session on
the repo, does one bounded unit of work, and opens a PR. You review and merge from your phone.

| File | Repo | Suggested schedule | What it does |
| --- | --- | --- | --- |
| `build-next-phase.md` | agent-vs-agent | daily, early morning | Builds the next PLAN.md phase (or the next slice of it) and opens a PR |
| `polish.md` | succulents.info, tonyjmartinez | weekly | Finds and ships one small, high-value improvement |
| `triage.md` | any | daily | Turns your rough `idea` issues into crisp `claude`-labeled tasks |

The two build routines are just `/factory:implement ship <instructions>`. That's the same command GitHub
Actions runs and `bin/factory run` tests locally. Projects wired in by `factory install` enable the factory plugin
in `.claude/settings.json`, so it's available in cloud sessions too. Guard rails: one PR per run, never push to
main, and stop if a previous routine PR is still open, so unreviewed work doesn't pile up.

Try one locally first, without `ship` and without pushing anything:
`bin/factory run agent-vs-agent "$(sed 's|^/factory:implement ship ||' routines/build-next-phase.md)"`

Create one by pasting the prompt into a scheduled task with the repo attached, or ask Claude in a cloud
session: "create a daily scheduled task on tonyjmartinez/agent-vs-agent with the prompt in
routines/build-next-phase.md from tone-zone-software-factory".
