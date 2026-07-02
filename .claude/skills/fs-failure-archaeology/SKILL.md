---
name: fs-failure-archaeology
description: >-
  The founder-skills defect chronicle: every known failure in this repo as
  symptom -> root cause -> evidence -> status, so no maintainer re-fights a
  settled battle or re-discovers a known trap. Use when a test fails, a command
  from a README doesn't work, an asset is missing, or you're about to touch
  .gitignore, add-skill.sh, prd/tasks, the Pages site, or a workflow script.
  Triggers on: "the tests fail", "FileNotFoundError matrix.template",
  "no module named pytest", "node --test can't find tests", "is this a known
  bug", "why is the site claiming X", "has this broken before", "add a defect
  to the ledger", "what's the status of defect N".
---

# fs-failure-archaeology — the defect ledger

Announce at start: "Consulting the failure archaeology ledger — checking whether this is a known, settled battle."

This skill is the **single home** for the founder-skills repo's defect history. Before you debug
anything in this repo, scan the at-a-glance table below. If your symptom matches an entry, read
that entry and **stop re-investigating** — apply the recorded fix or respect the recorded
accepted-risk. All relative paths below are from the repo root.

**Terms used once, defined once:**

| Term | Meaning |
|---|---|
| **Ledger entry** | One recorded defect: symptom, root cause, evidence, status. Numbered, never deleted. |
| **Plugin cache** | `~/.claude/plugins/cache/founder-skills/` — the copy Claude Code actually loads after `/plugin install`. Mutable at runtime; NOT the repo. Environment-specific path. |
| **PEP-668** | Python's "externally managed environment" marker: system `pip install` is blocked; you must use a venv. |
| **Golden four** | The four house-style-conforming skills: market-validation, build-options, ecosystem-planning, fable-org-audit. See `fs-skill-style-guide`. |
| **Status vocabulary** | `fixed` (fix committed), `fixed-uncommitted` (fix in working tree only), `open` (unfixed), `accepted-risk` (operator chose to live with it). |

## When NOT to use this skill

- You want the **process** for fixing a defect (spec -> plan -> commits) → load `fs-change-control`. This skill records history; it never authorizes changes.
- You need the **working test/venv commands** as a runbook → load `fs-toolchain-and-tests` (entries 2–3 below only explain *why* the README forms fail).
- You're shipping a fix to the live master → load `fs-release-and-publish` for the pre-push gate.
- You're writing or restyling a skill (entry 5's rewrite) → load `fs-skill-style-guide` + `fs-skill-authoring`.
- You're editing the Pages site (entry 6) → load `fs-site-and-positioning`.
- You want the PlatAtlas/market-map surface behind entry 8 → load `fs-platatlas-integration`.
- You're doing the periodic drift sweep → load `fs-freshness-watch` (it re-runs this file's provenance commands, among others).

---

## The ledger at a glance (verified 2026-07-02)

| # | Name | One-line symptom | Status (2026-07-02) |
|---|---|---|---|
| 1 | gitignore swallow | build-options crashes: `FileNotFoundError: matrix.template.html` | fixed-uncommitted |
| 2 | PEP-668 README | `python3 -m pytest` → "No module named pytest" | open |
| 3 | node directory form | `node --test tests/js/` → MODULE_NOT_FOUND; JS suite absent from README | open |
| 4 | syntax-checked-only workflows | Two Workflow scripts never actually executed end-to-end | open (honestly labeled) |
| 5 | prd/tasks import mismatch | Two skills in a foreign house style with an unstated CLI dependency | open (rewrite licensed) |
| 6 | site oversell drift | Pages site claims exceed what the skills do | open |
| 7 | add-skill.sh hazards | Validator can't catch missing assets; script `rm -rf`s a user dir | accepted-risk |
| 8 | emit_atlas rename | 2026-06-11 rename could have broken external users; no telemetry | accepted-risk |

---

## Entry 1 — gitignore swallow: build-options shipped broken

- **Symptom:** `/build-options` (and its pytest suite) failed with `FileNotFoundError` for
  `assets/matrix.template.html`. 2 of 9 tests failed. The plugin shipped this way from day one.
- **Root cause:** `plugins/build-options/.gitignore` line 5 is `*.html` (added to ignore *generated*
  matrix HTML). It also swallowed the hand-written template, which was therefore **never committed**.
  `claude plugin validate` passed anyway — it checks manifest schema only, not asset presence (see entry 7).
- **How it survived at all:** the sole copy lived in the mutable plugin cache
  (`~/.claude/plugins/cache/founder-skills/build-options/0.1.0/assets/matrix.template.html`,
  mtime 2026-06-24 00:15 — regenerated at runtime by a Claude session, while sibling assets carry the
  2026-06-23 22:43 install mtime). A cache-only file is one `plugin uninstall` away from extinction.
- **Evidence:** `.gitignore` `*.html` present since first commit `d0d3a40` (verified via
  `git show d91748c:plugins/build-options/.gitignore`); template absent from all history
  (`git log --oneline -- plugins/build-options/assets/matrix.template.html` was empty pre-rescue);
  pre-rescue pytest: 2 failed with FileNotFoundError.
- **Rescue (operator-authorized, executed 2026-07-02):** cache copy copied into
  `plugins/build-options/assets/matrix.template.html`; `.gitignore` gained line 6
  `!assets/matrix.template.html` (negation). Post-rescue: `9 passed` (re-run 2026-07-02).
- **Status:** **fixed-uncommitted** as of 2026-07-02 — `git status` shows
  `M plugins/build-options/.gitignore` and untracked `plugins/build-options/assets/matrix.template.html`.
  The operator commits; assistants run no mutating git commands. If `git status` is clean and the
  template is tracked, promote this entry to `fixed`.
- **Lesson:** any `.gitignore` wildcard in a plugin must carry `!`-negations for shipped assets, and
  "it works on my machine" can mean "the cache is hiding the loss." Structural rules live in `fs-plugin-anatomy`.

## Entry 2 — PEP-668: README test commands fail verbatim

- **Symptom:** `README.md` lines 218–219 say `python3 -m pytest -q tests/`. On the maintainer host
  (Python 3.13.5) this prints `No module named pytest`, and `pip install pytest` is refused (PEP-668).
- **Root cause:** README was written assuming a system pytest; the host Python is externally managed.
- **Working form (re-verified 2026-07-02):**
  ```bash
  python3 -m venv ~/venvs/founder-skills && ~/venvs/founder-skills/bin/pip install pytest
  cd plugins/market-validation && ~/venvs/founder-skills/bin/python -m pytest -q tests/  # 6 passed
  cd plugins/build-options    && ~/venvs/founder-skills/bin/python -m pytest -q tests/   # 9 passed
  ```
- **Status:** **open** — README still carries the failing form. Fixing it is a README change: route
  through `fs-change-control`. Full environment runbook: `fs-toolchain-and-tests`.

## Entry 3 — node:test directory form fails; JS suite undocumented

- **Symptom:** `node --test tests/js/` → `MODULE_NOT_FOUND` (re-verified 2026-07-02 on Node v24.16.0).
  The top-level README's Develop/test section doesn't mention the JS suite at all.
- **Root cause:** the tests live under `tests/js/*.test.mjs`; on this Node the directory form does not
  recurse to find them. Only the glob form works, and it's documented in exactly one place:
  `plugins/market-validation/SKILL.md:112`.
- **Working form (quote the glob so the shell doesn't expand it):**
  ```bash
  cd plugins/market-validation && node --test 'tests/js/*.test.mjs'   # 5 tests, all pass
  ```
- **Status:** **open** (README omission). The suite itself is green.

## Entry 4 — Workflow scripts are syntax-checked only

- **Symptom:** none yet — that's the point. Two `Workflow({scriptPath})` scripts have **never been
  executed end-to-end in generalized form**: `plugins/market-validation/assets/research-workflow.js`
  (the args-path variant) and `plugins/build-options/assets/build-options-workflow.js` plus its
  prd handoff.
- **Root cause:** they were generalized from private originals and validated by syntax check + the
  Function-wrapper JS harness (`tests/js/harness.mjs` stubs `agent`/`parallel`/`phase`/`log`/`args`),
  which is a simulation, not the real Workflow runtime.
- **Evidence:** the skills say so themselves — `plugins/market-validation/SKILL.md:93` and
  `plugins/build-options/SKILL.md:63`: "syntax-checked only — its first real invocation is its proving run."
- **Status:** **open**, honestly labeled. The proving run is a step of the gated campaign in
  `fs-flagship-chain-campaign` — do not silently "prove" these outside that campaign, and do not
  remove the honesty labels until a real run has passed (doctrine: `fs-doctrine-and-honesty`).

## Entry 5 — prd + tasks: off-style external imports

- **Symptom:** `plugins/prd/SKILL.md` (200 lines) and `plugins/tasks/SKILL.md` (480 lines) read
  nothing like the golden four: different voice, ❌/✅ emoji, no `references/`/`assets/`, no model
  routing, no Announce convention, 2–6× the house length norm.
- **Root cause:** imported wholesale from an external "compound engineering" methodology rather than
  authored in-house.
- **Hidden dependency:** `plugins/tasks/SKILL.md:67` **mandates** the third-party
  `agent-browser` CLI (github.com/vercel-labs/agent-browser) for all browser acceptance criteria —
  an unstated install dependency nowhere in the install docs.
- **Status:** **open — rewrite licensed** by operator decision 2026-07-02: prd/tasks MAY be rewritten
  into house style, and agent-browser should be genericized the same way Codex became
  "external executor". Until then: **never copy style from prd or tasks** (nor tufte-viz's
  nonconforming `|` frontmatter). Style source of truth: `fs-skill-style-guide`.

## Entry 6 — Pages site oversell drift

- **Symptom:** the live site (`docs/index.html`, deploys on every master push) makes claims the repo
  itself forbids:
  - lines 227 and 230: "~0 tokens" cost chips for session-start/effort — README doctrine says
    "a few hundred tokens";
  - line 243: fable-org-audit "runs itself weekly via /schedule..." — the skill only *documents*
    scheduling options; nothing runs itself.
- **Root cause:** marketing copy drifted past the no-oversell rule during the 2026-06-11 site work.
- **Status:** **open**. The correction is a documented follow-on, and site edits require a
  coordinated spec (two sibling sites must stay in step) — route through `fs-change-control`, then
  `fs-site-and-positioning` for mechanics. Do not hot-patch the HTML.
- **Lesson:** the repo's own doctrine (`fs-doctrine-and-honesty`) applies hardest to the most
  public surface; that's exactly where it slipped.

## Entry 7 — add-skill.sh hazards

`scripts/add-skill.sh` (~160 lines) works, but three sharp edges are recorded so nobody is surprised
(line numbers verified 2026-07-02):

| Hazard | Evidence | Consequence |
|---|---|---|
| Validation is manifest-schema-only | lines 148–150 run `claude plugin validate`; it passed build-options while its core asset was missing (entry 1) | a green validate does NOT mean the plugin works |
| Destructive symlink swap | line 142: `rm -rf "$SKILLS_DIR/$NAME"` when `~/.claude/skills/<name>` exists and is not a symlink | a real (non-symlink) personal skill directory of the same name is deleted |
| Cross-lists into a second marketplace | line 22: `RRF_REPO="${RRF_MARKETPLACE:-$HOME/claude-code-plugins}"` (RobotRegistryFoundation) | on machines without that repo it skips with a notice — but on machines *with* it, running the script mutates a second repo |

- **Status:** **accepted-risk** (no fix specced). Mitigations when running it: back up any
  same-named `~/.claude/skills/<name>` first; never trust `validate` as a functional test — run the
  suites (`fs-toolchain-and-tests`); check `~/claude-code-plugins` for unexpected diffs afterward.
  Full authoring workflow: `fs-skill-authoring`.

## Entry 8 — emit_atlas.py → emit_market_map.py rename

- **Symptom (potential, never observed):** any external user invoking `emit_atlas.py` by path broke
  on 2026-06-11.
- **Root cause:** deliberate vendor-neutral rename, commit `5f07aef` ("refactor: atlas emitter ->
  vendor-neutral market map emitter"): `assets/platatlas/` → `assets/market-map/`,
  `emit_atlas.py` → `emit_market_map.py`.
- **Evidence:** the spec pre-declared the risk —
  `docs/superpowers/specs/2026-06-11-public-judgment-layer-design.md:88`: "the rename of
  `emit_atlas.py` could break external users mid-flight — acceptable, the marketplace install pulls
  fresh and nothing external imports the module by path."
- **Status:** **accepted-risk**. Note the caveat: **no telemetry exists** to know whether anyone was
  actually affected — the "nothing external imports it" claim is an assumption, not a measurement.
  (The measured-not-claimed research direction in `fs-research-frontier` exists partly because of
  gaps like this.)
- **Lesson:** renames of shipped executable assets are breaking changes on a live-publishing master;
  spec them, state the risk, and prefer a deprecation shim when cheap.

---

## Why this ledger has zero reverts to record

`git log` shows 24 commits, zero reverts, zero dead branches, zero stashes (verified 2026-07-02).
That is not luck: every feature commit sits downstream of an operator-approved spec in
`docs/superpowers/specs/` and a checkbox plan in `docs/superpowers/plans/`, with commit messages
matching plan text verbatim. The defects above all slipped through *gaps beside* that pipeline
(a gitignore nobody specced, docs written from assumption, imported foreign material, marketing
copy) — none came from specced work being wrong. Keep it that way: `fs-change-control` is the
process; this file is what happens at its edges.

## Append protocol — adding entry 9+

Appending a ledger entry is **record-keeping** and may be done directly in this file. **Fixing** the
defect it describes is a change and goes through `fs-change-control`. Never route around that split.

1. **Number sequentially, never delete or renumber.** Superseded entries get a status update, not removal.
2. **Use the exact four-part shape:** Symptom (what a zero-context person observes, with the literal
   error text) → Root cause (mechanism, not blame) → Evidence (at least one of: `file:line`,
   commit hash, or pasted command output — a claim without evidence doesn't enter the ledger) →
   Status (one word from the status vocabulary table, **date-stamped**).
3. **Add a row to the at-a-glance table** and update its "verified" date.
4. **One home per fact:** if the durable lesson belongs to a sibling skill (style rule → 
   `fs-skill-style-guide`, structural rule → `fs-plugin-anatomy`), put the lesson there and
   cross-reference it here; the ledger keeps the incident narrative.
5. **On status change** (e.g. entry 1 becomes `fixed` once committed): edit the status line and
   table row in place with the new date; leave the narrative intact.
6. **Sanitization gate applies** (this file may become public): no client names, no live-key
   prefixes, no personal absolute paths except explicitly-labeled environment-specific mechanisms
   like the plugin cache. See `fs-doctrine-and-honesty`.

## Common mistakes

| Mistake | Fix |
|---|---|
| Re-debugging a symptom already in the ledger | Scan the at-a-glance table first, always |
| "validate passed, so the plugin is fine" | Entry 7: validate is schema-only; run the test suites |
| Rescuing a file from the plugin cache and calling it authoritative | The cache is mutable runtime state (entry 1); treat a cache-only file as a recovered artifact needing review, then commit it to the repo |
| Fixing entry 2/3/6 with a quick doc edit | README/site changes go through `fs-change-control` |
| Copying prd/tasks patterns into a new skill | Entry 5: they're off-style imports; use the golden four |
| Declaring the workflows "proven" after the harness passes | Entry 4: the harness is a stub simulation; only the gated proving run counts |

## Provenance and maintenance

All facts above verified 2026-07-02 against repo HEAD `2e4c9dd` on the maintainer host
(Raspberry Pi, Python 3.13.5, Node v24.16.0). One-liners to re-verify anything that can drift
(run from repo root; venv path per entry 2):

```bash
git log --oneline | grep -ci revert                          # expect 0 (zero-reverts claim)
git status --short plugins/build-options/                    # entry 1: empty => promote to fixed
grep -n 'matrix.template' plugins/build-options/.gitignore   # entry 1: negation line present
python3 -m pytest --version                                  # entry 2: still "No module named pytest"?
(cd plugins/market-validation && node --test tests/js/)      # entry 3: still MODULE_NOT_FOUND?
(cd plugins/market-validation && node --test 'tests/js/*.test.mjs')  # entry 3: glob form still green
grep -n 'syntax-checked' plugins/*/SKILL.md                  # entry 4: honesty labels intact
grep -n 'agent-browser' plugins/tasks/SKILL.md | head -3     # entry 5: dependency still present
grep -n '~0 tokens\|runs itself weekly' docs/index.html      # entry 6: oversell still live?
grep -n 'rm -rf' scripts/add-skill.sh                        # entry 7: destructive lines
sed -n '88p' docs/superpowers/specs/2026-06-11-public-judgment-layer-design.md  # entry 8 risk text
```

Volatile facts to re-check when any command above changes output: entry 1 status
(fixed-uncommitted as of 2026-07-02), entries 2/3/6 remain open only until their specced fixes ship,
line numbers in entries 2/5/6/7 shift with any edit to those files. If the at-a-glance table and a
re-verification command disagree, the command wins — update the table.

## References

- Sibling router: `fs-orientation` · process: `fs-change-control` · env/tests: `fs-toolchain-and-tests`
- Doctrine behind entries 4/6/8: `fs-doctrine-and-honesty` · campaign owning entry 4's proving run: `fs-flagship-chain-campaign`
- `docs/superpowers/specs/2026-06-11-public-judgment-layer-design.md` (entry 8 risk acceptance)
- `scripts/add-skill.sh` (entry 7) · `plugins/build-options/.gitignore` (entry 1)
