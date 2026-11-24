#!/bin/sh
# Prints the table of what loads in Claude's context at startup for a project
# (one-audit-3, one-audit-4, one-audit-5).
#
# Usage: sh startup-context.sh [project-root]
#   With no argument the project root is the current folder.
# Environment (to run against a fixture in tests):
#   HOME              the user's home folder (~/.claude, ~/.claude/projects).
#   CLAUDE_MANAGED_MD the managed policy CLAUDE.md (default: the path of the
#                     system, /etc/claude-code/CLAUDE.md or the macOS one).
#   CLAUDE_PLUGIN_ROOT  the playbook plugin's root (rules.md, skills/, agents/);
#                     defaults to the folder above this script.
#
# One row per source: path | level | loads | lines | bytes | limit passed.
# Level is project, user, plugin, or managed. "Loads" is startup or on demand. The limit
# column holds a limit of Claude Code's documentation the source passes, or "-".
# The rows of skill and agent descriptions are one row per level and kind: the
# path says how many descriptions, and the bytes column holds their characters.
# The script does not read MCP servers: use `claude mcp list` and /context.
#
# Limits (memory.md, hooks.md): 200 lines per CLAUDE.md; MEMORY.md 200 lines or
# 25KB (taken as 25600 bytes); the session-start hook loads the playbook's
# rules.md and docs/playbook/README.md within 9000 characters (the hook's own
# budget, under the 10,000 of the SessionStart cap).
root=$(cd "${1:-.}" && pwd -P) || exit 1
home=${HOME:?}
plugin=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd -P)}
claude_lines=200
mem_lines=200
mem_bytes=25600
hook_budget=9000
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

nlines() { awk 'END { print NR }' "$1"; }
nbytes() { wc -c < "$1" | tr -d ' '; }

# row <path> <level> <loads> <lines> <bytes> <limit>
row() { printf '| %s | %s | %s | %s | %s | %s |\n' "$1" "$2" "$3" "$4" "$5" "$6"; }

# file_row <file> <level> <loads> <kind>: kind is claude, memory, or other.
file_row() {
  l=$(nlines "$1"); b=$(nbytes "$1"); lim=-
  case $4 in
    claude) [ "$l" -gt "$claude_lines" ] && lim="over $claude_lines lines per CLAUDE.md" ;;
    memory)
      [ "$l" -gt "$mem_lines" ] && lim="over $mem_lines lines of MEMORY.md"
      if [ "$b" -gt "$mem_bytes" ]; then
        [ "$lim" = - ] && lim="over 25KB of MEMORY.md" || lim="$lim; over 25KB"
      fi ;;
  esac
  row "$1" "$2" "$3" "$l" "$b" "$lim"
}

# setting <key>: the string value of the first settings file that sets it,
# the project's local settings, then the project's, then the user's.
settings_files() { printf '%s\n' "$root/.claude/settings.local.json" "$root/.claude/settings.json" "$home/.claude/settings.json"; }
setting() {
  settings_files | while IFS= read -r f; do
    [ -f "$f" ] || continue
    v=$(sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$f" | head -n 1)
    [ -n "$v" ] && { printf '%s\t%s\n' "$f" "$v"; break; }
  done
}

# --- CLAUDE.md and CLAUDE.local.md, their imports ---------------------------
seen=
# claude_file <file> <level> <depth>: a row for the file, then its @imports.
claude_file() {
  [ -f "$1" ] || return 0
  case "$seen" in *"
$1
"*) return 0 ;; esac
  seen="$seen
$1
"
  file_row "$1" "$2" startup claude
  [ "$3" -ge 5 ] && return 0
  grep -oE '(^|[[:space:]])@[^[:space:]]+' "$1" 2>/dev/null | sed 's/^[[:space:]]*@//' > "$tmp/imports.$3"
  while IFS= read -r imp; do
    case $imp in \~/*) imp="$home/${imp#\~/}" ;; /*) ;; *) imp="$(dirname "$1")/$imp" ;; esac
    [ -f "$imp" ] || imp=$(printf '%s' "$imp" | sed 's/[.,;:)]*$//')
    claude_file "$imp" "$2" $(($3 + 1))
  done < "$tmp/imports.$3"
}

echo '| Source | Level | Loads | Lines | Bytes | Limit passed |'
echo '|--------|-------|-------|-------|-------|--------------|'

# The managed policy CLAUDE.md and claudeMdExcludes: shown, not reasoned about.
if [ -z "${CLAUDE_MANAGED_MD:-}" ]; then
  case $(uname -s) in
    Darwin) CLAUDE_MANAGED_MD='/Library/Application Support/ClaudeCode/CLAUDE.md' ;;
    *) CLAUDE_MANAGED_MD=/etc/claude-code/CLAUDE.md ;;
  esac
fi
claude_file "$CLAUDE_MANAGED_MD" managed 0
settings_files | while IFS= read -r f; do
  [ -f "$f" ] && grep -q '"claudeMdExcludes"' "$f" && row "$f" - "claudeMdExcludes set" - - -
done

d=$root
while :; do
  lvl=user; [ "$d" = "$root" ] && lvl=project
  claude_file "$d/CLAUDE.md" "$lvl" 0
  claude_file "$d/CLAUDE.local.md" "$lvl" 0
  [ "$d" = "$home" ] || [ "$d" = / ] && break
  d=$(dirname "$d")
done
claude_file "$root/.claude/CLAUDE.md" project 0
claude_file "$home/.claude/CLAUDE.md" user 0

# --- rules ------------------------------------------------------------------
for pair in "$root/.claude/rules:project" "$home/.claude/rules:user"; do
  rdir=${pair%:*}; lvl=${pair##*:}
  [ -d "$rdir" ] || continue
  [ "$rdir" = "$root/.claude/rules" ] && [ "$root" = "$home" ] && lvl=user
  find -L "$rdir" -type f -name '*.md' 2>/dev/null | sort > "$tmp/rules"
  while IFS= read -r f; do
    if awk 'NR==1 { if ($0 !~ /^---[ \t]*$/) exit 1; next } /^---[ \t]*$/ { exit 1 } /^paths:/ { found = 1; exit } END { exit !found }' "$f"; then
      when="on demand"
    else
      when=startup
    fi
    file_row "$f" "$lvl" "$when" other
  done < "$tmp/rules"
done

# --- auto memory ------------------------------------------------------------
memdir=$(setting autoMemoryDirectory | cut -f2 | head -n 1)
case $memdir in \~/*) memdir="$home/${memdir#\~/}" ;; esac
if [ -z "$memdir" ]; then
  # The project is the main repository, so worktrees and subfolders share it.
  proj=$root
  gc=$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) && [ -n "$gc" ] && proj=$(dirname "$gc")
  folder=$(printf '%s' "$proj" | sed 's/[^A-Za-z0-9]/-/g')
  memdir=$home/.claude/projects/$folder/memory
fi
[ -f "$memdir/MEMORY.md" ] && file_row "$memdir/MEMORY.md" project startup memory

# --- the playbook's hook: rules.md and the wiki README -----------------------
rules=$plugin/rules.md
readme=$root/docs/playbook/README.md
if [ -f "$rules" ]; then
  rb=$(nbytes "$rules")
  budget=$((hook_budget - rb))
  file_row "$rules" plugin startup other
  if [ -f "$readme" ]; then
    l=$(nlines "$readme"); b=$(nbytes "$readme"); lim="within the hook budget of $budget (rules.md takes $rb of $hook_budget)"
    [ "$b" -gt "$budget" ] && lim="over the hook budget of $budget (rules.md takes $rb of $hook_budget)"
    row "$readme" project startup "$l" "$b" "$lim"
  fi
elif [ -f "$readme" ]; then
  file_row "$readme" project startup other
fi

# --- output style -----------------------------------------------------------
style=$(setting outputStyle | head -n 1)
if [ -n "$style" ]; then
  sfile=$(printf '%s' "$style" | cut -f1); sname=$(printf '%s' "$style" | cut -f2)
  case $sfile in "$root"/*) slvl=project ;; *) slvl=user ;; esac
  found=
  for sd in "$root/.claude/output-styles" "$home/.claude/output-styles"; do
    [ -f "$sd/$sname.md" ] && { found=$sd/$sname.md; break; }
  done
  if [ -n "$found" ]; then
    case $found in "$root"/*) slvl=project ;; *) slvl=user ;; esac
    file_row "$found" "$slvl" startup other
  else
    row "output style: $sname ($sfile)" "$slvl" startup - - -
  fi
fi

# --- skill and agent descriptions ---------------------------------------------
# desc_chars <file>: the characters of the description, or "off" for a skill
# with disable-model-invocation: true.
desc_chars() {
  awk '
    NR == 1 { if ($0 !~ /^---[ \t]*$/) exit; fm = 1; next }
    fm && /^---[ \t]*$/ { exit }
    fm {
      if ($0 ~ /^disable-model-invocation:[ \t]*true/) off = 1
      if (cont && $0 ~ /^[ \t]+[^ \t]/) { s = $0; sub(/^[ \t]+/, "", s); d = d " " s; next }
      cont = 0
      if ($0 ~ /^description:/) {
        s = $0; sub(/^description:[ \t]*/, "", s); cont = 1
        if (s ~ /^[>|][-+]?[ \t]*$/) s = ""
        d = s
      }
    }
    END {
      if (off) { print "off"; exit }
      sub(/^[ \t]+/, "", d)
      if (d ~ /^".*"$/ || d ~ /^'"'"'.*'"'"'$/) d = substr(d, 2, length(d) - 2)
      print length(d)
    }' "$1"
}

# tally <level> <kind> <dir>...: one row for the descriptions under the dirs.
tally() {
  tl=$1; tk=$2; shift 2
  n=0; chars=0
  for td in "$@"; do
    [ -d "$td" ] || continue
    if [ "$tk" = skills ]; then find "$td" -name SKILL.md -type f; else find "$td" -name '*.md' -type f; fi | sort > "$tmp/desc"
    while IFS= read -r f; do
      c=$(desc_chars "$f")
      [ "$c" = off ] && continue
      n=$((n + 1)); chars=$((chars + c))
    done < "$tmp/desc"
  done
  row "$tl $tk: $n descriptions (characters in the bytes column)" "$tl" startup - "$chars" -
}

# The enabled plugins: the first settings file that names one decides.
settings_files | while IFS= read -r f; do [ -f "$f" ] && cat "$f"; echo; done |
  grep -oE '"[^"]*@[^"]*"[[:space:]]*:[[:space:]]*(true|false)' | sed 's/"[[:space:]]*:[[:space:]]*/ /; s/"//g' |
  awk '!seen[$1]++ && $2 == "true" { print $1 }' > "$tmp/enabled"
pdirs=
while IFS= read -r key; do
  if [ "${key%%@*}" = playbook ]; then
    p=$plugin
  else
    p=$(awk -v k="\"$key\"" 'index($0, k) { f = 1 } f && /"installPath"/ { gsub(/.*"installPath"[ \t]*:[ \t]*"|".*/, ""); print; exit }' "$home/.claude/plugins/installed_plugins.json" 2>/dev/null)
  fi
  [ -n "$p" ] && pdirs="$pdirs $p"
done < "$tmp/enabled"
case " $pdirs " in *" $plugin "*) ;; *) pdirs="$pdirs $plugin" ;; esac

tally project skills "$root/.claude/skills"
tally project agents "$root/.claude/agents"
tally user skills "$home/.claude/skills"
tally user agents "$home/.claude/agents"
for kind in skills agents; do
  set --
  for p in $pdirs; do set -- "$@" "$p/$kind"; done
  tally plugin "$kind" "$@"
done
