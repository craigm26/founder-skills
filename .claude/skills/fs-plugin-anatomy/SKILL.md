---
name: fs-plugin-anatomy
description: >-
  The structural contract of a founder-skills plugin: directory layout, plugin.json schema and version
  semantics (0.1.0 vs 0.2.0), marketplace.json dual registration (local ./plugins vs git-subdir cross-list),
  relative-path and <skill-dir> conventions, and per-plugin .gitignore hazards including the *.html swallow
  that shipped build-options broken. Use when a maintainer asks "what files does a plugin need", "what goes
  in plugin.json", "why is my asset missing after install", "how do I register a plugin in the marketplace",
  "what version should this plugin be", "is my .gitignore safe", or "why did claude plugin validate pass but
  the skill still broke".
---

# fs-plugin-anatomy — the structural contract of a plugin

You are maintaining `founder-skills` (`/home/craigm26/projects/craigm26/founder-skills` on the origin
machine; public GitHub `craigm26/founder-skills`, MIT). It is a Claude Code **marketplace** — 12 plugins
committed at HEAD `2e4c9dd` plus 3 uncommitted `skill-*` plugins (2026-07-02), 15 on disk: a
repo whose root `.claude-plugin/marketplace.json` lists installable plugins, each a self-contained
directory under `plugins/`. This skill defines what a structurally correct plugin looks like, how the two
manifest layers relate, and the one class of defect (gitignore swallow) that has already shipped a plugin
broken once.

All facts below verified against the repo at HEAD `2e4c9dd` on 2026-07-02 unless stamped otherwise.

## When NOT to use this skill

| Your job | Load instead |
|---|---|
| Add a brand-new skill end to end (add-skill.sh workflow, stub → publish) | `fs-skill-authoring` |
| Write or edit SKILL.md *content* (frontmatter voice, phases, tables, closers) | `fs-skill-style-guide` |
| Ship a change to master / run the pre-push gate | `fs-release-and-publish` |
| Get a spec/plan approved before touching anything | `fs-change-control` |
| Run or extend the test suites, set up the venv | `fs-toolchain-and-tests` |
| Read the full incident narratives (how the swallow happened and was rescued) | `fs-failure-archaeology` |
| First orientation to the whole repo | `fs-orientation` |

## 1. The two manifest layers

There are two different JSON manifests. Confusing them is the most common structural mistake.

| Manifest | Location | Scope | Declares |
|---|---|---|---|
| `plugin.json` | `plugins/<name>/.claude-plugin/plugin.json` | one plugin | name, version, description, author, license |
| `marketplace.json` | `.claude-plugin/marketplace.json` (repo root) | the whole marketplace | owner + the list of installable plugins and where their source lives |

Both live inside a directory literally named `.claude-plugin/` — the per-plugin one inside the plugin dir,
the marketplace one at repo root. A plugin is not installable until it appears in **both** places.

## 2. Directory layout contract

Observed layout across all 15 plugins (verified 2026-07-02; the 3 uncommitted skill-* plugins
ship only the three REQUIRED files below — no assets/references/tests):

```
plugins/<name>/
├── SKILL.md                        # REQUIRED — at plugin ROOT, not in a skills/ subdir
├── README.md                       # REQUIRED here — marketing-facing walkthrough (all 15 have one)
├── .claude-plugin/
│   └── plugin.json                 # REQUIRED — the plugin manifest
├── references/                     # optional — worked examples, method docs (5 plugins have it)
├── assets/                         # optional — executable/template payloads (2: market-validation, build-options)
├── tests/                          # optional — pytest + node:test suites (2: market-validation, build-options)
├── demos/                          # tufte-viz only — shipped HTML demos
└── .gitignore                      # only where the skill GENERATES output files (2: market-validation, build-options)
```

Rules of thumb:

- **SKILL.md sits at the plugin root.** This repo does not use a `skills/` subdirectory convention.
- **README.md is the marketing face**, SKILL.md is the runbook. README template (Before you install /
  What it will ask you / What it produces / Cost / 60-second first run / Built on) is `fs-skill-style-guide`'s
  territory.
- **`assets/` = files the skill executes or fills at runtime** (workflow scripts, Python generators, HTML
  templates). **`references/` = files the skill reads for method/examples.** The distinction matters for
  `.gitignore` (see §6) and tests.
- Runtime junk (`__pycache__/`, `.pytest_cache/`) appears on disk in the two tested plugins; it is
  gitignored, never committed.

## 3. plugin.json schema as used here

Fields present in all 15 manifests (12 committed + 3 uncommitted skill-*; this is the house shape, not the full official schema):

| Field | Value pattern | Notes |
|---|---|---|
| `name` | lowercase slug, matches directory name | `add-skill.sh` enforces `^[a-z0-9][a-z0-9-]*$` |
| `version` | `0.1.0` or `0.2.0` | semantics in §4 — the installed-cache directory is literally named after this |
| `description` | one line, job-first | mirrors (not necessarily verbatim-equals) the SKILL.md frontmatter description |
| `author` | `{"name": "Craig Merry", "email": "craigm26@gmail.com"}` | full name here; the marketplace entry uses the handle instead |
| `homepage` | `https://github.com/craigm26/founder-skills` | same for all |
| `license` | `MIT` | same for all |
| `keywords` | 4–5 slugs | present in all 15 manifests, but `add-skill.sh` **omits** it when generating — add manually after scaffolding |

Validation: `claude plugin validate plugins/<name>` (and `--strict`). **Hard limitation, verified
2026-07-02: it validates the MANIFEST only** — its output says "Validating plugin manifest" and it passed
build-options while that plugin's core runtime asset was missing from git. Passing validate proves the JSON
is well-formed against the schema, nothing more. Never treat it as a ship gate; the real gate is
`fs-release-and-publish`.

## 4. Version semantics: 0.1.0 vs 0.2.0

- **0.1.0** = as-published baseline. `add-skill.sh` stamps every new plugin `0.1.0`.
- **0.2.0** = the Anthropic-primitives upgrade, commit `93d91a2` (2026-06-11): skills re-anchored on
  verified primitives (scheduling triggers, Outcome rubrics, `output_config.effort` disambiguation, the
  correctly-stated Fable 5 safety-boundary section).

Verified version map (2026-07-02):

| 0.2.0 (primitives-upgraded) | 0.1.0 (baseline) |
|---|---|
| effort, tasks, fable-loop-design, fable-orchestrated-feature-dev, fable-org-audit, fable-repo-audit | session-start, market-validation, build-options, prd, ecosystem-planning, tufte-viz + the 3 uncommitted skill-* plugins (2026-07-02) |

Counting caveat: the commit title says "across five skills" but the diff bumps **six** plugin.json files
(the message body groups fable-orchestrated-feature-dev + tasks as one upgrade). When citing, say "the
0.2.0 upgrade (six plugins bumped, commit `93d91a2`)" — count files, not the title.

**Version bumps are load-bearing for installs**: the plugin cache stores each install under a directory
named after `version` (§7). Shipping changed content without a bump means updated installs land in the
*same* cache directory name; there is no signal to users that content changed. Bump on any
behavior-relevant change.

## 5. marketplace.json and dual registration

### 5a. The local (canonical) marketplace

Root `.claude-plugin/marketplace.json` — top level: `$schema`
(`https://anthropic.com/claude-code/marketplace.schema.json`), `name` (`founder-skills`), `description`,
`owner {name, email}`, `plugins[]`. Each plugin entry:

```json
{
  "name": "build-options",
  "description": "one-liner (independently worded; NOT auto-synced with plugin.json)",
  "author": { "name": "craigm26" },
  "category": "productivity",
  "source": "./plugins/build-options",
  "homepage": "https://github.com/craigm26/founder-skills"
}
```

- `source` is a **relative path string** (`./plugins/<name>`) for the local marketplace.
- `author.name` is the handle `craigm26` here vs `Craig Merry` in plugin.json — intentional, keep it.
- `category` is `productivity` for all 15 (the `add-skill.sh` default).
- **Three descriptions exist per plugin** (SKILL.md frontmatter, plugin.json, marketplace entry) and
  nothing keeps them in sync. When you change one, diff the other two.

### 5b. The cross-list (second registration)

`scripts/add-skill.sh` also registers each new plugin in a **second** marketplace — the
RobotRegistryFoundation repo at `$HOME/claude-code-plugins` (overridable via env var `RRF_MARKETPLACE`).
There the entry's `source` is an **object**, not a path:

```json
"source": { "source": "git-subdir", "url": "https://github.com/craigm26/founder-skills.git", "path": "plugins/<name>" }
```

Meaning: the cross-list marketplace does not vendor the plugin; installers pull the subdirectory straight
from the founder-skills git repo. Consequences:

- founder-skills master is the single source of truth for both marketplaces — cross-list entries go stale
  in *listing metadata* only (name/description), never in content.
- The cross-list target is machine-local. **Verified 2026-07-02: `~/claude-code-plugins` does not exist on
  the origin Raspberry Pi host** — `add-skill.sh` detects this and skips with a warning
  (`--no-cross-list` skips explicitly). Do not treat cross-listing as guaranteed; it is best-effort.
- Registration in both places is idempotent: the script checks `any(p["name"] == name)` before appending.

## 6. Path conventions inside a plugin

A plugin must work from wherever it is installed (repo checkout, plugin cache, symlink). Three rules make
that true, all observed in the golden plugins:

1. **SKILL.md prose uses relative paths** — `references/…`, `assets/…` — never absolute paths, never
   `/home/…`.
2. **Runnable commands in SKILL.md use the `<skill-dir>` placeholder** for the plugin's own root, e.g.
   (verbatim from market-validation SKILL.md):
   ```
   python3 <skill-dir>/assets/market-map/emit_market_map.py deck-data.json <out-dir>/market-map
   node --test '<skill-dir>/tests/js/*.test.mjs'
   ```
   `<skill-dir>` is a convention the executing model substitutes at runtime, not an env var. Output
   locations use `<out-dir>` the same way.
3. **Executable assets self-locate their siblings** via `Path(__file__).parent`, never cwd. Verified in
   both generators: `TEMPLATE = HERE / "matrix.template.html"` (build_matrix.py:16), `TEMPLATE = HERE /
   "deck.template.html"` (build_deck.py:15). This is why a missing template is a hard
   `FileNotFoundError` at runtime — and why the gitignore swallow (§7) broke build-options completely.

## 7. .gitignore hazards — the *.html swallow

The one structural defect class that has already shipped broken (defect ledger #1; full incident narrative
and rescue story live in `fs-failure-archaeology` — this section is the pattern, not the chronicle).

Both chain plugins generate HTML output next to where they keep HTML **templates**. Their `.gitignore`
files took opposite approaches (both verbatim, 2026-07-02):

| `plugins/build-options/.gitignore` — the pattern that BROKE | `plugins/market-validation/.gitignore` — the pattern that was SAFE |
|---|---|
| `__pycache__/`<br>`*.pyc`<br>`*.pdf`<br>`*.pptx`<br>`*.html` ← swallow<br>`!assets/matrix.template.html` ← post-rescue negation<br>`.pytest_cache/` | `__pycache__/`<br>`*.pyc`<br>`*.pdf`<br>`*.pptx`<br>`deck.html` ← exact output filename only<br>`.pytest_cache/` |

What happened: `*.html` matched the shipped runtime asset `assets/matrix.template.html`, so it was never
committed. `claude plugin validate` passed anyway (manifest-only, §3). The plugin published broken; the sole
surviving copy of the template lived in the mutable plugin cache
(`~/.claude/plugins/cache/founder-skills/build-options/0.1.0/assets/`, regenerated at runtime 2026-06-24 —
environment-specific path, origin machine). Rescued 2026-07-02: template copied back into the repo,
`!assets/matrix.template.html` negation added, pytest back to 9/9. **As of 2026-07-02 the rescue is
UNCOMMITTED** (`git status`: modified `.gitignore` + untracked `assets/matrix.template.html`) — operator
commits per standing rule; re-check before relying on it being in history.

Rules going forward:

1. **Prefer exact output filenames** (`deck.html`) over extension wildcards. The output filename is known —
   the skill's own generator names it.
2. **If you must wildcard an extension, immediately add a `!` negation for every shipped asset** of that
   extension — and remember negations must come after the wildcard line.
3. **Templates are inputs, not outputs.** Anything under `assets/` or `references/` or `demos/` that the
   skill reads must be tracked. (tufte-viz ships four HTML demos and — correctly — has no `.gitignore`
   at all; a repo-wide `*.html` rule would have nuked those too.)
4. **A plugin only needs a `.gitignore` if it generates files inside its own directory.** Thirteen of
   fifteen plugins have none.

Verification commands (run from repo root; these caught / would have caught the swallow):

```bash
# Is any shipped payload gitignored? Filter legit junk; ANY remaining line = defect.
# (Plain check-ignore, not -v: -v also prints negation matches, which are NOT ignored.)
git check-ignore plugins/*/assets/* plugins/*/references/* plugins/*/demos/* 2>/dev/null \
  | grep -v -e __pycache__ -e '\.pyc$'
# exit 1 + no output = clean (verified 2026-07-02)

# Diff what git ships vs what's on disk, per plugin (LC_ALL=C: git sorts in C locale).
# Lines prefixed '>' are on disk but NOT tracked — today this shows the uncommitted
# matrix.template.html rescue; after it's committed, expect no output.
diff <(git ls-files plugins/build-options/assets/ | LC_ALL=C sort) \
     <(find plugins/build-options/assets -maxdepth 1 -type f ! -name '*.pyc' | LC_ALL=C sort)

# Manifest well-formed (remember: manifest-ONLY)
claude plugin validate plugins/<name> --strict && claude plugin validate .
```

## 8. Install reality: the plugin cache

Environment-specific (origin machine paths; the mechanism is Claude Code's, the paths are per-user):

- Installed plugins live at `~/.claude/plugins/cache/founder-skills/<plugin>/<version>/` — the version
  directory name is literally `plugin.json`'s `version` field (verified: build-options → `0.1.0`,
  fable-org-audit/tasks/effort → `0.2.0`). A `.in_use/` subdir tracks live sessions.
- The cache is a **copy**, frozen at install time (origin cache = HEAD `2e4c9dd`, installed 2026-06-24).
  Every subsequent push to master silently desyncs installed users until they run
  `/plugin marketplace update founder-skills`.
- The cache is **mutable at runtime** — a session can write into it (that is how the swallowed template
  survived at all). Never treat cache contents as ground truth for what the repo ships; compare against
  `git ls-files`.
- `add-skill.sh` separately symlinks `~/.claude/skills/<name>` → `plugins/<name>` on the authoring machine
  ("one copy" rule) — and line ~142 `rm -rf`s any existing non-symlink dir there first (hazard, ledger #7).
  Verified 2026-07-02: no founder-skills symlinks currently present in `~/.claude/skills/` on the origin
  host.

## 9. New-plugin structural checklist

For the full authoring workflow use `fs-skill-authoring`; this is the anatomy-only gate. A plugin is
structurally complete when:

- [ ] `plugins/<name>/SKILL.md` exists at plugin root with `name` + `description` frontmatter only
- [ ] `plugins/<name>/README.md` exists (marketing template)
- [ ] `plugins/<name>/.claude-plugin/plugin.json` has all 7 house fields (§3) — add `keywords` by hand
- [ ] `version` set intentionally (`0.1.0` new; bump on behavior change)
- [ ] Entry appended to root `.claude-plugin/marketplace.json` with `source: "./plugins/<name>"`
- [ ] Cross-list attempted (or consciously `--no-cross-list`) — absence of `~/claude-code-plugins` is normal
- [ ] Every file under `assets/`, `references/`, `demos/` is TRACKED: `git check-ignore` returns nothing,
      `git ls-files` matches `find`
- [ ] `.gitignore` (if any) uses exact output filenames, or wildcard + `!` negations for shipped assets
- [ ] All SKILL.md commands use `<skill-dir>`/relative paths; executable assets self-locate via `__file__`
- [ ] `claude plugin validate plugins/<name> --strict` and `claude plugin validate .` pass — knowing this
      proves manifests only
- [ ] Change went through `fs-change-control`; ship via `fs-release-and-publish` (never route around them)

## Provenance and maintenance

All claims verified 2026-07-02 against `/home/craigm26/projects/craigm26/founder-skills` at HEAD `2e4c9dd`
plus the uncommitted build-options rescue. Re-verify with:

- Version map: `for p in plugins/*/; do echo "$p $(python3 -c "import json;print(json.load(open('$p/.claude-plugin/plugin.json'))['version'])")"; done`
- 0.2.0 commit + its "five vs six" count: `git show --stat 93d91a2 | grep -c plugin.json` (expect 6)
- Layout census: `find plugins -mindepth 2 -maxdepth 2 \( -name assets -o -name references -o -name tests -o -name demos -o -name .gitignore \) | sort` (2026-07-02: assets×2, references×5, tests×2, demos×1, .gitignore×2 — the 3 skill-* plugins add no such dirs, so the census is unchanged from HEAD)
- Gitignore safety: `git check-ignore plugins/*/assets/* plugins/*/references/* plugins/*/demos/* 2>/dev/null | grep -v -e __pycache__ -e '\.pyc$'` (expect no output)
- Rescue committed yet?: `git status --short plugins/build-options/` (2026-07-02: still shows `M .gitignore` + `?? assets/matrix.template.html`)
- Marketplace entries parse + count: `python3 -c "import json;m=json.load(open('.claude-plugin/marketplace.json'));print(len(m['plugins']))"` (expect 15 in the 2026-07-02 working tree; 12 at HEAD 2e4c9dd)
- Validate behavior (manifest-only wording): `claude plugin validate plugins/market-validation` (output says "Validating plugin manifest")
- Cross-list presence on this machine: `ls -d ~/claude-code-plugins 2>&1` (absent on origin host 2026-07-02)
- Cache version-dir naming: `ls ~/.claude/plugins/cache/founder-skills/build-options/` (environment-specific; expect a dir named exactly the plugin.json version)
- `<skill-dir>` convention still in use: `grep -rn '<skill-dir>' plugins/*/SKILL.md`

Volatile facts most likely to drift: the uncommitted 2026-07-02 tree (the rescue + the 3 skill-* plugins
will become commits), the plugin count and version map (any new skill or bump), cache install date/HEAD,
and the absence of `~/claude-code-plugins`.
