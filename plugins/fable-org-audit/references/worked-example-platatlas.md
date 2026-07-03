# Worked example — the PlatAtlas probe set

The platform this skill was built against. Org names are fictionalized (`acme-fields` stands in
for a real customer org). Use this as the template for your own platform's dimension→endpoint
map: each dimension below shows the endpoints probed, the checks, and the grading thresholds.

Endpoint map live-verified **2026-07-02** (unauthenticated route probes against the production
worker — see "Re-verifying this map" at the bottom). Endpoint maps drift; re-verify before
trusting this one.

## Dimension 1 / Trace ingest

```
GET /api/orgs/<slug>/actions                (first page — the verified-action ledger)
GET /api/orgs/<slug>/intelligence/summary   (event counts + verification rates)
GET /api/orgs/<slug>/api-keys               (ingest-key inventory, metadata only)
GET /api/key/whoami                         (with the org's ingest key, if held)
```
Check: traces present (how many last 7 days)? verification verdict `verified` on recent traces
(unsigned = device not using the signing protocol)? most recent trace < 48h (silent ingest
failure if older)? does `/api/key/whoami` return a valid ingest-key identity (live write key
configured)? does `/api-keys` show a live key at all (key minted + zero traces = the silent
misconfiguration signature)?

Operators with platform-org admin also get the cross-org view: `GET /api/admin/ingest-health`
surfaces every org matching that key-minted/zero-traces signature in one call.

Grade Healthy: traces exist, most recent < 48h, ≥ 80% verified. Degraded: stale (2–7 days) or
< 80% verified. Broken: no traces or most recent > 7 days. Not configured: zero events and no
ingest key.

## Dimension 2 / Actor graph

```
GET /api/orgs/<slug>/atlases
GET /api/orgs/<slug>/atlases/<atlas_id>/graph
GET /api/orgs/<slug>/robots                 (the actor inventory)
```
Check: actors present (nodes/edges counts)? trust coverage > 50% (from
`/intelligence/summary`)? isolated actors? growing week-over-week or static?

Healthy: > 5 actors, > 10 edges, trust coverage > 50%. Degraded: < 5 edges or coverage < 50%.
Broken: graph empty despite traces existing. Not configured: no atlases provisioned.

## Dimension 3 / Work program

```
GET /api/orgs/<slug>/progress
```
Check: `published: true`? `generated_at` < 24h? `status.now[]` non-empty? hypotheses present —
any non-unproven? `ship_log` activity in the last 48h?

Healthy: published, fresh, now[] populated, ≥ 1 hypothesis. Degraded: stale (1–7 days) or now[]
empty. Broken: `published: false`. Not configured: endpoint 404s.

## Dimension 4 / GIS / field

```
GET /api/orgs/<slug>/robots-geo
GET /api/orgs/<slug>/plat                   (parcel/field boundary layers)
```
Check: published? `sites[]` non-empty with declared (not illustrative) coordinates? `robots[]`
listed with site assignments? `zones[]` with real geometry? `viewpoints[]` declared? plat
layers present and declared rather than illustrative?

Healthy: published, ≥ 1 declared site, ≥ 1 robot assigned. Degraded: all coordinates
illustrative, or no zones. Broken: `published: false`. Not configured: endpoint 404s.

## Dimension 5 / Hypotheses

```
GET /api/orgs/<slug>/progress → hypotheses[]   (the published board)
GET /api/orgs/<slug>/hypotheses                (the live plat: thesis + evidence resolution)
```
(plus the org's hypotheses seed file if accessible.)

Check: how many? status distribution (proven / partial / unproven / disproven)? every hypothesis
has a `next_experiment`? board freshness? disproven hypotheses acknowledged or abandoned?

Healthy: ≥ 3 hypotheses, ≥ 1 non-unproven, all have next_experiment. Degraded: all unproven or
next_experiment missing. Broken: board empty though the org has been active > 2 weeks.
Not configured: no seed file and no board entries.

## Dimension 6 / Billing

```
GET /api/orgs/<slug>/billing   (or infer from entitlement behaviour)
GET /api/orgs/<slug>/cost      (run-cost estimate vs declared budget)
```
Check: plan `active` or `trialing`? days remaining if trialing? `billing_exempt` (platform/demo
orgs)? hitting entitlement gates (402s)? cost estimate tracked against a set budget, or budget
never declared?

Healthy: active, or trialing > 7 days remaining, or exempt. Degraded: trialing ≤ 7 days
(approaching lockout), or cost estimate over budget. Broken: trial_expired or canceled (org
locked out at 402). Not configured: never provisioned through billing.

## Dimension 7 / Intelligence

```
GET /api/orgs/<slug>/intelligence/summary
GET /api/orgs/<slug>/intelligence/by-actor
GET /api/orgs/<slug>/pulse                  (the composed daily brief — one-call rollup)
GET /api/orgs/<slug>/loadout                (per-actor observed-vs-declared config)
```
Check: `error_rate` < 10%? `by_source` / `by_actor_type` populated? `trust_coverage` a real
number? frame outcomes tracked? pulse fields resolving (each is `{value, source, as_of}` or
null — a null field points at the sub-surface that failed)? loadout bloat flags — actors
carrying declared tools/plugins their traces never show them using (token waste), or using
tools they never declared (drift)?

Healthy: error_rate < 10%, all buckets populated, no undeclared-usage loadout flags. Degraded:
10–30% error rate, some metrics empty, or loadout bloat flagged. Broken: > 30% or endpoint
errors. Not configured: no traces to compute from.

## Dimension 8 / Robots (edge devices)

```
GET /api/orgs/<slug>/robots-geo → robots[]    cross-referenced with ingest traces
GET /api/orgs/<slug>/robots                   (registry identifiers + lifecycle state)
```
Check: robots declared with registry identifiers (RRNs)? those identifiers appearing in ingest
traces with verified signatures? mission state tracked? is the device gateway (robot-md) running
— a recent gateway timestamp on traces?

Healthy: ≥ 1 robot with verified signed ingest in last 48h, mission state tracked. Degraded:
robot declared but ingest stale/unverified. Broken: no robots, or all traces unverified.
Not configured: no robots declared, no signed ingest at all.

## Cross-cutting probes

Not graded as their own dimension, but worth one call each on platforms that have them:

```
GET /api/orgs/<slug>/grants           (federation: who may read what slice of this org, until when)
GET /api/admin/org-collisions         (operator-only: duplicate-org detector)
GET /api/admin/ingest-health          (operator-only: cross-org silent-misconfig sweep)
```

A stale or surprising grant list is an access-hygiene finding; fold it into whichever
dimension the granted slice belongs to.

## Output layout from real runs

```
~/.claude/audits/
  org-platatlas-2026-06-11.md      ← the platform's own org, audited point-in-time
  org-platatlas-memory.md
  org-acme-fields-2026-06-15.md    ← customer org audited before a demo
  org-acme-fields-memory.md
```

## Re-verifying this map

Route existence can be checked without credentials — probe a garbage path first as the
control (must 404), then each endpoint (401 = exists behind auth):

```
curl -s -o /dev/null -w "%{http_code}\n" https://<platform>/api/orgs/<slug>/zzz-garbage-control
curl -s -o /dev/null -w "%{http_code}\n" https://<platform>/api/orgs/<slug>/pulse
```

Read the codes carefully — three classes matter beyond 401/404:

- **405** = the path exists but not for GET (on PlatAtlas, `/usage` is POST-only ingest and
  the org-scoped `/traces` is a DELETE purge — neither is a read anymore).
- **Uniform-404 surfaces**: some member-gated reads deliberately return 404 to non-members
  to avoid an existence oracle (on PlatAtlas: `/audit-log`, `/status`, `/evidence/*`,
  per-trace `/traces/<id>/frames`). An unauthenticated 404 there is NOT proof of absence —
  confirm against the router source or an authenticated call.
- **200 unauthenticated** = a public read (e.g. `/atlases` list) — fine, but note it.

Drift log (what changed since the 2026-06 snapshot): `GET /usage` and `GET /traces` are gone
as reads (405 — write-only verbs remain); bare `GET /graph` → `/atlases/<id>/graph`; bare
`GET /intelligence` → `/intelligence/summary` + `/intelligence/by-actor`. Added since:
`/pulse`, `/loadout`, `/cost`, `/hypotheses`, `/actions`, `/robots`, `/api-keys`, `/plat`,
`/grants`, and the operator-only `/api/admin/*` pair.

## Porting notes

- The dimension set follows the platform's product surface — yours will differ. Keep eight as a
  target breadth; grade gaps ⚫ by design rather than shrinking the audit.
- Thresholds (48h freshness, 80% verified, > 5 actors) were tuned on live orgs; start with these
  and adjust to your data volumes.
- Endpoint maps are point-in-time snapshots of a moving surface — this one drifted in three
  weeks. Re-run the probe sweep above before every audit season.
- The memory loop is platform-independent — it's what makes the weekly audit get cheaper and
  sharper over time.
