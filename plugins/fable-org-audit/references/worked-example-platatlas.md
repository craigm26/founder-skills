# Worked example — the PlatAtlas probe set

The platform this skill was built against. Org names are fictionalized (`acme-fields` stands in
for a real customer org). Use this as the template for your own platform's dimension→endpoint
map: each dimension below shows the endpoints probed, the checks, and the grading thresholds.

## Dimension 1 / Trace ingest

```
GET /api/orgs/<slug>/usage
GET /api/orgs/<slug>/traces   (first page)
```
Check: traces present (how many last 7 days)? verification verdict `verified` on recent traces
(unsigned = device not using the signing protocol)? most recent trace < 48h (silent ingest
failure if older)? does `/api/key/whoami` return a valid ingest-key identity (live write key
configured)?

Grade Healthy: traces exist, most recent < 48h, ≥ 80% verified. Degraded: stale (2–7 days) or
< 80% verified. Broken: no traces or most recent > 7 days. Not configured: zero events and no
ingest key.

## Dimension 2 / Actor graph

```
GET /api/orgs/<slug>/graph
GET /api/orgs/<slug>/intelligence
```
Check: actors present (nodes/edges counts)? trust coverage > 50%? isolated actors? growing
week-over-week or static?

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
```
Check: published? `sites[]` non-empty with declared (not illustrative) coordinates? `robots[]`
listed with site assignments? `zones[]` with real geometry? `viewpoints[]` declared?

Healthy: published, ≥ 1 declared site, ≥ 1 robot assigned. Degraded: all coordinates
illustrative, or no zones. Broken: `published: false`. Not configured: endpoint 404s.

## Dimension 5 / Hypotheses

Read from `GET /api/orgs/<slug>/progress → hypotheses[]` (plus the org's hypotheses seed file
if accessible).

Check: how many? status distribution (proven / partial / unproven / disproven)? every hypothesis
has a `next_experiment`? board freshness? disproven hypotheses acknowledged or abandoned?

Healthy: ≥ 3 hypotheses, ≥ 1 non-unproven, all have next_experiment. Degraded: all unproven or
next_experiment missing. Broken: board empty though the org has been active > 2 weeks.
Not configured: no seed file and no board entries.

## Dimension 6 / Billing

```
GET /api/orgs/<slug>/billing   (or infer from entitlement behaviour)
```
Check: plan `active` or `trialing`? days remaining if trialing? `billing_exempt` (platform/demo
orgs)? hitting entitlement gates (402s)?

Healthy: active, or trialing > 7 days remaining, or exempt. Degraded: trialing ≤ 7 days
(approaching lockout). Broken: trial_expired or canceled (org locked out at 402).
Not configured: never provisioned through billing.

## Dimension 7 / Intelligence

```
GET /api/orgs/<slug>/intelligence
```
Check: `error_rate` < 10%? `by_source` / `by_actor_type` populated? `trust_coverage` a real
number? frame outcomes tracked?

Healthy: error_rate < 10%, all buckets populated. Degraded: 10–30% or some metrics empty.
Broken: > 30% or endpoint errors. Not configured: no traces to compute from.

## Dimension 8 / Robots (edge devices)

```
GET /api/orgs/<slug>/robots-geo → robots[]    cross-referenced with ingest traces
```
Check: robots declared with registry identifiers (RRNs)? those identifiers appearing in ingest
traces with verified signatures? mission state tracked? is the device gateway (robot-md) running
— a recent gateway timestamp on traces?

Healthy: ≥ 1 robot with verified signed ingest in last 48h, mission state tracked. Degraded:
robot declared but ingest stale/unverified. Broken: no robots, or all traces unverified.
Not configured: no robots declared, no signed ingest at all.

## Output layout from real runs

```
~/.claude/audits/
  org-platatlas-2026-06-11.md      ← the platform's own org, audited point-in-time
  org-platatlas-memory.md
  org-acme-fields-2026-06-15.md    ← customer org audited before a demo
  org-acme-fields-memory.md
```

## Porting notes

- The dimension set follows the platform's product surface — yours will differ. Keep eight as a
  target breadth; grade gaps ⚫ by design rather than shrinking the audit.
- Thresholds (48h freshness, 80% verified, > 5 actors) were tuned on live orgs; start with these
  and adjust to your data volumes.
- The memory loop is platform-independent — it's what makes the weekly audit get cheaper and
  sharper over time.
