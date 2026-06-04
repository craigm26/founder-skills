"""Pure scoring/weighting logic for build-options.

No third-party deps. This is the SINGLE SOURCE OF TRUTH for the decision math — `build_matrix.py`
imports it so the rendered matrix always reflects these functions (weighted totals are never
hand-stored in decision-data.json; they are computed here at render time).
"""

TIE_MARGIN = 0.3  # gap on the weighted 0-5 scale within which the top two options are "too close to call"


def aggregate_judges(judge_dicts):
    """judge_dicts: list of {criterionKey: score(0-5)} (one per judge).
    Returns {criterionKey: {"mean": float, "spread": int/float, "n": int}}. spread = max-min across judges."""
    keys = set()
    for d in judge_dicts:
        keys |= set(d.keys())
    out = {}
    for k in keys:
        vals = [d[k] for d in judge_dicts if k in d]
        if not vals:
            continue
        out[k] = {"mean": sum(vals) / len(vals), "spread": max(vals) - min(vals), "n": len(vals)}
    return out


def weighted_total(scores, criteria):
    """scores: {criterionKey: score(0-5)}. criteria: [{key, weight, higherIsBetter}].
    Returns the weighted 0-5 total, inverting criteria where higherIsBetter is False (e.g. reg_risk)."""
    total = 0.0
    for c in criteria:
        s = scores.get(c["key"])
        if s is None:
            continue
        eff = s if c.get("higherIsBetter", True) else (5 - s)
        total += c["weight"] * eff
    return round(total, 4)


def detect_tie(ranked, margin=TIE_MARGIN, criteria=None, option_scores=None):
    """ranked: [(optionId, weightedTotal)] sorted DESC. Returns {isTie, margin, decidingFactor}.
    decidingFactor (when tied) = the highest-weight criterion on which the top two options differ."""
    if len(ranked) < 2:
        return {"isTie": False, "margin": None, "decidingFactor": None}
    gap = ranked[0][1] - ranked[1][1]
    is_tie = gap <= margin
    deciding = None
    if is_tie and criteria and option_scores:
        a, b = ranked[0][0], ranked[1][0]
        for c in sorted(criteria, key=lambda x: -x["weight"]):
            sa = option_scores.get(a, {}).get(c["key"])
            sb = option_scores.get(b, {}).get(c["key"])
            if sa is None or sb is None:
                continue
            if sa != sb:
                deciding = c["key"]
                break
    return {"isTie": is_tie, "margin": round(gap, 3), "decidingFactor": deciding}


def validate_weights(criteria, tol=1e-6):
    """Criteria weights must sum to ~1.0. Returns (ok, total)."""
    total = sum(c.get("weight", 0) for c in criteria)
    return (abs(total - 1.0) <= tol, round(total, 6))
