---
name: skill-release-gate
description: >-
  Ship a Claude Code skill marketplace safely when your default branch is
  live-publishing: run a local pre-push gate (test suites, manifest JSON parse,
  sanitization grep, gitignore-swallow check, optional live-URL sweep), bump
  plugin versions with content, and handle installed-cache desync and catalog
  site coordination. Use when a marketplace maintainer says "I'm about to push
  my marketplace", "gate my marketplace release", "release this plugin to my
  marketplace", "publish the new skill", "bump a plugin version", "why don't my
  marketplace's installed users see the change", or "is this safe to ship".
---

# skill-release-gate

Announce at start: "Using skill-release-gate — running the local pre-push gate before anything reaches your live marketplace branch."

## Why this skill exists

A Claude Code plugin marketplace is **live-publishing by default**: installers read your marketplace manifest and plugin files straight from the head of your default branch. The moment you push, that IS the release — there is no staging tier unless you built one. If your repo also has no CI (or CI you can't trust to block a push), the local gate below is the only thing standing between a mistake and every installer.

This skill is the moment-of-push gate. It assumes the work itself is already done and reviewed; it checks that what you are about to publish is complete, green, and sanitized.

Terms used once, defined once:

| Term | Meaning |
|---|---|
| plugin | A directory under `plugins/<name>/` with `SKILL.md` + `.claude-plugin/plugin.json` |
| marketplace manifest | `.claude-plugin/marketplace.json` at repo root; lists every plugin; installers read it from your default branch |
| installed cache | Per-machine snapshot at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`, created at install time |
| sanitization gate | Zero-hit grep over `plugins/` for anything private — client names, key prefixes, absolute home-directory paths, internal hostnames |
| catalog site | Any page (in this repo or a sibling repo) that describes your plugins and must be updated by hand |

## The pre-push gate

Run every gate from the repo root, in order. Any failure = **do not push**. The commands below are generic — adapt paths, suite locations, and patterns to your repo, and consider committing the adapted sequence as a single script so it can't be run partially.

| # | Gate | Generic command | Why |
|---|---|---|---|
| 1 | Every test suite, exactly as your docs state it | e.g. `python -m pytest -q plugins/<name>/tests/` and/or `node --test 'plugins/<name>/tests/*.test.mjs'` | If a documented command fails verbatim on a fresh machine (missing venv, wrong glob form), fix the docs or the environment now — users will hit the same wall |
| 2 | Manifest JSON parse + source dirs | `python3 -c "import json,glob; [json.load(open(f)) for f in ['.claude-plugin/marketplace.json']+glob.glob('plugins/*/.claude-plugin/plugin.json')]"` then check every marketplace `source` directory exists | A malformed manifest breaks every installer at once |
| 3 | Sanitization grep | `grep -rn -e 'ClientName' -e 'internal.example.com' -e 'yourkeyprefix_' -e "$HOME" plugins/` — expect **zero hits**; maintain the pattern list in one committed place | The repo is public; a leaked client name or key prefix cannot be un-pushed |
| 4 | Gitignore-swallow check | `git status --short` (every file you created MUST appear) and `git check-ignore -v plugins/<name>/assets/* 2>/dev/null` (any output = a `.gitignore` line is silently dropping an asset; add a `!` negation) | A broad ignore line like `*.html` can swallow a core asset while everything looks green locally |
| 5 | Live-URL sweep (when you changed public claims or links) | curl every unique `https?://` URL under `plugins/`; 2xx/3xx pass; 401/403/405/429 = warn and verify manually (bot-blocking); anything else fails | Claims should trace to live sources; link rot accumulates silently between releases |

Also run your platform's manifest validator (`claude plugin validate .`) — but treat it as **necessary, not sufficient**. It checks manifest schema only; it will happily pass a plugin whose core asset never got committed. It is one step of the gate, never the gate.

## Release runbook (in order)

1. **Change control first.** Whatever review/spec process your repo uses, this skill does not authorize skipping it — it only gates the final push.
2. **Run gates 1–4** (add gate 5 if you touched READMEs, claims, or links).
3. **Run the manifest validator** as a supplementary check.
4. **Version bump** if any plugin's content changed (next section) — in the same commit as the change.
5. **Push** (or hand off to whoever in your team is authorized to push).
6. **Post-push:** confirm any auto-deployed site actually redeployed (`curl -sI <your-site> | head -1`), then refresh your own installed cache (`/plugin marketplace update <marketplace>` inside Claude Code) so you are testing what users now get.
7. **Catalog follow-on** if the plugin count or a plugin's capabilities changed (see below).

## Version-bump procedure

- Versions should live in exactly one place per plugin: `plugins/<name>/.claude-plugin/plugin.json` → `"version"`. Check whether your marketplace manifest duplicates version fields — if it does, they must move together; if it doesn't, there is no second file to sync.
- **Content change and bump travel in the same commit.** A content change without a bump is the classic silent-desync source.
- The installed cache is keyed by version directory. Bumping guarantees installers get a fresh directory; relying on a same-version cache refresh is betting on behavior you probably haven't verified.

## Installed-cache desync (know this before you push)

- **Installs are snapshots.** Every push silently desyncs every installed user until they run `/plugin marketplace update <marketplace>`. There is no push notification, and unless you built telemetry, you have no way to know who is stale or who a breaking rename affected.
- **The cache is mutable at runtime.** A Claude session can regenerate a missing asset inside a user's cache, which then masks a broken repo — the install "works" while a fresh clone fails. Never use an installed cache as evidence the repo is complete; test from `git ls-files` or a fresh clone.
- After any push, refresh your own cache immediately, so your daily driver matches what new installers receive.

## Catalog-site coordination

If more than one page describes your marketplace (a docs page in this repo, a portfolio site in a sibling repo), only the in-repo one moves automatically with your push. For every new or changed plugin:

1. Update the in-repo page in the same push (it rides the same gate).
2. Update any sibling-repo page manually — nothing will remind you.
3. Update every hard-coded plugin **count** — grep for the number rather than assuming you found all occurrences (hero copy, manifest description, install loops).
4. Write honest cost/behavior copy on new cards; do not copy-paste an existing card's claims without re-verifying them.
5. Push order: marketplace repo first (the plugin must be installable before any site claims it), sites second.

## When NOT to use this skill

- **Creating or scaffolding a new plugin** — that is authoring work; this skill only gates the moment it goes public.
- **Writing the spec or deciding whether a change is safe** — use your repo's change-control process; nothing here routes around it.
- **Debugging a red test suite** — fix it with your normal toolchain first; the gate only runs suites, it doesn't repair them.
- **Repos with a real staging tier and blocking CI** — most of this still applies (sanitization, versioning, cache desync), but the "local gate is the only gate" urgency does not.

## Common mistakes | Fix

| Mistake | Fix |
|---|---|
| "The manifest validator passed, ship it" | Schema-only. Run the full gate; the validator is one step, not the gate |
| Running a *variant* of the documented test command | Run the docs' command verbatim; if it fails on your machine, the docs are the bug |
| Trusting `git status` clean = repo complete | `.gitignore` can swallow new assets silently; `git check-ignore -v` every new asset |
| Pushing content changes without a version bump | Installed caches are version-keyed; bump in the same commit |
| Testing against your installed cache | Caches are mutable snapshots; test from a fresh clone or `git ls-files` |
| Updating the in-repo site card and calling it done | Sibling catalog pages are manual; run the follow-on protocol |
| Skipping the URL sweep after editing claims | Link rot and stale claims accumulate; the sweep is cheap |
| Pushing before change-control review | This skill gates the push; it never replaces review |

## Known limitations (keep your honesty consistent)

- The gate list here is generic; **your repo's actual gate is whatever you commit as a script**. Until you write that script, this is a checklist, and checklists get skipped under deadline pressure.
- The sanitization grep only catches patterns you thought to list. It cannot catch a secret in a format you didn't anticipate — pair it with a proper secret scanner if the stakes warrant it.
- The URL sweep proves a URL is alive, not that the claim citing it is still accurate.
- Whether a marketplace update refreshes a cache entry whose version did **not** change is behavior you should verify on your own platform version before relying on it — this skill assumes you bump instead.
- Nothing here detects external installers you don't know about; without telemetry, desync impact is unknowable, not zero.

## Provenance and maintenance

Distilled from a maintainer runbook for a public 12-plugin Claude Code marketplace with a live-publishing default branch and no CI, where each gate exists because its absence shipped a real defect (an ignored core asset that passed manifest validation while the plugin shipped broken for roughly four weeks; test commands that failed verbatim on a fresh host; a runtime-mutated cache masking a broken repo). Repo-specific commands were replaced with generic equivalents — adapt them to your repo and keep the adapted script under version control.

Re-verify before trusting: run your adapted gate end-to-end on a fresh clone at least once, and re-check the docs links in the README against their live pages (last verified 2026-07-02).

## References

- Claude Code plugins — https://code.claude.com/docs/en/plugins
- Plugin marketplaces — https://code.claude.com/docs/en/plugin-marketplaces
