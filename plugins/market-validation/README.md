# market-validation — is there a real market for this?

Turns a product idea into a defensible, **cited** market-evidence pack: a multi-angle web-research
workflow with mandatory live-URL verification, a Tufte-style HTML deck (with PDF/PPTX export), a
build/integrate brief, and a market-map graph of the competitive landscape.

## Before you install

This is the heavyweight skill in the chain. A full run is a deliberate spend, not a quick lookup —
a MEASURED minimum run (4 default angles, 30 agents) was **1,134,356 tokens in ~20 minutes** on 2026-07-02; the full-fidelity reference run was **~1.5M tokens, ~38 agents, ~50 minutes**. The skill tells you this up front
and confirms scope before launching anything. Its core discipline is non-negotiable: every claim
that survives into the evidence pack has a **live-verified URL**, and a counter-evidence research
angle always runs alongside the supportive ones.

## What it will ask you

One `AskUserQuestion` call (Phase 0):

1. **Geography** — US only / US + adjacent / global
2. **Customer segment** — the core buyer
3. **Proof angles to prioritize** — pain / competitor / willingness-to-pay / market-size (multi-select)

It then shows you the composed research **angle set** before launching the workflow, because the
angle set determines the spend.

## What it produces

- `deck-data.json` — the single source of truth for every artifact
- A markdown **evidence pack** (every claim cited, counter-evidence included, confidence rated)
- `<slug>.html` — a self-contained Tufte deck with clickable citations (+ `.pdf` / `.pptx` when the
  toolchain is present)
- `market-map/nodes.json` + `flows.json` — the competitive landscape as a small graph
  (contract: [`references/market-map-schema.md`](references/market-map-schema.md); destinations:
  [`references/sinks.md`](references/sinks.md))
- A **build/integrate brief** from the verdict

## Cost

Measured: 1,134,356 tokens / ~20 min for a 4-angle minimum run (2026-07-02); ~1.5M tokens / ~45–60 min for a full run. Scope it down in Phase 0 (fewer angles, narrower
geography) for a cheaper pass.

## 60-second first run

```
/market-validation  — "is there a market for <your idea>?"
```

Answer the three scope questions, review the proposed angle set, approve the launch. Come back to
a cited evidence pack and a deck. A full worked example (fictional **ShiftMate**, a shift-swap
marketplace) ships in [`references/example-shiftmate/`](references/example-shiftmate/).

## Built on

| Anthropic primitive | Role here | Docs |
|---|---|---|
| `Workflow` tool | Deterministic fan-out: investigate → curate → live-verify → synthesize | [Agent SDK](https://code.claude.com/docs/en/agent-sdk/overview) |
| Subagents | ~38 parallel investigators, verifiers, synthesizers | [Subagents](https://code.claude.com/docs/en/sub-agents) |
| `AskUserQuestion` | Phase-0 scoping | [Interactive mode](https://code.claude.com/docs/en/interactive-mode) |
| Web search + fetch | Every surviving claim is checked against its live URL | [Tool use](https://platform.claude.com/docs/en/docs/agents-and-tools/tool-use/overview) |
