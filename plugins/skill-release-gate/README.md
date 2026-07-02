# skill-release-gate — the moment-of-push gate for a live marketplace

A release runbook for Claude Code skill-marketplace maintainers whose default branch **is** the
release: a local pre-push gate (test suites, manifest JSON parse, sanitization grep,
gitignore-swallow check, optional live-URL sweep), version-bump discipline, installed-cache desync
handling, and catalog-site coordination.

## Before you install

This skill is for the maintainer of a plugin marketplace repo, not for plugin users. It earns its
keep when installers read your plugins straight from your default branch and you have no staging
tier — every gate in it exists because skipping it once shipped a real defect somewhere (an
ignored core asset that passed manifest validation, docs whose test commands failed verbatim on a
fresh machine, a mutable install cache masking a broken repo). If you have blocking CI and a
staging branch, parts still apply (sanitization, versioning, cache desync) but the urgency is
lower.

The gate commands are generic on purpose; the skill tells you where to substitute your repo's own
suites and patterns, and recommends committing the adapted sequence as a single script.

## What it will ask you

Nothing scripted — but on first use it will have you pin down your repo's gate inventory before
running anything: which test suites exist and their exact documented commands, your sanitization
pattern list, whether a marketplace/plugin version field is duplicated anywhere, and which catalog
pages describe the repo. Subsequent runs just execute the gate.

## What it produces

- A pass/fail verdict per gate, and a single **safe-to-push / do-not-push** summary
- A version-bump decision (which plugins changed, what to bump, in the same commit)
- A post-push checklist: site redeploy confirmation, own-cache refresh, catalog follow-ons

## Cost

Low — a few turns of conversation plus whatever your test suites cost in wall time. The optional
live-URL sweep adds one curl per unique URL in `plugins/`.

## 60-second first run

```
/skill-release-gate — "I'm about to push a new plugin, run the gate"
```

Answer the gate-inventory questions once, watch the gates run in order, and only push on the
all-green summary. Then refresh your own installed cache so you're testing what users now get.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Plugins | The unit being released | [Plugins](https://code.claude.com/docs/en/plugins) |
| Plugin marketplaces | The live-publishing surface this skill gates | [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) |
| `AskUserQuestion` | First-run gate-inventory questions | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
