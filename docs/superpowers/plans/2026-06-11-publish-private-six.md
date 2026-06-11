# Publish the Private Six Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Near-copy the six private skills into founder-skills as sanitized public plugins (12/12 installable), update marketplace + README + both sites, and re-point local skill dirs to symlinks.

**Architecture:** Copy from `~/.claude/skills/<name>/` into `~/founder-skills/plugins/<name>/`, apply per-skill sanitization (verified by a scripted scan), add plugin.json + walkthrough README each, register in marketplace.json. Sites flip from 6-installable to 12-installable. Private originals stay untouched except the 5 non-divergent local dirs become symlinks.

**Tech Stack:** Markdown/JSON/HTML, python3 checks, gh CLI.

**Sanitization gate (scripted, run over `plugins/` before push) — zero hits for:**
`Reservoir|reservoirfarms|sk_live|sk_test|cfut_|/home/craigm26|castor-dash|/opt/robot-md|/etc/robot-md` and (in the six new plugins only) `Codex|/goal ` as a required executor (allowed only as a named example phrase "such as Codex").

### Task 1: Copy + sanitize the six skills

- [ ] **fable-orchestrated-feature-dev**: copy SKILL.md. Edits: title "Run Skill Generator — " → "Fable Orchestrated Feature Dev"; flow-diagram + Step 3b + Step 2 table + Model Reference row: Codex `/goal` → "external executor (hand the plan file to a cheaper Claude session, Haiku 4.5, or a third-party plan-runner such as Codex)"; Common-Mistakes rows mentioning Codex updated the same way.
- [ ] **fable-repo-audit**: copy SKILL.md. Edits: example output filenames `workflow-atlas-2026-06-11.md`/`parcelriskreport-2026-05-31.md` → `my-api-2026-06-11.md`/`my-webapp-2026-05-31.md`.
- [ ] **fable-org-audit**: REWRITE SKILL.md as platform-agnostic (frontmatter description: "live integration audit of a customer organization on your platform — probes real API signals across eight dimensions, not code quality"): keep When-to-Use (drop "like Reservoir"), the eight-dimension table reworded generically (ingest / actor graph / work program / geo-field / hypotheses / billing / metrics / edge devices), the grading rubric, Step 1 agent prompt reduced to the generic probe loop with "map each dimension to your platform's endpoints — see references/worked-example-platatlas.md", Step 2, memory pattern, output location (generic org slugs), quick reference, common mistakes (drop `requireEntitledMember` name → "most endpoints need an authenticated operator session"). Create `references/worked-example-platatlas.md` = the original 8 dimension probe blocks nearly verbatim with: Reservoir/reservoirfarms → fictional `acme-fields`, "pre-deal orgs like Reservoir" dropped, robot-md-gateway → "the robot gateway (robot-md)".
- [ ] **fable-loop-design**: copy SKILL.md. Edits: "This is the core Anthropic insight for getting the most out of Mythos-class models." → "This is the pattern that gets the most out of Mythos-class models."; memory-progression table: drop the unverifiable % figures ("~17% coverage"/"up to 73%") → qualitative ("sometimes"/"consistently"); primitives table: `/goal` row → `/loop` in Claude Code, keep Workflow row, "Outcomes in Claude Managed Agents" row kept; "Opus 4.7" comparisons kept (qualitative).
- [ ] **tufte-viz**: copy SKILL.md + references/ + demos/ verbatim (scan returned clean).
- [ ] **ecosystem-planning**: copy SKILL.md + references/plan-template.md. SKILL.md edits: "Call `advisor`" → "Run an independent reviewer agent (a fresh context window acting as plan advisor)". Worked example: copy with personal-machine scrub — `~/castor-dash/...` → "the project scratch dir", `/opt/robot-md-gateway/.venv` + `/etc/robot-md-gateway/` → "the gateway's deployed venv / system config dir", home-dir repo paths `~/robot-md/` style → repo names without `~/`; keep the disagreement table, advisor catches, and plan shape (the value).
- [ ] Each plugin gets `.claude-plugin/plugin.json` (same shape as existing six; version 0.1.0; keywords per skill) and a family-standard `README.md` (what it does / before you install / what it asks / what it produces / cost / 60-second first run / built-on table with verified doc links).
- [ ] Commit per skill or one commit: `feat: publish the six orchestration/craft skills as public plugins`.

### Task 2: Registry + repo README

- [ ] marketplace.json: 6 new entries (category "productivity", source ./plugins/<name>, homepage repo URL) with descriptions matching the catalog-site cards (post-sanitization wording).
- [ ] README.md: "six skills" framing → twelve in four groups (Session layer / Fable 5 orchestration / Workflow chain / Craft); install-all loop lists 12; skills table gains 6 rows; "Related skills (private repo)" section REPLACED by a short "Origins" note (skills graduated from a private incubation repo; personal variants may diverge).
- [ ] Commit: `docs: README + marketplace — 12/12 installable`.

### Task 3: Local symlink swap (single-copy discipline)

- [ ] For fable-orchestrated-feature-dev, fable-repo-audit, fable-loop-design, tufte-viz, ecosystem-planning: `mv ~/.claude/skills/<n> ~/.claude/skills/<n>.private-backup-2026-06-11 && ln -s ~/founder-skills/plugins/<n> ~/.claude/skills/<n>`. NOT fable-org-audit (divergent personal version stays).
- [ ] Verify: `ls -la ~/.claude/skills/ | grep '\->'` shows the 5 new links resolving.

### Task 4: Sites flip to 12/12

- [ ] **catalog site** (`~/claude-skills-site/index.html`): hero body → "12 Claude skills … — all 12 installable today via the founder-skills plugin marketplace."; stats → 12 Skills / 12 Installable today / 3 Surfaces; category headers B and D drop "private — not yet published" → "installable today · MIT"; the 6 `>private</span>` tags → `installable`; org-audit + ecosystem-planning card texts already portable-pattern (keep); install panel: drop the "private —" comment lines → full 12-skill comment or install-all loop; Desktop prose "(private — not yet published)" qualifiers removed; API prose "it is private today; the same routing tiers…" → "the same routing tiers are documented in the public effort skill"; scenarios: remove all "· private" badge suffixes; source section sub-copy + meta → 12 Installable / MIT / 3 Surfaces; footer "MIT (public six)" → "MIT".
- [ ] **founder-skills site** (`docs/index.html`): install block → marketplace add + install-all loop for 12 (or grouped); six cards → twelve in four labeled groups (reuse card grid with group sub-headers); "Part of a larger catalog" section reworded: catalog = the browsing/portfolio view of the same 12; counts in hero/meta updated.
- [ ] Commits in each repo.

### Task 5: Verify + push + live + memory

- [ ] Sanitization scan (gate above) over `~/founder-skills/plugins/` → zero hits; secret-pattern scan over all new files.
- [ ] pytest green ×2; all JSON parses; every plugin source dir exists; "private — not yet published" zero hits on both pages; both pages well-formed; URL curl pass on changed files.
- [ ] Push founder-skills (master) and claude-skills-site (main); poll both live; confirm "12" copy live and cross-links intact.
- [ ] Update memory file `project_skill_sites_family_2026_06_11.md` (12/12 done; loose end resolved).
