# tone-zone-software-factory

A software factory for Tony's side projects: a Claude Code plugin (`plugin/`), reusable GitHub workflows, and the
`bin/factory` CLI.

**Validate (run before every PR):** `tests/validate.sh`. Quote its last line, `VALIDATE: PASS`, in the PR.

- `README.md`: what it is and how to run it
- `BACKLOG.md`: the plan; the Night shift takes the first unchecked item
- `docs/principles/`: one page each, read the ones that apply
- `docs/decisions/`: ADRs; check before reopening a settled question

## Rules

- `plugin/commands/*.md` is the single source for what the agent does and may do (`allowed-tools`). Change
  permissions there, then extend `tests/guard.sh`.
- Prove agent-facing changes with a real `bin/factory run <project> --from <checkout> "<task>"`.
- Keep agent-facing text short. Agents never merge; `.github/workflows/automerge.yml` merges agent PRs
  when CI passes, gate changes included, so never weaken CI or `tests/validate.sh` to get green. Never put secrets where an agent can read them.
