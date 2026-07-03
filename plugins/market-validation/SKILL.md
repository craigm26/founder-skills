---
name: market-validation
description: >-
  Validate whether there is a real market for a product idea, end to end: scope questions → a multi-angle
  web-research workflow with mandatory live-URL verification → a cited evidence pack → a Tufte HTML deck +
  PDF + PPTX → a build/integrate brief and an emitted market-map graph. Use when the
  user asks "is there a market for X", "validate demand for", "prove the market for", "should I build X",
  "market research / competitor + willingness-to-pay evidence for X", or wants a fundable evidence pack.
---

# Market Validation

Runs the proven pipeline that turns a product idea into a defensible, cited market-evidence pack plus
shareable artifacts. Generalized from the ShiftMate run (see `references/example-shiftmate/`).

## Before you start (state this to the user)
- **Cost/time:** MEASURED 2026-07-02: a minimum-honest run (4 default angles) = **1,134,356 tokens, 30 agents, ~20 min**; a full run is larger — the reference run was **~1.5M tokens, ~38 agents, ~50 min** on a
  4-core Pi. Confirm scope (Phase 0) before launching; this is a deliberate spend, not a quick lookup.
- **Workflow opt-in:** Phase 1 launches the Workflow tool. That is allowed because *this skill's
  instructions tell you to call Workflow* (the tool's documented allowance) — you do not need separate
  user opt-in beyond their asking for the validation.
- **Discipline:** read `references/verification-discipline.md` and follow it. Live-URL verification and the
  counter-evidence angle are non-negotiable. Apply the same honesty to your own integration claims.

## Phase 0 — Scope
Ask the user 3 questions with AskUserQuestion (one call, three questions):
1. **Geography** — US only / US + adjacent (e.g. Canada) / US + global.
2. **Customer segment** — the core buyer/ICP; optionally adjacent segments.
3. **Proof angles to prioritize** (multiselect) — pain / competitor / willingness-to-pay / market-size.

Assemble a `RunConfig`: `{ product, oneLiner, customer, geography, date, scope }` where `scope` is a 2-3
sentence paragraph (market definition + customer + geography + "prefer recent sources / current status as
of <date>").

## Phase 1 — Investigate (the Workflow)
**You** compose the research **angle set** (the script does NOT invent angles — spec R2):
- The 4 fixed dimensions are always included: `pain`, `competitor`, `wtp`, `counter` (counter-evidence).
- Add **4–7 product-specific angles** (e.g. per-region pain, an adjacent-market analog, a policy/regulatory
  angle, a financing/pricing angle). Each angle is `{ key, title, focus }` with a concrete `focus`.
- **Show the angle set to the user** before launching (it determines the spend).

Launch the bundled workflow:
```
Workflow({
  scriptPath: "<skill-dir>/assets/research-workflow.js",
  args: { config: RunConfig, angles: [ ...angleObjects ] }
})
```
It runs investigate → curate → **live-URL verify** → synthesize and returns
`{ report, survivors[], competitors[], droppedCount }`. (`survivors` = verified claims with quotes + URLs.)

## Phase 2 — Synthesize → canonical `deck-data.json`
From the workflow's `survivors` + `competitors` + `report`, assemble ONE `deck-data.json` (the single source
of truth). **This report→`deck-data.json` step is a manual seam where run-to-run quality varies most — mirror
`references/example-shiftmate/deck-data.json` closely** (assign each competitor a tier, number every source,
map every inline `[n]` ref to the sources list). Required blocks: `meta`,
`verdict` (with HIGH/MODERATE/LOW `confidence`), `pain`, `categories` (tiers), `competitors` (with a
`category` per the tiers), `competitorKicker`, `wtp`, `global`, `counter` (risks + gaps), `sources`
(numbered; every cited URL). Optional blocks — include only if the data exists: `sizing` (durable vs
frozen/ended bars), `funding` (events with `date "YYYY-MM"`, `amount`, `tier`), `homeowner`/demand stats,
and `process` (`{steps:[{label}]}` — the workflow the product targets, for the atlas). Also keep the full
markdown evidence pack (the workflow's `report`) as the durable write-up.

## Phase 3 — Visualize
```
<python-with-python-pptx> <skill-dir>/assets/build_deck.py deck-data.json --out <out-dir> --pdf
```
- Produces `<slug>.html` (always; self-contained Tufte deck, clickable citations, in-page Save-PDF /
  Export-PPTX buttons), `<slug>.pptx` (if python-pptx importable, else `PPTX_SKIPPED`), and `<slug>.pdf`
  (if `--pdf` and chromium present, else `PDF_SKIPPED`).
- A python with python-pptx — create a venv if needed
  (`python3 -m venv ~/.mv-venv && ~/.mv-venv/bin/pip install python-pptx`). The HTML alone satisfies
  "export to PDF/PPTX" via its buttons, so missing python-pptx/chromium is not fatal — report what was made.

## Phase 4 — Decide & integrate
1. **Emit the market-map graph:**
   ```
   python3 <skill-dir>/assets/market-map/emit_market_map.py deck-data.json <out-dir>/market-map
   ```
   Produces `nodes.json` + `flows.json` — the competitive landscape and target process as a small graph
   (contract in `references/market-map-schema.md`). Loading it into a viewer or platform is sink-specific:
   see `references/sinks.md`. **Describe the output as "shape-valid; loading is the sink's to verify"** —
   never claim a specific platform integration "works today" without having run it.
2. **Write the build/integrate brief** by filling `assets/market-map/brief.template.md` from the evidence
   pack. If the map is destined for a platform without a write API, the brief's "follow-on work" stub names
   that import path as its own project — this skill only emits the JSON + the stub.

## Deliverables of a run
`deck-data.json`, the markdown evidence pack, `<slug>.html` (+ `.pdf`/`.pptx` if produced),
`market-map/nodes.json` + `market-map/flows.json`, and the build/integrate brief. Surface them to the user (SendUserFile).

## Known limitations (keep your honesty consistent)
- **The generalized workflow was proven on 2026-07-02** (see
  `docs/superpowers/specs/2026-07-02-flagship-campaign-execution.md`): a real minimum-honest run
  (4 default angles, real product topic, 30 agents) threaded `args.config` into the investigator
  prompts and returned the documented `{ report, survivors[], competitors[], droppedCount }` shape
  (24 curated / 24 survived / 0 dropped). `args.angles` beyond the defaults is still unexercised;
  on a custom-angles run, confirm they flow into the prompts before trusting the output.
- **The emitted market map is shape-valid; a sink's load path is only proven where `references/sinks.md`
  records a dated proof** (the PlatAtlas hosted path was proven 2026-07-02; every OTHER sink remains
  "shape-valid, load-untested"). Do not tell the user an unproven platform integration "works today."
- **Phase 2 (report → `deck-data.json`) is a manual seam.** No code automates it; lean hard on the golden example.

## References
- `references/verification-discipline.md` — the non-negotiable rules (read first).
- `references/market-map-schema.md` — the market-map output contract.
- `references/sinks.md` — where the emitted map can go (generic + worked example).
- `references/example-shiftmate/` — a full worked example (`deck-data.json` + `brief.md`) to mirror.

## Tests
- `python3 -m pytest <skill-dir>/tests -q` — smoke-tests the deck generator (full + minimal data) and the
  market-map emitter (shape + referential integrity). Run after editing `build_deck.py` or `emit_market_map.py`.
- `node --test '<skill-dir>/tests/js/*.test.mjs'` — exercises `assets/research-workflow.js` via a harness
  (`tests/js/harness.mjs`) that replicates the Workflow runtime (wraps the script body in an async function
  and injects stubbed `agent`/`parallel`/`phase`/`log`/`args`). Covers the investigator retry / looser-schema
  fallback: a flaky angle (null-or-throw on the strict attempt) is recovered on retry, a permanently-failing
  angle is logged as DROPPED by name (no silent cap), and the happy path makes no spurious retry/drop. Run
  after editing the investigator section of `research-workflow.js`.
