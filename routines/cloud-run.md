# Cloud run: one night of work on one project, from a scheduled Claude Code cloud session

Scheduled cloud sessions (one per project, with that project's repo attached) are woken nightly with a message that
says `Follow routines/cloud-run.md for PROJECT=<alias>`. This path needs no GitHub secrets. It does the same work as the
Night shift workflow's `bin/factory night`, and uses the same branch names, so the two never stack PRs.

Nobody is watching. Work autonomously and finish properly.

1. **Get the factory:**
   `rm -rf /tmp/factory && git clone --depth 1 https://github.com/tonyjmartinez/tone-zone-software-factory /tmp/factory`.
   Read `/tmp/factory/projects/<PROJECT>/project.env` for `REPO` and `NIGHTLY`.
2. **Start clean.** You are in a checkout of `REPO`, possibly left over from an earlier run.
   - Run `git fetch origin`.
   - Check out the default branch and reset it to `origin/<default>`.
   - Discard any leftover local changes.
3. **Back-pressure.** If `REPO` has an open PR whose head branch starts with `claude/night-`, stop. Reply
   `waiting for review: <PR URL>`.
4. **Do the work.** Read `/tmp/factory/plugin/commands/implement.md` and
   `/tmp/factory/plugin/skills/factory-standards/SKILL.md` and follow them in **ship** mode, treating
   `${CLAUDE_PLUGIN_ROOT}` as `/tmp/factory/plugin`. The request is `/tmp/factory/routines/<NIGHTLY>.md`, without its
   leading `/factory:implement ship`. Project rules come from the repo's `CLAUDE.md`, or from
   `/tmp/factory/projects/<PROJECT>/CLAUDE.md` if the repo has none.
5. **Verify.** Run `bash /tmp/factory/plugin/scripts/verify.sh`, plus `tests/validate.sh` when `REPO` is the factory
   itself.
6. **Ship.** Push a `claude/night-<routine>-<slug>` branch and open a PR against the default branch, with the report as
   its body.
   - End with the PR URL and the `FACTORY_RESULT:` line.
   - Never push to the default branch, never merge, and touch only `REPO`.
