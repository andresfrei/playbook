#!/bin/sh
# Prints the contract as the extra context of a subagent that starts: one line
# of JSON for the SubagentStart hook. Uses only sh, sed, and awk.
# Prints nothing and exits 0 when the contract is missing.
contract="$(dirname "$0")/../contract.md"
[ -f "$contract" ] || exit 0

tab=$(printf '\t')
cr=$(printf '\r')
# sed escapes backslash, double quote, tab, and carriage return; awk joins the
# lines with \n. Other control characters are not handled. A contract with no
# newline at its end gets one in the text.
text=$(sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$tab/\\\\t/g" -e "s/$cr/\\\\r/g" "$contract" |
  awk '{ printf "%s%s", sep, $0; sep = "\\n" } END { printf "%s", sep }')
printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"%s"}}\n' "$text"
