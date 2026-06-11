# founder-skills v2 — generic judgment layer + public site

**Date:** 2026-06-11
**Repo:** `craigm26/founder-skills` (public, master is live)
**Status:** approved by operator (with attribution + "why" additions)

## Goal

Turn founder-skills from a personal skill chain into a generic, accurate, well-documented
starting package for any builder/developer/researcher using Claude Code with Fable 5 —
with a GitHub Pages site that flows like the setup itself.

## Motivation (ships as site + README content)

1. **Token efficiency.** A 30-second calibration at session start (effort tier, domain,
   done-looks-like) prevents hours of wrong-direction work and wrong-model routing.
   The judgment layer spends a few hundred tokens to govern millions.
2. **Fable 5 is a leap in intuition.** A model that can genuinely judge *when* to plan,
   *what* to route where, and *how much* effort a task deserves makes a calibration layer
   worth building. These skills give that intuition a structured place to act — explicit,
   inspectable, and reusable — instead of leaving it implicit in each session.

## Workstreams

### 1. Genericize skill content

- **market-validation** — atlas emission becomes a vendor-neutral "market map" artifact:
  - `assets/platatlas/` → `assets/market-map/`; `emit_atlas.py` → `emit_market_map.py`;
    `brief.template.md` language de-branded.
  - `references/workflow-atlas-schema.md` → `references/market-map-schema.md`, vendor-neutral.
  - New `references/sinks.md`: how to wire the market-map JSON into any destination;
    PlatAtlas documented as one worked example among others (dashboard, Notion, plain git).
  - `tests/test_emit_atlas.py` renamed/updated; suite stays green.
  - SKILL.md + plugin.json descriptions updated to "market map", no PlatAtlas in the main flow.
- **session-start** — memory path uses a `<project>` placeholder; Constrained tier reframed
  as "hand the plan file to any external executor (cheaper Claude session, Haiku 4.5, or
  third-party tools)". No hard Codex dependency.
- **effort** — same executor reframe; "Sprint end" = plans only, execution to user's executor.
- **Full sweep** of all six plugins + marketplace.json + README for personal assumptions.
  Private-repo cross-references stay but labeled clearly as optional extensions.

### 2. Per-skill walkthroughs

Each of the six plugins gets a human-facing `README.md` (GitHub renders it in the folder):
what the skill asks, what it produces, approximate token/time cost, a 60-second first-run
example, and which Anthropic primitives it builds on (with verified doc links).
`SKILL.md` stays lean — it is model context, not human documentation.

### 3. Anthropic docs accuracy pass

- Live-verify every official-docs URL before use. Canonical homes as of 2026:
  `code.claude.com/docs` (Claude Code), `platform.claude.com/docs` (API).
- Fix dead `docs.anthropic.com` links across README and all SKILL.md files.
- Every primitive in the judgment-layer table gets a working link explaining its merits.

### 4. GitHub Pages site

- `docs/index.html` — single page, hand-rolled, no build step. Served from `master:/docs`.
- Page flow mirrors the setup journey:
  hero ("a judgment layer for Claude Code") → **why this exists** (token efficiency +
  Fable 5 intuition) → **before you begin** (3 concepts with official-doc links) →
  **install** (copy-paste blocks) → **session zero** walkthrough (mock of the
  AskUserQuestion flow) → **the chain** (validate→options→prd→tasks) → per-skill cards
  linking to plugin READMEs → AskUserQuestion pattern reference → links/FAQ →
  **footer attribution: built by [Craig Merry](https://craigmerry.com)** (ownership of
  page and skills; also linked in repo README).
- Enable Pages via `gh api` (source: master, /docs). Verify the live URL responds with
  the page content before claiming done.

### 5. Verification gate (before each push)

- `pytest` green in `plugins/market-validation` and `plugins/build-options`.
- `marketplace.json` parses; every plugin `source` path exists; plugin.json files parse.
- Every external URL in README, SKILL.mds, plugin READMEs, and index.html curl-checked (2xx/3xx-to-2xx).
- After enabling Pages: fetch `https://craigm26.github.io/founder-skills/` live.

## Out of scope

- New slash-command machinery beyond session-start/effort (the judgment layer ships
  through docs + genericization this session).
- Changes to the private `craigm26/claude-skills` repo.
- The `~/.claude/skills/` symlinked copies update automatically via the symlinks for
  market-validation/build-options/prd/tasks; no separate sync step.

## Risks

- Repo is live: every push publishes. Mitigation: verification gate before each push;
  the rename of `emit_atlas.py` could break external users mid-flight — acceptable, the
  marketplace install pulls fresh and nothing external imports the module by path.
- Pages first-deploy latency: verify with retry, not a single fetch.
