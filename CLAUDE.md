# tone-zone-software-factory

A software factory for Tony's side projects: a Claude Code plugin (`plugin/`), reusable GitHub workflows, and the
`bin/factory` CLI. Start with `README.md`; the plan is `BACKLOG.md`.

## Checks (run before every PR)

```sh
tests/guard.sh                                   # permission guard cases
actionlint .github/workflows/*.yml               # install: go install github.com/rhysd/actionlint/cmd/actionlint@latest
for f in bin/factory plugin/scripts/*.sh tests/*.sh; do bash -n "$f"; done; node --check bin/lib/*.mjs
tests/gha.sh <a project checkout> [CI name]      # workflows under act, when Docker is available
```

## Rules

- `plugin/commands/*.md` is the single source for what the agent does and may do (`allowed-tools`). GitHub,
  `bin/lib/guard.mjs` and the audit all read it. Change permissions there, then extend `tests/guard.sh`.
- Prove agent-facing changes with a real `bin/factory run <project> --from <checkout> "<task>"`.
- Keep agent-facing text short. Never auto-merge. Never put secrets where an agent can read them.
