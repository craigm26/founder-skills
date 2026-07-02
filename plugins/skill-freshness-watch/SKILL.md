---
name: skill-freshness-watch
description: >-
  Run a recurring re-verification sweep that catches drift in a published Claude Code skill
  marketplace: hardcoded model IDs and the multi-file bump procedure when Anthropic ships new
  models, beta API surfaces cited in skill text, cited doc-URL liveness, installed-plugin-cache
  vs repo sync, sibling-site consistency, and divergence from upstream/downstream repos. Use
  when a marketplace maintainer says "sweep my marketplace for drift", "is my skill marketplace
  stale", "a new model shipped — what do we bump in my marketplace", "audit my published claims
  for staleness", "check my marketplace's cited URLs", "are my installed users behind my repo",
  or on any monthly / pre-release maintenance pass over a marketplace you publish.
---

# skill-freshness-watch — the recurring drift sweep

A published skill marketplace makes **claims about a moving target**: model names, beta API
parameters, pricing, and documentation URLs get hardcoded across dozens of files, while the
world keeps moving. "Drift" = the world changing while your repo's text stands still. This
skill is the sweep that detects it, plus the procedure for fixing what it finds.

**Announce at start:** "Running skill-freshness-watch: drift sweep across model IDs, beta
surfaces, URLs, installed cache, and sibling repos."

The sweep itself is **read-only**. Anything it finds that needs a published-file edit goes
through your normal change process (spec/review/version-bump — whatever your repo uses); this
skill never authorizes routing around it.

---

## Step 0 — Confirm the drift surfaces

Ask once, batched, before sweeping:

```
AskUserQuestion:
1. "Where do published skills live?" — plugins/*/SKILL.md (Recommended) / .claude/skills/ / other (specify)
2. "Which environment-specific checks apply on this machine?" (multi-select) —
   installed plugin cache (~/.claude/plugins/cache/) / sibling marketing site repo /
   an upstream or downstream repo that must stay in sync / none
```

Skip the question if the maintainer already told you, or if you can see the layout directly.

---

## Step 1 — Inventory what can drift

Six check classes. Run the greps from the repo root and adapt the paths to your repo:

| # | Check | How (generic) |
|---|---|---|
| 1 | Model-ID inventory | `grep -rcE '<model marketing names \| API IDs>' --include='*.md' --include='*.json' --include='*.html' <published dirs> \| grep -v ':0$'` |
| 2 | Manifest parse + version table | `for f in plugins/*/.claude-plugin/plugin.json; do python3 -c "import json;d=json.load(open('$f'));print(d['name'],d['version'])"; done` |
| 3 | Beta-surface citations | `grep -rnE '<beta header strings \| event names \| param names>' --include='*.md' <published dirs>` |
| 4 | Cited-URL inventory | `grep -rhoE 'https?://[^ )>"]+' --include='*.md' <published dirs> \| sort -u` |
| 5 | Installed cache vs repo | `diff -q ~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/SKILL.md plugins/<plugin>/SKILL.md` per plugin |
| 6 | Sibling / upstream repos | `git -C <sibling checkout> log -1 --format='%h %ad'` vs your expectation |

Checks 5–6 are environment-specific — they need a maintainer machine with the installed cache
and local checkouts. Skip them gracefully elsewhere and say so; do not report them as passed.

Report every finding as either `OK` (with the evidence) or `[ATTENTION]` (with the file:line),
then triage `[ATTENTION]` items using Steps 2–5.

---

## Step 2 — Model-ID drift and the multi-file bump procedure

If your skills route work between model tiers (planner tier / implementer tier / cheap tier),
every hardcoded model name is a bump site when a successor generation ships. Two string kinds
drift independently: **marketing names** (e.g. "Opus 4.8") and **literal API IDs** (e.g.
`claude-opus-4-8`) — grep for both.

**Bump procedure** (a published-content change — run it through your change process first):

1. Regenerate the per-file map (check 1 above with `-l` instead of `-c`). Split the files
   into two classes:
   - **DO edit**: skill bodies, plugin READMEs, `plugin.json` descriptions that name models,
     the marketplace manifest, the top-level README, any published site pages.
   - **DO NOT edit**: dated specs, plans, changelogs, or decision records — they are
     historical documents; rewriting them falsifies history.
2. Verify the new model names/IDs against the official models page
   (`https://platform.claude.com/docs/en/docs/about-claude/models/overview`) **in the same
   session** — never bump from memory or secondhand posts.
3. Bump the `version` in each touched plugin's `plugin.json` (semver). Installed users only
   see changes when versions move.
4. Mirror the change into any **sibling site or catalog repo** in the same pass — assume no
   automation links the repos unless you built it.
5. Ship through your normal release gate. If your default branch is live-publishing,
   remember that installed users desync silently until they update (Step 5).

---

## Step 3 — Beta API surfaces (start a staleness clock)

If any skill cites a **beta** surface — a beta header string, an event name, a default or
maximum, an opt-in parameter — record the date it was last verified against official docs.
Betas rename, graduate, or vanish, and their numeric limits change on GA.

Maintain a citation table (check 3 regenerates the locations):

| Beta surface | Cited at | Claim at risk | Last verified |
|---|---|---|---|
| e.g. a beta header string + minimum value | `plugins/<plugin>/SKILL.md:<line>` | header string + minimum may change on GA | date |

**Re-verification procedure**: fetch the current official docs and confirm each header
string, event name, and numeric limit still appears verbatim. Anything that graduated or
renamed is a content fix → change process, edit the skill(s), bump versions. Suggested
cadence: every sweep; hard requirement if more than 90 days since last verification.

---

## Step 4 — Cited doc-URL liveness

List every external URL cited across published files (check 4), then curl each:

```bash
grep -rhoE 'https?://[^ )>"]+' --include='*.md' plugins README.md | sort -u | \
  while read -r u; do printf '%s ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' -L --max-time 10 "$u"; done
```

A 200 proves **liveness, not correctness**: for doc pages that anchor a specific claim, also
spot-check that the page still supports the claim. Tolerate a redirect chain ending in 200;
treat 404/410/timeouts as `[ATTENTION]` → fix the link through your change process. Stamp the
check date next to the results.

---

## Step 5 — Installed cache, sibling sites, upstream repos

Three environment-specific checks. The mechanisms are real everywhere; the exact paths are
yours to adapt.

- **Installed plugin cache** (`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`) —
  this is what a Claude Code session actually loads after install, and it is *mutable at
  runtime*: a session can regenerate a missing asset into the cache, leaving the cache as the
  only surviving copy of a file your `.gitignore` silently swallowed from the repo. So: a
  cache file with **no repo counterpart is a red flag, not junk** — investigate before
  deleting. Also expect DIVERGE right after any release, on every machine that hasn't
  re-installed.
- **Sibling site / catalog repo** — if a separate repo markets or lists your skills, it holds
  its own copies of model names and claims. Check its last-commit date against your last
  content change; mirror model bumps manually in the same pass.
- **Upstream/downstream repo** — if your skills graduated from (or feed into) another repo,
  decide which one is canonical and check the other hasn't moved. Any commit past the agreed
  freeze/sync point is policy drift worth flagging.

---

## CANDIDATE (not claimed working): scheduled self-maintenance

Two mechanisms could run this sweep automatically; treat both as an open experiment until
**you** have proven one in your environment, and do not describe the sweep as "automated"
anywhere public until then:

- A Claude Code `/schedule` routine (cloud cron agent) invoking this skill on a cadence and
  reporting `[ATTENTION]` items. Unverified in general: whether the scheduled agent has your
  repo plus the local cache/sibling checkouts available (checks 5–6 would skip).
- Host `cron` running your sweep commands and mailing/logging non-zero exits.

If you prove one, record the working invocation here.

---

## Common mistakes | Fix

| Mistake | Fix |
|---|---|
| "Sweep passed, so all claims are current" | Automated checks cover strings and status codes; beta-surface and URL *content* re-verification are manual (Steps 3–4) |
| Editing dated specs/plans during a model bump | Never — they are history; edit only the DO-edit list in Step 2 |
| Fixing drift directly on the live branch because "it's just a string" | Published-content changes go through your change process and release gate |
| Bumping the repo but not the sibling site | Same-pass manual mirror; assume no automation links the repos |
| Deleting "orphan" files from the plugin cache | Cache-only files may be the sole survivor of a gitignore swallow — investigate first |
| Writing `[^ ...\]]` bracket patterns in `grep -E` | In ERE, `\` is not special inside brackets; `\]` closes the class early and the pattern silently matches nothing |
| Claiming the sweep "runs itself" | It doesn't — scheduling is a labeled CANDIDATE above |

---

## Known limitations (keep your honesty consistent)

- The greps in this skill are **templates, not a shipped script** — adapt file globs, model
  strings, and directory names to your repo before trusting a green result.
- Exit-clean means "no automated drift found", never "all published claims are true".
- Checks 5–6 only run on a maintainer machine with the cache and sibling checkouts present;
  on any other machine they are skipped, not passed.
- Cadence guidance (monthly, 90-day hard limit for beta re-verification) is a maintainer
  heuristic, not a measured optimum.
- No telemetry: this skill cannot tell you whether installed users were actually affected by
  drift — only that drift exists.

---

## Provenance and maintenance

This plugin is the genericized public version of an internal maintainer skill developed for a
live 12-plugin Claude Code marketplace; the check classes, the bump procedure, the
cache-as-sole-survivor incident, and the ERE bracket gotcha all come from real maintenance of
that repo. Repo-specific numbers (occurrence counts, commit hashes, dates) were removed —
regenerate your own with the Step 1 commands and re-stamp them each sweep.

Volatile facts to re-stamp when they change in **your** repo: repo HEAD, cache install date,
URL check date, beta verification date, model-ID occurrence counts.

## References

- `https://platform.claude.com/docs/en/docs/about-claude/models/overview` — canonical model
  names/IDs; verify against this page in-session before any bump
- Your own change-process and release-gate docs — this skill hands every fix to them
