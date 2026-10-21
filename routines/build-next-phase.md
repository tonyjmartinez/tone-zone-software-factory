/factory:implement ship Build the next phase of PLAN.md. Nobody is watching this run.

First: if an open PR from an earlier run exists (head branch starts with `claude/phase-`), don't start new work.
Check that PR instead. If its CI is red or a review asked for changes, fix them on that branch and push, then stop.

Otherwise read PLAN.md and DESIGN_NOTES.md. Find the earliest phase in section 7 whose "Done when" checklist the
code on main doesn't meet yet, and build it. If it's too big for one session, build the next coherent slice. Run
every check the phase lists and look at any screenshots it produces. Update DESIGN_NOTES.md. Name the branch
`claude/phase-<n>-<slug>` and title the PR "Phase <n>: <what>". Put the phase's "Done when" checklist in the
PR body, with each item ticked or explained.
