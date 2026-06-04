import json, subprocess, sys, pathlib, tempfile, shutil

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
GOLDEN = ROOT / "references/example-shiftmate/decision-data.json"


def _render(data_path):
    work = pathlib.Path(tempfile.mkdtemp())
    shutil.copy(ROOT / "assets/matrix.template.html", work / "matrix.template.html")
    shutil.copy(ROOT / "assets/build_matrix.py", work / "build_matrix.py")
    shutil.copy(ROOT / "assets/weighting.py", work / "weighting.py")
    r = subprocess.run([sys.executable, str(work / "build_matrix.py"), str(data_path)],
                       cwd=work, capture_output=True, text=True)
    return r, work


def test_renders_golden_with_recommendation_and_all_options():
    r, work = _render(GOLDEN)
    assert r.returncode == 0, r.stderr + r.stdout
    html = list(work.glob("*.html"))[0].read_text()
    assert "__DECISION_DATA__" not in html
    data = json.loads(GOLDEN.read_text())
    for o in data["options"]:
        assert o["name"] in html
    assert "Recommendation" in html


def test_enrich_ranks_automation_undercut_first():
    from assets import build_matrix
    data = build_matrix.enrich(json.loads(GOLDEN.read_text()))
    assert data["ranking"][0] == "automation-undercut"          # the scored winner
    assert data["tie"]["isTie"] is False                          # clear margin, discriminating
    # weighted totals strictly descending in ranking order
    totals = [next(o for o in data["options"] if o["id"] == i)["weightedTotal"] for i in data["ranking"]]
    assert totals == sorted(totals, reverse=True)


def test_minimal_decision_renders():
    minimal = {
        "meta": {"title": "Tiny Decision", "subtitle": "x", "date": "2026-06-02", "provenance": "test"},
        "context": {"incumbents": ["Inc"], "mustReuseAssets": [], "constraints": ""},
        "criteria": [{"key": "a", "label": "A", "weight": 0.5, "higherIsBetter": True},
                     {"key": "b", "label": "B", "weight": 0.5, "higherIsBetter": True}],
        "options": [
            {"id": "o1", "name": "Opt One", "lens": "l1", "thesis": "t", "timeToRevenue": "weeks",
             "scores": {"a": {"mean": 4, "spread": 1}, "b": {"mean": 3, "spread": 1}}, "adversarial": {"verdict": "survive", "killerRisks": []}},
            {"id": "o2", "name": "Opt Two", "lens": "l2", "thesis": "t2", "timeToRevenue": "months",
             "scores": {"a": {"mean": 2, "spread": 1}, "b": {"mean": 2, "spread": 1}}, "adversarial": {"verdict": "wounded", "killerRisks": ["r"]}},
        ],
        "recommendation": {"optionId": "o1", "rationale": "r", "grafts": [], "confidence": "HIGH"},
        "killCriteria": ["k"],
    }
    work = pathlib.Path(tempfile.mkdtemp())
    (work / "d.json").write_text(json.dumps(minimal))
    r, work2 = _render(work / "d.json")
    assert r.returncode == 0, r.stderr + r.stdout
    html = list(work2.glob("*.html"))[0].read_text()
    assert "Opt One" in html and "Opt Two" in html and "__DECISION_DATA__" not in html
