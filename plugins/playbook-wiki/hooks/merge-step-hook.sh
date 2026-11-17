#!/bin/sh
# PreToolUse hook for Bash commands that run "git merge". It runs
# merge-step.sh for the ref being merged; when that lists something, it asks
# the person, showing the list, and gives the same list to the agent.
# Uses only sh, sed, and awk. Prints nothing and exits 0 when there is nothing
# to list or when it cannot parse its input: it never blocks a merge by error.
step="$(dirname "$0")/../merge-step.sh"
lib="$(dirname "$0")/git-hook-lib.sh"
[ -f "$step" ] && [ -f "$lib" ] || exit 0

# input is read by json_string, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
# shellcheck source=/dev/null
. "$lib"

command=$(json_string command)
[ -n "$command" ] || exit 0
cwd=$(json_string cwd)
[ -n "$cwd" ] || cwd=.

# The repository directory on the first line, the ref on the second, and the
# branch merged into on the third. Nothing when the command merges no ref.
parsed=$(git_parse merge)
[ -n "$parsed" ] || exit 0
repo=$(printf '%s\n' "$parsed" | sed -n 1p)
ref=$(printf '%s\n' "$parsed" | sed -n 2p)
ours=$(printf '%s\n' "$parsed" | sed -n 3p)
[ -n "$ref" ] || exit 0

list=$(sh "$step" "$ref" "$repo" "${ours:-HEAD}" 2>/dev/null)
[ -n "$list" ] || exit 0


text=$(json_lines "$list")
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s","additionalContext":"%s"}}\n' "$text" "$text"
