---
name: fs-anthropic-primitives
description: >-
  Domain reference for the Anthropic primitives the founder-skills plugins orchestrate, as used in
  THIS repo (not a textbook): the Workflow({scriptPath,args}) opt-in pattern and its injected-globals
  runtime, batched AskUserQuestion with the (Recommended) option first, the Agent() model-tier
  routing tables (Fable 5 plans/reviews, Opus 4.8 complex, Sonnet 4.6 standard, external executor
  cheap), output_config.effort vs the Task Budgets beta, /loop and /schedule and Claude Managed
  Agents scheduling, session-context.md tier persistence, and the canonical Anthropic doc-URL list
  with re-verify curls. Use when a maintainer asks "what does Workflow({scriptPath}) mean here",
  "which model implements vs plans", "what is the model routing table", "what's the difference
  between /effort and output_config.effort", "what is the task budgets beta", "how do these skills
  schedule recurring runs", "where is the effort tier persisted", "what URLs do these skills cite",
  or needs to edit any SKILL.md text that mentions Agent, Workflow, AskUserQuestion, Outcomes,
  model IDs, or Anthropic doc links.
---

# fs-anthropic-primitives — the primitives these skills orchestrate, as used here

Announce at start: "Loading fs-anthropic-primitives — Anthropic primitives reference for founder-skills."

This repo's product is a "judgment layer": its plugins (15 as of 2026-07-02 — 12 committed + 3 uncommitted skill-*) tell Claude *when and how* to use
Anthropic's execution primitives. To maintain the plugins you must know what each primitive is,
exactly how this repo uses it, and which usage claims are verified vs still open. That is this
skill. Everything below was checked against the repo files on **2026-07-02**; claims that come
from Anthropic docs were last **content**-verified against live official URLs on **2026-06-11**
(the v0.2.0 fact-check) — that content check is now ~3 weeks stale. URL *reachability* was
re-checked 2026-07-02 (see the URL table).

**Definition — "primitive":** a capability provided by Anthropic surfaces (Claude Code tools,
slash commands, the Claude API, or Claude Managed Agents) that a skill invokes or instructs.
The skills wrap primitives; they never reimplement them.

## When NOT to use this skill

| Your actual job | Load instead |
|---|---|
| Orient in the repo / find which skill covers X | `fs-orientation` |
| Understand WHY routing/no-oversell rules exist and their exact wording | `fs-doctrine-and-honesty` |
| Write or restyle a SKILL.md (voice, frontmatter, closers) | `fs-skill-style-guide` |
| Run the test suites / rebuild the venv / the JS harness commands | `fs-toolchain-and-tests` |
| Prove the unproven Workflow scripts end-to-end | `fs-flagship-chain-campaign` |
| Sweep for drifted model IDs / stale doc claims on a cadence | `fs-freshness-watch` |
| The history of how primitive claims went wrong before | `fs-failure-archaeology` |

---

## 1. Workflow({scriptPath, args}) — the opt-in pattern

**What it is:** the Claude Code `Workflow` tool runs a bundled JS orchestration script that can
spawn sub-agents. Two plugins ship such scripts:

| Plugin | Script | Entry call (verbatim from SKILL.md) |
|---|---|---|
| market-validation | `assets/research-workflow.js` | `Workflow({ scriptPath: "<skill-dir>/assets/research-workflow.js", args: { config: RunConfig, angles: [...] } })` |
| build-options | `assets/build-options-workflow.js` | `Workflow({ scriptPath: "<skill-dir>/assets/build-options-workflow.js", args: { context: DecisionContext, criteria: [...], lenses: [...] } })` |

**The opt-in pattern (house convention):** launching Workflow is allowed *because the skill's own
instructions tell you to call it* — the tool's documented allowance. No separate user opt-in is
needed beyond the user invoking the skill. Both SKILL.mds state this explicitly
(market-validation SKILL.md:19–21, build-options SKILL.md:20). Preserve that sentence when editing.

**Division of labor (spec rule R2):** the *skill* (you, the orchestrating model) composes the
inputs — angle set, criteria, lenses — and shows the spend-determining set to the user; the
*script* only executes them. Scripts never invent research angles or scoring criteria.

**Runtime contract (verified against `plugins/market-validation/tests/js/harness.mjs`, 2026-07-02):**
a Workflow script is NOT a standalone Node module. The runtime wraps the script body in an async
function and injects the globals `agent`, `parallel`, `phase`, `log`, `args`. Consequences:
- Top-level `await` AND top-level `return` are legal inside the script (illegal in a plain ES module).
- You cannot `import()` or `node` the script to test it; the test harness replicates the wrapper
  with `new Function('agent','parallel','phase','log','args', ...)` and stubbed globals.
- Therefore `node --test 'tests/js/*.test.mjs'` (glob form only — directory form fails,
  defect ledger #3) is the ONLY way to exercise the shipped script offline.

**Honesty status (do not weaken this):** both scripts were **proven on 2026-07-02** (campaign Phase 1 spec); before that they were self-declared **"syntax-checked only —
its first real invocation is its proving run"** (market-validation SKILL.md:93, build-options
SKILL.md:63; defect ledger #4). They were rewritten 2026-06-11 to read `args.*` but have only ever
executed in an earlier hardcoded form. The gated proving run belongs to `fs-flagship-chain-campaign`.
Until it passes, no SKILL.md, README, or site copy may claim the generalized scripts "work".

## 2. AskUserQuestion — batched, (Recommended) first

**What it is:** the Claude Code interactive-mode tool that presents structured multiple-choice
questions. House conventions (extracted from the golden four + calibration skills):

- **Batch questions into ONE call.** `session-start` asks 3 questions in a single call;
  `market-validation` Phase 0 asks its 3 scope questions in one call. Never serialize
  one-question-per-call when the questions are known upfront.
- **The recommended option comes FIRST and is labeled `(Recommended)`** — e.g. `effort`'s
  `"Ample — Opus 4.8 (Recommended for new work)"`, `session-start`'s
  `"Quick exploration (Recommended for most sessions)"`.
- Skills embed the question as a **literal fenced block** (header / question / options with
  label + description), so any model can reproduce it verbatim.
- Every option's `description` states the consequence (which model, what cost), not marketing.

## 3. Agent() and the model-tier routing tables

**What it is:** spawning a sub-agent on a named model. The repo's core doctrine rides on it:
**Fable plans, orchestrates, and reviews — Fable never writes implementation code**
(rationale and exact wording: `fs-doctrine-and-honesty`).

Canonical model table (verbatim IDs from `fable-orchestrated-feature-dev` SKILL.md "Model
Reference", verified 2026-07-02 — these IDs are hardcoded prose and WILL drift; `fs-freshness-watch`
owns re-checking them):

| Model ID | Alias in `Agent({model})` | Role in this repo | Cost tier |
|---|---|---|---|
| `claude-fable-5` | `fable` | Planner, orchestrator, reviewer, auditor — **never coder** | High |
| `claude-opus-4-8` | `opus` | Implementer — complex features, ample budget | High |
| `claude-sonnet-4-6` | `sonnet` | Implementer — standard work; also the independent verifier/grader in loops | Medium |
| External executor | — (plan-file handoff, not an Agent call) | Token-exhausted fallback: a cheaper Claude session, **Haiku 4.5**, or a third-party plan-runner "such as Codex" | Minimal |

Session-tier → routing (two tables exist; both are canonical for their skill):

| `effort` tier | Routing announced |
|---|---|
| Ample | Planning + implementation → Opus 4.8 |
| Moderate | Planning → Opus 4.8, implementation → Sonnet 4.6 |
| Constrained | All → Sonnet 4.6; heavy lifts → external executor via plan file |
| Sprint end | Plans only; ALL implementation → external executor |

| `session-start` tier | Fable planning | Implementation | Review |
|---|---|---|---|
| Quick | Sonnet 4.6 | Sonnet 4.6 | Sonnet 4.6 |
| Focused | Opus 4.8 | Sonnet 4.6 | Opus 4.8 |
| Deep | Opus 4.8 | Opus 4.8 | Opus 4.8 |
| Constrained | Sonnet 4.6 | Sonnet 4.6 → external executor | Sonnet 4.6 |

Recurring Agent() patterns you must preserve when editing:
- **Plan-file handoff:** Fable's planner Agent returns *only an absolute file path*
  (`~/.claude/plans/<slug>-<date>.md`); handoffs pass file paths, never inline content.
- **Independent verifier:** loop graders run on a *different* model in a fresh context
  (`fable-loop-design`: `model: "sonnet"` grades Fable's output). Official basis: "Separate
  fresh-context verifier sub-agents tend to outperform self-critique" (migration guide,
  content-verified 2026-06-11).
- **Sanitization:** Codex may only be named as an example — "such as Codex" — never as a
  hard dependency (doctrine; the prd/tasks `agent-browser` dependency is the known violation,
  licensed for rewrite).

## 4. output_config.effort vs Task Budgets (don't confuse with `/effort`)

Three different things share the word "effort". The disambiguation table (source: `effort`
SKILL.md "Related API primitives", spec item 4; content-verified 2026-06-11):

| Thing | Level | What it controls |
|---|---|---|
| `/effort` skill (this repo) | Session | Which MODEL handles each role; persisted to session-context.md |
| `output_config.effort` (`low`/`medium`/`high`/`xhigh`/`max`) | Per API request | Thinking depth / token spend within one request |
| Task Budgets — `output_config.task_budget`, beta header `task-budgets-2026-03-13`, **min 20,000 tokens** | Per agentic loop | A model-visible token countdown; the model self-moderates |

Officially documented lever the Constrained tier relies on (as of 2026-06-11): on Fable 5,
**lower effort settings still perform very well — often exceeding the `xhigh`/`max` performance of
previous models** — so dial `output_config.effort` down before downgrading models.

## 5. Loops and scheduling: /goal, /loop, /schedule, Claude Managed Agents

As used by `fable-loop-design` and `fable-org-audit` (all content-verified 2026-06-11 via the
primitives-upgrade spec):

| Primitive | Surface | Use here |
|---|---|---|
| `/goal` | Claude Code | Sets the direction for a run (restored to the docs per the migration guide) |
| `/loop` | Claude Code | Re-runs a prompt/slash command until stopped — the built-in loop harness for standard self-correction |
| `/schedule` (routines) | Claude Code | Cron-cadence runs on Anthropic-managed cloud infra (laptop can be off) — the default weekly org-audit trigger |
| Outcomes | Claude Managed Agents (CMA) | Hosted iterate → grade → revise loop. Send a `user.define_outcome` EVENT on an existing session (not a session-create field; don't also send a kickoff `user.message`). Rubric REQUIRED (`{type:"text"|"file"}`), grader is Anthropic-managed (model not user-configurable), `max_iterations` default **3** / max **20**, terminal results: `satisfied`, `max_iterations_reached`, `failed`, `interrupted` (`needs_revision` loops again) |
| Scheduled deployments | CMA | `deployments.create()` with cron expression + IANA timezone; each firing writes a `deployment_run` record with typed errors; test with manual `deployments.run()` first |
| Memory stores | CMA | Workspace-scoped filesystem mounted into sessions; per-mutation versioning — the hosted analog of the local `memory/` progression |

Bridge pattern (spec item 3): a plan file's machine-verifiable acceptance criteria (what `tasks`
produces) ARE an Outcomes rubric — extract them to markdown and send `user.define_outcome`. This
"hosted executor" path is *described, not yet exercised* in this repo. UNVERIFIED beyond docs.

**Safety boundary (spec item 5, applies to Fable audit skills):** Fable 5's safety classifiers can
false-positive on security-adjacent audit work. A decline arrives as HTTP **200** with
`stop_reason: "refusal"` (pre-output refusals unbilled) — not an error. On the API, fallback to
Opus 4.8 is **opt-in** (beta `fallbacks` param, SDK middleware, or manual retry); consumer surfaces
handle it automatically. Skills must report a refused section as *refused*, never silently skip it.

## 6. session-context.md — tier persistence

The effort tier is set ONCE (via `/effort` or `/session-start`) and persisted to
`~/.claude/session-context.md` (environment-specific path — the user-level Claude Code home; this
is the actual mechanism, not an example). Downstream skills read it instead of re-asking.

**Known seam (verified 2026-07-02, unresolved):** the two writers disagree on semantics —
`effort` SKILL.md:51 says *"append or overwrite the `effort_tier` line"*; `session-start`
SKILL.md:81 says *"overwrite each session — this is a scratchpad, not memory"*. Both cannot be
literally true of one file. Treat as an open consistency defect if you touch either skill; fixing
it requires a spec (`fs-change-control`).

Distinct from session-context.md: the Claude Code **memory system**
(`~/.claude/projects/<project>/memory/MEMORY.md`) which `session-start` Step 4 reads for pending
items, and the `memory/rules.md` progression `fable-loop-design` designs. Don't conflate the three.

## 7. Canonical doc-URL list + re-verify curls

Every Anthropic-doc claim in this repo must trace to one of these official URLs (doctrine).
Last FULL content verification: **2026-06-11** (curl 2xx + content check, per the v0.2.0 spec) —
**stale as of 2026-07-02**. Reachability only (HTTP 200 via `curl -L`, content NOT re-checked)
confirmed 2026-07-02 for all eleven URLs below.

| URL | Cited by (repo-verified 2026-07-02, incl. the 3 uncommitted skill-* plugins) |
|---|---|
| https://code.claude.com/docs/en/skills | 11 plugin READMEs ("built on" tables, incl. skill-style-guide) + docs/index.html |
| https://code.claude.com/docs/en/sub-agents | 7 plugin READMEs + README.md + docs/index.html |
| https://code.claude.com/docs/en/interactive-mode | effort, session-start SKILL.mds + READMEs; all 3 skill-* READMEs |
| https://code.claude.com/docs/en/agent-sdk/overview | session-start SKILL.md + READMEs |
| https://code.claude.com/docs/en/memory | session-start SKILL.md + READMEs |
| https://code.claude.com/docs/en/slash-commands | README.md + docs/index.html |
| https://code.claude.com/docs/en/overview | docs/index.html + prd README |
| https://code.claude.com/docs/en/plugins | docs/index.html + superpowers spec/plan + skill-release-gate SKILL/README + skill-style-guide README |
| https://code.claude.com/docs/en/plugin-marketplaces | docs/index.html + superpowers spec/plan + skill-release-gate SKILL/README + skill-style-guide README |
| https://platform.claude.com/docs/en/docs/about-claude/models/overview | effort, session-start SKILL.mds + READMEs; skill-freshness-watch SKILL/README |
| https://platform.claude.com/docs/en/docs/agents-and-tools/tool-use/overview | README.md + market-validation README + docs/index.html |

One-line reachability sweep (run from repo root; expect eleven `200`s — the count itself is a
drift signal: if it changes, a citation was added or removed somewhere). Note the character
class excludes backticks: a backtick-wrapped URL (e.g. skill-freshness-watch cites the models
page inside `` ` ``) would otherwise be captured with a trailing `` ` `` and curl as a phantom
HTTP 400:

```bash
grep -rhoE 'https://(code|platform)\.claude\.com[^ )>"'"'"'`]*' README.md docs plugins | sed 's/[.,]$//' | sort -u | while read u; do printf '%s ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' -L --max-time 20 "$u"; done
```

A `200` proves the page exists, NOT that the fact still holds. Facts that need periodic
content re-verification (owner: `fs-freshness-watch`): the Task Budgets beta header/date and
20k minimum, `output_config.effort` level names, Outcomes event shape and iteration limits,
the `stop_reason: "refusal"` + `fallbacks` behavior, the "low effort on Fable 5 still performs
very well" claim, and every hardcoded model ID (`claude-fable-5`, `claude-opus-4-8`,
`claude-sonnet-4-6`, "Haiku 4.5").

## Common mistakes

| Mistake | Fix |
|---|---|
| Testing a Workflow script with `node script.js` or `import()` | It has top-level `return`; use the harness via `node --test 'tests/js/*.test.mjs'` (glob form only) |
| Claiming the generalized Workflow scripts work | They are "syntax-checked only" until the `fs-flagship-chain-campaign` proving run passes |
| Serializing AskUserQuestion calls | Batch known questions into one call; (Recommended) option first |
| Letting Fable emit implementation code | Doctrine violation — see `fs-doctrine-and-honesty`; prompts must say "planning only" |
| Confusing `/effort` with `output_config.effort` or Task Budgets | Section 4 table: session routing vs per-request depth vs loop countdown |
| Treating `stop_reason: "refusal"` as a crash or empty result | Check `stop_reason`; report the section as refused; fallback is opt-in on the API |
| Adding a doc claim with no URL, or a URL verified "sometime" | Verify the live URL *that session* and date-stamp it (doctrine) |
| Editing model IDs in one skill only | They are hardcoded across effort, session-start, fable-* SKILL.mds and docs/index.html — sweep all (`fs-freshness-watch`) |

## Provenance and maintenance

Sources read 2026-07-02: `plugins/effort/SKILL.md`, `plugins/session-start/SKILL.md`,
`plugins/fable-loop-design/SKILL.md`, `plugins/fable-orchestrated-feature-dev/SKILL.md`,
`plugins/fable-org-audit/SKILL.md`, `plugins/market-validation/SKILL.md` (+ `tests/js/harness.mjs`),
`plugins/build-options/SKILL.md`, `docs/superpowers/specs/2026-06-11-anthropic-primitives-upgrade.md`.

Re-verify before trusting (one line each):

```bash
# Workflow call signatures still as documented here
grep -rn "Workflow({" plugins/market-validation/SKILL.md plugins/build-options/SKILL.md
# "syntax-checked only" admissions still present (if gone, the proving run happened — update §1)
grep -rn "syntax-checked only" plugins/*/SKILL.md
# Injected-globals runtime contract unchanged
sed -n '1,12p' plugins/market-validation/tests/js/harness.mjs
# Model IDs and routing tables unchanged
grep -rn "claude-fable-5\|claude-opus-4-8\|claude-sonnet-4-6" plugins/*/SKILL.md
# Task Budgets beta + effort levels as stated
grep -n "task-budgets-2026-03-13\|xhigh" plugins/effort/SKILL.md
# Outcomes / scheduling facts as stated
grep -n "user.define_outcome\|max_iterations\|deployments.create" plugins/fable-loop-design/SKILL.md plugins/fable-org-audit/SKILL.md plugins/fable-orchestrated-feature-dev/SKILL.md
# session-context.md writers (and the append-vs-overwrite seam)
grep -rn "session-context" plugins/effort/SKILL.md plugins/session-start/SKILL.md
# URL reachability sweep — see §7 one-liner; expect all 200s
```

Volatile date-stamps in this file: repo facts 2026-07-02; Anthropic-doc content facts 2026-06-11
(stale); URL reachability 2026-07-02. If any grep above disagrees with this skill, the repo wins —
update this file via the `fs-change-control` pipeline (internal `.claude/skills/` edits still get
operator review before commit; assistants run no mutating git commands).
