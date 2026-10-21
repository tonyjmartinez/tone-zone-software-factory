# Research: software factories + Kent C. Dodds' setup

Compiled 2026-10-20 from public sources (links at the bottom). This is **research, not instructions**. The
factory's actual plan lives in [`BACKLOG.md`](../../BACKLOG.md) and its decisions in [`docs/decisions/`](../decisions/).

## 1. What a "software factory" is

A repeatable, instrumented loop: signals in (bugs, feedback, errors, specs) → triage → spec → implement →
verify/review → ship → monitor. Monitoring produces new signals. Engineers design and tune the stages instead of
writing the code inside them.

| Source | Core idea | Useful takeaway |
|---|---|---|
| Dan Shapiro, "The Five Levels" (Jan 2026) | L0 spicy autocomplete → L5 dark factory | Moving up is gated by **verification density**, not model IQ. |
| StrongDM AI (Feb 2026) | Non-interactive "dark factory" | **Scenario holdouts** stored outside the repo so agents can't reward-hack tests; digital twins of external services. |
| Factory.ai "Factory 2.0" (Jun 2026) | Enterprise factory | Codify workflows before granting long-horizon autonomy. |
| Warp memo (Jul 2026) | "Factory engineers, not product engineers" | Efficiency ≈ shipped product / (inference cost + human time). ~30–35% of tasks automated. |
| Kent C. Dodds, "What the devil is a Factory Engineer?!" (Jul 2026) | Agrees on machinery, keeps product human | Agents handle polish/quality/implementation; **product vision and judgment stay human.** |
| Addy Osmani, `addyosmani/factory` | Reference factory on stock Claude Code | Most directly copyable. See §4. |

## 2. Kent C. Dodds' setup

### 2a. Kody (kody.codes, `kody-hq/kody`, FSL-1.1-ALv2)

Not an agent: a shared cloud any MCP host plugs into. Problem: every agent is a walled garden; memory, integrations,
automations and secrets get rebuilt per agent, and `.env` files leak to agents.

- **Two MCP tools ("Code Mode"):** `search` (capabilities, `guide:<id>` docs, packages, integrations, memories;
  secret *metadata* only) and `execute` (runs a temporary TS module server-side that composes capabilities and
  imports `kody:@owner/pkg/export`).
- **Primitives:** secrets referenced as `{{secret:name}}` and filled in only for approved hosts (agents never see
  values); git-backed **packages** with versioned imports and `packageStorage()` KV; **jobs** (cron in the manifest
  under `kody.jobs`, shipped `enabled: false`), one-shot workflows, webhooks, email; **apps** (PWA surfaces);
  **memory** shared across agents.
- **Core loop: ask once, save it, trigger it.** Explore with `execute`, turn what's useful into deterministic package
  code (no model in the loop), re-invoke cheaply, optionally schedule.
- **Architecture:** Nx monorepo on Cloudflare Workers, Remix 3, D1, KV, Durable Objects for MCP state, Playwright,
  Vite. Hosted Kody can't reach localhost; Kent bridges home devices with a home MCP server over Cloudflare Tunnel.
- **Connect:** MCP URL `https://kody.codes/mcp`, OAuth. Approving grants the agent **full account access**.

### 2b. The factory loop ("How I Put My Codebase on Autopilot", Oct 13 2026)

122 PRs merged in 24 hours, mostly unattended. **Central insight: agents don't fix friction, they work around it**, and
workarounds compound. So every shipped PR ends by filing friction, and other agents fix it, often overnight.

Three pillars of confidence:
1. **Good PRs in the first place:** ADRs in `docs/contributing/decisions/`; a primitives catalog so agents compose
   rather than invent; a CLI for agents to self-verify UI/API locally; a **system recap on every PR** classifying
   changes as *composes / extends / adds* so humans review architecture, not diffs; `npm run validate` as the single
   authoritative local gate.
2. **Catch mistakes before prod:** CI, preview deploys, AI reviewers (Bugbot, CodeRabbit, Devin review, Sentry Seer),
   and `ship-pr` to drive a PR to done.
3. **Limit blast radius:** feature flags with success metrics; disaster recovery with **restore tests**.

Plus scheduled cleanup (agents hate deleting code), dogfooding, and signal pipes from Sentry, runtime errors and
user feedback into nightly/weekly agents.

### 2c. Concrete pieces (public Kody packages under `@kentcdodds`)

**`ship-pr`: a "progressive tick" loop.** The agent calls `tick`. It returns a short checklist of the whole process,
what's done, and full detail only for the current step, with runnable example calls. **The package reports state;
the agent decides.**

| Step | What tick checks |
|---|---|
| ready | PR open, not draft |
| ci | head-SHA checks, deduped re-runs, AI reviewer checks excluded |
| ai-review | bot reviewer state, sorted findings, unresolved threads |
| merge | risk policy, mergeability |
| deploy | workflow runs on merge SHA |
| friction | leftover papercuts filed via friction-log |
| report | Discord summary |

- **Risk tiers:**
  - **low:** green CI; AI review is optional.
  - **medium:** wait for Bugbot and handle valid findings.
  - **high:** also wait for CodeRabbit and Devin, then **park** unless merge authority was granted.
- `decide` records a 7-day decision on a thread or check (ignored / skipped / wontfix / accepted, with a required
  reason) so noise stops resurfacing.
- Read-only unless `applySafeAutomations: true`. The loop is done when `exit.done: true`.

**`friction-log`: routes papercuts.**
- **What to file:** only **durable, recurring, clear-owner, reproducible** contract gaps (a missing step, a type
  that lies, a broken harness, docs that don't match the code). One-off confusion is skipped.
- **What a filing carries:** a short preliminary investigation plus `relevantFiles`. Never invent a root cause.
- **How it's filed:** a GitHub issue labeled `friction`, deduped by title.
- **Daily sweep at 5am:** takes open `friction` issues without `friction-skipped` and handles **at most one** per day.
  For each, it either closes it (already fixed or invalid), ships an obvious low/medium-risk fix, or comments a
  recommended fix and adds `friction-skipped`. It has a pause/resume kill switch, and everything supports dry-run.
- **Fix policy:** prefer **one clear contract** over aliases, fallbacks or compat shims, and fix the real owner. Reject
  a fix that invents a second way to do the same thing.

**Other packages:** `quiet-hours` (bots queue overnight, then an 8am digest of finished work and open decisions),
`sentry-triage`, `kody-issue-triage`, `codebase-cleanup`, `skills`, `codemod-runner`, `github`, `discord`.

**Recurring automations:** "Keep Tests Tight" runs nightly and deletes low-signal tests against a
`testing-principles.md` (fewer, longer workflow tests). Friction sweep runs daily. Weekly and nightly agents are fed
by Sentry and user feedback.

### 2d. Principles for agent-facing repos

- **The always-on file is a router, not an encyclopedia.** Kody's `AGENTS.md` is ~20 lines: one validation command,
  then links to the contributing map, `docs/principles/` and the skills.
- **One page per principle, loaded only when relevant:**
  - generic platform; normalized source of truth
  - delete what's off the common path; cleanup
  - no breaking changes; fail loudly at the right layer; fix the root bottleneck
  - two-way vs one-way doors (decides review depth)
  - examples over prose; lean agent context
  - no test-only code in prod; test the workflow
- **Short ADRs**, so the next agent "opens the no" instead of making you the memory.
- **Review systems, not diffs.** Use AI to gather evidence for product decisions, but keep the judgment human.

## 3. Mapping to stock Claude Code

| Kent's piece | Claude Code equivalent |
|---|---|
| Router `AGENTS.md` + principles | Thin `CLAUDE.md` linking `docs/principles/*.md`, `docs/decisions/*.md` |
| `.agents/skills/` | Plugin skills (here: `plugin/skills/`) or `.claude/skills/` |
| `ship-pr` tick | Skill + script that queries `gh` and prints the current step; agent acts and re-ticks |
| friction-log + daily sweep | `friction` label + issue form; scheduled cloud routine picks one eligible issue |
| Independent review | `verifier` subagent that reads the diff cold and reverts the fix to prove the test fails |
| Risk tiers / merge authority | Charter file + branch protection; hook that blocks `gh pr merge` |
| Quiet hours + digest | Routine posting a morning summary |
| Packages + secrets vault | MCP server(s) on Cloudflare Workers (Tony's Tonezone MCP is a start); tokens never in agent-visible env |

Claude Code limits: routines have native GitHub triggers for `pull_request` and `release` but **not new issues**
(poll on a schedule or use an Action); cloud environment config isn't committable; a green run ≠ task success; env
vars are not secrets.

## 4. Addy Osmani's reference factory (`addyosmani/factory`, MIT)

- `docs/factory/CHARTER.md` (human-owned): tier, load-bearing paths, allowed work, definition of done, `STOP_IF`
  back-pressure cap on pending reviews.
- **Queue and handoff:** the queue is GitHub issues with `factory:*` labels; the handoff is a structured
  `factory-handoff:v1` comment.
- **Claiming:** a deterministic branch `claude/fq-<issue>`. The first push wins, so runs can't collide.
- **Skills:** triage, spec (with four human approval gates), implement (test first), verify, monitor.
- **Agents:** verifier and critic. A monthly tune pass only proposes changes.
- **`gates.sh`:** types, lint, tests, build, audit, mutation, architecture. It emits a verdict line agents must quote,
  and a missing gate is `MISCONFIGURED` with exit 2 (fail closed).
- **Merge is never automated**, because the binding constraint is human review attention. (Kent auto-merges
  low/medium risk; pick deliberately.)

## 5. Caveats

- Kody moved from `kentcdodds/kody` to `kody-hq/kody`. The "autopilot" video is summarized from its description, not
  a transcript. Kody is FSL-licensed: fine to self-host and learn from, not to resell. Kody OAuth gives full account
  access.

## Sources

kody.codes (docs: how-kody-works, kody-factory, connect-your-agent, platform-friction) · github.com/kody-hq/kody ·
kody.codes/@kentcdodds/ship-pr · kody.codes/@kentcdodds/friction-log · kentcdodds.com/better ·
youtube.com/watch?v=lDRjsHjkbjI · kentcdodds.com/talks/build-a-free-agent · factory.com/news/software-factory ·
warp.dev/blog/we-are-now-factory-engineers-not-product-engineers · simonwillison.net/2026/feb/7/software-factory ·
simonwillison.net/2026/Jan/28/the-five-levels · github.com/addyosmani/factory
