# Market-map graph contract (for `emit_market_map.py`)

The market map is the structural artifact of a validation run: the competitive landscape and
(optionally) the target process, expressed as a small graph of **nodes** grouped into **families**
and connected by **flows**. It is two self-contained JSON files; the emitter checks referential
integrity (every flow step references an emitted node) before writing.

## File shapes (the emitter's output contract)

`nodes.json`:
```json
{
  "families": [ { "id": "str", "label": "str", "color": "#hex (optional)" } ],
  "nodes": [ { "id": "str", "label": "str", "family": "family-id",
              "kind": "service|artifact|cli|user|external|gateway|surface|milestone|...",
              "paths": ["glob/** (optional)"], "parent": "node-id (optional)", "expands": ["node-id (optional)"] } ]
}
```
`flows.json`:
```json
{
  "flows": [ { "id": "str", "title": "str",
               "view": "sequence|lifecycle|fanout|timeline",
               "tags": ["str"], "summary": "str (optional)",
               "steps": [ { "from": "node-id", "to": "node-id", "label": "str",
                            "detail": "str?", "status": "done|in-progress|planned?",
                            "date": "YYYY-MM-DD?", "milestone": "id?", "link": "url?" } ] } ]
}
```
Every flow step `from`/`to` MUST reference an emitted node `id`. `emit_market_map.py` asserts this
before writing.

## Market-map mapping

- **families** = competitor tiers (`direct`/`adjacent`/`counter`/`caution`, from `deck-data.categories`) + `process` + `policy`.
- **nodes** = one `market` hub (`surface`) + one `external` node per competitor (family = its tier) + optional
  `artifact` process-step nodes (only if `deck-data` carries a `process.steps` block) + one `external` node
  per material counter-risk (family `policy`).
- **flows** = `competitive-landscape` (`fanout`: hub → each competitor) always; `target-process` (`sequence`)
  only when explicit process steps are supplied.

## Loading the map somewhere

Loading the map into a specific viewer or system is sink-specific — see `sinks.md` for generic
options (commit-and-render, DOT/Mermaid conversion) and a worked third-party example. Keep claims
honest: the emitter guarantees the *shape*; whether a given consumer loads and renders it is the
sink's job to verify.
