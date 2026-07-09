---
name: founder-effort
description: >-
  Use when declaring or checking the token budget / model tier for this session. Triggers on:
  "set effort", "how much budget do we have", "low on tokens", "use opus", "use sonnet",
  "constrained this week", or any explicit model-tier selection. Can also be called mid-session
  to downgrade tier when tokens run low.
---

# Founder Effort

A single-question calibrator that sets the **model routing tier** for the session. Every downstream
skill that routes to Opus vs. Sonnet vs. an external executor reads this decision. Set it once; change it if
the situation changes mid-session.

> Not to be confused with Claude Code's built-in `/effort` command, which sets the current model's
> *reasoning effort* (thinking depth) and never changes which model runs. This skill was renamed
> from `effort` to `founder-effort` to avoid that collision.

**Announce at start:** "Using founder-effort to set the token budget tier."

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
`/founder-effort` again and re-announce. Downstream skills will adjust routing automatically.

---

## Related API primitives (don't confuse them with this skill)

This skill routes **which model** handles each role for the session. The Claude API has two
*per-request* controls with similar names:

| Primitive | What it controls |
|---|---|
| `output_config.effort` (`low`/`medium`/`high`/`xhigh`/`max`) | Thinking depth and token spend within one request |
| Task Budgets (`output_config.task_budget`, beta `task-budgets-2026-03-13`, min 20,000 tokens) | A model-visible token countdown for a whole agentic loop — the model self-moderates |

Useful, officially documented fact for the Constrained tier: on Fable 5, **lower effort settings
still perform very well — often exceeding the `xhigh`/`max` performance of previous models** — so
dialing effort down is a legitimate budget lever before downgrading models.

---

## Model reference

| Model | Best for | Token cost |
|---|---|---|
| Opus 4.8 | Complex reasoning, planning, architectural review | High |
| Sonnet 4.6 | Feature implementation, iteration, most tasks | Medium |
| External executor (any plan-runner) | Executing a written plan file with minimal Claude token spend | Minimal |

See: [Claude models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) ·
[Interactive mode / AskUserQuestion](https://code.claude.com/docs/en/interactive-mode)
