import json, subprocess, sys, pathlib, tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
GOLDEN = ROOT / "references/example-shiftmate/deck-data.json"
EMIT = ROOT / "assets/market-map/emit_market_map.py"


def _run(data_path):
    out = pathlib.Path(tempfile.mkdtemp())
    r = subprocess.run([sys.executable, str(EMIT), str(data_path), str(out)],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stderr + r.stdout
    nodes = json.loads((out / "nodes.json").read_text())
    flows = json.loads((out / "flows.json").read_text())
    return nodes, flows


def test_families_cover_tiers_and_process_policy():
    nodes, _ = _run(GOLDEN)
    fam = {f["id"] for f in nodes["families"]}
    assert {"direct", "adjacent", "counter", "caution", "process", "policy"} <= fam
    for f in nodes["families"]:
        assert f["id"] and f["label"]


def test_every_competitor_becomes_a_node():
    nodes, _ = _run(GOLDEN)
    data = json.loads(GOLDEN.read_text())
    tiers = {"direct", "adjacent", "counter", "caution"}
    comp_nodes = [n for n in nodes["nodes"] if n["family"] in tiers]
    assert len(comp_nodes) == len(data["competitors"])
    for n in nodes["nodes"]:
        assert n["id"] and n["label"] and n["kind"]


def test_flows_reference_real_nodes_and_landscape_exists():
    nodes, flows = _run(GOLDEN)
    ids = {n["id"] for n in nodes["nodes"]}
    assert any(f["id"] == "competitive-landscape" for f in flows["flows"])
    for f in flows["flows"]:
        assert f["view"] in {"sequence", "lifecycle", "fanout", "timeline"}
        for s in f["steps"]:
            assert s["from"] in ids and s["to"] in ids


def test_explicit_process_block_yields_target_process_flow():
    data = json.loads(GOLDEN.read_text())
    data["process"] = {"steps": [{"label": "Lead"}, {"label": "File"}, {"label": "Reimburse"}]}
    work = pathlib.Path(tempfile.mkdtemp())
    (work / "d.json").write_text(json.dumps(data))
    nodes, flows = _run(work / "d.json")
    ids = {n["id"] for n in nodes["nodes"]}
    tp = [f for f in flows["flows"] if f["id"] == "target-process"]
    assert tp and tp[0]["view"] == "sequence"
    for s in tp[0]["steps"]:
        assert s["from"] in ids and s["to"] in ids
