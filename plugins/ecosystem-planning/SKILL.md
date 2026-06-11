---
name: ecosystem-planning
description: >-
  Use when a change is architecturally significant and spans three or more repos — to thread a hard-won
  lesson through an entire ecosystem with a single approvable plan. Triggers on: "bake X into the whole
  ecosystem", "incorporate lessons across repos", "design a multi-repo program", or any cross-service
  plan that flows through a shared protocol or identity layer.
---

# Ecosystem Planning

Produces ONE approvable, executable plan that threads a hard-won lesson through every layer of a
multi-repo system (libraries → core service → gateway/protocol → consumer app → enterprise app), keeping a
shared identity/protocol invariant intact. Generalized from the robot-md/RCAN/RRF/OpenCastor/PlatAtlas
planning session (see `references/worked-example-robot-md.md`). The output is a plan file; the value is the
*process* that makes the plan trustworthy.

**Announce at start:** "I'm using the ecosystem-planning skill to design this cross-repo plan."

## Role in the Fable 5 skill suite

This skill is the **planning layer for cross-repo scope**. It sits alongside the other Fable skills:

| Skill | Scope | Fable's role |
|---|---|---|
| `/fable-orchestrated-feature-dev` | Single feature, one repo | Fable writes spec → model implements |
| `/fable-repo-audit` | Single repo health | Fable audits code quality + architecture |
| `/ecosystem-planning` | **Multi-repo program** | Fable orchestrates Explore + Plan agents across all repos |
| `/fable-loop-design` | Any scope, any repo | Fable designs self-correction rubric + memory |

Use this skill when `/fable-orchestrated-feature-dev` is the wrong unit — the change doesn't fit in one
repo's plan file. Ecosystem planning produces the *input* that `/fable-orchestrated-feature-dev` then
executes per-repo, one workstream at a time.

**Handoff pattern:**
```
/ecosystem-planning        → produces: ~/.claude/plans/ecosystem-<name>.md
                              (multi-repo workstreams, verified facts, definition of done)
  ↓ per workstream
/fable-orchestrated-feature-dev  → Fable takes one workstream as its plan file
                                   Opus/Sonnet implements that repo's slice
                                   Fable reviews against the workstream spec
  ↓ after all workstreams
/fable-loop-design         → design the self-correction loop that validates
                             the cross-repo integration end-to-end (the proof)
```

## When to use

Use this when the change is **architecturally significant and spans ≥3 repos/services**, must preserve a
**cross-cutting invariant** (a protocol, an identity/auth system, an audit plane), and the user wants a
*plan they can approve and execute*, not a quick edit. If it's one repo or a localized change, plan
inline — this is overkill.

This skill is designed to run inside **plan mode** (read-only until ExitPlanMode). It composes with the
harness plan workflow (Explore agents in Phase 1, Plan agents in Phase 2).

## The non-negotiable principle

> **Schema-valid ≠ works. Confident ≠ correct.**

Two failure modes this process exists to defeat:
1. A design that is internally consistent but disagrees with physical/runtime reality (the motivating bug:
   a manifest the validator passed and the driver "responded" to, yet the gripper never closed).
2. Sub-agents (and your own priors) stating load-bearing facts **confidently and wrongly**. The single
   highest-value step below is **verifying cross-agent disagreements against the actual code before you
   write a line of the plan.**

## The process (9 steps)

### 1. Anchor on a durable, real lesson — never plan in the abstract
Start from a written retrospective grounded in something that actually happened (a shipped fix, a
hardware run, a postmortem). If one doesn't exist, write it first (a short `LESSONS_*.md`): what broke,
the root cause, the fix, and the proof. Every plan decision traces back to it. Each lesson becomes a
candidate capability.

### 2. Map the ecosystem (read-only orientation, ~1 tool call)
Before spawning anyone, locate the terrain so agents have real targets:
- Source repos vs installed packages vs **running services** (they diverge — the deployed copy is often a
  built wheel, not the source repo; the service runs from its own venv/path).
- For each repo: is it a git repo, what branch, what remote (org matters).
- Entry points / plugin registries / systemd services / config dirs.

Reusable sweep (adapt the grep):
```bash
ls -d */ | grep -iE "<ecosystem keywords>"
for d in <dirs>; do git -C "$d" remote get-url origin; git -C "$d" rev-parse --abbrev-ref HEAD; done
python3 -c "import importlib.util,os; [print(m, importlib.util.find_spec(m)) for m in (...)]"
python3 -c "from importlib.metadata import entry_points; ..."   # plugin registries
systemctl cat <service> | grep -E 'ExecStart|WorkingDirectory|User'; ls /etc/<service>/
pip show -f <pkg> | grep -E 'Location|Editable'                  # wheel vs editable
```

### 3. Clarify ONLY scope-shaping decisions (AskUserQuestion)
Ask the few questions whose answers change the plan's shape — not preferences with obvious defaults.
The recurring four:
- **Depth/scope across layers** (deep-core + roadmap-tail vs all-deep vs one-layer-first).
- **Hard-but-right vs easy-but-partial architectural path** (e.g. route through the gateway vs bypass it).
- **In-scope vs separate** for an entangled concern (e.g. a crypto/protocol migration).
- **Definition of done** (a re-runnable end-to-end proof vs "features merged").

Put the recommended option first, labeled "(Recommended)". These answers are the spine of the plan.

### 4. Fan out parallel Explore agents — map seams, don't design (read-only)
One Explore agent per subsystem cluster (≈3 max). Each prompt: the targets (exact paths from step 2),
the lessons/decisions as context, and a demand for **exact files + line numbers + short real excerpts**
and **"the cleanest insertion point for X"** — explicitly *not* a design. Tell them to flag what exists
vs what's missing. Run them in one message (parallel).

### 5. Fan out parallel Plan agents — design each slice against real code
One Plan agent per workstream. Give each: the exploration findings (so they don't re-explore), the locked
decisions from step 3, and **named seams to coordinate** (e.g. "the gateway agent will define these exact
`tool_name`/arg schemas — match them"). Demand **one recommended approach per decision with a one-line
rationale**, not a menu. Ask for: files to create/modify, data flow, schema/contract changes, a build
sequence, tests, and flagged risky assumptions.

### 6. VERIFY cross-agent disagreements before writing (highest-value step)
Agents *will* confidently contradict each other and reality. Collect every load-bearing claim that (a)
agents disagree on, or (b) the whole plan rests on, and check each with a direct read-only command. Real
examples that flipped decisions: "the service uses a NoOp stub" (false — it resolved the real class);
"there's no source repo" (false — it existed but the install was a wheel); "the schema lacks field X"
(false — already present). Write the **"Verified facts"** section from what you confirm, not what was
asserted.

### 7. Consolidate into ONE plan file (fixed structure)
See `references/plan-template.md`. The skeleton:
- **Context** — the lesson, the root cause, why now, the locked operator decisions.
- **Verified facts this plan rests on** — from step 6, each cross-checked.
- **Workstreams** — deep (execution-depth) for the in-scope core; **roadmap-depth** (seams + phased
  sequence) for downstream consumers.
- **Cross-cutting concerns** — the invariants that touch every layer (identity/protocol, and the
  *operational* glue that's easy to forget — e.g. "after any signed-artifact write you must re-sign +
  redeploy or the next op fails closed").
- **Definition of done / the proof** — a concrete, re-runnable end-to-end demonstration with a budget.
- **Build sequence** — least-breaking first; no-hardware/no-migration foundations before risky steps;
  validate the #1 risk early.
- **Verification** — hardware-free unit tests + in-the-loop checks + cutover gates.
- **Open questions / risks** — the assumptions to confirm early.

Recommended approach only (not every alternative). Concise enough to scan, detailed enough to execute.

### 8. Advisor review before finalizing
Run an independent reviewer agent — a fresh context window acting as plan advisor — with the plan durable on disk. It reliably catches **missing steps inside your chosen
architecture** (not redirects) — the operational loop you forgot, a hard-won fix you didn't carry into
the productized path, a place where "already proven" quietly conflates two different things. Fold the
corrections in; re-state the conflict if you have contradicting evidence.

### 9. ExitPlanMode

## Meta-lessons to bake into any plan (learned the hard way)
- **Carry hard-won fixes forward.** If you switched from approach A to B because A failed, make sure the
  productized default is B — don't let a sub-agent silently re-introduce A. (We almost shipped the vision
  map that *didn't* work as the default; the proven simpler model was the real default.)
- **Name ownership seams explicitly.** When a change crosses a package boundary you don't control, call it
  out as a decision, don't assume it.
- **Decouple migrations** (crypto, org moves) from the feature unless the user puts them in scope — and
  when in scope, find the lowest-risk path (e.g. the registry already served the new key material → no
  registry change needed; accept-both → cut over).
- **Don't trust "it responds" as "it works."** Bake a reality-check / commissioning step into the plan
  itself, mirroring the lesson that motivated it.

## Red flags (you're doing it wrong)
- Writing plan prose before step 6 (verifying facts). → Stop; verify first.
- Plan agents returning a menu of options instead of a recommendation. → Re-prompt for a pick + rationale.
- A "Verified facts" section that just repeats what agents asserted. → It must cite what *you* confirmed.
- No re-runnable proof / definition of done. → The plan can't be checked; add one with a budget.
- Skipping the advisor pass. → It's where the load-bearing missing-step gets caught.

## Worked example
`references/worked-example-robot-md.md` — the full robot-md/RCAN/RRF/OpenCastor/PlatAtlas run this
skill was generalized from, including the exact cross-agent disagreements that got verified and the
advisor catches that were folded in.
