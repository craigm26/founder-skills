---
name: skill-style-guide
description: >-
  A written house style for Claude Code skill-marketplace SKILL.md and README.md files —
  frontmatter rules, trigger-rich descriptions, Phase/Step body skeletons, recurring honesty and
  Tests sections, a six-section plugin README template, and a conformance checklist you calibrate
  against your own repo's golden examples. Use when a marketplace maintainer says "set up a style
  guide for my skill marketplace", "does this skill match my marketplace's house style", "review
  a SKILL.md against my golden set", "write trigger-rich frontmatter for a new skill in my
  marketplace", or "style-check my marketplace's plugins" — in any marketplace repo you maintain.
---

# skill-style-guide — a house style for skill marketplaces

**Announce at start:** "Using skill-style-guide to style-check against your golden set."

This is a style contract for the SKILL.md and README.md files in a Claude Code skill marketplace.
It was extracted from a working public 12-plugin marketplace by reading every shipped skill —
every rule was verified against files that shipped. The rules are portable; the *calibration*
(which skills are exemplary, exact length norms) is yours to set. When this guide and your best
shipped skill disagree, your golden set wins.

## Step 0 — Designate your golden set

Pick 2–4 of your marketplace's best skills as the **golden set** (reference implementations);
open one side-by-side while writing. Also name any **never-copy** skills — external imports or
legacy files whose voice, emoji habits, or frontmatter shape you don't want propagated. If the
user hasn't designated a golden set yet, ask once and record it (adapt to your repo — the repo's
contributor docs are the usual home).

## Rule 1 — Frontmatter

Exactly **two** YAML fields: `name` and `description`. Nothing else — no `version`, no `author`,
no `tools`, no `model` (those belong in the plugin manifest, not the skill). Multi-line
descriptions use the YAML **folded scalar `>-`**:

```yaml
---
name: my-skill
description: >-
  <Job statement, one or two sentences: what running this produces.> Use when the
  user asks "<literal utterance 1>", "<literal utterance 2>", "<literal utterance 3>",
  or <a situational trigger, e.g. "after running `/upstream-skill`">.
---
```

- `name` matches the skill's directory name exactly (kebab-case).
- Never the literal block `|` (it preserves newlines the loader doesn't need), and never a
  one-line double-quoted string for anything longer than ~1 line.

## Rule 2 — The description is a trigger surface

The description is what the model reads to decide whether to load the skill. Two mandatory parts,
in order:

1. **The job first** — what the skill does end-to-end, concrete deliverables named
   (e.g. "scope questions → cited evidence pack → HTML deck → build brief").
2. **Then triggers** — "Use when …" and/or "Triggers on:" followed by 3–6 **literal quoted
   utterances** a user would actually type (`"is there a market for X"`, `"audit this org"`),
   plus at least one situational trigger where it applies ("or after running
   `/market-validation`", "or a scheduled weekly check").

Bad: "Helps with market research." Good: a description a router could match against real messages.

## Rule 3 — Body skeleton (pick the matching one)

Imperative second person throughout ("Ask the user…", "Launch the bundled workflow…"). The body is
a runbook the model executes, not documentation about one.

**A. Pipeline/chain skill** (phases with artifacts flowing between them):

```markdown
# Title
<1-3 line summary; name the worked example it was generalized from.>
## Before you start          ← cost/time in tokens+agents, opt-in notes, honesty pointer
## Phase 0 — Scope/Frame     ← AskUserQuestion batch
## Phase 1 — <verb>          ← usually the heavy launch, fenced call with <skill-dir>/ path
## Phase 2..N — <verb>       ← each phase names its input artifact and output artifact
## Deliverables              ← flat list of files; surface them to the user
## Known limitations (keep your honesty consistent)
## Tests                     ← required if the skill ships executable assets
## References                ← bullet list of references/ files, one-line purpose each
```

**B. Audit/orchestration skill** (invokes subagents/judges):

```markdown
# Title
## Overview                  ← what it is, what it is NOT ("Distinct from `/sibling` …")
## When to Use               ← bulleted situations
## <the core model>          ← e.g. a dimensions table + grading scale 🟢🟡🔴⚫
## Step 1 — Invoke …         ← fenced subagent call, prompt verbatim
## Step 2 — Surface and act
## Output Location
## Quick Reference           ← grade/decision table
## Common Mistakes           ← two-column table: Mistake | Fix
## Related Skills            ← slash-named siblings, one line each on the difference
## References
```

Numbered **Phases** for chain skills, numbered **Steps** for orchestration/planning skills. Never
an unnumbered wall-of-prose procedure.

## Rule 4 — Recurring sections and when they're required

| Section | Required when |
|---|---|
| `**Announce at start:** "…"` one quoted line | Calibration/planning skills that set session state or run long |
| `## Known limitations (keep your honesty consistent)` | The skill makes any claim that is unproven — use that exact heading |
| `## Tests` with exact copy-paste commands | The skill ships executable assets (`assets/*.py`, `assets/*.js`) |
| `## Common Mistakes` (Mistake \| Fix table) | Audit/orchestration skills |
| `## Quick Reference` table | The skill has a grading/decision rubric |
| Model Reference table (model \| best for \| cost) | The skill routes between model tiers |
| Fenced ` ```dot ` digraph for flow diagrams | A multi-actor flow needs a picture — pick ONE diagram dialect repo-wide and stick to it |
| Grading scale 🟢 Healthy · 🟡 Degraded · 🔴 Broken · ⚫ Not configured | Any health-grading skill — reuse one exact scale everywhere |

Consistency is the point: a reader of your third skill should recognize the furniture from your first.

## Rule 5 — Model routing language

When a skill routes work between models, fix the vocabulary once and reuse it everywhere:

- The planning-tier model **plans and reviews and never writes implementation code**; the
  implementation tiers do standard vs. complex work.
- Pick one generic term for the token-exhausted fallback (e.g. "**external executor**": a cheaper
  Claude session, a small model, or a third-party plan-runner). Name specific third-party tools
  only as examples ("such as Codex"), never as a dependency.
- Set the tier ONCE per session (a calibration skill writing a session-context file works well);
  downstream skills *read* it, they don't re-ask.
- Model IDs are volatile facts: date-stamp them and schedule a freshness sweep.

## Rule 6 — AskUserQuestion convention

- Show the question set as a **literal fenced block** (header / question / options with label +
  description) — not a paraphrase.
- **Batch** related questions into ONE AskUserQuestion call ("one call, three questions").
- The recommended option comes **first**, labeled `(Recommended)` — optionally with a reason.
- Ask only scope-shaping questions, not preferences with obvious defaults.

## Rule 7 — Chaining and handoffs

- Refer to sibling skills by slash name: `` `/validate` → `/decide` → `/spec` ``.
- Handoffs pass **file paths or JSON artifacts, never inline content**.
- One canonical data file per pipeline ("the single source of truth"), e.g. `decision-data.json`.
- Each chain-adjacent skill states explicitly what it is **distinct from** and links the sibling.

## Rule 8 — Paths and commands

- Inside a skill, all bundled files are relative: `references/…`, `assets/…`, `tests/…`.
- Runnable commands use the `<skill-dir>/` placeholder:
  `python3 <skill-dir>/assets/build_matrix.py data.json --out <out-dir>`.
- Never an absolute home-directory path in anything shipped publicly (a machine-specific path is
  both a leak and a portability bug). `~/.claude/…` paths are allowed only when they ARE the
  mechanism (session-context files, audit memory files).
- Commands must be copy-paste runnable; if a dependency may be missing, say what happens (e.g.
  "else `PPTX_SKIPPED`") and give the setup one-liner. Watch for PEP-668 externally-managed
  Pythons: bare `python3 -m pytest` fails on many hosts — document the venv form.

## Rule 9 — Honesty in prose

- Unproven executable paths carry a standing admission verbatim, e.g. **"syntax-checked only —
  its first real invocation is its proving run."**
- Emitted-artifact claims are scoped: "shape-valid; loading is the sink's to verify" — never claim
  a specific platform integration "works today" without having run it.
- Cost/time claims cite a real measured run ("the reference run was ~1.5M tokens, ~38 agents,
  ~50 min"), never a round invented number. Directional numbers are labeled directional.
- Every published claim about vendor features traces to an official source you verified this
  session; drop unverifiable percentages.

## Rule 10 — Worked examples under references/

Every generalized skill preserves the concrete run it was generalized from, under `references/`
(a fictional company, or an approved-public one). The body links it in sentence one or two
("Generalized from the <example> run — see `references/example-<name>/`") and manual seams say
"mirror the golden example closely". Worked examples must pass the same sanitization gate as the
skill: no client names, no credentials or key prefixes, no personal machine paths or infra layout.

## Rule 11 — Length

Derive your norm empirically: `wc -l plugins/*/SKILL.md` over your conforming skills (the source
marketplace measured **~78–233 lines**). Under the floor usually means missing honesty/Tests/
References sections; over the ceiling means content that belongs in `references/`. SKILL.md is
the runbook; `references/` holds method docs, schemas, and worked examples.

## Rule 12 — Per-plugin README.md (marketing-facing)

Exactly these six `##` sections, in this order:

```markdown
# <name> — <one-line hook as a question or promise>
## Before you install      ← cost warning, non-negotiable disciplines, what kind of skill this is
## What it will ask you    ← the AskUserQuestion batch, enumerated
## What it produces        ← bulleted artifact list with filenames
## Cost                    ← tokens + wall-clock, plus how to scope it down
## 60-second first run     ← the slash command + a 2-3 sentence "answer, approve, come back to"
## Built on                ← table: platform primitive | Role here | Docs link
```

"Built on" links must be official vendor URLs, live-verified (2xx + content check) in the session
you write them.

## Conformance checklist

Run this before proposing any new/edited skill (style conformance never substitutes for your
repo's change-control process):

- [ ] Frontmatter has exactly `name` + `description`; multi-line description uses `>-`
- [ ] `name` == directory name
- [ ] Description = job first, then "Use when …" with ≥3 literal quoted utterances
- [ ] Body is imperative second person, numbered Phases or Steps
- [ ] Cost/time stated up front if the run is heavy (tokens, agents, minutes — measured, not invented)
- [ ] AskUserQuestion shown as literal fenced block, batched, `(Recommended)` first
- [ ] All bundled paths relative; runnable commands use `<skill-dir>/`; no machine-specific absolute paths
- [ ] Model routing (if any) uses the house vocabulary; planner never writes implementation code
- [ ] Sibling skills slash-named; handoffs pass file paths/JSON, never inline content
- [ ] Executable assets ⇒ `## Tests` with exact commands
- [ ] Unproven claims ⇒ `## Known limitations (keep your honesty consistent)` + "syntax-checked only" where true
- [ ] Worked example under `references/`, linked early, sanitized
- [ ] Ends with `## References` bullet list (or an explicit worked-example pointer)
- [ ] Length within your repo's measured norm; overflow moved to `references/`
- [ ] README (if plugin is public) has the six sections in order; Built-on links live-verified this session
- [ ] Zero style borrowed from your designated never-copy skills

## Known limitations (keep your honesty consistent)

- These norms were extracted from ONE marketplace (12 plugins, single maintainer). They held up
  there; they are not validated against other marketplaces. Treat every threshold (line counts,
  section names, emoji scale) as a default to calibrate, not a law.
- The six-section README template assumes marketing-facing plugin READMEs; internal-only repos
  may not want one.
- This plugin ships no executable assets and no `references/` directory — the reference
  implementation is your own golden set, which this skill cannot see until you designate it.
  Carrying everything in one file also puts this SKILL.md slightly above the source repo's
  78–233 line norm (Rule 11) — a deliberate trade, acknowledged rather than hidden.
- The verification commands below prove conformance *shape*, not quality; a skill can pass every
  grep and still be a bad runbook.

## Provenance and maintenance

Extracted 2026-07-02 from a public 12-plugin Claude Code marketplace by reading every shipped
`plugins/*/SKILL.md` and README, then genericized from that repo's internal maintainer guide.
Repo-specific detail (golden-set membership, exact line norms, host toolchain quirks) stays in
the source repo — adapt to yours. Re-derive the norms in YOUR marketplace (from the repo root):

```bash
wc -l plugins/*/SKILL.md                                              # length norms (Rule 11)
head -12 plugins/*/SKILL.md | grep -E '^(---|name:|description:|==)'  # frontmatter shape (Rule 1)
grep -rl 'Announce at start' plugins/*/SKILL.md                       # Rule 4 row 1
grep -rl 'Known limitations' plugins/*/SKILL.md                       # Rule 4 row 2
grep -rln '^## Tests' plugins/*/SKILL.md                              # Rule 4 row 3
grep -rl 'Common Mistakes' plugins/*/SKILL.md                         # Rule 4 row 4
grep -h '^## ' plugins/<your-cleanest-plugin>/README.md               # Rule 12 heading set
```

Volatile facts to re-check on drift sweeps: current model names/tiers wherever you wrote them
(date-stamp them), your measured length norm, your never-copy list (if a skill gets rewritten
into house style, move it out), and the README heading set if you evolve the template.

## References

- Your designated golden set (Step 0) — the living reference implementation; open one
  side-by-side while writing.
- The conformance checklist above — the operational summary of Rules 1–12.
