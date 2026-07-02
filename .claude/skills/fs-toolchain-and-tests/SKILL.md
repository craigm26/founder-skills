---
name: fs-toolchain-and-tests
description: >-
  Recreate the founder-skills working environment from scratch and run or extend its
  three test suites: the venv procedure (the host Python is PEP-668 externally managed,
  so the README's test commands fail verbatim), the Node glob-form-only rule for the JS
  suite, the Function-wrapper harness pattern for testing top-level-await Workflow
  scripts, how to add a test to each suite, and a symptom-to-triage table for toolchain
  failures. Use when a maintainer says "run the tests", "pytest says no module named
  pytest", "node --test can't find the module", "set up the environment", "why do the
  README test commands fail", "FileNotFoundError matrix.template.html", "how do I test
  a workflow script", or "add a test for this asset".
---

# fs-toolchain-and-tests

**Announce at start:** "Loading fs-toolchain-and-tests — environment setup + the three test suites."

This skill gets you from a bare clone of `/home/craigm26/projects/craigm26/founder-skills`
(public GitHub `craigm26/founder-skills`) to all three test suites green, and teaches you
how to extend them. Every command below was copy-paste verified on the host on **2026-07-02**.

## When NOT to use this skill

| Your job | Load instead |
|---|---|
| Orienting in the repo, "which skill covers X" | **fs-orientation** |
| Shipping a change (spec → plan → commit pipeline, who commits) | **fs-change-control** |
| The pre-push gate script / publishing to the live marketplace | **fs-release-and-publish** |
| Plugin directory layout, SKILL.md/plugin.json contract | **fs-plugin-anatomy** |
| The history/incidents behind these gotchas (gitignore swallow, PEP-668 README failure, node directory form) | **fs-failure-archaeology** |
| Writing a new skill or its house style | **fs-skill-authoring**, **fs-skill-style-guide** |
| What `Workflow({scriptPath,args})`, `agent()`, `parallel()` mean at the platform level | **fs-anthropic-primitives** |

## The environment (as of 2026-07-02)

| Fact | Value | Why it matters |
|---|---|---|
| Host | Raspberry Pi, Linux 6.12.75+rpt-rpi-2712 | slow cores; suites are fast anyway (<1s each) |
| Python | 3.13.5, **PEP-668 externally managed** | `python3 -m pip install` errors; `python3 -m pytest` → "No module named pytest" |
| Node | v24.16.0 | `node --test` glob expansion works (needs ≥ v22); directory form does NOT here |
| Packaging | **none** — no package.json, no pyproject.toml, no version pins, no lockfiles | nothing to `npm install`; the only dependency to install anywhere is `pytest` |
| CI | **none, by standing rule** (no GitHub Actions ever, since 2026-06-19) | YOU are CI: run all three suites locally before any push (see fs-release-and-publish) |
| `claude` CLI | present at `~/.local/bin/claude`, v2.1.198 (environment-specific) | needed only for `claude plugin validate` (add-skill.sh, pre-push gate) — NOT for the test suites |

**PEP-668 (define once):** modern Debian-family Pythons mark the system interpreter
"externally managed" — `pip install` into it is refused with
`error: externally-managed-environment`. The only supported route is a virtual
environment (venv). This is why the README's `python3 -m pytest -q tests/` commands
(README.md "Develop / test" section, lines ~218–219) **fail verbatim on this host** —
a known defect, ledger item #2; fixing the README is fs-change-control scope, don't
just patch it.

## Setup from scratch (one time)

```bash
# 1. Create a venv anywhere you like and install the ONE dependency.
#    (~/venvs/founder-skills is a convention, not a requirement — any path works.)
python3 -m venv ~/venvs/founder-skills
~/venvs/founder-skills/bin/pip install pytest        # pytest 9.1.1 as of 2026-07-02

# 2. Sanity-check
~/venvs/founder-skills/bin/python -m pytest --version
node --version    # must be >= v22 for node --test glob expansion; host has v24.16.0
```

No Node setup exists or is needed: the JS suite uses only `node:test`, `node:assert/strict`,
`node:fs`, `node:path`, `node:url` builtins.

## The three suites — run them all

Set `VENV=~/venvs/founder-skills` (or your path). From the **repo root**:

```bash
$VENV/bin/python -m pytest -q plugins/market-validation/tests plugins/build-options/tests
# expected: 15 passed  (6 + 9)

node --test 'plugins/market-validation/tests/js/*.test.mjs'
# expected: pass 5, fail 0
```

Or per-plugin (equivalent; the SKILL.md `## Tests` sections use this form):

```bash
cd plugins/market-validation && $VENV/bin/python -m pytest -q tests/   # 6 passed
cd plugins/build-options     && $VENV/bin/python -m pytest -q tests/   # 9 passed
cd plugins/market-validation && node --test 'tests/js/*.test.mjs'      # 5 pass
```

| Suite | Location | Count (2026-07-02) | What it proves |
|---|---|---|---|
| market-validation pytest | `plugins/market-validation/tests/` | 6 | `assets/build_deck.py` renders golden + minimal deck-data; `assets/market-map/emit_market_map.py` shape + referential integrity |
| build-options pytest | `plugins/build-options/tests/` | 9 | `assets/build_matrix.py` renders golden + minimal decision matrix; `assets/weighting.py` aggregate/weighting/tie math |
| market-validation JS | `plugins/market-validation/tests/js/` | 5 | `assets/research-workflow.js` investigator retry / looser-schema fallback / named-drop behavior, via the harness (below) |

### The glob-form rule (Node)

`node --test tests/js/` (directory form) **fails** on this repo with
`Error: Cannot find module '…/tests/js'` (`code: 'MODULE_NOT_FOUND'`) — verified
2026-07-02 on Node v24.16.0. Always use the **quoted glob form**:
`node --test 'tests/js/*.test.mjs'`. The quotes matter: they hand the glob to Node's
own expansion instead of the shell's, which keeps the command portable. This is defect
ledger item #3 (the JS suite is absent from the README entirely).

Both pytest suites are cwd-tolerant *internally* (test files resolve `ROOT` from
`__file__`), but the path argument you pass to pytest is cwd-relative — so either run
from the plugin dir with `tests/`, or from repo root with the full `plugins/<name>/tests` path.

## The Function-wrapper harness pattern

**Problem:** `assets/research-workflow.js` (and build-options'
`assets/build-options-workflow.js`) are **Workflow scripts**, not ES modules. The
Workflow tool runs them by wrapping the body in an async function and injecting the
globals `agent`, `parallel`, `phase`, `log`, `args`. The scripts legitimately use
**top-level `await` and a top-level `return`** — the `return` is illegal in a plain
module, so `import()` throws a SyntaxError. You cannot unit-test them the normal way.

**Solution:** `plugins/market-validation/tests/js/harness.mjs` replicates the Workflow
runtime (~53 lines). Read it — it is the reference implementation. What it does:

1. Reads the **real, unmodified** source from disk (`../../assets/research-workflow.js`
   relative to the harness) — tests exercise the shipped bytes, never a copy.
2. Strips the one piece of module sugar: `src.replace(/^export\s+const\s+meta/m, 'const meta')`.
3. Wraps: `new Function('agent','parallel','phase','log','args', 'return (async () => {\n' + body + '\n})();')`
   — top-level `await`/`return` are now legal (they're inside the async wrapper).
4. Injects stubs. `runWorkflow(stubs)` accepts `{ agent, parallel?, phase?, log?, args }`:
   - `agent(prompt, opts)` — your stub; `opts.label` identifies the call
     (`investigate:<key>`, `investigate-loose:<key>`, `curate`, `verify:<i>`, `synthesize`).
     The harness records every label in order.
   - `parallel` defaults to `Promise.all` over thunks. The real Workflow runtime's
     `parallel()` semantics are **UNVERIFIED** — the suite's last test deliberately
     re-runs under an `allSettled`-style stub to prove recovery holds either way. Keep
     that both-ways discipline in new tests.
   - `phase`/`log` default to no-ops / a recorder; `args` defaults to `{}`.
5. Returns `{ result, logs, agentCalls }` — assert on the workflow's return value, its
   log lines (e.g. `DROPPED ANGLE`), and the ordered label list.

**Honesty boundary:** the harness proves the script's *logic under stubs*. It does NOT
prove the script runs under the real Workflow tool — both workflow scripts are still
labeled **"proven on 2026-07-02"** (before that: "syntax-checked only"; the harness remains a simulation — the live-runtime proof lives in the campaign spec)
(defect ledger #4; the proving run is **fs-flagship-chain-campaign** scope).

## How to add a test to each suite

**Python (either plugin):** drop `test_<thing>.py` in the plugin's `tests/` — pytest
auto-discovers, no registration. Follow the existing patterns:
- Testing a *script* asset (`build_deck.py`, `build_matrix.py`): copy the script AND its
  HTML template into a `tempfile.mkdtemp()` dir, run it via
  `subprocess.run([sys.executable, ...], cwd=work)`, assert on returncode + emitted HTML
  (see `test_build_matrix.py::_render`). The copy-template step is load-bearing because
  the test copies the *script itself* into the temp dir: the script resolves its template
  via `Path(__file__).parent` (never cwd — see fs-plugin-anatomy §6 rule 3), so the
  template must travel with the copied script.
- Testing an *importable* asset (`weighting.py`, `enrich`): `sys.path.insert(0, str(ROOT))`
  then `from assets import ...` (see `test_weighting.py`).
- Golden inputs live in `references/example-shiftmate/` (`deck-data.json`,
  `decision-data.json`) — reuse them; add a minimal-input test for any new render path.

**JS (workflow scripts):** drop `<name>.test.mjs` in
`plugins/market-validation/tests/js/` — the glob picks it up. Import
`{ runWorkflow } from './harness.mjs'`, build a stateful `agent` stub keyed on
`opts.label`, and assert on `logs`/`result`/`agentCalls`. Keep downstream phases
trivially valid (return `{claims:[],competitors:[]}` for `curate`, a confirm verdict
for `verify:*`) so the run completes and your test stays focused.

**Extending the harness to build-options (open/candidate):**
`plugins/build-options/assets/build-options-workflow.js` currently has **no JS tests**
(verified 2026-07-02 — build-options ships only the pytest suite). It uses the same
`export const meta` + injected-globals shape, so the harness pattern transplants: copy
`harness.mjs` into a new `plugins/build-options/tests/js/`, change the `WORKFLOW` path
constant, and re-derive the label conventions from that script before asserting on them
(do NOT assume market-validation's labels). This is an improvement candidate, not an
instruction — adding a whole new suite is a change; route it per **fs-change-control**.

## Symptom → triage

| Symptom (verbatim) | Cause | Fix |
|---|---|---|
| `/usr/bin/python3: No module named pytest` | Host Python is PEP-668; pytest was never system-installed | Use the venv: `$VENV/bin/python -m pytest ...` (Setup section) |
| `error: externally-managed-environment` from pip | You ran `pip install` against the system Python | Never `--break-system-packages`; create the venv and install there |
| `Error: Cannot find module '…/tests/js'` / `code: 'MODULE_NOT_FOUND'` from `node --test` | Directory form; Node here doesn't auto-discover a bare dir arg | Quoted glob form: `node --test 'tests/js/*.test.mjs'` |
| `MODULE_NOT_FOUND` naming `tests/js/*.test.mjs` literally | Glob didn't match — wrong cwd (pattern is cwd-relative) | Run from the plugin dir, or use the full `plugins/market-validation/tests/js/*.test.mjs` glob from repo root |
| `SyntaxError: Illegal return statement` importing a workflow script | You `import()`ed a Workflow script directly | They aren't modules; test through the Function-wrapper harness |
| `FileNotFoundError: … assets/matrix.template.html` (build-options, 2 tests) | The gitignore-swallow defect: `*.html` in the plugin `.gitignore` ate the template; your checkout predates the 2026-07-02 rescue (repo fix uncommitted as of that date) | Confirm `git ls-files` tracks `plugins/build-options/assets/matrix.template.html` and `.gitignore` has the `!assets/matrix.template.html` negation; full story + rescue source in **fs-failure-archaeology** |
| `claude: command not found` | Claude Code CLI absent (it lives at `~/.local/bin/claude` on the reference host — environment-specific) | Not needed for any test suite. Needed for `claude plugin validate` in `scripts/add-skill.sh` and the pre-push gate — install Claude Code or skip validate-dependent steps and say so |
| pytest collects 0 tests | Wrong path arg (e.g. ran `pytest -q tests/` from repo root) | Pass the real path: `plugins/<name>/tests` from root, or `cd` into the plugin first |
| Both pytest suites at once report import collisions | Should not happen — test module names are unique across plugins (verified: combined run = 15 passed, 2026-07-02) | If it appears after adding files, rename the new `test_*.py` to be repo-unique |

## Known limitations (keep your honesty consistent)

- Pass counts (6/9/5) are a **2026-07-02 snapshot**; re-verify, don't cite stale numbers.
- Green suites ≠ working plugins: `claude plugin validate` is manifest-schema-only and
  the workflow scripts are unproven under the real Workflow runtime (ledger #4, #7).
- The 9/9 build-options result depends on the template rescue, which was **uncommitted**
  as of 2026-07-02 — a fresh clone may still be broken until the operator commits it.
- No lint, no type-check, no coverage tooling exists here — the three suites plus the
  pre-push gate (**fs-release-and-publish**) are the entire verification surface.

## Provenance and maintenance

All claims verified live on 2026-07-02 against repo HEAD `2e4c9dd` (plus the uncommitted
template rescue). One-line re-verification for anything that may drift:

```bash
python3 --version && node --version                      # host toolchain (was 3.13.5 / v24.16.0)
python3 -m pytest --version                              # still fails system-wide? (PEP-668 claim)
$VENV/bin/python -m pytest -q plugins/market-validation/tests plugins/build-options/tests  # was 15 passed
node --test 'plugins/market-validation/tests/js/*.test.mjs'                                # was pass 5
node --test plugins/market-validation/tests/js/ 2>&1 | grep MODULE_NOT_FOUND               # directory form still broken?
git ls-files plugins/build-options/assets/matrix.template.html   # empty output = rescue not committed yet
grep -n 'python3 -m pytest' README.md                    # README still ships the failing verbatim form?
ls plugins/build-options/tests/js 2>/dev/null            # still absent = harness-transplant candidate still open
claude --version                                         # CLI presence (validate steps only)
```

## References

- `plugins/market-validation/tests/js/harness.mjs` — the reference Function-wrapper harness.
- `plugins/market-validation/tests/js/research-workflow.retry.test.mjs` — model JS test (stateful stub, both-parallel-semantics discipline).
- `plugins/build-options/tests/test_build_matrix.py`, `plugins/market-validation/tests/test_build_deck.py` — model script-asset pytest pattern.
- `plugins/build-options/tests/test_weighting.py` — model importable-asset pytest pattern.
- `plugins/market-validation/SKILL.md` (`## Tests` section) — the per-skill test-command convention new skills must follow.
