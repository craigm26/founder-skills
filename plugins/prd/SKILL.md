---
name: prd
description: >-
  Generate an implementation-ready Product Requirements Document for a feature: self-clarify the
  open questions (no user interview), then write a structured PRD — goals, one-session tasks with
  verifiable acceptance criteria, numbered functional requirements, non-goals — saved to
  /tasks/prd-<feature-name>.md, ready for the `tasks` skill to convert into an executable plan.
  Use when the user asks "create a prd", "write a prd for X", "plan this feature",
  "spec out X", "requirements for X", or after running `build-options` (its Phase 4 hands the
  winning option here).
---

# PRD

Turns a feature description into a clear, implementation-ready PRD an AI agent (or a human) can
execute from. Third link in the founder chain `/market-validation` → `/build-options` → **`/prd`**
→ `/tasks`. A full worked example ships in `references/example-prd-task-priority.md` — mirror it
closely. Distinct from `/build-options` (which decides WHAT to build; this skill specs the chosen
thing) and from `/tasks` (which converts the finished PRD file into `prd.json`).

**Announce at start:** "Using prd to spec <feature> — self-clarifying, then writing the PRD to `/tasks/`."

## Before you start
- **Cost/time:** minimal — single-model document generation; no subagents, no Workflow.
- **No questions, no code:** this skill never calls AskUserQuestion (it *self-clarifies* from
  context) and never implements anything. It produces one document, then stops.
- **Model routing:** authoring a PRD is planning work — it stays with the session's planning
  model. Read the tier from `~/.claude/session-context.md` (set once via `/effort` or
  `/session-start`); don't re-ask. Fable 5 plans and reviews and never writes implementation
  code — this document is squarely its job. The PRD's tasks get implemented downstream at the
  tier's implementation model (Opus 4.8 for complex work, Sonnet 4.6 for standard, an external
  executor when tokens are exhausted).
- **Input:** a feature description. Chained from `/build-options`, that is the winning option's
  `thesis` + `mvpScope` + `businessModel` + key constraints (its Phase 4). Standalone, it is the
  user's request plus codebase context (AGENTS.md/CLAUDE.md, existing patterns, any reports provided).

## Phase 1 — Self-clarify

Before writing anything, ask yourself these five questions and **print your answers** (they are
where errors would live, so the user can correct them and re-run):

1. **Problem/Goal:** What problem does this solve? Why now?
2. **Core Functionality:** What are the 2–3 key actions this enables?
3. **Scope/Boundaries:** What should this explicitly NOT do? (Be conservative — prefer smaller scope.)
4. **Success Criteria:** How do we verify it's working? (Must be verifiable.)
5. **Constraints:** What technical/time constraints exist? (Note any stated ones, e.g. "no DB migrations".)

Emit the answers in this exact block, then proceed — do not wait for approval:

```
## Self-Clarification

1. **Problem/Goal:** [answer from the request and codebase context]
2. **Core Functionality:** [answer]
3. **Scope/Boundaries:** [answer — conservative]
4. **Success Criteria:** [answer — verifiable]
5. **Constraints:** [answer]
```

## Phase 2 — Write the PRD

Generate the PRD with these sections, in order (see the worked example for the full shape):

| # | Section | Contains |
|---|---|---|
| 1 | Introduction/Overview | Brief description of the feature and the problem it solves |
| 2 | Goals | Specific, measurable objectives (bullet list) |
| 3 | Tasks | `T-00n` blocks — see the format below; aim for 8–15 (the `/tasks` skill's target granularity) |
| 4 | Functional Requirements | Numbered `FR-n:` statements ("FR-1: The system must allow users to…") |
| 5 | Non-Goals (Out of Scope) | What this feature will NOT include — critical for managing scope |
| 6 | Technical Considerations | *Optional:* constraints, dependencies, integration points, performance |
| 7 | Success Metrics | How success will be measured |
| 8 | Open Questions | Remaining unknowns needing clarification |

Each task must be small enough to implement in one focused session, in this format:

```markdown
### T-001: [Title]
**Description:** [What to implement]

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] Quality checks pass
- [ ] **[UI tasks only]** Verify in browser
```

Acceptance-criteria discipline — the reader may be an AI agent, so criteria must be boolean and
machine-checkable:

| Do | Don't |
|---|---|
| "Button shows confirmation dialog before deleting" | "Works correctly" |
| Include "Verify in browser" on every task that touches UI | Ship a UI task with no runtime check |
| Number requirements (`FR-1`, `T-001`) for easy reference | Bury requirements in prose |
| Be explicit and unambiguous; explain jargon; give concrete examples | Assume the reader shares your context |

## Phase 3 — Save and hand off to `/tasks`

- **Location + filename (the chain contract — do not change):** `/tasks/prd-<feature-name>.md`,
  kebab-case, markdown. The `/tasks` skill reads exactly this path pattern and converts the file
  into `prd.json` for the execution loop.
- Before saving, check: self-clarification printed (all 5 answered) · tasks small and one-session
  each · acceptance criteria verifiable · functional requirements numbered · non-goals present.
- Hand off by **file path, never inline content**: tell the user (or the chaining skill) the saved
  path and that `/tasks` is the next step. Surface the file to the user (SendUserFile).

## Deliverables

One file: `/tasks/prd-<feature-name>.md` — self-clarification block + the 8-section PRD.

## Known limitations (keep your honesty consistent)

- **The `/build-options` → `/prd` handoff is described, not yet exercised** (mirrors the admission
  in build-options' own Known limitations). On the first chained run, confirm the PRD actually
  lands in `/tasks/` before telling the user the chain worked.
- **Self-clarification answers come from context, not the user.** On a thin repo or vague request
  they can be confidently wrong — that is why the block is printed before the PRD. Correct-and-re-run
  is the intended fix loop; the skill does not detect its own bad answers.
- **Task sizing is judgment, not measurement.** "One focused session" is not verified by anything;
  the 8–15 target comes from `/tasks`' granularity guidance, not from measured runs.

## References

- `references/example-prd-task-priority.md` — full worked example PRD (fictional Task Priority
  System); mirror its task format and acceptance criteria.
- `/build-options` SKILL.md Phase 4 — the upstream handoff that feeds this skill.
- `/tasks` SKILL.md — the downstream consumer of `/tasks/prd-<feature-name>.md`.
