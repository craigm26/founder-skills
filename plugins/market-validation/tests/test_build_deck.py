import subprocess, sys, pathlib, tempfile, shutil

ROOT = pathlib.Path(__file__).resolve().parents[1]
GOLDEN = ROOT / "references/example-shiftmate/deck-data.json"


def _build(data_path):
    work = pathlib.Path(tempfile.mkdtemp())
    shutil.copy(ROOT / "assets/deck.template.html", work / "deck.template.html")
    shutil.copy(ROOT / "assets/build_deck.py", work / "build_deck.py")
    r = subprocess.run([sys.executable, str(work / "build_deck.py"), str(data_path)],
                       cwd=work, capture_output=True, text=True)
    return r, work


def test_build_deck_injects_and_renders():
    r, work = _build(GOLDEN)
    assert r.returncode == 0, r.stderr + r.stdout
    htmls = list(work.glob("*.html"))
    assert htmls, "no html emitted"
    html = htmls[0].read_text()
    assert "__DECK_DATA__" not in html           # placeholder fully injected
    assert "wheniwork.com" in html              # golden data present
    assert html.count("<section") >= 6           # all sections rendered


def test_build_deck_handles_minimal_data():
    """A product with no sizing/funding/homeowner blocks must still render."""
    minimal = {
        "meta": {"title": "Tiny Test Market", "subtitle": "x", "date": "2026-06-02", "provenance": "test"},
        "verdict": {"headline": "h", "paras": ["p"], "confidence": [{"label": "x", "level": "HIGH"}]},
        "pain": {"intro": "i", "items": [{"point": "p", "quote": "q", "who": "w", "ref": 1}], "kicker": "k"},
        "categories": [{"key": "direct", "label": "Direct", "meaning": "m"}],
        "competitors": [{"name": "Acme", "category": "direct", "what": "x", "funding": "y", "ref": 1}],
        "competitorKicker": "ck",
        "wtp": {"intro": "i", "items": [{"point": "p", "detail": "d", "ref": 1}], "honest": "h"},
        "global": [{"region": "US", "text": "t", "refs": [1]}],
        "counter": {"intro": "i", "risks": [{"title": "t", "body": "b", "weak": False, "refs": [1]}], "gaps": ["g"]},
        "sources": [{"n": 1, "title": "T", "pub": "P", "date": "2026", "url": "https://example.com"}],
    }
    work = pathlib.Path(tempfile.mkdtemp())
    (work / "deck-data.json").write_text(__import__("json").dumps(minimal))
    r, work2 = _build(work / "deck-data.json")
    assert r.returncode == 0, r.stderr + r.stdout
    html = list(work2.glob("*.html"))[0].read_text()
    assert "__DECK_DATA__" not in html
    assert "example.com" in html
