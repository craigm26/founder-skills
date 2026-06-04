---
name: market-validation
description: >-
  Validate whether there is a real market for a product idea, end to end: scope questions → a multi-angle
  web-research workflow with mandatory live-URL verification → a cited evidence pack → a Tufte HTML deck +
  PDF + PPTX → a build/integrate brief and an emitted workflow-atlas market map. Use when the
  user asks "is there a market for X", "validate demand for", "prove the market for", "should I build X",
  "market research / competitor + willingness-to-pay evidence for X", or wants a fundable evidence pack.
---

# Market Validation

Runs the proven pipeline that turns a product idea into a defensible, cited market-evidence pack plus
shareable artifacts. Generalized from the ShiftMate run (see `references/example-shiftmate/`).

## Before you start (state this to the user)
- **Cost/time:** a full run is large — the reference run was **~1.5M tokens, ~38 agents, ~50 min** on a
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
- A python with python-pptx: `~/.rebateops-viz-venv/bin/python`, or create one
  (`python3 -m venv ~/.mv-venv && ~/.mv-venv/bin/pip install python-pptx`). The HTML alone satisfies
  "export to PDF/PPTX" via its buttons, so missing python-pptx/chromium is not fatal — report what was made.

## Phase 4 — Decide & integrate
1. **Emit the workflow-atlas market map:**
   ```
   python3 <skill-dir>/assets/platatlas/emit_atlas.py deck-data.json <out-dir>/atlas
   ```
   Produces `nodes.json` + `flows.json` for a repo's `docs/workflows/`. **Describe these as "shape-valid;
   end-to-end load UNTESTED"** unless `references/workflow-atlas-schema.md` records a passed load round-trip
   (spec R3). Do not claim the atlas "works in workflow-atlas today."
2. **Write the build/integrate brief** by filling `assets/platatlas/brief.template.md` from the evidence
   pack — including the **Project-2 spec stub** (a new `POST …/atlases/import` endpoint so the map becomes
   one-click). Project 2 is its own brainstorm → build cycle; this skill only emits the JSON + the stub.

## Deliverables of a run
`deck-data.json`, the markdown evidence pack, `<slug>.html` (+ `.pdf`/`.pptx` if produced), `atlas/nodes.json`
+ `atlas/flows.json`, and the build/integrate brief. Surface them to the user (SendUserFile).

## Known limitations (keep your honesty consistent)
- **The generalized workflow is syntax-checked only — its first real invocation is its proving run.**
  `assets/research-workflow.js` was rewritten to read `args.config`/`args.angles` and to return
  `{ report, survivors[], competitors[], droppedCount }`, but it has only ever executed in its earlier
  *hardcoded* form. On the first run, confirm `args.angles` actually flows into the investigator prompts and
  that the returned `survivors`/`competitors` match what Phase 2 consumes — before trusting the ~1.5M-token output.
- **The emitted atlas is shape-valid but load-untested** (spec R3 / `references/workflow-atlas-schema.md`).
  Do not tell the user it "works in workflow-atlas today."
- **Phase 2 (report → `deck-data.json`) is a manual seam.** No code automates it; lean hard on the golden example.

## References
- `references/verification-discipline.md` — the non-negotiable rules (read first).
- `references/workflow-atlas-schema.md` — the atlas output contract + the unproven load path.
- `references/example-shiftmate/` — a full worked example (`deck-data.json` + `brief.md`) to mirror.

## Tests
- `python3 -m pytest <skill-dir>/tests -q` — smoke-tests the deck generator (full + minimal data) and the
  atlas emitter (shape + referential integrity). Run after editing `build_deck.py` or `emit_atlas.py`.
- `node --test '<skill-dir>/tests/js/*.test.mjs'` — exercises `assets/research-workflow.js` via a harness
  (`tests/js/harness.mjs`) that replicates the Workflow runtime (wraps the script body in an async function
  and injects stubbed `agent`/`parallel`/`phase`/`log`/`args`). Covers the investigator retry / looser-schema
  fallback: a flaky angle (null-or-throw on the strict attempt) is recovered on retry, a permanently-failing
  angle is logged as DROPPED by name (no silent cap), and the happy path makes no spurious retry/drop. Run
  after editing the investigator section of `research-workflow.js`.
