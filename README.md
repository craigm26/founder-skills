# founder-skills

**A judgment layer for Claude Code** — fifteen skills that sit above Anthropic's execution primitives
and tell the model *when* to plan, *which model* to use, and *how* to structure work across a session.
Five groups: session calibration, Fable 5 orchestration, the founder workflow chain, craft, and
maintainer tooling.

Started as a founder's research-to-spec chain. Generalized into a starter package for any builder,
developer, or researcher using Claude Code with Fable 5.

---

## Why this exists

**Token efficiency.** A 30-second calibration at session start — effort tier, domain, what
done looks like — governs how millions of downstream tokens get spent. Wrong-direction work and
wrong-model routing are the two most expensive failure modes of an agentic session, and both are
cheapest to prevent before the first tool call. The judgment layer spends a few hundred tokens to
make that decision explicit.

**Fable 5 is a leap in intuition.** A model that can genuinely judge *when* to plan, *what* to
route where, and *how much* effort a task deserves makes a calibration layer worth building.
These skills give that intuition a structured place to act — explicit, inspectable, and reusable —
instead of leaving it implicit and unrepeatable inside each session.

---

## Before you begin

Three concepts to understand before installing:

### 1. Skills are the judgment layer

Claude Code ships with powerful orchestration primitives. Skills encode *when and how* to use them:

| Anthropic primitive | What it does | Docs |
|---|---|---|
| `Agent()` | Spawn a subagent from within a session | [Subagents](https://code.claude.com/docs/en/sub-agents) · [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) |
| `Workflow` tool | Fan-out multi-agent pipelines with deterministic control flow | [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) |
| `AskUserQuestion` | Structured clarifying questions with typed options | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| `/loop`, `/schedule` | Recurring tasks and cron-scheduled cloud agents | [Slash commands](https://code.claude.com/docs/en/slash-commands) |
| Model routing | Opus 4.8 / Sonnet 4.6 / Haiku 4.5 / external executors | [Models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) |
| Tool use | Give Claude structured tools that call APIs or run code | [Tool use](https://platform.claude.com/docs/en/docs/agents-and-tools/tool-use/overview) |

A skill doesn't replace any of these. It tells Claude: *under what conditions to invoke them, in what order, with what routing, and with what checks*. Think of it as the judgment layer on top of the execution layer.

### 2. Fable 5 is the planner — not the coder

These skills are designed around the Fable 5 orchestration pattern:

```
Fable plans  →  Opus 4.8 or Sonnet 4.6 implements  →  Fable reviews
```

Fable (the model running the skill) writes an in-depth plan, hands it to an implementation model,
then reviews the output against the plan. It never writes implementation code itself. This separation
produces better results than having one model do everything: the planner stays honest, the implementer
stays focused.

The `/effort` skill sets which model tier to route to. Every downstream skill respects that choice.

### 3. Token budget shapes the whole session

Running Opus on everything is powerful and expensive. Running Sonnet is fast and cost-effective.
An external executor (a cheaper Claude session, Haiku 4.5, or a third-party plan-runner) can execute
a written plan file with minimal token spend. These skills make the routing decision **explicit** —
at session start, not buried inside each skill.

---

## Install

```bash
/plugin marketplace add craigm26/founder-skills
```

Install specific skills:
```bash
/plugin install session-start@founder-skills   # start here — calibrates every session
/plugin install effort@founder-skills          # set token budget tier
/plugin install market-validation@founder-skills
/plugin install build-options@founder-skills
/plugin install prd@founder-skills
/plugin install tasks@founder-skills
/plugin install fable-orchestrated-feature-dev@founder-skills
/plugin install fable-repo-audit@founder-skills
/plugin install fable-org-audit@founder-skills
/plugin install fable-loop-design@founder-skills
/plugin install tufte-viz@founder-skills
/plugin install ecosystem-planning@founder-skills
/plugin install skill-style-guide@founder-skills
/plugin install skill-release-gate@founder-skills
/plugin install skill-freshness-watch@founder-skills
```

Or install all fifteen:
```bash
for skill in session-start effort market-validation build-options prd tasks \
             fable-orchestrated-feature-dev fable-repo-audit fable-org-audit \
             fable-loop-design tufte-viz ecosystem-planning \
             skill-style-guide skill-release-gate skill-freshness-watch; do
  /plugin install ${skill}@founder-skills
done
```

---

## The walkthrough

### Session zero — calibrate

Every session starts with two calls:

```
/session-start    ← three AskUserQuestion prompts: effort tier, domain, done-looks-like
/effort           ← or skip if session-start already set it
```

`/session-start` reads your memory (pending items from prior sessions), asks three structured
questions, then announces which skills to use and which model tier is active. Takes 30 seconds.
Prevents an hour of wrong-direction work.

### The full chain (new product idea)

```
/effort              →  set token budget
/session-start       →  establish goal + route to chain
/market-validation   →  is there a real market? (cited evidence pack, ~1.5M tokens)
/build-options       →  what should I build? (judge-panel decision matrix)
/prd                 →  write the spec
/tasks               →  break spec into a prd.json task plan
                     →  hand to Sonnet/Opus for implementation
                     →  Fable reviews against the plan
```

### Existing feature

```
/effort → /prd → /tasks → implement → Fable reviews
```

### Research or analysis

```
/effort → /market-validation (research-only mode) → artifact
```

### Architecture or multi-repo scope

```
/effort → /ecosystem-planning → /fable-orchestrated-feature-dev per workstream
```

---

## Skills

| Skill | Invoke | What it does |
|---|---|---|
| **session-start** | `/session-start` | Three AskUserQuestion prompts — effort tier, domain, done-looks-like. Routes to the right skill chain. Loads memory. **Start here every session.** |
| **effort** | `/effort` | Single-question token budget selector. Sets Opus / Sonnet / external-executor routing for the session. Can be called mid-session to downgrade. |
| **market-validation** | `/market-validation` | Multi-angle web research with live-URL verification → cited evidence pack → Tufte HTML deck + PDF/PPTX → build brief. ~1.5M tokens for a full run. |
| **build-options** | `/build-options` | Divergent options → independent judge-panel weighted decision matrix → adversarial stress-test → recommended build with kill criteria → hands to `prd`. |
| **prd** | `/prd` | Self-clarify open questions, then generate a clear implementation-ready Product Requirements Document. |
| **tasks** | `/tasks` | Convert a PRD markdown file into a `prd.json` task plan — granular, machine-verifiable sub-tasks with acceptance criteria. |
| **fable-orchestrated-feature-dev** | `/fable-orchestrated-feature-dev` | Fable plans → Opus/Sonnet implements → Fable reviews. The plan file is the handoff artifact; external-executor fallback when tokens run out. |
| **fable-repo-audit** | `/fable-repo-audit` | 4-phase principal-level repo audit: map → severity-rated findings (file:line) → strategy → milestone task plan. Analysis only. |
| **fable-org-audit** | `/fable-org-audit` | Live 8-dimension integration audit of a customer org on your platform, graded 🟢🟡🔴⚫ with a prioritized gap list. Portable pattern + PlatAtlas worked example. |
| **fable-loop-design** | `/fable-loop-design` | Design self-correction loops (rubric + independent verifier sub-agent) and cross-session memory (fail → investigate → verify → distill → consult). |
| **tufte-viz** | `/tufte-viz` | Ideate and critique data visualizations on Tufte's principles. Ships 4 working HTML demos as calibration examples. |
| **ecosystem-planning** | `/ecosystem-planning` | One approvable plan across ≥3 repos: verified facts, parallel Explore/Plan agents, advisor review, re-runnable definition of done. |
| **skill-style-guide** | `/skill-style-guide` | House style for skill-marketplace SKILL.md/README files: 16-item conformance checklist, calibrated against your own golden set. Reference-and-checklist skill. |
| **skill-release-gate** | `/skill-release-gate` | Local pre-push gate for a live-publishing marketplace: test suites, manifest JSON parse, sanitization grep, gitignore-swallow check, version-bump and cache-desync discipline. |
| **skill-freshness-watch** | `/skill-freshness-watch` | Read-only drift sweep for a published marketplace: model IDs, manifest versions, beta claims, cited-URL liveness, installed cache, sibling repos. |

---

## AskUserQuestion reference

`AskUserQuestion` is the tool these skills use to collect structured input. It presents typed options
(single or multi-select) with descriptions, which produces faster and more useful answers than
freeform prompts. The session-start and effort skills show the pattern in action.

You can wire your own AskUserQuestion calls into any Claude Code skill using the same format:

```
AskUserQuestion({
  questions: [{
    header: "Short label (≤12 chars)",
    question: "The actual question?",
    multiSelect: false,
    options: [
      { label: "Option A", description: "What it means" },
      { label: "Option B", description: "What it means" }
    ]
  }]
})
```

See [Interactive mode](https://code.claude.com/docs/en/interactive-mode) and the
[Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) for details.

---

## Worked example

`market-validation` and `build-options` ship a worked example built around **ShiftMate** — a
fictional shift-swap marketplace for hourly workers, validated against the real scheduling market.
See each plugin's `references/example-shiftmate/`.

---

## Origins

The six orchestration/craft skills graduated from a private incubation repo on 2026-06-11 as
sanitized near-copies — personal stack details generalized, client references removed. Personal
variants may diverge from the published versions.

---

## Develop / test

Each plugin is self-contained. The two that ship tests:

```bash
cd plugins/market-validation && python3 -m pytest -q tests/
cd plugins/build-options     && python3 -m pytest -q tests/
```

## Adding a new skill

```bash
scripts/add-skill.sh <name> --desc "one-line description with triggers"
```

Scaffolds the plugin, registers it in this marketplace, symlinks it into `~/.claude/skills/`, and
validates. Prints the `git commit && push` commands — it never pushes for you.

---

## License & attribution

Built and maintained by [Craig Merry](https://craigmerry.com).
MIT © 2026 Craig Merry. See [LICENSE](LICENSE).
