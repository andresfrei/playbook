#!/bin/sh
# PreToolUse: for a git commit (an "if" filter of hooks.json matched, and the
# command itself commits).
# When the repository has docs/playbook/ with changes since the last commit, it runs
# the check of the wiki and denies the commit when the check fails. It finds the
# repository from "cd <dir>" at the start of the command or "git -C <dir>", else
# the session's folder; <dir> may be quoted, as Code Mode sends it, and hold
# spaces. On any error of its own it lets the commit through.
# shellcheck disable=SC1091 # lib.sh is sourced at run time.
. "${CLAUDE_PLUGIN_ROOT}/hooks/lib.sh"
command=$(field command)
has git commit || exit 0
cwd=$(field cwd)
dir=${cwd:-.}
# word_after <pattern>: the shell word after the first match of <pattern> in
# $command, without its quotes or backslashes.
word_after() {
  printf '%s\n' "$command" | awk -v pat="$1" -v q="'" '
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      if (!match(text, pat)) exit
      rest = substr(text, RSTART + RLENGTH)
      c = substr(rest, 1, 1)
      if (c == q || c == "\"") {
        rest = substr(rest, 2); i = index(rest, c)
        if (i) print substr(rest, 1, i - 1)
        exit
      }
      out = ""
      for (j = 1; j <= length(rest); j++) {
        c = substr(rest, j, 1)
        if (c == "\\") { j++; out = out substr(rest, j, 1); continue }
        if (c ~ /[ \t\n;&|]/) break
        out = out c
      }
      print out
    }'
}
first=$(word_after '^[ \t]*cd[ \t]+')
other=$(word_after '(^|[ \t;&|])git[ \t]+-C[ \t]+')
for d in "$first" "$other"; do
  case $d in '') ;; /*) dir=$d ;; *) dir=$dir/$d ;; esac
done
# A folder the hook cannot resolve, such as "$repo"/app, falls back to the session's.
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) ||
  root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -d "$root/docs/playbook" ] || exit 0
[ -n "$(git -C "$root" status --porcelain --untracked-files=all -- docs/playbook 2>/dev/null)" ] || exit 0
output=$(sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" "$root/docs/playbook" 2>&1) && exit 0
reason=$(printf 'The check of the wiki failed; the commit is stopped. Repair what it lists, then commit again.\n%s' "$output" |
  awk '{ gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); gsub(/\t/, " "); printf "%s%s", (NR > 1 ? "\\n" : ""), $0 }')
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
