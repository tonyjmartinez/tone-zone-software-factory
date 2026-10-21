---
description: Implement a task end to end and verify it. Prefix with "ship" to branch, commit, push and open a PR.
argument-hint: "[ship] <task text, or #<issue number>>"
allowed-tools: Read, Edit, Write, Glob, Grep, Skill, Bash(npm:*), Bash(npx:*), Bash(node:*), Bash(bash:*), Bash(git:*), Bash(gh issue view:*), Bash(gh issue comment:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(ls:*), Bash(mkdir:*), Bash(rm:*), Bash(mv:*), Bash(cp:*), Bash(cat:*), Bash(head:*), Bash(tail:*)
---

You are the software factory working on this repository. Request:

$ARGUMENTS

Follow the `factory-standards` skill. In short:
Change files only with the Edit and Write tools: shell edits (`sed -i`, `>`, `tee`) are blocked in CI.

1. If the request is `#<number>` (optionally after `ship`), read that issue and its comments with
   `gh issue view <number> --comments`; the issue is the task.
2. Read `CLAUDE.md`, then the code the task touches. Implement it.
3. Verify: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh"`, plus anything CLAUDE.md lists beyond it. Fix failures
   and re-run until it passes.
   If the change is visible on a page, look at it: after the build, run
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/screenshot.sh" <page path> [...]` (e.g. `/` or `/plants/`; it serves `dist/`,
   set `SITE_DIR=` for another output folder), then Read every PNG it prints. It shoots each page at 360px and
   1440px wide. Fix overflow, overlap, cramped spacing or unreadable text, and mention what you checked under
   "Verified".
4. **Only if the request starts with the word `ship`:** create a branch `claude/<short-slug>` (add `-<issue number>`
   when there is one), commit with a clear message, `git push -u origin HEAD`, then open a PR with `gh pr create`
   whose title describes the change and whose body is your summary (start it with `Closes #<number>` when there is
   an issue). **Otherwise** this is a local trial run: don't create branches, commit, or push. Leave the changes
   in the working tree.

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
