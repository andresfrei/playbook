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
# <program> with these words among its arguments, in this order. The "if"
# filters of hooks.json are best-effort: Claude Code runs a hook for any command
# holding $(), backticks, or $VAR, so each hook checks the command itself.
has() {
  printf '%s\n' "$command" | awk -v want="$*" -v q="'" '
    BEGIN { n = split(want, w, " ") }
    {
      line = $0
      gsub(/\$\(|`|\(|\)|&&|\|\||[;|&{}]/, " ; ", line)
      m = split(line, t, /[ \t]+/)
      first = 1; k = 0
      for (i = 1; i <= m; i++) {
        tok = t[i]; gsub("^[\"" q "]+|[\"" q "]+$", "", tok)
        if (tok == "") continue
        if (tok == ";") { first = 1; k = 0; continue }
        if (first) {
          if (tok ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || tok ~ /^(do|then|else|elif|if|while|until|!|time)$/) continue
          first = 0
          if (tok == w[1]) k = 1
          if (k == n) { found = 1; exit }
          continue
        }
        if (k > 0 && k < n && tok == w[k + 1]) k++
        if (k == n) { found = 1; exit }
      }
    }
    END { exit !found }'
}
