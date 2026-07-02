---
name: fs-orientation
description: >-
  Entry-point map of the founder-skills repo: layout, the four skill groups, the
  two-session history, quality tiers (golden four vs off-style), the open-defect
  ledger pointer, and a router table telling you which fs- sibling skill to load
  for which job. Load this FIRST when starting any maintenance work on
  founder-skills. Use when a maintainer says "orient me in founder-skills",
  "what is this repo", "where do I start", "which skill covers X", "map of
  founder-skills", "how is this repo organized", or begins any founder-skills
  task without a specific fs- skill already in mind.
---

# fs-orientation — the founder-skills entry map

Announce at start: "Loading fs-orientation — repo map and router for founder-skills."

You are maintaining `/home/craigm26/projects/craigm26/founder-skills` — a public GitHub
repo (`craigm26/founder-skills`, MIT) that is a **Claude Code marketplace: 12 plugins
committed at HEAD `2e4c9dd` plus 3 uncommitted `skill-*` plugins authored 2026-07-02
(15 on disk)**, positioned as "a judgment layer for Claude Code". Skills here encode *when and how* to
use Anthropic's execution primitives (Agent, Workflow, AskUserQuestion, model routing),
not the primitives themselves.

Two things make this repo unusual to maintain. Internalize both before touching anything:

1. **master is live.** Every push is instantly installable by the public via
   `/plugin marketplace add craigm26/founder-skills` and redeploys the GitHub Pages site
   (served from `master:/docs`, live at https://craigm26.github.io/founder-skills/ —
   verified 200 on 2026-07-02). There is no CI and never will be (standing org-wide
   no-GitHub-Actions rule since 2026-06-19). The only gate is the LOCAL pre-push gate —
   see `fs-release-and-publish`.
2. **Change control is spec → plan → verbatim commits.** Nothing lands without an
   operator-approved spec. Do not route around it — see `fs-change-control`.

## Repo layout (verified 2026-07-02)

```
founder-skills/
├── .claude-plugin/marketplace.json   # the marketplace manifest — 15 plugin entries
├── .claude/skills/fs-*/              # THIS handoff library (repo-internal source of truth)
├── plugins/<name>/                   # 15 self-contained plugins (the product; 3 are uncommitted)
│   ├── .claude-plugin/plugin.json    #   per-plugin manifest
│   ├── SKILL.md                      #   model context (lean)
│   ├── README.md                     #   human/marketing walkthrough
│   ├── references/  assets/  tests/  #   only where the skill needs them
├── docs/
│   ├── index.html                    # hand-rolled Pages site, single file, no build step
│   └── superpowers/
│       ├── specs/                    # 4 specs, all "Status: approved by operator"
│       └── plans/                    # 3 checkbox plans; commits match plan text verbatim
├── scripts/add-skill.sh              # plugin scaffolder (~160 lines; has known hazards)
├── README.md                         # repo front door (its test commands are BROKEN — see below)
└── LICENSE                           # MIT © 2026 Craig Merry
```

Definitions (used across all fs- skills):

| Term | Meaning here |
|---|---|
| **plugin** | One directory under `plugins/`, installable via the marketplace. Each wraps exactly one skill. |
| **skill** | A `SKILL.md` file — model-facing instructions loaded into Claude Code's context. |
| **marketplace** | `.claude-plugin/marketplace.json` — the index Claude Code reads on `/plugin marketplace add`. |
| **judgment layer** | The repo's positioning: skills that decide when/what/how-much, sitting above execution primitives. |
| **operator** | Craig Merry, the repo owner. Approves specs; runs all mutating git commands. Assistants never `git add/commit/push`. |
| **fs- skills** | This 15-skill handoff library in `.claude/skills/`, distinct from the published plugins. Its curated 3-plugin public subset (`skill-style-guide`, `skill-release-gate`, `skill-freshness-watch`) was authored and registered in marketplace.json on 2026-07-02 — **uncommitted**, awaiting operator commit (operator decision 2026-07-02). |

## The skill groups (15 plugins)

| Group | Plugins | Job |
|---|---|---|
| Session calibration | `session-start`, `effort` | 30-second start-of-session calibration: effort tier, domain, done-looks-like, model routing. |
| Fable 5 orchestration | `fable-orchestrated-feature-dev`, `fable-repo-audit`, `fable-org-audit`, `fable-loop-design` | Fable-plans → Opus/Sonnet-implements → Fable-reviews patterns; audits; loop/memory design. |
| Founder workflow chain | `market-validation` → `build-options` → `prd` → `tasks` | The flagship chain: validate a market → pick what to build → spec it → task plan. Handoffs pass file paths/JSON, never inline content. |
| Craft | `tufte-viz`, `ecosystem-planning` | Visualization critique; single-approvable-plan multi-repo programs. |
| Marketplace-maintainer tooling (uncommitted, 2026-07-02) | `skill-style-guide`, `skill-release-gate`, `skill-freshness-watch` | Genericized public versions of three fs- maintainer skills. |

## Two-session history (verified via git log, 2026-07-02)

The entire repo — 24 commits, single `master` branch, HEAD `2e4c9dd`, zero reverts, zero
dead branches — was built in exactly two sessions:

| Session | Commits | What happened |
|---|---|---|
| 2026-06-04 | 4 (co-authored Opus 4.8) | Marketplace bootstrapped: market-validation + build-options, then prd + tasks (imported from an external "compound engineering" methodology), plus `scripts/add-skill.sh`. |
| 2026-06-11 | 20 (co-authored Fable 5) | Everything else: genericization (vendor-neutral market map, external-executor framing), session-start/effort, Pages site, six skills graduated from the private `craigm26/claude-skills` repo, v0.2.0 Anthropic-primitives upgrade. |

Origin note: the six orchestration/craft skills are sanitized near-copies from the
private repo. **Public founder-skills is CANONICAL for the graduated six; the private
repo is frozen as historical archive** (operator decision 2026-07-02). The v0.2.0
fact-check verified claims against live Anthropic URLs on 2026-06-11 — that verification
is now 3 weeks stale (see `fs-freshness-watch`).

## Quality tiers — copy style from the right files

Not all plugins are equal. When writing or judging skill prose:

| Tier | Skills | Status |
|---|---|---|
| **Golden four** (the house style IS extracted from these) | `market-validation` (117 lines), `build-options` (78), `ecosystem-planning` (172), `fable-org-audit` (227) | Copy structure, voice, frontmatter, closers from these ONLY. |
| Conforming | `session-start`, `effort`, `fable-orchestrated-feature-dev`, `fable-repo-audit`, `fable-loop-design` | House style, fine as secondary examples. |
| **Off-style — never copy** | `tufte-viz` — nonconforming `\|` literal-block frontmatter instead of `>-`. (`prd`/`tasks` were in this tier until 2026-07-02; both were rewritten to house style in campaign Phase 2 and are now conforming.) | Only tufte-viz remains off-style. |

The written style rules live in `fs-skill-style-guide`. Frontmatter contract, directory
contract, and the per-plugin README template live in `fs-plugin-anatomy`.

## Open-defect ledger (pointer)

The full chronicle — all eight ledger entries with root causes, rescues, and lessons —
lives in **`fs-failure-archaeology`**. That skill is the ledger's single home; do not
duplicate its detail. Headline state as of 2026-07-02:

| # | Defect | State 2026-07-02 |
|---|---|---|
| 1 | build-options `assets/matrix.template.html` swallowed by `.gitignore` `*.html` — plugin shipped broken | RESCUED (file restored + `!assets/matrix.template.html` negation; pytest 9/9) but **UNCOMMITTED** — confirm with `git status` before assuming it landed |
| 2 | README test commands fail verbatim (PEP-668 host Python) | Open — use the venv procedure in `fs-toolchain-and-tests` |
| 3 | JS suite absent from README; only the glob form runs | Open — `node --test 'tests/js/*.test.mjs'` |
| 4 | Two Workflow scripts self-declared "syntax-checked only", never proven | Open — proving run is the `fs-flagship-chain-campaign` target |
| 5 | prd + tasks off-style with unstated agent-browser dep | Fixed 2026-07-02 — rewritten to house style, agent-browser genericized |
| 6 | Site oversell drift ("~0 tokens" chips ×2, "runs itself weekly") | Fixed 2026-07-02 — chips honest, copy corrected, site-checks.sh green |
| 7 | add-skill.sh hazards (schema-only validation, `rm -rf` on line ~142, cross-lists into a second marketplace) | Open — see `fs-skill-authoring` |
| 8 | emit_atlas.py → emit_market_map.py rename; external breakage unknowable (no telemetry) | Closed-as-accepted per spec |

## Router table — which fs- sibling to load

Load exactly the skill for the job. One home per fact; siblings cross-reference, they
don't duplicate.

| Your job | Load |
|---|---|
| Classify/gate a change; write a spec or plan; anything that mutates the repo | `fs-change-control` (mandatory first for ALL changes) |
| Push to master; run the pre-push gate; publish | `fs-release-and-publish` |
| Set up the venv/Node env; run or extend the three test suites | `fs-toolchain-and-tests` |
| Understand or check a plugin's directory/manifest structure | `fs-plugin-anatomy` |
| Apply the non-negotiables: no-oversell, sanitization gate, planner-never-codes, attribution | `fs-doctrine-and-honesty` |
| Write or review skill prose against house style | `fs-skill-style-guide` |
| Add a brand-new skill end to end (add-skill.sh workflow) | `fs-skill-authoring` |
| Reference the Anthropic primitives as used here (Workflow/AskUserQuestion/Agent tiers) | `fs-anthropic-primitives` |
| Understand a past failure; check the full defect ledger | `fs-failure-archaeology` |
| Edit docs/index.html or reposition marketing copy | `fs-site-and-positioning` |
| Prove/fix the flagship founder chain end to end | `fs-flagship-chain-campaign` |
| Anything touching PlatAtlas (endpoint map drift, market-map sink, rail agents, Loadout) | `fs-platatlas-integration` |
| Run the recurring drift/staleness re-verification sweep | `fs-freshness-watch` |
| Explore open research problems (measured-not-claimed token costs, etc.) | `fs-research-frontier` |

Route ambiguity rule: if the job mutates anything under version control, `fs-change-control`
wins and is loaded first, then the specialist skill. No fs- skill may route around it.

## Standing operator decisions (2026-07-02 — treat as policy)

- Handoff library home = `.claude/skills/` (source of truth); the curated public subset of
  3 (`skill-{style-guide,release-gate,freshness-watch}`) was built and registered
  2026-07-02 — uncommitted, awaiting operator commit.
- Direct-push-to-live-master stays, but the local pre-push gate is non-negotiable
  (all 3 suites + JSON parse + sanitization grep + URL sweep) — `fs-release-and-publish`.
- No GitHub Actions, ever.
- Assistants run **no mutating git commands**; the operator reviews and commits.
- Hardest-problem campaign target = flagship-chain hardening (`fs-flagship-chain-campaign`).

## 60-second orientation check (copy-paste, read-only)

```bash
cd /path/to/founder-skills            # environment-specific; on the origin host this is
                                      # /home/craigm26/projects/craigm26/founder-skills
git log --oneline | wc -l             # 24 as of 2026-07-02 (HEAD 2e4c9dd); more = new work exists
git status --short                    # ALL of the following are intentional 2026-07-02 handoff work,
                                      # uncommitted until the operator commits — do NOT revert them:
                                      #   M .claude-plugin/marketplace.json     (registers the 3 skill-* plugins)
                                      #   M plugins/build-options/.gitignore    (template-rescue negation, ledger #1)
                                      #  ?? .claude/                            (this fs- handoff library)
                                      #  ?? plugins/build-options/assets/matrix.template.html  (rescued template)
                                      #  ?? plugins/skill-freshness-watch/  skill-release-gate/  skill-style-guide/
ls plugins | wc -l                    # 15 on disk (12 at HEAD 2e4c9dd + 3 uncommitted skill-*)
python3 -c 'import json; json.load(open(".claude-plugin/marketplace.json")); print("ok")'
ls .claude/skills                     # the fs- handoff library (15 skills when complete)
```

If `git log` shows more than 24 commits, this skill's history/HEAD facts are stale —
run the `fs-freshness-watch` sweep before trusting date-stamped claims here.

## When NOT to use this skill

This is a map, not a runbook. Do not act from it directly:

- **Making any change** (even a typo fix): load `fs-change-control` — this skill contains
  no gating procedure.
- **Running tests or setting up the environment**: load `fs-toolchain-and-tests` — the
  README's own commands fail on the origin host and this skill deliberately omits the fix.
- **Pushing/publishing**: load `fs-release-and-publish`.
- **Digging into a defect's root cause**: load `fs-failure-archaeology` — the table above
  is headlines only.
- **Writing a new skill or judging prose style**: load `fs-skill-style-guide` and
  `fs-skill-authoring`.

If you already know which specialist job you're doing, skip this skill and load the
sibling from the router table.

## Common mistakes

| Mistake | Fix |
|---|---|
| Copying style from tufte-viz because it's in the repo | Only the golden four define house style (prd/tasks conform since 2026-07-02) |
| Trusting README's `python3 -m pytest` | PEP-668 host — venv procedure in `fs-toolchain-and-tests` |
| Pushing "small" fixes straight to master | master is LIVE; gate via `fs-change-control` + `fs-release-and-publish` |
| Assuming the template rescue (ledger #1) is committed | It was uncommitted as of 2026-07-02; check `git status` |
| Treating the private claude-skills repo as upstream | Public is canonical; private is frozen archive |
| Running `git add/commit/push` as an assistant | Operator-only; prepare, don't land |

## Provenance and maintenance

All facts verified against the repo on 2026-07-02 (HEAD `2e4c9dd`). Re-verify volatile
facts with these one-liners (run from the repo root):

```bash
# Commit count / HEAD / two-session claim
git log --oneline | wc -l                                        # was 24
git log --format=%ad --date=short | sort | uniq -c               # was: 4× 2026-06-04, 20× 2026-06-11
# Plugin count and marketplace parse
ls plugins | wc -l                                               # was 15 on disk (12 at HEAD 2e4c9dd)
python3 -c 'import json; print(len(json.load(open(".claude-plugin/marketplace.json"))["plugins"]))'  # was 15 (12 at HEAD)
# Ledger #1 rescue state (expect nothing once operator commits)
git status --short -- plugins/build-options
# Site oversell strings still present? (ledger #6 fixed 2026-07-02; expect 0)
grep -c '~0 tokens' docs/index.html; grep -c 'runs itself weekly' docs/index.html
# Pages site live
curl -s -o /dev/null -w '%{http_code}\n' https://craigm26.github.io/founder-skills/   # was 200
# Golden-four line counts (style-tier claim)
wc -l plugins/{market-validation,build-options,ecosystem-planning,fable-org-audit}/SKILL.md
# Off-style frontmatter check
head -3 plugins/tufte-viz/SKILL.md                               # was 'description: |' (nonconforming)
```

Facts most likely to drift: HEAD/commit count (any push), the uncommitted-rescue status
(operator commit), the ledger states (siblings' campaigns close them), and the 15-skill
fs- library completeness (`ls .claude/skills`). This skill's router table must be updated
if any fs- sibling is renamed, added, or removed.
