#!/usr/bin/env bash
# site-checks.sh — read-only verification gate for docs/index.html (the Pages site).
# Run from the repo root: bash .claude/skills/fs-site-and-positioning/scripts/site-checks.sh
# Exit 0 = all checks pass. Any failure prints FAIL and exits 1.
# Origin: the scripted gate in docs/superpowers/specs/2026-06-11-skill-sites-family-design.md,
# extended 2026-07-02 with the oversell watch (defect ledger #6).
set -u
SITE="docs/index.html"
fail=0
note() { printf '%s\n' "$*"; }

[ -f "$SITE" ] || { note "FAIL: $SITE not found — run from the repo root"; exit 1; }

# 1. Forbidden strings (spec gate): dead CTAs, zip installs, unsanitized names.
if grep -nE 'releases/latest|zip|Codex|workflow-atlas|href="#"' "$SITE"; then
  note "FAIL: forbidden string present (see lines above)"; fail=1
else
  note "ok: forbidden-string sweep clean"
fi

# 2. Oversell watch (defect ledger #6 — these are EXPECTED to hit until the
#    operator-gated correction ships; the check tells you whether it has).
if grep -nE '~0 tokens|runs itself weekly' "$SITE"; then
  note "OPEN: oversell strings still present (defect #6 — known, operator-gated)"
else
  note "ok: oversell strings gone (defect #6 resolved — update the skill + ledger)"
fi

# 3. Card count must equal the number the copy claims (currently: twelve).
cards=$(grep -c '<div class="card">' "$SITE")
if [ "$cards" -ne 12 ]; then
  note "FAIL: card count is $cards, copy claims twelve — fix copy or cards"; fail=1
else
  note "ok: 12 cards == 'twelve skills' claim"
fi

# 4. HTML well-formedness (stack check via stdlib html.parser; no pip deps).
python3 - "$SITE" <<'EOF' || fail=1
import sys
from html.parser import HTMLParser
VOID={'meta','link','br','img','hr','input','source','wbr'}
class P(HTMLParser):
    def __init__(self):
        super().__init__(); self.stack=[]; self.errs=[]
    def handle_starttag(self,t,a):
        if t not in VOID: self.stack.append(t)
    def handle_endtag(self,t):
        if not self.stack or self.stack.pop()!=t: self.errs.append((t,self.getpos()))
p=P(); p.feed(open(sys.argv[1]).read())
if p.errs or p.stack:
    print(f"FAIL: HTML not well-formed: errs={p.errs} unclosed={p.stack}"); sys.exit(1)
print("ok: HTML well-formed")
EOF

# 5. Attribution footer must be intact (doctrine: mandatory, non-negotiable).
for s in 'built by' 'craigmerry.com' 'MIT' 'not affiliated with Anthropic'; do
  grep -q "$s" "$SITE" || { note "FAIL: footer missing '$s'"; fail=1; }
done
[ "$fail" -eq 0 ] && note "ok: attribution footer intact"

# 6. Every external URL curls 2xx/3xx. Skip the bare fonts.googleapis.com
#    preconnect origin — it 404s as a document but is not fetched as one.
while read -r u; do
  case "$u" in https://fonts.googleapis.com) continue;; esac
  code=$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$u")
  case "$code" in
    2*|3*) : ;;
    *) note "FAIL: $code $u"; fail=1 ;;
  esac
done < <(grep -oE 'https://[^"<)]+' "$SITE" | sort -u)
[ "$fail" -eq 0 ] && note "ok: URL sweep clean (2xx)"

# 7. Live-vs-repo drift: the Pages deploy should be byte-identical to master:/docs.
#    Informational — a mismatch right after a push just means Pages hasn't rebuilt yet.
live=$(mktemp) && curl -s --max-time 20 https://craigm26.github.io/founder-skills/ -o "$live"
if diff -q "$SITE" "$live" >/dev/null 2>&1; then
  note "ok: live page byte-identical to repo copy"
else
  note "NOTE: live page differs from repo copy (uncommitted edit, or Pages still deploying)"
fi
rm -f "$live"

exit "$fail"
