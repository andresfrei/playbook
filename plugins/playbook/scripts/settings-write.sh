#!/bin/sh
# Writes permission rules and attribution into a Claude Code settings file
# (permissions-wizard-5). Adds, never removes; writes atomically.
#
# Usage:
#   sh settings-write.sh rule FILE allow|ask|deny RULE...
#     Adds each RULE to .permissions.<kind> of FILE, once (no duplicates, order
#     kept, existing rules first). Creates permissions and the array if missing.
#   sh settings-write.sh attribution FILE none|commit|pr
#     none   sets .attribution = false (hides both the commit trailer and PR line)
#     commit sets .attribution.commit = "" (hides the commit trailer only)
#     pr     sets .attribution.pr = ""     (hides the PR line only)
#     For commit and pr, a non-object .attribution becomes an object first; an
#     object keeps its other keys.
#
# FILE missing: created as {} (its folder too). Every other key is kept.
# Refuses (message on stderr, exit 1, FILE unchanged): FILE is a symlink; FILE is
# not valid JSON or its top level is not an object; unknown command, kind or
# value; no RULE. Without jq on PATH it says so and writes nothing.
die() { printf 'settings-write: %s\n' "$*" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || die "jq is required and was not found on PATH; nothing was written"

cmd=${1:-}
file=${2:-}
[ -n "$cmd" ] && [ -n "$file" ] || die "usage: settings-write.sh rule FILE allow|ask|deny RULE... | attribution FILE none|commit|pr"
shift 2

case $cmd in
  rule)
    kind=${1:-}
    case $kind in
      allow | ask | deny) shift ;;
      *) die "unknown kind '$kind' (use allow, ask or deny)" ;;
    esac
    [ $# -gt 0 ] || die "no RULE given"
    ;;
  attribution)
    value=${1:-}
    case $value in
      none | commit | pr) ;;
      *) die "unknown value '$value' (use none, commit or pr)" ;;
    esac
    [ $# -eq 1 ] || die "attribution takes exactly one value"
    ;;
  *) die "unknown command '$cmd' (use rule or attribution)" ;;
esac

[ -L "$file" ] && die "$file is a symlink; refusing to write through it"
if [ -e "$file" ]; then
  [ -f "$file" ] || die "$file is not a regular file"
  jq -e 'type == "object"' "$file" >/dev/null 2>&1 || die "$file is not valid JSON with an object at the top level"
fi

dir=$(dirname "$file")
mkdir -p "$dir" || die "cannot create $dir"
tmp=$(mktemp "$dir/.settings-write.XXXXXX") || die "cannot create a temporary file in $dir"
trap 'rm -f "$tmp"' EXIT

if [ -e "$file" ]; then
  cp -p "$file" "$tmp" || die "cannot prepare the temporary file"
  src=$file
else
  chmod 644 "$tmp"
  printf '{}\n' > "$tmp.new" || die "cannot prepare the temporary file"
  src=$tmp.new
  trap 'rm -f "$tmp" "$tmp.new"' EXIT
fi

case $cmd in
  rule)
    jq --arg k "$kind" '
      if (.permissions // {} | type) != "object" then error("permissions is not an object") else . end
      | if ((.permissions[$k] // []) | type) != "array" then error("permissions list is not an array") else . end
      | .permissions = (.permissions // {})
      | .permissions[$k] = (reduce $ARGS.positional[] as $r ((.permissions[$k] // []);
          if any(.[]; . == $r) then . else . + [$r] end))
    ' "$src" --args -- "$@" > "$tmp" || die "jq failed; $file unchanged"
    ;;
  attribution)
    case $value in
      none) filter='.attribution = false' ;;
      commit) filter='.attribution = (if (.attribution | type) == "object" then .attribution else {} end) | .attribution.commit = ""' ;;
      pr) filter='.attribution = (if (.attribution | type) == "object" then .attribution else {} end) | .attribution.pr = ""' ;;
    esac
    jq "$filter" "$src" > "$tmp" || die "jq failed; $file unchanged"
    ;;
esac

mv "$tmp" "$file" || die "cannot replace $file"
