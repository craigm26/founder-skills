# tasks — break the spec into machine-verifiable work

Converts a PRD markdown file into `prd.json` — an ordered task plan where **every acceptance
criterion is a boolean check an agent can pass or fail on its own** ("run `npm test` — exits 0",
"file X contains Y", "POST /api/signup returns 200"). This is what makes the plan executable by an
implementation model or external executor without a human in the loop.

## Before you install

The skill's core discipline is the **golden rule**: no vague criteria ("works correctly", "looks
good") survive into the plan. Tasks are exploded into granular sub-tasks and ordered by dependency
(schema → backend → UI → tests). It runs autonomously — no questions asked.

## What it will ask you

Nothing. Point it at a PRD file (typically `/tasks/prd-<feature>.md` from the `prd` skill) and it
generates the JSON immediately.

## What it produces

`prd.json` — tasks with dependencies and machine-verifiable acceptance criteria, ready to hand to
whichever implementation tier your `/effort` setting chose.

## Outcome rubric export

Because every criterion is a boolean check, a `prd.json` task's acceptance criteria export directly
as a Managed Agents **Outcome rubric** — the format Outcomes requires ("explicit, independently
gradeable criteria"). That makes `tasks` the bridge from the planning chain to hosted autonomous
execution.

## Cost

Minimal — single-model conversion, no subagents.

## 60-second first run

```
/tasks  — "convert /tasks/prd-my-feature.md to prd.json"
```

Skim the acceptance criteria: if any aren't checkable by a machine, that's a bug — re-run or fix.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Skills chaining | `prd` → **tasks** → implementation → review | [Skills](https://code.claude.com/docs/en/skills) |
| Agent-verifiable criteria | The plan is written for autonomous execution | [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) |
