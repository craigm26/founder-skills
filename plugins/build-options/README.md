# build-options — what should I build?

Turns a validated market into a **defensible choice** among concrete build options: divergent
options are generated through different strategic lenses, scored by an independent judge panel
into a weighted decision matrix, the leaders are adversarially stress-tested, and one option is
recommended — with explicit **kill criteria** so you know when to abandon it.

## Before you install

Designed to chain after `market-validation` (it reads that run's `deck-data.json` and brief), but
works standalone from a short brief you provide. Scores are directional, not precise — the skill
always shows the full matrix and never a bare verdict, and LLM judges tend to cluster, so the real
lever is the criteria **weights** you confirm up front.

## What it will ask you

One `AskUserQuestion` round (Phase 0): budget/time horizon, risk appetite, must-reuse assets, and
confirmation of the default scoring criteria + weights (you can adjust; weights must sum to 1.0).

## What it produces

- `decision-data.json` — context, criteria, every option's scores, the recommendation, kill criteria
- `<slug>.html` — a Tufte decision matrix (+ `.pdf`/`.pptx` when the toolchain is present)
- A handoff into the `prd` skill: the winning option's thesis + MVP scope becomes the PRD input

## Cost

~12 agents (6 generators + 3 judges + ~3 skeptics) — roughly 300–600k tokens, well under a
market-validation run.

## 60-second first run

```
/build-options  — "what should I build for <validated market>?"
```

Confirm the framing and weights, let the judge panel run, read the matrix. A worked example
(fictional **ShiftMate**) ships in [`references/example-shiftmate/`](references/example-shiftmate/).

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| `Workflow` tool | generate → judge → stress-test pipeline with deterministic control flow | [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) |
| Subagents | Independent judges and adversarial skeptics (the independence is the point) | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| `AskUserQuestion` | Framing + weight confirmation | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| Skills chaining | `market-validation` → **build-options** → `prd` → `tasks` | [Skills](https://code.claude.com/docs/en/skills) |
