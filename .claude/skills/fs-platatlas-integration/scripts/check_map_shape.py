#!/usr/bin/env python3
"""check_map_shape.py <map-dir> — validate emit_market_map.py output against the
constraints of workflow-atlas's schemas/nodes.schema.json + schemas/flows.schema.json
(id patterns, 14-kind node enum, hex colors, flow view enum, step from/to/label).

Dependency-free (stdlib only; no jsonschema). Exit 0 = shape-valid, 1 = violations.
The enum/pattern values below were copied from the workflow-atlas schemas on
2026-07-02 — if this script and the schemas disagree, the schemas win; re-copy.
"""
import json, re, sys, pathlib

VALID_KINDS = {
    "flutter-app", "service", "cloud-function", "firestore", "external-api",
    "cli", "mcp-server", "gateway", "pendant", "user", "artifact", "surface",
    "milestone", "external",
}
VALID_VIEWS = {"sequence", "lifecycle", "fanout", "timeline"}
FAM_ID = re.compile(r"^[a-z0-9][a-z0-9.-]*$")
NODE_ID = re.compile(r"^[a-z0-9][a-z0-9.:-]*$")
HEX6 = re.compile(r"^#[0-9a-fA-F]{6}$")


def main():
    if len(sys.argv) != 2:
        print("usage: check_map_shape.py <dir-with-nodes.json+flows.json>", file=sys.stderr)
        sys.exit(2)
    d = pathlib.Path(sys.argv[1])
    nodes = json.loads((d / "nodes.json").read_text())
    flows = json.loads((d / "flows.json").read_text())
    errs = []

    for fam in nodes.get("families", []):
        if not FAM_ID.match(fam.get("id", "")):
            errs.append("family id %r fails pattern" % fam.get("id"))
        if "label" not in fam:
            errs.append("family %r missing label" % fam.get("id"))
        if "color" in fam and not HEX6.match(fam["color"]):
            errs.append("family %r color %r not #RRGGBB" % (fam.get("id"), fam["color"]))

    node_ids = set()
    for n in nodes.get("nodes", []):
        node_ids.add(n.get("id"))
        if not NODE_ID.match(n.get("id", "")):
            errs.append("node id %r fails pattern" % n.get("id"))
        if "label" not in n:
            errs.append("node %r missing label" % n.get("id"))
        if n.get("kind") and n["kind"] not in VALID_KINDS:
            errs.append("node %r kind %r outside the 14-kind enum (Rust loader rejects)" % (n.get("id"), n["kind"]))

    for f in flows.get("flows", []):
        if not FAM_ID.match(f.get("id", "")):
            errs.append("flow id %r fails pattern" % f.get("id"))
        for req in ("id", "title", "steps"):
            if req not in f:
                errs.append("flow %r missing %r" % (f.get("id"), req))
        if f.get("view") is not None and f["view"] not in VALID_VIEWS:
            errs.append("flow %r view %r invalid" % (f.get("id"), f.get("view")))
        for s in f.get("steps", []):
            for req in ("from", "to", "label"):
                if req not in s:
                    errs.append("flow %r step missing %r" % (f.get("id"), req))
            for end in ("from", "to"):
                if s.get(end) not in node_ids:
                    errs.append("flow %r step references unknown node %r" % (f.get("id"), s.get(end)))

    if errs:
        print("SHAPE VIOLATIONS (%d):" % len(errs))
        for e in errs:
            print(" -", e)
        sys.exit(1)
    print("shape-valid: %d nodes, %d families, %d flows (constraints of nodes/flows schemas, copied 2026-07-02)"
          % (len(nodes.get("nodes", [])), len(nodes.get("families", [])), len(flows.get("flows", []))))


if __name__ == "__main__":
    main()
