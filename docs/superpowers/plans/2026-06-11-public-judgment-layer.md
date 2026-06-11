# Public Judgment Layer v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Genericize founder-skills (de-PlatAtlas, de-Codex), add per-skill walkthrough READMEs with verified Anthropic doc links, and ship a single-page GitHub Pages site that flows like the setup itself.

**Architecture:** Content + rename work in a live public repo (`master` publishes). Generic "market map" replaces workflow-atlas branding; the JSON shape is unchanged. The site is one hand-rolled `docs/index.html`, Pages serves `master:/docs`. Verification = pytest suites + JSON parse checks + live curl of every external URL + live fetch of the Pages site.

**Tech Stack:** Python 3 (existing pytest suites), plain HTML/CSS, gh CLI for Pages enablement.

**Verified canonical doc URLs (use these everywhere; all curl-200 on 2026-06-11):**

| Topic | URL |
|---|---|
| Claude Code overview | https://code.claude.com/docs/en/overview |
| Skills | https://code.claude.com/docs/en/skills |
| Slash commands | https://code.claude.com/docs/en/slash-commands |
| Plugins | https://code.claude.com/docs/en/plugins |
| Plugin marketplaces | https://code.claude.com/docs/en/plugin-marketplaces |
| Memory | https://code.claude.com/docs/en/memory |
| Subagents | https://code.claude.com/docs/en/sub-agents |
| Interactive mode (AskUserQuestion lives here) | https://code.claude.com/docs/en/interactive-mode |
| Agent SDK | https://code.claude.com/docs/en/agent-sdk/overview |
| Models overview | https://platform.claude.com/docs/en/docs/about-claude/models/overview |
| Tool use | https://platform.claude.com/docs/en/docs/agents-and-tools/tool-use/overview |

Replace every `docs.anthropic.com/...` link in the repo with the matching row above.

---

### Task 1: Rename atlas → market map in market-validation (code + tests)

**Files:**
- Move: `plugins/market-validation/assets/platatlas/` → `plugins/market-validation/assets/market-map/`
- Move: `assets/platatlas/emit_atlas.py` → `assets/market-map/emit_market_map.py`
- Move: `tests/test_emit_atlas.py` → `tests/test_emit_market_map.py`
- Move: `references/workflow-atlas-schema.md` → `references/market-map-schema.md`

- [ ] **Step 1:** `git mv` the four paths above (`git mv assets/platatlas assets/market-map`, then `git mv` the two file renames inside the moved dir and tests/).
- [ ] **Step 2:** In `emit_market_map.py`: rewrite the module docstring to describe a vendor-neutral "market map graph (nodes.json + flows.json)"; point to `references/market-map-schema.md`; change the usage string to `emit_market_map.py <deck-data.json> <out-dir>`; drop the "workflow-atlas consumes" framing — note instead "the shape is compatible with graph viewers that accept families/nodes/flows JSON; see references/sinks.md". Keep ALL logic, mapping, and the referential-integrity assert identical. Soften the final print NOTE to: `print("NOTE: shape-valid market map; see references/sinks.md for loading it into a viewer")`.
- [ ] **Step 3:** In `tests/test_emit_market_map.py`: update `EMIT = ROOT / "assets/market-map/emit_market_map.py"`. No other changes.
- [ ] **Step 4:** Run `cd plugins/market-validation && python3 -m pytest -q tests/`. Expected: all pass (4 emit tests + deck tests).
- [ ] **Step 5:** Commit: `git commit -m "refactor: atlas emitter -> vendor-neutral market map emitter"`.

### Task 2: Rewrite the schema doc + add sinks.md

**Files:**
- Modify: `plugins/market-validation/references/market-map-schema.md`
- Create: `plugins/market-validation/references/sinks.md`

- [ ] **Step 1:** Rewrite `market-map-schema.md`: keep the two JSON shape blocks verbatim; reframe prose as "the market-map graph contract" (families = competitor tiers + process + policy; nodes; flows). Remove the `~/workflow-atlas` session-mapping paragraph, the D1/proxy-worker internals, and the "Project 2 / spec R3" sections — replace with one line: "Loading the map into a specific viewer is sink-specific; see sinks.md."
- [ ] **Step 2:** Create `sinks.md` covering: (a) what the artifact is (two JSON files, self-contained, referentially checked); (b) generic sinks — commit to the repo under `docs/market-map/`, render with any graph tool that maps families→groups/nodes→vertices/flow steps→edges, or convert to DOT/Mermaid with a ~15-line script (include the script); (c) **worked example: workflow-atlas/PlatAtlas** — files drop into `docs/workflows/`, shape matches its parser, end-to-end load is the consumer's to verify (preserve the honest "shape-valid, load-untested" caveat here).
- [ ] **Step 3:** Update `plugins/market-validation/SKILL.md`: replace the atlas-emit phase (lines ~76–88) to call `assets/market-map/emit_market_map.py`, output dir `<out-dir>/market-map`, reference `references/market-map-schema.md` + `sinks.md`; rename the "workflow-atlas market map" phrase in the description (line 6) to "market-map graph"; de-brand the brief step (the Project-2/POST atlases/import stub moves to sinks.md's PlatAtlas example or is dropped); fix the references list at the bottom.
- [ ] **Step 4:** De-brand `assets/market-map/brief.template.md` (read it first; replace PlatAtlas-specific copy with generic "your destination system" language).
- [ ] **Step 5:** Update `plugins/market-validation/.claude-plugin/plugin.json` and the marketplace entry in `.claude-plugin/marketplace.json`: "emitted workflow-atlas market map" → "emitted market-map graph".
- [ ] **Step 6:** `grep -ri "platatlas\|workflow-atlas" plugins/market-validation/` — only remaining hits must be inside `references/sinks.md` (the worked example). Run pytest again: green.
- [ ] **Step 7:** Commit: `git commit -m "docs: vendor-neutral market-map schema + pluggable sinks doc"`.

### Task 3: Generalize session-start + effort (executor + memory path)

**Files:**
- Modify: `plugins/session-start/SKILL.md`
- Modify: `plugins/effort/SKILL.md`
- Modify: `.claude-plugin/marketplace.json` (the two plugin descriptions)

- [ ] **Step 1:** session-start: replace every `Codex via /goal <plan-path>` phrasing with "an external executor — a cheaper Claude session, Haiku 4.5, or a third-party plan-runner". Constrained-tier option description becomes: "Sonnet 4.6 only. Hand heavy implementation off as a written plan file to an external executor when tokens run low." Routing table: `Sonnet 4.6 → external executor`. Step 4 memory path becomes: "read your Claude Code memory directory (`~/.claude/projects/<project>/memory/MEMORY.md`) if it exists — see https://code.claude.com/docs/en/memory". Update the footer doc links per the verified-URL table (Agent SDK, Tool use→interactive-mode for AskUserQuestion, Models overview, Memory).
- [ ] **Step 2:** effort: same executor reframe for "Constrained" and "Sprint end" options/announcements; model-reference table row `Codex /goal <path>` → `External executor (any plan-runner)` / "Executes a written plan file with minimal Claude token spend". Fix footer links.
- [ ] **Step 3:** marketplace.json: effort description drops "Codex routing tier" → "model routing tier (with an external-executor fallback)".
- [ ] **Step 4:** Commit: `git commit -m "refactor: generic external-executor framing; verified doc links in session-start/effort"`.

### Task 4: Personal-assumption sweep over all plugins + README

**Files:**
- Modify: any hits from the sweep; `README.md`

- [ ] **Step 1:** `grep -rin "craigm26\|craig\|castor\|parcelrisk\|rebateops\|opencastor\|robot-md\|/home/" plugins/ README.md` — fix every hit that isn't (a) the marketplace owner/author fields, (b) the install command `craigm26/founder-skills`, or (c) the labeled private-repo "Related skills" section.
- [ ] **Step 2:** README: update the primitive table links per the verified-URL table; fix the walkthrough section's Codex references the same way as Task 3; add a short **"Why this exists"** section after the intro: token efficiency (a 30-second calibration governs millions of downstream tokens) + Fable 5 as a leap in intuition (a model that can judge when to plan / what to route / how much effort a task deserves makes an explicit, inspectable calibration layer worth building). Add attribution line: "Built and maintained by [Craig Merry](https://craigmerry.com)."
- [ ] **Step 3:** Commit: `git commit -m "docs: genericize README, add why-this-exists + attribution, fix doc links"`.

### Task 5: Per-skill walkthrough READMEs (6 files)

**Files:**
- Create: `plugins/<name>/README.md` for session-start, effort, market-validation, build-options, prd, tasks.

- [ ] **Step 1:** Each README follows the same template (~60–90 lines): **What it does** (2 sentences) · **Before you install** (what to expect on first run) · **What it will ask you** (the actual AskUserQuestion questions, where applicable) · **What it produces** (artifacts with paths) · **Cost** (approx tokens/time — market-validation ~1.5M tokens/45+ min full run; build-options ~300–600k; prd/tasks/session-start/effort minimal) · **60-second first run** (copy-paste invocation + what happens) · **Built on** (table of Anthropic primitives used, each linked per the verified-URL table).
- [ ] **Step 2:** Accuracy rule: every claim in a README must be checkable against that plugin's SKILL.md — read each SKILL.md before writing its README (prd, tasks, build-options not yet read this session).
- [ ] **Step 3:** Commit: `git commit -m "docs: per-skill walkthrough READMEs"`.

### Task 6: The Pages site

**Files:**
- Create: `docs/index.html`

- [ ] **Step 1:** Single self-contained HTML file (inline CSS, no JS dependencies; system font stack; readable on mobile). Section order = the setup journey: (1) hero — "founder-skills: a judgment layer for Claude Code" + install one-liner; (2) **Why this exists** — token efficiency + Fable 5 intuition copy (same substance as README); (3) **Before you begin** — the three concepts (skills are the judgment layer / Fable plans, others implement / token budget shapes the session), each linking to the official docs per the verified-URL table; (4) **Install** — the `/plugin marketplace add craigm26/founder-skills` + per-skill `/plugin install` blocks; (5) **Session zero** — a rendered mock of the three session-start AskUserQuestion prompts (styled boxes, not screenshots) and what the announced routing looks like; (6) **The chain** — validate → options → prd → tasks → execute → review as a simple flow diagram (pure HTML/CSS); (7) **Skills** — six cards, each linking to `https://github.com/craigm26/founder-skills/tree/master/plugins/<name>` (the walkthrough READMEs); (8) **AskUserQuestion pattern** — the snippet from the README + interactive-mode doc link; (9) footer — "Built by <a href=https://craigmerry.com>Craig Merry</a> · MIT · GitHub repo link · not affiliated with Anthropic".
- [ ] **Step 2:** Sanity-check locally: `python3 -c` parse with `html.parser` for well-formedness; eyeball via `grep -o 'href="[^"]*"' docs/index.html` that every link is either a verified doc URL, the GitHub repo, or craigmerry.com.
- [ ] **Step 3:** Commit: `git commit -m "feat: GitHub Pages site — judgment layer walkthrough"`.

### Task 7: Verify, push, enable Pages, confirm live

- [ ] **Step 1:** Full verification gate: `python3 -m pytest -q` in market-validation and build-options; `python3 -m json.tool` on `.claude-plugin/marketplace.json` and every `plugins/*/.claude-plugin/plugin.json`; curl every external URL extracted from README, all SKILL.mds, all plugin READMEs, and index.html (expect 2xx, or 3xx resolving to 2xx with `-L`).
- [ ] **Step 2:** `git push origin master`.
- [ ] **Step 3:** Enable Pages: `gh api -X POST repos/craigm26/founder-skills/pages -f "source[branch]=master" -f "source[path]=/docs"`. (409 = already enabled; then PUT instead.)
- [ ] **Step 4:** Poll `https://craigm26.github.io/founder-skills/` with curl until 200 (retry up to ~3 min; first deploy is slow). Confirm the body contains "judgment layer".
- [ ] **Step 5:** Final commit of any verification fixes; push; report URLs to the operator.
