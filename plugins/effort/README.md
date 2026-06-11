# effort — the token budget calibrator

A single-question selector that sets the **model routing tier** for the session: Opus 4.8 for full
capability, Sonnet 4.6 for most work, or plans-only with an external executor when tokens are
tight. Every downstream skill that routes work between models reads this decision.

## Before you install

Use it standalone, or let `/session-start` set the tier as part of its broader calibration. The
useful property is that it can be re-run **mid-session**: when token pressure appears, one call
downgrades the tier and downstream skills adjust.

## What it will ask you

One `AskUserQuestion`:

- **Ample** — Opus 4.8 throughout (planning, architecture, high-stakes review)
- **Moderate** — Sonnet 4.6 (most feature work, research, iteration)
- **Constrained** — Sonnet + hand heavy implementation off as a written plan file to an
  external executor (a cheaper Claude session, Haiku 4.5, or a third-party plan-runner)
- **Sprint end** — plans only; all implementation goes to the external executor

## What it produces

A one-line routing announcement and an `effort_tier` entry in `~/.claude/session-context.md`.

## Cost

Negligible — one question, one announcement.

## 60-second first run

```
/effort
```

Pick a tier. The skill announces, e.g.:

> Effort: Moderate. Planning → Opus 4.8, implementation → Sonnet 4.6.

If you hit token pressure later, run `/effort` again and pick a lower tier.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| `AskUserQuestion` | The single typed question | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| Model routing | The decision this skill exists to make explicit | [Models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) |
