Triage this repo's issue inbox. Work autonomously; nobody is watching.

For each open issue labeled `idea` (rough notes, often typed on a phone):
1. Read it with CLAUDE.md and the relevant code in mind.
2. Rewrite the issue body into a crisp task: goal, acceptance criteria, files likely involved, how to verify.
   Keep the original text at the bottom under "Original note".
3. If it's clear and small enough for one PR, remove `idea` and add `claude` (this starts the GitHub Actions
   factory, which implements it). If it's big, split it into a few smaller issues labeled `claude` and close the
   original with links. If it truly needs a human decision, leave `idea`, add `needs-decision`, and comment with
   the specific question and your recommended answer.

Use the GitHub tools to edit issues. Don't write code in this task.
