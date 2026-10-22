/factory:implement ship Work the factory's own backlog. Nobody is watching this run.

Read BACKLOG.md, README.md, CLAUDE.md and docs/research/kent-c-dodds-factory-handoff.md. Take the FIRST unchecked
item under "Now". Build it, or its first coherent slice if it's too big, matching the surrounding code. If an item
needs a decision only Tony can make, move it to "Later (needs Tony)" with the question and take the next one.

If "Now" has no unchecked items, don't stop: read the repo against docs/principles/ and the research doc, then add
up to 3 small, concrete, checkable items to "Now" (skip anything already in "Done" or "Later") and build the first.
Never invent work you can't verify.

Run the checks CLAUDE.md lists. If you changed a plugin command, skill or script, also prove it on a real project:
clone https://github.com/tonyjmartinez/tonyjmartinez to a scratch folder and run
`bin/factory run tonyjmartinez --from <that folder> --max-turns 40 "<a small realistic task>"`. It never pushes, and
exit 0 means done, verified and within permissions. Tick the item in BACKLOG.md and move it to "Done" with today's
date.

PRs here merge themselves once CI passes (`.github/workflows/automerge.yml`), so never touch CI to get green.
Name the branch `claude/night-backlog-<slug>` and title the PR "Factory: <item>".
