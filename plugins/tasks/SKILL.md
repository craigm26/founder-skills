---
name: tasks
description: >-
  Convert a PRD markdown file (typically `/tasks/prd-<feature>.md` from the `prd` skill) into
  `prd.json` — an ordered, dependency-sorted execution plan where every acceptance criterion is a
  boolean check an agent can pass or fail without a human. Use when the user asks "convert prd",
  "create tasks", "prd to json", "generate tasks from prd", or after running `/prd` at the end of
  the `/market-validation → /build-options → /prd → /tasks` chain.
---

# Tasks

Turns a PRD into `prd.json`, the machine-verifiable task plan the execution loop consumes. Last
link of the founder chain; pairs with `/prd` (before) and whatever executes the plan (after).
Distinct from `/prd`: that skill *writes* the spec, this one *explodes* it into checkable work.
Worked example: `references/example-signup-fix.md`.

**Announce at start:** "Converting the PRD to prd.json — every acceptance criterion will be a
boolean check an agent can verify on its own."

## Before you start

- **Cost:** minimal — a single-model conversion, no subagents, no Workflow.
- **Autonomous mode:** do NOT ask questions. Use the PRD content and any provided context (branch
  name, output path) and generate `prd.json` immediately.
- **Model routing:** this skill converts; it does not implement. The plan it emits is executed by
  the implementation tier already chosen via `/founder-effort` or `/session-start` (read
  `~/.claude/session-context.md` — don't re-ask): Opus 4.8 for complex work, Sonnet 4.6 for
  standard work, or an external executor as the token-exhausted fallback. Fable 5 plans and
  reviews and never writes implementation code.

## Phase 1 — Read the PRD

Read the PRD file the user specified (typically `/tasks/prd-<feature-name>.md`, written by
`/prd`). Extract every work item: Tasks (`T-001`…), User Stories (`US-001`…), Functional
Requirements (`FR-1`…), or any numbered/bulleted list of work.

## Phase 2 — Explode into machine-verifiable sub-tasks

Every task must be **autonomously verifiable** by an agent without human intervention. The golden
rule: each acceptance criterion is a **boolean check** the agent can definitively pass or fail.

| Reject (vague/subjective) | Accept (machine-verifiable) |
|---|---|
| "Works correctly" | "Run `npm run typecheck` — exits with code 0" |
| "Review the configuration" | "File `src/auth/config.ts` contains `redirectUrl: '/onboarding'`" |
| "Verify it looks good" | "Open `/signup` — page loads with no console errors" |
| "Identify the issue" | "Log the routing prop value to the task's `notes` field" |

Write criteria as one of these capability patterns:

| Type | Pattern | Example |
|---|---|---|
| Command | "Run `[cmd]` — exits with code 0" | "Run `npm test` — exits with code 0" |
| File check | "File `[path]` contains `[string]`" | "File `middleware.ts` contains `clerkMiddleware`" |
| Browser: open | "browser: open `[url]` — [expected result]" | "browser: open /login — SignIn component renders" |
| Browser: interact | "browser: click/fill `[element]` — [expected result]" | "browser: click 'Submit' — redirects to /dashboard" |
| Browser: console | "browser: console shows no errors" | |
| Browser: screenshot | "browser: screenshot shows `[element]` visible" | "browser: screenshot shows CTA above fold" |
| API check | "GET/POST `[url]` returns `[status]` with `[body]`" | "POST /api/signup returns 200" |

Browser criteria assume the executing agent has a **browser executor** — any tool it can drive
that supports open / snapshot / click / fill / screenshot / console-check (such as agent-browser,
or the host's own browser tooling). Write the criteria as the capability patterns above, never as
tool-specific command lines — the executor is the executing agent's choice, not this plan's
dependency. If the target environment has no browser executor, substitute command/file/API checks
(e.g. "GET /signup returns 200 and body contains `<form`").

## Phase 3 — Size and split

- **Target 8–15 tasks per PRD.** Fewer than 6 usually means tasks need further splitting.
- **One concern per task:** navigate, check errors, test validation, test submission, verify
  redirect, test a viewport, implement a fix, verify the fix — each is its own task.
- **Never combine "find the problem" with "fix the problem"** in one task: investigation tasks log
  findings to `notes`; a later implementation task reads them.
- **One iteration each:** every task must be completable in roughly one context window. "Test the
  entire signup flow" or "add authentication" are too big — split into load page / inputs / submit
  / redirect, or schema / middleware / UI / session.

## Phase 4 — Order by dependencies

Set `priority` (lower number = executed first):

| Work type | Priority |
|---|---|
| Investigation (understand before changing) | 1–3 |
| Schema/database changes | 4–5 |
| Backend logic | 6–7 |
| UI components | 8–9 |
| Verification (browser/API end-to-end) | 10+ |

## Phase 5 — Emit `prd.json`

Write the file in exactly this shape — **the field names and semantics are a downstream contract;
do not rename or repurpose them.** Every task starts with `passes: false` and `notes: ""`:

```json
{
  "project": "Project Name",
  "branchName": "compound/[feature-name]",
  "description": "[One-line description from PRD]",
  "tasks": [
    {
      "id": "T-001",
      "title": "[Specific action verb] [specific target]",
      "description": "[1-2 sentences: what to do and why]",
      "acceptanceCriteria": [
        "Specific machine-verifiable criterion with expected outcome",
        "Run `npm run typecheck` - exits with code 0"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

Save immediately — do not wait for user confirmation — then summarize: task count, order with
priorities, branch name, and the saved file path. Because every criterion is boolean, a task's
`acceptanceCriteria` export directly as a Managed Agents **Outcome rubric** ("explicit,
independently gradeable criteria") — see `/fable-orchestrated-feature-dev` Step 3c for the
hosted-executor flow.

## Checklist (before saving)

- [ ] 8–15 tasks generated (not 3–5)
- [ ] Each task does ONE thing; investigation separated from implementation
- [ ] Every criterion is boolean pass/fail — no "review", "identify", "verify it works"
- [ ] Commands state expected exit codes; browser criteria state expected results
- [ ] All tasks have `passes: false`; priorities reflect dependencies
- [ ] The JSON parses (`python3 -m json.tool prd.json`)

## Known limitations (keep your honesty consistent)

- **The `prd.json` shape is a contract, not a suggestion** — downstream executors key on
  `id`/`title`/`description`/`acceptanceCriteria`/`priority`/`passes`/`notes` exactly. Nothing in
  this skill validates the file; run `python3 -m json.tool` before handing it off.
- **Criteria quality is bounded by PRD quality.** A vague PRD yields tasks you must sharpen
  yourself in Phase 2; the skill cannot invent missing acceptance conditions.
- **Browser criteria are only checkable if the executing environment has a browser executor.**
  State the capability assumption in the summary; where it may be absent, prefer command/file/API
  forms.
- **The `/prd` → `/tasks` chain handoff is described, not continuously exercised** — on a chained
  run, confirm the PRD actually landed in `/tasks/` before converting.

## References

- `references/example-signup-fix.md` — full worked example: a one-line PRD task exploded into a
  10-task `prd.json` (investigation → fix → verification), with the split rationale.
