# shellcheck shell=sh
# shellcheck disable=SC2154 # $command is set by the hook that sources this.
# Shared by the PreToolUse hooks; sourced, not run. Reads the hook's JSON
# input once into $input.
input=$(cat)

# field <name>: the value of a JSON string field of the input, with its
# escapes decoded enough for commands and paths.
field() {
  printf '%s' "$input" | awk -v key="\"$1\"" '
    { text = text $0 }
    END {
      i = index(text, key); if (!i) exit
      rest = substr(text, i + length(key)); sub(/^[ \t]*:[ \t]*"/, "", rest)
      out = ""
      for (j = 1; j <= length(rest); j++) {
        c = substr(rest, j, 1)
        if (c == "\\") {
          j++; c = substr(rest, j, 1)
          if (c == "n") c = "\n"; else if (c == "t") c = "\t"; else if (c == "r") c = ""
          out = out c; continue
        }
        if (c == "\"") break
        out = out c
      }
      print out
    }'
}

# has <program> <word>...: whether one of the simple commands in $command runs
# <program> with these words as its subcommands, in this order, options aside:
# "has git push" holds for "git -C dir push" and "timeout 60 git push", not for
# "git stash push". It drops the wrappers Claude Code drops before matching a
# rule (permissions.md): timeout, time, nice, nohup, stdbuf, command, builtin,
# noglob, and a bare xargs. The "if" filters of hooks.json are best-effort:
# Claude Code runs a hook for any command holding $(), backticks, or $VAR, so
# each hook checks the command itself.
has() {
  printf '%s\n' "$command" | awk -v want="$*" -v q="'" '
    BEGIN { n = split(want, w, " ") }
    {
      line = $0
      gsub(/\$\(|`|\(|\)|&&|\|\||[;|&{}]/, " ; ", line)
      m = split(line, t, /[ \t]+/)
      for (i = 1; i <= m; i++) { raw[i] = t[i]; gsub("^[\"" q "]+|[\"" q "]+$", "", t[i]) }
      state = "first"; k = 0; wrap = ""; skip = 0; open = ""
      for (i = 1; i <= m; i++) {
        tok = t[i]
        if (tok == "") continue
        if (tok == ";") { state = "first"; k = 0; wrap = ""; skip = 0; open = ""; continue }
        # The value of an option may be quoted and hold spaces: skip to its end.
        if (open != "") { if (substr(raw[i], length(raw[i])) == open) open = ""; continue }
        if (skip) {
          skip = 0; c = substr(raw[i], 1, 1)
          if ((c == q || c == "\"") && (length(raw[i]) == 1 || substr(raw[i], length(raw[i])) != c)) open = c
          else if (raw[i] ~ /\\$/) skip = 1
          continue
        }
        if (state == "first") {
          if (wrap != "") {
            if (tok ~ /^-/) { if (tok ~ /^-[nskioe]$|^--(signal|kill-after|adjustment)$/) skip = 1; continue }
            if (wrap == "timeout" && tok ~ /^[0-9.]+[smhd]?$/) { wrap = "done"; continue }
          }
          if (tok ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || tok ~ /^(do|then|else|elif|if|while|until|!|time|nohup|builtin|noglob)$/) continue
          if (tok == "command" && t[i + 1] !~ /^-[vV]$/) continue
          if (tok == "xargs" && t[i + 1] !~ /^-/) continue
          if (tok ~ /^(timeout|nice|stdbuf)$/) { wrap = tok; continue }
          state = (tok == w[1]) ? "match" : "other"; k = 1
          if (state == "match" && k == n) { found = 1; exit }
          continue
        }
        if (state != "match") continue
        if (tok ~ /^-/) { if (tok ~ /^(-C|-c|-R|--repo|--git-dir|--work-tree|--namespace)$/) skip = 1; continue }
        if (tok == w[k + 1]) { k++; if (k == n) { found = 1; exit } } else state = "other"
      }
    }
    END { exit !found }'
}
