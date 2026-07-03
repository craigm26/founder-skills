# Spec — Post-campaign follow-ons: measured costs, endpoint refresh, catalog sync (2026-07-02)

Status: approved by operator (2026-07-02, in-session: "Proceed with all" against the four
recommended next steps). Same-day companion to
`2026-07-02-flagship-campaign-execution.md`.

## Scope

1. **Measured-not-claimed cost figures** (research-frontier milestone #1, first win): replace
   estimated token-cost claims with measured figures from the 2026-07-02 proving runs, keeping
   full-fidelity estimates labeled as estimates:
   - market-validation: measured minimum run = 1,134,356 tokens / 30 agents / ~20 min
     (run `wf_8ea9a6d3-231`) — README, SKILL.md, site chip.
   - build-options: measured 3-lens run = 313,729 tokens / 9 agents / ~8 min
     (run `wf_58e1fc39-7fb`, first pass) — README, site chip.
2. **Version bumps for content-changed plugins**: market-validation 0.1.0→0.2.0,
   build-options 0.1.0→0.2.0 (their SKILL.md/assets changed in `2f16a61` without a bump — the
   cache-refresh rule "content without a bump does not reach installers" was demonstrated live
   this session when `claude plugin update` reported both "already latest").
3. **fable-org-audit worked-example refresh** (live-verified 2026-07-02): four of the eight
   original endpoints were dead or moved (`GET /usage` → 405 POST-only, `GET /traces` → 405
   DELETE-purge-only, `/graph` → `/atlases/<id>/graph`, `/intelligence` →
   `/intelligence/summary`); new endpoints folded into their dimensions (pulse, loadout,
   cost, hypotheses, actions, api-keys, plat, robots, admin ingest-health/org-collisions);
   uniform-404 no-oracle routes documented; drift log added.
4. **Sibling catalog sync**: claude-skills-site to 15 (Category E maintainer tooling) —
   separate repo, shipped `fc78416`.
5. **Loadout self-declaration proven** (skills-as-product hook, first-ever declaration): org
   `platatlas` actor `act_90fdfaad-1d32-4afa-9b85-e11d5bebd31c` declared 15 founder-skills
   items via `bin/declare-loadout.mjs` with a purpose-minted ingest-scope key
   (`claude-fable-seat-loadout`); declared-vs-observed bloat diff live (15/0/15 — honest:
   no traces from the seat yet). Recorded in fs-platatlas-integration.
6. **Attestable auditor outreach pack** (rail repo, docs-only): one-pager, demo script,
   target-firm criteria with falsifiable ACCEPT/CONDITIONAL/REJECT outcomes — the KC-A
   auditor-acceptance GO-gate artifact, grounded in the 2026-07-02 cited research run.

## Non-goals

Sibling-site scenarios/diagram restyling; any runtime change to the PlatAtlas worker; auditor
outreach itself (operator action); GitHub Actions (standing rule).
