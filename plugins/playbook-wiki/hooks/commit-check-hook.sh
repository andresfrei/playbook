#!/bin/sh
# PreToolUse hook for Bash commands that run "git commit". When the commit is
# in a repository whose docs/wiki/ is at the playbook's format and differs
# from the last commit, it runs check-wiki.sh; when the check fails, it denies
# the call and gives the check's output to the agent to repair.
# Uses only sh, sed, awk, and git. Prints nothing and exits 0 in every other
# case, and when it cannot parse its input or a script is missing: it never
# blocks a commit by its own error.
plugin="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || exit 0
lib="$plugin/hooks/git-hook-lib.sh"
check="$plugin/check-wiki.sh"
[ -f "$lib" ] && [ -f "$check" ] || exit 0

# input is read by json_string, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
# shellcheck source=/dev/null
. "$lib"

command=$(json_string command)
[ -n "$command" ] || exit 0
cwd=$(json_string cwd)
[ -n "$cwd" ] || cwd=.

# The directory of the first "git ... commit"; nothing when there is none.
dir=$(git_parse commit)
[ -n "$dir" ] || exit 0

root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$root" ] && [ -d "$root/docs/wiki" ] || exit 0

# A wiki below the playbook's format, or with no marker, is left to the doctor.
present=$(sh "$check" --format 2>/dev/null)
marker=$(head -n 1 "$root/docs/wiki/.format" 2>/dev/null | tr -d ' \t\r')
case $present in '' | *[!0-9]*) exit 0 ;; esac
# Ten characters or more is no number to the check either.
case $marker in '' | *[!0-9]* | ??????????*) exit 0 ;; esac
[ "$marker" -ge "$present" ] || exit 0

# Anything under docs/wiki/ that differs from the last commit, staged or not,
# new files included. In "git add -A && git commit" nothing is staged yet.
changed=$(git -C "$root" status --porcelain --untracked-files=all -- docs/wiki 2>/dev/null)
[ -n "$changed" ] || exit 0

output=$(sh "$check" "$root/docs/wiki" 2>&1)
[ $? -eq 1 ] || exit 0

text=$(json_lines "The check of this wiki failed, and the commit is stopped until it passes. Repair what it lists, then commit again.
$output")
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$text"
