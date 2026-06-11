---
name: effort
description: >-
  Use when declaring or checking the token budget / model tier for this session. Triggers on:
  "set effort", "how much budget do we have", "low on tokens", "use opus", "use sonnet",
  "constrained this week", or any explicit model-tier selection. Can also be called mid-session
  to downgrade tier when tokens run low.
---

# Effort

A single-question calibrator that sets the **model routing tier** for the session. Every downstream
skill that routes to Opus vs. Sonnet vs. an external executor reads this decision. Set it once; change it if
the situation changes mid-session.

**Announce at start:** "Using effort to set the token budget tier."

---

## The question

Run `AskUserQuestion` with exactly one question:

```
header: "Token budget"
question: "What's the effort tier for this session?"
options:
  - label: "Ample — Opus 4.8 (Recommended for new work)"
    description: "Full capability throughout. Best for planning, architectural decisions, high-stakes reviews."
  - label: "Moderate — Sonnet 4.6"
    description: "Strong capability, lower cost. Right for most feature work, research, and iteration."
  - label: "Constrained — Sonnet + external executor"
    description: "Sonnet for planning and short tasks; hand heavy implementation off as a written plan file to an external executor (a cheaper Claude session, Haiku 4.5, or a third-party plan-runner) to preserve remaining tokens."
  - label: "Sprint end — plans only"
    description: "Tokens nearly exhausted. Fable writes plans only; all implementation goes to an external executor. No generation here."
```

---

## After the answer

Announce the routing decision in one line:

| Tier | Announce |
|---|---|
| Ample | "Effort: Ample. Routing planning and implementation to **Opus 4.8**." |
| Moderate | "Effort: Moderate. Planning → **Opus 4.8**, implementation → **Sonnet 4.6**." |
| Constrained | "Effort: Constrained. All work → **Sonnet 4.6**; heavy lifts → **an external executor** (plan file handoff)." |
| Sprint end | "Effort: Sprint end. Plans only. Implementation → **external executor** (hand it the plan file)." |

Save to `~/.claude/session-context.md` (append or overwrite the `effort_tier` line).

---

## Mid-session downgrade

If you observe token pressure mid-session (context approaching limits, user mentions it), call
`/effort` again and re-announce. Downstream skills will adjust routing automatically.

---

## Model reference

| Model | Best for | Token cost |
|---|---|---|
| Opus 4.8 | Complex reasoning, planning, architectural review | High |
| Sonnet 4.6 | Feature implementation, iteration, most tasks | Medium |
| External executor (any plan-runner) | Executing a written plan file with minimal Claude token spend | Minimal |

See: [Claude models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) ·
[Interactive mode / AskUserQuestion](https://code.claude.com/docs/en/interactive-mode)
