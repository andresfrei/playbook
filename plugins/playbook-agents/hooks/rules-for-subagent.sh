#!/bin/sh
# SubagentStart hook for the agents playbook-agents:write and
# playbook-agents:review (repeated-corrections-18): prints the rules of level 2
# and up that evidence.sh keeps, as the extra context of the subagent, in one
# line of JSON. The input has no task text, so each rule says when it applies
# and the subagent judges. Prints nothing and exits 0 in every case it cannot
# do, and when there are no rules: it never blocks a subagent.
plugin="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || exit 0
lib="$plugin/hooks/hook-lib.sh"
[ -f "$lib" ] && [ -f "$plugin/evidence.sh" ] || exit 0

# input is read by json_string and json_lines, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
# shellcheck source=/dev/null
. "$lib"

case $(json_string agent_type) in
  playbook-agents:write | playbook-agents:review) ;;
  *) exit 0 ;;
esac

if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
  wiki=$CLAUDE_PROJECT_DIR/docs/wiki
else
  cwd=$(json_string cwd)
  [ -n "$cwd" ] || exit 0
  wiki=$cwd/docs/wiki
fi

rules=$(sh "$plugin/evidence.sh" rules "$wiki" 2>/dev/null)
[ -n "$rules" ] || exit 0

printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"%s"}}\n' "$(json_lines "$rules")"
exit 0
