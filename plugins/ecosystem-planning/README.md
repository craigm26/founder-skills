# ecosystem-planning — one plan across many repos

For changes that span **three or more repos** and must keep a shared invariant (a protocol, an
identity layer, an audit plane) intact: produces ONE approvable plan with verified facts,
per-workstream designs, a build sequence, and a re-runnable definition of done.

## Before you install

The non-negotiable principle: **schema-valid ≠ works; confident ≠ correct.** The highest-value
step is verifying cross-agent disagreements against actual code *before* writing plan prose.
`references/worked-example-robot-md.md` shows a real run — including five confidently-wrong
claims that got caught by verification and the advisor catches folded in before approval.

## What it will ask you

Only scope-shaping questions (via AskUserQuestion): depth across layers, hard-but-right vs
easy-but-partial path, whether an entangled migration is in scope, and what "done" means.

## What it produces

A single plan file: context + locked decisions → verified facts → deep workstreams for the core,
roadmap-depth for consumers → cross-cutting invariants → a re-runnable end-to-end proof →
build sequence → risks. Each workstream then feeds `/fable-orchestrated-feature-dev`.

## Cost

A few Explore + Plan subagents run in parallel (read-only), plus verification reads — moderate;
far cheaper than a wrong cross-repo plan.

## 60-second first run

```
/ecosystem-planning — "bake the commissioning self-test lesson into the CLI, gateway, and consumers"
```

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| Subagents | Parallel Explore agents (map seams) + Plan agents (design slices) | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| `AskUserQuestion` | The four scope-shaping decisions | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| Skills chaining | Output workstreams → `/fable-orchestrated-feature-dev`; proof loop → `/fable-loop-design` | [Skills](https://code.claude.com/docs/en/skills) |
