#!/bin/sh
# PreToolUse hook for every Bash command (ask-before-irreversible-12 and
# ask-before-irreversible-13). R14 makes push, pull requests, merges, and
# releases the owner's decisions: when a segment of the command is
# "git ... push", "gh pr create", "gh pr merge", or "gh release create|edit|delete",
# it answers "ask", so Claude Code shows its permission prompt in every mode,
# for subagents too, every time (ask-before-irreversible-3 to -5). It never
# denies, allows, or remembers an answer.
# The tokenizer of hook-lib.sh splits the command, so a word inside quoted
# text, such as a commit message, is not a command. It follows environment
# variables before a command and the options before the subcommand (-C, -c,
# --git-dir, and others), and reads the text of "sh -c", "bash -c", and "eval"
# once more, one level deep.
# Uses only sh and awk. Unlike the other hooks, when it cannot read its input
# (text that holds no "command" field, or hook-lib.sh missing) it asks: a
# failure here must not let a delivery action through. An empty command and an
# empty input print nothing. Prints nothing and exits 0 in every other case.
ask='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"R14: push, pull requests, merges, and releases are the owner'"'"'s decisions. Confirm this one."}}'
plugin="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || plugin=
lib="$plugin/hooks/hook-lib.sh"

# input is read by json_string, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
[ -f "$lib" ] || {
  [ -n "$input" ] && printf '%s\n' "$ask"
  exit 0
}
# shellcheck source=/dev/null
. "$lib"

command=$(json_string command)
if [ -z "$command" ]; then
  # An empty "command": "" is silent; no readable command field is not.
  [ -z "$input" ] && exit 0
  printf '%s\n' "$input" | grep -Eq '"command"[[:space:]]*:[[:space:]]*""' && exit 0
  printf '%s\n' "$ask"
  exit 0
fi

case $command in
  *git* | *gh*) ;;
  *) exit 0 ;;
esac

# shell_tokens comes from hook-lib.sh.
# shellcheck disable=SC2154
verdict=$(printf '%s' "$command" | awk "$shell_tokens"'
  # base name of a command word: /usr/bin/git is git
  function base(w) { sub(/.*\//, "", w); return w }
  # scan(depth): 1 when a segment of the tokens is an action of R14. At depth 0
  # it also keeps the text of "sh -c", "bash -c", and "eval" in inner[].
  function scan(depth,   i, j, b, k, t) {
    i = 1
    while (i <= nt) {
      if (sep[i]) { i++; continue }
      # skip what comes before the command word: NAME=value, shell keywords,
      # and the wrappers env, sudo, time, command, exec, and nohup with their options
      while (i <= nt && !sep[i]) {
        b = base(tok[i])
        if (tok[i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || b ~ /^(if|then|else|elif|do|while|until|!|\{)$/) i++
        else if (b ~ /^(time|command|exec|nohup)$/) {
          i++
          while (i <= nt && !sep[i] && substr(tok[i], 1, 1) == "-") i++
        } else if (b == "env" || b == "sudo") {
          i++
          while (i <= nt && !sep[i]) {
            if (b == "env" ? tok[i] ~ /^(-u|--unset|-C|--chdir)$/ : tok[i] ~ /^(-u|-g|-h|-p|-D|-R|-T|-U)$/) i += 2
            else if (substr(tok[i], 1, 1) == "-" || tok[i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/) i++
            else break
          }
        } else break
      }
      if (i > nt || sep[i]) continue
      b = base(tok[i])
      if (b == "git") {
        j = i + 1
        while (j <= nt && !sep[j] && substr(tok[j], 1, 1) == "-") {
          if (tok[j] ~ /^(-C|-c|--git-dir|--work-tree|--namespace|--exec-path)$/ && j + 1 <= nt && !sep[j + 1]) j += 2
          else j++
        }
        if (j <= nt && !sep[j] && tok[j] == "push") return 1
      } else if (b == "gh") {
        j = i + 1
        while (j <= nt && !sep[j] && substr(tok[j], 1, 1) == "-") {
          if (tok[j] ~ /^(-R|--repo)$/ && j + 1 <= nt && !sep[j + 1]) j += 2
          else j++
        }
        if (j + 1 <= nt && !sep[j] && !sep[j + 1]) {
          if (tok[j] == "pr" && tok[j + 1] ~ /^(create|merge|new)$/) return 1
          if (tok[j] == "release" && tok[j + 1] ~ /^(create|edit|delete|new)$/) return 1
        }
      } else if (depth == 0 && (b == "sh" || b == "bash")) {
        # options before the script text; -o and -O (also +o, +O, and as the
        # last letter of a group, as in -euo) take an argument
        for (j = i + 1; j <= nt && !sep[j] && tok[j] ~ /^[-+]/; j++) {
          if (tok[j] ~ /^-[A-Za-z]*c[A-Za-z]*$/ && j + 1 <= nt && !sep[j + 1]) { inner[++ni] = tok[j + 1]; break }
          if (tok[j] ~ /^[-+][A-Za-z]*[oO]$/) j++
        }
      } else if (depth == 0 && b == "eval") {
        t = ""
        for (j = i + 1; j <= nt && !sep[j]; j++) t = t (t == "" ? "" : " ") tok[j]
        if (t != "") inner[++ni] = t
      }
      while (i <= nt && !sep[i]) i++
    }
    return 0
  }
  BEGIN { RS = "\001" }
  { text = $0 }
  END {
    tokenize(text)
    if (scan(0)) { print "ask"; exit }
    for (k = 1; k <= ni; k++) {
      tokenize(inner[k])
      if (scan(1)) { print "ask"; exit }
    }
  }')
[ "$verdict" = ask ] && printf '%s\n' "$ask"
exit 0
