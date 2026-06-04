import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from assets.weighting import aggregate_judges, weighted_total, detect_tie, validate_weights


def test_aggregate_mean_and_spread():
    agg = aggregate_judges([{"wtp_fit": 4}, {"wtp_fit": 2}, {"wtp_fit": 3}])
    assert agg["wtp_fit"]["mean"] == 3 and agg["wtp_fit"]["spread"] == 2 and agg["wtp_fit"]["n"] == 3


def test_reg_risk_inverts():
    crit = [{"key": "reg_risk", "weight": 1.0, "higherIsBetter": False}]
    assert weighted_total({"reg_risk": 1}, crit) > weighted_total({"reg_risk": 5}, crit)


def test_weighted_sum():
    crit = [{"key": "a", "weight": 0.5, "higherIsBetter": True},
            {"key": "b", "weight": 0.5, "higherIsBetter": True}]
    assert weighted_total({"a": 4, "b": 2}, crit) == 3.0


def test_tie_detection():
    assert detect_tie([("x", 3.0), ("y", 2.9)], 0.3)["isTie"] is True
    assert detect_tie([("x", 3.0), ("y", 2.0)], 0.3)["isTie"] is False


def test_tie_deciding_factor():
    crit = [{"key": "moat", "weight": 0.6, "higherIsBetter": True},
            {"key": "gtm", "weight": 0.4, "higherIsBetter": True}]
    scores = {"x": {"moat": 5, "gtm": 2}, "y": {"moat": 3, "gtm": 2}}
    out = detect_tie([("x", 3.0), ("y", 2.9)], 0.3, crit, scores)
    assert out["isTie"] is True and out["decidingFactor"] == "moat"


def test_validate_weights():
    assert validate_weights([{"weight": 0.5}, {"weight": 0.5}])[0] is True
    assert validate_weights([{"weight": 0.5}, {"weight": 0.4}])[0] is False
