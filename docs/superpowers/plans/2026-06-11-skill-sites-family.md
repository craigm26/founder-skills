# Skill-Sites Family Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update both Pages sites into one cross-linked family: claude-skills-site = honest 12-skill catalog (6 installable / 6 private, no dead download), founder-skills site = installable package reskinned onto the shared dark editorial aesthetic.

**Architecture:** Two repos, each a single hand-rolled HTML file. claude-skills-site (`~/claude-skills-site/index.html`, 1302 lines) gets content surgery preserving its design system. founder-skills (`~/founder-skills/docs/index.html`) gets a reskin preserving its content. Scripted verification before each push.

**Tech Stack:** Plain HTML/CSS/JS, python3 for checks, gh CLI.

**Shared constants:**
- Sites: `https://craigm26.github.io/claude-skills-site/` (catalog) ↔ `https://craigm26.github.io/founder-skills/` (package)
- Installable six: session-start, effort, market-validation, build-options, prd, tasks. Private six: fable-orchestrated-feature-dev, fable-repo-audit, fable-org-audit, fable-loop-design, tufte-viz, ecosystem-planning.
- Counts: **12 cataloged / 6 installable / 6 private**. No other numbers anywhere.
- Forbidden strings on both pages after the work: `releases/latest`, `zip`, `Codex`, `workflow-atlas`, `href="#"`.
- Family footer (both): built by craigmerry.com · MIT · "not affiliated with Anthropic — see the official documentation" (link code.claude.com/docs/en/overview) · cross-link to the sibling site.
- Verified doc URLs: the table in `2026-06-11-public-judgment-layer.md` (same plan dir).

---

### Task 1: claude-skills-site — nav, hero, stats

**Files:** Modify `~/claude-skills-site/index.html:732-774`

- [ ] Nav logo `href="#"` → `href="#top"`; add `id="top"` to `<body>` or hero section. Nav "Download" link → "Source" (`#source`).
- [ ] Hero body: "10 Claude skills for Fable 5 orchestration…" → "12 Claude skills for Fable 5 orchestration, founder workflows, and craft — 6 installable today via the founder-skills plugin marketplace, 6 private in active development."
- [ ] Hero primary CTA: replace the releases/latest download anchor with `<a class="btn-primary" href="https://craigm26.github.io/founder-skills/">Install the public six →</a>`; keep ghost "Browse skills →".
- [ ] Stats: `12 Skills · 6 Installable today · 3 Surfaces` (replaces 12/3/4).
- [ ] Commit: `fix: honest hero — counts, marketplace CTA, no dead download`.

### Task 2: claude-skills-site — why-this-exists section + doc links

**Files:** Modify `~/claude-skills-site/index.html` (insert after hero, before #skills; add nav link "Why")

- [ ] New section `id="why"` using existing section classes (`section-header`/`section-tag` "00"): two short paragraphs — token efficiency (30-second calibration governs millions of downstream tokens; wrong-direction work and wrong-model routing are the expensive failure modes) and Fable 5 as a leap in intuition (a model that can judge when to plan / what to route / how much effort deserves an explicit, inspectable calibration layer). Close with one line linking the primitives to official docs: Skills, Subagents, Agent SDK, Interactive mode, Models overview (verified URLs).
- [ ] Commit: `feat: why-this-exists section with official doc links`.

### Task 3: claude-skills-site — card surgery (status labels + genericization)

**Files:** Modify `~/claude-skills-site/index.html:783-965`

- [ ] Category headers: A `2 skills · installable today · MIT` · B `4 skills · private — not yet published` · C `4 skills · installable today · MIT` · D `2 skills · private — not yet published`.
- [ ] Tag every installable card `installable` (replacing bare `MIT` where present keeps MIT too) and every private card with tag `private`.
- [ ] effort card: "Sets Opus 4.8 / Sonnet 4.6 / Codex routing" → "Sets Opus 4.8 / Sonnet 4.6 routing — with an external-executor fallback when tokens run low."
- [ ] fable-orchestrated-feature-dev card: "Codex /goal fallback when tokens are exhausted" → "Hands the plan file to an external executor when tokens are exhausted."
- [ ] fable-org-audit card: rewrite as the portable pattern — "Live integration audit for a platform org: probes the platform's real APIs across 8 dimensions, grades each 🟢 🟡 🔴 ⚫, produces a prioritized gap list. Built against a specific stack (PlatAtlas); the audit pattern is portable." Tag `platatlas` → `live apis` stays, add `portable pattern`.
- [ ] ecosystem-planning card: "Worked example from robot-md/gateway bringup included" → "Built from a real multi-repo robotics bring-up; the planning pattern is portable."
- [ ] Verify the market-validation card mentions no workflow-atlas (skim showed it clean — confirm).
- [ ] Commit: `fix: honest card labels; genericize executor + stack-specific descriptions`.

### Task 4: claude-skills-site — install section rewrite

**Files:** Modify `~/claude-skills-site/index.html:980-1123`

- [ ] CLI panel step 1 terminal → marketplace add: `# In any Claude Code session` / `/plugin marketplace add craigm26/founder-skills`. Step 2 → install: `/plugin install session-start@founder-skills` (+ effort, market-validation, build-options, prd, tasks). Step 3 → invoke: `/session-start`, `/effort`, `/market-validation` + comment `# The six fable-*/craft skills are private — not yet published.`
- [ ] CLI prose: rewrite around plugins (skills ship as Claude Code plugins; SKILL.md read on invocation; "all 10" → "the six public skills"; keep the founder-chain sequencing tip; add link to the founder-skills site for per-skill walkthroughs).
- [ ] Desktop panel: step 1 terminal → fetch a public SKILL.md from GitHub raw (`curl -s https://raw.githubusercontent.com/craigm26/founder-skills/master/plugins/session-start/SKILL.md`); prose keeps the paste-into-instructions guidance for session-start/effort; the fable-*/tufte-viz recommendations get "(private — not yet published)" qualifiers.
- [ ] API panel: code sample reads the same raw GitHub URL into `system` (fetch instead of `readFileSync` of zip path is fine; keep Node example minimal); prose: drop "Opus vs Sonnet vs Codex" → "Opus vs Sonnet vs an external executor"; founder-chain helper-script callout stays (true of the public repo).
- [ ] Commit: `fix: install section — marketplace-first, no zip paths`.

### Task 5: claude-skills-site — scenarios + source section + footer

**Files:** Modify `~/claude-skills-site/index.html:1126-1278`

- [ ] Last scenario card ("Tokens are running low"): "...routes implementation to Sonnet 4.6 when you're cost-conscious, or hands the plan file to an external executor when tokens are exhausted."
- [ ] Scenario cards for private skills: append ` · private` to the skill badge text where the skill is private (feature-dev, repo-audit, loop-design ×2, tufte-viz, ecosystem-planning).
- [ ] `#download` section → `id="source"`: title "Get the skills." stays; sub-copy → "The public six install in one command via the Claude Code plugin marketplace. The private six are in active development."; primary button → founder-skills site link "Install via marketplace →"; download-meta → `6 Installable · 6 Private · MIT Public six`.
- [ ] source-links: keep all four; add a fifth at the top → `craigm26.github.io/founder-skills` "Sibling site · install walkthrough + per-skill docs".
- [ ] Footer → family footer: left `// claude-skills · built by <a href=https://craigmerry.com>Craig Merry</a> · MIT`; right `sibling: <a href=…founder-skills/>founder-skills</a> · not affiliated with <a href=docs overview>Anthropic</a>`.
- [ ] Commit: `fix: scenarios + source section honest; family footer`.

### Task 6: claude-skills-site — verify + push + live

- [ ] Scripted checks: (a) html.parser well-formedness; (b) forbidden strings `releases/latest|zip|Codex|workflow-atlas|href="#"` → zero hits (case-sensitive Codex; allow "zip" only if truly gone — target zero); (c) card count: `grep -c 'class="skill-card'` == 12, `grep -c '>installable<'` == 6, `grep -c '>private<'` == 6 (adjust selectors to the markup used); (d) every `https://` href curl 2xx.
- [ ] `git push origin master` (confirm Pages source first: `gh api repos/craigm26/claude-skills-site/pages --jq .source`).
- [ ] Poll live URL until the new hero text ("6 installable today") appears.

### Task 7: founder-skills site — reskin + catalog cross-link

**Files:** Modify `~/founder-skills/docs/index.html`

- [ ] Replace the `<style>` block with the shared dark editorial system: tokens from the spec (bg #080c10, surface #0f1419, border #1e2a38, text #c8d0db, muted #4d6070, ember #ff6b2b, green #39d353, blue #58a6ff, gold #e3b341); Google Fonts link for Cormorant Garamond + IBM Plex Mono; display headings in Cormorant (h1 italic accent allowed), chips/kickers/code in Plex Mono; cards/tables/ask-mocks restyled onto surface+border; ember for accents/links-hover, blue for links.
- [ ] Keep ALL existing sections and copy. Markup changes only where the reskin needs hooks (e.g. hero eyebrow `// claude skills · craigm26 · 2026` to match the family header).
- [ ] New section before Links: `id="catalog"` — "Part of a larger catalog" — one paragraph: this package is the installable half of a 12-skill judgment layer; the Fable 5 orchestration skills (feature-dev, repo-audit, loop-design, org-audit) and craft skills live in the catalog → link `https://craigm26.github.io/claude-skills-site/`.
- [ ] Footer → family footer (mirror of Task 5's, pointing back at claude-skills-site).
- [ ] Commit: `feat: reskin onto shared editorial system; catalog cross-link; family footer`.

### Task 8: founder-skills — verify + push + final cross-check

- [ ] Same scripted checks as Task 6 (well-formedness, forbidden strings, URL curl) on `docs/index.html`.
- [ ] Push; poll the live founder-skills URL for the new `#080c10` token or "Part of a larger catalog".
- [ ] Final family check: fetch BOTH live pages; assert founder-skills page contains `claude-skills-site` link and claude-skills-site page contains `founder-skills` link. Report both URLs.
