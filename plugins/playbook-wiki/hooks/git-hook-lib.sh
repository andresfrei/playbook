# shellcheck shell=sh disable=SC2154
# Shared by merge-step-hook.sh and commit-check-hook.sh, which source it with
# ".". Uses only sh, sed, and awk. It expects the hook's JSON in $input and,
# for git_parse, the command in $command and the session's folder in $cwd.

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

# git_parse <subcommand>: finds the first "git <subcommand>" in the command.
# For "merge" it prints the repository directory, the ref merged, and the
# branch merged into (empty when unknown), one per line, and nothing when the
# command merges no ref. For "commit" it prints the repository directory.
# Prints nothing when the subcommand is not found.
git_parse() {
  printf '%s' "$command" | awk -v want="$1" -v cwd="$cwd" -v home="${HOME:-}" '
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
    repo = cwd; ours = ""; fresh = 0; i = 1
    while (i <= nt) {
      if (sep[i]) { i++; continue }
      # a segment starts here; leading NAME=value tokens are environment
      while (i <= nt && !sep[i] && tok[i] ~ /^[A-Za-z_][A-Za-z0-9_]*=/) i++
      if (i > nt || sep[i]) continue
      if (tok[i] == "cd" && i + 1 <= nt && !sep[i + 1] && tok[i + 1] != "-" && tok[i + 1] != "") {
        repo = join(repo, tok[i + 1])
      }
      if (tok[i] == "git") {
        j = i + 1; r = repo
        while (j <= nt && !sep[j] && tok[j] != want && tok[j] != "checkout" && tok[j] != "switch") {
          if (tok[j] == "-C" && j + 1 <= nt && !sep[j + 1]) { r = join(r, tok[j + 1]); j += 2 }
          else if (tok[j] == "-c" && j + 1 <= nt && !sep[j + 1]) j += 2
          else if (substr(tok[j], 1, 1) == "-") j++
          else break
        }
        if (j <= nt && !sep[j] && (tok[j] == "checkout" || tok[j] == "switch")) {
          # the branch checked out is the branch merged into; a new branch has nothing to compare
          j++; target = ""; made = 0
          while (j <= nt && !sep[j]) {
            t = tok[j]
            if (t == "--") break
            if (t ~ /^(-b|-B|-c|-C|--create|--force-create|--orphan)$/ || t ~ /^(-b|-B|-c|-C)./ || t ~ /^--(create|force-create|orphan)=/) {
              made = 1
              if (t ~ /^(-b|-B|-c|-C|--create|--force-create|--orphan)$/) j++
            } else if (t == "-") { if (target == "") target = "@{-1}" }
            else if (substr(t, 1, 1) != "-" && target == "") target = t
            j++
          }
          if (made) fresh = 1
          else if (target != "") { ours = target; fresh = 0 }
        }
        else if (j <= nt && !sep[j] && tok[j] == "commit" && want == "commit") { printf "%s\n", r; exit }
        else if (j <= nt && !sep[j] && tok[j] == "merge" && want == "merge") {
          j++
          while (j <= nt && !sep[j]) {
            t = tok[j]
            if (t == "--abort" || t == "--continue" || t == "--quit" || t == "--skip") exit
            if (t ~ /^(-m|--message|-s|--strategy|-X|--strategy-option|-F|--file|--into-name)$/) { j += 2; continue }
            if ((substr(t, 1, 1) == "-" && t != "-") || t == "") { j++; continue }
            if (fresh) exit
            printf "%s\n%s\n%s\n", r, t, ours
            exit
          }
          exit
        }
      }
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
