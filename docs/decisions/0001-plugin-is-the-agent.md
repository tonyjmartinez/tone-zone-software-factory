# 0001: The agent is a Claude Code plugin

Status: proposed (Tony to accept)

## Decision
The agent lives in `plugin/` as Claude Code commands, skills and scripts. Every entry point runs those same files:
GitHub Actions (`claude-code-action`), the `bin/factory` CLI (`claude -p --plugin-dir plugin/`), and Claude app or
scheduled sessions (projects enable the plugin in `.claude/settings.json`).

## Why
- A local run tests exactly what GitHub will do.
- Improving the plugin improves every project at once.
- `allowed-tools` in the command files is the one permission source; the guard and audit read it.

## What would change it
An entry point that cannot load plugins, or a need for logic that commands and scripts cannot express.
