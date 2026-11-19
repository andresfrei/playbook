#!/bin/sh
# PreToolUse hook for the Agent tool (setup-commands-10): when the call names
# playbook-agents:explore, write, or review, and the person set a model for
# that agent, adds "model" and, when set, "effort" to the call. The value is
# read from "playbook" > "models" > <agent> in the repository's
# .claude/settings.local.json first, then in the person's settings.json, as
# "<alias> [effort]", such as "opus xhigh". With no value, or a value that is
# not an alias and an effort Claude Code accepts, the call is left as it is
# and the agent's front matter, written from models.conf, applies.
# updatedInput replaces the whole input, so every field received is kept; a
# model the call already names is overridden by the one added after it.
# Uses only sh, sed, and awk. Prints nothing and exits 0 when it does not
# change the call or cannot parse its input: it never stops a call.
plugin="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || exit 0
lib="$plugin/hooks/hook-lib.sh"
[ -f "$lib" ] || exit 0

# input is read by json_string and json_object, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
# shellcheck source=/dev/null
. "$lib"

case $(json_string subagent_type) in
  playbook-agents:explore) agent="explore" ;;
  playbook-agents:write) agent="write" ;;
  playbook-agents:review) agent="review" ;;
  *) exit 0 ;;
esac

cwd=$(json_string cwd)
project=${CLAUDE_PROJECT_DIR:-$cwd}
value=
[ -n "$project" ] && value=$(json_path "$project/.claude/settings.local.json" "playbook/models/$agent")
[ -n "$value" ] || value=$(json_path "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" "playbook/models/$agent")
[ -n "$value" ] || exit 0

set -f
# shellcheck disable=SC2086
set -- $value
[ $# -le 2 ] || exit 0
case ${1:-} in haiku|sonnet|opus|fable) model=$1 ;; *) exit 0 ;; esac
effort=${2:-}
case $effort in ''|low|medium|high|xhigh|max) ;; *) exit 0 ;; esac

object=$(json_object tool_input)
case $object in '{'*'}') ;; *) exit 0 ;; esac
inner=${object#\{}
inner=${inner%\}}
added="\"model\":\"$model\""
[ -n "$effort" ] && added="$added,\"effort\":\"$effort\""
case $inner in *[![:space:]]*) added=",$added" ;; esac
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{%s%s}}}\n' "$inner" "$added"
