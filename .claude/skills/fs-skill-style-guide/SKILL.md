---
name: fs-skill-style-guide
description: >-
  The written house style for founder-skills SKILL.md and README.md files — the style the repo
  practiced but never wrote down, extracted from the golden four (market-validation, build-options,
  ecosystem-planning, fable-org-audit): frontmatter rules, trigger-rich descriptions, Phase/Step
  skeletons, the recurring closer tables, honesty and Tests sections, the README template, and a
  conformance checklist. Use when a founder-skills maintainer says "does this skill match the
  founder-skills house style", "review this founder-skills SKILL.md", "write the
  description/frontmatter for a new skill in this repo", "which skills can I copy from",
  "style-check this founder-skills plugin", or before editing any SKILL.md or plugin README in
  this repo. If you are NOT working inside founder-skills, load the public skill-style-guide
  plugin instead — it is the generic, calibrate-to-your-own-golden-set version.
---

# fs-skill-style-guide — the founder-skills house style

**Announce at start:** "Using fs-skill-style-guide to style-check against the golden four."

This is the style contract every SKILL.md and plugin README in
`founder-skills` must satisfy. It was extracted 2026-07-02 by reading all 12 plugins; nothing here
is aspiration — every rule is verified against files that exist in the repo today. When this guide
and a shipped skill disagree, the **golden four** win (they are the reference implementation).

## When NOT to use this skill

| Your actual job | Load instead |
|---|---|
| Directory layout, plugin.json, marketplace registration, what files a plugin needs | `fs-plugin-anatomy` |
| The end-to-end workflow of adding a new skill (add-skill.sh etc.) | `fs-skill-authoring` |
| The binding doctrine (no-oversell, sanitization gate, source traceability) | `fs-doctrine-and-honesty` |
| Getting/approving permission to change anything (spec → plan → commits) | `fs-change-control` |
| Orienting in the repo at all | `fs-orientation` |

This skill covers only **what the prose and structure of a SKILL.md / README.md must look like**.

## Copy-from and never-copy-from

| Tier | Skills | Rule |
|---|---|---|
| **Golden four** (copy from these) | `market-validation`, `build-options`, `ecosystem-planning`, `fable-org-audit` | Open one of these side-by-side while writing. They define the style. |
| Conforming | `effort`, `session-start`, `fable-repo-audit`, `fable-loop-design`, `fable-orchestrated-feature-dev`, `prd`, `tasks` | Fine as secondary examples for their conventions (Announce, dot digraphs, Common Mistakes). `prd`/`tasks` joined this tier 2026-07-02 — rewritten in place to house style (campaign Phase 2, all 9 acceptance criteria verified); before that they were never-copy off-style imports (ledger entry 5). |
| **NEVER copy** | `tufte-viz` | Nonconforming frontmatter: uses YAML literal block `\|` instead of folded `>-`, numbered-list description instead of "Use when …" utterances. |

## Rule 1 — Frontmatter

Exactly **two** YAML fields: `name` and `description`. Nothing else — no `version`, no `author`,
no `tools`, no `model`. Multi-line descriptions use the YAML **folded scalar `>-`**:

```yaml
---
name: my-skill
description: >-
  <Job statement, one or two sentences: what running this produces.> Use when the
  user asks "<literal utterance 1>", "<literal utterance 2>", "<literal utterance 3>",
  or <a situational trigger, e.g. "after running `market-validation`">.
---
```

- `name` matches the skill's directory name exactly (kebab-case).
- Never `|` (literal block — that is the tufte-viz mistake), never a one-line double-quoted
  string for anything longer than ~1 line (that is the prd/tasks import style).

## Rule 2 — The description is a trigger surface

The description is what the model reads to decide whether to load the skill. Two mandatory parts,
in order:

1. **The job first** — what the skill does end-to-end, concrete deliverables named
   (e.g. market-validation: "scope questions → … → a cited evidence pack → a Tufte HTML deck").
2. **Then triggers** — "Use when …" and/or "Triggers on:" followed by **literal quoted utterances**
   a user would actually type: `"is there a market for X"`, `"audit this org"`, `"set effort"`.
   3–6 utterances; include at least one situational (non-verbal) trigger where it applies
   ("or after running `market-validation`", "or a scheduled pre-demo / weekly org check").

Bad: "Helps with market research." Good: open `plugins/market-validation/SKILL.md` lines 3–8.

## Rule 3 — Body skeleton (pick the matching one)

Imperative second person throughout ("Ask the user…", "Launch the bundled workflow…"). The body is
a runbook the model executes, not documentation about one.

**A. Pipeline/chain skill** (has phases with artifacts flowing between them — market-validation,
build-options):

```markdown
# Title
<1-3 line summary; name the worked example it was generalized from.>
## Before you start          ← cost/time in tokens+agents, Workflow opt-in note, honesty pointer
## Phase 0 — Scope/Frame     ← AskUserQuestion batch
## Phase 1 — <verb>          ← usually the Workflow launch, fenced call with <skill-dir>/ path
## Phase 2..N — <verb>       ← each phase names its input artifact and output artifact
## Deliverables              ← flat list of files; "Surface them to the user (SendUserFile)."
## Known limitations (keep your honesty consistent)
## Tests                     ← required if the skill ships executable assets
## References                ← bullet list of references/ files, one-line purpose each
```

**B. Audit/orchestration skill** (invokes Agent()/judges — fable-org-audit, fable-repo-audit):

```markdown
# Title
## Overview                  ← what it is, what it is NOT ("Distinct from `/sibling` …")
## When to Use               ← bulleted situations
## <the core model>          ← e.g. "The Eight Dimensions" table + grading scale 🟢🟡🔴⚫
## Step 1 — Invoke …         ← fenced Agent({model:"fable", prompt:`…`}) block, prompt verbatim
## Step 2 — Surface and act
## Output Location
## Quick Reference           ← grade/decision table
## Common Mistakes           ← two-column table: Mistake | Fix
## Related Skills            ← slash-named siblings, one line each on the difference
## References
```

Numbered **Phases** for chain skills, numbered **Steps** for orchestration/planning skills
(ecosystem-planning uses "The process (9 steps)"). Never unnumbered wall-of-prose procedure.

## Rule 4 — Recurring sections and who carries them

Verified distribution as of 2026-07-02 (`grep -rl` over `plugins/*/SKILL.md`):

| Section | Required when | Currently in |
|---|---|---|
| `**Announce at start:** "…"` one quoted line | Calibration/planning skills that set session state or run long | effort, session-start, ecosystem-planning |
| `## Known limitations (keep your honesty consistent)` | Skill makes any claim that is unproven — use that exact heading | market-validation, build-options |
| `## Tests` with exact copy-paste commands | Skill ships executable assets (`assets/*.py`, `assets/*.js`) | market-validation, build-options |
| `## Common Mistakes` (Mistake \| Fix table) | Audit/orchestration skills | all four fable-* skills |
| `## Quick Reference` table | Skill has a grading/decision rubric | fable-org-audit, -repo-audit, -loop-design |
| Model Reference table (model \| best for \| cost) | Skill routes between model tiers | effort, fable-orchestrated-feature-dev |
| Fenced ` ```dot ` digraph for flow diagrams | A multi-actor flow needs a picture — dot, never mermaid/ASCII-art boxes | fable-repo-audit, -loop-design, -orchestrated-feature-dev |
| Grading scale 🟢 Healthy · 🟡 Degraded · 🔴 Broken · ⚫ Not configured | Any health-grading skill — reuse this exact scale | fable-org-audit |

## Rule 5 — Model routing language

When a skill routes work between models, use the house vocabulary exactly (source: effort,
session-start, fable-orchestrated-feature-dev; doctrine home: `fs-doctrine-and-honesty`):

- **Fable 5 plans and reviews and NEVER writes implementation code.**
- Opus 4.8 implements complex work; Sonnet 4.6 implements standard work.
- "**external executor**" is the generic term for the token-exhausted fallback (a cheaper Claude
  session, Haiku 4.5, or a third-party plan-runner). Name specific third-party tools only as
  "such as Codex", never as a dependency.
- The tier is set once via `/effort` or `/session-start` and persisted in
  `~/.claude/session-context.md` — skills *read* it, they don't re-ask.
- Model IDs are volatile facts: date-stamp them and expect `fs-freshness-watch` to sweep them.

## Rule 6 — AskUserQuestion convention

- Show the question set as a **literal fenced block** (header / question / options with label +
  description), exactly as effort does — not a paraphrase.
- **Batch** related questions into ONE AskUserQuestion call ("one call, three questions").
- The recommended option comes **first**, labeled `(Recommended)` — optionally with a reason:
  `"Ample — Opus 4.8 (Recommended for new work)"`.
- Ask only scope-shaping questions, "not preferences with obvious defaults" (ecosystem-planning §3).

## Rule 7 — Chaining and handoffs

- Refer to sibling skills by slash name: `` `/market-validation` → `/build-options` → `/prd` → `/tasks` ``.
- Handoffs pass **file paths or JSON artifacts, never inline content** (build-options Phase 4 hands
  prd a description built from fields of `decision-data.json`; ecosystem-planning hands
  `~/.claude/plans/ecosystem-<name>.md` to fable-orchestrated-feature-dev).
- One canonical data file per pipeline ("the single source of truth"): `deck-data.json`,
  `decision-data.json`. Downstream tools read it; humans don't retype it.
- Each chain-adjacent skill states explicitly what it is **distinct from** and links the sibling.

## Rule 8 — Paths and commands

- Inside a skill, all bundled files are relative: `references/…`, `assets/…`, `tests/…`.
- Runnable commands use the `<skill-dir>/` placeholder:
  `python3 <skill-dir>/assets/build_matrix.py decision-data.json --out <out-dir> --pdf`.
- Never a `/home/<user>` absolute path in anything shipped under `plugins/` (sanitization gate —
  see `fs-doctrine-and-honesty`). `~/.claude/…` paths are allowed only when they ARE the mechanism
  (session-context.md, audit memory files).
- Commands must be copy-paste runnable; if a dependency may be missing, say what happens
  (build_deck.py: "else `PPTX_SKIPPED`") and give the venv one-liner. Note (2026-07-02): the host
  is PEP-668 — bare `python3 -m pytest` fails; test commands and their working forms live in
  `fs-toolchain-and-tests`.

## Rule 9 — Honesty in prose (style-level; doctrine in fs-doctrine-and-honesty)

- Unproven executable paths carry the standing admission verbatim: **"syntax-checked only — its
  first real invocation is its proving run."**
- Emitted-artifact claims are scoped: "shape-valid; loading is the sink's to verify" — never claim
  a specific platform integration "works today" without having run it.
- Cost/time claims cite a real measured run ("the reference run was ~1.5M tokens, ~38 agents,
  ~50 min"), never a round invented number.
- Directional numbers are labeled directional ("scores are directional, not precise").

## Rule 10 — Worked examples under references/

Every generalized skill preserves the concrete run it was generalized from, under `references/`:
`example-shiftmate/` (market-validation + build-options share the fictional ShiftMate),
`worked-example-robot-md.md` (ecosystem-planning), `worked-example-platatlas.md` (fable-org-audit).
The body links it in sentence one or two ("Generalized from the ShiftMate run (see
`references/example-shiftmate/`)") and the manual seams say **"mirror the golden example closely"**.
Worked examples must be sanitized (fictional or approved-public names only).

## Rule 11 — Length

House norm **78–233 lines** for a SKILL.md (verified 2026-07-02 via `wc -l`: build-options 78 …
fable-loop-design 233; the golden four are 78/117/172/227). Under ~78 usually means missing
honesty/Tests/References sections; over ~233 means content that belongs in `references/`. `tasks`
at 480 is the counterexample, not a precedent. Push detail down: SKILL.md is the runbook,
`references/` holds the method docs, schemas, and worked examples.

## Rule 12 — Per-plugin README.md (marketing-facing)

These six `##` sections, in this order, are mandatory (verified present in order in all 15
plugin READMEs 2026-07-02; heading set verified against build-options/README.md). Five plugins
(effort, fable-orchestrated-feature-dev, fable-org-audit, fable-repo-audit, tasks) legitimately
insert ONE extra topical section — e.g. `## Make it recurring`, `## Related API primitives` —
between "What it will ask you" and "Cost"; that is allowed, but more than one insert is not
the norm:

```markdown
# <name> — <one-line hook as a question or promise>
## Before you install      ← cost warning, non-negotiable disciplines, what kind of skill this is
## What it will ask you    ← the AskUserQuestion batch, enumerated
## What it produces        ← bulleted artifact list with filenames
## Cost                    ← tokens + wall-clock, plus how to scope it down
## 60-second first run     ← the slash command + a 2-3 sentence "answer, approve, come back to"
## Built on                ← table: Anthropic primitive | Role here | Docs link
```

"Built on" links must be official Anthropic URLs, live-verified the session you write them
(doctrine — see `fs-doctrine-and-honesty`; last repo-wide verification 2026-06-11, now stale).

## Conformance checklist

Run this before proposing any new/edited skill (and route the change itself through
`fs-change-control` — style conformance never substitutes for change control):

- [ ] Frontmatter has exactly `name` + `description`; multi-line description uses `>-`
- [ ] `name` == directory name
- [ ] Description = job first, then "Use when …" with ≥3 literal quoted utterances
- [ ] Body is imperative second person, numbered Phases or Steps
- [ ] Cost/time stated up front if the run is heavy (tokens, agents, minutes — measured, not invented)
- [ ] AskUserQuestion shown as literal fenced block, batched, `(Recommended)` first
- [ ] All bundled paths relative; runnable commands use `<skill-dir>/`; no `/home/<user>` paths
- [ ] Model routing (if any) uses house vocabulary; Fable never writes implementation code
- [ ] Sibling skills slash-named; handoffs pass file paths/JSON, never inline content
- [ ] Executable assets ⇒ `## Tests` with exact commands
- [ ] Unproven claims ⇒ `## Known limitations (keep your honesty consistent)` + "syntax-checked only" where true
- [ ] Worked example under `references/`, linked early, sanitized
- [ ] Ends with `## References` bullet list (or an explicit worked-example pointer)
- [ ] 78–233 lines; overflow moved to `references/`
- [ ] README (if plugin is public) has the six sections in order; Built-on links live-verified this session
- [ ] Zero style borrowed from `prd`, `tasks`, or `tufte-viz`

## References

- `plugins/market-validation/SKILL.md`, `plugins/build-options/SKILL.md` — golden chain-skill shape.
- `plugins/ecosystem-planning/SKILL.md`, `plugins/fable-org-audit/SKILL.md` — golden planning/audit shape.
- `plugins/build-options/README.md` — cleanest instance of the six-section README template.

## Provenance and maintenance

Extracted 2026-07-02 from repo HEAD 2e4c9dd by reading all 12 `plugins/*/SKILL.md` + READMEs.
Re-verify before trusting (run from the repo root):

```bash
wc -l plugins/*/SKILL.md                                      # length norms (Rule 11)
head -12 plugins/*/SKILL.md | grep -E '^(---|name:|description:|==)'   # frontmatter shape (Rule 1)
grep -rl 'Announce at start' plugins/*/SKILL.md               # Rule 4 row 1
grep -rl 'Known limitations' plugins/*/SKILL.md               # Rule 4 row 2
grep -rln '^## Tests' plugins/*/SKILL.md                      # Rule 4 row 3
grep -rl 'Common Mistakes' plugins/*/SKILL.md                 # Rule 4 row 4
grep -rln '```dot' plugins/                                   # Rule 4 row 7
grep -h '^## ' plugins/build-options/README.md                # Rule 12 heading set
grep -c 'agent-browser' plugins/tasks/SKILL.md                # never-copy rationale (>0 = still off-style)
```

Volatile facts to re-check on drift sweeps (`fs-freshness-watch`): model names (Opus 4.8 /
Sonnet 4.6 / Fable 5 / Haiku 4.5, current as of 2026-07-02), the 78–233 line norm, the prd/tasks
off-style status (a house-style rewrite is operator-licensed — if executed, move them out of the
never-copy table), and the six-section README claim if any plugin is added.
