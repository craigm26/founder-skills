# Plan template — cross-repo ecosystem program

Copy this skeleton into the plan file. Fill from the verified facts, not the agent assertions.

```markdown
# Plan: <thread the lesson through the ecosystem> (<invariant>-native), with <consumers> roadmap

## Context
<The anchoring lesson + root cause (link the LESSONS_*.md). Why now. The thesis in one line.>
**Operator decisions (locked):** <the answers from AskUserQuestion — depth, hard-vs-easy path,
in-scope-vs-separate, definition of done.>

## Verified facts this plan rests on (cross-checked against the code)
- <each load-bearing fact you CONFIRMED with a read-only check — especially the ones agents got wrong.
  Note the #1 risk surfaced here.>

## Workstream A — <in-scope core #1> (deep)
Repo: <path>. Idiom: <existing pattern to follow>; reuse <existing helper>.
**A0. Foundations (no hardware; unblocks all):** <pure refactors + schema/contract additions + the
  cross-cutting helper everything needs.>
**A1..An.** <each capability: new files, flags, algorithm, reuse, write-back, tests. Map each to a lesson.>
**Shared contract (must match Workstream B exactly):** <the exact interface names/arg schemas at the seam.>

## Workstream B — <in-scope core #2 + entangled migration if in scope> (deep)
Repo: <path>. Build least-breaking first, behind flags.
**B1..Bn.** <gating/scope/tier, invariant enforcement (identity binding, manifest-driven policy), the
  migration with an accept-both → cutover path, audit + safety coverage.>
**Deploy note:** <how the built artifact reaches the running service (venv/path/restart); back up configs.>

## Workstream C..E — <downstream layers> (roadmap-depth: seams + phased sequence)
<For consumer/enterprise apps: P1/P2/P3 phases naming the real files/endpoints/migrations and the
  activation seams already present. Not full designs.>

## Cross-cutting — <invariant + operational glue>
<The identity/protocol invariant that touches every layer. AND the operational loop that's easy to forget
  and fails closed if omitted (e.g. re-sign+redeploy a signed artifact after every write; a correlation-id
  threaded across planes). State the sequencing decision.>

## <Definition of done> — the proof
<A concrete, re-runnable, end-to-end demonstration with a per-step wall-clock/effort budget. What's already
  proven vs what must be productized. How success is measured (run it twice, both pass).>

## Build sequence (least-breaking first)
1. <foundations: no hardware, no migration, behind flags>
2. <the risky integration — validate the #1 risk HERE>
3..n. <capabilities, then migration cutover, then surfaces, then roadmap phases>

## Verification
- Hardware/IO-free unit tests: <list, mirroring existing test patterns>.
- In-the-loop checks: <the real-hardware/real-runtime validations, incl. the #1 risk and the operational
  loop round-trip>.
- Cutover gates: <accept-both-passing before flipping enforce; etc.>

## Open questions / risks to resolve early
1..n. <assumptions to confirm, ownership seams to get sign-off on, migrations in flight to avoid colliding>
```

## Sizing guidance
- **Deep workstream** = execution-depth: exact files, functions, flags, algorithm, write-back, tests.
- **Roadmap workstream** = seams + phased sequence: name the files/endpoints and the activation points,
  defer the full design.
- Keep the whole plan scannable. One recommended approach per decision. No menus.
