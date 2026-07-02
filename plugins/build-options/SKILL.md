---
name: build-options
description: >-
  Decide WHAT to build after a market is validated: generate divergent build options, score them with an
  independent judge panel into a weighted decision matrix, adversarially stress-test the top, recommend one
  (with kill criteria), render a Tufte decision matrix, and hand the winner to the `prd` skill. Use when the
  user asks "what should I build", "what are my build options", "which option should we build", "decide what
  to build", or after running `market-validation`.
---

# Build Options

Turns a validated market into a *defensible choice* among concrete build options. Runs the judge-panel
method (generate → score → stress-test → choose). Pairs with `market-validation` (before) and `prd` (after).
Read `references/decision-method.md` and `references/chaining.md` first.

## Before you start
- **Cost/time:** ~12 agents (6 generators + 3 judges + ~3 skeptics) — smaller than a `market-validation` run,
  but confirm the framing in Phase 0 before launching.
- **Workflow opt-in:** Phase 1 launches the Workflow tool; allowed because this skill instructs it.
- **Honesty:** scores are directional, not precise — always show the full matrix + kill criteria, never a bare verdict.

## Phase 0 — Frame
Build a `DecisionContext` (`references/chaining.md`): **chain from a prior `market-validation` run** (read its
`deck-data.json` + brief) if available, else collect a short standalone brief. Then confirm with the user via
AskUserQuestion: budget/time horizon, risk appetite, and **must-reuse assets**. Present the **default criteria
+ weights** (`references/decision-method.md`) and let the user adjust (weights must sum to 1.0). Optionally
adjust the strategic **lenses**.

## Phase 1 — Run the judge panel (Workflow)
You supply the context, criteria, and lenses; the script executes them (it does not invent them):
```
Workflow({ scriptPath: "<skill-dir>/assets/build-options-workflow.js",
           args: { context: DecisionContext, criteria: [...], lenses: [...] } })
```
It generates one option per lens, has 3 independent judges score every option on every criterion, aggregates
to per-criterion `{mean, spread, notes}`, stress-tests the top ~3, and returns
`{ options (with scores + adversarial), criteria, judgeCount, stressTested }`.

## Phase 2 — Assemble `decision-data.json`
Write ONE canonical `decision-data.json` (mirror `references/example-shiftmate/decision-data.json`):
`meta`, `context`, `criteria` (with weights), `options` (the workflow's output verbatim — raw `scores` means;
**do NOT hand-compute weighted totals**, `build_matrix.py` does that), `recommendation` (your call: winner +
rationale + grafts + confidence), and `killCriteria`. If the workflow's top option was `killed` in the
adversarial pass, do not recommend it without re-scoring.

## Phase 3 — Visualize
```
python3 <skill-dir>/assets/build_matrix.py decision-data.json --out <out-dir> --pdf
```
Computes weighted totals + tie analysis via `weighting.py` and renders the Tufte matrix (`<slug>.html`;
`+ .pptx` if python-pptx; `+ .pdf` with `--pdf` + chromium). If `tie.isTie`, lead with the deciding factor.

## Phase 4 — Hand off to `prd`
Invoke the **`prd`** skill with a feature description = the winning option's `thesis` + `mvpScope` +
`businessModel` + key constraints (see `references/chaining.md`). It writes `/tasks/prd-*.md`; the `tasks`
skill then turns that into `prd.json`. Surface all artifacts to the user (SendUserFile).

## Deliverables
`decision-data.json`, `<slug>.html` (+ `.pdf`/`.pptx` if produced), and the PRD for the chosen option.

## Known limitations (keep your honesty consistent)
- **The workflow (`build-options-workflow.js`) was proven on 2026-07-02** (see
  `docs/superpowers/specs/2026-07-02-flagship-campaign-execution.md`): a real run (3 lenses,
  3 judges, 3 skeptics) threaded `args` and returned the documented shape — and caught a silent
  skeptic-verdict drop (verdicts joined on a model-echoed optionId; every mismatch defaulted to
  `survive/[]`). Fixed the same day by binding verdicts to options by construction. Lesson: join
  sub-agent outputs on keys YOU control, and treat an empty `killerRisks` on a top option as suspect.
- **The `prd` handoff is described, not yet exercised** — confirm the PRD lands in `/tasks/` the first time.
- **LLM judges cluster scores** → frequent "too close to call." If the matrix doesn't discriminate, sharpen
  the criteria **weights** (the lever), not the method.

## Tests
`python3 -m pytest <skill-dir>/tests -q` — unit-tests the weighting math (aggregation, weighted sum with
`reg_risk` inversion, tie detection) and smoke-tests the matrix render (golden + minimal). Run after editing
`weighting.py` or `build_matrix.py`.

## References
- `references/decision-method.md` — rubric, math, tie/kill rules.
- `references/chaining.md` — read market-validation output; standalone brief; the `prd` handoff.
- `references/example-shiftmate/decision-data.json` — worked example (ShiftMate).
