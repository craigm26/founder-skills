# workflow-atlas data model (for `emit_atlas.py`)

Mapped from `~/workflow-atlas` this session (proxy-worker D1 migrations + `crates/core/src/types`)
and confirmed against the repo's own `docs/examples/workflow-atlas/{nodes,flows}.json`.

## What an atlas is

workflow-atlas is **operational cognition mapping**: it documents agent/team workflows as a graph of
**nodes** (services, artifacts, CLIs, external APIs, users…) connected by **flows** (sequences of steps).
It is *read-rich, write-poor*: atlases are authored as JSON files in a consumer repo's `docs/workflows/`
and rendered by the console. There is **no HTTP API to create atlases/nodes/flows** (D1 tables exist; the
write path is unbuilt). Only `POST /api/traces` ingestion is live. So a market map is loaded as files.

## File shapes (the emitter's output contract)

`nodes.json`:
```json
{
  "families": [ { "id": "str", "label": "str", "color": "#hex (optional)" } ],
  "nodes": [ { "id": "str", "label": "str", "family": "family-id",
              "kind": "service|artifact|cli|user|external|mcp-server|gateway|surface|milestone|...",
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
Every flow step `from`/`to` MUST reference an emitted node `id`. `emit_atlas.py` asserts this before writing.

## Market-map mapping (spec §6)

- **families** = competitor tiers (`direct`/`adjacent`/`counter`/`caution`, from `deck-data.categories`) + `process` + `policy`.
- **nodes** = one `market` hub (`surface`) + one `external` node per competitor (family = its tier) + optional
  `artifact` process-step nodes (only if `deck-data` carries a `process.steps` block) + one `external` node
  per material counter-risk (family `policy`).
- **flows** = `competitive-landscape` (`fanout`: hub → each competitor) always; `target-process` (`sequence`)
  only when explicit process steps are supplied.

## Load path — UNPROVEN (spec R3, Task 5 gate)

Two things must hold; only the first is verified:

- **(a) Shape — VERIFIED.** Emitted `nodes.json`/`flows.json` keys are a strict subset of the repo's example
  files, so they match the parser's expected format.
- **(b) End-to-end load + render — UNTESTED.** Nobody has run: register an atlas row (console/CLI) → drop the
  JSON at `<repo>/docs/workflows/` → plugin `refresh` → `GET /api/orgs/:slug/atlases/:id/graph` renders. There
  was no running instance to test against this session, and standing up the runtime worker
  (`wrangler dev --config wrangler.runtime.toml` + wasm build + D1/R2 + a registered atlas) was out of scope.

**Therefore: describe the emitter's output as "shape-valid, load-untested." Do NOT claim it "works today."**
Proving (b) — and adding a one-click import endpoint so it's not a manual file drop — is **Project 2**.
