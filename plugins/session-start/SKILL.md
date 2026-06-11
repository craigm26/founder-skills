---
name: session-start
description: >-
  Use at the beginning of any new session — before any work begins — to establish effort tier,
  session goal, and skill routing. Triggers on: "start a session", "let's begin", "new session",
  "kick off", "where do we start", or whenever a fresh context needs calibration before a build,
  research, or planning task.
---

# Session Start

The judgment layer entry point. Runs before any work — establishes the three variables every
downstream skill needs: **effort tier** (which model to route to), **goal clarity** (what success
looks like), and **skill routing** (which skills apply this session).

**Announce at start:** "Using session-start to calibrate this session."

---

## Step 1 — Calibrate with AskUserQuestion

Run **one** `AskUserQuestion` call with these three questions together:

```
Question 1 — Effort tier
header: "Effort level"
question: "What's the effort level for this session?"
options:
  - label: "Quick exploration (Recommended for most sessions)"
    description: "Sonnet 4.6 throughout. Fast, focused, minimal token spend. Good for spikes, research, one-off tasks."
  - label: "Focused sprint"
    description: "Sonnet 4.6 for implementation, Opus 4.8 for plan writing and review. Best for shipping a real feature."
  - label: "Deep build"
    description: "Opus 4.8 throughout — planning, implementation review, loop design. Reserve for architectural decisions or high-stakes launches."
  - label: "Constrained (low tokens this week)"
    description: "Sonnet 4.6 only. Hand off heavy implementation to Codex via /goal <plan-path> when tokens run low."

Question 2 — Domain
header: "Domain"
question: "What are you working on this session?"
options:
  - label: "New product idea"
    description: "Validating demand, deciding what to build, or writing a first spec."
  - label: "Existing product — new feature"
    description: "Designing, speccing, or implementing a specific feature in an existing codebase."
  - label: "Research or analysis"
    description: "Market research, competitor analysis, technical spike, data exploration."
  - label: "Infrastructure / operations"
    description: "Deployment, CI/CD, dependency audit, migrations, devops."

Question 3 — Outcome
header: "Done looks like"
question: "What does 'done' look like at the end of this session?"
options:
  - label: "A decision I can act on"
    description: "A recommendation with rationale I trust enough to move forward."
  - label: "A plan file I can hand off"
    description: "A written spec, PRD, or implementation plan ready for Sonnet/Opus/Codex to execute."
  - label: "Working code merged or deployed"
    description: "A concrete, verified, shipped change."
  - label: "A brief or artifact I can share"
    description: "A doc, deck, report, or diagram for a stakeholder."
```

---

## Step 2 — Set the session context

After collecting answers, announce the session context aloud and save it:

```markdown
## Session Context — [date]

**Effort tier:** [Quick / Focused / Deep / Constrained]
**Model routing:** [Sonnet throughout / Sonnet impl + Opus plan+review / Opus throughout / Sonnet + Codex fallback]
**Domain:** [new product / existing feature / research / infra]
**Done looks like:** [decision / plan file / merged code / artifact]
**Goal (from user):** [one sentence from their message or AskUserQuestion notes]
```

Save to `~/.claude/session-context.md` (overwrite each session — this is a scratchpad, not memory).

---

## Step 3 — Route to the right skill

Based on domain + outcome, suggest the skill chain to use:

| Domain | Done looks like | Suggested chain |
|---|---|---|
| New product idea | Decision | `/market-validation` → `/build-options` |
| New product idea | Plan file | `/market-validation` → `/build-options` → `/prd` → `/tasks` |
| Existing feature | Plan file | `/prd` → `/tasks` → implementation |
| Research | Artifact | `/market-validation` (or direct research) |
| Infra | Merged code | `/tasks` (or inline — no chain needed) |
| Any multi-repo scope | Plan file | `/ecosystem-planning` |

Announce: "This session I'll route to [skill chain]. Say the skill name to begin, or ask me to start directly."

---

## Step 4 — Load memory

Before doing any work, read `~/.claude/projects/-home-<user>/memory/MEMORY.md` (if it exists).
Summarize any items marked PENDING, BLOCKED, or awaiting-operator that are relevant to this session's domain. Surface them as a short list before proceeding.

---

## Model routing reference

| Tier | Fable planning | Implementation | Review |
|---|---|---|---|
| Quick | Sonnet 4.6 | Sonnet 4.6 | Sonnet 4.6 |
| Focused | Opus 4.8 | Sonnet 4.6 | Opus 4.8 |
| Deep | Opus 4.8 | Opus 4.8 | Opus 4.8 |
| Constrained | Sonnet 4.6 | Sonnet 4.6 → Codex `/goal` | Sonnet 4.6 |

---

## What this skill builds on

| Anthropic primitive | Role in this skill |
|---|---|
| `AskUserQuestion` | Collects session context before any tokens are spent on work |
| Memory system (`~/.claude/projects/*/memory/`) | Surfaces pending items from prior sessions |
| Model routing (Opus / Sonnet / Codex) | Selected once here; downstream skills inherit the choice |
| Skills as judgment layer | This skill activates the right chain; it does not do the work itself |

See: [Claude Code agent SDK](https://docs.anthropic.com/en/docs/claude-code/sdk) ·
[Tool use](https://docs.anthropic.com/en/docs/build-with-claude/tool-use) ·
[Model overview](https://docs.anthropic.com/en/docs/about-claude/models/overview)
