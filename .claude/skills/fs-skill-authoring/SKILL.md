---
name: fs-skill-authoring
description: >-
  End-to-end workflow for adding a new skill/plugin to founder-skills: scripts/add-skill.sh
  anatomy step-by-step, its verified hazards (manifest-schema-only validation, the rm -rf
  symlink swap of ~/.claude/skills/<name>, the maybe-absent ~/claude-code-plugins cross-list,
  the folded-description misparse), the conformance pass against the house style, and the
  sanitize-and-graduate gate for publishing a private skill. Use when a maintainer asks
  "how do I add a new skill", "scaffold a plugin", "run add-skill.sh", "publish this private
  skill", "graduate a skill from claude-skills", "is this safe to make public", or "why did
  add-skill.sh eat my skill directory".
---

# fs-skill-authoring — adding a new skill, end to end

Announce at start: "Loading fs-skill-authoring — walking the add-skill.sh path with its hazards, then the conformance and sanitization gates."

You are adding a plugin to `founder-skills` (public GitHub `craigm26/founder-skills`, MIT), a
Claude Code marketplace (15 plugins as of 2026-07-02: 12 committed + 3 uncommitted skill-*)
that **live-publishes**: every push to `master` is instantly
installable by marketplace users. There is exactly one scaffolding tool, `scripts/add-skill.sh`
(161 lines), and it has shipped a broken plugin once already because its validation step checks
manifests, not content. This skill is the runbook that gets a new skill from idea to
publish-ready without repeating that incident.

All facts verified against the repo at HEAD `2e4c9dd` on 2026-07-02 unless stamped otherwise.
The four hazards below were each reproduced or observed on the origin machine that day.

## When NOT to use this skill

| Your job | Load instead |
|---|---|
| Understand what files a plugin needs, plugin.json/marketplace.json schema, .gitignore hazards in depth | `fs-plugin-anatomy` |
| Write the SKILL.md *content* — frontmatter voice, phases, tables, closers | `fs-skill-style-guide` |
| Get the spec/plan approved before you scaffold anything | `fs-change-control` |
| Actually push to master (pre-push gate, publish sequence) | `fs-release-and-publish` |
| Set up the venv / run the test suites | `fs-toolchain-and-tests` |
| The no-oversell and sanitization *doctrine* and its rationale | `fs-doctrine-and-honesty` |
| Full incident narratives (how build-options shipped broken and was rescued) | `fs-failure-archaeology` |
| First orientation to the repo | `fs-orientation` |

## Terms (defined once)

| Term | Meaning here |
|---|---|
| **Plugin** | A self-contained directory under `plugins/<name>/` with a `SKILL.md` and `.claude-plugin/plugin.json`, listed in the root marketplace manifest. |
| **Marketplace** | The repo itself: root `.claude-plugin/marketplace.json` lists every installable plugin. |
| **Cross-list** | A second registration of the same plugin in a *different* marketplace repo (`~/claude-code-plugins`, the RobotRegistryFoundation marketplace) via a `git-subdir` source pointing back at founder-skills master. |
| **Graduate** | Move a skill from the private repo `claude-skills` into public founder-skills as a sanitized near-copy. |
| **Sanitize-and-graduate gate** | The hard gate from `docs/superpowers/specs/2026-06-11-publish-private-six-design.md`: zero occurrences of client names, secret prefixes, personal paths, or infra layout in anything public. |
| **Public-is-canonical** | Standing operator rule (2026-07-02): for graduated skills, the public copy is the source of truth; the private repo is a frozen historical archive (last commit `ab5bcb2`, 2026-06-11). Never backport. |

## Step 0 — Change control comes first

Adding a skill is a publishable change to a live marketplace. Per `fs-change-control`, it needs
an operator-approved spec (`docs/superpowers/specs/`, date-prefixed) and a checkbox plan before
you scaffold. Do not route around this. Assistants never run mutating git commands — the script
prints `git add/commit/push` lines at the end; those are **for the operator**, not for you.

## Step 1 — add-skill.sh anatomy

Usage (from the script header, verified):

```bash
scripts/add-skill.sh <name> [--desc "one-line description with triggers"] \
                            [--from <dir>] [--category <cat>] [--no-cross-list]
```

`<name>` must be a lowercase slug (`^[a-z0-9][a-z0-9-]*$`). `plugins/<name>` must not already
exist (the script dies if it does — so re-runs fail early rather than double-register).

What it does, in order (line numbers from the 161-line script at HEAD `2e4c9dd`):

| # | Lines | Step | Detail |
|---|---|---|---|
| 1 | 50–57 | **Resolve source** | Three-way: `--from <dir>` (must contain `SKILL.md`) → else `~/.claude/skills/<name>` *if it is a real directory, not a symlink, with a SKILL.md* → else scaffold a stub SKILL.md you fill in. |
| 2 | 59–76 | **Import or stub** | `rsync -a` the source into `plugins/<name>/`, excluding `.git`, `.pytest_cache`, `__pycache__`; any imported `.claude-plugin/` is wiped and recreated fresh. |
| 3 | 79–93 | **Resolve description** | `--desc` wins; else a Python one-liner extracts the `description:` line from SKILL.md frontmatter. Dies if empty. **See Hazard 4 — this misparses folded `>-` descriptions.** |
| 4 | 96–109 | **Write plugin.json** | Always `version: 0.1.0`, MIT, author Craig Merry, homepage = the GitHub repo. |
| 5 | 132 | **Register locally** | Appends an entry to `.claude-plugin/marketplace.json` with source `./plugins/<name>`. Idempotent: skips if the name is already listed. |
| 6 | 133–138 | **Cross-list** | If `~/claude-code-plugins/.claude-plugin/marketplace.json` exists (override path with `RRF_MARKETPLACE` env var), appends a `git-subdir` entry there too. **See Hazard 3.** |
| 7 | 140–144 | **Symlink swap** | If `~/.claude/skills/<name>` is not already a symlink: `rm -rf` it, then symlink it to `plugins/<name>` ("one copy"). **See Hazard 2.** |
| 8 | 146–150 | **Validate** | `claude plugin validate "$PLUGIN_DIR" --strict`, then the repo, then the cross-list repo if touched. **See Hazard 1.** |
| 9 | 152–160 | **Print publish commands** | Echoes the `git add/commit/push` lines for both repos. It does NOT push for you. |

Because the script runs `set -euo pipefail`, a failure at the validate step (step 8) exits
**after** steps 4–7 already mutated things. Manual cleanup after a mid-run failure:
`rm -rf plugins/<name>`, `git checkout -- .claude-plugin/marketplace.json`, and restore
whatever was at `~/.claude/skills/<name>` from your backup (Hazard 2).

## Step 2 — The hazards

### Hazard 1 — validation is manifest-schema-only

`claude plugin validate` (options: `--strict` only, verified via `--help` 2026-07-02) validates
the **manifest**, not the plugin's content. It passed `build-options` while the plugin's core
asset `assets/matrix.template.html` was missing from git — swallowed by a `*.html` line in the
plugin's own `.gitignore` — so the plugin shipped broken and stayed broken until the 2026-07-02
rescue (full narrative: `fs-failure-archaeology`; the .gitignore mechanics: `fs-plugin-anatomy`).

A green validate therefore proves almost nothing. Add these two checks for **every file your
SKILL.md references** (both verified working 2026-07-02):

```bash
# 1. Is the file actually tracked by git? (exits 1 + error if not)
git ls-files --error-unmatch plugins/<name>/assets/<file>

# 2. Which .gitignore rule, if any, would swallow files in this plugin?
git check-ignore -v plugins/<name>/assets/* plugins/<name>/references/*
```

`git check-ignore -v` prints the exact `.gitignore` file and line that matches — this is the
command that would have caught the `*.html` swallow before it shipped. If the plugin has
executable assets, also run its tests (`fs-toolchain-and-tests`) before calling it done.

### Hazard 2 — the `rm -rf` symlink swap can destroy work

Line 142: `rm -rf "$SKILLS_DIR/$NAME"; ln -s "$PLUGIN_DIR" "$SKILLS_DIR/$NAME"` — guarded only
by "is it not already a symlink". Two data-loss paths:

1. **You pass `--from <dir>` while a real directory also exists at `~/.claude/skills/<name>`.**
   The `--from` source wins (source resolution never looks at the skills dir), so the existing
   real directory is `rm -rf`'d at step 7 *without ever being imported*.
2. **A real directory exists but has no `SKILL.md`** (work in progress, notes, drafts). Source
   resolution skips it (the elif requires `SKILL.md` to exist), the script scaffolds a stub —
   and then `rm -rf`s your work-in-progress directory anyway.

The safe path (`~/.claude/skills/<name>` is a real dir **with** SKILL.md and you pass no
`--from`) is fine: rsync copies it into the repo *before* the rm. But you cannot always know
which case you are in, so:

```bash
# ALWAYS back up before running, if anything exists at the target:
[ -e ~/.claude/skills/<name> ] && cp -a ~/.claude/skills/<name> \
  ~/.claude/skills-backup-$(date +%Y%m%d)-<name>
```

Note the inverse gotcha too: if `~/.claude/skills/<name>` is already a symlink pointing
somewhere *else*, the script leaves it alone silently — your new plugin is then not the copy
Claude loads. Check with `ls -l ~/.claude/skills/<name>` afterwards. These paths are
environment-specific (the origin machine's home dir); the mechanism is the same anywhere the
Claude Code skills dir lives.

### Hazard 3 — the cross-list repo may not exist

The script cross-lists into `$HOME/claude-code-plugins` (the RobotRegistryFoundation
marketplace) by default. Verified 2026-07-02: **that directory does not exist on the origin
machine** — the script prints `(RRF marketplace not found at ... — skipped cross-list; set
RRF_MARKETPLACE to override)` and continues harmlessly (`DID_RRF=0`).

The hazard is on machines where it DOES exist: the script then mutates a **second git repo**
whose new entry is a `git-subdir` source pointing at founder-skills master — meaning the
cross-listed entry is broken for installers until founder-skills itself is pushed, and the
second repo needs its own commit/push (the script prints that command line too). If you do not
intend to maintain the cross-list, pass `--no-cross-list` explicitly rather than relying on the
directory being absent.

### Hazard 4 — folded `>-` descriptions misparse to the literal string `>-`

Verified 2026-07-02 by running the script's exact Python extractor against a house-style
SKILL.md: when frontmatter uses the folded form the repo's own style guide mandates —

```yaml
description: >-
  Multi-line description...
```

— the extractor's single-line regex captures `>-` and writes **`">-"` as the plugin
description** into plugin.json and both marketplace entries. It is non-empty, so the script's
empty-description guard does not fire; the garbage ships silently.

Mitigation: **always pass `--desc "..."`** when the source SKILL.md uses a folded description
(i.e., always, if you follow `fs-skill-style-guide`). After any run, eyeball the description
fields in `plugins/<name>/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
This is an open defect candidate for a spec'd fix (route via `fs-change-control`); as of
2026-07-02 the script is unpatched.

## Step 3 — Conformance pass

The script gives you a structurally registered plugin; it does nothing for quality. Before
publish, check every row (detail lives in the named sibling — do not guess):

| Check | Gate | Detail in |
|---|---|---|
| Frontmatter is EXACTLY `name` + `description`, folded `>-`, description opens with the job then "Use when …" with literal utterances | required | `fs-skill-style-guide` |
| Body: imperative voice, numbered Phases/Steps, tables, house closers, `## References` list, honesty admissions ("syntax-checked only" where true) | required | `fs-skill-style-guide` |
| Model style anchors: copy from the golden four only (market-validation, build-options, ecosystem-planning, fable-org-audit); NEVER from prd/tasks/tufte-viz | required | `fs-skill-style-guide` |
| Directory layout, plugin.json fields, version semantics, per-plugin `.gitignore` audited for swallows | required | `fs-plugin-anatomy` |
| Every referenced asset passes `git ls-files --error-unmatch`; `git check-ignore -v` on assets/references comes back clean or negated | required | this skill, Hazard 1 |
| Executable assets have a `## Tests` section with exact commands, and the tests pass | required if assets exist | `fs-toolchain-and-tests` |
| Per-plugin README follows the walkthrough template (Before you install / What it will ask you / What it produces / Cost / 60-second first run / Built on) | required for published plugins | `fs-plugin-anatomy` |
| Every factual claim traces to a source verified this session; no oversell | required | `fs-doctrine-and-honesty` |

## Step 4 — The sanitize-and-graduate gate (publishing a private skill)

Applies whenever content originates in the private repo
`/home/craigm26/projects/craigm26/claude-skills` (environment-specific path; private GitHub
`craigm26/claude-skills`; skills live under `skills/<name>/`) — or in ANY private context.
The gate comes from the operator-approved spec
`docs/superpowers/specs/2026-06-11-publish-private-six-design.md` and is a **hard gate**: zero
hits, or each hit explicitly waived in a spec.

### 4a. Scripted grep scan

This skill ships the scan (tested 2026-07-02: `plugins/` scans clean; planted secrets, home
paths, and banned claims are all caught):

```bash
.claude/skills/fs-skill-authoring/scripts/sanitize-scan.sh plugins/<name>/
# exit 0 = clean, 1 = hits (printed file:line)
```

Pattern list (mirror of the spec's hard-gate list; keep the script and this table in sync):

| Pattern | Why |
|---|---|
| `sk_live`, `sk_test`, `cfut_`, inline `Bearer <token>` values | secret/token prefixes |
| `/home/craigm26` | personal home-dir paths |
| `reservoir` (case-insensitive) | real client org names — expect false positives on the English word; human-review every hit |
| `parcelriskreport` | real-project example filenames → genericize |
| "Anthropic('s) internal research" | banned claim class (`fs-doctrine-and-honesty`) |

Grep cannot catch everything the spec bans. Manually check for: personal-machine infra layout
(systemd unit paths, `/etc/` configs, venv locations), and reframe any hard third-party-tool
dependency generically (the precedent: Codex became "an external executor **such as** Codex").

### 4b. Near-copy divergence tracking

Graduated skills are *near-copies*, not identical copies (sanitization changed them at birth,
and v0.2.0 upgrades were public-only). Track divergence explicitly rather than assuming sync:

```bash
# Per graduated skill (private path is environment-specific):
diff -u /home/craigm26/projects/craigm26/claude-skills/skills/<name>/SKILL.md \
        plugins/<name>/SKILL.md
```

Verified 2026-07-02: ecosystem-planning already diverges (diff exits 1) — that is expected and
correct, because of:

### 4c. Public-is-canonical

Standing operator rule (2026-07-02): the public founder-skills copy is canonical for all six
graduated skills; private `claude-skills` is frozen as a historical archive at `ab5bcb2`
(2026-06-11). Consequences:

- Never edit the private copy to "keep it in sync". Never backport public changes.
- When graduating a NEW skill, the private original becomes archive material the moment the
  sanitized copy lands on master — all future edits happen public-side only.
- The divergence diff (4b) is archaeology, not a to-do list.

## Step 5 — Publish

Hand off to `fs-release-and-publish` and run its full local pre-push gate (all three test
suites + JSON parse + sanitization grep + URL sweep — mandatory, no CI exists to save you).
The operator reviews and runs the `git add/commit/push` lines the script printed. After the
push, installed users stay on their cached copy until they run
`/plugin marketplace update founder-skills` — a push alone updates nobody.

## Common mistakes | Fix

| Mistake | Fix |
|---|---|
| Trusting a green `claude plugin validate` | It is manifest-schema-only. Run the `git ls-files`/`git check-ignore` checks + tests (Hazard 1). |
| Running add-skill.sh with anything precious at `~/.claude/skills/<name>` and no backup | `cp -a` backup first, always (Hazard 2). |
| Omitting `--desc` because "the frontmatter has one" | Folded `>-` descriptions extract as the literal string `>-` (Hazard 4). Always pass `--desc`. |
| Assuming the cross-list happened (or didn't) | Read the script output; `--no-cross-list` to be explicit; second repo needs its own commit (Hazard 3). |
| Scaffolding before a spec is approved | Change control first (`fs-change-control`). Adding a plugin is a live-publishing change. |
| Editing the private claude-skills repo during graduation | Public is canonical; private is frozen (Step 4c). |
| Running the printed `git push` yourself | Operator-only. Assistants never run mutating git. |
| Leaving a half-run mess after a validate failure | Clean up all three mutations: plugin dir, marketplace.json entry, symlink (Step 1, cleanup note). |

## Quick reference

```bash
cd /home/craigm26/projects/craigm26/founder-skills   # environment-specific repo root

# 0. backup anything at the target skill path
[ -e ~/.claude/skills/NEW ] && cp -a ~/.claude/skills/NEW ~/.claude/skills-backup-$(date +%Y%m%d)-NEW

# 1. scaffold (always pass --desc; be explicit about cross-listing)
scripts/add-skill.sh NEW --desc "Job statement. Use when ..." --no-cross-list

# 2. content-level checks the validator skips
git check-ignore -v plugins/NEW/assets/* plugins/NEW/references/* ; echo "check-ignore exit=$?"
git ls-files --error-unmatch plugins/NEW/SKILL.md

# 3. sanitize gate (mandatory if any content originated privately; cheap enough to always run)
.claude/skills/fs-skill-authoring/scripts/sanitize-scan.sh plugins/NEW/

# 4. conformance: fs-skill-style-guide + fs-plugin-anatomy checklists, then fs-release-and-publish
```

## Provenance and maintenance

All claims verified 2026-07-02 at HEAD `2e4c9dd` on the origin machine. Re-verify with:

```bash
# Script anatomy / line numbers still accurate? (161 lines at 2e4c9dd)
wc -l scripts/add-skill.sh && sed -n '50,57p;140,150p' scripts/add-skill.sh

# Hazard 1 rescue state (was: matrix.template.html untracked + .gitignore negation uncommitted)
git status --short plugins/build-options/ && git check-ignore -v plugins/build-options/assets/*

# Hazard 3: does the cross-list repo exist on THIS machine?
ls "$HOME/claude-code-plugins/.claude-plugin/marketplace.json" 2>&1

# Hazard 4: does the extractor still misparse folded descriptions? (expect '>-' until fixed)
sed -n '80,91p' scripts/add-skill.sh   # then re-run the snippet against a folded SKILL.md

# validate CLI surface unchanged?
claude plugin validate --help

# sanitize scan still clean over the published tree?
.claude/skills/fs-skill-authoring/scripts/sanitize-scan.sh plugins/

# private repo still frozen at ab5bcb2? (environment-specific path)
git -C /home/craigm26/projects/craigm26/claude-skills log --oneline -1
```

Volatile facts to re-check on drift: HEAD hash, the uncommitted rescue state (defect ledger #1
— will change the moment the operator commits), the absent `~/claude-code-plugins` (another
machine may have it), and whether Hazard 4 has been fixed by a spec'd change.

## References

- `scripts/add-skill.sh` — the tool this skill documents
- `docs/superpowers/specs/2026-06-11-publish-private-six-design.md` — sanitization hard-gate source
- `scripts/sanitize-scan.sh` (in this skill dir) — executable half of the gate
- Siblings: `fs-plugin-anatomy`, `fs-skill-style-guide`, `fs-change-control`, `fs-release-and-publish`, `fs-toolchain-and-tests`, `fs-doctrine-and-honesty`, `fs-failure-archaeology`
