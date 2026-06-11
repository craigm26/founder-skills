---
name: fable-org-audit
description: >-
  Use when you need to verify that a customer organization on your platform is healthy and getting
  full value — a live integration audit that probes real API signals across eight dimensions, not a
  code review. Triggers on: "audit this org", "is <org> healthy", "health-check the integration",
  "why does this org feel off", or a scheduled pre-demo / weekly org check.
---

# Fable Org Audit

## Overview

An org audit is a **product health check**, not a code review. It asks: *is everything actually
working for this organization?* It probes live API signals across every dimension your platform
exposes — ingest, graphs, status programs, geo/field data, hypotheses, billing, metrics, edge
devices — and produces a graded report with a prioritized gap list.

**Distinct from `/fable-repo-audit`** (which audits a codebase). This audits a *customer org's
integration*, not the platform's code.

This skill ships as a **portable pattern**: the eight dimensions, the grading rubric, the audit
prompt shape, and the memory loop. It was built against a specific platform (PlatAtlas) — the full
original probe set, endpoint by endpoint, is preserved in
`references/worked-example-platatlas.md`. To run it on your platform, map each dimension to your
own endpoints; the example shows exactly what that mapping looks like.

---

## When to Use

- Before onboarding a new org — verify all integrations are live before the first demo
- Weekly for active orgs, especially ahead of a deal conversation — catch silent failures
- After any deploy — confirm no regressions broke a live org's experience
- When an org reports "something feels off" — structured diagnosis before guessing
- As part of a `/fable-loop-design` memory loop — Fable audits, writes findings to memory, next
  week's audit starts smarter

---

## The Eight Dimensions

Each dimension gets a grade: 🟢 Healthy · 🟡 Degraded · 🔴 Broken · ⚫ Not configured

| # | Dimension | The generic question |
|---|---|---|
| 1 | **Ingest** | Is data flowing in? Recent? Authenticated/verified at the expected rate? |
| 2 | **Graph / model** | Is the org's core data model populated and growing — not empty or static? |
| 3 | **Status program** | Is the org's published status/progress artifact fresh and non-empty? |
| 4 | **Geo / field** | Are physical-world declarations (sites, devices, zones) published and real? |
| 5 | **Hypotheses** | Is the org running experiments — and acknowledging the failed ones? |
| 6 | **Billing** | Subscribed, trialing with runway, or silently locked out? |
| 7 | **Metrics / intelligence** | Are computed metrics returning sane values (error rates, coverage)? |
| 8 | **Edge devices** | Are field devices reporting with verified identity, with state tracked? |

Not every platform has all eight — grade missing dimensions ⚫ *by design* and say so, rather than
silently shrinking the audit.

---

## Step 1 — Invoke Fable as org auditor

Pass the org identifier and your platform's base URL. Fable probes each dimension via the live
API. The session must carry a valid operator credential for the org — most platform endpoints
need an authenticated operator session.

```javascript
Agent({
  model: "fable",
  prompt: `You are auditing the organization: <org-slug>
Base URL: <your platform's base URL>
Your session carries a valid operator credential for this org.

Read existing memory first: ~/.claude/audits/org-<org-slug>-memory.md (if it exists).
It contains verified patterns from prior audits — consult it before forming hypotheses.

Probe each of the eight dimensions via the live API
(endpoint mapping for this platform: <your mapping — see the worked example for the shape>).
For every dimension report:
  (a) What you found (exact API response summary)
  (b) Grade: 🟢 Healthy / 🟡 Degraded / 🔴 Broken / ⚫ Not configured
  (c) Why it matters if not green (concrete consequence for this org)
  (d) Recommended action (specific, not vague)

Grading discipline (apply per dimension):
  Healthy   = working as intended, fresh data, expected volumes
  Degraded  = working but stale, partial, or below thresholds
  Broken    = not working — visible user impact
  Not configured = never set up (distinguish "broken" from "never started")

FINAL DELIVERABLE — a single document with:
1. Executive Summary — overall grade A (all green) → F (critical path broken),
   top 3 risks, top 3 opportunities for this week
2. Dimension Report — one row per dimension (grade, one-sentence finding, action);
   full detail for any 🟡 or 🔴
3. Prioritized Gap List — Broken first, then Degraded, then Not configured;
   each gap: what, concrete consequence, specific fix, effort (S/M/L)
4. Memory Update — patterns verified this run (promote to rules), new open
   questions, prior memory now known wrong (retract it)
5. Open Questions — anything requiring operator input

Save to: ~/.claude/audits/org-<org-slug>-<date>.md
Update memory: ~/.claude/audits/org-<org-slug>-memory.md (verified rules only)
Return only the audit file path.`,
})
```

---

## Step 2 — Surface findings and act

After Fable returns the file path:

1. Read and display the **Executive Summary** and **Prioritized Gap List** to the operator
2. For any 🔴 Broken dimension: treat as an incident — fix before the next demo or deal conversation
3. For 🟡 Degraded: queue into the org's status program / work queue
4. Fable writes verified patterns to `org-<slug>-memory.md` — the next audit reads these and
   doesn't re-derive known issues

### Chaining with a work program

If your platform publishes a status/work program for the org, audit gaps feed it directly:

```javascript
// After audit, if Broken dimensions exist:
Agent({
  model: "fable",
  prompt: `Update the org's status program based on the audit at <audit-path>.
           Move 🔴 Broken gaps into now[]. Move 🟡 Degraded into next[].
           Do not invent status — only promote items the audit explicitly flagged.`,
})
```

---

## Scheduling the cadence

"Weekly for active orgs" needs a real trigger, not an intention. Two documented mechanisms:

- **Claude Code `/schedule` (routines)** — a saved configuration that runs on Anthropic-managed
  cloud infrastructure on a cron cadence; your laptop can be off. Good default for a solo operator:
  `/schedule weekly Monday 7am — run /fable-org-audit for org <slug>, post the summary`.
- **Claude Managed Agents scheduled deployments** — `deployments.create()` with a cron expression +
  IANA timezone; every firing creates a session and writes a `deployment_run` record (with a typed
  error when session creation fails), so missed audits are auditable. Test with the manual
  `deployments.run()` endpoint before committing to the schedule.

Either way, the audit's memory file is what makes the recurring run compound instead of repeat.

---

## The Fable 5 safety boundary (security-adjacent work)

Fable 5 ships with safety classifiers (cybersecurity, biology/chemistry, model distillation) that
can **false-positive on legitimate security-adjacent audit work** — auth flows, crypto code, exploit-
shaped test fixtures. A classifier decline is not an error: the API returns HTTP 200 with
`stop_reason: "refusal"` (pre-output refusals are unbilled). Design for it:

- Check `stop_reason` before treating an empty result as a crash.
- On the API, fallback is **opt-in**: the beta `fallbacks` parameter retries on Opus 4.8 server-side,
  the SDK middleware does it client-side, or retry manually. Consumer surfaces (Claude.ai, Claude
  Code) handle the fallback automatically.
- A refused dimension or audit section should be *reported as refused*, not silently skipped.

---

## Memory Pattern for Org Audits

Apply the full fail → investigate → verify → distill → consult progression:

| Stage | Example for the Ingest dimension |
|---|---|
| **Fail** | "Ingest shows the verification verdict unresolvable on 40% of events" |
| **Investigate** | "The device ID in those events doesn't match any registered device" |
| **Verify** | "Confirmed: the field device reports ID-011 but the org's registry declares ID-009" |
| **Distill** | "Rule: cross-check event device IDs against the org's registry before marking ingest healthy" |
| **Consult** | Next audit reads this rule and checks it immediately without re-investigating |

---

## Output Location

```
~/.claude/audits/
  org-<slug>-<date>.md     ← point-in-time report
  org-<slug>-memory.md     ← verified rules across runs (distilled only)
```

Keep both files. The report is a snapshot; the memory file is the accumulation.

---

## Quick Reference

| Grade | Meaning | Action |
|---|---|---|
| 🟢 Healthy | Dimension working as intended | Monitor |
| 🟡 Degraded | Working but not fully | Queue in the org's work program |
| 🔴 Broken | Not working — user impact | Fix before next demo/deal |
| ⚫ Not configured | Never set up | Decide: configure now or document as out-of-scope |

**Overall grade formula:** A = all 🟢 · B = ≤2 🟡 · C = ≤1 🔴 or many 🟡 · D = multiple 🔴 ·
F = critical path broken (billing + ingest both 🔴)

---

## Common Mistakes

| Mistake | Fix |
|---|---|
| Confusing this with `/fable-repo-audit` | This audits a *live org integration*, not code — don't look at source files |
| Skipping the memory read at session start | Always read `org-<slug>-memory.md` first — avoids re-investigating known issues |
| Treating 🟡 Degraded as fine | Degraded today becomes 🔴 Broken after the next deploy or trial expiry |
| Auditing without an operator credential | Most platform endpoints require an authenticated operator session |
| Writing raw failure notes to memory | Only distilled, verified rules go in `memory.md` — failures stay in the report |
| Porting the pattern without mapping endpoints | Write your platform's dimension→endpoint map first — see the worked example |

## Related Skills

- `/fable-repo-audit` — audit the platform *codebase*, not a customer org
- `/fable-loop-design` — design the self-correction loop that runs this audit weekly
- `/fable-orchestrated-feature-dev` — fix gaps the audit surfaces

## References

- `references/worked-example-platatlas.md` — the original PlatAtlas probe set, endpoint by
  endpoint, with per-dimension grading thresholds. The template for your own platform mapping.
