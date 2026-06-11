# fable-orchestrated-feature-dev — plan, implement, review

The Fable 5 orchestration pattern for building features: **Fable writes a detailed plan to a
file, an implementation model (Opus 4.8 or Sonnet 4.6) executes it exactly, Fable reviews the
output against the spec.** Fable never writes implementation code — the separation keeps the
planner honest and the implementer focused.

## Before you install

This skill assumes you're comfortable spawning subagents and passing file paths between them.
The plan file (`~/.claude/plans/<slug>-<date>.md`) is the load-bearing artifact: it survives the
session, any executor can pick it up, and the review step grades against it.

## What it will ask you

At most one question — "Opus or Sonnet this week?" — and only if the token-budget signal is
genuinely ambiguous. Pair with `/effort` to make that signal explicit up front.

## What it produces

- A timestamped plan file: objective, files to touch, ordered tasks, acceptance criteria
- The implemented feature (by the chosen implementer model)
- Fable's review: which acceptance criteria are met, which are missing, any deviations

## Cost

Plan + review are a few thousand tokens of Fable; implementation cost depends on the feature and
the tier chosen. The external-executor fallback (hand the plan file to a cheaper Claude session,
Haiku 4.5, or a third-party plan-runner) costs almost nothing from this session.

## 60-second first run

```
/fable-orchestrated-feature-dev — "add CSV export to the reports page"
```

Watch for the gate: implementation must not start until the plan file exists on disk.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Subagents | Planner / implementer / reviewer in separate contexts | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| Model routing | Opus vs Sonnet vs external executor, by token budget | [Models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) |
| Skills chaining | `/effort` sets the tier; `/fable-repo-audit` output can be the plan | [Skills](https://code.claude.com/docs/en/skills) |
