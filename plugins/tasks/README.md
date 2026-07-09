# tasks — break the spec into machine-verifiable work

Converts a PRD markdown file into `prd.json` — an ordered task plan where **every acceptance
criterion is a boolean check an agent can pass or fail on its own** ("run `npm test` — exits 0",
"file X contains Y", "POST /api/signup returns 200"). This is what makes the plan executable by an
implementation model or external executor without a human in the loop.

## Before you install

The skill's core discipline is the **golden rule**: no vague criteria ("works correctly", "looks
good") survive into the plan. Tasks are exploded into granular sub-tasks and ordered by dependency
(investigation → schema → backend → UI → verification). It runs autonomously — no questions asked.
No third-party tools required: browser-based criteria are written as generic capability patterns
(open / click / fill / screenshot / console-check) that any browser executor the executing agent
has can satisfy.

## What it will ask you

Nothing. Point it at a PRD file (typically `/tasks/prd-<feature>.md` from the `prd` skill) and it
generates the JSON immediately.

## What it produces

- `prd.json` — dependency-ordered tasks, each with machine-verifiable acceptance criteria and an
  initial `passes: false`, ready to hand to whichever implementation tier your `/founder-effort` setting
  chose.
- A summary: task count, priority order, branch name, saved path.
- A worked example ships with the plugin (`references/example-signup-fix.md`) showing a one-line
  PRD task exploded into a 10-task plan.

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
