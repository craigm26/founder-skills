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

## How it integrates with workflow-atlas (workflow-atlas)
- **Surface:** {{platatlas_surface}}  <!-- agent? atlas? console feature? -->
- **Emitted now:** a market-map atlas (`nodes.json` + `flows.json`) for `docs/workflows/`. Status:
  **{{atlas_status}}** (see references/workflow-atlas-schema.md — shape-valid; end-to-end load may be untested).

## Project 2 — new workflow-atlas feature (spec stub)
The net-new platform work this run justifies (its own brainstorm → spec → build cycle):

- **Goal:** {{project2_goal}}
- **Endpoint:** `POST /api/orgs/:slug/atlases/import` — accept `{ families, nodes, flows }`; validate against
  the Rust/TS serde schema; upsert into D1 `atlases`/`nodes`/`flows`; return atlas id + 201.
- **Auth:** reuse `requireEntitledMember` (membership + entitlement); **audit** action `atlas.import`.
- **Why net-new:** today there is no write API for atlases/nodes/flows (only `POST /api/traces`); this makes
  emitted evidence-map atlases one-click instead of a manual file drop.
- **Acceptance:** round-trip — import JSON → `GET /api/orgs/:slug/atlases/:id/graph` renders the nodes+edges.
- **Out of scope for the skill:** the skill emits the JSON + this stub; building the endpoint is Project 2.
