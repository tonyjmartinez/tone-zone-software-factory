# Fail closed

When unsure, stop and say so. Never pass by default.

- A missing tool, unknown command or unparsable input is a failure (`MISCONFIGURED`), not a skip.
- Permissions are an allowlist. Anything not named is denied.
- A green result must mean the checks ran. Skipped checks print `SKIPPED` and the reason.
- Never weaken a test or a guard to get green.
