# Plan — Post-campaign follow-ons (2026-07-02)

Spec: `docs/superpowers/specs/2026-07-02-post-campaign-followons.md`.

- [x] Measured cost figures: docs/index.html chips (market-validation "1.13M tokens measured
      (4-angle run) · ~1.5M full"; build-options "314k tokens measured (3-lens run)");
      market-validation README+SKILL.md; build-options README. Estimates kept, labeled.
- [x] Version bumps: market-validation + build-options plugin.json → 0.2.0.
- [x] market-validation SKILL.md sink-limitation line reconciled with the proven Path C record
      in `references/sinks.md`.
- [x] fable-org-audit `references/worked-example-platatlas.md` refreshed (agent, all probes
      live-verified with control 404; drift log added).
- [x] Sibling site → 15: claude-skills-site `fc78416` pushed; live-verified (poll: "Install
      all 15", 3 maintainer cards present).
- [x] Loadout declaration: key minted (ingest scope) → declare 15 items → index shows
      actor with declared 15 / observed 0 / bloat 15.
- [x] Local plugin cache: prd 0.2.0 + tasks 0.3.0 pulled; 3 maintainer plugins installed.
- [x] Attestable outreach pack written under rail `docs/strategy/2026-07-02-attestable-auditor-outreach/`
      (one-pager, demo script, target-firms with falsifiable outcomes), committed to rail main
      (docs-only; no deploy surface).

## Verification (re-runnable)

```bash
grep -n "measured" docs/index.html                       # two measured chips
python3 -c "import json;[print(p, json.load(open(f'plugins/{p}/.claude-plugin/plugin.json'))['version']) for p in ('market-validation','build-options')]"
bash .claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh
curl -s https://craigm26.github.io/claude-skills-site/ | grep -c "Install all 15"
```
