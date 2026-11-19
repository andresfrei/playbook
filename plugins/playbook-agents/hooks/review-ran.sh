#!/bin/sh
# SubagentStop hook for the agent playbook-agents:review (review-trigger-7):
# writes the session's mark, which lets the next commit run without being held
# by review-before-commit.sh. Removes the marks and held commits older than
# seven days.
#
# It also stops a review that ended with findings and started no
# playbook-agents:classify (repeated-corrections-17), by printing
# {"decision":"block","reason":...}, which keeps the review running with the
# reason as its next instruction. It blocks only when the review is of that
# agent type, stop_hook_active is not true (so never twice), the last message
# has no line that is exactly "No findings.", and the transcript exists and
# holds no Agent call with "subagent_type":"playbook-agents:classify". The mark is written first and in
# every case, blocked or not: the commit hold does not depend on the classifier.
# On input it cannot read, it prints nothing; it always exits 0.
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
case $session in
  '' | *[!A-Za-z0-9_-]*) ;;
  *)
    mkdir -p "$data/review" 2>/dev/null && : > "$data/review/$session" 2>/dev/null
    find "$data/review" "$data/held" -type f -mtime +7 -exec rm -f {} + 2>/dev/null
    ;;
esac

# The check of the classifier.
printf '%s\n' "$input" |
  grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
message=$(json_string last_assistant_message)
[ -n "$message" ] || exit 0
# A clean review says "No findings." as a line of its own; the same words
# inside another line, or beside findings of another part, do not count.
printf '%s\n' "$message" |
  awk '{ gsub(/^[ \t\r]+|[ \t\r]+$/, "") } $0 == "No findings." { found = 1 } END { exit !found }' && exit 0
transcript=$(json_string agent_transcript_path)
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0
grep -Eq '"subagent_type"[[:space:]]*:[[:space:]]*"playbook-agents:classify"' "$transcript" 2>/dev/null && exit 0
printf '%s\n' '{"decision":"block","reason":"This review has findings and started no classifier. Start playbook-agents:classify with the findings, the root of the reviewed tree, and the review identifier, as your instructions say, then end with your full report again, findings included; or, if the review has no findings, end with \"No findings.\"."}'
exit 0
