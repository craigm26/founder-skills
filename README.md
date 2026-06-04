# founder-skills

Claude Code skills for founders and builders: **validate whether a market is real, decide what to build, then spec and plan it** — with cited research, an auditable decision matrix, and an implementation-ready PRD → task plan.

This repo is a [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) hosting installable plugins, one per skill.

## Install

```
/plugin marketplace add craigm26/founder-skills
/plugin install market-validation@founder-skills
/plugin install build-options@founder-skills
/plugin install prd@founder-skills
/plugin install tasks@founder-skills
```

Install any subset, or all for the full validate → build → spec → plan chain. Then just talk to Claude Code naturally — the skills activate on intent.

## The chain

```
market-validation  →  build-options  →  prd  →  tasks  →  build
   (is it real?)       (what to build)   (spec)  (plan)   (execute)
```

## Plugins

| Plugin | What it does | Triggers |
|---|---|---|
| **market-validation** | Multi-angle web research with **live-URL verification** → cited evidence pack → Tufte HTML deck + PDF/PPTX → a build/integrate brief + workflow-atlas market map. | "is there a market for X", "validate demand for", "should I build X" |
| **build-options** | Divergent options → independent **judge-panel weighted decision matrix** → adversarial stress-test → a recommended build with **kill criteria** → Tufte matrix → hands to `prd`. | "what should I build", "what are my build options" |
| **prd** | Self-clarify the open questions, then generate a clear, actionable, implementation-ready **Product Requirements Document**. | "create a prd", "write prd for", "spec out" |
| **tasks** | Convert a PRD markdown file into a **prd.json** task plan — granular, machine-verifiable sub-tasks with acceptance criteria. | "convert prd", "create tasks", "prd to json" |

## Worked example

`market-validation` and `build-options` ship a worked example built around a **fictional** product, **ShiftMate** (a shift-swap marketplace for hourly workers), validated against the real, public shift-scheduling market. It's illustrative — see each plugin's `references/example-shiftmate/`.

## Develop / test

Each plugin is self-contained. The two that ship tests:

```bash
cd plugins/market-validation && python3 -m pytest -q tests/
cd plugins/build-options     && python3 -m pytest -q tests/
```

## Adding a new skill to this marketplace

**Fastest — use the helper** (scaffolds the plugin, registers it in this marketplace *and* the RobotRegistryFoundation cross-list, symlinks it into `~/.claude/skills/`, and validates):

```bash
# import an existing skill from ~/.claude/skills/<name>, or scaffold a stub:
scripts/add-skill.sh <name> --desc "one-line description with triggers"
# other options: --from <dir>   --category <cat>   --no-cross-list
```

It prints the `git commit && push` commands to run for each repo (it never pushes for you). Re-running for an existing name is a no-op.

**Manual equivalent:**
1. Create `plugins/<name>/` with `SKILL.md` at its root (plus optional `assets/`, `references/`, `tests/`).
2. Add `plugins/<name>/.claude-plugin/plugin.json` (`name`, `version`, `description`, `author`, `homepage`, `license: MIT`).
3. Add an entry to `.claude-plugin/marketplace.json` with `"source": "./plugins/<name>"`.
4. Validate: `claude plugin validate plugins/<name> --strict && claude plugin validate .`
5. Commit + push. Installers update with `/plugin marketplace update founder-skills`.

## License

MIT © 2026 Craig Merry. See [LICENSE](LICENSE).
