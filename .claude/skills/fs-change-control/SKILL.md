---
name: fs-change-control
description: >-
  How changes to founder-skills are classified, gated, and reviewed: the
  operator-approved spec -> checkbox plan -> commits-matching-plan-verbatim
  pipeline, plus the five standing rules (direct-push-to-master with a
  mandatory local pre-push gate, no GitHub Actions ever, public repo canonical
  over private claude-skills, prd/tasks rewrite licensed, operator commits /
  assistants never run mutating git) with the rationale and incident behind
  each. Use when a maintainer asks "how do I ship a change here", "do I need
  a spec for this", "can I just push this fix", "why is there no CI", "who
  commits", "can I edit the site copy", "what's the change process", or
  before writing any spec, plan, or commit in this repo.
---

# fs-change-control — how changes ship in founder-skills

Announce at start: "Loading fs-change-control — checking what class of change this is and which gate applies."

This repo is a **live-publishing** repo: every push to `master` is instantly installable by
marketplace users and redeploys the GitHub Pages site (served from `master:/docs`). There is no
staging branch, no CI, and no review app. The change-control pipeline below is the ONLY safety
mechanism. Do not route around it, and do not let any other skill route around it.

## Terms (defined once)

| Term | Meaning here |
|---|---|
| **Operator** | The human owner (Craig Merry). The only party who approves specs and runs mutating git. |
| **Spec** | A design document in `docs/superpowers/specs/`, date-prefixed, carrying `**Status:** approved by operator`. Decisions live here. |
| **Plan** | A checkbox implementation plan in `docs/superpowers/plans/`, date-prefixed, matching a spec. Execution steps live here, including the exact commit messages. |
| **Pre-push gate** | The mandatory local verification run before any push (tests + JSON parse + sanitization grep + URL sweep). Executable script owned by `fs-release-and-publish`. |
| **Mutating git** | `git add`, `git commit`, `git push`, `git mv`, `git rm`, branch/tag creation, anything that changes repo state. Read-only (`git log/diff/show/status`) is always allowed. |
| **Sanitization** | The hard gate that keeps client names, secrets prefixes, and `/home/craigm26` paths out of anything public. Detail owned by `fs-doctrine-and-honesty`. |

## The pipeline: spec -> plan -> verbatim commits

Every non-trivial change flows through three artifacts, in order:

```
docs/superpowers/specs/YYYY-MM-DD-<topic>[-design].md      (operator approves)
        |
        v
docs/superpowers/plans/YYYY-MM-DD-<topic>.md               (checkbox tasks + literal commit messages)
        |
        v
commits on master whose messages match the plan text VERBATIM
```

### 1. The spec

- Path: `docs/superpowers/specs/`, filename date-prefixed (`2026-06-11-publish-private-six-design.md`).
  Three of the four existing specs use a `-design` suffix; one (`2026-06-11-anthropic-primitives-upgrade.md`)
  does not — the date prefix is the hard convention, the suffix is not.
- Header format (copy this):

  ```markdown
  # <Title of the change>

  **Date:** YYYY-MM-DD · **Status:** approved by operator
  ```

- Body: Goal, Motivation/Decisions, Workstreams, Out of scope, Risks. See
  `docs/superpowers/specs/2026-06-11-public-judgment-layer-design.md` as the exemplar.
- A spec is not actionable until its Status line says approved by the operator. Assistants draft
  specs; the operator approves them. All 4 existing specs carry `Status: approved by operator`
  (verified 2026-07-02).

### 2. The plan

- Path: `docs/superpowers/plans/`, same date prefix, no `-design` suffix.
- Opens with the agentic-workers header (copy verbatim from an existing plan):

  ```markdown
  > **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
  (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
  checkbox (`- [ ]`) syntax for tracking.
  ```

- Then `**Goal:**`, `**Architecture:**`, `**Tech Stack:**`, then `### Task N:` sections of
  `- [ ] **Step N:**` checkboxes.
- **Plans spell out the literal commit message for each commit**, e.g.
  `git commit -m "refactor: atlas emitter -> vendor-neutral market map emitter"`.
- Observed convention (verified 2026-07-02): the checkboxes are NOT ticked retroactively — all
  3 existing plans have 0 `[x]` boxes despite being fully executed. Completion evidence is the
  commit history, not the checkbox state. Do not "fix" old plans by ticking boxes.

### 3. Commits match the plan verbatim

The commit message in the plan IS the commit message on master. Verified examples (git log,
2026-07-02):

| Plan text | Commit |
|---|---|
| `refactor: atlas emitter -> vendor-neutral market map emitter` | `5f07aef` |
| `docs: vendor-neutral market-map schema + pluggable sinks doc` | `8b4cbdf` |
| `feat: publish the six orchestration/craft skills as public plugins` | `030c3d0` |
| `docs: README + marketplace — 12/12 installable` | `c2fd100` |

This makes the plan an audit trail: a reviewer can diff `git log --oneline` against the plan file
and see exactly what shipped and in what order. When you execute a plan, use its commit messages
exactly — do not paraphrase.

### Observed pipeline variants (classification)

| Change class | Required artifacts | Precedent |
|---|---|---|
| Multi-task workstream (new plugins, site overhaul, genericization) | Spec + Plan + verbatim commits | `publish-private-six`, `public-judgment-layer`, `skill-sites-family` (all 2026-06-11) |
| Focused upgrade with clear scope | Spec -> commit directly (no plan) | `anthropic-primitives-upgrade`: spec `bb6947d` -> feat `93d91a2`, no plan file |
| Site copy edits (`docs/index.html`) | Spec required — "site edits need coordinated spec per house change-control". The known oversell drift fix (defect ledger #6) is deliberately WAITING on a spec; do not hotfix it. | Facts pack 2026-07-02 |
| Pre-pipeline history | The first 5 commits (2026-06-04 through `951c82a`) predate the pipeline, which began at spec commit `4caee62` (2026-06-11). Do not cite them as precedent for skipping specs. | git log |

There is no documented "trivial" tier. If you think a change is too small for a spec, the safe
default in a live-publishing repo is: draft a short spec anyway and let the operator approve or
waive it. (UNVERIFIED: no written waiver rule exists; absence of a tier is not permission.)

### Known pipeline debt (2026-07-02) — this handoff itself

The 2026-07-02 uncommitted working tree (template rescue, this `.claude/skills/fs-*` handoff
library, and the 3 `plugins/skill-*` public plugins + their marketplace.json registration) was
operator-directed in-session, but **no spec or plan artifact exists for it yet** —
`docs/superpowers/specs/` and `plans/` still hold only the four 2026-06-11 documents. Per the
classification table above, the plugin + marketplace.json changes are a multi-task workstream.
Before the operator commits: draft `docs/superpowers/specs/2026-07-02-handoff-library-design.md`
(Status pending operator approval) plus a matching checkbox plan with literal commit messages
(template rescue / fs- library / 3 public plugins) — or have the operator explicitly waive the
pipeline for this change and record that waiver here. The session facts pack is scratchpad, not
a repo artifact; it does not substitute for the spec.

## The five standing rules

All five are operator-approved standing policy as of 2026-07-02. Each row: the rule, why it
exists, and the incident or decision behind it.

| # | Rule | Rationale | Incident / decision behind it |
|---|---|---|---|
| 1 | **Direct-push-to-master stays; a mandatory LOCAL pre-push gate is non-negotiable** (all 3 test suites + JSON parse + sanitization grep + URL sweep). | Master is live: every push publishes to installers and the Pages site instantly. With no staging, the gate is the only thing standing between a mistake and the public. Schema-only validation is proven insufficient. | **build-options shipped broken** (defect ledger #1): `assets/matrix.template.html` was swallowed by a plugin `.gitignore` line `*.html` and never committed; `claude plugin validate` passed anyway because it checks manifest schema only. Also **site oversell drift** (#6) shipped ungated. Gate made mandatory by operator decision 2026-07-02. |
| 2 | **No GitHub Actions ever.** No new workflow files, no auto-trigger CI, no Actions-based deploys. The gate runs locally. | GitHub Actions is billing-blocked for the org, and the operator prefers local verification he can run and inspect on the host (a Raspberry Pi). | Standing org-wide rule since **2026-06-19** (billing-blocked + operator preference), reaffirmed for this repo 2026-07-02. |
| 3 | **Public founder-skills is CANONICAL for the six graduated skills; private claude-skills is frozen as a historical archive.** Never port changes back to private; never treat private as upstream. | The six skills graduated 2026-06-11 as sanitized near-copies, and the public repo then moved AHEAD (the v0.2.0 Anthropic-primitives upgrades were public-only). Two writable copies would guarantee divergence and re-introduce unsanitized content risk. | Graduation executed per `docs/superpowers/plans/2026-06-11-publish-private-six.md`; canonical/frozen status set by operator decision 2026-07-02. Private repo last commit `ab5bcb2` (2026-06-11). |
| 4 | **prd and tasks MAY be rewritten into house style**, and their hard `agent-browser` CLI dependency should be genericized (the same way Codex became "external executor"). | They are off-style imports from an external "compound engineering" methodology: different voice, emoji ❌/✅, no references/assets, no model routing, ~480 lines (2–6× house norm), and an unstated third-party install dependency. They drag the library's quality floor down. | Defect ledger #5; rewrite explicitly licensed by operator decision 2026-07-02. Until rewritten, do NOT copy style from prd/tasks (see `fs-skill-style-guide`). |
| 5 | **The operator commits. Assistants never run mutating git commands.** Assistants prepare working-tree changes, run the gate, and hand off; the operator reviews and commits/pushes. | On a live-publishing master, the commit IS the release. Keeping a human at the commit boundary is the review step this repo has instead of PRs. | Operator decision 2026-07-02, demonstrated the same day: the template rescue (defect #1 fix) was executed by an assistant but deliberately left uncommitted in the working tree for operator review (`git status` shows the modified `.gitignore` + untracked template as of 2026-07-02). |

### Rule 1 in practice — the gate's contents

The gate components (executable script and full runbook owned by `fs-release-and-publish` —
load that skill to actually push; summary here for classification only):

1. All 3 test suites green: market-validation pytest (6), build-options pytest (9),
   market-validation JS `node --test 'tests/js/*.test.mjs'` (5). Env setup quirks (PEP-668 venv,
   glob-form-only node invocation) are owned by `fs-toolchain-and-tests`.
2. JSON parse: `.claude-plugin/marketplace.json` + every `plugins/*/.claude-plugin/plugin.json`,
   and every plugin `source` path exists.
3. Sanitization grep over the public dirs (`plugins/ docs/ README.md .claude-plugin/`,
   excluding `docs/superpowers`), case-insensitive — zero hits (pattern and rationale owned
   by `fs-doctrine-and-honesty`; the narrower plugins/-only historical pattern it extends is
   in `docs/superpowers/plans/2026-06-11-publish-private-six.md`).
4. External URL sweep: every external URL in README, SKILL.mds, plugin READMEs, and
   `docs/index.html` curls 2xx (or 3xx resolving to 2xx with `-L`). Note the last full URL
   verification was 2026-06-11 — 3 weeks stale as of 2026-07-02 (`fs-freshness-watch` owns the
   re-verification sweep).

## Runbook: shipping a change end-to-end

1. **Classify** the change using the table above. Anything touching published plugin content,
   the site, README, or marketplace.json needs at least a spec.
2. **Draft the spec** in `docs/superpowers/specs/YYYY-MM-DD-<topic>.md` with the header format
   above; leave Status pending until the operator approves. Get operator approval (only the
   operator can set `Status: approved by operator`).
3. **Write the plan** (multi-task changes) in `docs/superpowers/plans/YYYY-MM-DD-<topic>.md`
   with checkbox tasks and literal commit messages.
4. **Implement** in the working tree. If you are an assistant: no `git add/commit/push` at any
   point. Prepare the tree, that's all.
5. **Run the pre-push gate** (load `fs-release-and-publish` for the executable script). All
   green or you stop.
6. **Hand off to the operator** with: the spec, the plan, the gate output, and the exact
   plan-specified commit messages. The operator reviews, commits, pushes.
7. **After push**: master is live immediately; installed users' plugin cache
   (`~/.claude/plugins/cache/founder-skills/` — environment-specific path, the actual install
   mechanism) silently desyncs until they update. Post-push verification is
   `fs-release-and-publish`'s job.

Common mistakes:

| Mistake | Fix |
|---|---|
| "It's a one-line site fix, I'll just push it" | Site edits need a coordinated spec. The known oversell drift is intentionally unfixed pending one. |
| Paraphrasing plan commit messages | Copy them verbatim — the plan/log match is the audit trail. |
| Ticking checkboxes in old plans | Plans stay unchecked by convention; commits are the completion record. |
| Adding a GitHub Actions workflow "just for tests" | Rule 2: never. Gate runs locally. |
| Trusting `claude plugin validate` as the gate | It is manifest-schema-only; it passed a plugin whose core asset was missing. Run the full gate. |
| Backporting a fix to private claude-skills | Rule 3: private is frozen. Public is canonical. |
| Assistant running `git commit` because "the operator asked me to prepare the release" | Rule 5: preparing ≠ committing. Only the operator's own hands (or explicit permission-system approval) commit. |

## When NOT to use this skill

- **Actually executing a push** (gate script, Pages verification, cache-desync handling) →
  load `fs-release-and-publish`.
- **Setting up the test environment or running/extending suites** → `fs-toolchain-and-tests`.
- **Sanitization patterns, no-oversell rules, source-traceability doctrine** →
  `fs-doctrine-and-honesty`.
- **Writing a new skill's content** (style, structure) → `fs-skill-style-guide` and
  `fs-skill-authoring`.
- **First orientation in the repo** ("what is this place") → `fs-orientation`.
- **Past failures as lessons** (full incident narratives) → `fs-failure-archaeology`; this skill
  only cites incidents as rule rationale.

## Provenance and maintenance

Volatile facts in this skill were verified 2026-07-02 against repo HEAD `2e4c9dd`. Re-verify:

```bash
# Specs all approved + date-prefixed (expect 4 files, each with an approved Status line)
grep -l "Status:.*approved by operator" docs/superpowers/specs/*.md

# Plans exist and remain unchecked (expect 3 files; first grep -c returns 0 for each)
grep -c '\- \[x\]' docs/superpowers/plans/*.md; ls docs/superpowers/plans/

# Commit messages still match plan text verbatim (spot-check)
git log --oneline | grep -F "refactor: atlas emitter -> vendor-neutral market map emitter"
grep -F "atlas emitter -> vendor-neutral" docs/superpowers/plans/2026-06-11-public-judgment-layer.md

# Single live branch, direct-push model unchanged (expect only master)
git branch -a

# Rule 5 evidence: template rescue still uncommitted, or has been operator-committed since
git status --short plugins/build-options/

# No Actions workflows have crept in (expect no output)
ls .github/workflows/ 2>/dev/null

# Sanitization pattern of record
grep -A1 "Sanitization gate" docs/superpowers/plans/2026-06-11-publish-private-six.md
```

Sources of record: `docs/superpowers/specs/2026-06-11-public-judgment-layer-design.md` (live-repo
risk + verification gate origin), `docs/superpowers/plans/2026-06-11-publish-private-six.md`
(sanitization gate pattern, graduation), `docs/superpowers/plans/2026-06-11-public-judgment-layer.md`
(verbatim commit messages), git log. The five standing rules are operator decisions of 2026-07-02
recorded in the facts pack compiled that day; if a later operator decision supersedes any rule,
that decision wins — update this file the same session.
