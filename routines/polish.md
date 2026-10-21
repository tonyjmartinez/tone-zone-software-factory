/factory:implement ship Weekly polish: find and ship ONE small, high-value improvement. Nobody is watching this run.

First: if an open PR titled "Polish:" from an earlier run exists, stop. Unreviewed work shouldn't pile up.

Otherwise build the site and screenshot the main pages. Note candidates as you go: broken links, accessibility
problems, layout bugs at 360px, unclear copy, missing titles/descriptions/Open Graph tags, heavy assets, missing
tests for existing logic, and safe minor/patch dependency updates. Pick the one with the most value for a small
diff and do it well. Title the PR "Polish: <what>" and list the other candidates in its Notes, so each can become
an issue labeled `claude`. Don't invent facts or biography content.
