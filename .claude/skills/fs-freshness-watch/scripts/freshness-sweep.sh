#!/usr/bin/env bash
# freshness-sweep.sh — read-only drift sweep for founder-skills.
# Usage:
#   ./freshness-sweep.sh [--network] [REPO_ROOT]
# Default REPO_ROOT: two levels up from this script's skill dir (the repo root),
# or pass it explicitly. --network adds live curl checks on cited URLs (off by default).
#
# The script MUTATES NOTHING. Exit code: 0 = no drift detected, 1 = drift/attention items found.
set -u

NETWORK=0
REPO=""
for arg in "$@"; do
  case "$arg" in
    --network) NETWORK=1 ;;
    *) REPO="$arg" ;;
  esac
done
if [ -z "$REPO" ]; then
  # script lives at <repo>/.claude/skills/fs-freshness-watch/scripts/
  REPO="$(cd "$(dirname "$0")/../../../.." && pwd)"
fi
cd "$REPO" || { echo "FATAL: cannot cd to $REPO"; exit 2; }
[ -f .claude-plugin/marketplace.json ] || { echo "FATAL: $REPO is not the founder-skills repo root"; exit 2; }

ATTENTION=0
flag() { ATTENTION=1; echo "  [ATTENTION] $*"; }
hdr()  { echo; echo "== $* =="; }

# Published surfaces only (handoff skills in .claude/skills are allowed to NAME models as facts).
SURFACES="plugins docs README.md .claude-plugin"

hdr "1. Model-ID inventory (published surfaces: $SURFACES)"
# Marketing names AND API IDs. If Anthropic ships new models, every count below is a bump site.
for pat in 'Opus 4\.8' 'Sonnet 4\.6' 'Haiku 4\.5' 'Fable 5' 'claude-fable-5' 'claude-opus-4-8' 'claude-sonnet-4-6'; do
  n=$(grep -rE "$pat" --include='*.md' --include='*.json' --include='*.html' $SURFACES 2>/dev/null | wc -l)
  printf "  %-18s %s occurrences\n" "$pat" "$n"
done
echo "  Per-file map (bump sites):"
grep -rlE 'Opus 4\.8|Sonnet 4\.6|Haiku 4\.5|claude-fable-5|Fable 5' \
  --include='*.md' --include='*.json' --include='*.html' $SURFACES 2>/dev/null | sort | sed 's/^/    /'

hdr "2. JSON manifests parse + version table"
fail=0
for f in plugins/*/.claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  out=$(python3 -c "import json,sys;d=json.load(open('$f'));print(d.get('name','?'),d.get('version','-'))" 2>&1) \
    && printf "  OK  %-55s %s\n" "$f" "$out" \
    || { flag "JSON PARSE FAIL: $f — $out"; fail=1; }
done
[ $fail -eq 0 ] && echo "  All manifests parse. (marketplace.json entries carry no version field; versions live in plugin.json.)"

hdr "3. Beta API surfaces cited in v0.2.0 content (last live-verified 2026-06-11)"
echo "  These are BETA Anthropic surfaces named in published skills. Re-verify against"
echo "  platform.claude.com docs if >90 days since last verification."
for pat in 'task-budgets-2026-03-13' 'user\.define_outcome' 'fallbacks'; do
  echo "  -- $pat --"
  grep -rnE "$pat" --include='*.md' plugins README.md 2>/dev/null | cut -c1-120 | sed 's/^/    /' || true
done

hdr "4. Cited doc-URL inventory (from plugins/**.md + README.md)"
# Allowlist char class (a naive [^...] class with \] breaks in ERE: backslash is not
# special inside brackets, so \] closes the class early and the pattern silently matches nothing).
URLS=$(grep -rhoE 'https?://[A-Za-z0-9._~:/?#=&%+-]+' --include='*.md' --exclude-dir='.pytest_cache' plugins README.md 2>/dev/null \
  | sed 's/[.,;]*$//' | sort -u \
  | grep -vE 'localhost|yourplatform\.com|example\.com')
echo "$URLS" | sed 's/^/  /'
if [ "$NETWORK" = "1" ]; then
  echo "  -- live check (curl, 10s timeout each) --"
  while IFS= read -r u; do
    code=$(curl -s -o /dev/null -m 10 -L -w '%{http_code}' "$u" 2>/dev/null || echo "ERR")
    case "$code" in
      2*|3*) printf "  %-4s %s\n" "$code" "$u" ;;
      *) flag "URL $u -> $code" ;;
    esac
  done <<< "$URLS"
else
  echo "  (offline mode — rerun with --network to curl each URL)"
fi

hdr "5. Installed plugin cache vs repo (environment-specific: ~/.claude/plugins/cache)"
CACHE="$HOME/.claude/plugins/cache/founder-skills"
if [ -d "$CACHE" ]; then
  for p in plugins/*/; do
    name=$(basename "$p")
    ver=$(ls "$CACHE/$name" 2>/dev/null | head -1)
    if [ -z "$ver" ]; then flag "cache missing plugin: $name"; continue; fi
    if diff -q "$CACHE/$name/$ver/SKILL.md" "$p/SKILL.md" >/dev/null 2>&1; then
      printf "  in-sync  %-32s (cache v%s)\n" "$name" "$ver"
    else
      flag "cache/repo SKILL.md DIVERGE: $name (cache v$ver) — installed users are behind or ahead"
    fi
  done
else
  echo "  cache dir not present on this machine — skipped"
fi

hdr "6. Sibling site consistency (claude-skills-site, separate repo, manual coordination)"
SIB="${SIBLING_SITE:-$HOME/projects/craigm26/claude-skills-site}"
if [ -d "$SIB" ]; then
  sc=$(grep -cE 'Opus 4\.8|Sonnet 4\.6|Haiku 4\.5|Fable 5' "$SIB/index.html" 2>/dev/null || echo 0)
  last=$(git -C "$SIB" log -1 --format='%h %ad' 2>/dev/null || echo "no git")
  echo "  $SIB : $sc model-ID mentions in index.html, last commit: $last"
  echo "  Any model bump here must be mirrored there in the same pass (no automation exists)."
else
  echo "  sibling site checkout not present at $SIB — skipped (set SIBLING_SITE=... to point at it)"
fi

hdr "7. Private-repo divergence (claude-skills — frozen historical archive)"
PRIV="${PRIVATE_REPO:-$HOME/projects/craigm26/claude-skills}"
if [ -d "$PRIV" ]; then
  last=$(git -C "$PRIV" log -1 --format='%h %ad' 2>/dev/null || echo "no git")
  echo "  last commit: $last"
  echo "  Policy (operator, 2026-07-02): public founder-skills is CANONICAL for the six graduated"
  echo "  skills; the private repo is frozen. Any commit there NEWER than 2026-06-11 (ab5bcb2) is drift:"
  case "$last" in
    ab5bcb2*) echo "  OK — still frozen at ab5bcb2." ;;
    *) flag "private repo moved past frozen point ab5bcb2: $last" ;;
  esac
else
  echo "  private repo not present on this machine — skipped"
fi

hdr "RESULT"
if [ "$ATTENTION" = "1" ]; then
  echo "  DRIFT / ATTENTION ITEMS FOUND — see [ATTENTION] lines above."
  exit 1
else
  echo "  No drift detected by automated checks. Manual items (beta-surface re-verify, URL"
  echo "  content spot-check) still apply — see SKILL.md sections 3-4."
  exit 0
fi
