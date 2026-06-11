# session-start — the judgment layer entry point

Calibrates a Claude Code session before any work begins: three structured questions establish the
**effort tier** (which model to route to), the **domain** (what kind of work this is), and what
**done looks like**. The answers route you to the right skill chain and are inherited by every
downstream skill.

## Before you install

This skill does no work itself — it spends ~30 seconds of structured questions so the next several
hours of agentic work go in the right direction at the right cost. Expect one `AskUserQuestion`
dialog (three questions in a single call), then an announced routing decision.

## What it will ask you

1. **Effort level** — Quick exploration · Focused sprint · Deep build · Constrained
   (sets the model routing tier for the whole session)
2. **Domain** — New product idea · Existing feature · Research/analysis · Infrastructure
3. **Done looks like** — A decision · A plan file · Merged code · A shareable artifact

## What it produces

- A **session context block** saved to `~/.claude/session-context.md` (effort tier, model routing,
  domain, goal) — a scratchpad downstream skills read, overwritten each session.
- A **routing announcement**: which skill chain fits this session
  (e.g. new idea + plan file → `/market-validation` → `/build-options` → `/prd` → `/tasks`).
- A short list of **pending items** surfaced from your Claude Code
  [memory](https://code.claude.com/docs/en/memory), if any are relevant.

## Cost

Minimal — a few hundred tokens. The point is that those tokens govern how the session's millions
get spent.

## 60-second first run

```
/session-start
```

Answer the three questions. The skill announces something like:

> Effort: Focused. Planning → Opus 4.8, implementation → Sonnet 4.6.
> This session I'll route to /prd → /tasks. Say the skill name to begin.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| `AskUserQuestion` | Collects session context with typed options | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| Memory | Surfaces pending items from prior sessions | [Memory](https://code.claude.com/docs/en/memory) |
| Model routing | Selected once here; downstream skills inherit it | [Models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) |
| Skills | This skill activates the right chain; it does not do the work | [Skills](https://code.claude.com/docs/en/skills) |
