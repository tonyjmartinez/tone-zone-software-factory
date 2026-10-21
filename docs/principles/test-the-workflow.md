# Test the workflow

Prove the thing as it really runs, not just its parts.

- Change to a command, skill or script: run `bin/factory run <project> --from <checkout> "<task>"` and read the report.
- Change to a workflow: run `actionlint`, and `tests/gha.sh` under act when Docker is available.
- Exit 0 means done, verified and within permissions. A green unit test alone is not that.
- No test-only code in the product paths.
