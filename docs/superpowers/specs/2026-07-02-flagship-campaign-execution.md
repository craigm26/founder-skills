# Spec — Flagship-chain campaign execution + maintainer handoff library (2026-07-02)

Status: approved by operator (2026-07-02, in-session instructions: "build a complete skill
library", "Ok commit", "Push", "do the next milestones … then ensure everything is merged and
pushed to production"). This spec is partly retroactive: it records the operator-instructed batch
as the doc of record, discharging the pipeline debt noted in
`.claude/skills/fs-change-control/SKILL.md` ("Known pipeline debt (2026-07-02)").

## Scope

1. **Maintainer handoff library** (shipped `648d304`): 15 internal skills under `.claude/skills/`
   (fs-orientation … fs-research-frontier, 6 executable scripts) + 3 genericized public plugins
   (`skill-style-guide`, `skill-release-gate`, `skill-freshness-watch`) registered in
   `marketplace.json` (12 → 15).
2. **Campaign Phase 0** (shipped `648d304`): `matrix.template.html` rescued from the plugin cache
   (sole surviving copy) + `.gitignore` negation; build-options pytest 2-failing → 9/9.
3. **Campaign Phase 1 — proving runs** of the two "syntax-checked only" Workflow scripts, at the
   campaign's recommended minimum-honest scale with a real product topic (Attestable):
   - 1A `research-workflow.js` (run `wf_8ea9a6d3-231`, 30 agents): PASS on every expected
     observation — 4/4 angles, "Curated 24 claims; 13 competitors" (in the 18–24 band),
     "Verified: 24 survived, 0 dropped", return shape `{report, survivors, competitors,
     droppedCount}`, args threaded (product/scope text present in prompts and report).
   - 1B `build-options-workflow.js` (run `wf_58e1fc39-7fb`, 9 agents): ran end-to-end
     (3 gen → 3 judges → 3 skeptics; judgeCount 3; all scores numeric) and **caught ledger
     entry 9**: skeptic verdicts (`wounded`/`wounded`/`killed`) were silently replaced by the
     default `survive/[]` because the join trusted the model-echoed `optionId`. Fixed
     by-construction (closure stamps the id; prompt states it); stress-test leg re-run via
     Workflow resume. Evidence JSONs + `gate.sh phase1` output attached to the plan.
   - Promotion: the two SKILL.md "syntax-checked only" admissions graduate to
     "proven on 2026-07-02 (see this spec)" — updated, never deleted (fence F5).
4. **Campaign Phase 2 — prd/tasks house-style rewrite** (licensed 2026-07-02): in-place rewrite,
   prd 200→128 lines (v0.2.0), tasks 480→150 lines (v0.3.0), worked examples moved to
   `references/`, agent-browser genericized to "browser executor" (1 "such as" mention), handoff
   contract (`/tasks/prd-*.md` → `prd.json`, field names/`passes:false`) preserved verbatim.
   All 9 measurable acceptance criteria independently re-verified.
5. **Campaign Phase 3 — site truth-up** (operator un-gated in-session): oversell strings removed
   (`grep -c "~0 tokens\|runs itself weekly" docs/index.html` → 0), count copy "twelve"→"fifteen"
   site+README, 3 maintainer-tooling cards added in house card anatomy, footer untouched,
   `site-checks.sh` green (card assertion updated 12→15). Sibling-site (claude-skills-site)
   update remains a coordinated follow-on.
6. **PlatAtlas sink proving (Path C, full claim)** — run from PlatChat org `platatlas` `#general`
   (thread `msg_01KWJH0JGC6YKJC121X392XA08`): real 2026-06-24 market map registered as its own
   hosted atlas (`92892cbc-c4f1-5b06-a849-791d80677dcc`) via R2 META; flow
   `competitive-landscape` seeded to prod D1 (dry-run inspected → `--write`); hosted graph API
   edges 25→40 (15 `kind:step`), survey resolves `flow:competitive-landscape`.
   `references/sinks.md` caveat graduated to "proven on the hosted path, 2026-07-02".
   Findings recorded in `fs-platatlas-integration` (org-merged graph pool; gh-token
   device-exchange auth path).
7. **Status-board consistency sweep**: failure-archaeology entries 1/4/5/6 updated + entry 9
   appended; campaign status board; style-guide copy-from tiers; orientation router/ledger;
   `site-checks.sh` card count.

## Non-goals

- No GitHub Actions (standing rule). No changes to the private claude-skills repo (frozen
  archive). No workflow-atlas/rail repo changes beyond the R2/D1 org data writes listed in §6
  (the mirror plan stays documented-not-executed). Sibling catalog site not edited here.

## Risks stated

- Live-publishing master: this batch ships in one push after the full pre-push gate.
- The 1B fix changes a shipped executable asset (`build-options-workflow.js`); its behavior is
  proven by the resumed run's honest verdicts (evidence in plan).
