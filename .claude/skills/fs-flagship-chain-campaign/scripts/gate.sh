#!/usr/bin/env bash
# fs-flagship-chain-campaign gate script — measurable pass/fail per campaign phase.
# Success in this campaign is MEASURED (exit codes, counts, shapes), never judged by eye.
#
# Usage:
#   scripts/gate.sh phase0
#       Verifies the Phase 0 template rescue is intact AND all three test suites pass
#       (build-options pytest 9, market-validation pytest 6, market-validation node:test 5).
#   scripts/gate.sh phase1 <research-output.json> <build-options-output.json>
#       Verifies the SAVED return values of the two proving runs have the exact shapes
#       the downstream skill phases consume. Save each Workflow return value verbatim
#       as JSON before calling this.
#
# Exit 0 = gate PASSED (prints GATE PASS). Non-zero = FAILED (first failing check printed).
# PY: python to use for pytest. Defaults to the host venv (environment-specific path —
#     see fs-toolchain-and-tests for creating it). Falls back to python3 (will fail
#     pytest on a PEP-668 host without a venv; that failure is itself a real signal).
set -u
REPO="${REPO:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
PY="${PY:-$HOME/venvs/founder-skills/bin/python}"
[ -x "$PY" ] || PY=python3

fail() { echo "GATE FAIL: $*" >&2; exit 1; }

phase0() {
  local BO="$REPO/plugins/build-options" MV="$REPO/plugins/market-validation"
  [ -f "$BO/assets/matrix.template.html" ] \
    || fail "matrix.template.html missing — do NOT regenerate; restore the rescued copy (see SKILL.md fence F1)"
  grep -q '^!assets/matrix.template.html' "$BO/.gitignore" \
    || fail ".gitignore lacks the '!assets/matrix.template.html' negation — *.html will swallow the template again"
  local out
  out=$(cd "$BO" && "$PY" -m pytest -q tests/ 2>&1) || fail "build-options pytest failed:\n$out"
  echo "$out" | grep -q '9 passed' || fail "build-options pytest != 9 passed: $(echo "$out" | tail -1)"
  out=$(cd "$MV" && "$PY" -m pytest -q tests/ 2>&1) || fail "market-validation pytest failed:\n$out"
  echo "$out" | grep -q '6 passed' || fail "market-validation pytest != 6 passed: $(echo "$out" | tail -1)"
  out=$(cd "$MV" && node --test 'tests/js/*.test.mjs' 2>&1) || fail "node:test suite failed:\n$out"
  echo "$out" | grep -Eq 'pass 5' || fail "node:test != 5 pass: $(echo "$out" | grep -E 'pass|fail')"
  echo "GATE PASS: phase0 (template intact, gitignore negation present, 9+6 pytest, 5 node:test)"
}

phase1() {
  local RJ="${1:?usage: gate.sh phase1 <research-output.json> <build-options-output.json>}"
  local BJ="${2:?usage: gate.sh phase1 <research-output.json> <build-options-output.json>}"
  python3 - "$RJ" "$BJ" <<'EOF' || exit 1
import json, sys
def die(m): print(f"GATE FAIL: {m}", file=sys.stderr); sys.exit(1)

r = json.load(open(sys.argv[1]))
if not isinstance(r.get("report"), str) or len(r["report"]) < 500:
    die("research: 'report' missing or under 500 chars (not a real evidence pack)")
if not isinstance(r.get("survivors"), list) or not r["survivors"]:
    die("research: 'survivors' missing or empty (nothing survived verification, or shape wrong)")
if not isinstance(r.get("competitors"), list):
    die("research: 'competitors' missing or not a list")
if not isinstance(r.get("droppedCount"), int):
    die("research: 'droppedCount' missing or not an int")
for i, c in enumerate(r["survivors"]):
    if not c.get("text") or not c.get("sourceUrl"):
        die(f"research: survivor[{i}] lacks text/sourceUrl")
    v = (c.get("verify") or {}).get("verdict")
    if v not in ("confirm", "weaken"):
        die(f"research: survivor[{i}] verify.verdict={v!r} (a 'drop' leaked past the filter)")

b = json.load(open(sys.argv[2]))
opts = b.get("options")
if not isinstance(opts, list) or not opts:
    die("build-options: 'options' missing or empty")
if not isinstance(b.get("judgeCount"), int) or b["judgeCount"] < 2:
    die(f"build-options: judgeCount={b.get('judgeCount')!r} (<2 judges = no independent panel)")
crit = b.get("criteria") or []
wsum = sum(c.get("weight", 0) for c in crit)
if abs(wsum - 1.0) > 0.001:
    die(f"build-options: criteria weights sum to {wsum}, not 1.0")
ids = set()
for i, o in enumerate(opts):
    for k in ("id", "name", "lens", "scores", "adversarial"):
        if k not in o:
            die(f"build-options: options[{i}] missing '{k}'")
    ids.add(o["id"])
    if not o["scores"] or not all(isinstance(s.get("mean"), (int, float)) for s in o["scores"].values()):
        die(f"build-options: options[{i}] ({o['id']}) has empty/non-numeric scores — judges likely returned wrong optionId keys")
extra = set(b.get("stressTested") or []) - ids
if extra:
    die(f"build-options: stressTested ids not in options: {extra}")
print("GATE PASS: phase1 (both proving-run outputs shape-valid for downstream phases)")
EOF
}

case "${1:-}" in
  phase0) phase0 ;;
  phase1) shift; phase1 "$@" ;;
  *) echo "usage: gate.sh phase0 | gate.sh phase1 <research-output.json> <build-options-output.json>" >&2; exit 2 ;;
esac
