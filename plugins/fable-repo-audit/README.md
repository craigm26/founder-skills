# fable-repo-audit — an honest map before you change anything

A four-phase, principal-level repository audit: **discovery → evidence-based findings →
improvement strategy → milestone task plan.** Every finding cites file paths and line numbers;
strengths get a section too; nothing is modified — analysis only.

## Before you install

Use it before a refactor, before onboarding a contributor, before committing to a codebase, or
after a long sprint. Not for quick "what does this file do?" questions. Tell it the project's
maturity (prototype / internal / production) for calibrated recommendations.

## What it will ask you

Nothing during the audit. Afterwards, one question: convert the task plan into an
implementation run via `/fable-orchestrated-feature-dev`?

## What it produces

One report at `~/.claude/audits/<repo-slug>-<date>.md`: executive summary with an A–F grade,
repo map, severity-rated findings across 8 dimensions (architecture, quality, security, testing,
performance, dependencies, devex, docs), improvement strategy, and a milestone task plan with
quick wins flagged.

## Cost

One deep Fable pass over the repo — typically tens of thousands of tokens for a mid-size repo;
large repos get depth on the core 20% with lighter areas noted.

## 60-second first run

```
/fable-repo-audit — "audit this repo; it's a production service"
```

Read the Executive Summary and Quick Wins first — and the Strengths section before changing anything.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Subagents | Fable as a sealed analysis-only auditor | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| Skills chaining | Audit task plan → `/fable-orchestrated-feature-dev` | [Skills](https://code.claude.com/docs/en/skills) |
