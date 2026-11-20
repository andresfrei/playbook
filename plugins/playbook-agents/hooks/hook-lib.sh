# shellcheck shell=sh disable=SC2154
# Shared by review-before-commit.sh, review-ran.sh, and agent-models.sh, which
# source it with ".". Uses only sh, sed, awk, and tr. It expects the hook's JSON in $input and,
# for commit_dir, the command in $command and the session's folder in $cwd.
# json_string and json_lines are copies of those in
# plugins/playbook-wiki/hooks/git-hook-lib.sh, since a project may install
# playbook-agents without playbook-wiki (review-trigger-7); commit_dir is the
# commit part of its git_parse.

# json_string <key>: the first string value of that key in the input, decoded.
json_string() {
  printf '%s\n' "$input" | awk -v want="$1" '
    # Reads the string that starts after the quote at position p; sets str and
    # pos to the position after the closing quote.
    function readstr(p,   out, c, d, hex) {
      out = ""
      while (p <= n) {
        c = substr(text, p, 1)
        if (c == "\"") { str = out; pos = p + 1; return 1 }
        if (c == "\\") {
          p++; d = substr(text, p, 1)
          if (d == "n") c = "\n"; else if (d == "t") c = "\t"; else if (d == "r") c = "\r"
          else if (d == "b" || d == "f") c = " "
          else if (d == "u") {
            hex = substr(text, p + 1, 4); p += 4
            c = (hex ~ /^00[0-7][0-9a-fA-F]$/) ? sprintf("%c", index("0123456789abcdef", tolower(substr(hex, 3, 1))) * 16 - 16 + index("0123456789abcdef", tolower(substr(hex, 4, 1))) - 1) : "?"
          } else c = d
        }
        out = out c
        p++
      }
      return 0
    }
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      n = length(text); p = 1
      while (p <= n) {
        if (substr(text, p, 1) != "\"") { p++; continue }
        if (!readstr(p + 1)) exit
        key = str; p = pos
        while (substr(text, p, 1) ~ /[ \t\n\r]/) p++
        if (substr(text, p, 1) != ":") continue
        p++
        while (substr(text, p, 1) ~ /[ \t\n\r]/) p++
        if (substr(text, p, 1) != "\"") continue
        if (!readstr(p + 1)) exit
        if (key == want) { printf "%s", str; exit }
        p = pos
      }
    }'
}

# The awk text that splits a Bash command into tokens, shared by commit_dir and
# ask-before-delivery.sh (ask-before-irreversible-12). It defines
# tokenize(text): fills tok[1..nt] with the tokens, outside quoted text, and
# sep[k] is 1 where tok[k] marks a separator (& ; | ( ) or a newline) between
# segments. Backslash, single quotes, and double quotes follow the shell;
# nothing is expanded. It decides nothing about what a token means.
shell_tokens='
function add(t, s) { nt++; tok[nt] = t; sep[nt] = s }
function tokenize(text,   n, cur, have, i, c, d) {
  nt = 0; split("", tok); split("", sep)
  n = length(text); cur = ""; have = 0; i = 1
  while (i <= n) {
    c = substr(text, i, 1)
    if (c == "\\") {
      d = substr(text, i + 1, 1)
      if (d != "\n") { cur = cur d; have = 1 }
      i += 2; continue
    }
    if (c == "\047") {
      i++; have = 1
      while (i <= n && substr(text, i, 1) != "\047") { cur = cur substr(text, i, 1); i++ }
      i++; continue
    }
    if (c == "\"") {
      i++; have = 1
      while (i <= n && substr(text, i, 1) != "\"") {
        c = substr(text, i, 1)
        if (c == "\\" && substr(text, i + 1, 1) ~ /["\\$`]/) { i++; c = substr(text, i, 1) }
        cur = cur c; i++
      }
      i++; continue
    }
    if (c == " " || c == "\t" || c == "\n" || c == "&" || c == ";" || c == "|" || c == "(" || c == ")") {
      if (have) { add(cur, 0); cur = ""; have = 0 }
      if (c != " " && c != "\t") add("", 1)
      i++; continue
    }
    cur = cur c; have = 1; i++
  }
  if (have) add(cur, 0)
}'

# commit_dir: the repository directory of the first "git ... commit" in the
# command, following "cd <dir>" and "git -C <dir>"; nothing when there is none.
# A second line says "alone" when every segment before the commit is a "cd" or
# a "git add" without -f or --force, so nothing else changes the repository
# before the commit runs, and "other" when not.
commit_dir() {
  printf '%s' "$command" | awk -v cwd="$cwd" -v home="${HOME:-}" "$shell_tokens"'
  function join(base, d) {
    if (d == "~" || substr(d, 1, 2) == "~/") d = home substr(d, 2)
    return substr(d, 1, 1) == "/" ? d : base "/" d
  }
  BEGIN { RS = "\001" }
  { tokenize($0) }
  END {
    repo = cwd; alone = 1; i = 1
    while (i <= nt) {
      if (sep[i]) { i++; continue }
      # a segment starts here; leading NAME=value tokens are environment
      start = i
      while (i <= nt && !sep[i] && tok[i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/) i++
      if (i > nt || sep[i]) { alone = 0; continue }
      if (i > start) alone = 0
      if (tok[i] == "cd" && i + 1 <= nt && !sep[i + 1] && tok[i + 1] != "-" && tok[i + 1] != "") {
        repo = join(repo, tok[i + 1])
      }
      if (tok[i] == "git") {
        j = i + 1; r = repo
        while (j <= nt && !sep[j] && tok[j] != "commit") {
          if (tok[j] == "-C" && j + 1 <= nt && !sep[j + 1]) { r = join(r, tok[j + 1]); j += 2 }
          else if (tok[j] == "-c" && j + 1 <= nt && !sep[j + 1]) j += 2
          else if (substr(tok[j], 1, 1) == "-") j++
          else break
        }
        if (j <= nt && !sep[j] && tok[j] == "commit") { printf "%s\n%s\n", r, (alone ? "alone" : "other"); exit }
        if (j <= nt && !sep[j] && tok[j] == "add") {
          for (k = j + 1; k <= nt && !sep[k]; k++) if (tok[k] ~ /^(-f|--force|-[A-Za-z]*f[A-Za-z]*)$/) alone = 0
        } else alone = 0
      } else if (tok[i] != "cd") alone = 0
      while (i <= nt && !sep[i]) i++
    }
  }'
}

# json_lines <text>: the text as the inside of a JSON string. Control
# characters other than a newline, a tab, and a carriage return are dropped;
# sed escapes backslash, double quote, tab, and carriage return; awk joins the
# lines with \n.
json_lines() {
  tab=$(printf '\t')
  cr=$(printf '\r')
  printf '%s\n' "$1" | LC_ALL=C tr -d '\000-\010\013\014\016-\037' |
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e "s/$tab/\\\\t/g" -e "s/$cr/\\\\r/g" |
    awk '{ printf "%s%s", sep, $0; sep = "\\n" }'
}

# The awk function that reads a JSON string, used by json_path and
# json_object: readstr(p) reads the string whose first character is at p in
# text, of length n, sets str to it decoded and pos to the position after the
# closing quote, and returns 0 when the text ends first. \u escapes other than
# ASCII become "?".
json_readstr='
function readstr(p,   out, c, d, hex) {
  out = ""
  while (p <= n) {
    c = substr(text, p, 1)
    if (c == "\"") { str = out; pos = p + 1; return 1 }
    if (c == "\\") {
      p++; d = substr(text, p, 1)
      if (d == "n") c = "\n"; else if (d == "t") c = "\t"; else if (d == "r") c = "\r"
      else if (d == "b" || d == "f") c = " "
      else if (d == "u") {
        hex = substr(text, p + 1, 4); p += 4
        c = (hex ~ /^00[2-7][0-9a-fA-F]$/) ? sprintf("%c", index("0123456789abcdef", tolower(substr(hex, 3, 1))) * 16 - 16 + index("0123456789abcdef", tolower(substr(hex, 4, 1))) - 1) : "?"
      } else c = d
    }
    out = out c
    p++
  }
  return 0
}'

# json_path <file> <path>: the string value at that path of the JSON file,
# decoded, such as "playbook/models/review"; nothing when the file is missing,
# the value is not a string, or the path is absent. Keys are joined with "/";
# an element of an array counts as the key "#".
json_path() {
  [ -f "$1" ] || return 0
  awk -v want="$2" "$json_readstr"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      n = length(text); p = 1; depth = 0
      while (p <= n) {
        c = substr(text, p, 1)
        if (c == ",") { if (type[depth] == "o") expect[depth] = 1; p++; continue }
        if (c ~ /[ \t\n\r:]/) { p++; continue }
        if (c == "{") { depth++; type[depth] = "o"; expect[depth] = 1; key[depth] = ""; p++; continue }
        if (c == "[") { depth++; type[depth] = "a"; expect[depth] = 0; key[depth] = "#"; p++; continue }
        if (c == "}" || c == "]") { depth--; p++; continue }
        if (c == "\"") {
          if (!readstr(p + 1)) exit
          p = pos
          if (type[depth] == "o" && expect[depth]) { key[depth] = str; expect[depth] = 0; continue }
          path = ""
          for (i = 1; i <= depth; i++) path = path (i > 1 ? "/" : "") key[i]
          if (path == want) { printf "%s", str; exit }
          continue
        }
        while (p <= n && substr(text, p, 1) !~ /[,}\] \t\n\r]/) p++
      }
    }' "$1"
}

# json_object <key>: the text of the object that is the value of that key at
# the top level of the input, as written; nothing when there is none.
json_object() {
  printf '%s\n' "$input" | awk -v want="$1" "$json_readstr"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      n = length(text); p = 1; depth = 0
      while (p <= n) {
        c = substr(text, p, 1)
        if (c == "{" || c == "[") { depth++; p++; continue }
        if (c == "}" || c == "]") { depth--; p++; continue }
        if (c != "\"") { p++; continue }
        if (!readstr(p + 1)) exit
        k = str; p = pos
        if (depth != 1 || k != want) continue
        while (substr(text, p, 1) ~ /[ \t\n\r]/) p++
        if (substr(text, p, 1) != ":") continue
        p++
        while (substr(text, p, 1) ~ /[ \t\n\r]/) p++
        if (substr(text, p, 1) != "{") exit
        start = p; d = 0
        while (p <= n) {
          c = substr(text, p, 1)
          if (c == "\"") { if (!readstr(p + 1)) exit; p = pos; continue }
          if (c == "{" || c == "[") d++
          if (c == "}" || c == "]") { d--; if (d == 0) { printf "%s", substr(text, start, p - start + 1); exit } }
          p++
        }
        exit
      }
    }'
}
