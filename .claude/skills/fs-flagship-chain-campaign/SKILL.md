---
name: fs-flagship-chain-campaign
description: >-
  The decision-gated executable campaign that proved and hardened the flagship founder chain
  (market-validation → build-options → prd → tasks). Phases 0-3 executed 2026-07-02 (template
  rescue, proving runs, prd/tasks rewrite, site truth-up) — the skill remains the record and the
  playbook for regressions or a future re-run. Use when
  a maintainer says "run the proving run", "prove the workflow scripts", "harden the founder chain",
  "is the flagship chain fixed", "rewrite prd/tasks", "genericize agent-browser", "fix the site
  oversell", or asks what the current phase/status of the flagship campaign is.
---

# Flagship Chain Campaign

You are executing a phased, decision-gated campaign on the repo's hardest live problem. The
**flagship chain** is the four-plugin founder pipeline `/market-validation → /build-options → /prd
→ /tasks` (handoffs pass file paths, never inline content). Its execution end is unproven: the two
**Workflow scripts** (JS files run by Claude Code's `Workflow({scriptPath, args})` tool, which
orchestrates sub-agents) were self-declared **"syntax-checked only"** until the 2026-07-02
proving runs, and `prd`/`tasks` were off-style external imports until the same-day rewrite. A
**proving run** = the first real execution, judged only by measurable observations.

**Announce at start:** "Running the flagship-chain campaign — current phase status below; every
gate is measured (exit codes, counts, shapes), never judged by eye."

**Iron rules of this campaign:**
1. Promotion of every phase routes through **fs-change-control** (spec in `docs/superpowers/specs/`,
   date-prefixed, operator-approved → checkbox plan in `docs/superpowers/plans/` → commits matching
   the plan verbatim). No phase ships around it.
2. Assistants run **no mutating git commands**; the operator reviews and commits.
3. Success is MEASURED: test counts, gate-script exit codes, rendered artifacts. Run
   `.claude/skills/fs-flagship-chain-campaign/scripts/gate.sh` at every gate.

## Campaign status board (as of 2026-07-02)

| Phase | What | Status | Gate |
|---|---|---|---|
| 0 | Template rescue + gitignore fix | **DONE — committed `648d304`, pushed 2026-07-02** | `gate.sh phase0` → exit 0 ✓ |
| 1 | Proving runs of both Workflow scripts | **EXECUTED 2026-07-02** (minimum-honest scale, real topic): 1A passed all expected observations (4/4 angles, 24 curated/24 survived, shape+args ✓); 1B ran end-to-end and CAUGHT ledger entry 9 (silent skeptic-verdict drop) — fixed by-construction, stress-test leg re-run | `gate.sh phase1 <r.json> <b.json>` → exit 0 |
| 2 | Rewrite prd/tasks into house style + genericize agent-browser | **DONE 2026-07-02, uncommitted** — all 9 criteria pass (independent acceptance agent) | measurable criteria below ✓ |
| 3 | Site truth-up (docs/index.html oversell) | **DONE 2026-07-02, uncommitted** (operator un-gated in-session; 3 maintainer-tooling cards added; site-checks.sh green) | strings removed ✓ + fs-release-and-publish gate |

## When NOT to use this skill

| You actually want to… | Load instead |
|---|---|
| Understand the repo / find the right skill | **fs-orientation** |
| Write/format the spec+plan for a phase's promotion | **fs-change-control** |
| Push/publish a completed phase | **fs-release-and-publish** |
| Recreate the venv / run or extend the three test suites | **fs-toolchain-and-tests** |
| Learn the house style Phase 2 must target | **fs-skill-style-guide** |
| Edit the Pages site itself (Phase 3 mechanics) | **fs-site-and-positioning** |
| Read the history of how these defects happened | **fs-failure-archaeology** |
| Workflow/Agent/AskUserQuestion semantics in general | **fs-anthropic-primitives** |

## Phase 0 — Template rescue (DONE 2026-07-02; record + guard)

**What happened:** `plugins/build-options/assets/matrix.template.html` was never committed — the
plugin `.gitignore` line `*.html` swallowed it, so `build_matrix.py` (which hard-requires it at
`HERE / "matrix.template.html"`) shipped broken; 2 pytest failures (FileNotFoundError). The sole
surviving copy was rescued from the mutable plugin cache into the repo, and `.gitignore` gained the
negation `!assets/matrix.template.html`. Full history: **fs-failure-archaeology** (ledger #1).

**State:** committed as `648d304` and pushed 2026-07-02 (the handoff library + 3 skill-*
plugins + marketplace registration rode the same commit — the manifest references
`./plugins/skill-*` sources, so they had to ship together on the live-publishing master).

**Your job for Phase 0 now:** it's a guard, not a task — run the gate after any change touching
build-options assets or gitignores.
```bash
.claude/skills/fs-flagship-chain-campaign/scripts/gate.sh phase0
```
Expected: `GATE PASS: phase0 (template intact, gitignore negation present, 9+6 pytest, 5 node:test)`,
exit 0. If pytest can't import: the host Python (3.13.5) is PEP-668 externally managed — create the
venv per **fs-toolchain-and-tests**, or pass `PY=<venv>/bin/python` to the gate script (its default
`~/venvs/founder-skills/bin/python` is environment-specific).

## Phase 1 — Proving runs (the two syntax-checked-only Workflow scripts)

Both scripts read `args` defensively (JSON string or object) and were only ever executed in an
earlier hardcoded form. The unknown being proven is the **live Workflow runtime + args threading +
return shape**, NOT the internal logic (the JS harness already covers the investigator retry logic
— re-mocking proves nothing new).

**Scale options, ranked (pick with the operator via AskUserQuestion):**
1. **(Recommended) Minimum-honest run** — a real product idea, but minimal knobs: market-validation
   with only the 4 default angles (pain/competitor/wtp/counter); build-options with 3 lenses and the
   8 default criteria. Proves args plumbing + shapes at a fraction of the reference cost. Still real
   web-research spend.
2. **Full-fidelity run** — 4 fixed + 4–7 product angles, 6 lenses. Also proves the Phase-2 manual
   seam at reference cost (**~1.5M tokens, ~38 agents, ~50 min** on a 4-core Pi, per
   market-validation SKILL.md).
3. **FENCED: mocked "proving" run** — stubbing `agent()` again duplicates the existing node:test
   suite and proves nothing about the live runtime. Do not count it as the proving run.

### 1A — market-validation `research-workflow.js`

Invocation (from the repo checkout; `<repo>` = the founder-skills root — the installed plugin cache
copy is byte-identical at HEAD 2e4c9dd but may desync after future pushes, so prefer the repo path):
```
Workflow({
  scriptPath: "<repo>/plugins/market-validation/assets/research-workflow.js",
  args: { config: { product, oneLiner, customer, geography, date, scope },
          angles: [ { key, title, focus }, ... ] }   // omit angles → 4 defaults
})
```

**Expected observations, in order** (from the script source, verified 2026-07-02):

| Gate | Expect |
|---|---|
| Phases announced | `Investigate` → `Curate` → `Verify` → `Synthesize` |
| Agent labels | `investigate:<key>` per angle (+ `investigate-loose:<key>` only on strict-schema failure), then `curate`, then `verify:<i>` one per curated claim, then `synthesize` |
| Args threading | Your product name / scope text appears inside investigator prompts (SCOPE line). Generic "the product" = args did NOT thread |
| Log after Investigate | `Collected N raw claims across M of K dispatched angles` (dropped angles named: `DROPPED ANGLE "<key>" …`) |
| Log after Curate | `Curated N claims; M competitors` — N should be 18–24 on a real run |
| Log after Verify | `Verified: X survived, Y dropped` |
| Return shape | `{ report (markdown string), survivors[], competitors[], droppedCount }` |

**Then:** save the return value verbatim to `research-output.json` and run
`gate.sh phase1 research-output.json build-options-output.json` (after 1B).

**If you see X instead:**
- **Prompts say "the product" / generic scope** → args didn't thread. Check whether the Workflow
  host passed `args` as a JSON string vs object (script handles both) — if neither arrived, the
  args-passing convention itself is broken; record in **fs-failure-archaeology** and stop.
- **`curate` throws / returns null** → the workflow has NO retry outside investigators; a failed
  curate/verify/synthesize call aborts or empties the run. `toVerify` becomes `[]` → 0 survivors.
  Treat as a failed proving run, not "the market has no evidence".
- **All angles DROPPED** → `allClaims` is empty; abort rather than let curate hallucinate. Likely
  cause: the host's structured-output (`schema`) support differs from what `agent()` provides.
- **droppedCount very high (> survivors)** → verification working as designed but sources weak;
  the run is still a *successful proving* of the script — note the distinction.

### 1B — build-options `build-options-workflow.js`

```
Workflow({
  scriptPath: "<repo>/plugins/build-options/assets/build-options-workflow.js",
  args: { context: DecisionContext, criteria: [...], lenses: [...] } })  // omit → 8 criteria / 6 lenses
```

| Gate | Expect |
|---|---|
| Phases | `Generate` → `Score` → `Stress-test` |
| Agent labels | `gen:<lensKey>` per lens, `judge:1..3`, `refute:<optionId>` for top ~3 |
| Logs | `Generated N options` (N = lens count), `Scored by 3 judges; stress-testing top 3` |
| Return shape | `{ options[], criteria[], judgeCount, stressTested[] }`; each option has `scores` (per-criterion `{mean, spread, notes}`) and `adversarial` (`{verdict, killerRisks}`) |

Save the return verbatim to `build-options-output.json`, then:
```bash
.claude/skills/fs-flagship-chain-campaign/scripts/gate.sh phase1 research-output.json build-options-output.json
```
Expected: `GATE PASS: phase1 …`, exit 0. Then complete the chain-proof by feeding a
`decision-data.json` (assembled per build-options SKILL.md Phase 2) into:
```bash
python3 plugins/build-options/assets/build_matrix.py decision-data.json --out <out-dir>
```
Expected: `HTML <out-dir>/<slug>.html <n> chars` printed (the script asserts placeholder injection);
the rendered file is the measured artifact.

**If you see X instead:**
- **An option's `scores` is `{}` / gate fails "non-numeric scores"** → judges returned wrong
  `optionId` keys; the aggregation silently skips mismatches. Re-run judges or fix ids — do NOT
  hand-fill scores.
- **`judgeCount` < 3** → some judge agents returned null and were filtered; the panel is weaker.
  Gate allows ≥2; below that the "independent panel" claim is false — rerun.
- **A stress-tested option shows `adversarial.verdict: "survive"` with empty `killerRisks`** →
  KNOWN GOTCHA: a skeptic returning a mismatched `optionId` is silently replaced by a default
  `{verdict:'survive', killerRisks:[]}`. An empty killerRisks on a top-3 option is suspicious —
  check the `refute:<id>` labels matched real option ids before trusting "survive".

**Promotion:** when both gates pass, the proving run's evidence (saved JSONs + gate output +
rendered HTML) goes into a dated spec via **fs-change-control**; the SKILL.md "syntax-checked only"
admissions in both plugins may then be updated to "proven on <date> (see spec)" — never simply
deleted. Measurement artifacts from this run are exactly what **fs-research-frontier**'s
measured-not-claimed program wants — save token counts if the host reports them.

## Phase 2 — Rewrite prd/tasks into house style (licensed by operator 2026-07-02)

`plugins/prd/SKILL.md` (200 lines) and `plugins/tasks/SKILL.md` (480 lines) are imports from an
external "compound engineering" methodology: emoji ❌/✅ rubrics, no references/assets, no model
routing, no Announce convention, and `tasks` hard-depends on the third-party `agent-browser` CLI
(22 mentions, all in `plugins/tasks/SKILL.md` as of 2026-07-02 — an unstated install dependency).

Do the rewrite **in place** (same plugin dirs — the chain's slash-names and handoff contracts
`/tasks/prd-*.md` → `prd.json` must not change). Target style lives in **fs-skill-style-guide**
(extracted from the golden four); do NOT copy style from prd/tasks themselves or tufte-viz.

**Genericize agent-browser exactly the way Codex became "external executor":** the capability
becomes a generic **"browser executor"** with agent-browser named only as an example ("such as
agent-browser"), commands expressed as capability patterns (open/snapshot/click/fill/screenshot/
console-check), and the acceptance-criteria table kept — it is the import's genuinely valuable
idea (boolean, machine-verifiable criteria).

**Measurable acceptance criteria (all must hold before promotion):**

| # | Check | Command | Expect |
|---|---|---|---|
| 1 | Frontmatter exactly `name` + `description` (folded `>-`), trigger-rich | `head -12 plugins/{prd,tasks}/SKILL.md` | matches golden-four pattern |
| 2 | No hard third-party dep | `grep -rc "agent-browser" plugins/tasks/SKILL.md` | only inside "such as" example mentions (target ≤2) |
| 3 | No off-style emoji rubric | `grep -c "❌\|✅" plugins/{prd,tasks}/SKILL.md` | 0 |
| 4 | Length in house norm | `wc -l plugins/{prd,tasks}/SKILL.md` | ~78–233 each |
| 5 | House closers present | grep for `Known limitations`, `## References` | present |
| 6 | Handoff contract unchanged | build-options SKILL.md Phase 4 still true: PRD lands in `/tasks/prd-*.md`; tasks emits `prd.json` with `passes:false` | verified by reading, ideally by one live handoff |
| 7 | Nothing else broke | `gate.sh phase0` | exit 0 |

Route through **fs-change-control** (spec naming a before/after for each criterion → plan →
operator commits). Per-plugin READMEs (marketing-facing template) follow in the same spec.

## Phase 3 — Site truth-up (OPERATOR-GATED — do not start without explicit approval)

`docs/index.html` violates the repo's own no-oversell doctrine (defect ledger #6, verified
still open 2026-07-02): two `~0 tokens` cost chips and one "runs itself weekly" claim. The
exact strings and line numbers live in **fs-failure-archaeology** entry 6; the candidate
corrections table lives in **fs-site-and-positioning** — this phase points there rather than
duplicating them.

Mechanics and the sibling-site coordination requirement live in **fs-site-and-positioning**; the
push itself goes through **fs-release-and-publish** (master is live-publishing). Measured success:
`grep -c "~0 tokens\|runs itself weekly" docs/index.html` → 0, and the deployed page reflects it.

## Fenced wrong paths (do not go here)

| Fence | Why |
|---|---|
| **F1: Do NOT regenerate `matrix.template.html` from scratch** | The rescued copy is canonical; a regenerated one is an untested lookalike that silently changes the rendered artifact. If it goes missing, restore from git history (post-commit) or the plugin cache — never re-author. |
| **F2: No GitHub Actions, ever** | Standing org-wide rule since 2026-06-19 (billing-blocked + operator preference). All gates are LOCAL scripts. |
| **F3: No mocked proving run counted as proof** | The node:test harness already mocks; the unknown is the live runtime. |
| **F4: Never hand-compute weighted totals** | `build_matrix.py` + `weighting.py` are the single source of truth; hand math desyncs viz from data. |
| **F5: Don't delete the honesty admissions** | "syntax-checked only" lines get *updated with evidence*, not removed. |
| **F6: Don't edit docs/index.html outside Phase 3's operator gate** | Site edits need a coordinated spec (sibling catalog site must stay in sync manually). |

## Quick reference

```bash
# status of the campaign's ground truth
git -C <repo> status --short                       # phase-0 files still uncommitted?
.claude/skills/fs-flagship-chain-campaign/scripts/gate.sh phase0
.claude/skills/fs-flagship-chain-campaign/scripts/gate.sh phase1 research-output.json build-options-output.json
python3 plugins/build-options/assets/build_matrix.py decision-data.json --out out/   # rendered-artifact check
```

## Provenance and maintenance

All facts verified 2026-07-02 against HEAD `2e4c9dd` + the uncommitted phase-0 working tree.
Re-verify before trusting:

- Phase-0 state: `git -C <repo> status --short` (expect the seven-entry working tree listed in
  Phase 0 until the operator commits; after commit, `gate.sh phase0` is the only check that matters).
- Test counts (9/6/5): `gate.sh phase0` — it embeds all three suites.
- Workflow return shapes: `grep -n "^return {" plugins/market-validation/assets/research-workflow.js
  plugins/build-options/assets/build-options-workflow.js` (lines 146 and 129 as of 2026-07-02).
- honesty admissions graduated: `grep -rln "syntax-checked only" plugins/*/SKILL.md` matches ONLY
  skill-style-guide (which teaches the convention) since the 2026-07-02 promotion — market-validation
  and build-options now read "proven on 2026-07-02"; the spec records the evidence.
- agent-browser count: `grep -rc "agent-browser" plugins/tasks/SKILL.md` (1 since the 2026-07-02 rewrite; >2 = regression).
- Site oversell strings: `grep -n "~0 tokens\|runs itself weekly" docs/index.html` (0 since 2026-07-02; any hit = regression).
- Gate script self-test: it was verified 2026-07-02 to PASS on real phase-0 state and to FAIL on
  synthetic bad phase-1 JSON (leaked `drop` verdict; empty scores). If you edit it, re-run both directions.
- Reference-run cost figures (~1.5M tokens/~38 agents/~50 min): sourced from
  `plugins/market-validation/SKILL.md` "Before you start" — update there first, here second.
