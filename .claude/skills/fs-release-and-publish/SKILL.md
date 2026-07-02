---
name: fs-release-and-publish
description: >-
  Ship founder-skills safely on a live-publishing master with no CI: run the
  executable pre-push gate (both pytest suites, node glob test, JSON parse,
  sanitization grep, optional URL sweep), bump plugin versions, handle
  installed-cache desync, and coordinate the sibling catalog site. Use when a
  founder-skills maintainer says "I'm about to push founder-skills", "release
  this founder-skills change", "publish the new plugin in this repo", "run the
  founder-skills pre-push gate", "bump this plugin's version", "why don't
  installed users see my change", or "update the site cards". If you are NOT
  working inside founder-skills, load the public skill-release-gate plugin
  instead — it is the generic version of this gate.
---

# fs-release-and-publish

Announce at start: "Using fs-release-and-publish — running the local pre-push gate before anything touches master."

## Why this skill exists

This repo has **no CI** (standing org-wide rule since 2026-06-19: GitHub Actions billing-blocked plus operator preference — never author Actions workflows) and a **live-publishing master**: every push to `master` is instantly installable via the plugin marketplace and redeploys the GitHub Pages site from `master:/docs` (live at https://craigm26.github.io/founder-skills/, verified 200 on 2026-07-02). There is no staging. The mandatory LOCAL pre-push gate below is operator-approved standing policy (2026-07-02) and is the only thing standing between a mistake and the public.

Terms used once, defined once:

| Term | Meaning |
|---|---|
| plugin | A directory under `plugins/<name>/` with `SKILL.md` + `.claude-plugin/plugin.json` (see fs-plugin-anatomy) |
| marketplace | `.claude-plugin/marketplace.json` at repo root; lists every plugin (15 as of 2026-07-02: 12 committed + 3 uncommitted skill-*); installers read it from `master` |
| installed cache | Per-machine copy at `~/.claude/plugins/cache/founder-skills/<plugin>/<version>/` created when a user installs (environment-specific path; this is the actual mechanism, not a convenience) |
| sanitization gate | Zero-hit grep over `plugins/` for private names/keys/paths — doctrine hard gate for anything public (see fs-doctrine-and-honesty) |
| sibling site | `github.com/craigm26/claude-skills-site` — the separate catalog/portfolio repo (branch `main`, publishes https://craigm26.github.io/claude-skills-site/, verified 200 on 2026-07-02); must be coordinated manually |

## The pre-push gate (executable)

The gate is a real script in this skill, not a checklist:

```bash
# from repo root — gates 1–5 (~5 s after first run; first run creates a venv)
.claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh

# add gate 6 (live-URL sweep, needs network) when you changed public claims or links
.claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh --urls
```

Exit 0 = safe to push. Nonzero = **do not push**; the summary lists what failed.

| # | Gate | What it runs | Why |
|---|---|---|---|
| 0 | venv bootstrap | Creates `$FS_VENV` (default `~/venvs/founder-skills`) + installs pytest if missing | Host Python 3.13.5 is PEP-668 externally managed; bare `python3 -m pytest` fails (defect ledger #2) |
| 1 | pytest market-validation | `<venv>/python -m pytest -q tests/` in `plugins/market-validation` | 6 tests |
| 2 | pytest build-options | same, in `plugins/build-options` | 9 tests (2 of these failed on every fresh clone for ~4 weeks while master was live, 2026-06-04 → 2026-07-02 — defect #1) |
| 3 | node JS suite | `node --test 'tests/js/*.test.mjs'` in `plugins/market-validation` | 5 tests. GLOB form only — the directory form `node --test tests/js/` fails with MODULE_NOT_FOUND on Node v24 (defect #3) |
| 4 | JSON + source dirs | `json.load` on marketplace.json + every plugin.json (15 as of 2026-07-02); every marketplace `source` dir exists | A malformed manifest breaks every installer at once |
| 5 | sanitization grep | Zero hits, case-insensitive, over the public dirs (`plugins/ docs/ README.md .claude-plugin/`, excluding `docs/superpowers`) for `reservoir\|sk_live\|sk_test\|cfut_\|/home/craigm26\|castor-dash\|/opt/robot-md\|/etc/robot-md` — the doctrine scope (fs-doctrine-and-honesty Rule 3), which extends the plugins/-only pattern in `docs/superpowers/plans/2026-06-11-publish-private-six.md` repo-wide | Doctrine hard gate; the repo is public and docs/index.html + marketplace.json ship too |
| 6 | URL sweep (`--urls` only) | curl every unique `https?://` URL in `plugins/` (placeholder hosts example.com/localhost/`x` excluded as fixtures); 2xx/3xx pass, 401/403/405/429 WARN (bot-blocking — verify manually), else FAIL | No-oversell doctrine: claims trace to live URLs. Last full-repo URL verification before this script was 2026-06-11 (3 weeks stale) |

### Real recorded output (run 2026-07-02, HEAD 2e4c9dd + the uncommitted working tree: template rescue + 3 skill-* plugins + their marketplace registration)

```text
== founder-skills pre-push gate ==
repo: /home/craigm26/projects/craigm26/founder-skills
-- gate: pytest market-validation
6 passed in 0.23s
  PASS  pytest plugins/market-validation
-- gate: pytest build-options
9 passed in 0.11s
  PASS  pytest plugins/build-options
-- gate: node --test (market-validation js suite)
ℹ tests 5 / pass 5 / fail 0
  PASS  node --test plugins/market-validation/tests/js
-- gate: JSON parse + marketplace source dirs
  checked 16 JSON files + 15 marketplace source dirs
  PASS  JSON parse + source dirs
-- gate: sanitization grep over public dirs (plugins/ docs/ README.md .claude-plugin/)
  PASS  sanitization grep (zero hits)
-- gate: curl URL sweep over plugins/ (network required)
  PASS  URL sweep (22 unique URLs)
== summary ==
ALL GATES PASSED — safe to push.
```

Notes: gate 2 passes only because the `matrix.template.html` rescue is in the working tree (uncommitted as of 2026-07-02) — on a fresh clone of 2e4c9dd it fails 2/9, which is exactly the point of running the gate. On a clean checkout of 2e4c9dd (before the 3 skill-* plugins) gate 4 reports 13 JSON files + 12 source dirs and the URL sweep 20 URLs.

## Release runbook (in order)

1. **Change control first.** The work must already have a spec + checkbox plan per fs-change-control. This skill does not authorize skipping that; it gates the push at the end.
2. **Gitignore-swallow check** (defect #1 class: a plugin `.gitignore` line `*.html` silently dropped a core asset; only the mutable installed cache kept a copy):
   ```bash
   git status --short            # every file you created MUST appear
   git check-ignore -v plugins/<name>/assets/* 2>/dev/null   # any output = swallowed; add a !negation
   ```
3. **Run the gate** (`--urls` if you touched public claims, READMEs, or links).
4. **Manifest validation** — necessary but NOT sufficient:
   ```bash
   claude plugin validate .      # verified working 2026-07-02: "Validation passed"
   ```
   This checks manifest schema only. It passed while build-options was shipping without its core asset. Never treat it as the gate.
5. **Version bump** if any plugin's content changed (next section).
6. **Operator commits and pushes.** Standing rule (2026-07-02): assistants run no mutating git commands in this repo; the operator reviews and pushes. Commit messages match the plan text verbatim (fs-change-control).
7. **Post-push:** confirm the Pages deploy (`curl -sI https://craigm26.github.io/founder-skills/ | head -1`), refresh your own installed cache (`/plugin marketplace update founder-skills` inside Claude Code), and run the site follow-on below if plugin count or capabilities changed.

## Version-bump procedure

Versions live in exactly one place per plugin: `plugins/<name>/.claude-plugin/plugin.json` → `"version"`. The marketplace.json entries carry **no** version field (verified 2026-07-02), so no second file to sync inside this repo.

- Precedent (commit 93d91a2, 2026-06-11): the 0.1.0 → 0.2.0 bumps were made in the SAME commit as the SKILL.md capability changes they described. Follow that: content change and bump travel together.
- As of 2026-07-02 versions are mixed: effort, fable-loop-design, fable-orchestrated-feature-dev, fable-org-audit, fable-repo-audit, tasks are 0.2.0; the other nine (including the 3 uncommitted skill-* plugins) are 0.1.0. There is no repo-wide version.
- **Always bump when content changes.** The installed cache is keyed by version directory (`~/.claude/plugins/cache/founder-skills/<plugin>/<version>/`, layout verified 2026-07-02). Whether a marketplace update refreshes a cache entry whose version did NOT change is UNVERIFIED — bumping sidesteps the question.

## Installed-cache desync (know this before you push)

- Installs are snapshots. The operator's own cache equals HEAD 2e4c9dd, installed 2026-06-24. Every push **silently desyncs every installed user** until they run `/plugin marketplace update founder-skills` — there is no push notification and no telemetry (defect #8 established that: the emit_atlas→emit_market_map rename had no way to know who broke).
- The cache is mutable at runtime: a Claude session regenerated the missing build-options template inside the cache on 2026-06-24, which masked the breakage for its final 8 days (2026-06-24 → the 2026-07-02 rescue; the repo had shipped broken since 2026-06-04). Never use the cache as evidence that the repo is complete; test from `git ls-files` / a fresh clone. Full story: fs-failure-archaeology.
- After any push, refresh your local cache immediately so you are testing what users get, not what you remember.

## Sibling-site coordination + site-card follow-on for new plugins

Two sites describe this repo and only one of them lives in it:

| Site | Source | Deploys | Coordination |
|---|---|---|---|
| founder-skills site | this repo, `docs/index.html` | automatically on push to master | edits ride the same pre-push gate |
| catalog site | separate repo `claude-skills-site` (env-specific checkout: `/home/craigm26/projects/craigm26/claude-skills-site`, branch `main`, clean at 01aa2b6 on 2026-07-02) | on push to its `main` | fully manual — nothing reminds you |

When a **new plugin** ships, the follow-on protocol is:

1. Write a site-edit spec first — site changes are change-controlled like everything else (fs-change-control); wording and positioning rules live in fs-site-and-positioning.
2. `docs/index.html`: add a `<div class="card"><h3>name</h3><span class="cost">…</span>…</div>` inside the correct group's `.cards` grid; update every hard-coded plugin count (hero, meta description, section 05, install loop — grep for the number before assuming you found them all). The marketplace.json description was bumped to "15 skills" with the 2026-07-02 skill-* registration; the site and README still say "twelve" — that count decision (add cards + bump, or document the 3 as uncarded) is a mandatory spec'd follow-on of the same commit (see fs-site-and-positioning step 4).
3. Catalog site: add the matching card, update its count stats ("12 installable today" as of 2026-07-02) and install-all loop.
4. **Do not propagate the existing oversell** (defect #6: "~0 tokens" chips and "runs itself weekly" are live drift violating the repo's own no-oversell doctrine). New cards use honest cost copy; fixing the old cards is a documented follow-on, not a side effect of your push.
5. Push order: this repo first (plugin must be installable before either site claims it), then the catalog site.

## When NOT to use this skill

- **Creating or scaffolding a new plugin** (add-skill.sh flags, plugin.json generation, symlink discipline) → load **fs-skill-authoring**. This skill only gates the moment it goes public.
- **Classifying a change, writing the spec/plan** → **fs-change-control**. Nothing here routes around it.
- **Rebuilding the environment, extending the test suites, debugging a red suite** → **fs-toolchain-and-tests**. This skill only runs the suites.
- **Actually writing/redesigning site copy or positioning** → **fs-site-and-positioning**. This skill only tells you WHEN both sites must move.
- **What a plugin directory must contain** → **fs-plugin-anatomy**.
- **Understanding why these gates exist (past failures)** → **fs-failure-archaeology**.

## Common mistakes | Fix

| Mistake | Fix |
|---|---|
| "`claude plugin validate` passed, ship it" | Schema-only. Run `pre-push-gate.sh`; validate is step 4 of 7, not the gate |
| `python3 -m pytest` on the host | PEP-668 failure. The gate bootstraps `~/venvs/founder-skills`; use it |
| `node --test tests/js/` | MODULE_NOT_FOUND. Quoted glob only: `node --test 'tests/js/*.test.mjs'` |
| Trusting `git status` clean = repo complete | `.gitignore` can swallow new assets silently; run the `git check-ignore` check on every new asset |
| Pushing content changes without a version bump | Installed caches are version-keyed; bump in the same commit as the change |
| Editing docs/index.html cards and calling it done | The catalog site is a separate repo and will now be wrong; run the follow-on protocol |
| Assistant running `git push` | Forbidden standing rule; operator pushes |
| Skipping `--urls` after editing READMEs/claims | URL verification is 3+ weeks stale (2026-06-11); the sweep is cheap (22 URLs, ~30 s) |

## Provenance and maintenance

All facts verified 2026-07-02 against `/home/craigm26/projects/craigm26/founder-skills` at HEAD 2e4c9dd (+ uncommitted template rescue). Re-verify before trusting:

- Gate still green: `.claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh --urls`
- Test counts (6/9/5): the gate's own output prints them
- Plugin versions: `for f in plugins/*/.claude-plugin/plugin.json; do python3 -c "import json;d=json.load(open('$f'));print(d['name'],d['version'])"; done`
- Marketplace has no version fields: `grep -c '"version"' .claude-plugin/marketplace.json` (expect 0)
- Sanitization pattern origin (the gate extends it to the doctrine scope): `grep -n 'sk_live' docs/superpowers/plans/2026-06-11-publish-private-six.md`
- Cache layout: `ls ~/.claude/plugins/cache/founder-skills/*/` (env-specific)
- Both sites live: `curl -s -o /dev/null -w '%{http_code}\n' https://craigm26.github.io/founder-skills/ https://craigm26.github.io/claude-skills-site/` (expect 200 200)
- Sibling checkout state: `git -C /home/craigm26/projects/craigm26/claude-skills-site status --short` (env-specific)
- UNVERIFIED (open): whether `/plugin marketplace update` refreshes a same-version cache entry; whether any external installer exists to be desynced (no telemetry)

## References

- `scripts/pre-push-gate.sh` — the executable gate (this skill directory)
- `docs/superpowers/plans/2026-06-11-publish-private-six.md` — origin of the sanitization gate pattern (plugins/-only there; the gate script applies the wider doctrine scope)
- `scripts/add-skill.sh` (repo root) — scaffolding, covered by fs-skill-authoring
