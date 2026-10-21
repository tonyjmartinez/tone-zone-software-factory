/factory:implement ship Build the next phase of PLAN.md. Nobody is watching this run.

Read PLAN.md and DESIGN_NOTES.md. Find the earliest phase in section 7 whose "Done when" checklist the code on the
default branch doesn't meet yet, and build it. If it's too big for one session, build the next coherent slice. If
the repo has no CLAUDE.md yet, add one following PLAN.md's conventions. Run every check the phase lists and look
at any screenshots it produces. Update DESIGN_NOTES.md.

Name the branch `claude/night-phase-<n>-<slug>` and title the PR "Phase <n>: <what>". Put the phase's "Done when"
checklist in the PR body, with each item ticked or explained.
