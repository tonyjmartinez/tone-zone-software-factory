# Routines: what the Night shift does on each project

`.github/workflows/night-shift.yml` runs once a night (08:17 UTC). For every project in `projects/*/project.env` with a
`NIGHTLY=` line, it runs `bin/factory night <alias>`. That runs `/factory:implement ship <routine>`, the same command
GitHub's issue flow and local `factory run` use, on a fresh clone, and opens a PR on the project.

| Routine | Used by | What one run does | Branch / PR |
| --- | --- | --- | --- |
| `build-next-phase.md` | agent-vs-agent | Builds the next unfinished PLAN.md phase, or a slice of it | `claude/night-phase-*` / "Phase n: …" |
| `polish.md` | succulents.info, tonyjmartinez | Finds and ships one small, high-value improvement | `claude/night-polish-*` / "Polish: …" |
| `backlog.md` | tone-zone-software-factory | Builds the first unchecked item in BACKLOG.md | `claude/night-backlog-*` / "Factory: …" |
| `triage.md` | (manual) | Turns rough `idea` issues into crisp `claude` tasks | n/a |

**Back-pressure.** A project with an open `claude/night-*` PR is skipped until you merge or close that PR. You never
have more than one unreviewed night PR per repo, and a waiting night costs nothing.

**Try a routine locally first** (no push, no PR): `bin/factory night <alias> --trial [--from <checkout>]`.
**Run it now on GitHub:** Actions → Night shift → Run workflow (pick one project, optionally as a trial).
**Change it:**
- Edit a routine file, or a project's `NIGHTLY`, `NIGHTLY_MODEL` and `NIGHTLY_MAX_TURNS` in its `project.env`.
- Remove the `NIGHTLY` line to stop one project.
- Disable the workflow to stop everything.
