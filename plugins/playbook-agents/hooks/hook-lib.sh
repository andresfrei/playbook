# shellcheck shell=sh disable=SC2154
# Shared by review-before-commit.sh and review-ran.sh, which source it with
# ".". Uses only sh, sed, awk, and tr. It expects the hook's JSON in $input and,
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

# commit_dir: the repository directory of the first "git ... commit" in the
# command, following "cd <dir>" and "git -C <dir>"; nothing when there is none.
# A second line says "alone" when every segment before the commit is a "cd" or
# a "git add" without -f or --force, so nothing else changes the repository
# before the commit runs, and "other" when not.
commit_dir() {
  printf '%s' "$command" | awk -v cwd="$cwd" -v home="${HOME:-}" '
  function join(base, d) {
    if (d == "~" || substr(d, 1, 2) == "~/") d = home substr(d, 2)
    return substr(d, 1, 1) == "/" ? d : base "/" d
  }
  function add(t, s) { nt++; tok[nt] = t; sep[nt] = s }
  BEGIN { RS = "\001" }
  {
    text = $0; n = length(text); cur = ""; have = 0; i = 1
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
  }
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
