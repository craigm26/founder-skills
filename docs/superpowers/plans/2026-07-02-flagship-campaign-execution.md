# Plan — Flagship-chain campaign execution + handoff library (2026-07-02)

Spec: `docs/superpowers/specs/2026-07-02-flagship-campaign-execution.md` (operator-approved
in-session). Items are checked as executed; this plan is partly a record (the operator instructed
execution directly), preserving the spec → plan → commit chain for the archive.

## Tasks

- [x] Handoff library: 15 skills under `.claude/skills/` + 6 scripts; 3 public plugins
      (`skill-style-guide`, `skill-release-gate`, `skill-freshness-watch`); marketplace.json 12→15.
      Reviewed by 4 agents (factual×2/doctrine/usability, 35 findings) + fixer (17 fixed).
      → commit `648d304` "feat: maintainer handoff library …", pushed.
- [x] Phase 0: rescue `matrix.template.html` from plugin cache + `.gitignore` negation;
      build-options pytest 9/9. → same commit `648d304`. Gate: `gate.sh phase0` exit 0.
- [x] Phase 1A proving run: `research-workflow.js`, run `wf_8ea9a6d3-231` (30 agents,
      ~1.13M tokens). Observed: "Collected 35 raw claims across 4 of 4 dispatched angles",
      "Curated 24 claims; 13 competitors", "Verified: 24 survived, 0 dropped"; return shape
      exact; args threaded. All expected observations met.
- [x] Phase 1B proving run: `build-options-workflow.js`, run `wf_58e1fc39-7fb` (9 agents).
      First pass CAUGHT the silent skeptic-verdict drop (ledger entry 9): journal verdicts
      wounded/wounded/killed vs returned survive/survive/survive on mismatched optionIds.
- [x] Fix entry 9 by construction in `build-options-workflow.js` (closure stamps `optionId`;
      prompt states exact id); stress-test leg re-run via Workflow resume → honest verdicts
      (wounded 8 risks / killed 9 risks / wounded 8 risks).
- [x] Gate: `gate.sh phase1 research-output.json build-options-output.json` →
      "GATE PASS: phase1", exit 0.
- [x] Chain-proof render: `build_matrix.py decision-data.json` →
      "HTML …/attestable-what-to-build-proving-run.html 39885 chars" (rescued template exercised).
      Evidence archive (JSONs + rendered HTML, contains product strategy — NOT committed to this
      public repo): local `~/projects/craigm26/founder-skills-evidence/2026-07-02-proving-runs/`.
- [x] Promote honesty labels: both "syntax-checked only" admissions → "proven on 2026-07-02"
      (updated, not deleted — fence F5); the phrase remains in plugins/*/SKILL.md only where skill-style-guide teaches the convention.
- [x] Phase 2: prd rewrite (200→128 lines, v0.2.0, example → references/) + tasks rewrite
      (480→150 lines, v0.3.0, agent-browser → "browser executor", 1 mention, example →
      references/); READMEs to house template; handoff contract byte-compatible. Independent
      acceptance agent re-ran all 9 criteria: PASS.
- [x] Phase 3: site truth-up (`~0 tokens`/`runs itself weekly` → 0 hits; twelve→fifteen; 3
      maintainer-tooling cards; footer untouched; html.parser OK) + root README (table, install
      list, install-all loop). `site-checks.sh` green (card assertion 12→15).
- [x] PlatAtlas sink proving Path C on org `platatlas` (initiated + evidence posted in PlatChat
      `#general`, thread `msg_01KWJH0JGC6YKJC121X392XA08`): market-map atlas
      `92892cbc-c4f1-5b06-a849-791d80677dcc` live; flow `competitive-landscape` in prod D1;
      graph edges 25→40 (15 step); survey resolves the flow. `sinks.md` caveat graduated.
- [x] Status-board sweep: ledger entries 1/4/5/6 updated + entry 9 appended; campaign board;
      style-guide tiers (prd/tasks → conforming); orientation; anthropic-primitives;
      toolchain-and-tests; research-frontier; `site-checks.sh`.
- [x] Final ship: pre-push gate all-PASS → operator-instructed commit + push → live verification
      (Pages + raw marketplace + installability).

## Verification (re-runnable)

```bash
PY=~/venvs/founder-skills/bin/python bash .claude/skills/fs-flagship-chain-campaign/scripts/gate.sh phase0
bash .claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh
bash .claude/skills/fs-site-and-positioning/scripts/site-checks.sh
grep -rln "syntax-checked only" plugins/*/SKILL.md  # expect ONLY skill-style-guide (it teaches the convention)
grep -c "agent-browser" plugins/tasks/SKILL.md      # expect 1
```
