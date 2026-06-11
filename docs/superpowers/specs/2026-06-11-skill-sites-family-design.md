# Skill-sites family — extensive update of both GitHub Pages sites

**Date:** 2026-06-11 · **Status:** approved by operator
**Repos:** `craigm26/founder-skills` (site at /docs) + `craigm26/claude-skills-site` (site at root index.html)

## Goal

Make the two public skill sites one coherent family with two roles:
- **founder-skills site** — the installable public package (marketplace install, docs-anchored walkthrough).
- **claude-skills-site** — the full catalog/portfolio of all 12 skills, honestly labeling which are
  installable today (6 public via marketplace) vs private (6, not yet published).

## Decisions (operator-selected)

1. Two roles, cross-linked — no merge.
2. Dead "Download zip" CTA (private repo, no releases → 404) replaced by marketplace install as the
   primary CTA; private skills cataloged with "private — not yet published" labels. No zip anywhere.
3. Visual unification on claude-skills-site's editorial aesthetic (shared design system).
4. Stack-specific skills (fable-org-audit, ecosystem-planning) keep honest labels: described by their
   portable pattern + one-line "built against a specific stack; the pattern is portable" note.

## Shared design system

- Palette: bg `#080c10`, surface `#0f1419`, border `#1e2a38`, text `#c8d0db`, muted `#4d6070`,
  ember `#ff6b2b` (accent), ember-dim `#7a3010`, green `#39d353`, blue `#58a6ff`, gold `#e3b341`.
- Type: Cormorant Garamond (display), IBM Plex Mono (labels/chips/code), via Google Fonts.
- Shared header kicker (`// claude skills · craigm26 · 2026`) and shared footer: built by
  [craigmerry.com] · MIT · "not affiliated with Anthropic — defer to the official documentation"
  (linked) · cross-link to the sibling site.

## claude-skills-site changes (content surgery on index.html)

- **CTAs:** primary = `/plugin marketplace add craigm26/founder-skills` + link to the founder-skills
  site; secondary = "browse the catalog" (#skills). Remove both `releases/latest` links, the zip
  install steps, and the dead `href="#"`.
- **Counts:** single source of truth = the cards. 12 cataloged / 6 installable today / 6 private.
  Hero, stats row, and install copy all derive from these numbers.
- **Per-card status labels:** `MIT · installable` (session-start, effort, market-validation,
  build-options, prd, tasks) vs `private — not yet published` (fable-orchestrated-feature-dev,
  fable-repo-audit, fable-org-audit, fable-loop-design, tufte-viz, ecosystem-planning).
- **Genericization to the founder-skills standard:** Codex `/goal` → external executor; effort card
  drops Codex; market-validation card says "market-map graph" not workflow-atlas; fable-org-audit
  described as a live org-integration audit pattern + portable-pattern note; ecosystem-planning
  described generically + portable-pattern note.
- **Install section rewrite:** Claude Code tab = marketplace install for the public six + note that
  the fable-* orchestration skills are not yet published; Desktop/API tabs reference the public
  plugin READMEs on GitHub instead of zip contents.
- **New sections:** "Why this exists" (token efficiency + Fable 5 intuition — same substance as the
  founder-skills page) and official Anthropic doc links woven into the concept/primitives copy
  (verified URLs: code.claude.com/docs/en/{overview,skills,slash-commands,plugins,
  plugin-marketplaces,memory,sub-agents,interactive-mode,agent-sdk/overview} and
  platform.claude.com models-overview + tool-use).
- **Scenarios section:** audit for stale zip/Codex/PlatAtlas references; fix to the same standard.
- **Footer:** shared family footer (attribution, MIT, non-affiliation, cross-link).

## founder-skills site changes (reskin + cross-link)

- Reskin `docs/index.html` onto the shared design system (dark editorial). Content/structure
  preserved: hero → why → three concepts (doc-linked table) → install → session zero mock →
  chain → six cards → AskUserQuestion pattern → links → footer.
- New section: "Part of a larger catalog" → claude-skills-site (the Fable orchestration layer).
- Footer updated to the shared family footer.

## Verification gate (per repo, before push)

- Page count claims == rendered card count (scripted check on claude-skills-site).
- Zero occurrences of: `releases/latest`, `zip`, `Codex`, `workflow-atlas` on either page;
  `href="#"` dead anchors gone.
- HTML well-formedness (html.parser stack check) on both files.
- Every external URL curl-checked 2xx (follow redirects).
- After push: live-fetch both Pages URLs; verify each contains its cross-link to the other.

## Out of scope

- Publishing the private claude-skills repo or cutting releases.
- Changing skill content in either skills repo (sites only).
