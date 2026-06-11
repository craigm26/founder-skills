# {{product}} — Build & Integrate Brief

*Date: {{date}} · Source: the verified market-evidence pack ({{n_claims}} live-verified claims, {{n_competitors}} competitors)*

## Verdict recap
{{verdict}}

Confidence: {{confidence_line}}

## Recommended product & wedge
{{wedge}}

## Business-model caveat
What the evidence DOES prove vs. does NOT:
{{model_caveat}}

## The market map
- **Emitted now:** a market-map graph (`nodes.json` + `flows.json`) — the competitive landscape and
  target process as a small, referentially-checked graph (contract: `references/market-map-schema.md`).
- **Destination:** {{map_destination}}  <!-- where this map will live: repo docs/, a graph viewer, a platform — see references/sinks.md -->
- **Status:** {{map_status}}  <!-- always honest: "shape-valid; load into <sink> untested" unless you ran it -->

## Follow-on work — making the map one-click (spec stub)
The net-new integration work this run justifies (its own brainstorm → spec → build cycle):

- **Goal:** {{followon_goal}}
- **Shape:** an import path in the destination system that accepts `{ families, nodes, flows }`,
  validates against the schema, persists, and renders — so emitted maps load in one step instead of
  a manual file drop.
- **Acceptance:** round-trip — import the JSON → the destination renders the nodes + edges.
- **Out of scope for the skill:** the skill emits the JSON + this stub; building the import path is
  the follow-on project.
