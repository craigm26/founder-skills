# Chaining: market-validation → build-options → prd

## Input A — chain from `market-validation` (preferred)
Read that skill's run outputs:
- `deck-data.json`: use `meta` (product), `competitors`+`categories` (→ incumbents, esp. the highest-tier /
  most-cited), `wtp` (→ wtp_notes), `sizing?` (market scale), `counter.risks` (→ constraints/regulatory risk).
- the build/integrate brief: its recommended wedge seeds (but does not dictate) the option set.

Build a `DecisionContext`:
```
{ product, summary, incumbents: [..], wtp_notes, constraints, mustReuseAssets: [..] }
```
`summary` is a 2–4 sentence paragraph the workflow passes to every agent.

## Input B — standalone brief (fallback, no prior run)
Ask the user for a minimal brief and build the same `DecisionContext`:
```
{ product, market, incumbents: [..], wtp_notes, constraints, mustReuseAssets: [..] }
```

## Output handoff → `prd`
The installed `prd` skill (`~/.claude/skills/prd/SKILL.md`) consumes a **plain feature description**,
self-clarifies (does NOT ask the user), and writes `/tasks/prd-[feature-name].md`. So after choosing the winner:

> Invoke the `prd` skill with a feature description = the winning option's `thesis` + `mvpScope` +
> `businessModel` + the key `constraints`/`mustReuseAssets`.

Then the `tasks` skill can convert that PRD into `prd.json` for execution. Full chain:
**market-validation → build-options → prd → tasks → build.**

(Until exercised once, treat the prd handoff as "described, not yet run" — confirm the PRD lands in `/tasks/`.)
