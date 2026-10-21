# 0002: No auto-merge yet

Status: proposed (Tony to accept)

## Decision
A human merges everything. The agent opens PRs and never merges (`gh pr merge` is denied by the guard).

## Why
Merge authority is the largest blast radius we can grant, and we have no track record yet.

## Tiers we would use if Tony grants merge authority
| Tier | Examples | Gate before merge |
| --- | --- | --- |
| low | docs, copy, tests only | green CI |
| medium | app features, non-load-bearing scripts | green CI, verifier `confirmed`, review findings handled |
| high | workflows, permissions, auth, secrets, deploy config | never auto-merged; park for Tony |

Each project would list its own load-bearing paths; anything touching them is high.

## What would change it
Tony grants merge authority per tier (see "Later (needs Tony)" in `BACKLOG.md`).
