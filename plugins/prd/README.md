# prd — write the spec

Generates a clear, implementation-ready **Product Requirements Document** from a feature
description. Instead of interviewing you, it **self-clarifies**: it asks itself the 3–5 critical
questions (problem, core functionality, scope boundaries, success criteria, constraints), answers
them from available context, shows its reasoning, and then writes the PRD.

## Before you install

This skill deliberately does *not* ask you questions and does *not* implement anything — it
produces a document. That makes it safe to chain (e.g. `build-options` invokes it with the winning
option as input) and fast to use standalone. If its self-clarification answers are wrong, correct
them and re-run; the answers are printed before the PRD.

## What it will ask you

Nothing. It answers its own clarifying questions from your request, the codebase, and any
analysis you provide — preferring conservative, smaller scope.

## What it produces

`/tasks/prd-<feature-name>.md` — overview, goals, user stories, functional requirements,
non-goals, success metrics, and open questions. Ready for the `tasks` skill to convert into an
executable task plan.

## Cost

Minimal — single-model document generation, no subagents.

## 60-second first run

```
/prd  — "create a prd for <feature>"
```

Read the Self-Clarification block first (that's where errors would live), then the PRD.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Skills chaining | `build-options` → **prd** → `tasks` | [Skills](https://code.claude.com/docs/en/skills) |
| Context gathering | Reads the codebase + AGENTS.md instead of interviewing you | [Claude Code overview](https://code.claude.com/docs/en/overview) |
