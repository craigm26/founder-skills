#!/usr/bin/env bash
#
# pre-push-gate.sh — the mandatory LOCAL pre-push gate for founder-skills.
#
# This repo has NO CI (standing org-wide rule since 2026-06-19: no GitHub
# Actions) and master live-publishes on every push. This script IS the CI.
# Run it from anywhere; it locates the repo root relative to itself.
#
# Usage:
#   .claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh          # gates 1-5
#   .claude/skills/fs-release-and-publish/scripts/pre-push-gate.sh --urls   # + gate 6 (curl URL sweep)
#
# Env:
#   FS_VENV  — venv to use for pytest (default: ~/venvs/founder-skills).
#              Created + pytest installed automatically if missing.
#
# Exit 0 = safe to push. Nonzero = DO NOT PUSH; failures are listed.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
VENV="${FS_VENV:-$HOME/venvs/founder-skills}"
DO_URLS=0
[ "${1:-}" = "--urls" ] && DO_URLS=1

FAILURES=()
WARNINGS=()
pass() { echo "  PASS  $1"; }
fail() { echo "  FAIL  $1"; FAILURES+=("$1"); }
warn() { echo "  WARN  $1"; WARNINGS+=("$1"); }

echo "== founder-skills pre-push gate =="
echo "repo: $REPO_ROOT"

# --- Gate 0: venv (host Python is PEP-668 externally managed — bare python3 -m pytest fails) ---
if [ ! -x "$VENV/bin/python" ]; then
  echo "-- creating venv at $VENV"
  python3 -m venv "$VENV" || { fail "venv creation at $VENV"; }
fi
if [ -x "$VENV/bin/python" ] && ! "$VENV/bin/python" -m pytest --version >/dev/null 2>&1; then
  echo "-- installing pytest into $VENV"
  "$VENV/bin/pip" install -q pytest || fail "pip install pytest into $VENV"
fi

# --- Gates 1+2: the two pytest suites ---
for plugin in market-validation build-options; do
  echo "-- gate: pytest $plugin"
  if (cd "$REPO_ROOT/plugins/$plugin" && "$VENV/bin/python" -m pytest -q tests/); then
    pass "pytest plugins/$plugin"
  else
    fail "pytest plugins/$plugin"
  fi
done

# --- Gate 3: node:test JS suite (GLOB form only; directory form -> MODULE_NOT_FOUND) ---
echo "-- gate: node --test (market-validation js suite)"
if (cd "$REPO_ROOT/plugins/market-validation" && node --test 'tests/js/*.test.mjs'); then
  pass "node --test plugins/market-validation/tests/js"
else
  fail "node --test plugins/market-validation/tests/js"
fi

# --- Gate 4: JSON parse of marketplace.json + every plugin.json; every listed source dir exists ---
echo "-- gate: JSON parse + marketplace source dirs"
if REPO_ROOT="$REPO_ROOT" python3 - <<'PY'
import json, os, sys, glob
root = os.environ["REPO_ROOT"]; bad = 0
files = [os.path.join(root, ".claude-plugin/marketplace.json")] + \
        sorted(glob.glob(os.path.join(root, "plugins/*/.claude-plugin/plugin.json")))
for f in files:
    try:
        json.load(open(f))
    except Exception as e:
        print(f"  JSON FAIL {os.path.relpath(f, root)}: {e}"); bad += 1
mp = json.load(open(files[0]))
for p in mp.get("plugins", []):
    src = p.get("source")
    src = src if isinstance(src, str) else (src or {}).get("path", "")
    if not os.path.isdir(os.path.join(root, src)):
        print(f"  MISSING source dir for plugin '{p.get('name')}': {src}"); bad += 1
print(f"  checked {len(files)} JSON files + {len(mp.get('plugins', []))} marketplace source dirs")
sys.exit(1 if bad else 0)
PY
then pass "JSON parse + source dirs"; else fail "JSON parse + source dirs"; fi

# --- Gate 5: sanitization grep (hard gate, doctrine: zero hits over the public dirs) ---
# Pattern extends the plugins/-only, case-sensitive gate in
# docs/superpowers/plans/2026-06-11-publish-private-six.md to the doctrine scope
# (fs-doctrine-and-honesty Rule 3): case-insensitive, over plugins/ docs/ README.md
# .claude-plugin/, excluding docs/superpowers (specs/plans name the banned strings).
echo "-- gate: sanitization grep over public dirs (plugins/ docs/ README.md .claude-plugin/)"
SAN_PATTERN='reservoir|sk_live|sk_test|cfut_|/home/craigm26|castor-dash|/opt/robot-md|/etc/robot-md'
HITS="$(grep -rIniE "$SAN_PATTERN" \
        "$REPO_ROOT/plugins/" "$REPO_ROOT/docs/" "$REPO_ROOT/README.md" "$REPO_ROOT/.claude-plugin/" \
        --exclude-dir=superpowers \
        --exclude-dir=.pytest_cache --exclude-dir=__pycache__ --exclude-dir=node_modules 2>/dev/null || true)"
if [ -z "$HITS" ]; then
  pass "sanitization grep (zero hits)"
else
  echo "$HITS" | sed 's/^/    /'
  fail "sanitization grep — the lines above must not ship publicly"
fi

# --- Gate 6 (optional, --urls): live-URL sweep over plugins/ ---
if [ "$DO_URLS" = 1 ]; then
  echo "-- gate: curl URL sweep over plugins/ (network required)"
  # Placeholder hosts used in worked examples are excluded — they are fixtures, not claims.
  URLS="$(grep -rhoIE 'https?://[^ )">,`]+' "$REPO_ROOT/plugins/" \
          --exclude-dir=.pytest_cache --exclude-dir=__pycache__ 2>/dev/null \
          | sed 's/[].,;:)"'"'"']*$//' \
          | grep -vE '^https?://(example\.(com|org|net)|localhost|127\.0\.0\.1|x)([:/]|$)' \
          | sort -u)"
  URL_BAD=0
  while IFS= read -r u; do
    [ -z "$u" ] && continue
    code="$(curl -s -o /dev/null -L -m 20 -A 'founder-skills-pre-push-gate' -w '%{http_code}' "$u" 2>/dev/null)"
    code="${code:-000}"
    case "$code" in
      2*|3*) : ;;
      401|403|405|429) warn "URL $code (bot-blocked? verify manually): $u" ;;
      *) echo "    DEAD $code $u"; URL_BAD=$((URL_BAD+1)) ;;
    esac
  done <<< "$URLS"
  if [ "$URL_BAD" = 0 ]; then pass "URL sweep ($(echo "$URLS" | grep -c .) unique URLs)"; else fail "URL sweep — $URL_BAD dead URL(s)"; fi
fi

echo
echo "== summary =="
[ "${#WARNINGS[@]}" -gt 0 ] && printf 'WARN: %s\n' "${WARNINGS[@]}"
if [ "${#FAILURES[@]}" -eq 0 ]; then
  echo "ALL GATES PASSED — safe to push."
  exit 0
else
  printf 'FAILED: %s\n' "${FAILURES[@]}"
  echo "DO NOT PUSH."
  exit 1
fi
