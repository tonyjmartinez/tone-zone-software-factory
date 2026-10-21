---
name: factory-standards
description: How the software factory works on a side project. Use for any change you make in a repo wired into tone-zone-software-factory, including @claude requests on issues and PRs.
---

# Factory standards

1. **Read `CLAUDE.md` first.** It names the project's commands and rules. They override anything generic here.
2. **Keep the change small.** Do what was asked, the way the codebase already does things. No drive-by refactors.
3. **Edit with tools.** Use Edit and Write for file changes, never `sed -i` or shell redirection (blocked in CI).
4. **Verify for real.** Run the project's checks before you say you're done:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh"` runs whichever of `typecheck`, `check`, `lint`, `test`, `build`
   exist in package.json. Fix what fails. Never skip, delete, or weaken a test to get green.
5. **Don't stop to ask.** Nobody is watching. If something is ambiguous, pick the most sensible option, say so in the
   summary, and keep going. Only stop if the task is impossible or unsafe, and say why.
6. **Report honestly.** End with a summary in this shape. It becomes the PR body:

   ```
   ## Summary
   <what changed and why, 1–4 bullets>

   ## Verified
   <each command you ran and its result>

   ## Notes
   <choices you made on ambiguous points, follow-ups, anything a human must decide; "None" if empty>
   ```

   Then a last line, exactly `FACTORY_RESULT: done` if the change is complete and the checks pass, or
   `FACTORY_RESULT: blocked - <reason>` if not.
