/factory:implement ship Polish: find and ship ONE small, high-value improvement. Nobody is watching this run.

Build the site and screenshot the main pages. Note candidates as you go: broken links, accessibility problems,
layout bugs at 360px, unclear copy, missing titles/descriptions/Open Graph tags, heavy assets, missing tests for
existing logic, and safe minor/patch dependency updates. Pick the one with the most value for a small diff and do
it well. Don't pick something an open PR on this repo already covers (`gh pr list`).

Name the branch `claude/night-polish-<slug>` and title the PR "Polish: <what>". List the other candidates in the
PR's Notes, so each can become an issue labeled `claude`. Don't invent facts or biography content.
