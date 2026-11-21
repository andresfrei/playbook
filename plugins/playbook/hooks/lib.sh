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
# "git stash push". It reads the command as a shell does: quotes, backslashes,
# comments, command substitutions, whose commands it reads too, and heredocs,
# whose body it drops unless a shell reads it. It looks through the wrappers
# Claude Code drops before matching a rule (permissions.md): timeout, time,
# nice, nohup, stdbuf, command, builtin, noglob, and xargs; through env and
# sudo; and into the command a shell runs, as in bash -c "git push". The "if" filters of hooks.json are best-effort:
# Claude Code runs a hook for any command holding $(), backticks, or $VAR, so
# each hook checks the command itself.
has() {
  printf '%s\n' "$command" | awk -v want="$*" -v q="'" '
    function flush() { if (inword) { n++; tok[n] = cur; kind[n] = "w"; cur = ""; inword = 0 } }
    function sep() { flush(); n++; tok[n] = ""; kind[n] = "s" }

    # heredocs: the text without the body of each heredoc whose last line is
    # found. A body that a shell reads goes to subs, to be read as commands.
    function heredocs(text,    nl, lines, i, j, out, m, delim, hd, body, shell) {
      hd = "<<-?[ \t]*[\"" q "\\\\]?[A-Za-z_][A-Za-z0-9_]*"
      nl = split(text, lines, "\n"); out = ""
      for (i = 1; i <= nl; i++) {
        out = out lines[i] "\n"
        if (!match(lines[i], hd) || (RSTART > 1 && substr(lines[i], RSTART - 1, 1) == "<")) continue
        delim = substr(lines[i], RSTART, RLENGTH)
        sub(/^<<-?[ \t]*/, "", delim); sub("^[\"" q "\\\\]", "", delim)
        shell = lines[i] ~ /(^|[^A-Za-z0-9_.\/-])(ba|z|da)?sh([ \t]|$)/; body = ""
        for (j = i + 1; j <= nl; j++) {
          m = lines[j]; gsub(/^[ \t]+|[ \t]+$/, "", m)
          if (m == delim) { if (shell) subs[++ns] = body; i = j; break }
          body = body lines[j] "\n"
        }
      }
      return out
    }

    # scan: adds the words and separators of text to tok and kind, and each
    # command substitution to subs. Returns 0 when a quote or a substitution
    # stays open.
    function scan(text,    L, i, j, k, c, d, depth, dq, ok) {
      L = length(text); ok = 1; i = 1; dq = 0
      while (i <= L) {
        c = substr(text, i, 1)
        if (c == "\\") {
          if (substr(text, i + 1, 1) != "\n") { cur = cur substr(text, i + 1, 1); inword = 1 }
          i += 2; continue
        }
        if (c == q && !dq) {
          j = index(substr(text, i + 1), q)
          if (!j) { ok = 0; i++; continue }
          cur = cur substr(text, i + 1, j - 1); inword = 1; i += j + 1; continue
        }
        if (c == "\"") { dq = !dq; inword = 1; i++; continue }
        if (c == "`") {
          j = index(substr(text, i + 1), "`")
          if (!j) { ok = 0; i++; continue }
          subs[++ns] = substr(text, i + 1, j - 1); cur = cur "x"; inword = 1; i += j + 1; continue
        }
        if (c == "$" && substr(text, i + 1, 1) == "(") {
          depth = 1; k = i + 2
          while (k <= L && depth > 0) {
            d = substr(text, k, 1)
            if (d == "\\") { k += 2; continue }
            if (d == "(") depth++; else if (d == ")") depth--
            k++
          }
          if (depth > 0) ok = 0
          subs[++ns] = substr(text, i + 2, k - i - 2 - (depth == 0))
          cur = cur "x"; inword = 1; i = k; continue
        }
        if (dq) { cur = cur c; i++; continue }
        if (c == "#" && !inword) {
          j = index(substr(text, i), "\n")
          i = j ? i + j - 1 : L + 1; continue
        }
        if (c == " " || c == "\t" || c == ">" || c == "<") { flush(); i++; continue }
        if (c == "\n" || c == ";" || c == "&" || c == "|" || c == "(" || c == ")") { sep(); i++; continue }
        cur = cur c; inword = 1; i++
      }
      if (dq) ok = 0
      sep()
      return ok
    }

    # naive: the words of text with its quotes ignored, for a text scan could
    # not read to its end.
    function naive(text,    m, t, i) {
      n = 0; gsub(/\$\(|`|\(|\)|[;|&\n]/, " ; ", text)
      m = split(text, t, /[ \t]+/)
      for (i = 1; i <= m; i++) {
        gsub("^[\"" q "]+|[\"" q "]+$", "", t[i])
        if (t[i] == "") continue
        n++
        if (t[i] == ";") { tok[n] = ""; kind[n] = "s" } else { tok[n] = t[i]; kind[n] = "w" }
      }
    }

    # takesarg: whether the option t of a wrapper takes the next word.
    function takesarg(wrap, t) {
      if (t ~ /^--(signal|kill-after|adjustment|user|group)$/) return 1
      return t ~ /^-[A-Za-z]$/ && index(argflags[wrap], substr(t, 2, 1)) > 0
    }

    # runs: whether a simple command among the words, from the word at "from",
    # runs the program wanted. The words a shell or eval runs go to subs.
    function runs(from,    i, t, p, state, k, wrap, skip) {
      state = "first"; k = 0; wrap = ""; skip = 0
      for (i = from; i <= n; i++) {
        t = tok[i]
        if (kind[i] == "s") { state = "first"; k = 0; wrap = ""; skip = 0; continue }
        if (skip) { skip = 0; continue }
        if (state == "shell") { if (t !~ /^-/) subs[++ns] = t; continue }
        if (state == "first") {
          if (wrap != "" && wrap != "done") {
            if (t ~ /^-/) { if (takesarg(wrap, t)) skip = 1; continue }
            if (wrap == "timeout") { wrap = "done"; continue }
          }
          if (t ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || t ~ /^(do|then|else|elif|if|while|until|!|nohup|builtin|noglob|[{]|[}])$/) continue
          p = t; sub(/^.*\//, "", p)
          if (p == "command" && tok[i + 1] ~ /^-[vV]$/) { state = "other"; continue }
          if (p ~ /^(timeout|nice|stdbuf|time|command|env|sudo|xargs)$/) { wrap = p; continue }
          if (p ~ /^(bash|sh|zsh|dash|eval)$/) { state = "shell"; continue }
          state = (p == w[1]) ? "match" : "other"; k = 1
          if (state == "match" && k == nw) return 1
          continue
        }
        if (state != "match") continue
        if (t ~ /^-/) { if (t ~ /^(-C|-c|-R|--repo|--git-dir|--work-tree|--namespace)$/) skip = 1; continue }
        if (t == w[k + 1]) { k++; if (k == nw) return 1 } else state = "other"
      }
      return 0
    }

    BEGIN {
      nw = split(want, w, " ")
      argflags["timeout"] = "sk"; argflags["nice"] = "n"; argflags["stdbuf"] = "ioe"; argflags["time"] = "of"
      argflags["env"] = "uCS"; argflags["sudo"] = "ugChpU"; argflags["xargs"] = "nILPsdEa"
    }
    { text = text $0 "\n" }
    END {
      text = heredocs(text)
      ok = scan(text); read = 0; from = 1
      while (1) {
        while (read < ns) if (!scan(subs[++read])) ok = 0
        if (runs(from)) { found = 1; break }
        from = n + 1
        if (read == ns) break
      }
      if (!found && !ok) { naive(text); found = runs(1) }
      exit !found
    }'
}
