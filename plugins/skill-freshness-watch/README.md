# skill-freshness-watch — the drift sweep for your skill marketplace

A recurring re-verification sweep for anyone who **publishes** Claude Code skills: it hunts the
ways a live marketplace goes stale — hardcoded model IDs after a new model ships, beta API
claims that quietly graduated or renamed, dead cited URLs, an installed plugin cache that has
desynced from the repo, and sibling/upstream repos that were supposed to stay in step.

## Before you install

This skill assumes you **maintain** a repo that publishes skills or plugins (a marketplace, a
`plugins/` directory, or a `.claude/skills/` collection) — it is a maintainer tool, not an
end-user one. The sweep is read-only: it reports drift and hands every fix to your own change
process; it never edits published files itself. The check commands are templates — expect to
adapt file globs and model strings to your repo on first run.

## What it will ask you

One batched `AskUserQuestion` (skipped if the answers are already obvious):

1. **Where do published skills live** — `plugins/*/SKILL.md` (recommended default) /
   `.claude/skills/` / other
2. **Which environment-specific checks apply on this machine** (multi-select) — installed
   plugin cache / sibling marketing-site repo / an upstream or downstream repo / none

## What it produces

- A per-check report: `OK` (with evidence) or `[ATTENTION]` (with file:line) across six check
  classes — model-ID inventory, manifest parse + version table, beta-surface citations,
  cited-URL liveness, installed-cache diff, sibling-repo divergence
- A **multi-file model-bump procedure** when a new model generation ships (which files to
  edit, which dated documents to never touch, version bumps, sibling-site mirroring)
- Re-stamped verification dates for beta claims and URL checks, so the next sweep knows how
  stale you are

## Cost

Cheap — a handful of greps and JSON parses, plus one curl per cited URL if you run the
liveness pass. No subagent fan-out. The expensive part is the *fixes* it hands you, and those
go through your normal process.

## 60-second first run

```
/skill-freshness-watch  — "run the freshness sweep"
```

Answer the two setup questions, then read the report. Anything `[ATTENTION]` comes with the
triage step to run next. On a machine without your installed cache or sibling checkouts,
those checks are marked skipped — never silently passed.

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| `AskUserQuestion` | One batched setup question | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| Bash (grep / curl / git) | The six read-only drift checks | — |
| Models overview page | The canonical source every model bump is verified against, in-session | [Models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) |
