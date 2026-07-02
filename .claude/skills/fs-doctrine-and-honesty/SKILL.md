---
name: fs-doctrine-and-honesty
description: >-
  The founder-skills non-negotiables with their rationale: planner-never-writes-implementation-code
  routing, no-oversell / source-traceability (every claim traces to an official Anthropic URL
  verified that session), the sanitization hard gate for anything public, the attribution /
  non-affiliation footer, the honesty conventions (Known-limitations sections, the
  "syntax-checked only" admission, refused-not-silently-skipped), and the v0.2.0 fact-check
  methodology as this project's research method. Use when a maintainer asks "what are the rules
  here", "can I claim X on the site", "is this claim allowed", "sanitization check", "can I say
  this works", "why can't Fable write the code", "how do I cite Anthropic docs", "add a
  known-limitations section", or before reviewing ANY text that will ship publicly.
---

# fs-doctrine-and-honesty — the non-negotiables

Announce at start: "Loading fs-doctrine-and-honesty — the honesty and doctrine rules for founder-skills."

This repo's product is **credibility**. It is a public, live-publishing marketplace
(every push to master is instantly installable — see `fs-release-and-publish`) whose skills
teach *judgment*. One inflated claim, one leaked client name, one "works today" that was never
run, and the whole library reads as marketing. The rules below exist because each one was
violated once, or nearly, and the repair cost more than compliance would have.

Four hard rules + a set of honesty conventions + one research methodology. All file/line
references verified 2026-07-02 against the repo at `/home/craigm26/projects/craigm26/founder-skills`
(environment-specific path; the repo is public GitHub `craigm26/founder-skills`).

## When NOT to use this skill

| Your job | Load instead |
|---|---|
| Run the actual pre-push gate (suites + JSON parse + sanitization grep + URL sweep as a script) | `fs-release-and-publish` |
| Classify/spec/plan a change through the pipeline | `fs-change-control` |
| Prose, frontmatter, and section conventions for writing a skill | `fs-skill-style-guide` |
| Recurring sweep for stale model IDs / stale URL verification | `fs-freshness-watch` |
| What the Anthropic primitives actually are (Workflow, Outcomes, Task Budgets…) | `fs-anthropic-primitives` |
| Repo map, quality tiers, defect ledger | `fs-orientation` |

This skill is the **why and what** of doctrine. It never authorizes a change by itself —
nothing routes around `fs-change-control`.

---

## Rule 1 — The planner never writes implementation code

The exact doctrine line, from `plugins/fable-orchestrated-feature-dev/SKILL.md:12`:

> **Fable must never write implementation code.** Its role is analysis, planning, and
> post-implementation review only. Every capable model available today can implement a
> well-written spec faithfully — use that.

**Rationale:** Fable 5 is the expensive judgment tier. Spending it on implementation burns the
budget that planning and review exist to protect; a well-written plan is model-portable, so
implementation routes to whatever tier the session can afford. The canonical routing table
(from `plugins/session-start/SKILL.md`, "Model routing reference"):

| Tier | Fable planning | Implementation | Review |
|---|---|---|---|
| Quick | Sonnet 4.6 | Sonnet 4.6 | Sonnet 4.6 |
| Focused | Opus 4.8 | Sonnet 4.6 | Opus 4.8 |
| Deep | Opus 4.8 | Opus 4.8 | Opus 4.8 |
| Constrained | Sonnet 4.6 | Sonnet 4.6 → external executor | Sonnet 4.6 |

- "External executor" = any plan-runner outside this session (a cheaper Claude session,
  Haiku 4.5, or a third-party tool **"such as Codex"** — that exact softened phrase is the only
  form in which Codex may be named; a *required* Codex dependency is a sanitization violation,
  per the publish-private-six spec).
- Model IDs in these tables are volatile facts (written 2026-06-11). Checking them for
  staleness is `fs-freshness-watch`'s job; changing them is a spec'd change.

**Enforcement when maintaining:** any new or edited skill that has Fable emit code (not plans,
specs, reviews, or checklists) contradicts published doctrine and must not ship without an
operator-approved spec that explicitly amends the doctrine.

---

## Rule 2 — No oversell / source traceability

From the two governing specs (`docs/superpowers/specs/2026-06-11-anthropic-primitives-upgrade.md`
"Constraints" and `2026-06-11-publish-private-six-design.md` "Sanitization requirements"):

1. **Every published claim about Anthropic primitives traces to an official Anthropic source
   verified live in the same session the claim is written.** Canonical homes as of 2026-06-11:
   `code.claude.com/docs` (Claude Code), `platform.claude.com/docs` (API).
2. **No secondhand numbers.** The v0.2.0 upgrade explicitly kept third-party benchmark
   percentages ("Parameter Golf", "Continual Learning Bench") OUT because they could not be
   traced to an official source. Unverifiable percentages are dropped, not hedged.
3. **"Anthropic's internal research" claims are banned** (publish-private-six spec, line 25).
   Cite observable model behavior or a public doc, or say nothing.
4. **Never claim an unrun path works.** The standing formula is in
   `plugins/market-validation/references/verification-discipline.md` §6: *"If you only read
   that a path works but never ran it, say 'described, untested'."*

**The live counterexample (defect ledger #6, open as of 2026-07-02).** `docs/index.html`
currently violates its own rule twice: two "~0 tokens" cost chips (README doctrine says "a few
hundred tokens") and one "runs itself weekly" claim (the skill only *documents* scheduling
options). Exact strings and line numbers live in **fs-failure-archaeology** entry 6; candidate
corrections in **fs-site-and-positioning** — do not duplicate them here.

Do not silently fix these: site edits require a coordinated spec (see `fs-change-control` and
`fs-site-and-positioning`). Do cite them — they are the proof that oversell drift happens even
in a repo whose whole thesis is honesty, which is why review (below) checks marketing surfaces
against skill text, not against vibes.

---

## Rule 3 — The sanitization hard gate (anything public)

The public repo graduated six skills from a private repo on 2026-06-11. The hard gate
(publish-private-six spec) bans, in public files:

- real client org names (`Reservoir`, `reservoirfarms`)
- secret/token prefixes (`sk_live`, `sk_test`, `cfut_`, bearer values)
- personal home-dir paths (`/home/craigm26`)
- personal-machine infra layout (systemd unit paths, `/etc/` configs, venv locations) —
  except where documenting a public project's own install docs
- Codex as a *required* executor (allowed only as the named example "such as Codex")
- real-project example filenames → generic examples

The canonical scan below deliberately **extends** the original gate in
`docs/superpowers/plans/2026-06-11-publish-private-six.md:12` (which was case-sensitive and
covered `plugins/` only) to case-insensitive matching over every public dir. This wider form is
the doctrine scope — the executable pre-push gate (`fs-release-and-publish`) runs it too.
Re-verified clean (exit 1 = zero hits) on 2026-07-02:

```bash
cd <repo-root>
grep -rniE 'reservoir|sk_live|sk_test|cfut_|/home/craigm26|castor-dash|/opt/robot-md|/etc/robot-md' \
  plugins/ docs/ README.md .claude-plugin/ --exclude-dir=superpowers
# exit 1 (no output) = CLEAN. Any hit = do not push.
```

Scope notes:
- `--exclude-dir=superpowers` is deliberate: the specs/plans *name the banned strings* as
  documentation of the gate itself.
- The `.claude/skills/fs-*` handoff library is repo-internal source of truth but lives in a
  public repo; per the 2026-07-02 operator decision it may contain environment-specific paths
  **only when they are the actual mechanism and labeled environment-specific**. Any fs- skill
  promoted into `plugins/` must first pass the full gate above (strip or genericize such paths).
- The gate is one line of the mandatory local pre-push gate — the executable form lives in
  `fs-release-and-publish`. There is no CI to catch you (standing no-GitHub-Actions rule).

**Rationale:** master is live. A leaked client name or token prefix is public the instant you
push, and git history makes it permanent. The gate is grep-cheap; the failure is not.

---

## Rule 4 — Attribution and non-affiliation footer

Every public site in the family carries the footer. The live text
(`docs/index.html`, footer block, verified 2026-07-02):

> founder-skills · built by [Craig Merry](https://craigmerry.com) · MIT · source
> …not affiliated with Anthropic — see the official documentation

Check it survives any site edit:

```bash
grep -c "not affiliated with Anthropic" docs/index.html   # must be >= 1
grep -c "craigmerry.com" docs/index.html                  # must be >= 1
```

**Rationale:** the repo documents Anthropic products by name, from official docs, in
Anthropic's own house vocabulary. Without the disclaimer it reads as official; with it, the
accuracy discipline (Rule 2) is a personal warranty, which is the point.

---

## The honesty conventions (write these into skills)

These are house conventions, extracted from the golden four (see `fs-skill-style-guide` for
the full style; this section owns the *honesty* subset):

| Convention | Canonical instance | What it looks like |
|---|---|---|
| "Known limitations (keep your honesty consistent)" section | `plugins/market-validation/SKILL.md:92` | A skill that ships anything unproven names it, in the skill body, where the model will read it every run |
| The "syntax-checked only" admission | `market-validation/SKILL.md:93`, `build-options/SKILL.md:63` | *"The generalized workflow is syntax-checked only — its first real invocation is its proving run"* — verbatim, for both Workflow scripts (defect ledger #4; the proving run is the `fs-flagship-chain-campaign` target) |
| Refused, not silently skipped | `fable-org-audit/SKILL.md:163`, `fable-repo-audit/SKILL.md:179` | Fable 5 safety classifiers can false-positive on security-adjacent audit work; a refusal arrives as HTTP 200 + `stop_reason: "refusal"` — *"reported as refused, not silently skipped"*. Same shape in the research workflow: a permanently-failing angle is *"logged as DROPPED by name (no silent cap)"* (market-validation Tests section) |
| "Shape-valid; loading is the sink's to verify" | `market-validation/SKILL.md` Phase 4 | Emitted artifacts are described by what was actually tested; no platform integration "works today" until run (this is why the PlatAtlas flows.json question in `fs-platatlas-integration` is UNKNOWN, not assumed) |
| Confidence labels | verification-discipline.md §4 | Major claims carry HIGH/MODERATE/LOW; snippet-only or vendor-marketing sources are flagged weaker, never promoted to facts |
| Own-claims discipline | verification-discipline.md §6 | Verify your claims about your own artifacts the same way you verify research claims |

**When you add or edit a skill:** if it ships an executable asset, an unproven path, or a
manual seam, it MUST have a Known-limitations section naming that honestly. Deleting an
admission because the text "reads weak" is oversell — the admission is only removed by the
proving run that makes it false, committed through `fs-change-control`.

---

## The v0.2.0 fact-check methodology (this project's research method)

How the 2026-06-11 "Anthropic-primitives upgrade" turned a third-party listicle into five
shippable improvements — reuse this pipeline for ANY externally-sourced claim:

1. **Hypothesis.** Treat every third-party claim (here: a "14 steps" article about new
   Anthropic primitives) as a hypothesis, never as a fact.
2. **Live-URL verification, same session.** For each claim, find the official Anthropic page
   (launch doc, API reference, migration guide, announcement) and verify it live —
   `curl` the canonical URL, confirm 2xx, confirm the claim's content actually appears.
   Reading a cached summary or remembering the doc does not count.
3. **Adopt-or-drop.** Verified → adopt, cited to the official page, in official vocabulary.
   Unverifiable → drop entirely (the spec dropped the benchmark percentages). No hedged
   "reportedly" middle ground.
4. **It cuts both ways.** The same pass *restored* `/goal` as a real Claude Code surface,
   correcting an earlier over-removal — the method fixes under-claims too.
5. **Ship with a version bump and a gate.** Changed plugins went to `"version": "0.2.0"`
   (verified in `plugins/{fable-loop-design,effort,fable-org-audit}/.claude-plugin/plugin.json`);
   the spec's verification gate re-ran the sanitization scan, JSON parses, pytest, and a
   curl-check on every newly added link.

This is the same discipline market-validation imposes on market research
(`references/verification-discipline.md` §1: one tool-enabled verifier that re-fetches the
cited URL beats N toolless voters; default-drop what won't confirm) — applied to the repo's
own documentation. One method, two domains.

**Staleness warning (date-stamped):** the v0.2.0 URL verification ran on 2026-06-11. As of
2026-07-02 it is three weeks stale. "Verified that session" means claims do not stay verified;
the recurring re-verification sweep is `fs-freshness-watch`'s job. If you touch a doc claim
today, you re-verify its URL today — you do not inherit June's check.

---

## Honesty review checklist (run over any diff that ships text)

1. Does any new sentence claim a run/latency/token number not produced by an actual run? → cut or run it.
2. Does any "works with / loads into / runs itself" claim describe something never executed? → rewrite as "described, untested" or "shape-valid".
3. Does every Anthropic-primitive claim cite an official URL you verified live TODAY? → verify or drop.
4. Any percentages or benchmark numbers from non-official sources? → drop.
5. Sanitization grep (Rule 3) clean over the diff's files? → must be.
6. Footer intact if `docs/index.html` changed (Rule 4)?
7. Marketing surfaces (site cards, plugin READMEs) say nothing stronger than the SKILL.md they describe? (That delta is exactly defect #6.)
8. Known-limitations sections still true — and still present?

## Common mistakes

| Mistake | Fix |
|---|---|
| "The site says it, so the skill can too" | Direction is wrong: the SKILL.md is the ceiling; marketing surfaces may only equal or understate it |
| Softening a limitation ("mostly tested") instead of proving it | Run the proving run (see `fs-flagship-chain-campaign`) or keep the admission verbatim |
| Citing the migration guide from memory | Re-fetch the URL this session; docs move (docs.anthropic.com links were already once dead repo-wide) |
| Treating a Fable refusal as a bug and retrying silently | Report the section as refused (HTTP 200 + `stop_reason: "refusal"`); fallback to Opus 4.8 is opt-in on the API |
| Running the sanitization grep only over changed files | Run it repo-wide (public dirs) — a rename or template rescue can resurface an old string |
| Fixing the "~0 tokens" chips inline while doing other work | Site oversell fix is its own spec'd change through `fs-change-control` |

## Provenance and maintenance

All claims above verified 2026-07-02. One-line re-verification for anything that may drift:

```bash
cd <repo-root>   # /home/craigm26/projects/craigm26/founder-skills on the origin machine (environment-specific)

# Rule 1 doctrine line still present:
grep -n "must never write implementation code" plugins/fable-orchestrated-feature-dev/SKILL.md
# Routing table still as documented:
grep -n -A6 "Model routing reference" plugins/session-start/SKILL.md
# Rule 2 sources — the two governing specs:
ls docs/superpowers/specs/2026-06-11-anthropic-primitives-upgrade.md docs/superpowers/specs/2026-06-11-publish-private-six-design.md
# Oversell defect #6 still open (expect hits until the site spec lands; zero hits = fixed, update this skill):
grep -n "~0 tokens\|runs itself weekly" docs/index.html
# Rule 3 scan (exit 1 = clean):
grep -rniE 'reservoir|sk_live|sk_test|cfut_|/home/craigm26|castor-dash|/opt/robot-md|/etc/robot-md' plugins/ docs/ README.md .claude-plugin/ --exclude-dir=superpowers
# Rule 4 footer:
grep -c "not affiliated with Anthropic" docs/index.html
# Honesty conventions anchors:
grep -rn "syntax-checked only" plugins/*/SKILL.md
grep -rn "not silently skipped" plugins/*/SKILL.md
grep -rn "Known limitations" plugins/*/SKILL.md
# v0.2.0 bumps:
grep -h '"version"' plugins/fable-loop-design/.claude-plugin/plugin.json plugins/effort/.claude-plugin/plugin.json plugins/fable-org-audit/.claude-plugin/plugin.json
```

If any anchor above moves (line numbers WILL drift; the strings should not), update this skill
through the normal change pipeline — this file is source of truth for doctrine rationale, and a
stale runbook here is itself a Rule 2 violation.
