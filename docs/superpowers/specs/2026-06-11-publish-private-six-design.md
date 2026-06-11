# Publish the private six — 12/12 installable in founder-skills

**Date:** 2026-06-11 · **Status:** approved by operator

## Goal

Near-copy the six private skills (fable-orchestrated-feature-dev, fable-repo-audit,
fable-org-audit, fable-loop-design, tufte-viz, ecosystem-planning) into the public
founder-skills repo as installable plugins, making 12/12 installable — one clear pattern for
complete Fable 5 orchestration and organizational/operational usage. Update both sites + README.

## Decisions (operator-selected)

1. All 12 live in founder-skills (one marketplace). Private claude-skills repo keeps originals.
2. fable-org-audit publishes as a platform-agnostic pattern (8-dimension live-probe audit,
   placeholder endpoints) + sanitized PlatAtlas worked example. Client org names removed
   unconditionally.

## Sanitization requirements (hard gate)

- Zero occurrences in new public files of: real client org names (Reservoir, reservoirfarms),
  secrets/token prefixes (sk_live, sk_test, cfut_, bearer values), personal home-dir paths
  (`/home/craigm26`), and personal-machine infra layout (systemd unit paths, /etc/ configs,
  venv locations) except where they document a public project's own install docs.
- fable-loop-design: no "Anthropic's internal research" claims — cite observable Fable 5
  behavior and public docs.
- Codex `/goal` → external-executor framing (Codex may remain as a named example).
- Real-project example filenames (parcelriskreport) → generic examples.

## Structure

- `plugins/<name>/SKILL.md` + `.claude-plugin/plugin.json` + `README.md` (family walkthrough
  template: what it does / what it asks / what it produces / cost / 60-second first run /
  built-on table with verified doc links) for each of the six.
- tufte-viz keeps `references/` + `demos/` (4 self-contained HTML, public scientific data).
- ecosystem-planning keeps `references/plan-template.md` + scrubbed worked example.
- fable-org-audit gains `references/worked-example-platatlas.md` (sanitized).
- marketplace.json: 6 new entries; categories conveyed via descriptions (schema has a single
  `category` field — use "productivity" like existing entries; grouping lives in README/site).

## Local single-copy

`~/.claude/skills/{fable-orchestrated-feature-dev,fable-repo-audit,fable-loop-design,tufte-viz,ecosystem-planning}`
become symlinks into `~/founder-skills/plugins/`. `fable-org-audit` stays a real private dir
(intentionally divergent: real orgs + endpoints).

## Sites + README flip to 12/12

- Catalog site: hero "6 installable today…" → all-12 copy; stats 12/12 installable/3 surfaces;
  category headers + card tags drop "private — not yet published" (tag becomes `installable`);
  scenario badges drop "· private"; install section lists all 12 (or the install-all loop);
  Desktop/API private qualifiers removed; org-audit card text matches the generic-pattern
  framing; source section meta 12 Installable / MIT / 3 Surfaces.
- founder-skills site: twelve cards in four groups (session / orchestration / chain / craft);
  install block lists all 12; "Part of a larger catalog" reworded (catalog = browsing view);
  why/concepts unchanged.
- README: 12 skills table in 4 groups; install-all loop updated.

## Verification gate

- Sanitization scan (the hard-gate list above) over all new/changed files → zero hits.
- pytest green (market-validation, build-options); all plugin.json + marketplace.json parse;
  every plugin `source` dir exists.
- "private — not yet published" zero hits on both pages; both pages well-formed; URLs curl 2xx.
- Push both repos; live-fetch both sites; confirm 12-installable copy live.

## Out of scope

- Updating the private claude-skills repo.
- Changing the six public chain/session plugins.
