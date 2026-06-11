# fable-loop-design — design the loop, not the steps

For getting the most out of Fable 5: **don't prompt and steer step-by-step — design loops that
let the model self-correct against environment feedback.** Two loop types: in-session
self-correction (rubric + independent verifier sub-agent) and cross-session memory
(fail → investigate → verify → distill → consult).

## Before you install

The core discipline is that **the grader is never the doer**: a verifier sub-agent in a fresh
context window grades against a rubric of checkable criteria, because models grade their own
output poorly. The second discipline is that memory holds *distilled, verified rules* — raw
failure notes are source material, not the product.

## What it will ask you

Nothing — it's a design skill. You bring the task; it walks you through choosing the loop type,
writing a falsifiable rubric, and structuring the memory files.

## What it produces

- A rubric file of checkable criteria
- A loop harness design (using `/loop`, the Workflow tool, or Managed Agents Outcomes)
- A memory layout (`rules.md` / `open-questions.md` / `failures.md`) with promotion rules

## Cost

Minimal — design conversation plus small files. The loops it designs are where tokens go later.

## 60-second first run

```
/fable-loop-design — "design a loop that improves our test flakiness detector until it passes a rubric"
```

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Subagents | Independent verifier in a fresh context | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| Agent SDK / Workflow | Custom loop harnesses with schema-validated verdicts | [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) |
| Memory | The cross-session outer loop | [Memory](https://code.claude.com/docs/en/memory) |
