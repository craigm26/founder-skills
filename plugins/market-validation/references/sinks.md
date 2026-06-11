# Market-map sinks — where the emitted graph can go

`emit_market_map.py` produces two self-contained JSON files (`nodes.json` + `flows.json`,
contract in `market-map-schema.md`). The emitter guarantees the shape and referential
integrity; **loading the map into a destination is your job, and each sink below tells you
how honest you can be about it**.

## Sink 1 — commit it to the repo (zero infrastructure)

Drop the files next to the evidence pack, e.g. `docs/market-map/{nodes,flows}.json`, and
commit. The map is then a durable, diffable artifact of the validation run — useful even if
nothing ever renders it, because the families/tiers and flow steps are readable as plain JSON.

## Sink 2 — convert to DOT or Mermaid (render anywhere)

The graph maps directly onto standard formats: families → subgraphs/classes, nodes → vertices,
flow steps → edges. A minimal DOT converter:

```python
#!/usr/bin/env python3
"""market_map_to_dot.py <map-dir> — print Graphviz DOT to stdout."""
import json, pathlib, sys

d = pathlib.Path(sys.argv[1])
nodes = json.loads((d / "nodes.json").read_text())
flows = json.loads((d / "flows.json").read_text())
fam_color = {f["id"]: f.get("color", "#7a7468") for f in nodes["families"]}

print("digraph market_map {")
print('  node [shape=box, style=filled, fontcolor=white];')
for n in nodes["nodes"]:
    print('  "%s" [label="%s", fillcolor="%s"];' % (n["id"], n["label"], fam_color.get(n["family"], "#7a7468")))
for f in flows["flows"]:
    for s in f["steps"]:
        print('  "%s" -> "%s" [label="%s"];' % (s["from"], s["to"], s.get("label", "")))
print("}")
```

Then `python3 market_map_to_dot.py market-map/ | dot -Tsvg > market-map.svg`, or paste the
equivalent edges into a Mermaid `graph LR` block for GitHub-rendered markdown.

## Sink 3 — a graph/workflow platform (worked example: workflow-atlas)

[workflow-atlas](https://github.com/craigm26) (the engine behind PlatAtlas) consumes exactly
this families/nodes/flows shape from a repo's `docs/workflows/` directory. To use it as a sink:
drop `nodes.json` + `flows.json` there, register the atlas in the console, and refresh.

**Honesty caveat (applies to any third-party sink):** the emitted files are *shape-valid*
against that parser's documented format, but unless you have personally run the end-to-end
load-and-render path, describe the integration as **"shape-valid, load-untested"** — never
"works today". If your platform lacks a write API (workflow-atlas's atlas write path is
file-drop only), a one-click import endpoint is its own project, not this skill's output.

## Writing your own sink

Anything that can read two JSON files can be a sink: a Notion or Airtable importer, a D3 page,
an internal dashboard. Keep two rules: (1) preserve the family/tier coloring — the tiers
(direct / adjacent / counter / caution) carry the analytical content; (2) verify your loader
against `market-map-schema.md` and the referential-integrity guarantee rather than against one
sample output.
