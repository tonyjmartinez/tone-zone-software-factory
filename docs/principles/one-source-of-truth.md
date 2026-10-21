# One source of truth

Say each thing once and have everything else read it.

- `plugin/commands/*.md` defines what the agent does and may do. GitHub workflows, `bin/lib/guard.mjs` and the
  audit read it; they never keep their own copy.
- Changing a rule means changing one file, then extending the test that covers it.
- If two places must agree, generate one from the other or add a test that fails when they drift.
