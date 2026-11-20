#!/bin/sh
# SubagentStart hook for the agents playbook-agents:write and
# playbook-agents:review (repeated-corrections-18, seed-evidence-31): prints the
# index of the rules of level 2 and up that evidence.sh keeps (one line per
# kind with when it applies), and the command that prints one rule, as the
# extra context of the subagent, in one line of JSON. The input has no task
# text, so the subagent compares each "applies when" with its task and reads
# only the rules that match. The command holds absolute paths, since the
# subagent's Bash has no CLAUDE_PLUGIN_ROOT or CLAUDE_PROJECT_DIR. Prints
# nothing and exits 0 in every case it cannot do, and when there is no index:
# it never blocks a subagent.
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

index=$(sh "$plugin/evidence.sh" index "$wiki" 2>/dev/null)
[ -n "$index" ] || exit 0

text="Rules learned from repeated findings, as an index. Compare each line's \"applies when\" with your task. For each kind that matches, run this command before you work, with that kind in place of <kind>, and apply the rule it prints: sh \"$plugin/evidence.sh\" rule <kind> \"$wiki\"
For a kind that does not match, read nothing more.
$index"

printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"%s"}}\n' "$(json_lines "$text")"
exit 0
