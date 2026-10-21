# Lean agent context

Every always-loaded line costs attention on every run.

- `CLAUDE.md` is a router of about 20 lines: the validate command, then links.
- Details live in `docs/principles/` and `docs/decisions/`, loaded only when relevant.
- Commands and skills stay short. Cut anything the agent would do anyway.
