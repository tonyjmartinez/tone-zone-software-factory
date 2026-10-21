---
description: Review a change against CLAUDE.md. Pass a PR number to post the review on GitHub, or nothing to review local changes.
argument-hint: "[<pr number>]"
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(gh pr diff:*), Bash(gh pr view:*), Bash(gh pr comment:*), mcp__github_inline_comment__create_inline_comment
---

Review this change. Arguments: $ARGUMENTS

- With a PR number: get the diff with `gh pr diff <n>`. Without one: review `git diff HEAD` plus untracked files
  from `git status`.
- Read the PR description (`gh pr view <n>`) for intent: content the request asked for isn't invented.
- Don't run installs, builds or tests; CI does that. This is a read-only review.
- Read `CLAUDE.md` and judge the change against it. Report only real problems: bugs, broken behavior on phone or
  desktop, accessibility regressions, missing tests for new logic, violations of CLAUDE.md rules. No style nits.
- With a PR number, post inline comments for specific lines and one short summary with `gh pr comment`.
  Without one, print the findings.
- End with exactly `FACTORY_RESULT: done` and, on the line before it, `VERDICT: ship it` or `VERDICT: needs changes`.
