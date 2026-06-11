# Worked example — robot-md / RCAN / RRF / OpenCastor / PlatAtlas (2026-06)

The run this skill is generalized from. Concrete enough to copy the moves.

## Artifacts produced
- Lesson (anchor): `LESSONS_10min_robot.md` (the project scratch dir) — written from a real, recorded hardware win
  (autonomous vision pick-and-place on Bob, SO-ARM101 + OAK-D + Pi 5) after ~3 sessions of "almost."
- Final plan: a single plan file in `~/.claude/plans/`.

## 1. The anchoring lesson
Root cause of every prior failure was a **calibration-vs-reality gap**: the actuator `config.py` mapped the
gripper rad interface to ticks 2048–2367, but real jaw travel is open≈1700/close≈1200 — so "close" (tick
2048) was *wider than open* and the jaws never shut. `validate` passed schema; `doctor` saw the driver
respond; nothing checked that **declared ranges actually move the hardware**. Fix: drive the gripper in raw
ticks (a small raw-tick driver script); proof = stall tick 1529 held through the lift. Thesis: *schema-valid ≠
works.* The six lessons (commission self-test, teach-free IK-free vision cal, BYO-camera, teach/record,
raw-tick escape hatch, record-the-attempt) each became a capability.

## 2. Ecosystem map (one read-only sweep)
Found: the `robot-md` repo (CLI at `cli/src/robot_md`), `robot-md-gateway`, `robot-md-mcp`, the RCAN trio
(`rcan-py`/`rcan-ts`/`rcan-spec`), consumers `OpenCastor` + `workflow-atlas` (PlatAtlas); actuators
`so_arm101_actuator` + `oak_d_actuator` as **installed wheels** (the source repo existed
but the install was a wheel, not editable); the gateway ran as a systemd service from
its own deployed venv, with config in a system config dir.

## 3. The four scope-shaping decisions (AskUserQuestion)
1. Depth → **deep core (robot-md + gateway) + roadmap tail (OpenCastor, PlatAtlas)**.
2. Hardware path → **gateway commissioning-mode** (run through the gateway, not `systemctl stop`).
3. Crypto → **unify in this plan** (gateway → rcan-py/rcan-ts ML-DSA-65 + RRN binding + manifest HITL).
4. Done → **re-runnable <10-min RCAN-gated bring-up on Bob**.

## 4. Fan-out: 3 Explore agents → 3 Plan agents
- Explore: (a) robot-md CLI structure, (b) gateway + RCAN + RRF, (c) MCP + OpenCastor + PlatAtlas seams.
- Plan: (a) CLI capabilities + schema, (b) gateway mode + crypto, (c) roadmap + the 10-min proof.
Each Plan agent got the exploration findings, the four locked decisions, and the **shared tool-name
contract** (`set_torque`/`raw_tick_move`/`commission_probe`/`paced_move`) so the CLI and gateway designs
matched at the seam.

## 5. Cross-agent disagreements that got VERIFIED before writing (the key step)
| Claim | Source | Verified result |
|---|---|---|
| Gateway actuator is a NoOp stub (arm won't move via gateway) | Plan agent C | **FALSE** — `resolve_actuator('so-arm101')` → real `SOArm101Actuator`. Only `read_state` proven through gateway so far → became the #1 HIL risk to validate early. |
| `so_arm101_actuator` is install-only / no source | Plan agent A | **PARTLY** — wheel v0.2.1 installed *and* source repo `~/so-arm101-actuator` exists → edits need rebuild+reinstall into the gateway venv. |
| Need to ADD gripper open/close-steps to the schema | implied | **FALSE** — `physics.solver.gripper.open_steps/close_steps` already present (schema:202–210) → fix = consume existing fields. |
| Use `rcan.signing.verify_message` for the gateway | brief framing | **FALSE** — needs a fixed RCANMessage schema; right primitives are `rcan.hybrid.verify_body` + `rcan.crypto.verify_hybrid` (confirmed in v3.4.0). |
| RRF needs changes to serve PQ keys | open question | **FALSE** — `/v2/keys/[kid]` already returns `pq_public_key_b64`+`pq_kid` → gateway just reads them. |

Every row changed the plan. The "Verified facts" section was written from these, not from the assertions.

## 6. Advisor catches folded in before ExitPlanMode
1. **Missing manifest write → re-sign → deploy → reload loop** — signed-footer ops fail-closed (403) after
   any ruamel write; CLI writes working `ROBOT.md` while gateway enforces `/etc/.../ROBOT.md`. Added a
   `resign_and_deploy` helper + a two-cutover sequencing rule, in budget.
2. **Gateway `move()` poll-to-tolerance times out on sagging joints** — the exact bug we'd fixed with
   `slow_move`. Added a `paced_move` (issue-and-pace) gateway tool; productized motion uses it, never
   poll-to-tolerance.
3. **calibrate-vision productized the ABANDONED map** — the proven pick uses the arc model (`arc_map.json`),
   not PixelJointMap/XYZJointMap (which blew up). Made `--kind arc` the default; general map marked
   unvalidated-at-scale.
4. (Safety) `commission_probe` made current-limited with abort-on-early-stall (declared endpoints may be
   wrong — don't grind the gearing into a bad declared stop).

## 7. Plan shape that resulted
Context → Verified facts → Workstream A (CLI+schema, deep) → B (gateway+crypto, deep) → C (MCP) →
D/E (OpenCastor/PlatAtlas roadmap) → Cross-cutting (re-sign/deploy loop; corr_id thread) → 10-minute proof
(DoD) → Build sequence (no-hardware/no-crypto foundations first; validate gateway motion early) →
Verification (unit + HIL + cutover gates) → 7 open risks.
