---
name: fs-platatlas-integration
description: >-
  Map and maintain the founder-skills <-> PlatAtlas integration surface: the
  fable-org-audit endpoint map (with its known drift against the live worker),
  the market-validation market-map sink (nodes.json + flows.json into
  workflow-atlas, shape-valid but load-untested), adoption guidance for
  PlatAtlas rail agent seats, and the documented-not-executed mirror plan into
  workflow-atlas's own plugin convention. Use when a maintainer says "how does
  founder-skills connect to PlatAtlas", "is the org-audit endpoint map still
  current", "prove the market-map sink", "load the market map into PlatAtlas",
  "can the rail agents use these skills", "mirror founder-skills into
  workflow-atlas", or "what drifted on the PlatAtlas side".
---

# fs-platatlas-integration — the founder-skills <-> PlatAtlas surface

Announce at start: "Loading fs-platatlas-integration — the PlatAtlas surface map, adoption path, mirror plan, and sink proving protocol."

Scope fixed by operator decision 2026-07-02: four parts — (1) surface map, (2) rail-seat
adoption, (3) mirror plan (documented, NOT executed), (4) sink proving protocol (gated).
All facts below were verified 2026-07-02 unless labeled otherwise.

## Terms (read once)

| Term | Meaning |
|---|---|
| PlatAtlas | GitHub-org intelligence platform, live at `platatlas.com` (Worker + D1 + R2 + Pages) |
| workflow-atlas | The PlatAtlas dev monorepo. Environment-specific checkout: `/home/craigm26/projects/PlatAtlas/workflow-atlas` |
| rail | Separate monorepo; **its `main` is the production source for the live worker since the 2026-07-02 cutover** (the workflow-atlas `proxy-worker/` and its CLAUDE.md deploy notes predate this). Environment-specific checkout: `/home/craigm26/projects/rail` (worker at `apps/platatlas-worker/`) |
| atlas | An org's workflow graph: `nodes.json` (+ `edges.json`, `derived_edges.json`, optional `flows.json`) under a repo's `docs/workflows/` |
| market-map sink | market-validation's emitted `nodes.json` + `flows.json` dropped into a destination that renders them; PlatAtlas is the worked sink (`plugins/market-validation/references/sinks.md`, Sink 3) |
| Loadout (#137) | PlatAtlas per-actor declared-vs-observed inventory of plugins/MCP/skills/tools, with bloat flags (declared, never used) |
| rail seats | The data-driven agent roster in rail's PlatChat (`@claude-fable`, `@sonnet`, plus local gemma/qwen scouts) |

## When NOT to use this skill

- Repo orientation, group map, which skill covers what → **fs-orientation**.
- Actually executing the sink proving run as a campaign step (it is gated there) → **fs-flagship-chain-campaign**.
- Classifying/gating any change this skill motivates (endpoint-map update, mirror execution) → **fs-change-control**. Nothing here authorizes skipping the spec → plan → commit pipeline.
- The recurring drift sweep across ALL volatile facts (model IDs, URLs, this map included) → **fs-freshness-watch**.
- Editing or authoring skills that come out of this work → **fs-skill-authoring** / **fs-skill-style-guide**.

## Part 1 — Surface map

Two touchpoints exist between the repos. Nothing else in founder-skills references PlatAtlas
as a live system.

### 1a. fable-org-audit endpoint map (drifted)

`plugins/fable-org-audit/references/worked-example-platatlas.md` maps 8 audit dimensions to
worker endpoints: `/api/orgs/<slug>/usage`, `/traces`, `/graph`, `/intelligence`, `/progress`,
`/robots-geo`, `/billing`, `/api/key/whoami`, each with numeric grading thresholds.

**Drift, live-verified 2026-07-02** (unauthenticated probe: 401 = route exists behind auth,
404 = absent — control probe on a garbage path returned 404). The live worker now also serves,
none of which the worked example mentions:

| Endpoint | Live status | What it is |
|---|---|---|
| `GET /api/orgs/:slug/pulse` | 401 (exists) | Org Pulse rollup (rail `apps/platatlas-worker/src/routes/pulse.ts`) |
| `GET /api/orgs/:slug/grants` | 401 (exists) | Cross-org federation grants read path |
| `GET /api/admin/ingest-health` | 401 (exists) | Cross-org operator ingest-health panel |
| `GET /api/admin/org-collisions` | 401 (exists) | Duplicate-org detector |
| `GET/POST /api/orgs/:slug/loadout`, `/actors/:actor_id/loadout` (+`/declare`, `/reoptimize`) | in rail main source | Per-actor Loadout (#137) — see Part 2 |

Impact: an org audit run from the worked example under-probes the live surface (Pulse and
ingest-health are directly audit-relevant to Dimension 1/ingest and Dimension 7/intelligence).
Updating the worked example is a normal change — route it through **fs-change-control**.
The worked example itself is deliberately platform-generic ("map each dimension to YOUR
platform"); the drift matters when the audit target is PlatAtlas itself.

Re-verify (copy-paste):

```bash
# Route existence on the live worker (401=exists, 404=absent):
for p in pulse grants; do printf "%s: " $p; curl -s -o /dev/null -w "%{http_code}\n" \
  "https://platatlas.com/api/orgs/platatlas/$p"; done
curl -s -o /dev/null -w "ingest-health: %{http_code}\n" https://platatlas.com/api/admin/ingest-health
curl -s -o /dev/null -w "org-collisions: %{http_code}\n" https://platatlas.com/api/admin/org-collisions
curl -s -o /dev/null -w "control-404: %{http_code}\n" "https://platatlas.com/api/orgs/platatlas/nonexistent-zzz"
```

### 1b. market-map sink (format risk, mostly retired — one real gap remains)

`plugins/market-validation/assets/market-map/emit_market_map.py` emits `nodes.json`
(`{families,nodes}`) + `flows.json` (`{flows:[{id,title,view,tags,summary,steps}]}`).
`references/sinks.md` Sink 3 says: drop both into a repo's `docs/workflows/`, register the
atlas in the console, refresh — labeled **"shape-valid, load-untested"**.

The facts pack (2026-07-02) flagged a format-mismatch risk: workflow-atlas's own atlas uses
`edges.json`, not `flows.json`. **Inspection the same day narrows that risk:**

| Claim | Verified 2026-07-02 | Where |
|---|---|---|
| `flows.json` is a first-class optional companion format | YES — "Missing file = empty result, not an error" | workflow-atlas `crates/core/src/flow/loader.rs`; schema `schemas/flows.schema.json` |
| `edges.json` is likewise optional (missing = empty) | YES | `crates/core/src/atlas/edges.rs` (test `missing_file_returns_empty_edges`) — so the emitter emitting no edges.json is fine |
| The static web viewer fetches `flows.json` directly | YES (`.catch(() => ({flows:[]}))`) | `web/js/data.js` |
| Emitter output satisfies the schemas' constraints (id patterns, 14-kind node enum, hex colors, view enum, step from/to/label) | YES — sample run passed `scripts/check_map_shape.py` (this skill dir) | run it yourself, command below |
| The HOSTED org console renders a file-dropped map end-to-end | **NO — never run. This is the surviving gap.** | see Part 4 |

The surviving structural gap: the hosted path is **split**. Nodes/edges reach the hosted
console via `bin/atlas-onboard.mjs` (pulls per-repo `ATLAS.md`/`ROBOT.md` manifests → merges
into R2 META; it contains zero handling of flows), while flows reach it via a separate
operator-gated seeder `bin/seed-org-flows.mjs` (writes the D1 `flows` table, dry-run by
default). A naive "drop files into docs/workflows/" therefore feeds the local server and the
static viewer, but NOT the hosted console. `sinks.md`'s honesty caveat stands.

Re-verify (copy-paste; workflow-atlas checkout is environment-specific):

```bash
cd /home/craigm26/projects/PlatAtlas/workflow-atlas
head -1 crates/core/src/flow/loader.rs        # "Companion `flows.json` loader. Missing file = empty..."
ls schemas/ | grep -E 'nodes|flows|edges'      # nodes/flows/edges schemas all present
grep -ac flows bin/atlas-onboard.mjs           # 0 = onboard still ignores flows (-a: file trips grep's binary heuristic)
sed -n '10,13p' bin/seed-org-flows.mjs         # seeder usage line (D1 flows table, dry-run default)

# Emitter shape-check against the schemas' constraints (any deck-data.json):
python3 plugins/market-validation/assets/market-map/emit_market_map.py <deck-data.json> /tmp/mapout \
  && python3 .claude/skills/fs-platatlas-integration/scripts/check_map_shape.py /tmp/mapout
# (run from the founder-skills repo root for the two relative paths)
```

## Part 2 — Adoption: rail agent seats using founder-skills

**Current status (verified 2026-07-02): NOT adopted.** Neither rail nor workflow-atlas
references founder-skills anywhere load-bearing (only an unrelated copied strategy doc).
Everything below is the *candidate* path, not a description of running state.

The rail roster is data-driven (`apps/platchat-orchestrator/src/roster.ts`: scout /
supervisor / fable archetypes). Only seats that run **Claude Code sessions** can consume
these skills — local gemma/qwen scouts cannot (skills are Claude-Code-shaped prompts).

| Seat | Fit | Which skills |
|---|---|---|
| `@claude-fable` (frontier planner seat) | Good — matches the repo's Fable-plans-never-implements doctrine | fable-orchestrated-feature-dev, fable-repo-audit, fable-org-audit, fable-loop-design, ecosystem-planning |
| `@sonnet` (implementer seat) | Good for chain execution | market-validation, build-options, prd, tasks; session-start/effort for calibration |
| gemma/qwen scouts | No — not Claude Code | none |

Install (same as any user — the marketplace is live-publishing, so seats track master):

```bash
/plugin marketplace add craigm26/founder-skills
/plugin install fable-org-audit@founder-skills     # etc. per the seat table
```

**Loadout connection (#137).** Once a seat has skills installed, it should self-declare them
so PlatAtlas can diff declared-vs-observed and flag bloat. The mechanism exists and is in
rail main source (routes verified 2026-07-02: `POST /api/orgs/:slug/loadout/declare`,
per-actor `.../actors/:actor_id/loadout/declare` + `/reoptimize`):

```bash
# From the workflow-atlas checkout; auth = the org's ingest key (same credential
# as the trace uploader; server resolves the actor from the key):
node bin/declare-loadout.mjs --org <slug> --items-file loadout.json
```

This is the "skills-as-product" hook (operator beyond-SOTA decision #4): founder-skills
entries appearing in a seat's Loadout with observed-use evidence. **First declaration PROVEN
2026-07-02** for org `platatlas`: an ingest-scope key was minted via the admin console API
(`POST /api/orgs/:slug/api-keys`, session + `X-PlatAtlas-CSRF` from `GET /api/me`), stored at
`~/.platatlas-platatlas-ingest.key` (environment-specific), and `declare-loadout.mjs` declared
15 founder-skills items — the server auto-created actor
`act_90fdfaad-1d32-4afa-9b85-e11d5bebd31c` from the key subject, and the loadout index shows
declared 15 / observed 0 / bloat 15 (honest: the seat has pushed no traces yet, so every item
is correctly bloat-flagged until observed use arrives). Next milestone: observed>0 via the
seat's trace uploads.

## Part 3 — Mirror plan into workflow-atlas convention (documented, NOT executed)

Operator decision 2026-07-02: this is a follow-on plan only. Do NOT execute it from this
skill; execution requires a spec via **fs-change-control** (and a corresponding change in
the workflow-atlas repo, which has its own change discipline).

workflow-atlas uses a DIFFERENT plugin convention (verified 2026-07-02):
`plugin.json` (`{"name":"platatlas","version":"0.11.0",...,"commands":"commands/"}`) +
16 slash-command markdown files in `commands/` (`connect.md`, `init.md`, `refresh.md`, ...).
It has **no `.claude/skills/` and no `.claude/workflows/`** (`ls -d .claude` → not found).
Its command frontmatter differs from ours: `name: platatlas:<cmd>`, `description`, plus an
`arguments:` list with `required`/`flag` fields — richer than our two-field frontmatter.

The plan (checkbox form, for a future spec):

1. [ ] Pick the mirror set — candidates are the skills a PlatAtlas maintainer would invoke
   *inside* workflow-atlas: fable-org-audit, fable-repo-audit, tufte-viz-adjacent dataviz
   guidance. (workflow-atlas CLAUDE.md already routes to these via `~/.claude/skills/` —
   the mirror would make that routing repo-vendored instead of machine-dependent.)
2. [ ] Translation rule per skill: SKILL.md body → `commands/<name>.md` body; our
   `description` "Use when..." → their `description` triggers; any `AskUserQuestion` blocks
   and `Workflow({scriptPath})` references must be re-verified in their runner (their
   commands mostly wrap `bin/*.mjs` scripts — ours mostly don't; this is the hard part,
   not a rename).
3. [ ] Namespace: `platatlas:org-audit` etc.; bump their plugin.json version.
4. [ ] Decide sync direction: founder-skills stays canonical; the mirror is a generated
   copy with a provenance header, refreshed manually (no CI anywhere — standing rule).
5. [ ] Sanitization gate before anything lands in workflow-atlas: it is a different
   publication surface; re-apply the fs-doctrine-and-honesty checklist.

Open question (UNVERIFIED): whether their marketplace/plugin loader accepts a second
commands directory or a nested plugin — nobody has tried. Resolve during the spec, not here.

## Part 4 — Sink proving protocol (gated; current status: shape-valid, load-untested)

This is the end-to-end test that would retire the `sinks.md` honesty caveat. It is a
**gated step of fs-flagship-chain-campaign** — run it there, in order; this section is the
reference for what "proven" means.

Prerequisites (all must hold before starting):
- A market-validation run's real `deck-data.json` (not the synthetic sample).
- A live PlatAtlas org you may write to, with console access to see the result.
- Operator present for any `--write` step (hosted writes are operator-gated by the tools
  themselves: dry-run defaults in `connect.mjs` / `seed-org-flows.mjs`).
- `gh` (PAT: repo + read:org) and a logged-in `wrangler` on the machine (environment-specific).

Protocol — prove ONE path fully rather than three partially. Paths in ascending cost:

| Path | Steps | Proves |
|---|---|---|
| A. Static viewer (cheapest) | emit → shape-check → drop `nodes.json`+`flows.json` at a URL-fetchable base → open the workflow-atlas web viewer pointed at that base (`web/js/data.js` fetches `<base>/nodes.json` + `<base>/flows.json`) | files render as-is; flows draw |
| B. Local server | emit → shape-check → drop into a scratch repo's `docs/workflows/` (add a minimal `atlas.md`; `edges.json` may be absent) → run the workflow-atlas local server against it | the Rust loaders accept real emitter output |
| C. Hosted console (full claim) | emit → shape-check → nodes via the org's atlas path (note: hosted onboard reads `ATLAS.md` manifests, NOT raw JSON — expect to adapt) → flows via `bin/seed-org-flows.mjs --config ... --write` (operator runs the printed D1 commands) → console refresh → screenshot | "PlatAtlas renders an emitted market map" with zero asterisks |

Every path: 1. `emit_market_map.py <deck-data.json> <out-dir>` 2. `scripts/check_map_shape.py <out-dir>` (this skill dir) 3. load per path 4. render 5. record evidence
(command transcript + screenshot) in the campaign log, then update `sinks.md`'s caveat via
**fs-change-control** — the label only changes from "shape-valid, load-untested" to
"proven on path X, date Y" with evidence attached. Path C's nodes leg is expected to
surface work (the ATLAS.md-vs-JSON gap in Part 1b); if it does, that finding goes to
**fs-failure-archaeology**, not under the rug.

Status ledger (update in place):

| Date | Step | Result |
|---|---|---|
| 2026-06-11 | emit + referential-integrity assert | shape-valid (emitter self-check) |
| 2026-07-02 | emitter output vs workflow-atlas schema constraints | PASS on synthetic sample (`check_map_shape.py`) |
| 2026-07-02 | **Path C (hosted console) — PROVEN** on org `platatlas` with the real 2026-06-24 accountability-rail map (21 nodes / 6 families / 1 flow) | Nodes: registered as own atlas `92892cbc-c4f1-5b06-a849-791d80677dcc` (R2 META hand-PUT + non-destructive `[[atlases]]` append; backup kept). Flow `competitive-landscape` seeded via `bin/seed-org-flows.mjs --write` (dry-run inspected first). Hosted graph API: edges 25→40, 15 new `kind:step`; survey resolves `flow:competitive-landscape`. Screenshot NOT captured (no browser in the proving env) — graph DTO is the render evidence. Run log: PlatChat org platatlas `#general` thread `msg_01KWJH0JGC6YKJC121X392XA08`. |

**Findings from the proving run (2026-07-02):**
- The hosted graph endpoint serves the ORG-MERGED node pool for ANY atlas_id of the org
  (per-atlas ids scope ACCESS, not content) — both atlas ids returned the identical
  34-node / 11-family graph. Plan flows/nodes accordingly; a map atlas is not isolated in render.
- Auth for hosted verification: `~/.platatlas/auth.json` + the MCP cache both go stale; a
  session mints fine via `POST /auth/github/device-exchange` with the **gh CLI token**
  (`gh auth token`) — no interactive device flow needed while `gh` is logged in.
- Rollback (unused): `wrangler d1 execute platatlas --remote --command "DELETE FROM flows
  WHERE org_slug='platatlas' AND id='competitive-landscape'"`; descriptor backup at the
  proving session's scratchpad (`platatlas.toml.backup`).

## Provenance and maintenance

Sources: facts pack 2026-07-02; `plugins/fable-org-audit/references/worked-example-platatlas.md`;
`plugins/market-validation/references/sinks.md` + `assets/market-map/emit_market_map.py`;
read-only inspection of the workflow-atlas and rail checkouts (paths environment-specific).

One-line re-verification for everything volatile here:

```bash
# Live worker still serves the drifted endpoints (401=exists, 404=gone):
curl -s -o /dev/null -w "%{http_code}\n" https://platatlas.com/api/orgs/platatlas/pulse
# rail main still the worker source with pulse/grants/loadout routes (env-specific path):
grep -c "pulse\|:slug/grants\|loadout" /home/craigm26/projects/rail/apps/platatlas-worker/src/index.ts
# workflow-atlas convention unchanged (plugin.json commands + no .claude/skills):
cd /home/craigm26/projects/PlatAtlas/workflow-atlas && grep '"commands"' plugin.json && ls commands | wc -l && ls -d .claude 2>&1
# flows.json still first-class + onboard still flow-blind:
grep -l flows.json crates/core/src/flow/loader.rs; grep -ac flows bin/atlas-onboard.mjs
# Emitter output still shape-valid (from founder-skills root, with a deck-data.json):
python3 .claude/skills/fs-platatlas-integration/scripts/check_map_shape.py <emitted-map-dir>
# Rail seats still on the data-driven roster:
grep -n '"scout" | "supervisor" | "fable"' /home/craigm26/projects/rail/apps/platchat-orchestrator/src/roster.ts
# Adoption still not started:
grep -rl founder-skills /home/craigm26/projects/rail --include='*.ts' --include='*.json' | grep -v node_modules
```

Known drift risks: the rail cutover is one day old — deploy topology may move again;
the endpoint list grows monthly (route the map update through **fs-change-control**);
`check_map_shape.py` hardcodes schema constants copied 2026-07-02 (schemas win on conflict).
