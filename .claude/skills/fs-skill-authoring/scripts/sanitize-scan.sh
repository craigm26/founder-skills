#!/usr/bin/env bash
#
# sanitize-scan.sh — the scripted half of the sanitize-and-graduate hard gate.
# Pattern list sourced from docs/superpowers/specs/2026-06-11-publish-private-six-design.md
# ("Sanitization requirements (hard gate)") plus the doctrine ban on
# "Anthropic internal research" claims. Zero hits required before anything ships public.
#
# Usage:  .claude/skills/fs-skill-authoring/scripts/sanitize-scan.sh <path> [<path> ...]
#         (paths are files or directories; typically plugins/<name>/)
# Exit:   0 = clean, 1 = hits found (printed file:line), 2 = usage error.
#
# NOTE: 'reservoir' matches generic English uses too — every hit needs a human
# eyeball, but the gate is: zero hits, or each hit explicitly waived in the spec.
set -euo pipefail
[ $# -ge 1 ] || { echo "usage: $0 <path> [<path> ...]" >&2; exit 2; }

PATTERNS=(
  'sk_live'                        # live secret-key prefix
  'sk_test'                        # test secret-key prefix
  'cfut_'                          # Cloudflare user token prefix
  'Bearer [A-Za-z0-9_.\-]{16,}'    # inline bearer token values
  '/home/craigm26'                 # personal home-dir paths
  'reservoir'                      # client org name (case-insensitive; expect false positives)
  'parcelriskreport'               # real-project example filenames -> must be genericized
  "Anthropic'?.?s? internal research"  # banned claim (doctrine)
)

status=0
for p in "${PATTERNS[@]}"; do
  if hits=$(grep -rniE \
      --exclude-dir=.git --exclude-dir=__pycache__ --exclude-dir=.pytest_cache \
      -- "$p" "$@" 2>/dev/null); then
    echo "HIT pattern: $p"
    echo "$hits" | sed 's/^/  /'
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "clean: no sanitization hits in: $*"
fi
exit $status
