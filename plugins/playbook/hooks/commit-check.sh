#!/bin/sh
# PreToolUse: runs only when an "if" filter of hooks.json matched a git commit.
# When the repository has docs/wiki/ with changes since the last commit, it runs
# the check of the wiki and denies the commit when the check fails. It finds the
# repository from "cd <dir>" at the start of the command or "git -C <dir>", else
# the session's folder. On any error of its own it lets the commit through.
input=$(cat)
command=$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -n 1)
cwd=$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
dir=${cwd:-.}
first=$(printf '%s' "$command" | sed -n 's/^cd[[:space:]]\{1,\}\([^;&|[:space:]]\{1,\}\).*/\1/p')
other=$(printf '%s' "$command" | sed -n 's/.*git[[:space:]]\{1,\}-C[[:space:]]\{1,\}\([^;&|[:space:]]\{1,\}\).*/\1/p')
for d in $first $other; do
  case $d in /*) dir=$d ;; *) dir=$dir/$d ;; esac
done
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -d "$root/docs/wiki" ] || exit 0
[ -n "$(git -C "$root" status --porcelain --untracked-files=all -- docs/wiki 2>/dev/null)" ] || exit 0
output=$(sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" "$root/docs/wiki" 2>&1) && exit 0
reason=$(printf 'The check of the wiki failed; the commit is stopped. Repair what it lists, then commit again.\n%s' "$output" |
  awk '{ gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, " "); printf "%s%s", (NR > 1 ? "\\n" : ""), $0 }')
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
