# 0003: Stock Claude Code over Kody, for now

Status: proposed (Tony to accept)

## Decision
Build on stock Claude Code, GitHub and plain files. Kody is not adopted.

## Why
- Kody OAuth grants the agent full account access; we have no need for that yet.
- Kent's useful ideas (router file, principles, friction log, ship-pr tick) map onto plugin commands and skills.
- Kody is FSL-licensed: fine to learn from, not to resell.

## What would change it
We need a secrets vault or shared packages the plugin cannot give us, or the Kody trial in `BACKLOG.md` shows it
beats the Tonezone MCP server for that job.
