---
name: fs-research-frontier
description: >-
  The research agenda for founder-skills: four open problems where this repo could
  advance the state of the art, with why current skill catalogs fail, what asset
  this repo already holds, the first three concrete steps IN THIS REPO, and a
  falsifiable milestone for each. Priorities per operator decision 2026-07-02:
  measured-not-claimed token costs (primary), self-maintaining library,
  skills-as-product for PlatAtlas, ecosystem growth. Everything here is OPEN or
  CANDIDATE — nothing is claimed done. Use when a maintainer says "what's the
  research frontier", "what should we work on next beyond maintenance", "how do we
  measure token costs for real", "make the token claims honest", "can this library
  maintain itself", "skills as product", "how do outsiders contribute", or "what
  would make this repo state of the art".
---

# fs-research-frontier — open problems worth solving here

Announce at start: "Loading fs-research-frontier — the four-front research agenda (all items open/candidate)."

This skill is a **research agenda, not a runbook of finished work**. Every item below is
labeled OPEN or CANDIDATE. Nothing in this file may be cited as shipped. When one of these
fronts produces a result, the result moves out of this skill (into the sibling skill that
owns that surface) and this file's entry gets updated — via `fs-change-control`, like
everything else.

The four fronts and their priority order are an operator decision dated 2026-07-02.
Do not reorder them on your own judgment.

| # | Front | Status 2026-07-02 | One-line goal |
|---|---|---|---|
| 1 | **Measured-not-claimed** (PRIMARY) | OPEN — zero measurement artifacts exist | Every published token-cost number traces to a checked-in measurement artifact from a real run |
| 2 | Self-maintaining library | OPEN — manual sweep only | Freshness sweeps that auto-draft fix plans (never auto-approve) |
| 3 | Skills-as-product for PlatAtlas | OPEN — mapping undefined | founder-skills as the reference catalog behind PlatAtlas per-org Loadout |
| 4 | Ecosystem growth | OPEN — no contribution path | External contributions that pass the gate without operator rework |

## When NOT to use this skill

| You actually want | Load instead |
|---|---|
| Repo map, where anything lives, which skill for which job | `fs-orientation` |
| To ship any change these fronts propose (spec → plan → commits) | `fs-change-control` — no front here routes around it |
| The flagship-chain proving run (broken/unproven execution end) | `fs-flagship-chain-campaign` — that is the hardest LIVE problem; this skill is the horizon beyond it |
| The recurring drift sweep as it exists today | `fs-freshness-watch` — front 2 below is that sweep's future, not its manual |
| The PlatAtlas surface map, market-map sink, adoption guidance | `fs-platatlas-integration` — front 3 builds on it, doesn't restate it |
| House style / how to author a new skill | `fs-skill-style-guide`, `fs-skill-authoring` |
| Why the honesty rules exist | `fs-doctrine-and-honesty` |
| Past failures (the eight-entry defect ledger) | `fs-failure-archaeology` |

Definitions used below:

| Term | Meaning |
|---|---|
| **Measurement artifact** | A checked-in JSON/MD file recording token usage from one real run: totals by token type, model(s), date, and the transcript it was derived from. Does not exist yet anywhere in this repo. |
| **Transcript** | Claude Code's own per-session JSONL log. Environment-specific location: `~/.claude/projects/<escaped-cwd>/<session-id>.jsonl`. Each assistant message carries a `"usage"` object with `input_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, `output_tokens` (field names verified against a live transcript on this host, 2026-07-02). |
| **Loadout** | PlatAtlas feature #137: per-identity record of declared plugins/MCP/skills/tools with observed-vs-declared bloat flags. Lives in the PlatAtlas repo, not here. See `fs-platatlas-integration`. |
| **Chip** | The small gold token-cost label on each card of the Pages site (`docs/index.html`, `.card .cost`). |

---

## Front 1 — MEASURED-NOT-CLAIMED (primary)

### Why current state of the art fails

Skill catalogs — this one included — publish token-cost numbers **nobody measures**.
Verified in this repo on 2026-07-02:

- `plugins/market-validation/SKILL.md:17` claims "~1.5M tokens, ~38 agents, ~50 min" for
  the reference run. No artifact backs it; it is a recollection of one run.
- `docs/index.html` chips claim "~0 tokens" for session-start/effort and "~1.5M tokens /
  full run" for market-validation. The "~0 tokens" chips are already a logged defect
  (site oversell — defect ledger #6, see `fs-failure-archaeology`): loading any skill
  costs real context tokens.
- README claims "a few hundred tokens" for the judgment layer. Also unmeasured.

The wider ecosystem is worse: marketplace listings routinely carry no cost data at all,
or numbers with no provenance. Nobody measures because (a) measurement requires access to
raw session telemetry, (b) there is no agreed artifact format, and (c) claimed numbers
sell better than measured ones. A catalog whose every cost figure links to a reproducible
measurement would be, as far as we know (UNVERIFIED — no survey done), first of its kind.

### This repo's specific asset

1. **The honesty doctrine is already binding** (see `fs-doctrine-and-honesty`): no
   oversell, every claim traces to a verifiable source, unverifiable percentages dropped.
   Measured costs are the natural completion of that doctrine — the repo's own rules
   already demand this front.
2. **The admission convention exists**: both workflow skills already carry the line
   "syntax-checked only — its first real invocation is its proving run"
   (`plugins/market-validation/SKILL.md:93`, `plugins/build-options/SKILL.md:63`).
   "measured on N=1 run, artifact X" is the same honest register.
3. **Test harnesses exist** (pytest 6 + 9, node:test 5 — see `fs-toolchain-and-tests`),
   so a measurement script gets a test suite home instead of rotting as a loose script.
4. **The raw data source is confirmed present**: transcripts with per-message `usage`
   blocks exist on this host (verified 2026-07-02), and this skill ships a working,
   stdlib-only aggregator (below) proven against a live transcript.

### Seed tool (exists, in this skill dir, CANDIDATE for promotion)

```bash
python3 .claude/skills/fs-research-frontier/scripts/aggregate_transcript_usage.py \
  ~/.claude/projects/<escaped-cwd>/<session-id>.jsonl          # human-readable
# add --json for a machine-readable artifact body
```

Verified 2026-07-02 against this authoring session's own transcript: 147 lines, 48 usage
blocks, ~4.24M total tokens across all types (of which ~3.78M were cache reads — which is
exactly why "tokens" claims without a type breakdown mislead). The script is read-only
and dependency-free. It is NOT yet part of any plugin; promoting it requires a spec.

### First three steps — in this repo

1. **Spec the measurement-artifact schema** (via `fs-change-control`: date-prefixed spec
   in `docs/superpowers/specs/`, operator approval). CANDIDATE shape: `measurements/`
   top-level dir; one JSON per run: `{skill, date, model_ids, totals_by_token_type,
   usage_blocks, wall_clock, transcript_sha256, aggregator_version}`. Decide the
   cache-read question explicitly: report all four token types separately, never one
   blended number.
2. **Instrument the flagship proving run.** The `fs-flagship-chain-campaign` proving run
   is the first real invocation of the workflow scripts anyway — capture its transcript,
   run the aggregator, check in the first artifact. One run, two results (chain proven +
   first measurement). Do not run a separate burn just to measure.
3. **Replace one claim with one measurement.** Update `plugins/market-validation/SKILL.md:17`
   and the matching site chip to cite the artifact ("measured YYYY-MM-DD, N=1,
   `measurements/...json`") — site edits go through `fs-site-and-positioning` +
   change control. If the measured number contradicts ~1.5M, the claim changes, not
   the measurement.

### Falsifiable milestone

You have a result when: **at least one published token-cost number in this repo links to
a checked-in measurement artifact that a third party can regenerate from the referenced
transcript with a script in this repo — and a second independent run of the same skill
either lands within the artifact's stated tolerance or forces a published revision of the
claim.** If step 3 ships a "measured" label with no regenerable artifact behind it, the
front has failed its own doctrine.

---

## Front 2 — Self-maintaining library

### Why current state of the art fails

Every skill catalog rots: hardcoded model IDs go stale, verified URLs die, endpoint maps
drift. This repo has all three documented on 2026-07-02: the v0.2.0 URL fact-check is
three weeks stale; the fable-org-audit PlatAtlas endpoint map is missing four live
endpoints (see `fs-platatlas-integration`); the installed plugin cache silently desyncs
from HEAD on every push (see `fs-release-and-publish`). No catalog we know of detects its
own drift and drafts its own fix (UNVERIFIED — no survey done); freshness is universally
a human chore that stops happening.

### This repo's specific asset

- `fs-freshness-watch` already defines the sweep (what drifts, how to re-verify it).
- The change-control pipeline gives fix plans a **well-defined artifact shape**: checkbox
  plans in `docs/superpowers/plans/` whose text later commits must match verbatim. An
  auto-drafted plan therefore has an exact target format — rare among repos.
- Hard constraint that shapes the design: **no GitHub Actions, ever** (standing rule
  since 2026-06-19). Automation must be local or Anthropic-scheduled.

### First three steps — in this repo

1. Make the `fs-freshness-watch` sweep emit a **machine-readable findings file**
   (CANDIDATE: JSON list of `{check, expected, observed, verified_at}`) alongside its
   human output. Coordinate with that skill's owner surface; do not fork the sweep.
2. Write a **plan-drafter**: findings JSON → a `docs/superpowers/plans/`-style checkbox
   draft, hard-labeled `Status: DRAFT — not operator-approved`. The drafter proposes;
   only the operator promotes a draft to an approved plan. This front must never become
   a route around `fs-change-control` — auto-approval is explicitly out of scope.
3. Give the sweep a trigger that survives forgetting: CANDIDATE mechanisms are a Claude
   Code `/schedule` routine or a documented manual cadence in `fs-freshness-watch`.
   (Which mechanism actually fires reliably on this host is UNVERIFIED — proving that is
   part of the step.)

### Falsifiable milestone

You have a result when: **a scheduled or routinely-triggered sweep detects a real drift
item (e.g., a canonical URL now non-2xx, or a live endpoint absent from a skill's map)
and produces a draft fix plan the operator approves without re-diagnosing the drift by
hand.** If the operator has to redo the investigation, the draft added ceremony, not
maintenance — count it as a failure.

---

## Front 3 — Skills-as-product for PlatAtlas

### Why current state of the art fails

Marketplaces distribute skills but no platform closes the loop on **which identity
actually carries what, and whether it's used**. Declared-vs-observed tooling per agent
identity barely exists. PlatAtlas has the receiving half — Loadout (#137): per-identity
plugins/MCP/skills/tools with observed-vs-declared bloat flags, built in the PlatAtlas
repo (environment-specific; status per `fs-platatlas-integration`, dated 2026-07-02).
What no one has: a public skill catalog whose entries are **structured enough to be the
"declared" side of that comparison**, with measured per-skill cost as the datum bloat
flags need.

### This repo's specific asset

- `.claude-plugin/marketplace.json` is already a machine-readable catalog: 15 entries
  (12 committed + 3 uncommitted skill-*, 2026-07-02) with `name`, `description`, `author`,
  `category`, `source`, `homepage` (fields verified 2026-07-02). No scraping needed — the
  manifest IS the feed.
- `fable-org-audit` already audits live PlatAtlas orgs; a "Loadout / tooling" probe is a
  natural ninth dimension CANDIDATE (do not add it without a spec).
- Front 1's measurement artifacts, once they exist, are exactly the per-skill cost datum
  a bloat flag compares against.

### First three steps — in this repo

1. **Document the catalog contract**: a reference note (CANDIDATE home:
   `fs-platatlas-integration` references/, since that skill owns the integration surface)
   stating which marketplace.json fields are stable API for downstream consumers and
   which may change without notice. Today nothing is promised — that's the gap.
2. **Draft the mapping schema**: marketplace entry → Loadout "declared" record
   (CANDIDATE: `{plugin_name, version_or_commit, source_url, category, measured_cost_ref}`).
   Keep it vendor-neutral like the market-map emitter (`plugins/market-validation/
   assets/market-map/emit_market_map.py`) — PlatAtlas is the worked sink, not the schema.
3. **Wire cost into the schema**: `measured_cost_ref` points at a Front-1 artifact, or is
   explicitly `null` ("unmeasured") — never a claimed number. This is the honesty
   doctrine crossing the repo boundary.

### Falsifiable milestone

You have a result when: **one PlatAtlas identity's Loadout shows a founder-skills plugin
as declared, generated from marketplace.json by the mapping schema with zero hand-editing
of the record.** The generation happens PlatAtlas-side; the founder-skills result is that
the schema was consumed unchanged. If PlatAtlas needed to patch the schema to make it
load, the contract wasn't a contract — iterate here, not there.

---

## Front 4 — Ecosystem growth

### Why current state of the art fails

Skill-catalog contributions are drive-by PRs with no quality gate, so maintainers either
absorb style debt or stop merging. This repo's own history proves the failure mode
internally: `prd` and `tasks` were imported from an external methodology and are still
off-style — different voice, no model routing, ~480 lines, an unstated third-party CLI
dependency (defect ledger #5). That is what an unreviewed import does even when the
importer is the maintainer.

### This repo's specific asset

- The written house style now exists (`fs-skill-style-guide`) — extracted 2026-07-02 from
  the golden four. A contribution can be checked against a document, not a vibe.
- `scripts/add-skill.sh` scaffolds a conforming plugin — but its validation is
  manifest-schema-only and it has known hazards (`rm -rf` on an existing non-symlink
  skill dir; cross-listing into a marketplace that may not exist on other machines —
  defect ledger #7, details in `fs-skill-authoring`).
- The pre-push gate (`fs-release-and-publish`) plus the sanitization hard gate
  (`fs-doctrine-and-honesty`) already define what "safe to publish" means; a contributor
  checklist can point at them instead of inventing new rules.

### First three steps — in this repo

1. **Spec CONTRIBUTING.md** (does not exist — verified 2026-07-02). Content = pointers,
   not prose: style guide conformance, the venv + glob-form test commands that actually
   work on this host (see `fs-toolchain-and-tests` — the README's own test commands fail
   verbatim, defect ledger #2; fix that before inviting outsiders to follow them).
2. **Harden add-skill.sh validation** beyond manifest schema: it passed build-options
   while the plugin's core template asset was missing from git (ledger #1 + #7).
   CANDIDATE check: every file a SKILL.md references under `assets/`/`references/` must
   be tracked by git — that one check would have caught the repo's worst shipped defect.
3. **Define the external-contribution gate** as an explicit checklist in CONTRIBUTING.md:
   style conformance + tests present-and-passing + sanitization grep clean + no new
   unstated dependencies. Operator remains the only merger; the gate's job is that
   merging requires no rework.

### Falsifiable milestone

You have a result when: **the first external (non-operator) PR merges having passed the
documented gate with zero operator style rework, and the resulting plugin needs no entry
in the defect ledger for six weeks.** If the operator rewrites the contribution to make
it mergeable, the gate didn't gate — revise the checklist, not the standard.

---

## Cross-front rules (binding on all four)

| Rule | Consequence |
|---|---|
| Every front's changes go through `fs-change-control` | No auto-approval, no direct-to-master experiments, ever |
| No oversell | A front's result is claimable only after its falsifiable milestone is met — until then it stays OPEN/CANDIDATE in this file |
| No GitHub Actions (standing rule since 2026-06-19) | All automation is local scripts or Anthropic-scheduled runs |
| One home per fact | When a front ships, its facts move to the owning sibling skill; this file keeps only the agenda entry and its status |
| Measurement before marketing | Fronts 3 and 4 both consume Front 1's artifacts; do not ship cost claims into either while Front 1 is unmet |

## Common Mistakes

| Mistake | Fix |
|---|---|
| Citing this file as evidence something is built | Everything here is OPEN/CANDIDATE by definition — check the owning sibling skill for shipped state |
| Reporting one blended "total tokens" number | Always break out all four token types; cache reads dominated 89% of this skill's own authoring session |
| Measuring with a purpose-built burn run | Piggyback on runs that must happen anyway (the flagship proving run first) |
| Letting the plan-drafter self-approve | Drafts are `Status: DRAFT`; only the operator promotes — Front 2 never bypasses change control |
| Designing Front 3's schema around PlatAtlas internals | Vendor-neutral schema, PlatAtlas as worked sink — same discipline as the market-map emitter |
| Inviting contributors while README test commands are broken | Fix ledger #2 first (see `fs-toolchain-and-tests`); a broken front door is a contribution gate in the wrong direction |

## Provenance and maintenance

All facts dated 2026-07-02 unless noted. Re-verify before relying on:

```bash
# Unmeasured claims still present? (Front 1's targets)
grep -n "1.5M tokens" plugins/market-validation/SKILL.md docs/index.html
grep -n "~0 tokens" docs/index.html                     # ledger #6 oversell — gone means fixed
# Seed aggregator still runs (read-only; pick any transcript on this host):
python3 .claude/skills/fs-research-frontier/scripts/aggregate_transcript_usage.py \
  "$(ls -t ~/.claude/projects/*/*.jsonl | head -1)"     # environment-specific path
# Transcript usage fields still shaped as documented:
grep -m1 -o '"usage":{[^}]*}' "$(ls -t ~/.claude/projects/*/*.jsonl | head -1)"
# measurements/ dir exists yet? (Front 1 step 1 shipped?)
ls measurements/ 2>&1
# CONTRIBUTING.md exists yet? (Front 4 step 1 shipped?)
ls CONTRIBUTING.md 2>&1
# Marketplace manifest fields unchanged? (Front 3 depends on them)
python3 -c "import json;m=json.load(open('.claude-plugin/marketplace.json'));print(len(m['plugins']),sorted(m['plugins'][0].keys()))"
# Admission convention still present (Front 1 asset #2):
grep -rn "syntax-checked" plugins/*/SKILL.md
# Operator priorities: this file's own frontmatter + the 2026-07-02 decisions —
# if a newer operator decision reorders the fronts, update the table at top FIRST.
```

Volatile items most likely to drift: PlatAtlas Loadout status (lives in another repo —
defer to `fs-platatlas-integration`); the "no survey done" UNVERIFIED claims about the
wider ecosystem (a real survey would strengthen or kill Fronts 1–2's novelty claims);
transcript JSONL format (Anthropic-controlled, could change in any Claude Code release —
the aggregator's recursive scan tolerates layout shifts but re-run the grep above).

## References

- `scripts/aggregate_transcript_usage.py` — stdlib-only usage aggregator, proven against
  a live transcript 2026-07-02 (read-only; CANDIDATE for promotion into a plugin via spec)
