# founder-skills

Claude Code skills for founders and builders: **validate whether a market is real, then decide what to build** — with cited research and an auditable decision matrix.

This repo is a [Claude Code plugin marketplace](https://docs.anthropic.com/en/docs/claude-code/plugins) hosting one plugin, **`founder-suite`**, which bundles two skills.

## Install

```
/plugin marketplace add craigm26/founder-skills
/plugin install founder-suite@founder-skills
```

Then just talk to Claude Code naturally — the skills activate on intent (see triggers below).

## What's inside

### `market-validation`
Validate whether there is a real market for a product idea, end to end:
scope questions → a multi-angle web-research workflow with **mandatory live-URL verification** → a cited evidence pack → a Tufte HTML deck + PDF + PPTX → a build/integrate brief and an emitted workflow-atlas market map.

**Triggers:** "is there a market for X", "validate demand for", "prove the market for", "should I build X", "competitor + willingness-to-pay evidence for X".

### `build-options`
Decide **what** to build once a market is validated: generate divergent build options → score them with an independent judge panel into a **weighted decision matrix** → adversarially stress-test the top → recommend one with explicit **kill criteria** → render a Tufte decision matrix → hand the winner to the `prd` skill.

**Triggers:** "what should I build", "what are my build options", "which option should we build", or right after `market-validation`.

## The chain

```
market-validation  →  build-options  →  prd  →  tasks  →  build
   (is it real?)       (what to build)   (spec)  (plan)
```

`prd` and `tasks` are separate skills; `founder-suite` covers the first two stages.

## Worked example

Both skills ship a worked example built around a **fictional** product, **ShiftMate** (a shift-swap marketplace for hourly workers), validated against the real, public shift-scheduling market. It's illustrative — see:
- `skills/market-validation/references/example-shiftmate/`
- `skills/build-options/references/example-shiftmate/decision-data.json`

## Develop / test

Each skill is self-contained with its own tests:

```bash
cd plugins/founder-suite/skills/market-validation && python3 -m pytest -q tests/
cd plugins/founder-suite/skills/build-options     && python3 -m pytest -q tests/
```

## License

MIT © 2026 Craig Merry. See [LICENSE](LICENSE).
