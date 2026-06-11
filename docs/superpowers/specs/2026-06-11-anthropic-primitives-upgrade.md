# Anthropic-primitives upgrade — five fact-checked improvements to the published skills

**Date:** 2026-06-11 · **Status:** approved by operator
**Source:** fact-check of a third-party "14 steps" article against official Anthropic docs
(platform.claude.com launch doc, anthropic.com announcement, Claude API reference, migration guide).
Only claims verified against official sources are adopted.

## Changes

1. **fable-loop-design** — re-anchor on official primitives:
   - Add a proper Outcomes subsection: `user.define_outcome` event on a Managed Agents session,
     rubric required (`{type:"text"|"file"}`), Anthropic-managed grader (model not user-configurable),
     `max_iterations` default 3 / max 20, terminal results
     (satisfied / needs_revision / max_iterations_reached / failed / interrupted).
   - Restore `/goal` as a real Claude Code surface ("sets direction for the run", per the official
     migration guide) alongside `/loop` — corrects the earlier over-removal.
   - Cite the migration guide's authoritative line: "Separate fresh-context verifier sub-agents tend
     to outperform self-critique."
   - Mention CMA memory stores as the hosted persistence option for the cross-session loop.

2. **fable-org-audit** — name the real trigger mechanisms for the weekly cadence:
   new "Scheduling the cadence" section: Claude Code `/schedule` routines, or CMA scheduled
   deployments (cron + timezone, `deployment_runs` audit trail with per-firing error types,
   manual `run` endpoint for testing before committing to the schedule).

3. **fable-orchestrated-feature-dev + tasks** — document the plan-file → Outcome rubric path:
   machine-verifiable acceptance criteria (what `tasks` already produces) are exactly what Outcomes
   rubrics require ("explicit, independently gradeable criteria"). Add a hosted-executor option:
   convert the plan's acceptance criteria into a rubric, send `user.define_outcome` on a CMA session,
   the harness iterates→grades→revises. Cross-reference in both skills.

4. **effort** — "Related API primitives" note disambiguating our session-level model routing from:
   `output_config.effort` (low/medium/high/xhigh/max, per request), Task Budgets
   (`output_config.task_budget`, beta `task-budgets-2026-03-13`, min 20,000 tokens, model-visible
   countdown). Include the official finding that low effort on Fable 5 still performs very well —
   supporting the Constrained tier.

5. **fable-repo-audit + fable-org-audit** — safety-boundary paragraph (correctly stated):
   Fable 5's classifiers (cyber / bio-chem / distillation) can false-positive on security-adjacent
   audit work; refusals arrive as HTTP 200 with `stop_reason: "refusal"` (pre-output refusals
   unbilled); on the API, fallback to Opus 4.8 is **opt-in** (`fallbacks` beta param, SDK middleware,
   or manual retry) — consumer surfaces handle it automatically. Don't treat a refusal as a crash.

## Constraints

- Every claim added must trace to an official source already verified this session; no secondhand
  numbers (Parameter Golf / Continual Learning Bench percentages stay out).
- Family sanitization standard still applies (no client names, no personal paths).
- Bump changed plugins to version 0.2.0. READMEs updated only where the SKILL.md change alters
  what a user would expect ("built on" tables may gain a row).
- Sites unchanged (card descriptions remain accurate).

## Verification gate

Sanitization scan clean; all plugin.json + marketplace.json parse; pytest suites green;
URL curl-check on any newly added links; push; spot-check one live walkthrough page.
