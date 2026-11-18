#!/bin/sh
# SubagentStop hook for the agent playbook-agents:review (review-trigger-7):
# writes the session's mark, which lets the next commit run without being held
# by review-before-commit.sh. Removes the marks and held commits older than
# seven days. Prints nothing and exits 0 in every case: it never stops a
# subagent.
plugin="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || exit 0
lib="$plugin/hooks/hook-lib.sh"
data=${CLAUDE_PLUGIN_DATA:-}
[ -f "$lib" ] && [ -n "$data" ] || exit 0

# input is read by json_string, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
# shellcheck source=/dev/null
. "$lib"

[ "$(json_string agent_type)" = playbook-agents:review ] || exit 0
session=$(json_string session_id)
case $session in '' | *[!A-Za-z0-9_-]*) exit 0 ;; esac

mkdir -p "$data/review" 2>/dev/null && : > "$data/review/$session" 2>/dev/null
find "$data/review" "$data/held" -type f -mtime +7 -exec rm -f {} + 2>/dev/null
exit 0
