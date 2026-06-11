# fable-org-audit — is this org actually getting value?

A **live integration audit** of a customer organization on your platform: probes real API
signals across eight dimensions (ingest, graph, status program, geo/field, hypotheses, billing,
metrics, edge devices), grades each 🟢 🟡 🔴 ⚫, and produces a prioritized gap list. A product
health check — explicitly *not* a code review.

## Before you install

This ships as a **portable pattern**. It was built against a specific platform (PlatAtlas);
`references/worked-example-platatlas.md` preserves the original endpoint-by-endpoint probe set
with grading thresholds. To run it on your platform, write your own dimension→endpoint map first
— the worked example shows the shape. You'll need an authenticated operator session for the org.

## What it will ask you

Nothing — give it the org slug and base URL. It reads its own memory file from prior audits
before probing.

## What it produces

- `~/.claude/audits/org-<slug>-<date>.md` — executive summary (A–F), per-dimension grades,
  prioritized gap list with effort estimates
- `~/.claude/audits/org-<slug>-memory.md` — verified rules that make next week's audit start smarter

## Make it recurring

The skill documents two real triggers for the weekly cadence: Claude Code **`/schedule` routines**
(cloud runs, laptop off) and **CMA scheduled deployments** (cron + a per-firing audit trail).
Security-adjacent probing is refusal-aware: a Fable 5 classifier decline is reported as refused,
never silently skipped.

## Cost

One Fable pass with live API probes — modest tokens; the expensive part is honesty, not volume.

## 60-second first run

```
/fable-org-audit — "audit org acme-fields on https://yourplatform.com"
```

Treat any 🔴 as an incident before the next demo; queue 🟡 into the org's work program.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Subagents | Fable as live-API auditor with its own memory file | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| Memory pattern | fail → investigate → verify → distill → consult across weekly runs | [Memory](https://code.claude.com/docs/en/memory) |
| Skills chaining | Gaps feed `/fable-orchestrated-feature-dev`; cadence via `/fable-loop-design` | [Skills](https://code.claude.com/docs/en/skills) |
