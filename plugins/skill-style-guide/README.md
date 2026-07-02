# skill-style-guide — should every skill in your marketplace read like one author wrote it?

A written house style for Claude Code skill marketplaces: frontmatter rules, trigger-rich
descriptions, two body skeletons (chain skills vs. audit skills), the recurring honesty and Tests
sections, a six-section plugin README template, and a conformance checklist. Extracted from a
working public 12-plugin marketplace — every rule verified against files that shipped, then
genericized so you calibrate it against your own repo's best skills.

## Before you install

This is a **reference-and-checklist skill**, not a workflow — it runs no agents and spends almost
nothing. Its one discipline is calibration: it asks you to designate a **golden set** (2–4 of your
own best skills) and a **never-copy list**, and it style-checks against those, not against the
source marketplace. The thresholds it ships (line norms, section names) are defaults from one
repo, clearly labeled as such — you are expected to re-derive them in yours with the bundled
one-liner commands.

## What it will ask you

Nothing on a pure lookup ("what's the frontmatter rule?"). On a first style-check in a repo, one
`AskUserQuestion`:

1. **Golden set** — which 2–4 skills in this marketplace are the reference implementations
2. **Never-copy list** — any skills whose style should not be propagated (external imports, legacy)

## What it produces

- A **conformance report** against the 16-item checklist (pass/fail per item, with the offending
  line quoted)
- Suggested edits in house style (frontmatter rewrites, description trigger lists, section
  scaffolds)
- On request, a scaffolded `SKILL.md` or six-section plugin `README.md` skeleton for a new skill

## Cost

Negligible — the skill body is a few hundred tokens to load; a style-check reads the target
SKILL.md/README and reports. No subagents, no web research (except live-verifying "Built on" doc
links when you write a README, which is a handful of fetches).

## 60-second first run

```
/skill-style-guide — "style-check plugins/<name>/SKILL.md"
```

Name your golden set when asked, then read the conformance report and apply (or reject) the
suggested edits. Re-run after editing; a clean pass is 16/16 checklist items.

## Built on

| Platform primitive | Role here | Docs |
|---|---|---|
| Agent Skills (SKILL.md) | The artifact this skill sets the style contract for | [Skills](https://code.claude.com/docs/en/skills) |
| Plugins & marketplaces | The packaging layer the README template and manifest rules target | [Plugins](https://code.claude.com/docs/en/plugins) · [Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) |
| `AskUserQuestion` | The one-time golden-set calibration question | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
