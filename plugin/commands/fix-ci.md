---
description: Fix a CI failure on the current branch. Prefix with "ship" to commit and push the fix.
argument-hint: "[ship] <path to failing log>"
allowed-tools: Read, Edit, Write, Glob, Grep, Skill, Bash(npm:*), Bash(npx:*), Bash(node:*), Bash(bash:*), Bash(git:*), Bash(gh pr comment:*), Bash(gh pr view:*), Bash(gh run view:*), Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(tail:*), Bash(grep:*)
---

CI failed on this branch. Arguments: $ARGUMENTS

The argument after the optional `ship` is a file holding the tail of the failing job's log. Follow the
`factory-standards` skill.
Change files only with the Edit and Write tools: shell edits (`sed -i`, `>`, `tee`) are blocked in CI.

1. Read the log, then `CLAUDE.md`. Reproduce the failure locally with the same command.
2. Find the root cause and fix it with the smallest correct change. Never skip, delete, or weaken a test.
3. Re-run until it passes, then run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh"`.
4. If the failure has nothing to do with this branch's changes (for example it is red on the default branch
   too, or it's an outage), change nothing; explain it in the summary and use `FACTORY_RESULT: blocked - ...`.
   With `ship`, also post that explanation on the PR with `gh pr comment`.
5. **Only with `ship`:** commit with a message ending in `[factory-fix-ci]` and `git push origin HEAD`.
   Otherwise leave the fix uncommitted.

End your final message with this report (it becomes the PR body):

```
## Summary
<what changed and why, 1–4 bullets>

## Verified
<each command you ran and its result>

## Notes
<choices made on ambiguous points, follow-ups, anything a human must decide; "None" if empty>
```

and then a last line that is exactly `FACTORY_RESULT: done` (complete, checks pass) or
`FACTORY_RESULT: blocked - <reason>`.
