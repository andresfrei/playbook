#!/bin/sh
# PreToolUse: for a git commit (an "if" filter of hooks.json matched, and the
# command itself commits).
# When the repository has docs/playbook/ with changes since the last commit, it runs
# the check of the wiki and denies the commit when the check fails. It finds the
# repository from "cd <dir>" at the start of the command or "git -C <dir>", else
# the session's folder. On any error of its own it lets the commit through.
# shellcheck disable=SC1091 # lib.sh is sourced at run time.
. "${CLAUDE_PLUGIN_ROOT}/hooks/lib.sh"
command=$(field command)
has git commit || exit 0
cwd=$(field cwd)
dir=${cwd:-.}
first=$(printf '%s' "$command" | awk '$1 == "cd" && $2 != "" { d = $2; sub(/[;&|].*/, "", d); print d; exit }')
other=$(printf '%s' "$command" | awk '{ for (i = 1; i < NF; i++) if ($i == "git" && $(i + 1) == "-C" && i + 2 <= NF) { d = $(i + 2); sub(/[;&|].*/, "", d); print d; exit } }')
for d in $first $other; do
  case $d in /*) dir=$d ;; *) dir=$dir/$d ;; esac
done
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -d "$root/docs/playbook" ] || exit 0
[ -n "$(git -C "$root" status --porcelain --untracked-files=all -- docs/playbook 2>/dev/null)" ] || exit 0
output=$(sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" "$root/docs/playbook" 2>&1) && exit 0
reason=$(printf 'The check of the wiki failed; the commit is stopped. Repair what it lists, then commit again.\n%s' "$output" |
  awk '{ gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, " "); printf "%s%s", (NR > 1 ? "\\n" : ""), $0 }')
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
