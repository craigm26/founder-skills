#!/usr/bin/env python3
"""Emit a market-map graph (nodes.json + flows.json) from a market-validation deck-data.json.

Usage: emit_market_map.py <deck-data.json> <out-dir>

Output contract (see references/market-map-schema.md):

  nodes.json = { "families": [{id,label,color}], "nodes": [{id,label,family,kind,...}] }
  flows.json = { "flows":    [{id,title,view,tags,summary,steps:[{from,to,label,...}]}] }

Mapping:
  families  = competitor tiers (from deck-data.categories) + "process" + "policy"
  nodes     = one "market" hub + one node per competitor (family = its tier) +
              optional process-step nodes (if deck-data has a `process.steps` block) +
              one node per material counter-risk (family "policy")
  flows     = "competitive-landscape" (fanout: market -> each competitor) always;
              "target-process" (sequence) only when explicit process steps are provided.

The shape is a generic families/nodes/flows graph: self-contained, referentially checked
before writing, and loadable into any compatible viewer or converter — see
references/sinks.md for wiring it into a destination.
"""
import json, re, sys, pathlib

TIER_COLORS = {"direct": "#1a1a1a", "adjacent": "#3f6f80", "counter": "#9a6312", "caution": "#a23b2e"}
FAM_COLORS = {"process": "#2f6b4f", "policy": "#7a7468"}


def slug(t, seen):
    s = re.sub(r"[^a-z0-9]+", "-", str(t).lower()).strip("-") or "n"
    base, i = s, 2
    while s in seen:
        s = "%s-%d" % (base, i); i += 1
    seen.add(s)
    return s


def main():
    if len(sys.argv) < 3:
        print("usage: emit_market_map.py <deck-data.json> <out-dir>", file=sys.stderr); sys.exit(2)
    data = json.loads(pathlib.Path(sys.argv[1]).read_text())
    out = pathlib.Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)

    cats = data.get("categories", [])
    cat_label = {c["key"]: c.get("label", c["key"]) for c in cats}
    product = data.get("meta", {}).get("title", "Market")

    # ---- families ----
    families = []
    for c in cats:
        families.append({"id": c["key"], "label": c.get("label", c["key"]),
                         "color": TIER_COLORS.get(c["key"], "#7a7468")})
    families.append({"id": "process", "label": "Target process", "color": FAM_COLORS["process"]})
    families.append({"id": "policy", "label": "Policy / risk", "color": FAM_COLORS["policy"]})

    # ---- nodes ----
    seen = set()
    nodes = []
    hub_id = slug("market-" + product, seen)
    nodes.append({"id": hub_id, "label": product, "family": "process", "kind": "surface"})

    # optional explicit process steps (Claude may add a `process: {steps:[{label}]}` block)
    step_ids = []
    for st in (data.get("process", {}) or {}).get("steps", []):
        sid = slug("step-" + st.get("label", "step"), seen)
        step_ids.append(sid)
        nodes.append({"id": sid, "label": st.get("label", "step"), "family": "process", "kind": "artifact"})

    # competitors -> one external node each, family = its tier
    comp_ids = []
    for c in data.get("competitors", []):
        cid = slug("co-" + c.get("name", "co"), seen)
        comp_ids.append((cid, c.get("category", "direct")))
        nodes.append({"id": cid, "label": c.get("name", "?"),
                      "family": c.get("category", "direct") if c.get("category") in cat_label else "direct",
                      "kind": "external"})

    # material risks -> policy nodes (short labels)
    for i, r in enumerate(data.get("counter", {}).get("risks", [])):
        title = re.sub(r"^[A-Z]\.\s*", "", r.get("title", "risk")).strip()
        label = (title[:46] + "…") if len(title) > 47 else title
        nodes.append({"id": slug("risk-" + title, seen), "label": label,
                      "family": "policy", "kind": "external"})

    node_ids = {n["id"] for n in nodes}

    # ---- flows ----
    flows = []
    # competitive-landscape: always (market hub -> each competitor)
    flows.append({
        "id": "competitive-landscape",
        "title": product + " — competitive landscape",
        "view": "fanout",
        "tags": ["market"],
        "summary": "Each mapped competitor positioned against the market, coloured by tier "
                   "(direct / adjacent / counter-model / cautionary).",
        "steps": [{"from": hub_id, "to": cid, "label": cat_label.get(cat, cat)} for cid, cat in comp_ids],
    })
    # target-process: only when explicit steps were supplied
    if step_ids:
        chain = [hub_id] + step_ids
        steps = [{"from": chain[i], "to": chain[i + 1], "label": "then", "status": "in-progress"}
                 for i in range(len(chain) - 1)]
        flows.insert(0, {
            "id": "target-process", "title": product + " — target process",
            "view": "sequence", "tags": ["process"],
            "summary": "The workflow this product targets, step by step.", "steps": steps,
        })

    # ---- validate referential integrity before writing ----
    for f in flows:
        for s in f["steps"]:
            assert s["from"] in node_ids and s["to"] in node_ids, \
                "flow %s references unknown node (%s->%s)" % (f["id"], s["from"], s["to"])

    (out / "nodes.json").write_text(json.dumps({"families": families, "nodes": nodes}, indent=2, ensure_ascii=False))
    (out / "flows.json").write_text(json.dumps({"flows": flows}, indent=2, ensure_ascii=False))
    print("nodes.json", len(nodes), "nodes,", len(families), "families")
    print("flows.json", len(flows), "flows")
    print("NOTE: shape-valid market map; see references/sinks.md for loading it into a viewer")


if __name__ == "__main__":
    main()
