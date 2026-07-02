# prd — write the spec

Generates a clear, implementation-ready **Product Requirements Document** from a feature
description. Instead of interviewing you, it **self-clarifies**: it asks itself the five critical
questions (problem, core functionality, scope boundaries, success criteria, constraints), answers
them from available context, prints its reasoning, and then writes the PRD.

## Before you install

This skill deliberately does *not* ask you questions and does *not* implement anything — it
produces a document, then stops. That makes it safe to chain (`build-options` hands it the winning
option; `tasks` consumes its output) and fast to use standalone. If its self-clarification answers
are wrong, correct them and re-run — the answers are printed before the PRD, on purpose. A full
worked example ships in `references/example-prd-task-priority.md`.

## What it will ask you

Nothing. It answers its own clarifying questions from your request, the codebase
(AGENTS.md/CLAUDE.md, existing patterns), and any analysis you provide — preferring conservative,
smaller scope.

## What it produces

- `/tasks/prd-<feature-name>.md` — the printed self-clarification block plus an 8-section PRD:
  overview, goals, 8–15 one-session tasks with verifiable acceptance criteria, numbered functional
  requirements, non-goals, optional technical considerations, success metrics, open questions.
- Ready for the `tasks` skill to convert into an executable `prd.json` task plan.

## Cost

Minimal — single-model document generation, no subagents, no Workflow. Runs at your session's
planning tier (set via `/effort`).

## 60-second first run

```
/prd  — "create a prd for <feature>"
```

Read the Self-Clarification block first (that's where errors would live), then the PRD. If an
answer is wrong, say so and re-run.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Skills chaining | `build-options` → **prd** → `tasks`, handing off by file path | [Skills](https://code.claude.com/docs/en/skills) |
| Context gathering | Reads the codebase + AGENTS.md instead of interviewing you | [Claude Code overview](https://code.claude.com/docs/en/overview) |
