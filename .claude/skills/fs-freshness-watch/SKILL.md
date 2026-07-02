---
name: fs-freshness-watch
description: >-
  Run the recurring re-verification sweep that catches drift in founder-skills: hardcoded model
  IDs (Opus 4.8 / Sonnet 4.6 / Haiku 4.5 / Fable 5) and the multi-file bump procedure when
  Anthropic ships new models, beta API surfaces cited in v0.2.0 content (task budgets, Outcomes,
  fallbacks — last live-verified 2026-06-11), cited doc-URL liveness, installed-cache vs repo
  sync, sibling-site consistency, and private-repo divergence. Use when a founder-skills
  maintainer says "run the founder-skills freshness sweep", "is anything stale in this repo",
  "Anthropic shipped a new model — what do we bump here", "re-verify this repo's beta claims",
  "check the URLs this repo cites still resolve", "are installed users behind the repo", or on
  any monthly / pre-release founder-skills maintenance pass. If you are NOT working inside
  founder-skills, load the public skill-freshness-watch plugin instead — it is the generic
  version of this sweep.
---

# fs-freshness-watch — the recurring drift sweep

founder-skills publishes **claims about a moving target**: Anthropic model names, beta API
parameters, and documentation URLs are hardcoded across 27 files (2026-07-02 count), and the repo's own doctrine
says every published claim must trace to an official source verified *that session*
(see `fs-doctrine-and-honesty`). "Drift" = the world changing while the repo's text stands
still. This skill is the sweep that detects it, plus the procedure for fixing what it finds.

**Announce at start:** "Running fs-freshness-watch: drift sweep across model IDs, beta
surfaces, URLs, cache, and sibling repos."

The sweep itself is **read-only**. Anything it finds that needs a published-file edit goes
through the normal spec → plan → commit pipeline (`fs-change-control`) — this skill never
authorizes routing around it.

---

## When NOT to use this skill

| Your actual job | Load instead |
|---|---|
| Understand what the beta primitives (Outcomes, task budgets, fallbacks) *are* | `fs-anthropic-primitives` |
| Ship a change you already know about (gate, push, publish) | `fs-release-and-publish` |
| Classify/spec the fix the sweep uncovered | `fs-change-control` |
| Fix the site's oversell chips or edit docs/index.html | `fs-site-and-positioning` |
| Check the PlatAtlas endpoint map for drift (pulse/grants/ingest-health/org-collisions) | `fs-platatlas-integration` |
| First orientation to the repo | `fs-orientation` |

---

## Step 1 — Run the sweep script

An executable sweep lives beside this skill:

```bash
# offline (default — no network calls):
.claude/skills/fs-freshness-watch/scripts/freshness-sweep.sh

# with live URL checks (curl HEAD/GET each cited URL, 10s timeout):
.claude/skills/fs-freshness-watch/scripts/freshness-sweep.sh --network
```

Run it from anywhere; it locates the repo root from its own path (or pass the root as an
argument). It mutates nothing. Exit code **0** = no automated drift found; **1** = at least one
`[ATTENTION]` line; **2** = wrong directory.

It runs seven numbered checks: (1) model-ID inventory, (2) JSON manifest parse + version
table, (3) beta-surface citation map, (4) cited-URL inventory (+optional liveness),
(5) installed-cache vs repo diff, (6) sibling-site consistency, (7) private-repo divergence.
Checks 5–7 are environment-specific (they need this machine's `~/.claude` cache and local
checkouts) and skip gracefully elsewhere.

**Real output, run 2026-07-02 on the handoff working tree (abridged; exit 1):**

```
== 1. Model-ID inventory ==
  Opus 4\.8          32 occurrences      Fable 5            40 occurrences
  Sonnet 4\.6        31 occurrences      claude-fable-5     1 occurrences
  Haiku 4\.5         10 occurrences      claude-opus-4-8    3 / claude-sonnet-4-6  2
  Per-file map (bump sites): 27 files — see Step 2
== 2. JSON manifests ==  all 16 parse; versions 0.1.0 / 0.2.0 (see table)
== 3. Beta surfaces ==   task-budgets-2026-03-13 (effort:70), user.define_outcome (5 sites),
                         fallbacks (repo-audit:176, org-audit:160)
== 4. URLs ==            14 cited URLs; with --network all returned 200 on 2026-07-02
== 5. Cache ==           12 plugins in-sync (cache = repo HEAD 2e4c9dd), plus
                         [ATTENTION] cache missing plugin: skill-freshness-watch
                         [ATTENTION] cache missing plugin: skill-release-gate
                         [ATTENTION] cache missing plugin: skill-style-guide
== 6. Sibling site ==    8 model-ID mentions, last commit 01aa2b6 2026-06-11
== 7. Private repo ==    OK — still frozen at ab5bcb2 (2026-06-11)
== RESULT ==             DRIFT / ATTENTION ITEMS FOUND.
```

The three `[ATTENTION]` lines are the **expected baseline** until the 3 uncommitted
`skill-*` plugins (added to `plugins/` + marketplace.json on 2026-07-02) are committed and
installed — the script is correctly detecting that the cache predates them, not a defect.
Triage anything else printed as `[ATTENTION]` using Steps 2–6 below.

---

## Step 2 — Model-ID drift and the multi-file bump procedure

The repo hardcodes model names as **facts of its routing doctrine** (Fable 5 plans/reviews,
Opus 4.8 implements complex, Sonnet 4.6 standard, Haiku 4.5 as a cheap external executor).
When Anthropic ships a successor generation, every one of these is a bump site. Counts
verified 2026-07-02:

| String | Occurrences | Kind |
|---|---|---|
| `Fable 5` | 40 | marketing name (planner tier) |
| `Opus 4.8` / `Sonnet 4.6` | 32 / 31 | marketing names (implementer tiers) |
| `Haiku 4.5` | 10 | marketing name (cheap tier) |
| `claude-fable-5`, `claude-opus-4-8`, `claude-sonnet-4-6` | 1 / 3 / 2 | literal API IDs — in `plugins/fable-orchestrated-feature-dev/SKILL.md`, plus one `claude-opus-4-8` example mention in `plugins/skill-freshness-watch/SKILL.md` (Step 2, line 72 as of 2026-07-02) |

**Bump procedure** (this is a published-content change — spec it via `fs-change-control` first):

1. Regenerate the per-file map: sweep section 1 prints it. Files split into two classes:
   - **DO edit**: `plugins/*/SKILL.md`, `plugins/*/README.md`,
     `plugins/{effort,fable-loop-design,fable-orchestrated-feature-dev}/.claude-plugin/plugin.json`
     (descriptions name models), `.claude-plugin/marketplace.json` (3 descriptions),
     `README.md`, `docs/index.html`.
   - **DO NOT edit**: `docs/superpowers/specs/*` and `docs/superpowers/plans/*` — they are
     dated historical documents of record; rewriting them falsifies history.
2. Verify the new model names/IDs against the official models page (cited in the repo:
   `https://platform.claude.com/docs/en/docs/about-claude/models/overview`) **in the same
   session** — no-oversell doctrine requires session-fresh verification.
3. Bump the `version` in each touched plugin's `plugin.json` (semver; the v0.2.0 spec
   precedent bumped every plugin whose SKILL.md changed). Structural rules: `fs-plugin-anatomy`.
4. Mirror the change into the **sibling site** `claude-skills-site` (8 model-ID mentions in
   its `index.html`, verified 2026-07-02) in the same pass — no automation links the two repos.
5. Ship through the pre-push gate (`fs-release-and-publish`). Remember: master is
   live-publishing, and installed users desync silently until they update (Step 5).

---

## Step 3 — Beta API surfaces (staleness clock started 2026-06-11)

The v0.2.0 upgrade (spec `docs/superpowers/specs/2026-06-11-anthropic-primitives-upgrade.md`)
added claims about **beta** Anthropic surfaces, live-verified against official docs on
2026-06-11 — **3 weeks stale as of 2026-07-02**. Betas rename, graduate, or vanish. Citation
sites (sweep section 3 regenerates this):

| Beta surface | Cited at | Claim at risk |
|---|---|---|
| Task Budgets, header `task-budgets-2026-03-13`, min 20,000 tokens | `plugins/effort/SKILL.md:70` | header string + minimum may change on GA |
| Outcomes: `user.define_outcome` event, `max_iterations` default 3 / max 20 | `plugins/{tasks,fable-loop-design,fable-orchestrated-feature-dev}/SKILL.md` + one README | event name, defaults, terminal states |
| `fallbacks` beta param (opt-in Opus 4.8 retry on refusal) | `plugins/fable-{repo,org}-audit/SKILL.md` (lines 176 / 160) | param name + opt-in semantics |

**Re-verification procedure**: fetch the current official docs (platform.claude.com API
reference / betas page) and confirm each header string, event name, and numeric limit still
appears verbatim. If a surface graduated or renamed, that is a content fix → spec it
(`fs-change-control`), update the SKILL.md(s), bump versions. What these primitives mean and
how the skills use them is homed in `fs-anthropic-primitives` — don't duplicate it here.
Suggested cadence: every sweep, hard requirement if >90 days since last verification.

---

## Step 4 — Cited doc-URL liveness

14 external URLs are cited across `plugins/**.md` + `README.md` (9× code.claude.com docs,
2× platform.claude.com docs, github.com/vercel-labs/agent-browser, platatlas.com,
craigmerry.com — the 2026-07-02 skill-* plugins brought `docs/en/plugins` and
`docs/en/plugin-marketplaces` into the plugins/ scope). Sweep section 4 lists them;
`--network` curls each. **All 14 returned HTTP 200 on 2026-07-02.**

A 200 proves liveness, not correctness: for the two platform.claude.com doc pages, also
spot-check that the page still supports the claim it anchors (doctrine: source-traceability).
A redirect chain ending in 200 is tolerated by the script; a 404/410/ERR is an `[ATTENTION]`
item → fix the link through change control.

---

## Step 5 — Installed cache, sibling site, private repo

These three checks are **environment-specific** (this maintainer machine); the mechanisms are
real, the paths are not portable.

- **Installed plugin cache** (`~/.claude/plugins/cache/founder-skills/<plugin>/<version>/`) —
  what a Claude Code session actually loads after install. Verified in-sync with repo HEAD
  `2e4c9dd` on 2026-07-02. Every push to master silently desyncs every installed user until
  they update — so after any release, expect this check to flag DIVERGE on machines that
  haven't re-installed. The cache is also *mutable at runtime*: the build-options template
  survived **only** in this cache (regenerated there 2026-06-24) for the final 8 days of a
  breakage that had shipped since 2026-06-04 (defect ledger #1 — full story in
  `fs-failure-archaeology`). A cache file with no repo counterpart is a red flag, not junk.
- **Sibling site** `claude-skills-site` (separate repo → craigm26.github.io/claude-skills-site;
  local checkout `~/projects/craigm26/claude-skills-site`, override with `SIBLING_SITE=`):
  8 model-ID mentions, last commit 01aa2b6 (2026-06-11). Must be updated manually in the same
  pass as any model bump. Site-editing rules: `fs-site-and-positioning`.
- **Private repo** `claude-skills` (github.com/craigm26/claude-skills; local
  `~/projects/craigm26/claude-skills`, override with `PRIVATE_REPO=`): frozen historical
  archive at ab5bcb2 (2026-06-11) per operator decision 2026-07-02 — public founder-skills is
  canonical for the six graduated skills. Any commit there after ab5bcb2 is policy drift; the
  script flags it.

---

## CANDIDATE (not claimed working): scheduled self-maintenance

Two mechanisms could run this sweep automatically; **neither has been set up or proven for
this repo** — treat as an open experiment, and do not describe the sweep as "automated"
anywhere public (that would repeat the site's "runs itself weekly" oversell, defect ledger #6):

- Claude Code `/schedule` routine (cloud cron agent) invoking this skill monthly and reporting
  `[ATTENTION]` items. UNVERIFIED: whether a scheduled cloud agent has this repo + the local
  cache/sibling checkouts available (checks 5–7 would skip).
- Host `cron` on this machine running `freshness-sweep.sh --network` and mailing/logging
  non-zero exits. UNVERIFIED: no crontab entry exists as of 2026-07-02.

GitHub Actions is **not** a candidate — standing org-wide no-Actions rule (since 2026-06-19).
If someone proves one of these, record the working invocation here and in
`fs-failure-archaeology` if it misfires.

---

## Common mistakes | Fix

| Mistake | Fix |
|---|---|
| "Sweep passed, so all claims are current" | Exit 0 covers automated checks only; beta-surface and URL *content* re-verification are manual (Steps 3–4) |
| Editing specs/plans during a model bump | Never — they are dated history; edit only the DO-edit list in Step 2 |
| Fixing drift directly on master because "it's just a string" | Published-content changes go through `fs-change-control`, then the `fs-release-and-publish` gate |
| Bumping the repo but not the sibling site | Same-pass manual mirror; no automation exists |
| Deleting "orphan" files from the plugin cache | Cache-only files may be the sole survivor of a gitignore swallow (ledger #1) — investigate first |
| Writing `[^ ...\]]` bracket patterns in grep -E | In ERE, `\` is not special inside brackets; `\]` closes the class early and the pattern silently matches nothing (bug found and fixed in this script's own development, 2026-07-02) |
| Claiming the sweep "runs itself" | It doesn't — scheduling is a labeled CANDIDATE above |

---

## Provenance and maintenance

All facts dated 2026-07-02 unless noted. One-line re-verification commands (run from repo root):

- Full sweep (regenerates every number in this file): `.claude/skills/fs-freshness-watch/scripts/freshness-sweep.sh --network`
- Model-ID counts (Step 2 table): `grep -rcE 'Opus 4\.8|Sonnet 4\.6|Haiku 4\.5|Fable 5' --include='*.md' --include='*.json' --include='*.html' plugins docs README.md .claude-plugin | grep -v ':0$'`
- Beta citation lines (Step 3 table): `grep -rnE 'task-budgets-2026-03-13|user\.define_outcome|fallbacks' --include='*.md' plugins`
- Repo HEAD vs cache claim: `git log -1 --format='%h'` and `diff -q ~/.claude/plugins/cache/founder-skills/effort/0.2.0/SKILL.md plugins/effort/SKILL.md` (environment-specific)
- Plugin version table: `for f in plugins/*/.claude-plugin/plugin.json; do python3 -c "import json;d=json.load(open('$f'));print(d['name'],d['version'])"; done`
- Sibling-site staleness: `git -C ~/projects/craigm26/claude-skills-site log -1 --format='%h %ad'` (environment-specific)
- Private-repo freeze: `git -C ~/projects/craigm26/claude-skills log -1 --format='%h %ad'` — expect `ab5bcb2 ... Jun 11 2026` (environment-specific)
- v0.2.0 verification date + constraints: `sed -n '1,10p' docs/superpowers/specs/2026-06-11-anthropic-primitives-upgrade.md`

Volatile facts to re-stamp when they change: repo HEAD (2e4c9dd), cache install date
(2026-06-24), URL check date (2026-07-02, all 200), beta verification date (2026-06-11),
occurrence counts in Step 2.

## References

- `scripts/freshness-sweep.sh` — the executable sweep (this skill's asset)
- `docs/superpowers/specs/2026-06-11-anthropic-primitives-upgrade.md` — origin of the beta claims + their verification gate
- Siblings: `fs-change-control`, `fs-release-and-publish`, `fs-anthropic-primitives`, `fs-site-and-positioning`, `fs-failure-archaeology`, `fs-platatlas-integration`
