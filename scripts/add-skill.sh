#!/usr/bin/env bash
#
# add-skill.sh — scaffold a new founder-skills plugin and register it in both
# marketplaces (founder-skills + the RobotRegistryFoundation cross-list) in one shot.
#
# Usage:
#   scripts/add-skill.sh <name> [--desc "one-line description with triggers"] \
#                               [--from <dir>] [--category <cat>] [--no-cross-list]
#
# Source resolution (what becomes the plugin's skill content):
#   --from <dir>                 copy SKILL.md (+ assets/references/tests) from <dir>
#   else ~/.claude/skills/<name> if it's a real dir (not a symlink), import it
#   else                         scaffold a stub SKILL.md you fill in
#
# If --desc is omitted, the description is read from the SKILL.md frontmatter.
# The skill is left as a SYMLINK at ~/.claude/skills/<name> -> this repo (one copy).
# The script makes LOCAL changes + validates; it prints the commit/push commands
# (it does not push for you).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RRF_REPO="${RRF_MARKETPLACE:-$HOME/claude-code-plugins}"
SKILLS_DIR="$HOME/.claude/skills"
AUTHOR_NAME="Craig Merry"
AUTHOR_HANDLE="craigm26"
AUTHOR_EMAIL="craigm26@gmail.com"
HOMEPAGE="https://github.com/craigm26/founder-skills"
FS_URL="https://github.com/craigm26/founder-skills.git"

die() { echo "error: $*" >&2; exit 1; }

NAME=""; DESC=""; FROM=""; CATEGORY="productivity"; CROSS_LIST=1
while [ $# -gt 0 ]; do
  case "$1" in
    --desc) DESC="${2:-}"; shift 2;;
    --from) FROM="${2:-}"; shift 2;;
    --category) CATEGORY="${2:-}"; shift 2;;
    --no-cross-list) CROSS_LIST=0; shift;;
    -h|--help) sed -n '2,22p' "$0"; exit 0;;
    -*) die "unknown flag: $1";;
    *) [ -z "$NAME" ] && NAME="$1" || die "unexpected arg: $1"; shift;;
  esac
done

[ -n "$NAME" ] || die "skill name required. usage: scripts/add-skill.sh <name> [--desc ...]"
echo "$NAME" | grep -qE '^[a-z0-9][a-z0-9-]*$' || die "name must be a lowercase slug (a-z, 0-9, -)"
PLUGIN_DIR="$REPO_ROOT/plugins/$NAME"
[ -e "$PLUGIN_DIR" ] && die "plugins/$NAME already exists"

# --- resolve source ---
if [ -n "$FROM" ]; then
  [ -f "$FROM/SKILL.md" ] || die "--from '$FROM' has no SKILL.md"; SRC="$FROM"
elif [ -d "$SKILLS_DIR/$NAME" ] && [ ! -L "$SKILLS_DIR/$NAME" ] && [ -f "$SKILLS_DIR/$NAME/SKILL.md" ]; then
  SRC="$SKILLS_DIR/$NAME"
else
  SRC=""
fi

mkdir -p "$PLUGIN_DIR/.claude-plugin"
if [ -n "$SRC" ]; then
  echo "→ importing skill from $SRC"
  rsync -a --exclude='.git' --exclude='.pytest_cache' --exclude='__pycache__' "$SRC"/ "$PLUGIN_DIR"/
  rm -rf "$PLUGIN_DIR/.claude-plugin"; mkdir -p "$PLUGIN_DIR/.claude-plugin"
else
  echo "→ scaffolding a stub SKILL.md (fill it in)"
  cat > "$PLUGIN_DIR/SKILL.md" <<EOF
---
name: $NAME
description: "${DESC:-TODO: one-line description ending with: Triggers on: ...}"
---

# $NAME

TODO: write the skill body.
EOF
fi

# --- description: from flag, else SKILL.md frontmatter ---
if [ -z "$DESC" ]; then
  DESC="$(python3 - "$PLUGIN_DIR/SKILL.md" <<'PY'
import re, sys
t = open(sys.argv[1]).read()
m = re.search(r'^---\s*\n(.*?)\n---', t, re.S)
fm = m.group(1) if m else ""
d = re.search(r'^description:\s*(.+?)\s*$', fm, re.M)
val = (d.group(1).strip().strip('"\'' ) if d else "")
# collapse folded (>-) multi-line descriptions onto one line
val = re.sub(r'\s+', ' ', val)
print(val)
PY
)"
fi
[ -n "$DESC" ] || die "no description — pass --desc or set 'description:' in SKILL.md frontmatter"

# --- write plugin.json ---
NAME="$NAME" DESC="$DESC" AUTHOR_NAME="$AUTHOR_NAME" AUTHOR_EMAIL="$AUTHOR_EMAIL" HOMEPAGE="$HOMEPAGE" \
python3 - "$PLUGIN_DIR/.claude-plugin/plugin.json" <<'PY'
import json, os, sys
obj = {
  "name": os.environ["NAME"],
  "version": "0.1.0",
  "description": os.environ["DESC"],
  "author": {"name": os.environ["AUTHOR_NAME"], "email": os.environ["AUTHOR_EMAIL"]},
  "homepage": os.environ["HOMEPAGE"],
  "license": "MIT",
}
json.dump(obj, open(sys.argv[1], "w"), indent=2); open(sys.argv[1], "a").write("\n")
PY
echo "→ wrote plugins/$NAME/.claude-plugin/plugin.json"

# --- register in a marketplace.json (idempotent); arg: local|git-subdir ---
register() {
  local file="$1" mode="$2"
  NAME="$NAME" DESC="$DESC" CATEGORY="$CATEGORY" HANDLE="$AUTHOR_HANDLE" HOMEPAGE="$HOMEPAGE" \
  FS_URL="$FS_URL" MODE="$mode" python3 - "$file" <<'PY'
import json, os, sys
f = sys.argv[1]; d = json.load(open(f)); name = os.environ["NAME"]
if any(p.get("name") == name for p in d.get("plugins", [])):
    print(f"  (already listed in {os.path.basename(os.path.dirname(os.path.dirname(f)))}/{os.path.basename(f)} — skipped)"); sys.exit(0)
src = ("./plugins/%s" % name) if os.environ["MODE"] == "local" else {
    "source": "git-subdir", "url": os.environ["FS_URL"], "path": "plugins/%s" % name}
d.setdefault("plugins", []).append({
    "name": name, "description": os.environ["DESC"],
    "author": {"name": os.environ["HANDLE"]}, "category": os.environ["CATEGORY"],
    "source": src, "homepage": os.environ["HOMEPAGE"],
})
json.dump(d, open(f, "w"), indent=2); open(f, "a").write("\n")
print("  added.")
PY
}

echo "→ registering in founder-skills marketplace"; register "$REPO_ROOT/.claude-plugin/marketplace.json" local
DID_RRF=0
if [ "$CROSS_LIST" = 1 ] && [ -f "$RRF_REPO/.claude-plugin/marketplace.json" ]; then
  echo "→ cross-listing in $RRF_REPO"; register "$RRF_REPO/.claude-plugin/marketplace.json" git-subdir; DID_RRF=1
elif [ "$CROSS_LIST" = 1 ]; then
  echo "  (RRF marketplace not found at $RRF_REPO — skipped cross-list; set RRF_MARKETPLACE to override)"
fi

# --- one copy: symlink the skill into ~/.claude/skills ---
if [ ! -L "$SKILLS_DIR/$NAME" ]; then
  rm -rf "$SKILLS_DIR/$NAME"; ln -s "$PLUGIN_DIR" "$SKILLS_DIR/$NAME"
  echo "→ symlinked $SKILLS_DIR/$NAME -> plugins/$NAME (one copy)"
fi

# --- validate ---
echo "→ validating"
claude plugin validate "$PLUGIN_DIR" --strict
claude plugin validate "$REPO_ROOT"
[ "$DID_RRF" = 1 ] && claude plugin validate "$RRF_REPO"

cat <<DONE

✅ '$NAME' scaffolded + registered. Review plugins/$NAME/SKILL.md, then publish:

  git -C "$REPO_ROOT" add -A && git -C "$REPO_ROOT" commit -m "feat: add $NAME plugin" && git -C "$REPO_ROOT" push
$( [ "$DID_RRF" = 1 ] && echo "  git -C \"$RRF_REPO\" add -A && git -C \"$RRF_REPO\" commit -m \"marketplace: cross-list $NAME\" && git -C \"$RRF_REPO\" push" )

Installers update with:  /plugin marketplace update founder-skills
DONE
