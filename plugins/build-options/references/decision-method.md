# Decision method (judge panel + weighted matrix)

The scoring math lives in `assets/weighting.py` (unit-tested) and is applied by `assets/build_matrix.py`.
This file is the rubric + the rules so a run is reproducible and defensible.

## Scoring rubric (0–5 per criterion, per judge)
- **5** clearly excellent / decisive advantage · **4** strong · **3** adequate · **2** weak · **1** poor · **0** absent/disqualifying.
- Judges MUST use the full range and give a one-line note grounding each score (forces evidence, fights clustering).
- For `higherIsBetter: false` criteria (e.g. `reg_risk`), a higher raw score still means *more of the named thing*
  (more regulatory risk); the inversion happens only in the weighted total.

## Aggregation & weighting (single source of truth = weighting.py)
- Per (option, criterion): `mean` and `spread = max − min` across the judges. `spread ≥ 3` ⇒ flag low-confidence.
- `weightedTotal = Σ weightₖ · (higherIsBetterₖ ? meanₖ : 5 − meanₖ)` on a 0–5 scale.
- Criteria weights must sum to 1.0 (`validate_weights`); the matrix flags it if they don't.

## Tie & recommendation rules
- `TIE_MARGIN = 0.3` on the weighted total. If the top two are within it ⇒ **"too close to call"**: report the
  `decidingFactor` = the highest-weight criterion on which the top two differ, rather than forcing a pick.
- Recommend the top option; **graft** the best ideas from runners-up into the recommendation.
- Always show the full matrix and **kill criteria** ("what would change this answer"), not just a verdict.

## Adversarial stress-test
- The top ~3 options (by raw unweighted mean) get a skeptic each, prompted to *refute*.
- Verdicts: `killed` (fatal flaw — drop or heavily penalize), `wounded` (serious but survivable), `survive`.
- A `killed` top option must not be recommended without re-scoring its risk criteria.

## Honesty
- Scores are **directional, not precise** — say so. The value is the structured comparison + the surfaced risks,
  not false decimal precision. If everything clusters/ties, the criteria *weights* need sharpening (the lever),
  not the method.
