---
name: fs-site-and-positioning
description: >-
  Edit the founder-skills public surfaces — the Pages site (docs/index.html), the per-plugin
  READMEs, and the sibling catalog site — without breaking the single-file dark-editorial design
  system, the fixed README template, benefit-led copy rules, the mandatory attribution footer, or
  the no-oversell doctrine; includes the currently-open oversell defects and the
  measured-not-claimed standard for what may be claimed externally. Use when a maintainer says
  "update the site", "change docs/index.html", "add a card for the new skill", "edit a plugin
  README", "fix the token-cost chips", "the site oversells", "update the catalog site",
  "change the footer", or "what are we allowed to claim publicly".
---

# fs-site-and-positioning — the public surfaces and what they may claim

You are editing marketing surfaces for a repo whose core doctrine is **no oversell**. Every word
you change here is live within a minute of a push (the site deploys straight from `master:/docs`,
no CI, no staging). This skill gives you the design system, the copy rules, the fixed templates,
the verification gate, and the list of oversell defects that are already open so you do not add
to them.

**Announce at start:** "Loading fs-site-and-positioning — public-surface edits are doctrine-bound
and live-publishing; routing changes through fs-change-control."

## The three public surfaces (as of 2026-07-02)

| Surface | File(s) | Deploys how | Owner of truth |
|---|---|---|---|
| Pages site | `docs/index.html` (328 lines, ONE file) | GitHub Pages from `master:/docs`, auto on push | this repo |
| Plugin READMEs | `plugins/<name>/README.md` × 15 (12 committed + 3 uncommitted skill-* meta-plugins added 2026-07-02; only the 12 are carded on the site) | rendered on GitHub; linked from every site card | this repo |
| Sibling catalog site | `index.html` in the SEPARATE repo `craigm26/claude-skills-site` → craigm26.github.io/claude-skills-site | its own Pages deploy | that repo — coordinate manually |

There is no build step, no bundler, no external JS. The only external dependency on the site is
the Google Fonts stylesheet. Keep it that way: "single hand-rolled file" is a design decision,
not an accident.

## The design system (dark editorial — verbatim from docs/index.html:11–26)

Defined once as CSS custom properties in `:root`. Never hardcode a hex that has a token.

| Token | Value | Used for |
|---|---|---|
| `--bg` | `#080c10` | page background |
| `--surface` | `#0f1419` | cards, `pre`, ask-mocks |
| `--border` | `#1e2a38` | all borders, section rules |
| `--text` | `#c8d0db` | body text |
| `--muted` | `#4d6070` | secondary text, comments |
| `--dim` | `#2a3848` | ask-option borders |
| `--ember` | `#ff6b2b` | THE accent: tags, h1 em, arrows, hover |
| `--ember-dim` | `#7a3010` | catalog-box border |
| `--green` | `#39d353` | (reserved; defined, currently unused) |
| `--blue` | `#58a6ff` | links |
| `--gold` | `#e3b341` | token-cost chips (`.cost`), ask chips |
| `--bright` | `#e8edf2` | headings, emphasized strong |

Type: **Cormorant Garamond** (`--serif`) for display headings h1/h2, **IBM Plex Mono** (`--mono`)
for everything else — body, chips, kickers, code. Note the file's `:root` has two tokens
(`--dim`, `--bright`) that the 2026-06-11 spec palette omits; the file is ground truth.

### Page structure (do not reorder; section tags are numbered)

Hero (kicker `// claude skills · craigm26 · 2026 · founder-skills`) → `00 · Why this exists` →
`01 · Before you begin` (three concepts + primitives table) → `02 · Install` →
`03 · Session zero` (AskUserQuestion mock, `.ask`/`.opt`/`.chip`) → `04 · The chain` (`.chain`
pills) → `05 · The twelve skills` (four `<h3>` groups: Session layer / Fable 5 orchestration /
Workflow chain / Craft) → `06 · The pattern` → `07 · The bigger picture` (`.catalog-box`) →
`08 · Links` → footer. Every `<section>` opens with `<span class="tag">NN · Title</span>`.
Adding a section means renumbering nothing before it and everything after it.

### Card anatomy (exact — 12 instances, count is load-bearing)

```html
<div class="card"><h3>skill-name</h3><span class="cost">COST CHIP</span>
  <p><strong>Benefit sentence, second person, bold.</strong> One or two supporting
  sentences of mechanism.</p>
  <a href="https://github.com/craigm26/founder-skills/tree/master/plugins/skill-name">Walkthrough →</a></div>
```

Rules: the `<strong>` opener states the user's benefit ("You stop losing the first hour…"), not
the feature. The `.cost` chip is a token-cost claim and is subject to measured-not-claimed (below).
The card count must equal the number the copy claims ("twelve", `05 · The twelve skills`, hero,
meta description) — the gate script checks `grep -c '<div class="card">'` == 12. Add a 13th
skill and you must update every count in the same change.

## The fixed README template (all 15 plugin READMEs conform — verified 2026-07-02)

Section order is fixed. Optional insert sections go between "What it will ask you" and "Cost".

| Section | Required | Content |
|---|---|---|
| `# name — hook question/line` + intro para | yes | what it turns input into |
| `## Before you install` | yes | honest expectations: spend, discipline, prerequisites |
| `## What it will ask you` | yes | the literal AskUserQuestion content |
| *(optional insert)* | no | e.g. `## Make it recurring` (fable-org-audit), `## Hosted executor option` (feature-dev), `## Outcome rubric export` (tasks), `## Related API primitives` (effort), `## Security-adjacent code` (repo-audit) |
| `## What it produces` | yes | artifact list, file names, relative `references/` links |
| `## Cost` | yes | token/time estimate with honest framing |
| `## 60-second first run` | yes | fenced invocation + what happens next |
| `## Built on` | yes | table: Anthropic primitive / Role here / Docs (official URL) |

Voice: benefit-led but concrete; costs stated plainly ("~1.5M tokens, ~38 agents, ~50 minutes"
in market-validation is the house exemplar — it is a *measured reference run*, which is why it
may be stated). For SKILL.md body style (not READMEs), load **fs-skill-style-guide** instead.

## Copy doctrine: what may be claimed externally

Full doctrine with rationale lives in **fs-doctrine-and-honesty** — that is the home of these
rules; this section is the site-editor's operational summary.

1. **Source-traceability**: every capability claim traces to an official Anthropic URL verified
   *that session* (curl 2xx + content check). No secondhand numbers. Unverifiable percentages get
   dropped, not hedged. "Anthropic internal research" claims are banned.
2. **Measured-not-claimed** (operator priority 2026-07-02, program home: **fs-research-frontier**):
   a token-cost chip or `## Cost` number may be published only if it traces to a measurement
   artifact from a real run. market-validation's ~1.5M figure qualifies (reference run).
   A chip with no run behind it is oversell — see the open defects below.
3. **Sanitization hard gate**: no client names, no `sk_live`/`cfut_` prefixes, no `/home/craigm26`
   paths, no infra layout, Codex named only as "such as Codex" (on the sites: not at all — the
   forbidden-string sweep bans the bare word).
4. **Capability honesty**: a skill that *documents* an option must not be described as *doing* it.
   ("Documents two scheduling triggers" ≠ "runs itself weekly".)
5. **Mandatory attribution footer** (both sites, non-negotiable, exact substance):
   built by [Craig Merry](https://craigmerry.com) · MIT · link to source · sibling cross-link ·
   "not affiliated with Anthropic — see the official documentation" (linked).

## OPEN oversell defects (ledger #6 — verified still present 2026-07-02)

These violate rule 2 and rule 4 above. They are **documented, operator-gated follow-ons**: do NOT
hot-fix them ad hoc. Fixing the site is a change to a public surface and needs a spec + plan via
**fs-change-control** (house precedent: the 2026-06-11 site change shipped through
`docs/superpowers/specs/2026-06-11-skill-sites-family-design.md`).

| # | Where | Current text | Why it's oversell | Candidate correction (UNPROVEN — operator picks) |
|---|---|---|---|---|
| 6a | `docs/index.html:227` (session-start card) | chip `~0 tokens` | READMEs say "a few hundred tokens"; the site contradicts the repo's own doctrine and no run measured ~0 | chip `a few hundred tokens`, or a measured figure once one exists |
| 6b | `docs/index.html:230` (effort card) | chip `~0 tokens` | same | same |
| 6c | `docs/index.html:243` (fable-org-audit card) | "runs itself weekly via /schedule or CMA scheduled deployments" | the skill only *documents* those scheduling options; nothing runs itself | "documents two triggers for a weekly cadence (/schedule routines, CMA scheduled deployments)" — matches the README's own honest phrasing |

The gate script (below) prints `OPEN: oversell strings still present` while these stand, and
flips to `ok:` when the correction ships — at which point update this table and the ledger entry
in **fs-failure-archaeology**.

## Making a site or README change, end to end

1. **Classify it.** Copy tweak, new card, new section, sibling-site count change — anything on a
   public surface is at minimum spec-worthy per house change-control. Load **fs-change-control**
   and follow spec → checkbox plan → commits-match-plan-verbatim. Do not route around it.
2. **Edit within the system.** Reuse existing classes (`.card`, `.ask`, `.chain`, `.tag`,
   `.catalog-box`); pull colors from tokens; keep the file self-contained; keep section numbering
   contiguous.
3. **Check claim parity.** Anything a card claims must match the plugin's README and SKILL.md.
   The README is more honest than the site today (defect #6) — converge toward the README, never
   away from it.
4. **Check count parity.** "twelve" appears in the hero, meta description, section 05 tag,
   section 07, and the install loop (12 plugin names). The sibling site carries the same counts
   ("12 installable today via the founder-skills plugin marketplace" — live-verified in sync
   2026-07-02). A count change is always a TWO-REPO change; the sibling repo is not in this repo,
   so its half is a coordinated manual edit there.
   **WARNING — the trap is already armed (2026-07-02):** the uncommitted working tree registers
   15 plugins in marketplace.json (whose own description now says "15 skills") while the site,
   README, and sibling site still say "twelve"/12. The moment that manifest is pushed, every
   "twelve" count is false. Committing the handoff therefore makes the 15-vs-twelve decision
   mandatory before/with the push: either add cards for the 3 skill-* plugins and bump every
   count in BOTH repos, or explicitly document them as registered-but-uncarded meta-plugins —
   via a spec either way.
5. **Run the gate** (read-only, from repo root; script ships with this skill and passed clean
   on 2026-07-02):
   ```bash
   bash .claude/skills/fs-site-and-positioning/scripts/site-checks.sh
   ```
   It checks: forbidden strings (`releases/latest|zip|Codex|workflow-atlas|href="#"`), the
   oversell watch, card count == 12, HTML well-formedness (stdlib `html.parser`, no pip deps),
   footer integrity, every external URL 2xx (skipping the bare `fonts.googleapis.com` preconnect
   origin, which 404s as a document — known false positive), and live-vs-repo byte diff.
6. **Ship via the full pre-push gate** — the site checks are one slice of it; load
   **fs-release-and-publish** for the whole thing (test suites, JSON parse, sanitization grep).
   Remember: push = deployed. The live page was byte-identical to `docs/index.html` on 2026-07-02;
   after your push, re-run the gate until the live-diff check goes `ok` again.
7. **After pushing**, live-fetch both Pages URLs and confirm each still cross-links the other
   (spec requirement): `curl -s https://craigm26.github.io/founder-skills/ | grep -c claude-skills-site`
   and the mirror-image grep on the sibling.

## When NOT to use this skill

| Your job | Load instead |
|---|---|
| Writing/editing a SKILL.md body (house prose style, frontmatter, closers) | **fs-skill-style-guide** |
| The honesty/sanitization doctrine itself, with rationale | **fs-doctrine-and-honesty** |
| Spec/plan/commit pipeline mechanics for ANY change | **fs-change-control** |
| Actually pushing to the live master (full pre-push gate) | **fs-release-and-publish** |
| Adding a brand-new plugin (add-skill.sh, marketplace.json) | **fs-skill-authoring** / **fs-plugin-anatomy** |
| Re-checking staleness of doc URLs / model IDs across the repo | **fs-freshness-watch** |
| Building the measurement artifacts that would justify real cost chips | **fs-research-frontier** |
| First orientation to the repo | **fs-orientation** |

## Known limitations (keep your honesty consistent)

- The v0.2.0 URL fact-check was done 2026-06-11; my URL sweep re-verified all site URLs 2xx on
  2026-07-02, but *content*-level claims (what each doc page says) were not re-read — that
  recurring job belongs to **fs-freshness-watch**.
- The sibling site's internals (its card markup, its own checks) live in another repo; this skill
  only verifies it from the outside (live fetch). UNVERIFIED: whether that repo has its own copy
  of the scripted checks from the 2026-06-11 plan.
- Whether GitHub Pages is configured as "deploy from branch: master /docs" vs an Actions-based
  deploy is inferred from the facts pack + observed instant deploys; repo has no workflow files,
  consistent with branch-deploy. UNVERIFIED beyond that (needs repo Settings access).

## References

- `docs/index.html` — the site, single source of design truth
- `docs/superpowers/specs/2026-06-11-skill-sites-family-design.md` — design system + two-site roles + verification gate (operator-approved)
- `docs/superpowers/plans/2026-06-11-skill-sites-family.md` — the executed checkbox plan (card surgery, forbidden strings)
- `plugins/market-validation/README.md` — README-template exemplar with a *measured* cost claim
- `scripts/site-checks.sh` (in this skill dir) — the runnable gate

## Provenance and maintenance

All facts verified against the repo and live sites on **2026-07-02** (HEAD 2e4c9dd). Re-verify with:

```bash
# Everything at once (forbidden strings, oversell watch, counts, well-formedness, footer, URLs, live diff):
bash .claude/skills/fs-site-and-positioning/scripts/site-checks.sh
# Defect #6 still open? (hits at 227/230/243 as of 2026-07-02):
grep -nE '~0 tokens|runs itself weekly' docs/index.html
# README template still uniform across all 15 plugins:
for f in plugins/*/README.md; do echo "== $f"; grep -n '^## ' "$f"; done
# Design tokens unchanged (12 custom properties in :root):
sed -n '11,26p' docs/index.html
# Sibling site still in count-sync (expect "12 installable today"):
curl -s https://craigm26.github.io/claude-skills-site/ | grep -oE '12 installable[^<]*'
# Live page still byte-identical to repo:
curl -s https://craigm26.github.io/founder-skills/ | diff - docs/index.html && echo IN-SYNC
# Last commit that touched the site (history context):
git log --oneline -- docs/index.html
```
